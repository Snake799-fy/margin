extends SceneTree
var t := 0.0
var scenes := ["res://scenes/title.tscn", "res://scenes/ui_kit_demo.tscn"]
var i := 0
var cur
func _init():
	_load()
func _load():
	if cur: cur.queue_free()
	cur = load(scenes[i]).instantiate(); root.add_child(cur); t = 0.0
func _process(d):
	t += d
	if t > 1.5:
		var img = root.get_viewport().get_texture().get_image()
		img.save_png("/tmp/shot_%d.png" % i)
		i += 1
		if i >= scenes.size(): quit(0)
		else: _load()
	return false
