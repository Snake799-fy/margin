extends Control
## Phase 1 - Concept (CML 1-2, user segment): science objective + length of stay.

var main

func _ready() -> void:
	UI.header(self, "STEP 1/7 - CONCEPT (CML 1-2)", "WHAT WILL THE CREW STUDY?")
	var g := ButtonGroup.new()
	var i := 0
	for o in GS.D["objectives"]:
		var v := UI.card("%s: %s" % [o["id"], ["OLD LIFE", "CLIMATE", "WATER ICE"][i]])
		v.tooltip_text = o["name"]
		var c: Control = v.get_parent()
		add_child(UI.place(c, 4 + i * 105, 38, 102, 104))
		v.add_child(UI.card_text(o["question"]))
		var needs := []
		for n in o["needs"]: needs.append(GS.short_name(n))
		var nl := UI.card_text("Needs: " + ", ".join(needs))
		nl.add_theme_color_override("font_color", UI.RUST)
		v.add_child(nl)
		var spacer := Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		v.add_child(spacer)
		var id: String = o["id"]
		var b := UI.toggle("CHOOSE", g, func(): GS.objective = id; main.refresh_hud(); _goals())
		b.button_pressed = GS.objective == id
		v.add_child(b)
		i += 1
	add_child(UI.place(UI.label("STAY (SOLS):", UI.SMALL, UI.SAND), 4, 150))
	var g2 := ButtonGroup.new()
	var j := 0
	for n in GS.D["stay_options_sols"]:
		var sols := int(n)
		var b := UI.toggle("%d" % sols, g2, func(): GS.stay = sols; main.refresh_hud(); _goals())
		b.button_pressed = GS.stay == sols
		add_child(UI.place(b, 80 + j * 30, 145, 28, 14))
		j += 1
	goals_l = UI.label("", UI.SMALL, UI.YELLOW)
	goals_l.clip_text = true
	add_child(UI.place(goals_l, 4, 165, 254, 8))
	_goals()
	add_child(UI.place(UI.button("NEXT >", func(): main.goto("trade")), 262, 160))

var goals_l: Label

## Harder levels and longer stays ask for more target types.
func _goals() -> void:
	var g: Array = []
	for t in GS.goal_types(): g.append(String(t).to_upper())
	goals_l.text = "GOALS: " + "+".join(g)
