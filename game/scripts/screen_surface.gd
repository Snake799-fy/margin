extends Control
## Phase 6 - Surface (ground segment). Direct control, like a game pad:
##   WASD / arrows (hold) : move the selected unit      Q : switch ROBOT <-> CREW
##   E / SPACE            : interact (sample a target, end the sol at the lander)
##   Click the map        : the selected unit walks there    TAB : crew and details
## The crew starts an EVA by stepping out of the lander and ends it by stepping back in.

var main
const CELL := 16
const VIEW := Rect2(0, 18, 320, 148)

var view: Control
var world: Node2D
var fog: Node2D
var markers := {}
var crew_sprites: Array = []
var rover_sprite: AnimatedSprite2D
var scout_sprite: AnimatedSprite2D
var lost_icon: AnimatedSprite2D
var dust_fx: AnimatedSprite2D
var hazard_sprites: Array = []
var path_nodes: Array = []
var prompt: Label
var sel_ring: AnimatedSprite2D
var focus := Vector2.ZERO

var top_sol: Label
var top_scan: Label
var tab_robot: Button
var tab_crew: Button
var toast: Label
var toast_bg: ColorRect
var toast_t := 0.0
var btn_end: Button
var popup: Control
var info_panel: Control
var motor := AudioStreamPlayer.new()        # robot servo
var motor_rv := AudioStreamPlayer.new()     # crew rover rumble

var ctrl := "robot"            # "robot" or "crew"
var team: Array = []
var use_rover := true
var auto_path: Array = []
var cooldown := 0.0
var busy := false              # moving tween / sampling / event
var idle_t := 0.0
var warned := false
var beep_t := 0.0
var current_event := {}
var help_seen := false
var crew_cell := Vector2i.ZERO # crew position (lander when inside)
var crew_returning := false    # crew walks home on its own (no control)
var end_after_return := false
var robot_returning := false   # robot drives home to its charger on reserve power
var beacon_sprites: Array = []
var mark_sprites: Array = []
var map_panel: Control
var key_e: Label               # bottom bar: what E does right now
var sci_label: Label           # mission progress (science points so far)
var sci_bar: TextureProgressBar
var obj_label: Label
const SHORT_OPT := {"shelter_in_place": "STAY INSIDE", "short_eva": "SHORT EVA", "push_on": "PUSH ON",
	"use_shelter": "TO THE SHELTER", "rush_back": "RUSH BACK", "ignore": "IGNORE IT", "repair": "REPAIR",
	"improvise": "IMPROVISE", "drop_equipment": "STOP USING IT", "treat": "TREAT", "rest": "REST",
	"continue": "CONTINUE", "buffer": "BUFFER DATA", "prioritize": "SEND BEST DATA"}
const EVENT_SFX := {"dust_storm": "ev_dust", "solar_particle_event": "ev_geiger", "equipment_failure": "ev_clank",
	"medical_issue": "ev_heart", "relay_pass_missed": "ev_static", "dust_devil": "ev_whirl", "suit_leak": "ev_hiss",
	"ankle": "ev_thud", "find": "ev_chime", "stuck": "ev_spin", "reactor_hot": "ev_geiger", "dusty_panels": "ev_dust",
	"filter_clog": "ev_hiss", "tank_leak": "ev_hiss", "antenna_off": "ev_static", "rover_flat": "ev_clank",
	"crate_dent": "ev_thud", "spectro_hint": "ev_chime", "clear_sky": "success"}

func _ready() -> void:
	clip_contents = true
	for pair in [[motor, "sfx_motor_robot", -9.0], [motor_rv, "sfx_motor_rover", -6.0]]:
		var pl: AudioStreamPlayer = pair[0]
		pl.stream = load("res://audio/%s.ogg" % pair[1])
		if pl.stream is AudioStreamOggVorbis: pl.stream.loop = true
		pl.volume_db = pair[2]
		add_child(pl)
	# --- world ---
	view = Control.new()
	view.position = VIEW.position
	view.size = VIEW.size
	view.clip_contents = true
	view.mouse_filter = Control.MOUSE_FILTER_STOP
	view.gui_input.connect(_on_view_input)
	add_child(view)
	world = Node2D.new()
	view.add_child(world)
	var map_layer := TileMapLayer.new()
	map_layer.tile_set = preload("res://resources/margin_tileset.tres")
	world.add_child(map_layer)
	for y in GS.WORLD_H:
		for x in GS.WORLD_W:
			map_layer.set_cell(Vector2i(x, y), 0, Vector2i("PRSHLT".find(GS.tile(Vector2i(x, y))), 0))
	for oc in GS.obstacles:
		var ob := Sprite2D.new()
		ob.centered = false
		ob.texture = load("res://art/map/map_%s.png" % GS.obstacles[oc])
		ob.position = Vector2(oc * CELL)
		world.add_child(ob)
	var lander := UI.frames("res://art/anim/map/tile_lander_frames.tres")
	lander.position = Vector2(GS.lander * CELL)
	lander.play(&"blink")
	world.add_child(lander)
	for p in GS.pois:
		var m := UI.frames("res://art/anim/map/map_marker_target_frames.tres")
		m.position = Vector2(p["pos"] * CELL) + Vector2(0, -8)
		m.play(&"bob")
		world.add_child(m)
		markers[p["id"]] = m
	sel_ring = UI.frames("res://art/anim/map/map_cursor_frames.tres")
	sel_ring.play(&"pulse")
	world.add_child(sel_ring)
	scout_sprite = AnimatedSprite2D.new()
	scout_sprite.centered = false
	scout_sprite.sprite_frames = _robot_frames()
	scout_sprite.play(&"idle")
	world.add_child(scout_sprite)
	rover_sprite = AnimatedSprite2D.new()
	rover_sprite.centered = false
	world.add_child(rover_sprite)
	fog = FogLayer.new()
	world.add_child(fog)
	lost_icon = UI.frames("res://art/anim/ui/ui_alert_icon_frames.tres")
	lost_icon.play(&"blink")
	world.add_child(lost_icon)
	prompt = UI.label("", UI.SMALL, UI.YELLOW)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_color_override("font_outline_color", UI.DARK)
	prompt.add_theme_constant_override("outline_size", 3)
	world.add_child(prompt)
	dust_fx = UI.frames("res://art/anim/fx/fx_dust_overlay_frames.tres")
	dust_fx.play(&"loop")
	dust_fx.position = Vector2(0, -18)
	view.add_child(dust_fx)
	# --- top strip ---
	var top := ColorRect.new()
	top.color = Color(UI.DARK, 0.95)
	add_child(UI.place(top, 0, 0, 320, 18))
	top_sol = UI.label("", UI.SMALL, UI.ORANGE)
	add_child(UI.place(top_sol, 4, 1))
	top_scan = UI.label("", UI.SMALL, UI.SKY)
	top_scan.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(UI.place(top_scan, 180, 1, 136))
	tab_robot = _tab(func(): if ctrl != "robot" and not busy and not popup: _switch())
	add_child(UI.place(tab_robot, 2, 9, 96, 9))
	tab_crew = _tab(func(): if ctrl != "crew" and not busy and not popup: _switch())
	add_child(UI.place(tab_crew, 100, 9, 218, 9))
	toast_bg = ColorRect.new()
	toast_bg.color = Color(UI.DARK, 0.8)
	toast_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UI.place(toast_bg, 20, 21, 280, 18))
	toast = UI.label("", UI.SMALL, UI.YELLOW, true)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(UI.place(toast, 22, 22, 276, 16))
	# --- bottom hint ---
	_build_bottom_bar()
	var pb := ColorRect.new()
	pb.color = Color(UI.DARK, 0.8)
	pb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UI.place(pb, 0, 156, 254, 10))
	sci_label = UI.label("", UI.SMALL, UI.SAND)
	add_child(UI.place(sci_label, 3, 157))
	sci_bar = UI.bar(0, 27, 70)
	add_child(UI.place(sci_bar, 60, 158))
	obj_label = UI.label("", UI.SMALL)
	obj_label.clip_text = true
	add_child(UI.place(obj_label, 134, 157, 120, 8))
	job_bg = ColorRect.new()
	job_bg.color = Color(UI.DARK, 0.75)
	job_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(UI.place(job_bg, 0, 146, 320, 10))
	job_label = UI.label("", UI.SMALL, UI.YELLOW)
	job_label.clip_text = true
	add_child(UI.place(job_label, 3, 147, 314, 8))
	_begin_sol()

