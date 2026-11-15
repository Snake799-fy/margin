extends Control
## Phase 3 - Cargo manifest (CML 4, space segment): pack the lander's 7x5 grid.
## Left: cargo list. Center: grid + what is still missing. Right: buttons + the item under the mouse.
## Click an item then a cell to place. Right click (or drag out) removes. R / mouse wheel rotates.

var main
var grid: CargoGrid
var info: Label
var todo: Array = []
var list_buttons := {}
var trash: Button
var hand: Label

func _trash() -> void:
	if grid.selected != "":
		grid.discard_held()
	else:
		info.text = "TO TRASH:\nRIGHT CLICK AN\nITEM IN THE\nGRID, OR DRAG\nIT OFF THE GRID."

const HINT := {
	"hot": "Hot: keep tubes and medkit away.",
	"contaminant": "Dirty: keep away from the tubes.",
	"clean": "Sterile: away from drill and heat.",
	"heat_sensitive": "Keep away from the reactor.",
	"water": "Next to the shelter = shield.",
	"shelter": "Put water next to it.",
}

func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(UI.place(scroll, 2, 20, 106, 158))
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 1)
	vb.custom_minimum_size.x = 96
	scroll.add_child(vb)
	for c in GS.D["components"]:
		var id: String = c["id"]
		var b := UI.button("", func(): _pick(id), UI.SMALL)
		b.icon = load("res://art/items/item_%s.png" % id)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 10)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(96, 14)
		b.clip_text = true
		b.mouse_entered.connect(func(): _show(id))
		vb.add_child(b)
		list_buttons[id] = b
	add_child(UI.place(UI.label("STEP 3/7 - PACK THE LANDER", UI.SMALL, UI.SAND), 112, 20))
	UI.stepper(self, 3, 248, 29)
	grid = CargoGrid.new()
	add_child(UI.place(grid, 112, 30))
	grid.changed.connect(_on_changed)
	grid.placed.connect(func(): GS.snd.sfx("place"))
	grid.picked.connect(func(): GS.snd.sfx("pick"))
	grid.refused.connect(func(): GS.snd.sfx("error"))
	grid.discarded.connect(func(): GS.snd.sfx("pick"))
	grid.hovered.connect(func(id): if id != "": _show(id))
	GS.prune_grid()
	GS.ensure_required()
	for i in 4:
		var l := UI.label("", UI.SMALL)
		add_child(UI.place(l, 112, 113 + i * 9))
		todo.append(l)
	var bx := 230
	add_child(UI.place(UI.button("ROTATE", func(): grid.rotate_piece(), UI.SMALL), bx, 36, 86, 14))
	trash = UI.button("TRASH", _trash, UI.SMALL)
	add_child(UI.place(trash, bx, 52, 86, 14))
	add_child(UI.place(UI.button("CLEAR ALL", func(): GS.placements.clear(); GS.ensure_required(); grid.select(""); _on_changed(), UI.SMALL), bx, 68, 86, 14))
	add_child(UI.place(UI.button("< BACK", func(): main.goto("trade"), UI.SMALL), 112, 163, 60, 15))
	add_child(UI.place(UI.button("NEXT >", func(): main.goto("review"), UI.SMALL), bx, 163, 86, 15))
	hand = UI.label("", UI.SMALL, UI.YELLOW)
	hand.clip_text = true
	add_child(UI.place(hand, bx, 86, 88, 8))
	info = UI.label("", UI.SMALL, UI.WHITE, true)
	add_child(UI.place(info, bx, 96, 88, 64))
	info.text = "CLICK AN ITEM,\nTHEN THE GRID.\nDRAG TO MOVE.\nRIGHT CLICK =\nTRASH."
	combo_l = UI.label("", UI.SMALL, UI.GREEN)
	combo_l.clip_text = true
	add_child(UI.place(combo_l, 112, 150, 116, 8))
	last_combos = GS.combos()
	_on_changed()

var combo_l: Label
var last_combos: Array = []

func _pick(id: String) -> void:
	if GS.count_of(id) >= GS.max_count(id):
		info.text = "%s\nALREADY LOADED." % GS.short_name(id).to_upper()
		GS.snd.sfx("error")
		return
	grid.select(id)
	_show(id)

