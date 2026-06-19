extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("TelemetryManager").consent_state = "declined"
	var packed_scene := load("res://Scenes/World/GroceryStore25D.tscn") as PackedScene
	_expect(packed_scene != null, "2.5D scene loads")
	if packed_scene == null:
		_finish()
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	await physics_frame

	var player := scene.get_node("Player") as CharacterBody3D
	var shelf := scene.get_node("Store/AppleShelf") as StaticBody3D
	var shelf_target := shelf.get_node("InteractionTarget") as Area3D
	var npc := scene.get_node("Assistant") as StaticBody3D
	var npc_target := npc.get_node("InteractionTarget") as Area3D
	var right_boundary := scene.get_node("Store/RightBoundary") as StaticBody3D

	_expect(scene.get_node("Camera3D") is Camera3D, "Orthographic camera exists")
	_expect(scene.get_node("Camera3D").projection == Camera3D.PROJECTION_ORTHOGONAL, "Camera uses orthographic projection")
	_expect(player != null and player.collision_mask == 4, "Player uses 3D world collision")
	_expect(shelf.collision_layer == 4, "Apple shelf blocks the player")
	_expect(shelf_target.collision_layer == 8, "Apple shelf exposes an interaction area")
	_expect(npc.collision_layer == 4, "NPC is immovable world geometry")
	_expect(right_boundary != null, "Invisible right boundary keeps the player inside")
	_expect(not right_boundary.has_node("Mesh"), "Foreground right wall no longer blocks the view")

	player.global_position = Vector3(0, 0.8, 1.0)
	await physics_frame
	await physics_frame
	_expect(player.get_closest_interaction_target() == shelf_target, "Player detects the apple shelf nearby")
	_expect(player.test_move(player.global_transform, Vector3(0, 0, -2.0)), "Shelf collision blocks forward movement")

	var database := root.get_node("VocabularyDatabase")
	var apple_entry: Resource = database.get_entry(&"pingguo")
	var seen_before: int = apple_entry.seen_count
	shelf_target.interact()
	await process_frame
	_expect(root.get_node("DialogueSystem").is_showing, "Shelf interaction opens Chinese dialogue")
	_expect(apple_entry.seen_count == seen_before + 1, "Shelf interaction records 蘋果")
	root.get_node("DialogueSystem").advance()
	_expect(not root.get_node("DialogueSystem").is_showing, "Shelf dialogue closes normally")

	var npc_seen_before: int = apple_entry.seen_count
	npc_target.interact()
	await process_frame
	_expect(npc.is_speaking, "NPC starts a speech sequence")
	_expect(npc.get_node("SpeechBubble").visible, "NPC world-space speech bubble appears")
	_expect(npc.get_node("SpeechBubble/SpeechLabel").text == "蘋果", "NPC bubble displays 蘋果")
	_expect(apple_entry.seen_count == npc_seen_before + 1, "NPC speech records 蘋果")
	await create_timer(npc.speech_delay + 0.1).timeout
	_expect(not npc.is_speaking, "NPC speech sequence finishes")
	_expect(not npc.get_node("SpeechBubble").visible, "NPC speech bubble closes")

	root.get_node("AudioManager").voice_player.stop()
	root.get_node("AudioManager").voice_player.stream = null
	scene.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		failures.append(description)
		push_error("FAIL: %s" % description)

func _finish() -> void:
	if failures.is_empty():
		print("2.5D prototype smoke test passed.")
		quit(0)
		return
	print("2.5D prototype smoke test failed (%d): %s" % [failures.size(), failures])
	quit(1)
