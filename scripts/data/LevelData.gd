class_name LevelData
extends Resource

@export var level_id: String = "level_01"
@export var level_name: String = "风之高塔 · 完整横版关卡"
@export var required_feathers: int = 5

@export var viewport_size: Vector2 = Vector2(480, 854)
@export var level_width: float = 3800.0
@export var world_bottom: float = 960.0

@export var player_start: Vector2 = Vector2(120, 730)
@export var central_wind_ring_position: Vector2 = Vector2(2050, 630)
@export var portal_position: Vector2 = Vector2(3420, 620)

@export var platform_layout: Array[Dictionary] = []
@export var feather_positions: Array[Vector2] = []
@export var coin_positions: Array[Vector2] = []
@export var route_platform_names: Array[String] = []


func get_platform_by_name(platform_name: String) -> Dictionary:
	for data in platform_layout:
		if str(data.get("name", "")) == platform_name:
			return data
	return {}


func has_platform(platform_name: String) -> bool:
	return not get_platform_by_name(platform_name).is_empty()


func duplicate_level_data() -> LevelData:
	var copy := LevelData.new()
	copy.level_id = level_id
	copy.level_name = level_name
	copy.required_feathers = required_feathers
	copy.viewport_size = viewport_size
	copy.level_width = level_width
	copy.world_bottom = world_bottom
	copy.player_start = player_start
	copy.central_wind_ring_position = central_wind_ring_position
	copy.portal_position = portal_position
	copy.platform_layout = platform_layout.duplicate(true)
	copy.feather_positions = feather_positions.duplicate(true)
	copy.coin_positions = coin_positions.duplicate(true)
	copy.route_platform_names = route_platform_names.duplicate(true)
	return copy