# ============================================================ sol flow
func _begin_sol() -> void:
	auto_path.clear(); _draw_path()
	busy = false
	warned = false
	crew_returning = false
	end_after_return = false
	robot_returning = false
	crew_cell = GS.lander
	GS.recharges_left = int(GS.dv("recharges")) if GS.has("charger") else 0
	if not GS.scout["lost"]: GS.scout["moves"] = GS.robot_moves()
	_auto_team()
	dust_fx.visible = GS.dust_today
	GS.spawn_hazards()
	_build_hazards()
	ctrl = "robot" if not GS.scout["lost"] else "crew"
	_new_job()
	var e := GS.roll_event()
	dust_fx.visible = GS.dust_today
	_refresh()
	if not e.is_empty():
		_show_event(e)
	elif not help_seen and GS.sol == 1:
		_show_help()
	else:
		_say("SOL %d. SCOUT WITH THE ROBOT, THEN TAKE THE CREW OUT." % GS.sol)

## Picks the 2 astronauts with the most suit time left today (then best condition).
func _auto_team() -> void:
	var cands := []
	for id in ["okoye", "tanaka", "vega", "duarte"]:
		if GS.can_eva(id): cands.append(id)
	cands.sort_custom(func(a, b):
		var sa := GS.suit_left(a); var sb := GS.suit_left(b)
		if absf(sa - sb) > 0.5: return sa > sb
		return GS.member(a)["cond"] > GS.member(b)["cond"])
	team = cands.slice(0, 2)

func _can_go_out() -> bool:
	if GS.today.get("eva_blocked", false): return false
	var n := 0
	for id in ["okoye", "tanaka", "vega", "duarte"]:
		if GS.can_eva(id) and GS.suit_left(id) >= 1.0: n += 1
	return n >= 2

func _vehicle() -> String:
	return GS.usable_vehicle() if use_rover else ""

func _build_bottom_bar() -> void:
	var bot := ColorRect.new()
	bot.color = UI.DARK
	add_child(UI.place(bot, 0, 166, 320, 14))
	var line := ColorRect.new()
	line.color = Color("7a3424")
	add_child(UI.place(line, 0, 166, 320, 1))
	var x := 3
	x = _keycap(x, "WASD", "MOVE")
	x = _keycap(x, "Q", "SWAP")
	x = _keycap(x, "TAB", "CREW")
	var cap := _keycap_box("E")
	add_child(UI.place(cap, x, 168))
	key_e = UI.label("", UI.SMALL, UI.YELLOW)
	key_e.clip_text = true
	add_child(UI.place(key_e, x + cap.size.x + 3, 170, 222 - (x + cap.size.x + 3), 8))
	var bm := UI.button("MAP", _toggle_map, UI.SMALL)
	add_child(UI.place(bm, 222, 167, 38, 13))
	btn_end = UI.button("END SOL", _end_sol, UI.SMALL)
	add_child(UI.place(btn_end, 262, 167, 57, 13))

func _keycap_box(k: String) -> Control:
	# a little key drawn with two rects: dark-rust border, sand face, darker bottom edge
	var w := k.length() * 6 + 5
	var box := Control.new()
	box.size = Vector2(w, 10)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border := ColorRect.new()
	border.color = Color("b5552e")
	border.size = Vector2(w, 10)
	box.add_child(border)
	var face := ColorRect.new()
	face.color = UI.SAND
	face.position = Vector2(1, 1)
	face.size = Vector2(w - 2, 7)
	box.add_child(face)
	var l := UI.label(k, UI.SMALL, UI.DARK)
	l.position = Vector2(3, 0)
	box.add_child(l)
	return box

func _keycap(x: int, k: String, label: String) -> int:
	var cap := _keycap_box(k)
	add_child(UI.place(cap, x, 168))
	var l := UI.label(label, UI.SMALL, UI.WHITE)
	add_child(UI.place(l, x + cap.size.x + 3, 170))
	return x + int(cap.size.x) + 3 + label.length() * 6 + 8

func _tab(cb: Callable) -> Button:
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", UI.SMALL)
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	b.pressed.connect(cb)
	return b

func _robot_frames() -> SpriteFrames:
	var tex: Texture2D = load("res://art/map/map_scout_robot.png")
	var sf := SpriteFrames.new()
	sf.add_animation(&"idle"); sf.add_animation(&"drive")
	sf.set_animation_speed(&"idle", 3); sf.set_animation_speed(&"drive", 12)
	for i in 10:   # 0-3 idle (head scans, antenna blinks), 4-9 drive (wheels turn, body bobs)
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * 16, 0, 16, 16)
		sf.add_frame(&"idle" if i < 4 else &"drive", at)
	return sf

## Little dust puffs behind a moving vehicle.
func _puff(cell_px: Vector2, dir: Vector2i, n := 3) -> void:
	for i in n:
		var d := ColorRect.new()
		d.size = Vector2(2, 2)
		d.color = [UI.SAND, Color("d98c4a"), Color("b5552e")][i % 3]
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var start := cell_px + Vector2(8, 13) - Vector2(dir) * 6 + Vector2(randf_range(-3, 3), randf_range(-1, 1))
		d.position = start
		world.add_child(d)
		world.move_child(d, fog.get_index())
		var tw := create_tween().set_parallel(true)
		tw.tween_property(d, "position", start + Vector2(-dir.x * randf_range(2, 6), randf_range(-6, -2)), 0.5)
		tw.tween_property(d, "modulate:a", 0.0, 0.5)
		tw.chain().tween_callback(d.queue_free)

func _build_hazards() -> void:
	for h in hazard_sprites: h.queue_free()
	hazard_sprites.clear()
	var tex: Texture2D = load("res://art/map/map_dust_devil.png")
	var sf := SpriteFrames.new()
	sf.set_animation_speed(&"default", 8)
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * 16, 0, 16, 16)
		sf.add_frame(&"default", at)
	for c in GS.hazards:
		var a := AnimatedSprite2D.new()
		a.centered = false
		a.sprite_frames = sf
		a.play(&"default")
		a.position = Vector2(c * CELL)
		world.add_child(a)
		world.move_child(a, fog.get_index())
		hazard_sprites.append(a)

