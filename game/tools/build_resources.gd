extends SceneTree
# Generates the pixel font (no antialiasing), the UI theme and the map TileSet. Run: godot --headless -s build_resources.gd
func _init():
	var font := FontFile.new()
	var err = font.load_dynamic_font("res://fonts/PressStart2P-Regular.woff2")
	if err != OK: print("ERRO fonte ", err); quit(1); return
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	font.multichannel_signed_distance_field = false
	ResourceSaver.save(font, "res://fonts/press_start_2p.tres")

	var th := Theme.new()
	th.default_font = load("res://fonts/press_start_2p.tres")
	th.default_font_size = 8
	var W := Color("#f4f0e8"); var K := Color("#1a1020"); var G := Color("#a0a0b0")
	var btn := {"normal":"ui_button_normal","hover":"ui_button_hover","pressed":"ui_button_pressed","disabled":"ui_button_disabled"}
	for st in btn:
		var sb := StyleBoxTexture.new()
		sb.texture = load("res://art/ui/%s.png" % btn[st])
		sb.texture_margin_left = 4; sb.texture_margin_top = 3; sb.texture_margin_right = 4; sb.texture_margin_bottom = 5
		sb.content_margin_left = 6; sb.content_margin_right = 6
		sb.content_margin_top = 4 if st != "pressed" else 5; sb.content_margin_bottom = 6 if st != "pressed" else 5
		th.set_stylebox(st, "Button", sb)
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	th.set_color("font_color", "Button", W)
	th.set_color("font_hover_color", "Button", K)       # dark text on hover (contrast)
	th.set_color("font_pressed_color", "Button", W)
	th.set_color("font_focus_color", "Button", W)
	th.set_color("font_hover_pressed_color", "Button", W)
	th.set_color("font_disabled_color", "Button", G)
	var console := StyleBoxTexture.new()
	console.texture = load("res://art/ui/ui_panel_console.png")
	console.texture_margin_left = 8; console.texture_margin_top = 8; console.texture_margin_right = 8; console.texture_margin_bottom = 8
	console.content_margin_left = 8; console.content_margin_top = 8; console.content_margin_right = 8; console.content_margin_bottom = 8
	th.set_stylebox("panel", "Panel", console)
	th.set_stylebox("panel", "PanelContainer", console)
	th.set_color("font_color", "Label", W)
	th.set_color("default_color", "RichTextLabel", W)
	# type variation: decision card (dark text on the light body)
	var card := StyleBoxTexture.new()
	card.texture = load("res://art/ui/ui_card.png")
	card.texture_margin_left = 6; card.texture_margin_top = 12; card.texture_margin_right = 6; card.texture_margin_bottom = 6
	card.content_margin_left = 8; card.content_margin_top = 3; card.content_margin_right = 8; card.content_margin_bottom = 8
	th.add_type("CardPanel"); th.set_type_variation("CardPanel", "PanelContainer")
	th.set_stylebox("panel", "CardPanel", card)
	var cardA := card.duplicate(); cardA.texture = load("res://art/ui/ui_card_alert.png")
	th.add_type("CardPanelAlert"); th.set_type_variation("CardPanelAlert", "PanelContainer")
	th.set_stylebox("panel", "CardPanelAlert", cardA)
	th.add_type("CardText"); th.set_type_variation("CardText", "Label")
	th.set_color("font_color", "CardText", K)
	ResourceSaver.save(th, "res://resources/margin_theme.tres")

	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://art/map/tiles_sheet.png")
	src.texture_region_size = Vector2i(16, 16)
	for i in 6: src.create_tile(Vector2i(i, 0))
	ts.add_source(src, 0)
	ResourceSaver.save(ts, "res://resources/margin_tileset.tres")
	print("RECURSOS OK")
	quit(0)
