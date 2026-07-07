extends Node2D

const PLAYER_SCRIPT := preload("res://scripts/Player.gd")
const COLLECTIBLE_SCRIPT := preload("res://scripts/Collectible.gd")
const COIN_SCRIPT := preload("res://scripts/Coin.gd")
const PORTAL_SCRIPT := preload("res://scripts/NextLevelPortal.gd")
const CHEST_SCRIPT := preload("res://scripts/RewardChest.gd")
const LEVEL_LOADER_SCRIPT := preload("res://scripts/LevelLoader.gd")
const CHECKPOINT_SCRIPT := preload("res://scripts/Checkpoint.gd")

const MAX_SAFE_PLATFORM_RISE := 92.0
const MIN_INTERESTING_PLATFORM_GAP := 110.0
const MAX_SAFE_PLATFORM_GAP := 220.0

var player: CharacterBody2D
var portal: Area2D
var hud: CanvasLayer
var level_data: LevelData
var elapsed := 0.0
var victory := false
var game_over := false
var player_lives := 3
var player_energy := 100.0
var player_score := 0
var player_feathers := 0
var current_checkpoint_id := "start"
var pending_loaded_save: Dictionary = {}

@onready var world: Node2D = $World

func _ready() -> void:
	# 输入映射在运行时创建，项目文件保持简单，拷贝后也能直接运行。
	_ensure_input_actions()
	level_data = LEVEL_LOADER_SCRIPT.load_level(LEVEL_LOADER_SCRIPT.get_first_level_id())
	if level_data == null:
		push_error("Main: failed to load first level data.")
		return
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		var loaded_save: Variant = save_manager.call("consume_pending_continue")
		if typeof(loaded_save) == TYPE_DICTIONARY:
			pending_loaded_save = loaded_save

	hud = $HUD
	_play_bgm("level_01")
	_build_parallax_background()
	_build_background_silhouettes()
	_validate_level_layout()
	_build_level()
	_spawn_player()
	_spawn_checkpoints()
	_spawn_collectibles()
	_spawn_coins()
	_spawn_portal()
	_spawn_decorations()
	_apply_loaded_save_if_any()
	_refresh_hud()


func _process(delta: float) -> void:
	if not victory and not game_over:
		elapsed += delta
		_refresh_hud()


func _ensure_input_actions() -> void:
	_add_key("move_left", KEY_A)
	_add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_D)
	_add_key("move_right", KEY_RIGHT)
	_add_key("jump", KEY_SPACE)
	_add_key("jump", KEY_W)
	_add_key("jump", KEY_UP)
	_add_key("glide", KEY_SPACE)
	_add_key("dash", KEY_SHIFT)
	_add_key("dash", KEY_J)
	_add_key("crouch", KEY_S)
	_add_key("crouch", KEY_DOWN)


