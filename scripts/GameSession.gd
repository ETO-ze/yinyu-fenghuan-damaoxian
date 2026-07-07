extends Node

const FIRST_LEVEL_ID := "level_01"
const MAIN_SCENE_PATH := "res://scenes/Main.tscn"

var current_level_id: String = FIRST_LEVEL_ID
var last_completed_level_id: String = ""
var session_started := false


func start_new_game() -> void:
	current_level_id = FIRST_LEVEL_ID
	last_completed_level_id = ""
	session_started = true

	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.call("start_new_game")


func start_level(level_id: String) -> bool:
	if not LevelLoader.has_level(level_id):
		push_error("GameSession: unknown level_id: %s" % level_id)
		return false

	current_level_id = level_id
	session_started = true
	return true


func get_current_level_id() -> String:
	if current_level_id == "":
		current_level_id = FIRST_LEVEL_ID
	return current_level_id


func set_from_save_data(save_data: Dictionary) -> bool:
	var level_id := str(save_data.get("level_id", FIRST_LEVEL_ID))
	if not LevelLoader.has_level(level_id):
		push_warning("GameSession: save references unknown level_id: %s, fallback to %s" % [level_id, FIRST_LEVEL_ID])
		current_level_id = FIRST_LEVEL_ID
		session_started = true
		return false

	current_level_id = level_id
	session_started = true
	return true


func mark_level_completed(level_id: String) -> void:
	last_completed_level_id = level_id


func request_next_level(current_level_data: LevelData) -> bool:
	if current_level_data == null:
		return false

	var next_id := str(current_level_data.next_level_id)
	if next_id == "":
		return false

	return start_level(next_id)


func reload_main_scene(tree: SceneTree) -> Error:
	return tree.change_scene_to_file(MAIN_SCENE_PATH)


func reset_session() -> void:
	current_level_id = FIRST_LEVEL_ID
	last_completed_level_id = ""
	session_started = false
