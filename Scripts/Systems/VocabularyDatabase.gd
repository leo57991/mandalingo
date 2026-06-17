extends Node

signal vocabulary_first_seen(id: StringName)

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
		if not dir.current_is_dir():
			var is_tres = file_name.ends_with(".tres") or file_name.ends_with(".tres.remap")
			if is_tres:
				var clean_name = file_name
				if clean_name.ends_with(".remap"):
					clean_name = clean_name.trim_suffix(".remap")
				var resource := load("%s/%s" % [VOCABULARY_DIR, clean_name])
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

func mark_learned(id: StringName, location: String = "") -> void:
	var entry: Resource = get_entry(id)
	if entry != null:
		var is_first_encounter: bool = entry.seen_count == 0
		entry.learned = true
		entry.seen_count += 1
		if not location.is_empty():
			entry.last_seen = location
		TelemetryManager.track_vocabulary_seen(id, entry.seen_count, entry.last_seen)
		if is_first_encounter:
			vocabulary_first_seen.emit(id)

func mark_seen_from_dialogue(id: StringName, location: String = "") -> void:
	if not String(id).is_empty():
		mark_learned(id, location)

func mark_many_seen_from_dialogue(ids: Array, location: String = "") -> void:
	for id in ids:
		mark_seen_from_dialogue(StringName(id), location)

func discover_words_in_text(_text: String, _location: String = "", _exclude_id: StringName = &"") -> void:
	# Prototype v0.1 intentionally avoids substring discovery.
	# Words are only unlocked when a dialogue line explicitly marks its vocab id.
	pass

func get_audio_path(id: StringName) -> String:
	var entry: Resource = get_entry(id)
	if entry == null:
		return ""
	return entry.audio_file