func _add_key(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return

	var key := InputEventKey.new()
	key.physical_keycode = keycode
	InputMap.action_add_event(action, key)


func _build_parallax_background() -> void:
	# 三层 Parallax 背景：蓝天白云、远景高塔、云海。横向移动时会产生纵深感。
	var parallax := ParallaxBackground.new()
	parallax.name = "ParallaxCloudSea"
	parallax.layer = -10
	add_child(parallax)
	move_child(parallax, 0)

	var sky_layer := _create_parallax_layer(parallax, "SkyLayer", Vector2(0.0, 0.0))
	if ResourceLoader.exists("res://assets/backgrounds/bg_blue_sky_clouds.png"):
		var sky_texture: Texture2D = load("res://assets/backgrounds/bg_blue_sky_clouds.png") as Texture2D
		var sky_sprite := Sprite2D.new()
		sky_sprite.name = "BlueSkyClouds"
		sky_sprite.texture = sky_texture
		sky_sprite.centered = false
		sky_sprite.position = Vector2.ZERO
		sky_layer.add_child(sky_sprite)
	else:
		var sky := ColorRect.new()
		sky.name = "BlueSkyFallback"
		sky.position = Vector2(-260, -40)
		sky.size = Vector2(level_data.viewport_size.x + 520, level_data.viewport_size.y + 160)
		sky.color = Color(0.24, 0.62, 0.96)
		sky_layer.add_child(sky)

	for i in range(32):
		_add_parallax_star(sky_layer, Vector2(12 + (i * 73) % 720, 88 + (i * 47) % 310), 1.2 + float(i % 3))

	var cloud_layer := _create_parallax_layer(parallax, "CloudSeaLayer", Vector2(0.34, 0.07))
	_add_parallax_sprite(cloud_layer, "res://assets/backgrounds/bg_cloud_small_00.png", Vector2(-60, 190), Vector2(0.52, 0.52))
	_add_parallax_sprite(cloud_layer, "res://assets/backgrounds/bg_cloud_small_01.png", Vector2(210, 260), Vector2(0.58, 0.58))
	_add_parallax_sprite(cloud_layer, "res://assets/backgrounds/bg_cloud_small_02.png", Vector2(460, 178), Vector2(0.42, 0.42))
	_add_parallax_sprite(cloud_layer, "res://assets/backgrounds/bg_cloud_small_03.png", Vector2(700, 300), Vector2(0.62, 0.62))
	_add_parallax_sprite(cloud_layer, "res://assets/backgrounds/bg_cloud_small_04.png", Vector2(80, 630), Vector2(0.48, 0.48))
	_add_parallax_sprite(cloud_layer, "res://assets/backgrounds/bg_cloud_small_05.png", Vector2(360, 690), Vector2(0.56, 0.56))
	_add_parallax_sprite(cloud_layer, "res://assets/backgrounds/bg_cloud_small_06.png", Vector2(610, 610), Vector2(0.50, 0.50))


func _create_parallax_layer(parent: ParallaxBackground, layer_name: String, motion: Vector2) -> ParallaxLayer:
	var layer := ParallaxLayer.new()
	layer.name = layer_name
	layer.motion_scale = motion
	layer.motion_mirroring = Vector2(960, 0)
	parent.add_child(layer)
	return layer


func _add_parallax_sprite(parent: Node, path: String, pos: Vector2, sprite_scale: Vector2) -> void:
	if not ResourceLoader.exists(path):
		return
	var texture: Texture2D = load(path) as Texture2D
	if not texture:
		return

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = sprite_scale
	parent.add_child(sprite)


func _build_background_silhouettes() -> void:
	# 背景只使用贴图化资源；比例大的建筑改成远处小浮空装饰。
	_add_generated_sprite("res://assets/backgrounds/bg_tiny_sky_decor_01.png", Vector2(760, 430), Vector2(0.26, 0.26), -68)
	_add_generated_sprite("res://assets/backgrounds/bg_tiny_sky_decor_03.png", Vector2(1380, 360), Vector2(0.20, 0.20), -68)
	_add_generated_sprite("res://assets/backgrounds/bg_tiny_sky_decor_02.png", Vector2(2380, 340), Vector2(0.18, 0.18), -68)
	_add_generated_sprite("res://assets/backgrounds/bg_tiny_sky_decor_00.png", Vector2(3100, 430), Vector2(0.18, 0.18), -68)
	_add_generated_sprite("res://assets/backgrounds/bg_cloud_clump_00.png", Vector2(620, 710), Vector2(0.46, 0.46), -69)
	_add_generated_sprite("res://assets/backgrounds/bg_cloud_clump_00.png", Vector2(1740, 735), Vector2(0.42, 0.42), -69)
	_add_generated_sprite("res://assets/backgrounds/bg_cloud_clump_00.png", Vector2(2860, 730), Vector2(0.42, 0.42), -69)
	_add_generated_sprite("res://assets/backgrounds/bg_cloud_small_02.png", Vector2(300, 320), Vector2(0.42, 0.42), -67)
	_add_generated_sprite("res://assets/backgrounds/bg_cloud_small_05.png", Vector2(1180, 260), Vector2(0.38, 0.38), -67)
	_add_generated_sprite("res://assets/backgrounds/bg_cloud_small_06.png", Vector2(2050, 340), Vector2(0.34, 0.34), -67)
	_add_generated_sprite("res://assets/backgrounds/bg_cloud_small_01.png", Vector2(3300, 300), Vector2(0.34, 0.34), -67)
	_add_generated_sprite("res://assets/effects/fx_sparkle_cluster_00.png", Vector2(1280, 390), Vector2(0.58, 0.58), -62)
	_add_generated_sprite("res://assets/effects/fx_sparkle_cluster_00.png", Vector2(2600, 420), Vector2(0.50, 0.50), -62)


func _build_level() -> void:
	# 完整横版结构：左侧起点 -> 中间浮空平台 -> 中央风环地标 -> 右侧高塔终点传送门。
	for data in level_data.platform_layout:
		_create_platform(data["center"], data["size"], data["name"])


func _spawn_player() -> void:
	player = CharacterBody2D.new()
	player.name = "Player"
	player.z_index = 20
	player.set_script(PLAYER_SCRIPT)
	player.global_position = level_data.player_start

	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	player.add_child(collision)

	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(level_data.level_width)
	camera.limit_bottom = int(level_data.world_bottom)
	player.add_child(camera)
	world.add_child(player)

	player.connect("stats_changed", Callable(self, "_on_player_stats_changed"))
	player.connect("inventory_changed", Callable(self, "_on_player_inventory_changed"))
	player.connect("defeated", Callable(self, "_on_player_defeated"))


func _spawn_checkpoints() -> void:
	var checkpoints: Array[Dictionary] = [
		{"id": "start", "position": level_data.player_start},
		{"id": "mid_wind_ring", "position": Vector2(2050, 720)},
		{"id": "before_tower", "position": Vector2(2960, 560)}
	]

	for data in checkpoints:
		var checkpoint := Area2D.new()
		checkpoint.name = "Checkpoint_" + str(data["id"])
		checkpoint.set_script(CHECKPOINT_SCRIPT)
		checkpoint.global_position = data["position"]
		checkpoint.set("checkpoint_id", str(data["id"]))
		world.add_child(checkpoint)
		checkpoint.connect("checkpoint_activated", Callable(self, "_on_checkpoint_activated"))


func _spawn_collectibles() -> void:
	# 前 5 根羽毛位于终点传送门之前，玩家到达右侧高塔时可以通关。
	for pos in level_data.feather_positions:
		var feather := Area2D.new()
		feather.name = "Feather"
		feather.set_script(COLLECTIBLE_SCRIPT)
		feather.global_position = pos
		world.add_child(feather)


func _spawn_coins() -> void:
	for pos in level_data.coin_positions:
		var coin := Area2D.new()
		coin.name = "Coin"
		coin.set_script(COIN_SCRIPT)
		coin.global_position = pos
		world.add_child(coin)


func _spawn_portal() -> void:
	portal = Area2D.new()
	portal.name = "NextLevelPortal"
	portal.z_index = 9
	portal.set_script(PORTAL_SCRIPT)
	portal.global_position = level_data.portal_position
	portal.set("required_feathers", level_data.required_feathers)
	world.add_child(portal)
	portal.connect("victory_requested", Callable(self, "_on_victory_requested"))
	portal.connect("locked_attempt", Callable(self, "_on_portal_locked"))


func _spawn_decorations() -> void:
	_add_decorative_wind_ring(level_data.central_wind_ring_position)
	_add_wind_banner(Vector2(2075, 760))
	_add_finish_tower(Vector2(3420, 710))
	_add_npc(Vector2(3272, 732), "bird")
	_add_npc(Vector2(3500, 732), "rabbit")
	_add_npc(Vector2(3388, 736), "hood")
	_spawn_reward_chest(Vector2(3610, 760))
	_add_generated_sprite("res://assets/environment/prop_blue_lantern_00.png", Vector2(122, 702), Vector2(0.46, 0.46), 7)
	_add_generated_sprite("res://assets/environment/prop_blue_lantern_00.png", Vector2(2085, 742), Vector2(0.42, 0.42), 7)
	_spawn_platform_props()


func _spawn_reward_chest(pos: Vector2) -> void:
	var chest := Area2D.new()
	chest.name = "RewardChest"
	chest.z_index = 12
	chest.set_script(CHEST_SCRIPT)
	chest.global_position = pos
	world.add_child(chest)
	chest.connect("reward_claimed", Callable(self, "_on_chest_reward_claimed"))


func _spawn_platform_props() -> void:
	# Small reusable props keep platforms from repeating one visual silhouette.
	var grass_points := [
		Vector2(515, 686), Vector2(880, 616), Vector2(1260, 548),
		Vector2(1592, 606), Vector2(1910, 538), Vector2(2268, 588),
		Vector2(2605, 646), Vector2(2968, 574), Vector2(3318, 676)
	]
	for i in range(grass_points.size()):
		var path := "res://assets/environment/prop_grass_tuft_%02d.png" % (i % 2)
		_add_generated_sprite(path, grass_points[i], Vector2(0.72, 0.72), 8)

	var crystal_points := [
		Vector2(610, 685), Vector2(1340, 548), Vector2(1998, 538),
		Vector2(2670, 646), Vector2(3376, 676)
	]
	for i in range(crystal_points.size()):
		var path := "res://assets/environment/prop_crystal_post_%02d.png" % (i % 2)
		_add_generated_sprite(path, crystal_points[i], Vector2(0.42, 0.42), 7)

	var flower_points := [
		Vector2(310, 774), Vector2(1160, 774), Vector2(2150, 774),
		Vector2(2878, 568), Vector2(3480, 674)
	]
	for i in range(flower_points.size()):
		var path := "res://assets/environment/prop_flower_cluster_%02d.png" % (i % 2)
		_add_generated_sprite(path, flower_points[i], Vector2(0.34, 0.34), 8)

	var rock_points := [
		Vector2(430, 776), Vector2(1710, 776), Vector2(2475, 776),
		Vector2(3198, 674)
	]
	for i in range(rock_points.size()):
		var path := "res://assets/environment/prop_rock_cluster_%02d.png" % (i % 2)
		_add_generated_sprite(path, rock_points[i], Vector2(0.30, 0.30), 7)

	_add_generated_sprite("res://assets/environment/prop_chain_arch_00.png", Vector2(3536, 688), Vector2(0.28, 0.28), 6)
	_add_generated_sprite("res://assets/environment/prop_cloud_bird_00.png", Vector2(3680, 505), Vector2(0.30, 0.30), -60)


func _create_platform(center: Vector2, size: Vector2, kind: String) -> void:
	var body := StaticBody2D.new()
	body.name = "Platform_" + kind
	body.position = center
	world.add_child(body)

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)

	if _add_platform_art(body, size, kind):
		return

	# Fallback only: if a texture is missing, draw a simple debug platform so the level remains playable.
	var top := _rect_polygon(Vector2.ZERO, size, Color(0.45, 0.49, 0.55))
	body.add_child(top)
	var face := _rect_polygon(Vector2(0, size.y * 0.18), Vector2(size.x, size.y * 0.64), Color(0.20, 0.24, 0.29))
	body.add_child(face)
	var trim := _rect_polygon(Vector2(0, -size.y * 0.36), Vector2(size.x, 6), Color(0.78, 0.82, 0.86))
	body.add_child(trim)
	var tiles := int(size.x / 48.0)
	for i in range(tiles):
		var x := -size.x * 0.5 + i * 48.0
		var line := Line2D.new()
		line.width = 2.0
		line.default_color = Color(0.10, 0.12, 0.16, 0.7)
		line.points = PackedVector2Array([Vector2(x, -size.y * 0.45), Vector2(x, size.y * 0.42)])
		body.add_child(line)


