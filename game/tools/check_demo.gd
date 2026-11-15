extends SceneTree
func _init():
	var s = load("res://scenes/ui_kit_demo.tscn")
	if s == null: print("ERRO demo"); quit(1); return
	var n = s.instantiate(); root.add_child(n)
	print("demo ok: botoes=", n.get_node("Card/VBox/Buttons").get_child_count(), " barra=", n.get_node("PowerBar").value)
	quit(0)
