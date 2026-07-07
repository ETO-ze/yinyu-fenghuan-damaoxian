extends Node

const SAVE_PATH := "user://save.json"
const CURRENT_VERSION := 1

var pending_continue := false
var pending_save_data: Dictionary = {}


func start_new_game() -> void:
	pending_continue = false
	pending_save_data.clear()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func request_continue() -> bool:
	var data := load_save()
	if data.is_empty():
		pending_continue = false
		pending_save_data.clear()
		return false

	pending_continue = true
	pending_save_data = data.duplicate(true)
	return true


func consume_pending_continue() -> Dictionary:
	if not pending_continue:
		return {}

	var data := pending_save_data.duplicate(true)
	pending_continue = false
	pending_save_data.clear()
	return data


func save_game(data: Dictionary) -> bool:
	var normalized := data.duplicate(true)
	normalized["version"] = CURRENT_VERSION
	normalized["saved_at_unix"] = Time.get_unix_time_from_system()

	var json_text := JSON.stringify(normalized, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: failed to open save file for writing: %s" % SAVE_PATH)
		return false

	file.store_string(json_text)
	file.close()
	return true


func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: failed to open save file for reading: %s" % SAVE_PATH)
		return {}

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_warning("SaveManager: save json parse failed at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		push_warning("SaveManager: save file root is not Dictionary.")
		return {}

	var data: Dictionary = json.data
	if int(data.get("version", 0)) > CURRENT_VERSION:
		push_warning("SaveManager: save version is newer than current game.")
		return {}

	return data


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func build_save_data(level_id: String, checkpoint_id: String, player: Node, elapsed: float, extra: Dictionary = {}) -> Dictionary:
	var data := {
		"version": CURRENT_VERSION,
		"level_id": level_id,
		"checkpoint_id": checkpoint_id,
		"player_position_x": 0.0,
		"player_position_y": 0.0,
		"score": 0,
		"feathers": 0,
		"lives": 3,
		"wing_energy": 100.0,
		"elapsed": elapsed,
		"collected_feathers": [],
		"collected_coins": [],
		"opened_chests": []
	}

	if player != null:
		var pos: Vector2 = player.global_position
		data["player_position_x"] = pos.x
		data["player_position_y"] = pos.y
		data["score"] = int(player.get("score"))
		data["feathers"] = int(player.get("feathers"))
		data["lives"] = int(player.get("lives"))
		data["wing_energy"] = float(player.get("wing_energy"))

	for key in extra.keys():
		data[key] = extra[key]

	return data