func _add_platform_art(body: StaticBody2D, size: Vector2, kind: String) -> bool:
	var path := _select_platform_art_path(kind)

	if path == "" or not ResourceLoader.exists(path):
		return false

	var texture: Texture2D = load(path) as Texture2D
	if not texture:
		return false

	var sprite := Sprite2D.new()
	sprite.name = "GeneratedPlatformArt"
	sprite.texture = texture
	sprite.z_index = 4
	var target_width := size.x + _platform_art_extra_width(kind)
	var scale_value := target_width / float(texture.get_width())
	sprite.scale = Vector2(scale_value, scale_value)
	sprite.position = Vector2(0, _aligned_platform_art_y(path, texture, size, scale_value))
	body.add_child(sprite)
	return true


func _select_platform_art_path(kind: String) -> String:
	if kind == "tower_finish":
		return "res://assets/environment/platform_unified_tower_cap_00.png"
	if kind == "tower_ground":
		return "res://assets/environment/platform_unified_long_01.png"
	if kind == "approach_ground":
		return "res://assets/environment/platform_unified_long_00.png"
	if kind == "portal_ground":
		return "res://assets/environment/platform_unified_long_01.png"
	if kind == "start_ground":
		return "res://assets/environment/platform_unified_long_00.png"
	if kind == "floating_a":
		return "res://assets/environment/platform_unified_small_01.png"
	if kind == "floating_b":
		return "res://assets/environment/platform_unified_small_02.png"
	if kind == "floating_c":
		return "res://assets/environment/platform_unified_small_01.png"
	if kind.contains("portal") or kind.contains("step"):
		return "res://assets/environment/platform_unified_small_02.png"
	if kind.contains("floating"):
		return "res://assets/environment/platform_unified_small_00.png"
	return "res://assets/environment/platform_unified_long_00.png"


