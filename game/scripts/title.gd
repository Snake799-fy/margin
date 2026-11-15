extends Node2D
## Title screen: click or press any key to start.

func _ready() -> void:
	GS.snd.play_music("theme")

func _unhandled_input(e: InputEvent) -> void:
	if (e is InputEventMouseButton and e.pressed) or (e is InputEventKey and e.pressed and (e as InputEventKey).keycode != KEY_N):
		GS.snd.sfx("next")
		get_tree().change_scene_to_file("res://scenes/main.tscn")
