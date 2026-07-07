extends Control

const BASE_SIZE: Vector2 = Vector2(480.0, 854.0)
const MAIN_SCENE_PATH := "res://scenes/Main.tscn"

@onready var _canvas: Control = $MenuCanvas
@onready var _start_button: Button = $MenuCanvas/StartButton
@onready var _continue_button: Button = $MenuCanvas/ContinueButton
@onready var _settings_button: Button = $MenuCanvas/SettingsButton
@onready var _start_text: Sprite2D = $MenuCanvas/TextButtonStart
@onready var _continue_text: Sprite2D = $MenuCanvas/TextButtonContinue
@onready var _settings_text: Sprite2D = $MenuCanvas/TextButtonSettings
@onready var _hint_sprite: Sprite2D = $MenuCanvas/TextHintClickStart
@onready var _hint_label: Label = $MenuCanvas/HintStatusLabel
@onready var _controls_label: Label = $MenuCanvas/ControlsLabel

var _starting := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_setup_labels()
	_wire_button(_start_button, _start_text, Callable(self, "_start_game"))
	_wire_button(_continue_button, _continue_text, Callable(self, "_show_no_save_message"))
	_wire_button(_settings_button, _settings_text, Callable(self, "_toggle_controls"))
	_play_bgm("title")
	resized.connect(_layout_canvas)
	_layout_canvas()


func _layout_canvas() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var fit_scale: float = minf(viewport_size.x / BASE_SIZE.x, viewport_size.y / BASE_SIZE.y)
	_canvas.scale = Vector2.ONE * fit_scale
	_canvas.position = (viewport_size - BASE_SIZE * fit_scale) * 0.5


func _setup_labels() -> void:
	_controls_label.visible = false
	_hint_label.visible = false
	var labels: Array[Label] = [_controls_label, _hint_label]
	for label in labels:
		label.add_theme_font_size_override("font_size", 14 if label == _controls_label else 17)
		label.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0) if label == _controls_label else Color(1.0, 0.88, 0.42))
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.09, 0.98))
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
		label.add_theme_constant_override("outline_size", 1 if label == _controls_label else 2)
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)


func _wire_button(button: Button, text_sprite: Sprite2D, callback: Callable) -> void:
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_make_button_invisible(button)
	button.pressed.connect(callback)
	button.mouse_entered.connect(func() -> void:
		text_sprite.modulate = Color(1.0, 0.92, 0.48)
		_play_sfx("menu_select")
	)
	button.mouse_exited.connect(func() -> void:
		text_sprite.modulate = Color.WHITE
	)


func _make_button_invisible(button: Button) -> void:
	var states: Array[String] = ["normal", "hover", "pressed", "disabled", "focus"]
	for state in states:
		var empty_style := StyleBoxFlat.new()
		empty_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		button.add_theme_stylebox_override(state, empty_style)


func _toggle_controls() -> void:
	if _starting:
		return

	_controls_label.visible = not _controls_label.visible
	_hint_sprite.visible = not _controls_label.visible
	_hint_label.visible = _controls_label.visible
	_hint_label.text = "再按一次设置隐藏提示" if _controls_label.visible else ""


func _show_no_save_message() -> void:
	if _starting:
		return

	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and bool(save_manager.call("request_continue")):
		_play_sfx("menu_confirm")
		_starting = true
		_hint_sprite.visible = false
		_hint_label.visible = true
		_hint_label.text = "正在读取存档..."
		var continue_err: Error = get_tree().change_scene_to_file(MAIN_SCENE_PATH)
		if continue_err != OK:
			_starting = false
			_hint_label.text = "存档读取失败，请检查 Main.tscn"
			push_error("StartMenu failed to continue %s, error %s" % [MAIN_SCENE_PATH, continue_err])
		return

	_controls_label.visible = false
	_hint_sprite.visible = false
	_hint_label.visible = true
	_hint_label.text = "暂无存档，请点击开始游戏"


func _start_game() -> void:
	if _starting:
		return

	_starting = true
	_play_sfx("menu_confirm")
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.call("start_new_game")

	_hint_sprite.visible = false
	_hint_label.visible = true
	_hint_label.text = "正在进入风之高塔..."

	var err: Error = get_tree().change_scene_to_file(MAIN_SCENE_PATH)
	if err != OK:
		_starting = false
		_hint_label.text = "关卡加载失败，请检查 Main.tscn"
		push_error("StartMenu failed to load %s, error %s" % [MAIN_SCENE_PATH, err])


func _play_sfx(sound_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_sfx", sound_name)


func _play_bgm(track_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_bgm", track_name)