func _platform_art_extra_width(kind: String) -> float:
	if kind == "tower_finish":
		return 8.0
	if kind.contains("ground"):
		return 12.0
	return 18.0


func _aligned_platform_art_y(path: String, texture: Texture2D, size: Vector2, scale_value: float) -> float:
	var bbox_top := _platform_visual_surface_y(path)
	if path.contains("platform_tower_cap"):
		bbox_top = 32.0
	elif path.contains("platform_floating_small"):
		bbox_top = 74.0
	elif path.contains("platform_floating_long"):
		bbox_top = 111.0

	var visible_top_from_center := (bbox_top - float(texture.get_height()) * 0.5) * scale_value
	return -size.y * 0.5 - visible_top_from_center


func _platform_visual_surface_y(path: String) -> float:
	var file_name := path.get_file()
	if file_name == "platform_unified_small_00.png":
		return 32.0
	if file_name == "platform_unified_small_01.png":
		return 21.0
	if file_name == "platform_unified_small_02.png":
		return 22.0
	if file_name == "platform_unified_long_00.png":
		return 15.0
	if file_name == "platform_unified_long_01.png":
		return 14.0
	if file_name == "platform_unified_long_02.png":
		return 21.0
	if file_name == "platform_unified_tower_cap_00.png":
		return 44.0
	if file_name == "platform_unified_badge_00.png":
		return 39.0
	return 0.0


