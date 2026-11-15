class_name CargoGrid
extends Control
## The 7x5 cargo grid of the lander (heart of the game).
## Click a component in the list, then click a cell. Right click / R rotates.
## Press on a placed item to pick it up and drag it. Adjacency lines show
## BEFORE you drop the piece.

signal changed
signal hovered(id: String)
signal placed
signal picked
signal refused
signal discarded

const CELL := 16
const RULE_COLOR := {"heat": UI.ORANGE, "contamination": UI.BROWN, "shielding": UI.SKY}

var cols := 7
var rows := 5
var selected := ""     # component id in hand
var rot := false
var hover := Vector2i(-1, -1)
var dragging := false
var grab := Vector2i.ZERO      # which cell of the piece the mouse holds
var origin := {}               # where a dragged piece came from (to snap back)
var tex_cache := {}

func _ready() -> void:
	cols = GS.grid_cols()
	rows = GS.grid_rows()
	size = Vector2(cols * CELL, rows * CELL)
	mouse_filter = Control.MOUSE_FILTER_STOP

func tex(id: String) -> Texture2D:
	if not tex_cache.has(id):
		tex_cache[id] = load("res://art/items/item_%s.png" % id)
	return tex_cache[id]

func dims(id: String, r: bool) -> Vector2i:
	var c = GS.comp[id]
	return Vector2i(c["h"], c["w"]) if r else Vector2i(c["w"], c["h"])

func select(id: String) -> void:
	selected = id
	rot = false
	grab = Vector2i.ZERO
	origin = {}
	dragging = false
	queue_redraw()

## Throws away the piece in hand (if it was on the grid, it is simply not put back).
func discard_held() -> void:
	if selected == "": return
	selected = ""
	origin = {}
	dragging = false
	discarded.emit()
	changed.emit()
	queue_redraw()

func ghost() -> Dictionary:
	if selected == "" or hover.x < 0: return {}
	var d := dims(selected, rot)
	var tl := hover - Vector2i(min(grab.x, d.x - 1), min(grab.y, d.y - 1))
	return {"id": selected, "x": tl.x, "y": tl.y, "w": d.x, "h": d.y, "rot": rot}

func ghost_ok(g: Dictionary) -> bool:
	if g.is_empty(): return false
	if GS.count_of(g["id"]) >= GS.max_count(g["id"]): return false
	return GS.can_place(g["id"], g["x"], g["y"], g["w"], g["h"])

func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		var c := Vector2i(int(e.position.x) / CELL, int(e.position.y) / CELL)
		if c != hover:
			hover = c
			var i := GS.cell_owner(c)
			hovered.emit(GS.placements[i]["id"] if i >= 0 else selected)
			queue_redraw()
	elif e is InputEventMouseButton and e.pressed and e.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		rotate_piece()
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT:
		# holding a piece: put it back; otherwise remove the item under the mouse
		if selected != "":
			discard_held()
			return
		var i := GS.cell_owner(hover)
		if GS.is_locked(i):
			refused.emit()
			hovered.emit("locked:" + GS.placements[i]["id"])
		elif i >= 0:
			GS.placements.remove_at(i)
			discarded.emit()
			changed.emit()
			queue_redraw()
	elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			if selected != "":
				try_place()
			else:
				var i := GS.cell_owner(hover)
				if GS.is_locked(i):
					refused.emit()
					hovered.emit("locked:" + GS.placements[i]["id"])
				elif i >= 0:
					var p = GS.placements[i]
					GS.placements.remove_at(i)
					selected = p["id"]
					rot = p.get("rot", false)
					grab = hover - Vector2i(p["x"], p["y"])
					origin = p
					dragging = true
					picked.emit()
					changed.emit()
					queue_redraw()
		elif dragging:
			dragging = false
			if not Rect2(Vector2.ZERO, size).has_point(e.position):
				discard_held()   # dropped outside the grid = thrown away
				return
			if not ghost_ok(ghost()) and not origin.is_empty():
				# does not fit there: snap back to where it was
				GS.placements.append(origin)
				refused.emit()
				selected = ""
				origin = {}
				changed.emit()
				queue_redraw()
				return
			try_place()

func _unhandled_key_input(e: InputEvent) -> void:
	if e.pressed and (e as InputEventKey).keycode == KEY_R:
		rotate_piece()