func _show(id: String) -> void:
	if id == "": return
	if id.begins_with("locked:"):
		info.text = "%s\nREQUIRED FOR\nTHE OBJECTIVE.\nLOCKED." % GS.short_name(id.substr(7)).to_upper()
		return
	var c = GS.comp[id]
	var t := "%s\n%st  %dM$" % [GS.short_name(id).to_upper(), str(c["mass_t"]), c["cost"]]
	var e := float(c.get("energy_kwh_sol", 0.0)) + float(c.get("energy_per_sol_kwh", 0.0))
	if e != 0.0: t += "\nPOWER %+.0f" % e
	if c.has("supply_sols"): t += "\n+%d SOLS FOOD" % c["supply_sols"]
	if id == "charger": t += "\nRobot recharges at the lander."
	if id == "beacon": t += "\nCrew installs: robot keeps signal."
	var active: Array = GS.combos()
	var shown := 0
	for k in GS.combos_of(id):
		if shown >= 2: break
		var cb: Dictionary = GS.COMBOS[k]
		var other: String = cb["b"][0] if cb["a"] == id else cb["a"]
		t += "\n%s+%s: %s" % ["* " if k in active else "", GS.short_name(other).to_upper(), cb["text"]]
		shown += 1
	if shown == 0:
		for tg in c.get("tags", []):
			if HINT.has(tg):
				t += "\n" + HINT[tg]
				break
	info.text = t

func _process(_d: float) -> void:
	if hand:
		hand.text = ("> " + GS.short_name(grid.selected).to_upper()) if grid.selected != "" else ""
		trash.text = "TRASH IT" if grid.selected != "" else "TRASH"

func _on_changed() -> void:
	for id in list_buttons:
		var n := GS.count_of(id)
		var m := GS.max_count(id)
		var b: Button = list_buttons[id]
		b.text = GS.short_name(id) + ("" if n == 0 else (" x%d" % n if m > 1 else ""))
		var req: bool = id in GS.required_ids()
		b.modulate = Color(1, 1, 1, 0.5) if n >= m and not req else Color.WHITE
		b.add_theme_color_override("font_color", UI.YELLOW if req else UI.WHITE)
	# only what is still missing
	var s := GS.stats()
	var need := GS.food_need()
	var miss := []
	if s["mass"] > s["cap"]: miss.append(["HEAVY %.0f/%.0fT" % [s["mass"], s["cap"]], UI.RED])
	if s["cost"] > s["budget"]: miss.append(["MONEY %d" % int(s["budget"] - s["cost"]), UI.RED])
	if s["energy"] < 0: miss.append(["POWER %+.0f" % s["energy"], UI.YELLOW])
	if s["supply"] < need: miss.append(["FOOD %.0f/%d SOLS" % [s["supply"], need], UI.YELLOW])
	if s["downlink"] <= 0: miss.append(["NO RADIO", UI.YELLOW])
	if not GS.has("shelter"): miss.append(["NO SHELTER", UI.YELLOW])
	var bad := 0
	for a in s["adj"]:
		if a["rule"] != "shielding": bad += 1
	if bad > 0: miss.append(["%d BAD NEIGHBOR%s" % [bad, "S" if bad > 1 else ""], UI.ORANGE])
	for i in todo.size():
		todo[i].text = ""
	if miss.is_empty():
		todo[0].text = "ALL SET!"
		todo[0].add_theme_color_override("font_color", UI.GREEN)
		todo[1].text = "PRESS NEXT >"
		todo[1].add_theme_color_override("font_color", UI.GREEN)
	else:
		todo[0].text = "MISSING:"
		todo[0].add_theme_color_override("font_color", UI.GREY)
		for i in min(miss.size(), todo.size() - 1):
			todo[i + 1].text = "! " + miss[i][0]
			todo[i + 1].add_theme_color_override("font_color", miss[i][1])
	# combos: a short line, flashing when a new one forms
	var cmb: Array = GS.combos()
	var names: Array = []
	for k in cmb: names.append(GS.COMBOS[k]["name"])
	combo_l.text = ("%d COMBO%s ON!" % [names.size(), "S" if names.size() > 1 else ""]) if not names.is_empty() else "TIP: TRY COMBOS!"
	combo_l.add_theme_color_override("font_color", UI.GREEN if not names.is_empty() else UI.GREY)
	for k in cmb:
		if not k in last_combos:
			GS.snd.sfx("success")
			grid.flash_combo(GS.COMBOS[k]["name"] + "! " + GS.COMBOS[k]["text"])
	last_combos = cmb
	if main: main.refresh_hud()
