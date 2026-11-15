extends Control
## Phase 7 - Report (user segment): big result, 4 bars, the main reason, a similar real mission.

var main

func _ready() -> void:
	var r := GS.report()
	var failed: bool = r["seal"] in ["MISSION ABORTED", "MISSION FAILED"]
	GS.snd.sfx("error" if failed else "success")
	var col := UI.GREEN if r["seal"] == "MISSION COMPLETE" else (UI.YELLOW if r["seal"] == "PARTIAL SUCCESS" else UI.RED)
	var seal := UI.label(r["seal"], 16, col)
	seal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(UI.place(seal, 0, 8, 320))
	seal.pivot_offset = Vector2(160, 8)
	seal.scale = Vector2(1.8, 1.8)
	create_tween().tween_property(seal, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if not GS.tokens_given:
		GS.tokens_given = true
		GS.award_tokens(r)
	var score := UI.label("SCORE %d / 100" % int(round(r["total"])), 8, UI.WHITE)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(UI.place(score, 0, 30, 320))
	# bars
	var y := 48
	add_child(UI.place(UI.label("SCIENCE NEEDED: 27", UI.SMALL, UI.GREY), 8, 106))
	for l in [["SCIENCE", r["science"], 35], ["CREW", r["crew"], 25], ["ENGINEERING", r["eng"], 20], ["EFFICIENCY", r["eff"], 20]]:
		add_child(UI.place(UI.label(l[0], UI.SMALL, UI.SAND), 8, y))
		var b := UI.bar(0, l[2], 70)
		add_child(UI.place(b, 78, y + 1))
		create_tween().tween_method(func(v): UI.set_bar(b, v), 0.0, float(l[1]), 0.9).set_delay(0.3 + y * 0.004)
		add_child(UI.place(UI.label("%d/%d" % [int(round(l[1])), l[2]], UI.SMALL), 152, y))
		y += 14
	# main reason
	var v := UI.card("WHY?", failed)
	v.add_child(UI.card_text(r["causes"][0] if not r["causes"].is_empty() else "Every choice held up."))
	add_child(UI.place(v.get_parent(), 184, 44, 132, 62))
	# left column: short lines
	var crew_txt := "ALL 4 CREW HOME" if r["evac"] == 0 else "%d CREW EVACUATED" % r["evac"]
	add_child(UI.place(UI.label(crew_txt, UI.SMALL, UI.WHITE), 8, 116))
	add_child(UI.place(UI.label("DATA SENT %d/%d MB" % [int(r["sent"]), int(r["gen"])], UI.SMALL, UI.WHITE), 8, 126))
	add_child(UI.place(UI.label("REAL MISSION: %s" % String(r["analog"]["name"]).to_upper(), UI.SMALL, UI.SKY), 8, 136, 174, 8))
	add_child(UI.place(UI.label("Game numbers are simplified.", UI.SMALL, UI.GREY), 8, 146))
	# right column: goals, side jobs and tokens (counts up)
	add_child(UI.place(UI.label("GOALS %d/%d  JOBS %d" % [r["done"].size(), r["goals"].size(), GS.micro_done], UI.SMALL, UI.SAND), 186, 112, 130, 8))
	var tok := UI.label("+0 TOKENS", 8, UI.YELLOW)
	add_child(UI.place(tok, 186, 123, 130, 10))
	if not GS.last_unlocks.is_empty():
		add_child(UI.place(UI.label("UNLOCKED: " + ", ".join(GS.last_unlocks), UI.SMALL, UI.GREEN), 186, 134, 130, 8))
	add_child(UI.place(UI.link("UPGRADES (%d TOKENS) >" % int(GS.meta["tokens"]), func(): GS.prep_back = "report"; main.goto("prep")), 184, 144, 132, 12))
	var tw := create_tween()
	tw.tween_interval(1.2)
	tw.tween_method(func(v): tok.text = "+%d TOKENS" % int(v), 0.0, float(GS.last_tokens), 0.8)
	tw.tween_callback(func(): GS.snd.sfx("ev_chime"))
	add_child(UI.place(UI.button("REDESIGN & FLY AGAIN", func(): GS.redesign(); main.goto("trade"), UI.SMALL), 4, 160, 160, 16))
	add_child(UI.place(UI.button("TITLE", func(): get_tree().change_scene_to_file("res://scenes/title.tscn"), UI.SMALL), 216, 160, 100, 16))
