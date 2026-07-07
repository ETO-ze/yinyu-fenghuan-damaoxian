class_name Level02Data
extends LevelData


func _init() -> void:
	level_id = "level_02"
	level_name = "云桥花园 · 浮云试炼"
	next_level_id = ""
	required_feathers = 6

	viewport_size = Vector2(480, 854)
	level_width = 4300.0
	world_bottom = 1000.0

	player_start = Vector2(120, 730)
	central_wind_ring_position = Vector2(2100, 640)
	portal_position = Vector2(3860, 620)

	platform_layout = [
		{"name": "start_ground", "center": Vector2(280, 812), "size": Vector2(560, 72), "type": "stone"},
		{"name": "garden_ground", "center": Vector2(1040, 812), "size": Vector2(480, 72), "type": "stone"},
		{"name": "cloud_a", "center": Vector2(760, 650), "size": Vector2(180, 28), "type": "cloud"},
		{"name": "cloud_b", "center": Vector2(1080, 575), "size": Vector2(180, 28), "type": "cloud"},
		{"name": "cloud_c", "center": Vector2(1410, 640), "size": Vector2(190, 28), "type": "cloud"},
		{"name": "rest_mid", "center": Vector2(1840, 812), "size": Vector2(520, 72), "type": "stone"},
		{"name": "cloud_d", "center": Vector2(2200, 615), "size": Vector2(190, 28), "type": "cloud"},
		{"name": "cloud_e", "center": Vector2(2520, 550), "size": Vector2(190, 28), "type": "cloud"},
		{"name": "cloud_f", "center": Vector2(2860, 620), "size": Vector2(190, 28), "type": "cloud"},
		{"name": "tower_step_a", "center": Vector2(3220, 675), "size": Vector2(220, 30), "type": "stone"},
		{"name": "tower_ground", "center": Vector2(3740, 812), "size": Vector2(620, 72), "type": "stone"},
		{"name": "tower_finish", "center": Vector2(3860, 710), "size": Vector2(360, 34), "type": "stone"}
	]

	feather_positions = [
		Vector2(760, 590),
		Vector2(1080, 515),
		Vector2(1410, 580),
		Vector2(2200, 555),
		Vector2(2520, 490),
		Vector2(2860, 560),
		Vector2(3600, 650)
	]

	coin_positions = [
		Vector2(520, 765),
		Vector2(920, 765),
		Vector2(1240, 540),
		Vector2(1720, 765),
		Vector2(2380, 530),
		Vector2(3060, 765),
		Vector2(3480, 765)
	]

	route_platform_names = [
		"start_ground",
		"cloud_a",
		"cloud_b",
		"cloud_c",
		"rest_mid",
		"cloud_d",
		"cloud_e",
		"cloud_f",
		"tower_step_a",
		"tower_finish"
	]

	checkpoint_layout = [
		{"id": "start", "position": player_start},
		{"id": "garden_mid", "position": Vector2(1840, 730)},
		{"id": "before_tower", "position": Vector2(3220, 610)}
	]
