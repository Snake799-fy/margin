extends Control
## Challenges (opt-in) and the rocket upgrades they unlock.
## Win a mission with a challenge ON -> its upgrade unlocks -> buy it with tokens (won missions pay tokens).

var main
var info: Label
var tok: Label
var ups := {}
var tgl := {}

func _ready() -> void:
	add_child(UI.place(UI.label("UPGRADES & CHALLENGES", 8, UI.SAND), 6, 5))
	tok = UI.label("", 8, UI.YELLOW)
	tok.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(UI.place(tok, 200, 5, 114))
	add_child(UI.place(UI.label("CHALLENGES (OPTIONAL)", UI.SMALL, UI.RUST), 6, 20))
	add_child(UI.place(UI.label("WIN WITH IT ON = UNLOCK", UI.SMALL, UI.SKY), 164, 20))
	var y := 30
	for id in GS.MODS:
		var m: Dictionary = GS.MODS[id]
		var up_id: String = m["unlocks"]
		var b := UI.toggle("", null, func(): pass)
		b.button_pressed = GS.mod(id)
		b.toggled.connect(func(on): GS.mods[id] = on; GS.snd.sfx("pick" if on else "click"); _refresh())
		b.mouse_entered.connect(func(): info.text = "%s Win with it on to unlock %s." % [m["text"], GS.UPGRADES[up_id]["name"]])
		add_child(UI.place(b, 6, y, 150, 14))
		tgl[id] = b
		var u: Dictionary = GS.UPGRADES[up_id]
		var ub := UI.button("", func(): _buy(up_id), UI.SMALL)
		ub.mouse_entered.connect(func(): info.text = u["text"] if GS.unlocked(up_id) else "LOCKED: win a mission with %s on." % m["name"])
		add_child(UI.place(ub, 164, y, 150, 14))
		ups[up_id] = ub
		y += 16
	var bg := ColorRect.new()
	bg.color = Color(UI.DARK, 0.8)
	add_child(UI.place(bg, 4, 145, 312, 12))
	info = UI.label("WIN = +3 TOKENS (+1 PER CHALLENGE ON).", UI.SMALL, UI.WHITE)
	info.clip_text = true
	add_child(UI.place(info, 6, 147, 308, 8))
	add_child(UI.place(UI.button("< BACK", func(): main.goto(GS.prep_back), UI.SMALL), 236, 161, 80, 16))
	_refresh()

func _buy(id: String) -> void:
	if GS.buy(id):
		GS.snd.sfx("success")
		info.text = "BOUGHT: %s (level %d)." % [GS.UPGRADES[id]["name"], GS.up(id)]
		var b: Button = ups[id]
		b.pivot_offset = b.size / 2.0
		b.scale = Vector2(1.15, 1.15)
		create_tween().tween_property(b, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	else:
		GS.snd.sfx("error")
		info.text = "NOT ENOUGH TOKENS. WIN MISSIONS TO EARN MORE." if GS.unlocked(id) else "LOCKED: beat its challenge first."
	_refresh()

func _refresh() -> void:
	tok.text = "%d TOKENS" % int(GS.meta["tokens"])
	for id in tgl:
		var beaten: bool = id in GS.meta.get("beaten", [])
		tgl[id].text = GS.MODS[id]["name"] + ("  (WON)" if beaten else "")
	for id in ups:
		var u: Dictionary = GS.UPGRADES[id]
		var lvl := GS.up(id)
		var costs: Array = u["cost"]
		var b: Button = ups[id]
		if not GS.unlocked(id):
			b.text = u["name"] + " (LOCKED)"; b.disabled = true
		elif lvl >= costs.size():
			b.text = "%s  MAX" % u["name"]; b.disabled = true
		else:
			b.text = "%s %s  %dT" % [u["name"], "I".repeat(lvl + 1), int(costs[lvl])]
			b.disabled = int(GS.meta["tokens"]) < int(costs[lvl])