func rotate_piece() -> void:
	if selected == "": return
	rot = not rot
	queue_redraw()

func try_place() -> void:
	var g := ghost()
	if not ghost_ok(g):
		if not g.is_empty(): refused.emit()
		return
	GS.placements.append(g)
	placed.emit()
	origin = {}
	grab = Vector2i.ZERO
	if GS.count_of(selected) >= GS.max_count(selected):
		selected = ""
	changed.emit()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		hover = Vector2i(-1, -1)
		queue_redraw()

func _rect(p: Dictionary) -> Rect2:
	return Rect2(p["x"] * CELL, p["y"] * CELL, p["w"] * CELL, p["h"] * CELL)

func _draw_item(p: Dictionary, mod := Color.WHITE) -> void:
	var r := _rect(p)
	var t := tex(p["id"])
	if p.get("rot", false):
		# texture is drawn in its original orientation, rotated 90 degrees around the rect center
		var center := r.get_center()
		draw_set_transform(center, PI / 2.0, Vector2.ONE)
		var ts := t.get_size()
		draw_texture_rect(t, Rect2(-ts / 2.0, ts), false, mod)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect(t, r, false, mod)

func _draw() -> void:
	# cells
	draw_rect(Rect2(Vector2.ZERO, size), Color(UI.DARK, 0.85))
	for x in cols:
		for y in rows:
			draw_rect(Rect2(x * CELL, y * CELL, CELL, CELL), Color(UI.RUST, 0.8), false, 1.0)
	# placed items
	for p in GS.placements:
		_draw_item(p)
		if p.get("locked", false):
			draw_rect(_rect(p).grow(-1), UI.YELLOW, false, 1.0)
	# ghost + preview adjacency
	var list: Array = GS.placements
	var g := ghost()
	if not g.is_empty():
		var ok := ghost_ok(g)
		_draw_item(g, Color(0.6, 1, 0.6, 0.75) if ok else Color(1, 0.4, 0.4, 0.6))
		if ok:
			list = GS.placements.duplicate()
			list.append(g)
	for c in GS.combo_pairs(list):
		var ca: Vector2 = _rect(list[c[0]]).get_center(); var cb2: Vector2 = _rect(list[c[1]]).get_center()
		var pulse := 0.6 + 0.4 * sin(Time.get_ticks_msec() / 150.0)
		draw_line(ca, cb2, Color(UI.GREEN, pulse), 2.0)
		draw_circle(ca.lerp(cb2, 0.5), 3.0, Color(UI.GREEN, pulse))
	for a in GS.adjacency(list):
		var pa = list[a["a"]]; var pb = list[a["b"]]
		var col: Color = RULE_COLOR[a["rule"]]
		draw_line(_rect(pa).get_center(), _rect(pb).get_center(), col, 2.0)
		draw_circle(_rect(pa).get_center(), 2.5, col)
		draw_circle(_rect(pb).get_center(), 2.5, col)
	draw_rect(Rect2(Vector2.ZERO, size), UI.SAND, false, 1.0)


func _process(_d: float) -> void:
	if not GS.combo_pairs().is_empty(): queue_redraw()

## Juice: green flash + floating text when a new combo forms.
func flash_combo(t: String) -> void:
	var fl := ColorRect.new()
	fl.color = Color(UI.GREEN, 0.45)
	fl.size = size
	fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fl)
	var l := UI.label(t, UI.SMALL, UI.GREEN)
	l.add_theme_color_override("font_outline_color", UI.DARK)
	l.add_theme_constant_override("outline_size", 3)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(maxf(size.x, 120), 8)
	l.position = Vector2((size.x - l.size.x) / 2.0, size.y / 2.0 - 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	var tw := create_tween().set_parallel()
	tw.tween_property(fl, "color:a", 0.0, 0.35)
	tw.tween_property(l, "position:y", l.position.y - 14, 1.4)
	tw.tween_property(l, "modulate:a", 0.0, 1.4).set_delay(0.6)
	tw.chain().tween_callback(func(): fl.queue_free(); l.queue_free())
	var base := position
	var sh := create_tween()
	for i in 4: sh.tween_property(self, "position", base + Vector2(randf_range(-2, 2), randf_range(-1, 1)), 0.03)
	sh.tween_property(self, "position", base, 0.03)