func _validate_level_layout() -> void:
	# 检查主路线相邻平台的高度和边缘距离，提前发现“跳不上去”的关卡数据。
	var by_name := {}
	for data in level_data.platform_layout:
		by_name[data["name"]] = data

	var previous_name := ""
	for platform_name in level_data.route_platform_names:
		if not by_name.has(platform_name):
			push_warning("Missing route platform: %s" % platform_name)
			continue

		if previous_name != "":
			var previous_top := _platform_top_y(by_name[previous_name])
			var current_top := _platform_top_y(by_name[platform_name])
			var rise := previous_top - current_top
			if rise > MAX_SAFE_PLATFORM_RISE:
				push_warning("Platform rise from %s to %s is %.1fpx, above safe %.1fpx" % [previous_name, platform_name, rise, MAX_SAFE_PLATFORM_RISE])

			var horizontal_gap := _platform_left_x(by_name[platform_name]) - _platform_right_x(by_name[previous_name])
			if horizontal_gap > MAX_SAFE_PLATFORM_GAP:
				push_warning("Platform gap from %s to %s is %.1fpx, above safe %.1fpx" % [previous_name, platform_name, horizontal_gap, MAX_SAFE_PLATFORM_GAP])
			elif horizontal_gap >= 0.0 and previous_name != "start_ground" and horizontal_gap < MIN_INTERESTING_PLATFORM_GAP:
				push_warning("Platform gap from %s to %s is %.1fpx, below intended rhythm %.1fpx" % [previous_name, platform_name, horizontal_gap, MIN_INTERESTING_PLATFORM_GAP])

		previous_name = platform_name


func _platform_top_y(data: Dictionary) -> float:
	return data["center"].y - data["size"].y * 0.5


func _platform_left_x(data: Dictionary) -> float:
	return data["center"].x - data["size"].x * 0.5


func _platform_right_x(data: Dictionary) -> float:
	return data["center"].x + data["size"].x * 0.5


func _rect_polygon(center: Vector2, size: Vector2, color: Color) -> Polygon2D:
	var poly := Polygon2D.new()
	var half := size * 0.5
	poly.position = center
	poly.color = color
	poly.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y)
	])
	return poly


func _add_parallax_star(parent: Node, pos: Vector2, size: float) -> void:
	var paths: Array[String] = [
		"res://assets/effects/fx_sky_star_00.png",
		"res://assets/effects/fx_sky_star_01.png",
		"res://assets/effects/fx_sky_star_02.png",
		"res://assets/effects/fx_sky_star_03.png"
	]
	var path: String = paths[int(pos.x + pos.y) % paths.size()]
	var texture := _load_texture(path)
	if texture:
		var star := Sprite2D.new()
		star.name = "SkyStar"
		star.texture = texture
		star.position = pos
		star.scale = Vector2.ONE * max(0.55, size * 0.18)
		star.modulate.a = 0.78
		parent.add_child(star)
		return

	var fallback := _rect_polygon(pos, Vector2(size, size), Color(0.96, 0.98, 1.0, 0.72))
	parent.add_child(fallback)


