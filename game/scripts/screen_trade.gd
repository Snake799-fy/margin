extends Control
## Phase 2 - Trade study (CML 3, launch segment): rocket x launch date. Two big choices, short text.

var main
var info: Label
var rocket_btns := {}
var window_btns := {}

func _ready() -> void:
	UI.header(self, "STEP 2/7 - TRADE STUDY (CML 3)", "PICK A ROCKET AND A LAUNCH DATE")
	add_child(UI.place(UI.label("ROCKET", UI.SMALL, UI.GREY), 4, 42))
	var g := ButtonGroup.new()
	var i := 0
	for l in GS.D["launchers"]:
		var id: String = l["id"]
		var b := _choice(g, func(): GS.launcher = id; _update())
		b.button_pressed = GS.launcher == id
		add_child(UI.place(b, 4 + i * 158, 50, 154, 34))
		rocket_btns[id] = b
		i += 1
	add_child(UI.place(UI.label("LAUNCH DATE (EARTH-MARS WINDOW)", UI.SMALL, UI.GREY), 4, 92))
	var g2 := ButtonGroup.new()
	i = 0
	for w in GS.D["windows"]:
		var id: String = w["id"]
		var b := _choice(g2, func(): GS.window = id; _update())
		b.button_pressed = GS.window == id
		add_child(UI.place(b, 4 + i * 158, 100, 154, 34))
		window_btns[id] = b
		i += 1
	info = UI.label("", 8, UI.SAND)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(UI.place(info, 0, 142, 320))
	add_child(UI.place(UI.button("< BACK", func(): main.goto("concept")), 4, 160))
	add_child(UI.place(UI.button("NEXT >", func(): main.goto("cargo")), 262, 160))
	_update()

## A big choice card: a toggle button with two labels on it (title + numbers).
func _choice(g: ButtonGroup, cb: Callable) -> Button:
	var b := UI.toggle("", g, cb, UI.SMALL)
	for i in 2:
		var l := UI.label("", 8 if i == 0 else UI.SMALL, UI.WHITE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.position = Vector2(0, 7 + i * 13)
		l.size = Vector2(154, 10)
		l.name = "L%d" % i
		b.add_child(l)
	b.toggled.connect(func(on):
		for i in 2: b.get_node("L%d" % i).add_theme_color_override("font_color", UI.YELLOW if on else UI.WHITE))
	return b

func _set_text(b: Button, title: String, sub: String) -> void:
	b.get_node("L0").text = title
	b.get_node("L1").text = sub
	for i in 2: b.get_node("L%d" % i).add_theme_color_override("font_color", UI.YELLOW if b.button_pressed else UI.WHITE)

func _update() -> void:
	var core := float(GS.D["core"]["mass_t"])
	var bonus := float(GS.window_data()["launcher_bonus_t"])
	for l in GS.D["launchers"]:
		var b: Button = rocket_btns[l["id"]]
		var cargo := float(l["capacity_t"]) + bonus - core
		_set_text(b, "HEAVY" if l["id"] == "heavy" else "SUPER-HEAVY", "%.0f T CARGO - %d M$" % [cargo, l["cost"]])
	for w in GS.D["windows"]:
		var b: Button = window_btns[w["id"]]
		_set_text(b, "ON TIME" if w["id"] == "A" else "LATE", "+%d T - DUST RISK %d%%" % [w["launcher_bonus_t"], int(100 * float(w["dust_event_chance"]))])
	var s := GS.stats()
	info.text = "CARGO %.0f T   MONEY %d M$" % [s["cap"], int(s["budget"]) - int(GS.D["core"]["cost"]) - int(GS.launcher_data()["cost"])]
	if main: main.refresh_hud()
