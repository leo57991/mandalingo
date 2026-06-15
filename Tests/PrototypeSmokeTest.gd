extends SceneTree

const EXPECTED_VOCABULARY_IDS: Array[StringName] = [
	&"cha",
	&"ni",
	&"nihao",
	&"pingguo",
	&"ren",
	&"shei",
	&"shi",
	&"shui",
	&"ta",
	&"wo",
	&"zhe",
]

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var telemetry_manager: Node = root.get_node("TelemetryManager")
	telemetry_manager.consent_state = "declined"

	var packed_scene: PackedScene = load("res://Scenes/World/GroceryStore.tscn")
	_expect(packed_scene != null, "Main scene loads")
	if packed_scene == null:
		_finish()
		return

	var scene: Node2D = packed_scene.instantiate()
	root.add_child(scene)
	await process_frame

	_validate_vocabulary()
	_validate_scene_structure(scene)
	_validate_telemetry()
	await _validate_npc_dialogue(scene)
	await _validate_object_dialogue(scene)
	_validate_notebook(scene)

	var audio_manager: Node = root.get_node("AudioManager")
	audio_manager.voice_player.stop()
	audio_manager.voice_player.stream = null
	await create_timer(0.2).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	_finish()

func _validate_vocabulary() -> void:
	var database: Node = root.get_node("VocabularyDatabase")
	_expect(
		database.entries.size() == EXPECTED_VOCABULARY_IDS.size(),
		"Vocabulary count matches the prototype set"
	)
	for id in EXPECTED_VOCABULARY_IDS:
		_expect(database.get_entry(id) != null, "Vocabulary exists: %s" % id)

func _validate_scene_structure(scene: Node2D) -> void:
	var required_paths := [
		"Player",
		"NPCs/ShopOwner",
		"NPCs/Assistant",
		"NPCs/CustomerA",
		"NPCs/CustomerB",
		"NPCs/CustomerC",
		"Shelves/ShelfApples",
		"Shelves/ShelfTea",
		"Shelves/ShelfWater",
	]
	for path in required_paths:
		_expect(scene.has_node(path), "Scene node exists: %s" % path)

	for npc in get_nodes_in_group("npc"):
		var target: Area2D = npc.get_node("InteractionTarget")
		_expect(not target.lines.is_empty(), "%s has dialogue" % npc.name)
		_expect(
			target.lines.size() == target.vocab_ids.size(),
			"%s dialogue and vocabulary arrays align" % npc.name
		)

func _validate_npc_dialogue(scene: Node2D) -> void:
	var player: CharacterBody2D = scene.get_node("Player")
	var assistant: CharacterBody2D = scene.get_node("NPCs/Assistant")
	var customer_b: CharacterBody2D = scene.get_node("NPCs/CustomerB")
	var customer_b_start := customer_b.global_position
	var target: Area2D = assistant.get_node("InteractionTarget")
	var bubble: PanelContainer = assistant.get_node("SpeechBubble")
	var label: Label = assistant.get_node("SpeechBubble/MarginContainer/SpeechLabel")

	player.global_position = assistant.global_position + Vector2(35, 0)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.reset_smoothing()
	await process_frame

	Input.action_press("move_right")
	var player_start := player.global_position
	target.interact()
	await process_frame

	_expect(assistant.is_speaking, "NPC interaction starts dialogue")
	_expect(label.text == "你好", "NPC dialogue starts with 你好")
	_expect(bubble.visible, "NPC speech bubble is visible")
	_expect(bubble.offset_bottom <= -20.0, "Speech bubble stays close above the NPC")

	var seen_before_repeat: int = root.get_node("VocabularyDatabase").get_entry(&"nihao").seen_count
	target.interact()
	await process_frame
	var seen_after_repeat: int = root.get_node("VocabularyDatabase").get_entry(&"nihao").seen_count
	_expect(
		seen_after_repeat == seen_before_repeat,
		"Repeated interaction during dialogue is ignored"
	)

	var notebook: CanvasLayer = get_first_node_in_group("notebook_ui")
	notebook.open()
	_expect(not notebook.visible, "Notebook cannot open during dialogue")

	await create_timer(0.4).timeout
	_expect(
		player.global_position.distance_to(player_start) < 1.0,
		"Player is frozen during NPC dialogue"
	)
	Input.action_release("move_right")

	await create_timer(5.8).timeout
	_expect(not assistant.is_speaking, "NPC dialogue finishes")
	_expect(
		customer_b.global_position.distance_to(customer_b_start) > 1.0,
		"Random-walking NPC continues moving"
	)
	_expect(
		customer_b.random_walk_bounds.has_point(customer_b.global_position),
		"Random-walking NPC stays inside its assigned area"
	)

	camera.enabled = false
	assistant.global_position = Vector2(100, 5)
	await process_frame
	assistant.display_word("你好")
	_expect(
		bubble.offset_top >= 20.0,
		"Speech bubble flips below the NPC at the top screen edge"
	)
	assistant.speech_timer.stop()
	assistant._hide_speech()