func _add_decorative_wind_ring(pos: Vector2) -> void:
	if _add_generated_sprite("res://assets/environment/marker_wind_ring_00.png", pos, Vector2(0.92, 0.92), 4):
		return

	var ring := Node2D.new()
	ring.name = "CentralWindRingMarker"
	ring.position = pos
	world.add_child(ring)

	for radius in [72.0, 58.0, 44.0]:
		var arc := Line2D.new()
		arc.width = 5.0 if radius > 50.0 else 3.0
		arc.default_color = Color(0.86, 0.95, 1.0, 0.60)
		var points := PackedVector2Array()
		for step in range(50):
			var angle := TAU * float(step) / 49.0
			points.append(Vector2(cos(angle), sin(angle)) * radius)
		arc.points = points
		arc.closed = true
		ring.add_child(arc)

	var core := _rect_polygon(Vector2.ZERO, Vector2(34, 34), Color(0.96, 0.98, 1.0, 0.88))
	core.rotation = PI * 0.25
	ring.add_child(core)


func _add_finish_tower(base: Vector2) -> void:
	if _add_generated_sprite("res://assets/environment/tower_finish_generated.png", base + Vector2(0, -250), Vector2(0.92, 0.92), 3):
		return

	var tower := Node2D.new()
	tower.name = "RightFinishTower"
	tower.position = base
	world.add_child(tower)

	tower.add_child(_rect_polygon(Vector2(0, -64), Vector2(82, 128), Color(0.45, 0.49, 0.55)))
	tower.add_child(_rect_polygon(Vector2(0, -145), Vector2(60, 76), Color(0.54, 0.58, 0.64)))
	tower.add_child(_rect_polygon(Vector2(0, -198), Vector2(42, 44), Color(0.66, 0.69, 0.74)))
	tower.add_child(_rect_polygon(Vector2(0, -236), Vector2(18, 32), Color(0.88, 0.90, 0.92)))

	for y in [-105, -65, -25]:
		tower.add_child(_rect_polygon(Vector2(-22, y), Vector2(11, 19), Color(0.15, 0.20, 0.27)))
		tower.add_child(_rect_polygon(Vector2(22, y), Vector2(11, 19), Color(0.15, 0.20, 0.27)))

	var flag := Polygon2D.new()
	flag.position = Vector2(24, -244)
	flag.color = Color(0.03, 0.04, 0.06)
	flag.polygon = PackedVector2Array([Vector2(0, 0), Vector2(64, 16), Vector2(0, 34)])
	tower.add_child(flag)


func _add_wind_banner(pos: Vector2) -> void:
	if _add_generated_sprite("res://assets/environment/prop_wind_banner_pole_00.png", pos + Vector2(36, -48), Vector2(0.56, 0.56), 5):
		return

	var banner := Node2D.new()
	banner.name = "CentralWindBanner"
	banner.position = pos
	world.add_child(banner)

	var pole := Line2D.new()
	pole.width = 4.0
	pole.default_color = Color(0.86, 0.76, 0.52)
	pole.points = PackedVector2Array([Vector2(0, 0), Vector2(0, -84)])
	banner.add_child(pole)

	var cloth := Polygon2D.new()
	cloth.position = Vector2(0, -78)
	cloth.color = Color(0.025, 0.03, 0.045)
	cloth.polygon = PackedVector2Array([Vector2(0, 0), Vector2(74, 10), Vector2(58, 38), Vector2(0, 30)])
	banner.add_child(cloth)


func _add_npc(pos: Vector2, variant: String) -> void:
	var npc := Node2D.new()
	npc.name = "NPC_" + variant
	npc.position = pos
	world.add_child(npc)
	if _add_animated_sprite(npc, _npc_frame_paths(variant), Vector2(0, -24), Vector2(0.43, 0.43), 11, 3.6):
		return

	var body_color := Color(0.90, 0.92, 0.95)
	if variant == "rabbit":
		body_color = Color(0.92, 0.84, 0.70)
	elif variant == "hood":
		body_color = Color(0.30, 0.34, 0.42)

	npc.add_child(_rect_polygon(Vector2(0, 12), Vector2(26, 28), body_color))
	var head := _rect_polygon(Vector2(0, -11), Vector2(30, 24), Color(0.96, 0.97, 0.98))
	npc.add_child(head)
	npc.add_child(_rect_polygon(Vector2(-7, -12), Vector2(3, 3), Color.BLACK))
	npc.add_child(_rect_polygon(Vector2(7, -12), Vector2(3, 3), Color.BLACK))

	var arm_l := Line2D.new()
	arm_l.width = 4.0
	arm_l.default_color = body_color
	arm_l.points = PackedVector2Array([Vector2(-13, 7), Vector2(-27, -7)])
	npc.add_child(arm_l)

	var arm_r := Line2D.new()
	arm_r.width = 4.0
	arm_r.default_color = body_color
	arm_r.points = PackedVector2Array([Vector2(13, 7), Vector2(27, -7)])
	npc.add_child(arm_r)


