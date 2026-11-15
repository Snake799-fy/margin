extends Control
## Mission briefing: what the game is about, in 3 steps. Shown after the title.

var main

func _ready() -> void:
	var t := UI.label("MISSION BRIEFING - MARS, 2040", 8, UI.SAND)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(UI.place(t, 0, 6, 320))
	var s := UI.label("You are the Mission Director. Four astronauts depend on every kilo you choose to bring.", UI.SMALL, UI.WHITE, true)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(UI.place(s, 10, 18, 300))
	var steps := [
		["1. PACK", "Space, weight and money are limited.", "pack"],
		["2. LAND", "Four astronauts land near an old lake.", "land"],
		["3. EXPLORE", "Explore in pairs. The rocket leaves on a fixed day.", "eva"],
	]
	for i in steps.size():
		var v := UI.card(steps[i][0])
		add_child(UI.place(v.get_parent(), 6 + i * 104, 34, 100, 90))
		var pic := Control.new()
		pic.custom_minimum_size = Vector2(84, 30)
		v.add_child(pic)
		match steps[i][2]:
			"pack":
				var x := 4
				for id in ["crate", "medkit", "spectrometer", "water"]:
					var r := TextureRect.new()
					r.texture = load("res://art/items/item_%s.png" % id)
					r.position = Vector2(x, 10)
					pic.add_child(r)
					x += 20
			"land":
				var a := UI.frames("res://art/anim/screens/lander_frames.tres")
				a.position = Vector2(26, -4)
				a.play(&"landed")
				pic.add_child(a)
			"eva":
				var x := 10
				for id in ["vega", "okoye", "tanaka", "duarte"]:
					var a := UI.frames("res://art/anim/crew/eva_%s_frames.tres" % id)
					a.position = Vector2(x, 14)
					a.play(&"walk")
					pic.add_child(a)
					x += 17
		v.add_child(UI.card_text(steps[i][1]))
	# difficulty
	add_child(UI.place(UI.label("DIFFICULTY:", UI.SMALL, UI.SAND), 8, 134))
	var g := ButtonGroup.new()
	var x := 78
	desc = UI.label("", UI.SMALL, UI.GREY)
	for d in [["easy", "EASY"], ["medium", "MEDIUM"], ["hard", "HARD"]]:
		var id: String = d[0]
		var b := UI.toggle(d[1], g, func(): GS.difficulty = id; _desc())
		b.button_pressed = GS.difficulty == id
		add_child(UI.place(b, x, 130, 54, 13))
		x += 58
	add_child(UI.place(desc, 8, 148))
	var on := 0
	for k in GS.mods: if GS.mods[k]: on += 1
	var extra := "UPGRADES & CHALLENGES (%d TOKENS%s) >" % [int(GS.meta["tokens"]), (", %d ON" % on) if on > 0 else ""]
	add_child(UI.place(UI.link(extra, _prep), 4, 163, 236, 12))
	_desc()
	add_child(UI.place(UI.button("START >", func(): main.goto("concept")), 244, 161, 72, 16))

var desc: Label

func _prep() -> void:
	GS.prep_back = "intro"
	main.goto("prep")

func _desc() -> void:
	desc.text = {"easy": "Big lander, more money, far-seeing robot.",
		"medium": "Smaller lander and budget. Balanced.",
		"hard": "Tiny lander, tight money, short-sighted robot."}[GS.difficulty]
