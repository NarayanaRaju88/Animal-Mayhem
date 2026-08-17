extends Node
## Music, ambience, and one-shot SFX. Future worlds swap streams here.

var _music: AudioStreamPlayer
var _ambience: AudioStreamPlayer
var _water: AudioStreamPlayer
var _sfx: AudioStreamPlayer
var _animal: AudioStreamPlayer

var _streams: Dictionary = {}


func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.bus = "Master"
	_music.volume_db = -8.0
	add_child(_music)
	_ambience = AudioStreamPlayer.new()
	_ambience.volume_db = -10.0
	add_child(_ambience)
	_water = AudioStreamPlayer.new()
	_water.volume_db = -16.0
	add_child(_water)
	_sfx = AudioStreamPlayer.new()
	_sfx.volume_db = -6.0
	add_child(_sfx)
	_animal = AudioStreamPlayer.new()
	_animal.volume_db = -8.0
	add_child(_animal)
	_load_all()
	_loop(_ambience, "jungle_ambience")
	_loop(_music, "music_exploration")
	_loop(_water, "water_loop")
	_water.volume_db = -80.0


func set_near_water(near: bool) -> void:
	_water.volume_db = -12.0 if near else -80.0


func play_sfx(key: String) -> void:
	var stream: AudioStream = _streams.get(key)
	if stream == null:
		return
	_sfx.stream = stream
	_sfx.play()


func play_animal(kind: StringName) -> void:
	var key := "sfx_%s" % String(kind)
	var stream: AudioStream = _streams.get(key)
	if stream == null:
		return
	_animal.stream = stream
	_animal.play()


func _load_all() -> void:
	var names := [
		"jungle_ambience", "music_exploration", "water_loop",
		"sfx_footstep", "sfx_push", "sfx_climb", "sfx_coil", "sfx_gate",
		"sfx_switch", "sfx_complete", "sfx_buffalo", "sfx_monkey", "sfx_snake",
	]
	for n in names:
		var path := "res://assets/audio/%s.wav" % n
		if ResourceLoader.exists(path):
			var s: AudioStream = load(path)
			if s is AudioStreamWAV:
				(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD if n.begins_with("jungle") or n.begins_with("music") or n.begins_with("water") else AudioStreamWAV.LOOP_DISABLED
			_streams[n] = s


func _loop(player: AudioStreamPlayer, key: String) -> void:
	var stream: AudioStream = _streams.get(key)
	if stream == null:
		return
	player.stream = stream
	player.play()