func _npc_frame_paths(variant: String) -> Array[String]:
	if variant == "rabbit":
		return [
			"res://assets/npcs/npc_rabbit_cheer_00.png",
			"res://assets/npcs/npc_rabbit_cheer_01.png"
		]
	if variant == "hood":
		return [
			"res://assets/npcs/npc_hood_cheer_00.png",
			"res://assets/npcs/npc_hood_cheer_01.png",
			"res://assets/npcs/npc_hood_cheer_02.png"
		]
	return [
		"res://assets/npcs/npc_bird_cheer_00.png",
		"res://assets/npcs/npc_bird_cheer_01.png",
		"res://assets/npcs/npc_bird_cheer_02.png"
	]


func _add_open_chest(pos: Vector2) -> void:
	if _add_generated_sprite("res://assets/collectibles/chest_reward_open_00.png", pos + Vector2(0, -12), Vector2(0.70, 0.70), 8):
		return

	var chest := Node2D.new()
	chest.position = pos
	world.add_child(chest)
	chest.add_child(_rect_polygon(Vector2(0, 9), Vector2(70, 28), Color(0.23, 0.14, 0.07)))
	chest.add_child(_rect_polygon(Vector2(0, -12), Vector2(68, 14), Color(0.38, 0.23, 0.10)))
	chest.add_child(_rect_polygon(Vector2(0, 6), Vector2(54, 10), Color(1.0, 0.75, 0.22)))
	chest.add_child(_rect_polygon(Vector2(0, 6), Vector2(12, 20), Color(0.95, 0.87, 0.62)))


func _add_generated_sprite(path: String, pos: Vector2, sprite_scale: Vector2, z: int) -> bool:
	if not ResourceLoader.exists(path):
		return false
	var texture: Texture2D = load(path) as Texture2D
	if not texture:
		return false

	var sprite := Sprite2D.new()
	sprite.name = path.get_file().get_basename()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = sprite_scale
	sprite.z_index = z
	world.add_child(sprite)
	return true


func _add_animated_sprite(parent: Node, paths: Array[String], pos: Vector2, sprite_scale: Vector2, z: int, fps: float) -> bool:
	var frames := SpriteFrames.new()
	var animation_name := "idle"
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, true)
	frames.set_animation_speed(animation_name, fps)

	var added := 0
	for path in paths:
		var texture := _load_texture(path)
		if texture:
			frames.add_frame(animation_name, texture)
			added += 1

	if added == 0:
		return false

	var sprite := AnimatedSprite2D.new()
	sprite.name = "GeneratedAnimatedSprite"
	sprite.sprite_frames = frames
	sprite.animation = animation_name
	sprite.position = pos
	sprite.scale = sprite_scale
	sprite.z_index = z
	parent.add_child(sprite)
	sprite.play(animation_name)
	return true


func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func _on_player_stats_changed(lives: int, wing_energy: float) -> void:
	player_lives = lives
	player_energy = wing_energy


func _on_player_inventory_changed(score: int, feathers: int) -> void:
	player_score = score
	player_feathers = feathers
	if portal:
		portal.call("update_feathers", feathers)
	_refresh_hud()


func _on_checkpoint_activated(checkpoint_id: String, spawn_position: Vector2) -> void:
	current_checkpoint_id = checkpoint_id
	if hud:
		hud.call("show_hint", "风之印记已记录")

	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and level_data != null and player != null:
		var save_data_variant: Variant = save_manager.call("build_save_data", level_data.level_id, current_checkpoint_id, player, elapsed, {
			"player_position_x": spawn_position.x,
			"player_position_y": spawn_position.y
		})
		if typeof(save_data_variant) == TYPE_DICTIONARY:
			save_manager.call("save_game", save_data_variant)


