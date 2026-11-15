extends Control
## Screen manager: keeps the HUD on top and swaps the phase screens.

const SCREENS := {
	"intro": preload("res://scripts/screen_intro.gd"),
	"concept": preload("res://scripts/screen_concept.gd"),
	"trade": preload("res://scripts/screen_trade.gd"),
	"cargo": preload("res://scripts/screen_cargo.gd"),
	"review": preload("res://scripts/screen_review.gd"),
	"landing": preload("res://scripts/screen_landing.gd"),
	"surface": preload("res://scripts/screen_surface.gd"),
	"cutscene": preload("res://scripts/screen_cutscene.gd"),
	"report": preload("res://scripts/screen_report.gd"),
	"prep": preload("res://scripts/screen_prep.gd"),
}

var hud: Hud
var holder: Control
var current: Control

func _ready() -> void:
	size = Vector2(320, 180)
	var bgp := Panel.new()
	bgp.size = Vector2(320, 180)
	bgp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bgp)
	holder = Control.new()
	holder.size = Vector2(320, 180)
	holder.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(holder)
	hud = Hud.new()
	add_child(hud)
	goto("intro")

func goto(name: String) -> void:
	if current: current.queue_free()
	current = SCREENS[name].new()
	current.size = Vector2(320, 180)
	current.set("main", self)
	holder.add_child(current)
	hud.mission = name in ["landing", "surface", "report"]
	hud.visible = not name in ["landing", "intro", "surface", "cutscene", "report", "prep"]
	if name != "cutscene":
		GS.snd.play_music({"surface": "surface", "report": "report"}.get(name, "theme"))
	hud.refresh()

func refresh_hud() -> void:
	hud.refresh()
