extends SceneTree
func _init():
	var errs = 0
	var f = FileAccess.open("res://art/anim/anim_manifest.json", FileAccess.READ)
	var man = JSON.parse_string(f.get_as_text())
	var n_anim = 0
	for ent in man.keys():
		var e = man[ent]
		var sf = load(e["sprite_frames"])
		if sf == null or not (sf is SpriteFrames):
			print("ERRO load ", ent); errs += 1; continue
		for an in e["animations"].keys():
			var a = e["animations"][an]
			n_anim += 1
			if not sf.has_animation(an):
				print("ERRO sem animacao ", ent, ".", an); errs += 1; continue
			if sf.get_frame_count(an) != int(a["frames"]):
				print("ERRO frames ", ent, ".", an); errs += 1
			if abs(sf.get_animation_speed(an) - float(a["fps"])) > 0.001 or sf.get_animation_loop(an) != bool(a["loop"]):
				print("ERRO fps/loop ", ent, ".", an); errs += 1
			for i in sf.get_frame_count(an):
				var t = sf.get_frame_texture(an, i)
				if not (t is AtlasTexture) or t.atlas == null:
					print("ERRO textura ", ent, ".", an, " ", i); errs += 1; continue
				var r = t.region
				if r.size != Vector2(a["frame_w"], a["frame_h"]) or r.end.x > t.atlas.get_width() or r.end.y > t.atlas.get_height():
					print("ERRO regiao ", ent, ".", an, " ", i, " ", r, " atlas ", t.atlas.get_size()); errs += 1
			if sf.get_frame_texture(an, 0).atlas.get_width() != int(a["frame_w"]) * int(a["frames"]):
				print("ERRO largura da folha ", ent, ".", an); errs += 1
	for sc in ["res://art/anim/examples/title_screen_example.tscn", "res://art/anim/examples/landing_example.tscn"]:
		var p = load(sc)
		if p == null: print("ERRO cena ", sc); errs += 1; continue
		var inst = p.instantiate()
		if inst == null: print("ERRO instanciar ", sc); errs += 1
		else: inst.free()
	print("VALIDACAO: entidades=", man.size(), " animacoes=", n_anim, " erros=", errs)
	quit(errs)
