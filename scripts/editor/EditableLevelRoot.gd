@tool
class_name EditableLevelRoot
extends Node2D

@export var level_id := "level_01"
@export var level_name := "风之高塔 · 完整横版关卡"
@export var required_feathers := 5
@export var viewport_size := Vector2(480, 854)
@export var level_width := 3800.0
@export var world_bottom := 960.0


func to_level_data() -> LevelData:
	var data := LevelData.new()
	data.level_id = level_id
	data.level_name = level_name
	data.required_feathers = required_feathers
	data.viewport_size = viewport_size
	data.level_width = level_width
	data.world_bottom = world_bottom

	var player_marker := _find_point("player_start")
	if player_marker:
		data.player_start = player_marker.global_position

	var wind_ring_marker := _find_point("wind_ring")
	if wind_ring_marker:
		data.central_wind_ring_position = wind_ring_marker.global_position

	var portal_marker := _find_point("portal")
	if portal_marker:
		data.portal_position = portal_marker.global_position

	data.platform_layout = _read_platforms()
	data.route_platform_names = _read_route_platform_names()
	data.feather_positions = _read_points("feather")
	data.coin_positions = _read_points("coin")
	data.checkpoint_layout = _read_checkpoints()
	return data


func _read_platforms() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var platforms := get_node_or_null("Platforms")
	if platforms == null:
		return result

	for child in platforms.get_children():
		if child is EditablePlatform:
			var platform := child as EditablePlatform
			result.append({
				"name": platform.platform_name,
				"center": platform.global_position,
				"size": platform.platform_size
			})
	return result


func _read_route_platform_names() -> Array[String]:
	var result: Array[String] = []
	var platforms := get_node_or_null("Platforms")
	if platforms == null:
		return result

	for child in platforms.get_children():
		if child is EditablePlatform:
			var platform := child as EditablePlatform
			if platform.route_platform:
				result.append(platform.platform_name)
	return result


func _read_points(point_type: String) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for point in _get_all_points():
		if point.point_type == point_type:
			result.append(point.global_position)
	return result


func _read_checkpoints() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for point in _get_all_points():
		if point.point_type == "checkpoint":
			result.append({
				"id": point.point_id,
				"position": point.global_position
			})
	return result


func _find_point(point_type: String) -> EditableLevelPoint:
	for point in _get_all_points():
		if point.point_type == point_type:
			return point
	return null


func _get_all_points() -> Array[EditableLevelPoint]:
	var result: Array[EditableLevelPoint] = []
	_collect_points(self, result)
	return result


func _collect_points(node: Node, result: Array[EditableLevelPoint]) -> void:
	for child in node.get_children():
		if child is EditableLevelPoint:
			result.append(child as EditableLevelPoint)
		_collect_points(child, result)
