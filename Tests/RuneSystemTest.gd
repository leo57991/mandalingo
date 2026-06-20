extends SceneTree

const TEST_QUEUE_FILE := "user://rune_system_test_events.json"

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

	var pattern := load("res://Data/Spells/identify_apple.tres") as SpellPattern
	_expect(pattern != null and pattern.is_valid_pattern(), "SpellPattern resource loads and validates")

	var apple_characters: Array[StringName] = [&"蘋", &"果"]
	var reversed_characters: Array[StringName] = [&"果", &"蘋"]
	var char_judge := CharToWordJudge.new({&"pingguo": apple_characters})
	var word_result := char_judge.evaluate(apple_characters)
	_expect(word_result.success and word_result.result_id == &"pingguo", "Characters form the expected word")
	_expect(
		not char_judge.evaluate(reversed_characters).success,
		"Character order is exact"
	)

	var patterns: Array[SpellPattern] = [pattern]
	var correct_spell: Array[StringName] = [&"zhe", &"shi", &"pingguo"]
	var incorrect_spell: Array[StringName] = [&"shi", &"zhe", &"pingguo"]
	var sentence_judge := WordToSentenceJudge.new(patterns)
	var spell_result := sentence_judge.evaluate(correct_spell)
	_expect(spell_result.success and spell_result.result_id == &"identify_apple", "Words match the resource-defined spell")
	_expect(
		not sentence_judge.evaluate(incorrect_spell).success,
		"Spell slot order is enforced"
	)

	var machine := RuneStateMachine.new()
	root.add_child(machine)
	var visited_states: Array[RuneStateMachine.State] = []
	machine.state_changed.connect(
		func(_previous: RuneStateMachine.State, current: RuneStateMachine.State) -> void:
			visited_states.append(current)
	)
	_expect(
		machine.begin_input(sentence_judge, {"location": "grocery_store_25d"}),
		"RuneStateMachine starts collecting input"
	)
	var machine_result := machine.submit_input(correct_spell)
	_expect(machine_result.success and machine.state == RuneStateMachine.State.IDLE, "Successful judgement returns the machine to idle")
	_expect(visited_states.has(RuneStateMachine.State.JUDGING), "State machine enters judging")
	_expect(visited_states.has(RuneStateMachine.State.SUCCESS), "State machine exposes success")

	var prep1_tea := load("res://Data/Spells/prep1_identify_tea.tres") as SpellPattern
	var prep1_water := load("res://Data/Spells/prep1_identify_water.tres") as SpellPattern
	var prep2_greeting := load("res://Data/Spells/prep2_greeting.tres") as SpellPattern
	_expect(
		prep1_tea != null and prep1_tea.is_valid_pattern()
		and prep1_water != null and prep1_water.is_valid_pattern()
		and prep2_greeting != null and prep2_greeting.is_valid_pattern(),
		"Multi-level spell resources load and validate"
	)

	var progression := TocflProgressionManager.new()
	progression.spell_patterns = [prep1_tea, prep1_water, prep2_greeting]
	root.add_child(progression)
	var unlocked_levels: Array[String] = []
	progression.level_unlocked.connect(func(level: String) -> void: unlocked_levels.append(level))
	_expect(
		not progression.record_spell_success(&"prep1_identify_tea"),
		"Mastering one of two Prep1 spells does not unlock the next level"
	)
	_expect(
		is_equal_approx(progression.get_level_progress("Prep1"), 0.5),
		"One of two mastered Prep1 spells reports 0.5 progress"
	)
	_expect(
		progression.record_spell_success(&"prep1_identify_water"),
		"Mastering both Prep1 spells triggers a level unlock"
	)
	_expect(progression.current_level == "Prep2", "TOCFL progression advances in level order")
	_expect(unlocked_levels == ["Prep2"], "TOCFL progression emits the unlocked level")
	var prep2_spell_ids := progression.get_spell_ids_for_level("Prep2")
	var expected_prep2_spell_ids: Array[StringName] = [&"prep2_greeting"]
	_expect(
		prep2_spell_ids == expected_prep2_spell_ids,
		"The public level query returns the next-level spell pool"
	)
	_expect(
		not progression.record_spell_success(&"prep1_identify_tea"),
		"Duplicate spell mastery is ignored"
	)

	var event_names: Array[String] = []
	var judgement_event: Dictionary = {}
	for event in data_manager.event_queue:
		var event_name := String(event.get("event_name", ""))
		event_names.append(event_name)
		if event_name == "rune_judgement":
			judgement_event = event
	_expect(event_names.has("rune_judgement"), "Rune attempts are recorded through DataManager")
	_expect(event_names.has("rune_spell_success"), "Successful spells are recorded through DataManager")
	_expect(event_names.has("tocfl_level_unlocked"), "TOCFL unlocks are recorded through DataManager")
	_expect(
		judgement_event.get("location", "") == "grocery_store_25d"
		and judgement_event.get("context", {}).get("location", "") == "grocery_store_25d"
		and judgement_event.get("details", {}).get("sequence", []) == ["zhe", "shi", "pingguo"]
		and judgement_event.get("details", {}).get("success", false),
		"DataManager preserves rune judgement details, context, and location"
	)

	machine.queue_free()
	progression.queue_free()
	await process_frame
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
		print("Rune system test passed.")
		quit(0)
		return
	print("Rune system test failed (%d): %s" % [failures.size(), failures])
	quit(1)
