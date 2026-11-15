extends Node
## Sound manager (child of GS, use GS.snd): music loops + sound effects. All sounds made in code by Claude (AI, see CREDITS).
## Press N to mute/unmute.

var music := AudioStreamPlayer.new()
var current := ""
var muted := false
var _cache := {}
var _pool: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music.volume_db = -8.0
	add_child(music)
	for i in 6:
		var p := AudioStreamPlayer.new()
		p.volume_db = -4.0
		add_child(p)
		_pool.append(p)
	# every button in the game clicks
	get_tree().node_added.connect(func(n):
		if n is BaseButton: n.pressed.connect(func(): sfx("click")))

func _load(name: String) -> AudioStream:
	if not _cache.has(name):
		_cache[name] = load("res://audio/%s.ogg" % name)
	return _cache[name]

func play_music(name: String) -> void:
	if name == current: return
	current = name
	var s := _load("music_" + name) as AudioStreamOggVorbis
	if s: s.loop = true
	var tw := create_tween()
	if music.playing:
		tw.tween_property(music, "volume_db", -40.0, 0.4)
	tw.tween_callback(func():
		music.stream = s
		music.volume_db = -8.0
		music.play())

func sfx(name: String) -> void:
	if muted: return
	for p in _pool:
		if not p.playing:
			p.stream = _load("sfx_" + name)
			p.play()
			return

func _unhandled_key_input(e: InputEvent) -> void:
	if e.pressed and (e as InputEventKey).keycode == KEY_N:
		muted = not muted
		AudioServer.set_bus_mute(0, muted)