func _refresh() -> void:
	var left: int = GS.stay - GS.sol
	top_sol.text = "SOL %d/%d   %s" % [GS.sol, GS.stay, ("ASCENT IN %d SOL%s" % [left, "" if left == 1 else "S"]) if left > 0 else "ASCENT TODAY!"]
	var robot_txt := "ROBOT %d" % GS.scout["moves"] if not GS.scout["lost"] else "ROBOT LOST!"
	tab_robot.text = ("> " if ctrl == "robot" else "  ") + robot_txt
	var rc: Color = UI.YELLOW if ctrl == "robot" else (UI.RED if GS.scout["lost"] else UI.GREY)
	for k in ["font_color", "font_hover_color", "font_pressed_color"]: tab_robot.add_theme_color_override(k, rc)
	var names: String = "+".join(team.map(func(i): return String(GS.member(i)["name"]).split(" ")[-1].to_upper()))
	var crew_txt := "CREW %s" % names
	if not GS.eva.is_empty(): crew_txt += "  SUIT %.1fH" % GS.eva_left()
	else: crew_txt += "  SUIT %.1fH" % GS.team_suit_left(team)
	tab_crew.text = ("> " if ctrl == "crew" else "  ") + crew_txt
	var low := not GS.eva.is_empty() and GS.eva_left() < 2.0
	var cc: Color = UI.RED if low else (UI.YELLOW if ctrl == "crew" else UI.GREY)
	for k in ["font_color", "font_hover_color", "font_pressed_color"]: tab_crew.add_theme_color_override(k, cc)
	btn_end.disabled = busy
	# sprites
	scout_sprite.position = Vector2(GS.scout["pos"] * CELL) if not busy or ctrl != "robot" else scout_sprite.position
	lost_icon.visible = GS.scout["lost"]
	lost_icon.position = Vector2(GS.scout["pos"] * CELL) + Vector2(0, -12)
	scout_sprite.modulate = Color(0.5, 0.5, 0.5) if GS.scout["lost"] else Color.WHITE
	for p in GS.pois:
		var m: AnimatedSprite2D = markers[p["id"]]
		m.visible = GS.is_revealed(p["pos"])
		m.modulate = [Color.WHITE, Color(1, 1, 1, 0.6), Color(1, 1, 1, 0.2)][min(GS.visits(p["id"]), 2)]
	for i in hazard_sprites.size():
		var hp := Vector2(GS.hazards[i] * CELL)
		if hazard_sprites[i].position != hp:
			create_tween().tween_property(hazard_sprites[i], "position", hp, 0.2)
		hazard_sprites[i].visible = GS.is_revealed(GS.hazards[i])
	while beacon_sprites.size() < GS.beacons.size():
		var bsp := AnimatedSprite2D.new()
		bsp.centered = false
		var sf := SpriteFrames.new()
		sf.set_animation_speed(&"default", 2)
		for i in 2:
			var at := AtlasTexture.new()
			at.atlas = load("res://art/map/map_beacon.png")
			at.region = Rect2(i * 16, 0, 16, 16)
			sf.add_frame(&"default", at)
		bsp.sprite_frames = sf
		bsp.play(&"default")
		bsp.position = Vector2(GS.beacons[beacon_sprites.size()] * CELL)
		world.add_child(bsp)
		world.move_child(bsp, fog.get_index())
		beacon_sprites.append(bsp)
	for m in mark_sprites: m.queue_free()
	mark_sprites.clear()
	for mk in GS.marks:
		var ms := UI.frames("res://art/anim/map/map_cursor_frames.tres")
		ms.play(&"pulse")
		ms.modulate = Color(1, 0.35, 0.3)
		ms.position = Vector2(mk * CELL)
		world.add_child(ms)
		mark_sprites.append(ms)
	if not busy: _place_crew()
	fog.queue_redraw()
	var rep := GS.report()
	sci_label.text = "SCI %d/27" % int(rep["science"])
	UI.set_bar(sci_bar, min(rep["science"], 27.0), "green" if rep["science"] >= 27 else ("yellow" if rep["science"] >= 14 else "red"))
	var goals: Array = rep["goals"]; var done: Array = rep["done"]
	var next := ""
	for g in goals:
		if not g in done: next = g; break
	obj_label.text = "ALL GOALS OK" if next == "" else "%d/%d FIND %s" % [done.size(), goals.size(), next.to_upper()]
	obj_label.add_theme_color_override("font_color", UI.GREEN if next == "" else UI.ORANGE)
	if done.size() > goals_seen:
		if goals_seen >= 0:
			_flash(UI.YELLOW, 0.35); shake = 2.5
			_say("GOAL COMPLETE: %s! %s" % [String(done[-1]).to_upper(), "ALL GOALS DONE!" if next == "" else "NEXT: " + next.to_upper()], 4.5, UI.YELLOW)
		goals_seen = done.size()
	if goals_seen < 0: goals_seen = done.size()
	_job_text()
	_update_prompt()

func _crew_outside() -> bool:
	return not GS.eva.is_empty()

func _place_crew() -> void:
	for s in crew_sprites: s.queue_free()
	crew_sprites.clear()
	rover_sprite.visible = false
	var show := _crew_outside() or ctrl == "crew"
	if not show: return
	var veh: String = GS.eva["vehicle"] if _crew_outside() else _vehicle()
	var pos := Vector2(crew_cell * CELL)
	if veh != "":
		rover_sprite.sprite_frames = load("res://art/anim/map/map_%s_frames.tres" % veh)
		rover_sprite.play(&"idle")
		rover_sprite.position = pos
		rover_sprite.visible = true
	else:
		var tm: Array = GS.eva["team"] if _crew_outside() else team
		for i in tm.size():
			var a := UI.frames("res://art/anim/crew/eva_%s_frames.tres" % tm[i])
			a.position = pos + Vector2(i * 4 - 2, 0)
			a.play(&"idle")
			world.add_child(a)
			world.move_child(a, fog.get_index())
			crew_sprites.append(a)

func _unit_cell() -> Vector2i:
	return GS.scout["pos"] if ctrl == "robot" else crew_cell

func _context() -> String:
	if popup or info_panel or map_panel or busy: return ""
	if ctrl == "crew":
		if crew_returning: return ""
		var p := GS.poi_at(crew_cell)
		if _crew_outside() and not p.is_empty() and GS.visits(p["id"]) < GS.VISITS_PER_TARGET:
			return "SAMPLE" if GS.can_sample() == "" else "NO SUIT TIME"
		if _crew_outside() and GS.can_deploy_beacon() == "":
			return "PLACE BEACON (%d)" % GS.beacons_left
		if crew_cell == GS.lander and not _crew_outside():
			return "GO OUT" if _can_go_out() else "END SOL"
		return ""
	if GS.scout["lost"]: return ""
	if robot_returning: return ""
	if GS.has("charger") and GS.recharges_left > 0 and GS.scout["pos"] != GS.lander and GS.scout["moves"] < GS.robot_moves() - 5:
		return "RECHARGE"
	if not GS.poi_at(GS.scout["pos"]).is_empty(): return "SEND THE CREW"
	return ""

func _update_prompt() -> void:
	var t := _context()
	if ctrl == "robot" and GS.scout["lost"]: prompt.text = "NO SIGNAL"
	elif ctrl == "crew" and crew_returning: prompt.text = "RETURNING..."
	else: prompt.text = ("E: " + t) if t != "" else ""
	if key_e: key_e.text = {"PLACE BEACON (%d)" % GS.beacons_left: "BEACON", "SEND THE CREW": "GO", "NO SUIT TIME": "-", "RECHARGE": "CHARGE"}.get(t, t) if t != "" else "-"
	var c := Vector2(_unit_cell() * CELL)
	prompt.position = c + Vector2(-42, -14)
	prompt.size = Vector2(100, 8)
	sel_ring.position = c

# ============================================================ per-frame: input, camera, scanner
func _process(delta: float) -> void:
	focus = focus.lerp(Vector2(_unit_cell()), min(1.0, delta * 10.0))
	var target := (focus * CELL + Vector2(8, 8)) - VIEW.size / 2.0
	target.x = clamp(target.x, 0, GS.WORLD_W * CELL - VIEW.size.x)
	target.y = clamp(target.y, 0, GS.WORLD_H * CELL - VIEW.size.y)
	world.position = (-target).round()
	if shake > 0.0:
		shake = maxf(0.0, shake - delta * 10.0)
		world.position += Vector2(randf_range(-shake, shake), randf_range(-shake, shake)).round()
	if job_marker: job_marker.position.y = job_marker_y + round(sin(Time.get_ticks_msec() / 200.0) * 2.0)
	if toast_t > 0:
		toast_t -= delta
		if toast_t <= 0: toast.text = ""
	toast_bg.visible = toast.text != ""
	_scanner(delta)
	# movement
	cooldown -= delta
	idle_t += delta
	if idle_t > 0.25:
		if motor.playing: motor.stop()
		if motor_rv.playing: motor_rv.stop()
	if busy or popup or info_panel or map_panel or cooldown > 0.0: return
	var dir := Vector2i.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): dir = Vector2i(0, -1)
	elif Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): dir = Vector2i(0, 1)
	elif Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): dir = Vector2i(-1, 0)
	elif Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): dir = Vector2i(1, 0)
	var locked := (ctrl == "crew" and crew_returning) or (ctrl == "robot" and robot_returning)
	if dir != Vector2i.ZERO and not locked:
		auto_path.clear(); _draw_path()
		_step(dir)
	elif not auto_path.is_empty():
		var nxt: Vector2i = auto_path.pop_front()
		if path_nodes.size() > 0: path_nodes.pop_front().queue_free()
		_step(nxt - _unit_cell())

