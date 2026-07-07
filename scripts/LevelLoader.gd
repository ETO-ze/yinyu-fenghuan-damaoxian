class_name LevelLoader
extends Node

const FIRST_LEVEL_ID := "level_01"

const LEVEL_SCRIPT_PATHS := {
	"level_01": "res://data/levels/Level01Data.gd"
}


static func get_first_level_id() -> String:
	return FIRST_LEVEL_ID


static func has_level(level_id: String) -> bool:
	return LEVEL_SCRIPT_PATHS.has(level_id)


static func load_level(level_id: String = FIRST_LEVEL_ID) -> LevelData:
	if not LEVEL_SCRIPT_PATHS.has(level_id):
		push_error("LevelLoader: unknown level_id: %s" % level_id)
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
