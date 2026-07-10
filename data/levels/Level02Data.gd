class_name Level02Data
extends LevelData


func _init() -> void:
	level_id = "level_02"
	level_name = "云桥花园 · 浮云试炼"
	next_level_id = ""
	required_feathers = 6

	viewport_size = Vector2(480, 854)
	level_width = 4650.0
	world_bottom = 1000.0

	player_start = Vector2(120, 730)
	central_wind_ring_position = Vector2(2520, 640)
	portal_position = Vector2(4210, 620)

	platform_layout = [
		{"name": "start_ground", "center": Vector2(260, 812), "size": Vector2(520, 72), "type": "stone"},
		{"name": "garden_ground", "center": Vector2(860, 812), "size": Vector2(320, 72), "type": "stone"},
		{"name": "cloud_a", "center": Vector2(1245, 705), "size": Vector2(200, 28), "type": "cloud"},
		{"name": "cloud_b", "center": Vector2(1570, 650), "size": Vector2(200, 28), "type": "cloud"},
		{"name": "cloud_c", "center": Vector2(1900, 710), "size": Vector2(200, 28), "type": "cloud"},
		{"name": "rest_mid", "center": Vector2(2335, 812), "size": Vector2(430, 72), "type": "stone"},
		{"name": "cloud_d", "center": Vector2(2765, 698), "size": Vector2(190, 28), "type": "cloud"},
		{"name": "cloud_e", "center": Vector2(3065, 640), "size": Vector2(190, 28), "type": "cloud"},
		{"name": "cloud_f", "center": Vector2(3385, 700), "size": Vector2(190, 28), "type": "cloud"},
		{"name": "tower_step_a", "center": Vector2(3720, 690), "size": Vector2(240, 30), "type": "stone"},
		{"name": "tower_ground", "center": Vector2(4140, 812), "size": Vector2(620, 72), "type": "stone"},
		{"name": "tower_finish", "center": Vector2(4210, 710), "size": Vector2(360, 34), "type": "stone"}
	]

	feather_positions = [
		Vector2(1245, 645),
		Vector2(1570, 590),
		Vector2(1900, 650),
		Vector2(2765, 638),
		Vector2(3065, 580),
		Vector2(3385, 640),
		Vector2(3950, 650)
	]

	coin_positions = [
		Vector2(560, 765),
		Vector2(860, 765),
		Vector2(1420, 635),
		Vector2(2220, 765),
		Vector2(2920, 625),
		Vector2(3580, 675),
		Vector2(3940, 765)
	]

	route_platform_names = [
		"start_ground",
		"garden_ground",
		"cloud_a",
		"cloud_b",
		"cloud_c",
		"rest_mid",
		"cloud_d",
		"cloud_e",
		"cloud_f",
		"tower_step_a",
		"tower_ground",
		"tower_finish"
	]

	checkpoint_layout = [
		{"id": "start", "position": player_start},
		{"id": "garden_mid", "position": Vector2(2335, 730)},
		{"id": "before_tower", "position": Vector2(3720, 625)}
	]
