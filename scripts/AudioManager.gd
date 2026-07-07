extends Node

const SFX_PATHS := {
	"menu_select": "res://assets/audio/sfx/menu_select.wav",
	"menu_confirm": "res://assets/audio/sfx/menu_confirm.wav",
	"jump": "res://assets/audio/sfx/jump.wav",
	"land": "res://assets/audio/sfx/land.wav",
	"dash": "res://assets/audio/sfx/dash.wav",
	"collect_feather": "res://assets/audio/sfx/collect_feather.wav",
	"collect_coin": "res://assets/audio/sfx/collect_coin.wav",
	"portal_locked": "res://assets/audio/sfx/portal_locked.wav",
	"portal_clear": "res://assets/audio/sfx/portal_clear.wav",
	"chest_open": "res://assets/audio/sfx/chest_open.wav"
}

const BGM_PATHS := {
	"title": "res://assets/audio/bgm/title_theme.ogg",
	"level_01": "res://assets/audio/bgm/level_01.ogg"
}

var _bgm_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _last_missing_warning: Dictionary = {}


func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)

	for i in range(8):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%02d" % i
		add_child(player)
		_sfx_pool.append(player)


func play_sfx(name: String) -> void:
	if not SFX_PATHS.has(name):
		_warn_once("unknown_sfx_" + name, "AudioManager: unknown sfx: %s" % name)
		return

	var stream := _load_audio_stream(SFX_PATHS[name])
	if stream == null:
		_warn_once("missing_sfx_" + name, "AudioManager: missing sfx resource: %s" % SFX_PATHS[name])
		return

	var player := _get_free_sfx_player()
	player.stream = stream
	player.play()


func play_bgm(name: String) -> void:
	if not BGM_PATHS.has(name):
		_warn_once("unknown_bgm_" + name, "AudioManager: unknown bgm: %s" % name)
		return

	var stream := _load_audio_stream(BGM_PATHS[name])
	if stream == null:
		_warn_once("missing_bgm_" + name, "AudioManager: missing bgm resource: %s" % BGM_PATHS[name])
		return

	if _bgm_player.stream == stream and _bgm_player.playing:
		return

	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.play()


func stop_bgm() -> void:
	if _bgm_player:
		_bgm_player.stop()


func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	return _sfx_pool[0]


func _load_audio_stream(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream


func _warn_once(key: String, message: String) -> void:
	if _last_missing_warning.has(key):
		return
	_last_missing_warning[key] = true
	push_warning(message)
