extends CharacterBody3D

@export var speed := 4.2

@onready var interaction_area: Area3D = %InteractionArea

var _was_j_pressed := false

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if _is_dialogue_active():
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var camera := get_viewport().get_camera_3d()
	var direction := Vector3(input.x, 0.0, input.y)
	if camera != null:
		var right := camera.global_basis.x
		var forward := -camera.global_basis.z
		right.y = 0.0
		forward.y = 0.0
		direction = right.normalized() * input.x + forward.normalized() * -input.y
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()

func _process(_delta: float) -> void:
	var notebook := get_tree().get_first_node_in_group("notebook_ui")
	var toggle_notebook := Input.is_action_just_pressed("ui_focus_next")
	if Input.is_physical_key_pressed(KEY_J) and not _was_j_pressed:
		toggle_notebook = true
	_was_j_pressed = Input.is_physical_key_pressed(KEY_J)

	if toggle_notebook and not _is_dialogue_active() and notebook != null:
		if notebook.visible:
			notebook.close()
		else:
			notebook.open()

func _unhandled_input(event: InputEvent) -> void:
	var notebook := get_tree().get_first_node_in_group("notebook_ui")
	if notebook != null and notebook.visible:
		return

	if event.is_action_pressed("interact"):
		if DialogueSystem.is_showing:
			DialogueSystem.advance()
			get_viewport().set_input_as_handled()
			return

		var target := get_closest_interaction_target()
		if target != null:
			target.interact()
			get_viewport().set_input_as_handled()

func get_closest_interaction_target() -> Area3D:
	var closest: Area3D = null
	var closest_distance := INF
	for area in interaction_area.get_overlapping_areas():
		if not area.has_method("interact"):
			continue
		var distance := global_position.distance_to(area.global_position)
		if distance < closest_distance:
			closest = area
			closest_distance = distance
	return closest

func _is_dialogue_active() -> bool:
	if DialogueSystem.is_showing:
		return true
	for npc in get_tree().get_nodes_in_group("npc"):
		if "is_speaking" in npc and npc.is_speaking:
			return true
	return false