func _scanner(delta: float) -> void:
	var d := 99.0
	if not GS.scout["lost"]: d = GS.scanner(GS.scout["pos"])
	if _crew_outside(): d = min(d, GS.scanner(crew_cell))
	if d <= float(GS.dv("scan")):
		top_scan.text = "SCANNER " + "|".repeat(5 - int(d))
		beep_t -= delta
		if beep_t <= 0.0 and not popup:
			GS.snd.sfx("ping")
			beep_t = 0.15 + (d - 1.0) * 0.28
	else:
		top_scan.text = "SCANNER -"

func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey and e.pressed and not e.echo): return
	match (e as InputEventKey).keycode:
		KEY_TAB:
			if not popup and not map_panel: _toggle_info()
			get_viewport().set_input_as_handled()
		KEY_M:
			if not popup and not info_panel: _toggle_map()
		KEY_G:
			if not popup and not info_panel and not map_panel and not busy and not crew_returning: _go_flag()
		KEY_Q:
			if not popup and not info_panel and not map_panel and not busy and not crew_returning and not robot_returning: _switch()
		KEY_E, KEY_SPACE, KEY_ENTER:
			if not popup and not info_panel and not map_panel and not busy: _interact()

func _switch() -> void:
	ctrl = "crew" if ctrl == "robot" else "robot"
	auto_path.clear(); _draw_path()
	GS.snd.sfx("robot_chirp" if ctrl == "robot" else "pick")
	if ctrl == "crew" and not _crew_outside() and _can_go_out():
		_say("CREW SELECTED. WALK OUT WITH WASD, OR PRESS E TO GO OUT.", 4.0, UI.WHITE)
	if ctrl == "robot" and GS.scout["lost"]:
		_say("ROBOT HAS NO SIGNAL. WALK THE CREW TO IT.", 3.0, UI.RED)
	_refresh()

func _say(t: String, secs := 4.0, col := UI.YELLOW) -> void:
	toast.text = t
	toast.add_theme_color_override("font_color", col)
	toast_t = secs

# ============================================================ moving
func _step(dir: Vector2i) -> void:
	if ctrl == "robot": _robot_step(dir)
	else: _crew_step(dir)

func _robot_step(dir: Vector2i) -> void:
	if GS.scout["lost"]:
		_say("NO SIGNAL! WALK THE CREW TO THE ROBOT (Q).", 3.0, UI.RED); cooldown = 0.5; return
	if GS.scout["moves"] <= 0 and not robot_returning:
		if GS.has("charger") and GS.recharges_left > 0:
			_say("BATTERY EMPTY. PRESS E: THE ROBOT DRIVES HOME TO RECHARGE.", 3.0, UI.ORANGE)
		else:
			_say("ROBOT BATTERY EMPTY FOR TODAY. SWITCH TO THE CREW (Q).", 3.0, UI.ORANGE)
		cooldown = 0.5; return
	var from: Vector2i = GS.scout["pos"]
	var r := GS.scout_move(dir, robot_returning)
	if not r["moved"]:
		var blk: Vector2i = from + dir
		if GS.obstacle(blk) != "" and GS.is_revealed(blk):
			_say("THE ROBOT CAN'T CLIMB %s." % ("BOULDERS" if GS.obstacle(blk) == "boulder" else "INTO A CRACK"), 1.5, UI.ORANGE)
		cooldown = 0.15; return
	busy = true
	idle_t = 0.0
	if not motor.playing and not GS.snd.muted: motor.play()
	scout_sprite.flip_h = dir.x < 0 if dir.x != 0 else scout_sprite.flip_h
	scout_sprite.play(&"drive")
	_puff(Vector2(from * CELL), dir, 2)
	var tw := create_tween()
	tw.tween_property(scout_sprite, "position", Vector2(GS.scout["pos"] * CELL), 0.13)
	await tw.finished
	if not is_inside_tree(): return
	busy = false
	cooldown = 0.0
	scout_sprite.play(&"idle")
	GS.move_hazards()
	if GS.hazard_near(GS.scout["pos"]):
		GS.scout["moves"] = max(0, int(GS.scout["moves"]) - 5)
		_say("A DUST DEVIL HIT THE ROBOT! -5 BATTERY.", 2.5, UI.ORANGE)
		shake = 3.0; _flash(UI.ORANGE, 0.25)
	for p in r["found"]: _found(p)
	if job.get("type", "") == "survey" and not job.get("done", false) and GS.scout["pos"] == job["cell"]: _job_done()
	if r.get("recharged", false):
		robot_returning = false
		auto_path.clear(); _draw_path()
		GS.snd.sfx("charge")
		_float(GS.lander, "+BATTERY", UI.SKY)
		_say("ROBOT RECHARGED! %d CHARGE%s LEFT TODAY." % [GS.recharges_left, "" if GS.recharges_left == 1 else "S"], 3.5, UI.GREEN)
	elif robot_returning and GS.scout["pos"] == GS.lander:
		robot_returning = false
	if r["lost"]:
		GS.snd.sfx("alarm")
		auto_path.clear(); _draw_path()
		_say("ROBOT LOST SIGNAL! SEND THE CREW TO ITS LAST POSITION.", 5.0, UI.RED)
		shake = 3.0; _flash(UI.RED, 0.3)
	_refresh()

func _crew_step(dir: Vector2i) -> void:
	var to := crew_cell + dir
	var veh_now: String = GS.eva["vehicle"] if _crew_outside() else _vehicle()
	if GS.crew_blocked(to, veh_now):
		if GS.obstacle(to) == "boulder":
			_say("BOULDERS: THE ROVER CAN'T PASS. GO AROUND, OR TURN THE ROVER OFF (TAB).", 3.0, UI.ORANGE)
		elif GS.obstacle(to) == "crack":
			_say("A DEEP CRACK. NOBODY CAN CROSS IT.", 2.5, UI.ORANGE)
		auto_path.clear(); _draw_path()
		cooldown = 0.4; return
	if not _crew_outside():
		var err := GS.eva_begin(team, _vehicle())
		if err != "":
			_say(err.to_upper() + " (TAB TO PICK CREW)", 3.0, UI.RED); GS.snd.sfx("error"); cooldown = 0.6; return
		GS.snd.sfx("next")
		_say("EVA STARTED. SUIT %.0fH. COME BACK BEFORE IT RUNS OUT." % GS.eva_left(), 3.5, UI.WHITE)
		_refresh()
	var from := crew_cell
	var r := GS.eva_step(to)
	crew_cell = to
	busy = true
	idle_t = 0.0
	var veh: String = GS.eva["vehicle"] if _crew_outside() else ""
	if veh != "":
		if not motor_rv.playing and not GS.snd.muted: motor_rv.play()
		_puff(Vector2(from * CELL), dir, 4)
	else:
		GS.snd.sfx("step")
		_puff(Vector2(from * CELL), Vector2i.ZERO, 1)
	await _move_sprites(from, to, 0.13 if veh != "" else 0.2)
	if not is_inside_tree(): return
	busy = false
	GS.move_hazards()
	for p in r["found"]: _found(p)
	if r.get("recovered", false):
		GS.snd.sfx("success")
		_say("ROBOT RECOVERED! SIGNAL IS BACK.", 3.5, UI.GREEN)
	if crew_cell == GS.lander:
		auto_path.clear(); _draw_path()
		var emergency: bool = GS.eva.get("emergency", false)
		crew_returning = false
		_finish_eva(emergency)
		if end_after_return:
			end_after_return = false
			_end_sol()
		return
	if r["out_of_time"] and not GS.eva.get("emergency", false):
		GS.eva["emergency"] = true
		GS.snd.sfx("alarm")
		_say("SUIT EMPTY! WALKING HOME ON EMERGENCY OXYGEN...", 5.0, UI.RED)
		_start_return()
		_refresh()
		return
	if crew_returning:
		_refresh()
		return
	_check_suit()
	var ev: Dictionary = r["event"]
	if ev.is_empty() and GS.hazard_near(crew_cell):
		ev = GS.make_walk_event("dust_devil")
	if not ev.is_empty():
		auto_path.clear(); _draw_path()
		await _walk_event(ev)
	_refresh()