func _apply_loaded_save_if_any() -> void:
	if pending_loaded_save.is_empty():
		return
	if player == null or level_data == null:
		return

	current_checkpoint_id = str(pending_loaded_save.get("checkpoint_id", "start"))

	var x := float(pending_loaded_save.get("player_position_x", level_data.player_start.x))
	var y := float(pending_loaded_save.get("player_position_y", level_data.player_start.y))
	var restored_position := Vector2(x, y)
	player.global_position = restored_position
	player.call("set_spawn_position", restored_position)

	player.set("score", int(pending_loaded_save.get("score", 0)))
	player.set("feathers", int(pending_loaded_save.get("feathers", 0)))
	player.set("lives", int(pending_loaded_save.get("lives", 3)))
	player.set("wing_energy", float(pending_loaded_save.get("wing_energy", 100.0)))
	elapsed = float(pending_loaded_save.get("elapsed", 0.0))

	player_score = int(player.get("score"))
	player_feathers = int(player.get("feathers"))
	player_lives = int(player.get("lives"))
	player_energy = float(player.get("wing_energy"))

	if portal:
		portal.call("update_feathers", player_feathers)

	_refresh_hud()


func _on_portal_locked(required: int, current: int) -> void:
	hud.call("show_hint", "还需要 %d 根羽毛，回去继续收集" % max(0, required - current))


func _on_victory_requested() -> void:
	if victory:
		return

	victory = true
	player.call("celebrate")
	_create_victory_sound_placeholder()
	hud.call("show_victory", elapsed, player_score, player_feathers)
	_spawn_victory_burst()


func _create_victory_sound_placeholder() -> void:
	# 真实音效接入时，把 AudioStream 赋给这个占位播放器即可。
	var audio := AudioStreamPlayer.new()
	audio.name = "VictorySoundPlaceholder"
	add_child(audio)


func _spawn_victory_burst() -> void:
	# 彩带和星光粒子从右侧终点传送门爆开。
	var confetti_paths: Array[String] = [
		"res://assets/effects/fx_confetti_00.png",
		"res://assets/effects/fx_confetti_01.png",
		"res://assets/effects/fx_confetti_02.png",
		"res://assets/effects/fx_confetti_03.png",
		"res://assets/effects/fx_confetti_04.png",
		"res://assets/effects/fx_confetti_05.png"
	]
	var sparkle_paths: Array[String] = [
		"res://assets/effects/fx_star_sparkle_00.png",
		"res://assets/effects/fx_star_sparkle_01.png",
		"res://assets/effects/fx_star_sparkle_02.png",
		"res://assets/effects/fx_star_sparkle_03.png"
	]
	var fallback_colors := [
		Color(1.0, 0.86, 0.22), Color(0.42, 0.76, 1.0),
		Color(1.0, 1.0, 1.0), Color(0.95, 0.45, 0.70)
	]
	for i in range(72):
		var bit := _make_particle_sprite(confetti_paths[i % confetti_paths.size()], sparkle_paths[i % sparkle_paths.size()], fallback_colors[i % fallback_colors.size()], i)
		bit.global_position = portal.global_position + Vector2(randf_range(-30, 30), randf_range(-40, 20))
		bit.rotation = randf() * TAU
		bit.z_index = 30
		world.add_child(bit)

		var target := bit.position + Vector2(randf_range(-230, 230), randf_range(-220, -40))
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(bit, "position", target, randf_range(0.75, 1.35)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(bit, "rotation", bit.rotation + randf_range(2.0, 6.0), 1.1)
		tween.tween_property(bit, "modulate:a", 0.0, 1.35)
		tween.chain().tween_callback(Callable(bit, "queue_free"))

	hud.call("show_hint", "胜利音效占位：叮！风环已启动")


func _make_particle_sprite(confetti_path: String, sparkle_path: String, fallback_color: Color, index: int) -> Node2D:
	var path := confetti_path if index % 3 != 0 else sparkle_path
	var texture := _load_texture(path)
	if texture:
		var sprite := Sprite2D.new()
		sprite.name = "VictoryParticle"
		sprite.texture = texture
		sprite.scale = Vector2(1.45, 1.45)
		return sprite

	return _rect_polygon(Vector2.ZERO, Vector2(8, 8), fallback_color)


func _on_player_defeated(score: int, feathers: int) -> void:
	if game_over or victory:
		return

	game_over = true
	hud.call("show_failure", elapsed, score, feathers)


func _on_chest_reward_claimed(score_value: int, energy_value: float) -> void:
	hud.call("show_hint", "奖励宝箱：+%d 分，羽翼能量 +%d%%" % [score_value, int(energy_value)])


func _refresh_hud() -> void:
	if hud:
		hud.call("update_stats", player_lives, player_energy, player_score, player_feathers, level_data.required_feathers, level_data.level_name, elapsed)


func _play_bgm(track_name: String) -> void:
	var audio_manager := get_node_or_null("/root/AudioManager")
	if audio_manager != null:
		audio_manager.call("play_bgm", track_name)
