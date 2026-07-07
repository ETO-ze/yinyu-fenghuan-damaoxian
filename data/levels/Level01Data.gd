class_name Level01Data
extends LevelData


func _init() -> void:
	level_id = "level_01"
	level_name = "风之高塔 · 完整横版关卡"
	required_feathers = 5

	viewport_size = Vector2(480, 854)
	level_width = 3800.0
	world_bottom = 960.0

	player_start = Vector2(120, 730)
	central_wind_ring_position = Vector2(2050, 630)
	portal_position = Vector2(3420, 620)

	platform_layout = [
		{"name": "start_ground", "center": Vector2(270, 812), "size": Vector2(540, 72)},
		{"name": "approach_ground", "center": Vector2(1240, 812), "size": Vector2(500, 72)},
		{"name": "portal_ground", "center": Vector2(2220, 812), "size": Vector2(520, 72)},
		{"name": "tower_ground", "center": Vector2(3340, 812), "size": Vector2(620, 72)},
		{"name": "start_step", "center": Vector2(540, 718), "size": Vector2(190, 30)},
		{"name": "floating_a", "center": Vector2(890, 648), "size": Vector2(188, 30)},
		{"name": "floating_b", "center": Vector2(1240, 580), "size": Vector2(206, 30)},
		{"name": "floating_c", "center": Vector2(1580, 638), "size": Vector2(220, 30)},
		{"name": "portal_left", "center": Vector2(1920, 570), "size": Vector2(210, 30)},
		{"name": "portal_right", "center": Vector2(2260, 620), "size": Vector2(210, 30)},
		{"name": "tower_step_a", "center": Vector2(2600, 678), "size": Vector2(220, 30)},
		{"name": "tower_step_b", "center": Vector2(2960, 606), "size": Vector2(210, 30)},
		{"name": "tower_finish", "center": Vector2(3420, 710), "size": Vector2(360, 34)}
	]

	feather_positions = [
		Vector2(540, 659),
		Vector2(890, 589),
		Vector2(1240, 521),
		Vector2(1580, 579),
		Vector2(1920, 511),
		Vector2(2260, 561),
		Vector2(2600, 619),
		Vector2(2960, 547),
		Vector2(3300, 650)
	]

	coin_positions = [
		Vector2(700, 765),
		Vector2(1050, 765),
		Vector2(1390, 765),
		Vector2(1740, 765),
		Vector2(2100, 765),
		Vector2(2440, 765),
		Vector2(2780, 660),
		Vector2(3180, 660)
	]

	route_platform_names = [
		"start_ground",
		"start_step",
		"floating_a",
		"floating_b",
		"floating_c",
		"portal_left",
		"portal_right",
		"tower_step_a",
		"tower_step_b",
		"tower_finish"
	]
