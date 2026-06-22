extends SceneTree

const TEST_QUEUE_FILE := "user://player_event_queue_test.json"

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_delete_test_queue()
	var telemetry := root.get_node("TelemetryManager")
	var autoload_data_manager := root.get_node("DataManager")
	telemetry.consent_state = telemetry.CONSENT_DECLINED
	telemetry._session_started = true
	_expect(
		telemetry.session_id == autoload_data_manager.session_id,
		"TelemetryManager uses the canonical DataManager session id"
	)

	var manager: Node = _create_manager()
	var event: Dictionary = manager.track_guess_updated(
		&"pingguo", "apple", {"scene_name": "test"}
	)
	_expect(event.event_name == "guess_updated", "DataManager preserves the event name")
	_expect(event.session_id == manager.session_id, "DataManager adds the session id")
	_expect(event.build_version == manager.build_version, "DataManager adds the build version")
	_expect(event.player_guess == "apple", "Local events retain the player guess")
	_expect(event.guess_length == 5 and event.has_guess, "Guess metadata is normalized")
	_expect(event.context.scene_name == "test", "Context dictionaries are preserved")
	_expect(event.has("play_time_seconds"), "DataManager adds play time")
	_expect(event.has("client_timestamp"), "DataManager adds a client timestamp")
	_expect(FileAccess.file_exists(TEST_QUEUE_FILE), "New events persist to a local JSON queue")

	var water_entry: VocabularyEntry = VocabularyEntry.new()
	water_entry.id = &"test_water"
	water_entry.english_internal = "water"
	var vocab_db: Node = root.get_node("VocabularyDatabase")
	vocab_db.entries[water_entry.id] = water_entry
	var water_reaction: InteractableReaction = InteractableReaction.new()
	water_reaction.reaction_id = &"water_reacts"
	water_reaction.trigger_sequence = [&"test_water", &"lai"]
	var reactions: Array[InteractableReaction] = [water_reaction, null]
	var reaction_lookup: Dictionary = InteractableReactionMatcher.build_lookup(reactions)
	var matched_reaction: InteractableReaction = InteractableReactionMatcher.match(
		water_reaction.trigger_sequence, reaction_lookup
	)
	_expect(matched_reaction == water_reaction, "Reaction matcher finds an exact sequence")
	var partial_sequence: Array[StringName] = [&"test_water"]
	_expect(
		InteractableReactionMatcher.match(partial_sequence, reaction_lookup) == null,
		"Reaction matcher rejects partial sequences"
	)
	_expect(
		InteractableReactionMatcher.build_fallback_log(
			partial_sequence, vocab_db, "The {element} remains still."
		) == "The water remains still.",
		"Fallback logs use internal English vocabulary metadata"
	)
	var missing_sequence: Array[StringName] = [&"missing"]
	var empty_english_entry: VocabularyEntry = VocabularyEntry.new()
	empty_english_entry.id = &"empty_english"
	vocab_db.entries[empty_english_entry.id] = empty_english_entry
	var empty_english_sequence: Array[StringName] = [empty_english_entry.id]
	var empty_sequence: Array[StringName] = []
	_expect(
		InteractableReactionMatcher.build_fallback_log(
			missing_sequence, vocab_db, "{element}"
		) == "missing"
		and InteractableReactionMatcher.build_fallback_log(
			empty_english_sequence, vocab_db, "{element}"
		) == "empty_english"
		and InteractableReactionMatcher.build_fallback_log(
			empty_sequence, vocab_db, "{element}"
		) == "Unknown",
		"Fallback logs safely handle missing data, empty English, and empty input"
	)
	var reaction_event: Dictionary = manager.track_interactable_reaction(
		&"well", water_reaction.trigger_sequence, matched_reaction, "courtyard"
	)
	_expect(
		reaction_event.event_name == "interactable_reaction_triggered"
		and reaction_event.details.submitted_sequence == "test_water|lai"
		and reaction_event.details.is_success
		and reaction_event.details.matched_reaction_id == "water_reacts",
		"DataManager records normalized interactable reaction details"
	)
	vocab_db.entries.erase(water_entry.id)
	vocab_db.entries.erase(empty_english_entry.id)

	var reloaded_manager: Node = _create_manager()
	_expect(reloaded_manager.event_queue.size() == 2, "DataManager reloads the local queue")
	var uploaded_ids: Array[String] = [
		String(event.event_id),
		String(reaction_event.event_id),
	]
	_expect(
		reloaded_manager.clear_uploaded_events(uploaded_ids) == 2,
		"Confirmed uploaded event ids can be removed"
	)
	_expect(reloaded_manager.event_queue.is_empty(), "Clearing uploaded ids preserves queue integrity")

	var forwarded_payloads: Array[Dictionary] = []
	var listener := func(payload: Dictionary) -> void:
		forwarded_payloads.append(payload)
	telemetry.event_recorded.connect(listener)
	telemetry.consent_state = telemetry.CONSENT_ACCEPTED
	manager.track_guess_updated(&"pingguo", "private guess", {"source": "test"})
	_expect(forwarded_payloads.size() == 1, "Consented events are forwarded to TelemetryManager")
	if forwarded_payloads.size() == 1:
		var properties: Dictionary = forwarded_payloads[0].properties
		_expect(not properties.has("player_guess"), "Remote telemetry redacts guess text")
		_expect(properties.guess_length == 13, "Remote telemetry keeps guess length")
	telemetry.event_recorded.disconnect(listener)

	var corrupt_file := FileAccess.open(TEST_QUEUE_FILE, FileAccess.WRITE)
	corrupt_file.store_string("{not valid json")
	corrupt_file = null
	var recovered_manager: Node = _create_manager()
	_expect(recovered_manager.event_queue.is_empty(), "A corrupt queue safely falls back to empty")

	telemetry.consent_state = telemetry.CONSENT_DECLINED
	manager.queue_free()
	reloaded_manager.queue_free()
	recovered_manager.queue_free()
	await process_frame
	_delete_test_queue()
	_finish()

func _create_manager() -> Node:
	var manager_script := load("res://Scripts/Systems/DataManager.gd") as Script
	var manager: Node = manager_script.new()
	manager.queue_file_path = TEST_QUEUE_FILE
	root.add_child(manager)
	return manager

func _delete_test_queue() -> void:
	if FileAccess.file_exists(TEST_QUEUE_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_QUEUE_FILE))

func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		failures.append(description)
		push_error("FAIL: %s" % description)

func _finish() -> void:
	if failures.is_empty():
		print("DataManager test passed.")
		quit(0)
		return
	print("DataManager test failed (%d): %s" % [failures.size(), failures])
	quit(1)
