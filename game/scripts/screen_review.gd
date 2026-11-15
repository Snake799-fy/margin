extends Control
## Phase 4 - Design review (CML 4): automatic checklist + the crew's opinion.

var main
var portrait: AnimatedSprite2D
var speech: Label
var who: Label
var order := ["vega", "okoye", "tanaka", "duarte"]
var idx := 0
var opinions := {}

func _ready() -> void:
	UI.header(self, "STEP 4/7 - DESIGN REVIEW (CML 4)", "READY TO LAUNCH?")
	# checklist laid out by a container so wrapped lines never overlap
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	box.clip_contents = true
	add_child(UI.place(box, 4, 42, 196, 114))
	for r in GS.review():
		var tag := "[OK]"
		var col := UI.GREEN
		if not r["ok"]:
			tag = "[X]" if r["block"] else "[!]"
			col = UI.RED if r["block"] else UI.YELLOW
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		box.add_child(row)
		var tl := UI.label(tag, UI.SMALL, col)
		tl.custom_minimum_size = Vector2(24, 0)
		row.add_child(tl)
		var l := UI.label(r["text"], UI.SMALL, UI.WHITE, true)
		l.custom_minimum_size = Vector2(168, 0)
		row.add_child(l)
	# crew opinions
	opinions = GS.crew_opinions()
	var v := UI.card("CREW SAYS")
	add_child(UI.place(v.get_parent(), 202, 38, 116, 118))
	var hb := Control.new()
	hb.custom_minimum_size = Vector2(48, 48)
	v.add_child(hb)
	portrait = AnimatedSprite2D.new()
	portrait.centered = false
	portrait.position = Vector2(26, 0)
	hb.add_child(portrait)
	who = UI.card_text("")
	who.add_theme_color_override("font_color", UI.RUST)
	v.add_child(who)
	speech = UI.card_text("")
	v.add_child(speech)
	var t := Timer.new()
	t.wait_time = 3.0
	t.autostart = true
	t.timeout.connect(_next)
	add_child(t)
	_next()
	add_child(UI.place(UI.button("< CARGO", func(): main.goto("cargo")), 4, 160))
	var go := UI.button("LAUNCH >", func(): main.goto("landing"))
	go.disabled = not GS.can_launch()
	if go.disabled: go.tooltip_text = "Fix the red [X] items first."
	add_child(UI.place(go, 246, 160))
	if go.disabled:
		add_child(UI.place(UI.label("Fix [X] to launch", UI.SMALL, UI.RED), 120, 164))

func _next() -> void:
	var id: String = order[idx % order.size()]
	idx += 1
	var worried := String(opinions[id]).contains("No ") or String(opinions[id]).contains("lack") \
		or String(opinions[id]).contains("negative") or String(opinions[id]).contains("thin") or String(opinions[id]).contains("damaged")
	portrait.sprite_frames = load("res://art/anim/crew/crew_%s_frames.tres" % id)
	portrait.play(&"talk_worried" if worried else &"talk_normal")
	who.text = _name(id)
	speech.text = opinions[id]
	get_tree().create_timer(1.6).timeout.connect(func():
		if is_instance_valid(portrait): portrait.play(&"idle_worried" if worried else &"idle_normal"))

func _name(id: String) -> String:
	for c in GS.D["crew"]:
		if c["id"] == id: return c["name"]
	return id
