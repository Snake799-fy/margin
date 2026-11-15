class_name UI
## Small helpers to build the interface in code (theme comes from margin_theme.tres).

const DARK := Color("1a1020")
const RUST := Color("7a3424")
const SAND := Color("f0c48a")
const GREY := Color("a0a0b0")
const WHITE := Color("f4f0e8")
const GREEN := Color("4fb04a")
const YELLOW := Color("f2c230")
const RED := Color("d6362f")
const ORANGE := Color("f07a1e")
const BROWN := Color("7a5230")
const BLUE := Color("3a7bd5")
const SKY := Color("8fc7f0")
const SMALL := 6   # body text size (canvas_items stretch keeps it crisp)

static func label(text: String, size := SMALL, color := WHITE, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

static func card_text(text: String, size := SMALL) -> Label:
	var l := Label.new()
	l.theme_type_variation = &"CardText"
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

static func button(text: String, cb: Callable, size := 8) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	return b

static func toggle(text: String, group: ButtonGroup, cb: Callable, size := SMALL) -> Button:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.button_group = group
	b.add_theme_font_size_override("font_size", size)
	b.focus_mode = Control.FOCUS_NONE
	mark_toggle(b)
	b.pressed.connect(cb)
	return b

## Selected toggles get yellow text so the choice is obvious.
static func mark_toggle(b: Button) -> void:
	b.add_theme_color_override("font_pressed_color", YELLOW)
	b.add_theme_color_override("font_hover_pressed_color", YELLOW)

const _BAR_UNDER := preload("res://art/ui/ui_bar_under.png")
const _BAR := {
	"green": preload("res://art/ui/ui_bar_fill_green.png"),
	"yellow": preload("res://art/ui/ui_bar_fill_yellow.png"),
	"red": preload("res://art/ui/ui_bar_fill_red.png"),
}

## Pixel-art progress bar. Color by fraction unless given.
static func bar(value: float, max_value: float, w: float, h := 6.0, col := "") -> TextureProgressBar:
	var b := TextureProgressBar.new()
	b.size = Vector2(w, h)
	b.nine_patch_stretch = true
	b.stretch_margin_left = 2; b.stretch_margin_top = 2; b.stretch_margin_right = 2; b.stretch_margin_bottom = 2
	b.texture_under = _BAR_UNDER
	b.max_value = max_value
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_bar(b, value, col)
	return b

static func set_bar(b: TextureProgressBar, value: float, col := "") -> void:
	b.value = value
	if col == "":
		var f := value / maxf(b.max_value, 0.001)
		col = "green" if f >= 0.5 else ("yellow" if f >= 0.3 else "red")
	b.texture_progress = _BAR[col]

## Card = PanelContainer + VBox. Returns the VBox (card is its parent).
static func card(title: String, alert := false) -> VBoxContainer:
	var p := PanelContainer.new()
	p.theme_type_variation = &"CardPanelAlert" if alert else &"CardPanel"
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	p.add_child(v)
	var t := Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", SMALL)
	t.clip_text = true
	t.custom_minimum_size.y = 11
	v.add_child(t)
	return v

static func place(c: Control, x: float, y: float, w := -1.0, h := -1.0) -> Control:
	c.position = Vector2(x, y)
	if w > 0 and h > 0:
		c.size = Vector2(w, h)
	elif w > 0:
		c.size.x = w
	return c

static func frames(path: String) -> AnimatedSprite2D:
	var a := AnimatedSprite2D.new()
	a.sprite_frames = load(path)
	a.centered = false
	return a

## step: small grey line ("STEP 1/7 - CONCEPT"); todo: big instruction in sand.
static func header(parent: Control, step: String, todo: String) -> void:
	parent.add_child(place(label(step, SMALL, GREY), 4, 20))
	parent.add_child(place(label(todo, 8, SAND), 4, 28))
	var n := int(step.get_slice("STEP ", 1).get_slice("/", 0)) if step.begins_with("STEP") else 0
	if n > 0: stepper(parent, n, 244, 21)

## Mission progress: 7 small blocks (done = green, now = yellow, next = grey).
static func stepper(parent: Control, n: int, x: int, y: int) -> void:
	for i in 7:
		var r := ColorRect.new()
		r.color = GREEN if i + 1 < n else (YELLOW if i + 1 == n else Color("3a2438"))
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(place(r, x + i * 10, y, 8, 4))


## Discreet text-only button (secondary options that should not compete with the main ones).
static func link(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", SMALL)
	b.add_theme_color_override("font_color", GREY)
	b.add_theme_color_override("font_hover_color", SAND)
	b.add_theme_color_override("font_pressed_color", YELLOW)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(cb)
	return b