## The crew walks home on its own (no control).
func _start_return() -> void:
	ctrl = "crew"
	auto_path = GS.crew_path(crew_cell, GS.lander)
	if auto_path.size() > 0: auto_path.remove_at(0)
	if auto_path.is_empty():
		# no known way back (should not happen): the others pick them up
		_finish_eva(true)
		if end_after_return:
			end_after_return = false
			_end_sol()
		return
	crew_returning = true
	_draw_path()

func _move_sprites(from: Vector2i, to: Vector2i, secs: float) -> void:
	_place_crew()
	var nodes: Array = crew_sprites.duplicate()
	if rover_sprite.visible: nodes = [rover_sprite]
	var tw := create_tween().set_parallel(true)
	for i in nodes.size():
		var n: AnimatedSprite2D = nodes[i]
		var off := Vector2(i * 4 - 2, 0) if nodes.size() > 1 else Vector2.ZERO
		n.position = Vector2(from * CELL) + off
		if to.x != from.x: n.flip_h = to.x < from.x
		n.play(&"drive" if n == rover_sprite else &"walk")
		tw.tween_property(n, "position", Vector2(to * CELL) + off, secs)
		if n == rover_sprite:
			var bob := create_tween()
			bob.tween_property(n, "offset:y", -1.0, secs / 2.0)
			bob.tween_property(n, "offset:y", 0.0, secs / 2.0)
	sel_ring.position = Vector2(to * CELL)
	await tw.finished

## A target was discovered: flag it on the map so the crew can go straight there (G).
func _found(p: Dictionary) -> void:
	GS.snd.sfx("success")
	if not p["pos"] in GS.marks:
		if GS.marks.size() >= 8: GS.marks.pop_front()
		GS.marks.append(p["pos"])
	var goal: bool = p["type"] in GS.goal_types()
	_flash(UI.GREEN, 0.2); shake = 1.5
	_float(p["pos"], "!" if not goal else "GOAL!", UI.YELLOW)
	if job.get("type", "") == "find" and not job.get("done", false): _job_done()
	_say("%sFOUND %s! FLAGGED. CREW: PRESS G TO GO." % ["GOAL TARGET! " if goal else "", String(p["label"]).to_upper()], 4.5, UI.GREEN)
	_refresh()

## G: the crew walks to the closest flagged target that still has samples to take.
func _go_flag() -> void:
	if ctrl != "crew":
		ctrl = "crew"
		GS.snd.sfx("pick")
	var best: Array = []
	for mk in GS.marks:
		var p := GS.poi_at(mk)
		if not p.is_empty() and GS.visits(p["id"]) >= GS.VISITS_PER_TARGET: continue
		var path := GS.crew_path(crew_cell, mk)
		if path.size() < 2: continue
		if best.is_empty() or path.size() < best.size(): best = path
	if best.is_empty():
		_say("NO FLAG THE CREW CAN REACH. SCOUT WITH THE ROBOT (Q).", 3.0, UI.ORANGE)
		GS.snd.sfx("error")
		_refresh()
		return
	best.remove_at(0)
	auto_path = best
	_draw_path()
	_say("CREW HEADING TO THE FLAG.", 2.5, UI.WHITE)
	_refresh()

func _check_suit() -> void:
	if not _crew_outside() or warned: return
	var back := GS.path_hours(GS.crew_path(crew_cell, GS.lander))
	if GS.eva_left() < back + 1.0:
		warned = true
		GS.snd.sfx("alarm")
		_say("SUIT TIME LOW! HEAD BACK TO THE LANDER NOW.", 5.0, UI.RED)

func _on_view_input(e: InputEvent) -> void:
	if popup or info_panel or busy: return
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var cell := Vector2i(((e.position - world.position) / CELL).floor())
		var path: Array = []
		if ctrl == "robot":
			if GS.scout["lost"]: return
			path = GS.robot_path(cell)
		else:
			if not GS.is_revealed(cell):
				_say("UNKNOWN GROUND. SCOUT IT FIRST, OR WALK THERE WITH WASD.", 3.0, UI.ORANGE); return
			path = GS.crew_path(crew_cell, cell)
		if path.size() < 2: return
		path.remove_at(0)
		auto_path = path
		_draw_path()
		GS.snd.sfx("pick")
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT:
		auto_path.clear(); _draw_path()

func _draw_path() -> void:
	for n in path_nodes: n.queue_free()
	path_nodes.clear()
	for i in auto_path.size():
		var d := UI.frames("res://art/anim/map/map_path_dot_frames.tres")
		d.position = Vector2(auto_path[i] * CELL)
		d.play(&"blink")
		d.frame = i % 3
		world.add_child(d)
		path_nodes.append(d)

# ============================================================ interact
func _interact() -> void:
	var ctx := _context()
	if ctx == "SAMPLE": _sample()
	elif ctx.begins_with("PLACE BEACON"): _beacon()
	elif ctx == "GO OUT":
		for d in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
			if not GS.crew_blocked(GS.lander + d, _vehicle()):
				_crew_step(d)
				return
	elif ctx == "END SOL": _end_sol()
	elif ctx == "RECHARGE":
		var pth := GS.robot_path(GS.lander)
		if pth.size() > 1:
			pth.remove_at(0)
			auto_path = pth
			robot_returning = true
			_draw_path()
			_say("ROBOT DRIVING HOME TO ITS CHARGER (RESERVE POWER).", 3.0, UI.SKY)
	elif ctx == "SEND THE CREW": _go_flag()

func _beacon() -> void:
	GS.deploy_beacon()
	GS.snd.sfx("beacon")
	_say("RELAY BEACON INSTALLED. THE ROBOT KEEPS SIGNAL AROUND HERE.", 4.0, UI.SKY)
	_float(crew_cell, "BEACON", UI.SKY)
	if job.get("type", "") == "beacon" and not job.get("done", false): _job_done()
	_refresh()

func _sample() -> void:
	var err := GS.can_sample()
	if err != "":
		_say(err.to_upper(), 2.5, UI.ORANGE); GS.snd.sfx("error"); return
	busy = true
	for s in crew_sprites: s.play(&"work")
	var bar := UI.bar(0, 100, 24, 4.0, "green")
	bar.position = Vector2(crew_cell * CELL) + Vector2(-4, -6)
	world.add_child(bar)
	var tw := create_tween()
	tw.tween_property(bar, "value", 100.0, 1.2)
	await tw.finished
	if not is_inside_tree(): return
	bar.queue_free()
	var sci_before: float = GS.sample_points + GS.instrument_points
	var t := GS.sample()
	GS.snd.sfx("success")
	shake = 1.2
	_float(crew_cell, "+%d SCI" % int(round(GS.sample_points + GS.instrument_points - sci_before)), UI.GREEN)
	var pulse := create_tween()
	pulse.tween_property(sci_label, "modulate", Color(2, 2, 0.6), 0.08)
	pulse.tween_property(sci_label, "modulate", Color.WHITE, 0.4)
	var here := GS.poi_at(crew_cell)
	if not here.is_empty() and GS.visits(here["id"]) >= GS.VISITS_PER_TARGET:
		GS.marks.erase(crew_cell)
		if job.get("type", "") == "full" and not job.get("done", false): _job_done()
	var sp := UI.frames("res://art/anim/fx/fx_sparkle_frames.tres")
	sp.position = Vector2(crew_cell * CELL)
	world.add_child(sp)
	sp.play(&"burst")
	sp.animation_finished.connect(sp.queue_free)
	busy = false
	_say(t.to_upper(), 4.0, UI.GREEN)
	_check_suit()
	_refresh()