func _validate_telemetry() -> void:
	var telemetry_manager: Node = root.get_node("TelemetryManager")
	var recorded_payloads: Array[Dictionary] = []
	var listener := func(payload: Dictionary) -> void:
		recorded_payloads.append(payload)
	telemetry_manager.event_recorded.connect(listener)

	telemetry_manager.consent_state = "declined"
	telemetry_manager._session_started = true
	telemetry_manager.record_event("declined_smoke_test")
	_expect(recorded_payloads.is_empty(), "Telemetry is suppressed without consent")

	telemetry_manager.consent_state = "accepted"
	telemetry_manager.record_event("accepted_smoke_test", {"value": 1})
	_expect(recorded_payloads.size() == 1, "Telemetry records events after consent")
	if recorded_payloads.size() == 1:
		_expect(
			recorded_payloads[0].event_name == "accepted_smoke_test",
			"Telemetry payload preserves the event name"
		)

	telemetry_manager.event_recorded.disconnect(listener)
	telemetry_manager.consent_state = "declined"
	telemetry_manager._session_started = false

func _validate_object_dialogue(scene: Node2D) -> void:
	var dialogue_system: Node = root.get_node("DialogueSystem")
	var shelf_target: Area2D = scene.get_node("Shelves/ShelfTea/InteractionTarget")
	var player: CharacterBody2D = scene.get_node("Player")

	shelf_target.interact()
	await process_frame
	_expect(dialogue_system.is_showing, "Object interaction opens dialogue")

	Input.action_press("move_left")
	var player_start := player.global_position
	await create_timer(0.2).timeout
	_expect(
		player.global_position.distance_to(player_start) < 1.0,
		"Player is frozen during object dialogue"
	)
	Input.action_release("move_left")

	dialogue_system.advance()
	dialogue_system.advance()
	_expect(not dialogue_system.is_showing, "Object dialogue closes after final line")

func _validate_notebook(scene: Node2D) -> void:
	var database: Node = root.get_node("VocabularyDatabase")
	var audio_manager: Node = root.get_node("AudioManager")
	var notebook: CanvasLayer = get_first_node_in_group("notebook_ui")
	var entry: Resource = database.get_entry(&"cha")

	var seen_before_replay: int = entry.seen_count
	audio_manager.play_vocabulary(&"cha", "", false)
	_expect(entry.seen_count == seen_before_replay, "Notebook replay does not increase seen count")

	database.mark_learned(&"cha", "smoke_test")
	notebook._populate_words()
	notebook._populate_words()
	_expect(
		notebook.word_list.get_child_count() == _seen_vocabulary_count(database),
		"Notebook rebuild does not duplicate cards"
	)

	paused = true
	notebook.open()
	notebook.close()
	_expect(paused, "Notebook restores an existing paused state")
	paused = false

func _seen_vocabulary_count(database: Node) -> int:
	var count := 0
	for entry in database.entries.values():
		if entry.seen_count > 0:
			count += 1
	return count

func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		failures.append(description)
		push_error("FAIL: %s" % description)

func _finish() -> void:
	if failures.is_empty():
		print("Prototype smoke test passed.")
		quit(0)
		return

	print("Prototype smoke test failed (%d): %s" % [failures.size(), failures])
	quit(1)
