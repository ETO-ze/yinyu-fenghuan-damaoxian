class_name LevelLoader
extends Node

const FIRST_LEVEL_ID := "level_01"

const LEVEL_SCENE_PATHS := {
	"level_01": "res://scenes/levels/Level01Editable.tscn"
}

const LEVEL_SCRIPT_PATHS := {
	"level_01": "res://data/levels/Level01Data.gd",
	"level_02": "res://data/levels/Level02Data.gd"
}


static func get_first_level_id() -> String:
	return FIRST_LEVEL_ID


static func has_level(level_id: String) -> bool:
	return LEVEL_SCENE_PATHS.has(level_id) or LEVEL_SCRIPT_PATHS.has(level_id)


static func load_level(level_id: String = FIRST_LEVEL_ID) -> LevelData:
	if not has_level(level_id):
		push_error("LevelLoader: unknown level_id: %s" % level_id)
		return null

	var scene_data := _load_level_from_scene(level_id)
	if scene_data != null:
		return scene_data

	return _load_level_from_script(level_id)


static func _load_level_from_scene(level_id: String) -> LevelData:
	if not LEVEL_SCENE_PATHS.has(level_id):
		return null

	var path: String = LEVEL_SCENE_PATHS[level_id]
	if not ResourceLoader.exists(path):
		return null

	var packed_scene := load(path) as PackedScene
	if packed_scene == null:
		push_warning("LevelLoader: failed to load editable level scene: %s" % path)
		return null

	var root := packed_scene.instantiate()
	if root == null:
		push_warning("LevelLoader: failed to instantiate editable level scene: %s" % path)
		return null

	var data: LevelData = null
	if root.has_method("to_level_data"):
		var value: Variant = root.call("to_level_data")
		if value is LevelData:
			data = value as LevelData
		else:
			push_warning("LevelLoader: editable scene did not return LevelData: %s" % path)
	else:
		push_warning("LevelLoader: editable scene missing to_level_data(): %s" % path)

	root.free()
	return data


static func _load_level_from_script(level_id: String) -> LevelData:
	if not LEVEL_SCRIPT_PATHS.has(level_id):
		push_error("LevelLoader: missing fallback script for level_id: %s" % level_id)
		return null

	var path: String = LEVEL_SCRIPT_PATHS[level_id]
	if not ResourceLoader.exists(path):
		push_error("LevelLoader: missing level script: %s" % path)
		return null

	var script: Script = load(path)
	if script == null:
		push_error("LevelLoader: failed to load script: %s" % path)
		return null

	var data: Variant = script.new()
	if not (data is LevelData):
		push_error("LevelLoader: script does not create LevelData: %s" % path)
		return null

	return data as LevelData
