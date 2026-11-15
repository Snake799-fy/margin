extends Control
## End cutscene before the report. A different scene for each outcome:
## success, aborted, evacuation, supplies, power, objective missed. Tone stays sober.

var main
var caption: Label
var kind := "success"
var lander: AnimatedSprite2D
var done := false

const TEXT := {
	"success": "ASCENT. All four astronauts lift off with their samples. Every kilo you chose made it count.",
	"objective": "The rocket leaves on time and everyone is safe, but the main science goal was not reached.",
	"science": "The crew is safe, but the sample boxes are almost empty. Not enough science: the mission failed.",
	"power": "The power failed. Heaters ran cold and the crew rationed every watt until the ascent window.",
	"supplies": "Food and water ran out before the window. The crew lifts off tired and weak.",
	"evacuation": "%s had to be evacuated early. The rest of the crew lifts off with a heavy heart.",
	"aborted": "MISSION ABORTED. Emergency ascent: crew safety comes first.",
}

func _ready() -> void:
	var r := GS.report()
	var log_text := ""
	for l in GS.mission_log: log_text += String(l["text"]) + "\n"
	var evac_names := []
	for c in GS.crew:
		if c["evac"]: evac_names.append(c["name"])
	if r["seal"] == "MISSION COMPLETE": kind = "success"   # a won mission always gets the happy ending
	elif r["seal"] == "MISSION ABORTED" and evac_names.size() >= 2: kind = "aborted"
	elif not evac_names.is_empty(): kind = "evacuation"
	elif log_text.contains("Supplies ran out"): kind = "supplies"
	elif log_text.contains("Power ran out"): kind = "power"
	elif r["seal"] == "MISSION FAILED": kind = "science"
	elif not r["primary"]: kind = "objective"
	else: kind = "success"
	GS.snd.play_music("report" if kind == "success" else "surface")
	var bg := TextureRect.new()
	bg.texture = preload("res://art/ui/landing_bg.png")
	add_child(bg)
	lander = UI.frames("res://art/anim/screens/lander_frames.tres")
	lander.position = Vector2(144, 113)
	lander.play(&"landed")
	add_child(lander)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0)
	shade.size = Vector2(320, 180)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var box := ColorRect.new()
	box.color = Color(UI.DARK, 0.85)
	add_child(UI.place(box, 0, 148, 320, 32))
	caption = UI.label("", UI.SMALL, UI.WHITE, true)
	add_child(UI.place(caption, 6, 151, 236, 28))
	var skip := UI.button("REPORT >", _to_report, UI.SMALL)
	add_child(UI.place(skip, 248, 158, 68, 16))
	var text: String = TEXT[kind]
	if kind == "evacuation": text = text % " and ".join(evac_names)
	_play(shade, text)

func _type(text: String) -> void:
	caption.text = text
	caption.visible_characters = 0
	var tw := create_tween()
	tw.tween_property(caption, "visible_characters", text.length(), text.length() * 0.035)

func _play(shade: ColorRect, text: String) -> void:
	# walkers: the crew still able to walk heads to the lander
	var walkers := []
	for c in GS.crew:
		if kind == "aborted" or c["evac"]: continue
		walkers.append(c["id"])
	if kind == "power":
		var t := create_tween()
		t.tween_property(shade, "color", Color(0, 0, 0.05, 0.55), 2.5)
	if kind in ["aborted", "evacuation"]:
		var v := UI.frames("res://art/anim/fx/fx_alert_vignette_frames.tres")
		v.play(&"pulse")
		add_child(v)
		move_child(v, 3)
		GS.snd.sfx("alarm")
	if kind == "supplies" or kind == "power":
		var d := UI.frames("res://art/anim/fx/fx_dust_overlay_frames.tres")
		d.play(&"loop")
		d.modulate.a = 0.5
		add_child(d)
		move_child(d, 3)
	_type(text)
	var sprites := []
	for i in walkers.size():
		var a := UI.frames("res://art/anim/crew/eva_%s_frames.tres" % walkers[i])
		a.position = Vector2(-20 - i * 18, 124)
		a.play(&"walk")
		add_child(a)
		move_child(a, 2)
		sprites.append(a)
	var walk_time := 3.2 if kind != "supplies" else 5.0
	if not sprites.is_empty():
		var tw := create_tween().set_parallel(true)
		for i in sprites.size():
			tw.tween_property(sprites[i], "position:x", 136.0 - i * 3, walk_time + i * 0.4)
		await tw.finished
		if not is_inside_tree(): return
		if kind in ["success", "objective"]:
			for s in sprites: s.play(&"wave")
			await get_tree().create_timer(1.2).timeout
			if not is_inside_tree(): return
		for s in sprites: s.queue_free()
	else:
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree(): return
	# lift-off
	var dust := UI.frames("res://art/anim/screens/touchdown_dust_frames.tres")
	dust.position = Vector2(120, 117)
	dust.play(&"burst")
	add_child(dust)
	move_child(dust, 2)
	dust.animation_finished.connect(dust.queue_free)
	lander.play(&"descent")
	GS.snd.sfx("landing")
	var up := create_tween()
	up.tween_property(lander, "position:y", -60.0, 3.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await up.finished
	if not is_inside_tree(): return
	if kind == "success": GS.snd.sfx("success")
	done = true

func _to_report() -> void:
	main.goto("report")