func _finish_eva(rescued: bool) -> void:
	if not rescued and job.get("type", "") == "safe" and not job.get("done", false) and not GS.eva.is_empty() \
			and GS.team_suit_left(GS.eva["team"]) >= 2.0:
		_job_done()
	var lines := GS.eva_end(rescued)
	crew_cell = GS.lander
	_auto_team()
	if _can_go_out():
		lines.append("Ready to go out again (%s)." % "+".join(team.map(func(i): return String(GS.member(i)["name"]).split(" ")[-1])))
	if rescued: GS.snd.sfx("alarm")
	else: GS.snd.sfx("radio")
	_refresh()
	_say(" ".join(lines).to_upper() + ("" if _can_go_out() or rescued else " PRESS E TO END THE SOL."), 5.0, UI.RED if rescued else UI.GREEN)

func _end_sol() -> void:
	if info_panel: _toggle_info()
	if busy: return
	var lines := []
	if _crew_outside():
		end_after_return = true
		_say("THE CREW IS WALKING BACK TO THE LANDER. THE SOL ENDS WHEN THEY ARRIVE.", 4.0, UI.WHITE)
		_start_return()
		_refresh()
		return
	if not GS.today.get("eva_done", false):
		lines.append("No EVA today.")
	lines.append_array(GS.end_sol())
	_refresh()
	var over := GS.sol >= GS.stay
	var everyone_out := true
	for c in GS.crew:
		if not c["evac"]: everyone_out = false
	var title := "SOL %d SUMMARY" % GS.sol
	if over: title = "ASCENT WINDOW - SOL %d" % GS.stay
	if everyone_out: title = "MISSION ABORTED"
	if over or everyone_out:
		lines.append("The crew boards the ascent vehicle.")
	_summary(title, lines, over or everyone_out)

# ============================================================ popups
func _popup_base(title: String, alert: bool, rect: Rect2) -> VBoxContainer:
	popup = Control.new()
	popup.size = Vector2(320, 180)
	add_child(popup)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.55)
	shade.size = Vector2(320, 180)
	popup.add_child(shade)
	var v := UI.card(title, alert)
	popup.add_child(UI.place(v.get_parent(), rect.position.x, rect.position.y, rect.size.x, rect.size.y))
	motor.stop(); motor_rv.stop()
	_update_prompt()
	return v

func _close_popup() -> void:
	if popup: popup.queue_free()
	popup = null
	_update_prompt()

func _show_help() -> void:
	help_seen = true
	var v := _popup_base("HOW TO EXPLORE", false, Rect2(24, 26, 272, 136))
	v.add_child(UI.card_text("ROBOT (WASD): clears the fog, BEEPS near hidden targets and FLAGS what it finds.\nQ: switch to the CREW. G: walk to the nearest flag. E on a target: SAMPLE.\nWatch SUIT time. Back at the lander the other pair can go out. E there: END SOL.\nEvery sol has a SIDE JOB for a bonus. The science goal needs ALL your sols. M: map. N: mute."))
	v.add_child(UI.button("GOT IT", func(): _close_popup(); _say("DRIVE THE ROBOT WITH WASD.", 4.0)))

func _summary(title: String, lines: Array, final: bool) -> void:
	GS.snd.sfx("radio")
	var v := _popup_base(title, final, Rect2(40, 30, 240, 120))
	v.add_child(UI.card_text("\n".join(lines)))
	v.add_child(UI.button("ASCENT >" if final else "NEXT SOL >", func():
		_close_popup()
		if final:
			GS.mission_over = true
			main.goto("cutscene")
		else:
			GS.next_sol()
			_begin_sol()))

func _walk_event(e: Dictionary) -> void:
	busy = true
	GS.snd.sfx(EVENT_SFX.get(e["id"], "alarm"))
	var v := _popup_base(String(e["title"]).to_upper(), true, Rect2(40, 30, 240, 128))
	v.add_child(UI.card_text(e["text"]))
	var chosen := [""]
	for o in e["options"]:
		var oid: String = o[0]
		v.add_child(UI.button(o[1], func(): chosen[0] = oid, UI.SMALL))
		v.add_child(UI.card_text(o[2]))
	while chosen[0] == "":
		await get_tree().process_frame
		if not is_inside_tree(): return
	var res := GS.apply_walk(e, chosen[0])
	_close_popup()
	busy = false
	_say(String(res[0]).to_upper(), 3.5, UI.WHITE)
	if res[1]:
		_start_return()
	_check_suit()
	_refresh()

func _show_event(e: Dictionary) -> void:
	current_event = e
	GS.snd.sfx(EVENT_SFX.get(e["id"], "alarm"))
	if e["id"] in ["spectro_hint", "clear_sky", "find"]: _flash(UI.GREEN, 0.25)
	else:
		shake = 3.5; _flash(UI.RED, 0.25)
	var v := _popup_base(String(e["title"]).to_upper() + " - SOL %d" % GS.sol, true, Rect2(4, 22, 312, 154))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	v.add_child(row)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 160
	row.add_child(left)
	var pic := Control.new()
	pic.custom_minimum_size = Vector2(160, 90)
	left.add_child(pic)
	var anim_path := "res://art/anim/events/event_%s_frames.tres" % e["id"]
	if e.has("item"):
		var tr := TextureRect.new()
		tr.texture = load("res://art/items/item_%s.png" % e["item"])
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.size = Vector2(160, 80)
		tr.position = Vector2(0, 5)
		pic.add_child(tr)
	elif ResourceLoader.exists(anim_path):
		var a := UI.frames(anim_path)
		a.play(&"loop")
		pic.add_child(a)
	else:
		var who := "duarte"
		if e["id"] == "medical_issue": who = GS.lowest_crew().get("id", "duarte")
		if e["id"] == "relay_pass_missed": who = "tanaka"
		var a := UI.frames("res://art/anim/crew/crew_%s_frames.tres" % who)
		a.position = Vector2(56, 20)
		a.play(&"talk_worried")
		pic.add_child(a)
	left.add_child(UI.card_text(_event_text(e)))
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 128
	right.add_theme_constant_override("separation", 2)
	row.add_child(right)
	for o in GS.event_options(e):
		var oid: String = o["id"]
		var b := UI.button(SHORT_OPT.get(oid, String(o["label"]).to_upper()), func(): _choose(e, oid), UI.SMALL)
		b.clip_text = true
		b.custom_minimum_size.x = 128
		if o["disabled"] != "":
			b.disabled = true
			b.tooltip_text = o["disabled"]
		right.add_child(b)
		right.add_child(UI.card_text(o["cost"] + ("" if o["disabled"] == "" else " (" + o["disabled"] + ")")))
	if not GS.fit("vega") and e["options"].size() > 2:
		right.add_child(UI.card_text("(Cmdr. Vega is out: fewer options.)"))

func _event_text(e: Dictionary) -> String:
	if e.has("text"): return e["text"]
	match e["id"]:
		"dust_storm": return "Dust blocks the sun. Solar power drops 70% and the robot sees less."
		"solar_particle_event": return "A solar flare sends charged particles. Get people behind shielding."
		"equipment_failure": return "The %s failed after hard use." % (GS.comp[GS.usable_vehicle()]["name"] if GS.usable_vehicle() != "" else "EVA suit")
		"medical_issue":
			var m := GS.lowest_crew()
			return "%s is unwell (condition %d)." % [m.get("name", "?"), int(m.get("cond", 0))]
		"relay_pass_missed": return "The orbiting relay missed today's pass. No UHF link."
	return ""

func _choose(e: Dictionary, oid: String) -> void:
	var r := GS.apply_event(e, oid)
	_close_popup()
	_auto_team()
	_refresh()
	_say(r.to_upper(), 4.0, UI.WHITE)
	if not help_seen and GS.sol == 1: _show_help()

