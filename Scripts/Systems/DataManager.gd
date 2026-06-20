extends Node

signal player_event_recorded(event: Dictionary)
signal queue_changed(size: int)

const DEFAULT_QUEUE_FILE := "user://player_event_queue.json"
const EVENT_SCHEMA_VERSION := 1

var queue_file_path := DEFAULT_QUEUE_FILE
var session_id := ""
var build_version := ""
var session_started_at_msec := 0
var event_queue: Array[Dictionary] = []

var _random := RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_random.randomize()
	session_started_at_msec = Time.get_ticks_msec()
	session_id = _create_session_id()
	build_version = String(
		ProjectSettings.get_setting("telemetry/build_id", "prototype-v0.1")
	)
	load_queue()

func record_player_event(event_name: String, data: Dictionary = {}) -> Dictionary:
	if event_name.strip_edges().is_empty():
		push_warning("DataManager ignored a player event with an empty event name.")
		return {}

	var event := _build_event(event_name, data)
	event_queue.append(event.duplicate(true))
	_save_queue()
	queue_changed.emit(event_queue.size())
	player_event_recorded.emit(event.duplicate(true))
	_forward_to_telemetry(event)
	return event

func track_vocabulary_seen(
	vocab_id: StringName,
	seen_count: int,
	location: String,
	context: Dictionary = {}
) -> Dictionary:
	return record_player_event("vocabulary_seen", {
		"vocab_id": String(vocab_id),
		"location": location,
		"context": context,
		"details": {"seen_count": seen_count},
	})

func track_interaction(
	target_name: String,
	target_kind: String,
	vocab_ids: Array,
	location: String = "",
	context: Dictionary = {}
) -> Dictionary:
	var ids: Array[String] = []
	_collect_vocab_ids(vocab_ids, ids)
	return record_player_event("interaction", {
		"vocab_id": ids[0] if not ids.is_empty() else "",
		"location": location,
		"context": context,
		"details": {
			"target": target_name,
			"target_kind": target_kind,
			"vocab_ids": ids,
		},
	})

func track_guess_updated(
	vocab_id: StringName,
	player_guess: String,
	context: Dictionary = {}
) -> Dictionary:
	return record_player_event("guess_updated", {
		"vocab_id": String(vocab_id),
		"player_guess": player_guess,
		"context": context,
	})

func load_queue() -> void:
	event_queue.clear()
	if not FileAccess.file_exists(queue_file_path):
		push_warning("DataManager queue file is missing; using an empty queue.")
		queue_changed.emit(0)
		return

	var file := FileAccess.open(queue_file_path, FileAccess.READ)
	if file == null:
		push_warning("DataManager could not open the local player event queue.")
		queue_changed.emit(0)
		return

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or not json.data is Array:
		push_warning("DataManager found an invalid player event queue; using an empty queue.")
		queue_changed.emit(0)
		return

	var skipped_entries := 0
	for raw_event in json.data:
		if raw_event is Dictionary:
			event_queue.append(raw_event)
		else:
			skipped_entries += 1
	if skipped_entries > 0:
		push_warning("DataManager skipped %d malformed queue entries." % skipped_entries)
	queue_changed.emit(event_queue.size())

func get_queue_snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for event in event_queue:
		snapshot.append(event.duplicate(true))
	return snapshot

func clear_uploaded_events(uploaded_event_ids: Array[String]) -> int:
	if uploaded_event_ids.is_empty():
		return 0

	var id_lookup := {}
	for event_id in uploaded_event_ids:
		id_lookup[event_id] = true

	var removed := 0
	for index in range(event_queue.size() - 1, -1, -1):
		var event_id := String(event_queue[index].get("event_id", ""))
		if id_lookup.has(event_id):
			event_queue.remove_at(index)
			removed += 1

	if removed > 0:
		_save_queue()
		queue_changed.emit(event_queue.size())
	return removed

func _build_event(event_name: String, data: Dictionary) -> Dictionary:
	var context := _dictionary_or_empty(data.get("context", {}), "context")
	var details := _dictionary_or_empty(data.get("details", {}), "details")
	var player_guess := String(data.get("player_guess", ""))
	var event := {
		"schema_version": EVENT_SCHEMA_VERSION,
		"event_id": _create_event_id(),
		"session_id": session_id,
		"build_version": build_version,
		"build_id": build_version,
		"event_name": event_name,
		"vocab_id": String(data.get("vocab_id", "")),
		"location": String(data.get("location", "")),
		"context": context,
		"player_guess": player_guess,
		"guess_length": player_guess.length(),
		"has_guess": not player_guess.strip_edges().is_empty(),
		"play_time_seconds": (
			float(Time.get_ticks_msec() - session_started_at_msec) / 1000.0
		),
		"client_timestamp": Time.get_datetime_string_from_system(true),
		"details": details,
		"details_json": JSON.stringify(details),
	}
	return event

func _dictionary_or_empty(value: Variant, field_name: String) -> Dictionary:
	if value is Dictionary:
		return value.duplicate(true)
	push_warning("DataManager expected %s to be a Dictionary; using an empty value." % field_name)
	return {}

func _forward_to_telemetry(event: Dictionary) -> bool:
	if not is_instance_valid(TelemetryManager):
		return false
	if not TelemetryManager.has_method("record_event") or not TelemetryManager.is_configured():
		return false
	if TelemetryManager.consent_state != TelemetryManager.CONSENT_ACCEPTED:
		return false

	var properties := event.duplicate(true)
	properties.erase("event_name")
	# The existing consent copy promises that guess text is never uploaded.
	properties.erase("player_guess")
	var details: Dictionary = event.get("details", {})
	for key in details:
		if not properties.has(key):
			properties[key] = details[key]
	TelemetryManager.record_event(String(event.event_name), properties)
	return true

func _save_queue() -> bool:
	var file := FileAccess.open(queue_file_path, FileAccess.WRITE)
	if file == null:
		push_warning("DataManager could not write the local player event queue.")
		return false
	file.store_string(JSON.stringify(event_queue))
	return true

func _collect_vocab_ids(raw_ids: Array, output: Array[String]) -> void:
	for vocab_id in raw_ids:
		if vocab_id is Array:
			_collect_vocab_ids(vocab_id, output)
		elif not String(vocab_id).is_empty():
			output.append(String(vocab_id))

func _create_session_id() -> String:
	return "%s-%08x-%08x" % [
		Time.get_unix_time_from_system(),
		_random.randi(),
		_random.randi(),
	]

func _create_event_id() -> String:
	return "%s-%08x" % [Time.get_ticks_usec(), _random.randi()]
