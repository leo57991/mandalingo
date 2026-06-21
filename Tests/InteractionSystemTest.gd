extends SceneTree

const TEST_QUEUE_FILE := "user://interaction_system_test_events.json"
const INVALID_ATTEMPT_COUNT := 100

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_delete_test_queue()
	var data_manager: Node = root.get_node("DataManager")
	var telemetry_manager: Node = root.get_node("TelemetryManager")
	var original_queue_path: String = data_manager.queue_file_path
	data_manager.queue_file_path = TEST_QUEUE_FILE
	data_manager.event_queue.clear()
	telemetry_manager.consent_state = telemetry_manager.CONSENT_DECLINED

	var open_door_reaction := InteractableReaction.new()
	open_door_reaction.reaction_id = &"open_door"
	open_door_reaction.trigger_sequence = [&"開", &"門"]
	open_door_reaction.particle_effect_type = "door_dust"
	open_door_reaction.log_english_template = "The {element} does not react."
	var reactions: Array[InteractableReaction] = [open_door_reaction]
	var lookup: Dictionary = InteractableReactionMatcher.build_lookup(reactions)

	var correct_sequence: Array[StringName] = [&"開", &"門"]
	var matched: InteractableReaction = InteractableReactionMatcher.match(
		correct_sequence, lookup
	)
	_expect(matched == open_door_reaction, "An exact sequence returns its reaction")

	var reversed_sequence: Array[StringName] = [&"門", &"開"]
	_expect(
		InteractableReactionMatcher.match(reversed_sequence, lookup) == null,
		"A reversed sequence does not trigger a reaction"
	)

	var empty_sequence: Array[StringName] = []
	_expect(
		InteractableReactionMatcher.match(empty_sequence, lookup) == null,
		"An empty sequence safely returns no match"
	)

	var vocab_db: Node = root.get_node("VocabularyDatabase")
	var unknown_sequence: Array[StringName] = [&"不存在的字"]
	var fallback_log: String = InteractableReactionMatcher.build_fallback_log(
		unknown_sequence, vocab_db, "The {element} does not react."
	)
	_expect(
		fallback_log == "The 不存在的字 does not react.",
		"Unknown vocabulary safely falls back to its submitted id"
	)

	var mixed_sequence: Array[StringName] = [&"開", &"不存在的字", &"門"]
	_expect(
		InteractableReactionMatcher.match(mixed_sequence, lookup) == null,
		"A mixed known and unknown sequence safely returns no match"
	)

	var char_judge := CharToWordJudge.new({&"open_door": correct_sequence})
	var unknown_char_result: RuneJudgeResult = char_judge.evaluate(unknown_sequence)
	var empty_char_result: RuneJudgeResult = char_judge.evaluate(empty_sequence)
	_expect(
		not unknown_char_result.success and unknown_char_result.result_id.is_empty()
		and not empty_char_result.success and empty_char_result.result_id.is_empty(),
		"CharToWordJudge safely returns its fallback result for invalid input"
	)

	var event: Dictionary = data_manager.track_interactable_reaction(
		&"shop_door",
		correct_sequence,
		matched,
		"grocery_store_25d",
		{"scene_name": "interaction_system_test"}
	)
	var details: Dictionary = event.get("details", {})
	_expect(event is Dictionary, "DataManager returns an event Dictionary")
	_expect(
		event.get("event_name", "") == "interactable_reaction_triggered"
		and event.get("context", {}).get("scene_name", "") == "interaction_system_test"
		and details.get("reaction_id", "") == "open_door"
		and details.get("trigger_sequence", "") == "開|門"
		and details.get("submitted_sequence", "") == "開|門"
		and details.get("particle_effect_type", "") == "door_dust",
		"DataManager preserves reaction identity, sequences, effects, and context"
	)

	var invalid_events_before: int = data_manager.event_queue.size()
	var invalid_attempts_stable := true
	for index: int in INVALID_ATTEMPT_COUNT:
		var invalid_sequence: Array[StringName] = [
			StringName("invalid_%d" % index),
			&"門",
		]
		var invalid_match: InteractableReaction = InteractableReactionMatcher.match(
			invalid_sequence, lookup
		)
		var invalid_event: Dictionary = data_manager.track_interactable_reaction(
			&"shop_door", invalid_sequence, invalid_match, "grocery_store_25d"
		)
		if invalid_match != null or invalid_event.is_empty():
			invalid_attempts_stable = false
			break
	_expect(
		invalid_attempts_stable
		and data_manager.event_queue.size() == invalid_events_before + INVALID_ATTEMPT_COUNT,
		"Repeated invalid attempts remain stable and are recorded"
	)

	data_manager.queue_file_path = original_queue_path
	data_manager.event_queue.clear()
	_delete_test_queue()
	_finish()

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
		print("Interaction system test passed.")
		quit(0)
		return
	print("Interaction system test failed (%d): %s" % [failures.size(), failures])
	quit(1)
