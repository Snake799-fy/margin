extends Control
## Phase 5 - Landing (EDL, space segment). Shows the chance and where it comes from BEFORE rolling.

var main
var panel_text: Label
var btn: Button

func _ready() -> void:
	GS.start_mission()
	var bg := TextureRect.new()
	bg.texture = preload("res://art/ui/landing_bg.png")
	add_child(bg)
	var v := UI.card("PHASE 5 - LANDING (EDL)")
	add_child(UI.place(v.get_parent(), 8, 6, 304, 58))
	var ch := GS.landing_chance()
	var t := "Cargo landed first (pre-positioned). Now the crew descends.\nPrecise landing: %d%% base" % int(ch["base"] * 100)
	if ch["penalty"] > 0.0:
		t += " - %d%% for a thin mass margin (%d%%)" % [int(ch["penalty"] * 100), int(GS.stats()["mass_margin_pct"])]
	t += " = %d%%." % int(ch["p"] * 100)
	panel_text = UI.card_text(t)
	v.add_child(panel_text)
	btn = UI.button("LAND", _land)
	add_child(UI.place(btn, 136, 160))

func _land() -> void:
	btn.disabled = true
	btn.visible = false
	var anim: Node2D = preload("res://art/anim/examples/landing_example.tscn").instantiate()
	add_child(anim)
	move_child(anim, 1)
	var ok := GS.roll_landing()
	GS.snd.sfx("landing")
	await get_tree().create_timer(4.8).timeout
	if not is_inside_tree(): return
	if ok:
		panel_text.text = "TOUCHDOWN! On target. All cargo intact.\nFour astronauts on Mars. Ascent window: sol %d." % GS.stay
	else:
		panel_text.text = "HARD LANDING. " + String(GS.mission_log[-1]["text"]) + "\nCrew shaken (-10 condition). Ascent window: sol %d." % GS.stay
	var go := UI.button("TO THE SURFACE >", func(): main.goto("surface"))
	add_child(UI.place(go, 196, 160))