# ============================================================ map (M)
func _toggle_map() -> void:
	if info_panel: _toggle_info()
	if popup: return
	if map_panel:
		map_panel.queue_free(); map_panel = null
		_refresh()
		return
	motor.stop(); motor_rv.stop()
	GS.snd.sfx("pick")
	map_panel = Control.new()
	map_panel.size = Vector2(320, 180)
	add_child(map_panel)
	var bg := ColorRect.new()
	bg.color = UI.DARK
	bg.size = Vector2(320, 180)
	map_panel.add_child(bg)
	map_panel.add_child(UI.place(UI.label("MAP - CLICK TO MARK A SPOT", UI.SMALL, UI.SAND), 4, 1))
	var mv := MapView.new()
	mv.screen = self
	map_panel.add_child(UI.place(mv, 2, 10, 256, 160))
	var x := 262
	map_panel.add_child(UI.place(UI.button("GO", _go_mark, UI.SMALL), x, 10, 56, 18))
	map_panel.add_child(UI.place(UI.label("TO THE\nRED FLAG", UI.SMALL, UI.GREY), x + 2, 30))
	map_panel.add_child(UI.place(UI.button("CLEAR", func(): GS.marks.clear(); mv.queue_redraw(), UI.SMALL), x, 60, 56, 16))
	map_panel.add_child(UI.place(UI.button("CLOSE", _toggle_map, UI.SMALL), x, 152, 56, 18))

func _map_click(cell: Vector2i, right: bool) -> void:
	if cell.x < 0 or cell.y < 0 or cell.x >= GS.WORLD_W or cell.y >= GS.WORLD_H: return
	if cell in GS.marks:
		GS.marks.erase(cell)
	elif not right:
		if GS.marks.size() >= 6: GS.marks.pop_front()
		GS.marks.append(cell)
		GS.snd.sfx("place")

## The selected unit walks / drives to the newest mark.
func _go_mark() -> void:
	if GS.marks.is_empty():
		GS.snd.sfx("error"); return
	var cell: Vector2i = GS.marks[-1]
	_toggle_map()
	var path: Array = []
	if ctrl == "robot":
		if GS.scout["lost"]: _say("ROBOT HAS NO SIGNAL.", 2.5, UI.RED); return
		path = GS.robot_path(cell)
	else:
		path = GS.crew_path(crew_cell, cell)
		if path.size() < 2:
			_say("NO KNOWN WAY FOR THE CREW. SCOUT IT WITH THE ROBOT FIRST.", 3.5, UI.ORANGE); return
	if path.size() < 2: return
	path.remove_at(0)
	auto_path = path
	_draw_path()
	_say("ON THE WAY TO THE RED FLAG.", 2.5, UI.WHITE)


## Mini map drawn with the game's own art at half size (8 px per cell).
class MapView extends Control:
	var screen
	const C := 8
	var t := 0.0
	var tiles: Texture2D = preload("res://art/map/tiles_sheet.png")
	var robot: Texture2D = preload("res://art/map/map_scout_robot.png")
	var marker: Texture2D = preload("res://art/map/map_marker_target_0.png")
	var astro: Texture2D = preload("res://art/crew/eva_okoye_0.png")
	var beacon: Texture2D = preload("res://art/map/map_beacon.png")
	var devil: Texture2D = preload("res://art/map/map_dust_devil.png")
	var lander: Texture2D = preload("res://art/map/tile_lander.png")
	var boulder: Texture2D = preload("res://art/map/map_boulder.png")
	var crack: Texture2D = preload("res://art/map/map_crack.png")
	func _process(delta: float) -> void:
		t += delta
		queue_redraw()
	func _gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed and e.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			screen._map_click(Vector2i((e.position / C).floor()), e.button_index == MOUSE_BUTTON_RIGHT)
			queue_redraw()
	func _icon(tex: Texture2D, region: Rect2, c: Vector2i, mod := Color.WHITE) -> void:
		draw_texture_rect_region(tex, Rect2(Vector2(c * C), Vector2(C, C)), region, mod)
	func _draw() -> void:
		for y in GS.WORLD_H:
			for x in GS.WORLD_W:
				var c := Vector2i(x, y)
				if GS.is_revealed(c):
					var idx := "PRSHLT".find(GS.tile(c))
					if idx == 5: idx = 0
					_icon(tiles, Rect2(idx * 16, 0, 16, 16), c)
				else:
					draw_rect(Rect2(x * C, y * C, C, C), Color("241626"))
					if (x + y) % 2 == 0: draw_rect(Rect2(x * C + 3, y * C + 3, 1, 1), Color("3a2438"))
		draw_rect(Rect2(Vector2.ZERO, size), Color("7a3424"), false, 1.0)
		for oc in GS.obstacles:
			if GS.is_revealed(oc):
				_icon(boulder if GS.obstacles[oc] == "boulder" else crack, Rect2(0, 0, 16, 16), oc)
		_icon(lander, Rect2(0, 0, 16, 16), GS.lander)
		for p in GS.pois:
			if GS.is_revealed(p["pos"]):
				var v := GS.visits(p["id"])
				_icon(marker, Rect2(0, 0, 16, 16), p["pos"], [Color.WHITE, Color(1, 1, 1, 0.75), Color(0.5, 0.5, 0.5, 0.7)][min(v, 2)])
		for b in GS.beacons: _icon(beacon, Rect2(0, 0, 16, 16), b)
		for h in GS.hazards:
			if GS.is_revealed(h): _icon(devil, Rect2(0, 0, 16, 16), h)
		var blink := fmod(t, 0.8) < 0.5
		if not (GS.scout["lost"] and not blink):
			_icon(robot, Rect2(0, 0, 16, 16), GS.scout["pos"], Color(1, 0.5, 0.5) if GS.scout["lost"] else Color.WHITE)
		_icon(astro, Rect2(0, 0, 16, 16), screen.crew_cell)
		var me: Vector2i = screen._unit_cell()
		if blink: draw_rect(Rect2(Vector2(me * C) - Vector2(1, 1), Vector2(C + 2, C + 2)), UI.YELLOW, false, 1.0)
		for mk in GS.marks:
			var o := Vector2(mk * C)
			draw_line(o + Vector2(2, 8), o + Vector2(2, 0), UI.WHITE, 1.0)
			draw_colored_polygon(PackedVector2Array([o + Vector2(3, 0), o + Vector2(8, 2), o + Vector2(3, 4)]), UI.RED)


# ============================================================ info panel (TAB)
func _toggle_info() -> void:
	if map_panel: return
	if info_panel:
		info_panel.queue_free(); info_panel = null
		_refresh()
		return
	motor.stop(); motor_rv.stop()
	info_panel = Control.new()
	info_panel.size = Vector2(320, 165)
	add_child(info_panel)
	var shade := ColorRect.new()
	shade.color = Color(UI.DARK, 0.97)
	shade.size = Vector2(320, 165)
	info_panel.add_child(shade)
	var head := UI.label("CREW - CLICK TO PICK WHO GOES OUT  (TAB CLOSES)", UI.SMALL, UI.SAND)
	info_panel.add_child(UI.place(head, 8, 4))
	for i in GS.crew.size():
		var c: Dictionary = GS.crew[i]
		var x := 6 + (i % 2) * 156
		var y := 15 + (i / 2) * 64
		info_panel.add_child(_crew_card(c, x, y))
	var y2 := 146
	if GS.usable_vehicle() != "":
		var rb := UI.toggle("ROVER: " + ("ON" if use_rover else "OFF"), ButtonGroup.new(), func(): pass)
		rb.button_group = null
		rb.button_pressed = use_rover
		rb.disabled = _crew_outside()
		rb.toggled.connect(func(on): use_rover = on; rb.text = "ROVER: " + ("ON" if on else "OFF"))
		info_panel.add_child(UI.place(rb, 6, y2, 72, 13))
	var found := 0
	for p in GS.pois:
		if GS.is_revealed(p["pos"]): found += 1
	var st := UI.label("TARGETS %d/%d   FOOD %.0f SOLS   SENT %.0fMB" % [found, GS.pois.size(), GS.supplies, GS.data_sent], UI.SMALL, UI.WHITE)
	info_panel.add_child(UI.place(st, 84, y2 + 3, 232, 8))

