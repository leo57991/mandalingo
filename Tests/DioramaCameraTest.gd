extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var telemetry_manager: Node = root.get_node("TelemetryManager")
	var original_consent: String = telemetry_manager.consent_state
	var original_session_started: bool = telemetry_manager._session_started
	telemetry_manager.consent_state = telemetry_manager.CONSENT_ACCEPTED
	telemetry_manager._session_started = true
	var recorded_events: Array[String] = []
	var listener := func(payload: Dictionary) -> void:
		recorded_events.append(String(payload.get("event_name", "")))
	telemetry_manager.event_recorded.connect(listener)

	var target := Node3D.new()
	target.position = Vector3(0.0, 0.8, 0.0)
	root.add_child(target)
	var camera_script := load("res://Scripts/Systems/DioramaCamera3D.gd") as Script
	var camera: Variant = camera_script.new()
	camera.target_player = target
	camera.camera_offset = Vector3(0.0, 4.0, 8.0)
	camera.limit_left = -3.0
	camera.limit_right = 3.0
	camera.follow_speed = 100.0
	camera.blur_transition_speed = 100.0
	root.add_child(camera)
	await process_frame

	_expect(recorded_events.has("shop_camera_initialized"), "Camera initialization records telemetry")
	_expect(camera.attributes is CameraAttributesPractical, "Camera uses CameraAttributesPractical")
	var camera_attributes := camera.get_camera_attributes() as CameraAttributesPractical
	_expect(
		camera_attributes.dof_blur_far_enabled and camera_attributes.dof_blur_near_enabled,
		"Near and far depth of field are enabled"
	)

	target.global_position.x = 100.0
	camera._handle_camera_panning(1.0)
	_expect(is_equal_approx(camera.global_position.x, 3.0), "Camera clamps to the right limit")
	target.global_position.x = -100.0
	camera._handle_camera_panning(1.0)
	_expect(is_equal_approx(camera.global_position.x, -3.0), "Camera clamps to the left limit")

	target.global_position = Vector3(0.0, 0.8, 0.0)
	camera._handle_camera_panning(1.0)
	var first_focus_distance: float = camera.global_position.distance_to(target.global_position)
	camera._update_dynamic_focus(1.0)
	_expect(
		is_equal_approx(
			camera_attributes.dof_blur_far_distance,
			first_focus_distance + camera.focus_margin
		),
		"Far focus distance follows the player distance"
	)
	var first_near_distance := camera_attributes.dof_blur_near_distance
	target.global_position.z = 3.0
	var second_focus_distance: float = camera.global_position.distance_to(target.global_position)
	camera._update_dynamic_focus(1.0)
	_expect(
		not is_equal_approx(camera_attributes.dof_blur_near_distance, first_near_distance)
		and is_equal_approx(
			camera_attributes.dof_blur_near_distance,
			maxf(second_focus_distance - camera.focus_margin, 0.01)
		),
		"Near focus distance updates when relative player distance changes"
	)

	telemetry_manager.event_recorded.disconnect(listener)
	telemetry_manager.consent_state = original_consent
	telemetry_manager._session_started = original_session_started
	camera.queue_free()
	target.queue_free()
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
		print("Diorama camera test passed.")
		quit(0)
		return
	print("Diorama camera test failed (%d): %s" % [failures.size(), failures])
	quit(1)
