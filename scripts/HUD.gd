extends CanvasLayer

const GAME_TITLE := "银羽风环大冒险"
const VICTORY_MESSAGE := "风之徽记已点亮，新的旅程即将开启！"
const FAILURE_MESSAGE := "羽翼能量回路熄火了，先整理斗篷再出发。"

var title_label: Label
var lives_label: Label
var energy_label: Label
var score_label: Label
var feather_label: Label
var level_label: Label
var timer_label: Label
var hint_label: Label
var victory_panel: PanelContainer
var victory_detail: Label
var failure_panel: PanelContainer
var failure_detail: Label
var hint_time_left := 0.0

func _ready() -> void:
	_build_ui()


func _process(delta: float) -> void:
	if hint_time_left > 0.0:
		hint_time_left -= delta
		if hint_time_left <= 0.0:
			hint_label.visible = false


func update_stats(lives: int, wing_energy: float, score: int, feathers: int, required: int, level_name: String, elapsed: float) -> void:
	title_label.text = GAME_TITLE
	lives_label.text = "生命 " + _repeat_text("♥", lives)
	energy_label.text = "羽翼能量 " + str(roundi(wing_energy)) + "%"
	score_label.text = "分数 %06d" % score
	feather_label.text = "羽毛 %d/%d" % [feathers, required]
	level_label.text = level_name
	timer_label.text = _format_time(elapsed)


func show_hint(text: String) -> void:
	hint_label.text = text
	hint_label.visible = true
	hint_time_left = 2.2


func show_victory(final_time: float, score: int, feathers: int) -> void:
	victory_detail.text = "%s\n用时 %s  分数 %06d  羽毛 %d" % [VICTORY_MESSAGE, _format_time(final_time), score, feathers]
	victory_panel.visible = true
	show_hint("恭喜通关！")


func show_failure(final_time: float, score: int, feathers: int) -> void:
	failure_detail.text = "%s\n用时 %s  分数 %06d  羽毛 %d" % [FAILURE_MESSAGE, _format_time(final_time), score, feathers]
	failure_panel.visible = true
	show_hint("挑战失败")


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var top_bar := PanelContainer.new()
	top_bar.anchor_left = 0.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_bottom = 136.0
	top_bar.add_theme_stylebox_override("panel", _panel_style(Color(0.02, 0.025, 0.035, 0.94), Color(0.85, 0.90, 0.95), 2))
	root.add_child(top_bar)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 3)
	rows.offset_left = 10.0
	rows.offset_top = 8.0
	rows.offset_right = -10.0
	rows.offset_bottom = -8.0
	top_bar.add_child(rows)

	title_label = _make_label(GAME_TITLE, 21)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(title_label)

	level_label = _make_label("风之高塔 · 完整横版关卡", 15)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(level_label)

	var row_one := HBoxContainer.new()
	row_one.alignment = BoxContainer.ALIGNMENT_CENTER
	row_one.add_theme_constant_override("separation", 10)
	rows.add_child(row_one)
	lives_label = _make_label("生命 ♥♥♥", 16)
	energy_label = _make_label("羽翼能量 100%", 16)
	timer_label = _make_label("00:00.00", 16)
	row_one.add_child(_make_icon("res://assets/ui/ui_icon_heart_full.png", 18))
	row_one.add_child(lives_label)
	row_one.add_child(_make_icon("res://assets/ui/ui_icon_wing_energy_full.png", 18))
	row_one.add_child(energy_label)
	row_one.add_child(_make_icon("res://assets/ui/ui_icon_timer.png", 18))
	row_one.add_child(timer_label)

	var row_two := HBoxContainer.new()
	row_two.alignment = BoxContainer.ALIGNMENT_CENTER
	row_two.add_theme_constant_override("separation", 18)
	rows.add_child(row_two)
	score_label = _make_label("分数 000000", 16)
	feather_label = _make_label("羽毛 0/5", 16)
	row_two.add_child(_make_icon("res://assets/ui/ui_icon_score_coin_00.png", 18))
	row_two.add_child(score_label)
	row_two.add_child(_make_icon("res://assets/ui/ui_icon_feather_00.png", 18))
	row_two.add_child(feather_label)

	hint_label = _make_label("", 18)
	hint_label.anchor_left = 0.08
	hint_label.anchor_right = 0.92
	hint_label.anchor_top = 0.15
	hint_label.anchor_bottom = 0.15
	hint_label.offset_top = 0.0
	hint_label.offset_bottom = 34.0
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.visible = false
	root.add_child(hint_label)

	victory_panel = PanelContainer.new()
	victory_panel.anchor_left = 0.05
	victory_panel.anchor_top = 0.68
	victory_panel.anchor_right = 0.95
	victory_panel.anchor_bottom = 0.95
	victory_panel.visible = false
	victory_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.01, 0.012, 0.018, 0.96), Color(0.96, 0.96, 0.90), 3))
	root.add_child(victory_panel)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	victory_panel.add_child(box)

	var victory_title := _make_label("恭喜通关！", 27)
	victory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(victory_title)

	victory_detail = _make_label("", 16)
	victory_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(victory_detail)

	failure_panel = PanelContainer.new()
	failure_panel.anchor_left = 0.05
	failure_panel.anchor_top = 0.68
	failure_panel.anchor_right = 0.95
	failure_panel.anchor_bottom = 0.95
	failure_panel.visible = false
	failure_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.018, 0.02, 0.96), Color(0.94, 0.72, 0.62), 3))
	root.add_child(failure_panel)

	var failure_box := VBoxContainer.new()
	failure_box.alignment = BoxContainer.ALIGNMENT_CENTER
	failure_box.add_theme_constant_override("separation", 10)
	failure_panel.add_child(failure_box)

	var failure_title := _make_label("挑战失败", 27)
	failure_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	failure_box.add_child(failure_title)

	failure_detail = _make_label("", 16)
	failure_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	failure_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	failure_box.add_child(failure_detail)


func _make_label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _make_icon(path: String, size: int) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(size, size)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(path):
		icon.texture = load(path) as Texture2D
	return icon


func _panel_style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	return style


func _repeat_text(text: String, count: int) -> String:
	var out := ""
	for i in range(count):
		out += text
	return out


func _format_time(seconds: float) -> String:
	var minutes := int(seconds / 60.0)
	var secs := int(seconds) % 60
	var centiseconds := int(fposmod(seconds, 1.0) * 100.0)
	return "%02d:%02d.%02d" % [minutes, secs, centiseconds]
