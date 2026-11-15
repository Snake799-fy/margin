class_name Hud
extends Control
## Top bar with the 6 mission resources. Always visible. Call refresh() after any change.

const KEYS := ["mass", "power", "budget", "data", "comms", "time"]
const TEX_UNDER := preload("res://art/ui/ui_bar_under.png")
const TEX := {
	"green": preload("res://art/ui/ui_bar_fill_green.png"),
	"yellow": preload("res://art/ui/ui_bar_fill_yellow.png"),
	"red": preload("res://art/ui/ui_bar_fill_red.png"),
}

var mission := false
var slots := {}

func _ready() -> void:
	size = Vector2(320, 18)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := ColorRect.new()
	bg.color = Color(UI.DARK, 0.9)
	bg.size = Vector2(320, 18)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	for i in KEYS.size():
		var k: String = KEYS[i]
		var x := i * 53 + 1
		var slot := Control.new()
		slot.position = Vector2(x, 0)
		slot.size = Vector2(53, 18)
		slot.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(slot)
		var icon := UI.frames("res://art/anim/ui/res_%s_frames.tres" % k)
		icon.position = Vector2(0, 1)
		icon.play(&"idle")
		slot.add_child(icon)
		var l := UI.label("", UI.SMALL)
		l.position = Vector2(17, 1)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(l)
		var bar := TextureProgressBar.new()
		bar.position = Vector2(17, 10)
		bar.size = Vector2(34, 6)
		bar.nine_patch_stretch = true
		for m in ["stretch_margin_left", "stretch_margin_top", "stretch_margin_right", "stretch_margin_bottom"]:
			bar.set(m, 2)
		bar.texture_under = TEX_UNDER
		bar.texture_progress = TEX["green"]
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(bar)
		slots[k] = {"label": l, "bar": bar, "slot": slot}
	refresh()

func _set_slot(k: String, text: String, frac: float, margin: float, tip: String) -> void:
	var s = slots[k]
	s["label"].text = text
	s["bar"].value = clamp(frac, 0.0, 1.0) * 100.0
	var col := "green"
	if margin < 5.0: col = "red"
	elif margin < 15.0: col = "yellow"
	s["bar"].texture_progress = TEX[col]
	s["slot"].tooltip_text = tip

func refresh() -> void:
	if slots.is_empty(): return
	var s := GS.stats()
	# MASS: used vs capacity (after the habitat core)
	_set_slot("mass", "%.0f/%.0ft" % [s["mass"], s["cap"]], s["mass"] / max(s["cap"], 1.0), s["mass_margin_pct"],
		"MASS: cargo %.1f t of %.1f t the launcher can carry after the habitat core. Margin %d%%." % [s["mass"], s["cap"], int(s["mass_margin_pct"])])
	# BUDGET: remaining
	var left: float = s["budget"] - s["cost"]
	_set_slot("budget", "%d" % int(left), s["cost"] / s["budget"], 100.0 * left / s["budget"],
		"BUDGET: %d of %d M$ spent (core + launcher + cargo). %d left." % [s["cost"], s["budget"], left])
	if not mission:
		var prod: float = s["solar"] + max(0.0, s["energy_base"] + 49.0)
		_set_slot("power", "%+.0f" % s["energy"], 0.5 + s["energy"] / 200.0, (s["energy"] / 50.0) * 100.0,
			"POWER: net %+.0f kWh per sol on a clear day (habitat uses 49)." % s["energy"])
		_set_slot("data", "%.0fMb" % (20 + (25 if GS.has("spectrometer") else 0) + (60 if GS.has("gpr") else 0)), 0.5, 50,
			"DATA: Mb produced per EVA by the instruments you carry.")
		_set_slot("comms", "%.0f" % s["downlink"], s["downlink"] / 140.0, 100.0 if s["downlink"] > 0 else 0.0,
			"COMMS: downlink %.0f Mb per sol. Mars-Earth delay is 4 to 24 minutes." % s["downlink"])
		var need := GS.food_need()
		_set_slot("time", "%.0f/%d" % [s["supply"], need], s["supply"] / max(need, 1), 100.0 * (s["supply"] - need) / need + 15.0,
			"FOOD: %.0f sols packed. A %d-sol stay needs %d (EVAs make the crew eat more)." % [s["supply"], GS.stay, need])
	else:
		var net: float = s["energy_base"] + s["solar"] * (0.3 if GS.dust_today else 1.0)
		_set_slot("power", "%+.0f" % net, 0.5 + net / 200.0, net / 50.0 * 100.0,
			"POWER: net %+.0f kWh today%s. Battery %.0f of %.0f kWh." % [net, " (dust storm)" if GS.dust_today else "", GS.battery, s["storage"]])
		_set_slot("data", "%.0f" % GS.data_buffer, GS.data_buffer / 200.0, 100.0 - GS.data_buffer / 2.0,
			"DATA: %.0f Mb waiting in memory. %.0f Mb already sent to Earth." % [GS.data_buffer, GS.data_sent])
		_set_slot("comms", "%.0f" % GS.data_sent, GS.data_sent / max(GS.data_gen, 1.0), 100.0 * GS.data_sent / max(GS.data_gen, 1.0),
			"COMMS: %.0f Mb sent of %.0f Mb produced. Downlink %.0f Mb/sol." % [GS.data_sent, GS.data_gen, s["downlink"]])
		var to_go: int = GS.stay - GS.sol + 1
		_set_slot("time", "%.0f/%d" % [GS.supplies, to_go], GS.supplies / max(to_go, 1), 100.0 * (GS.supplies - to_go) / max(to_go, 1),
			"TIME: %.0f sols of supplies left, %d sols until the ascent window." % [GS.supplies, to_go])