## One crew card, all children absolutely placed inside a 152x60 frame (nothing sticks out).
func _crew_card(c: Dictionary, x: int, y: int) -> Control:
	var id: String = c["id"]
	var box := Control.new()
	box.position = Vector2(x, y)
	box.size = Vector2(152, 60)
	box.clip_contents = true
	var frame := PanelContainer.new()
	frame.theme_type_variation = &"CardPanel"
	frame.size = box.size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(frame)
	# portrait in its own dark window on the left
	var win := ColorRect.new()
	win.color = Color(UI.DARK, 0.85)
	win.position = Vector2(4, 4); win.size = Vector2(44, 52)
	box.add_child(win)
	var clip := Control.new()
	clip.clip_contents = true
	clip.position = win.position; clip.size = win.size
	box.add_child(clip)
	var pic := AnimatedSprite2D.new()
	pic.centered = false
	pic.sprite_frames = load("res://art/anim/crew/crew_%s_frames.tres" % id)
	pic.play(&"idle_worried" if c["cond"] < 50 else &"idle_normal")
	pic.position = Vector2(-2, 4)
	if c["evac"]: pic.modulate = Color(0.4, 0.4, 0.4)
	clip.add_child(pic)
	var name_l := UI.label(String(c["name"]).to_upper(), UI.SMALL, UI.SAND)
	name_l.clip_text = true
	box.add_child(UI.place(name_l, 52, 5, 96, 8))
	var role := UI.label(String(c["role"]).to_upper(), UI.SMALL, UI.RUST)
	role.clip_text = true
	box.add_child(UI.place(role, 52, 15, 66, 8))
	box.add_child(UI.place(UI.label("%.0fH" % GS.suit_left(id), UI.SMALL, UI.BLUE), 122, 15, 26, 8))
	var bar := UI.bar(c["cond"], 100, 64)
	box.add_child(UI.place(bar, 52, 26))
	box.add_child(UI.place(UI.label("EVAC" if c["evac"] else "%d" % int(c["cond"]), UI.SMALL, UI.DARK), 122, 25, 26, 8))
	var b := Button.new()
	b.toggle_mode = true
	UI.mark_toggle(b)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", UI.SMALL)
	b.button_pressed = id in team
	b.text = "GOES OUT" if id in team else "STAYS IN"
	b.disabled = not GS.can_eva(id) or _crew_outside()
	if not GS.can_eva(id) and not c["evac"]: b.text = "TOO TIRED"
	elif GS.suit_left(id) < 1.0 and not c["evac"]: b.text = "SUIT EMPTY"; b.disabled = true
	b.toggled.connect(func(on):
		if on and not team.has(id): team.append(id)
		if not on: team.erase(id)
		b.text = "GOES OUT" if on else "STAYS IN"
		_refresh())
	box.add_child(UI.place(b, 52, 40, 96, 14))
	return box


class FogLayer extends Node2D:
	var tex: Texture2D = preload("res://art/map/map_fog.png")
	func _draw() -> void:
		for y in GS.WORLD_H:
			for x in GS.WORLD_W:
				if not GS.is_revealed(Vector2i(x, y)):
					draw_texture(tex, Vector2(x * 16, y * 16))


# ============================================================ juice
var shake := 0.0
var goals_seen := -1

## Full-view colour flash that fades out.
func _flash(col: Color, a := 0.3) -> void:
	if not is_inside_tree(): return
	var fl := ColorRect.new()
	fl.color = Color(col, a)
	fl.size = VIEW.size
	fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_child(fl)
	var tw := create_tween()
	tw.tween_property(fl, "color:a", 0.0, 0.3)
	tw.tween_callback(fl.queue_free)

## Text that pops up over a map cell and floats away.
func _float(cell: Vector2i, text: String, col: Color) -> void:
	var l := UI.label(text, UI.SMALL, col)
	l.add_theme_color_override("font_outline_color", UI.DARK)
	l.add_theme_constant_override("outline_size", 3)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(80, 8)
	l.position = Vector2(cell * CELL) + Vector2(-32, -10)
	l.scale = Vector2(0.5, 0.5)
	l.pivot_offset = Vector2(40, 4)
	world.add_child(l)
	var tw := create_tween().set_parallel()
	tw.tween_property(l, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", l.position.y - 16, 1.2)
	tw.tween_property(l, "modulate:a", 0.0, 0.5).set_delay(0.8)
	tw.chain().tween_callback(l.queue_free)

# ============================================================ side jobs (one per sol)
var job := {}
var job_bg: ColorRect
var job_label: Label
var job_marker: Label
var job_marker_y := 0.0

func _new_job() -> void:
	if job_marker: job_marker.queue_free(); job_marker = null
	var opts: Array = ["survey", "full", "safe"]
	for p in GS.pois:
		if not GS.is_revealed(p["pos"]): opts.append("find"); break
	if GS.beacons_left > 0: opts.append("beacon")
	var kind: String = opts.pick_random()
	job = {"type": kind, "done": false}
	match kind:
		"survey":
			var best := Vector2i(-1, -1)
			for i in 60:
				var c := Vector2i(randi_range(1, GS.WORLD_W - 2), randi_range(1, GS.WORLD_H - 2))
				var d: float = Vector2(c - GS.scout["pos"]).length()
				if d < 5.0 or d > 11.0 or not GS.passable(c) or GS.obstacle(c) != "": continue
				if GS.robot_path(c).size() < 2: continue
				best = c; break
			if best.x < 0:
				job = {"type": "full", "done": false}
			else:
				job["cell"] = best
				job_marker = UI.label("?", 8, UI.YELLOW)
				job_marker.add_theme_color_override("font_outline_color", UI.DARK)
				job_marker.add_theme_constant_override("outline_size", 3)
				job_marker.position = Vector2(best * CELL) + Vector2(4, 0)
				job_marker_y = job_marker.position.y
				world.add_child(job_marker)
	_job_text()

func _job_text() -> void:
	if not job_label: return
	if job.is_empty(): job_label.text = ""; return
	if job["done"]:
		job_label.text = "JOB DONE! (%d THIS MISSION)" % GS.micro_done
		job_label.add_theme_color_override("font_color", UI.GREEN)
		return
	job_label.add_theme_color_override("font_color", UI.YELLOW)
	job_label.text = "JOB: " + {
		"survey": "DRIVE THE ROBOT TO THE ?   > +4 SCI",
		"find": "FIND A NEW TARGET (ROBOT)   > +6 MOVES",
		"full": "SAMPLE A TARGET 2/2 TODAY   > +3 SCI",
		"beacon": "INSTALL A BEACON   > +2 SCI, +8 MOVES",
		"safe": "END AN EVA WITH 2H+ SUIT LEFT   > +8 CREW",
	}[job["type"]]

func _job_done() -> void:
	job["done"] = true
	GS.micro_done += 1
	var reward := ""
	match job["type"]:
		"survey":
			GS.sample_points += 4.0
			GS.reveal(job["cell"], 3.0)
			reward = "+4 SCI"
		"find":
			GS.scout["moves"] = int(GS.scout["moves"]) + 6
			reward = "+6 MOVES"
		"full":
			GS.sample_points += 3.0
			for id in team:
				var m := GS.member(id); m["cond"] = minf(100.0, m["cond"] + 10.0)
			reward = "+3 SCI"
		"beacon":
			GS.sample_points += 2.0
			GS.scout["moves"] = int(GS.scout["moves"]) + 8
			reward = "+2 SCI"
		"safe":
			for id in team:
				var m := GS.member(id); m["cond"] = minf(100.0, m["cond"] + 8.0)
			reward = "+8 CREW"
	if job_marker: job_marker.queue_free(); job_marker = null
	GS.snd.sfx("ev_chime")
	_flash(UI.YELLOW, 0.3); shake = 2.0
	_float(_unit_cell(), "JOB DONE! " + reward, UI.YELLOW)
	GS.log_add("Side job done (%s)." % reward)
	_job_text()
	fog.queue_redraw()
