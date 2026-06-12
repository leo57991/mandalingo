extends Node

const VOCABULARY_DIR := "res://Data/Vocabulary"

var entries: Dictionary[StringName, Resource] = {}

func _ready() -> void:
	load_entries()

func load_entries() -> void:
	entries.clear()

	var dir := DirAccess.open(VOCABULARY_DIR)
	if dir == null:
		push_warning("Vocabulary directory is missing: %s" % VOCABULARY_DIR)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := load("%s/%s" % [VOCABULARY_DIR, file_name])
			if resource != null and "id" in resource:
				entries[resource.id] = resource
		file_name = dir.get_next()
	dir.list_dir_end()

func get_entry(id: StringName) -> Resource:
	return entries.get(id)

func get_chinese(id: StringName) -> String:
	var entry: Resource = get_entry(id)
	if entry == null:
		return ""
	return entry.chinese

func mark_learned(id: StringName) -> void:
	var entry: Resource = get_entry(id)
	if entry != null:
		entry.learned = true

func get_audio_path(id: StringName) -> String:
	var entry: Resource = get_entry(id)
	if entry == null:
		return ""
	return entry.audio_file
