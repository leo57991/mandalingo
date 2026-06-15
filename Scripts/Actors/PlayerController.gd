extends CharacterBody2D

@export var speed: float = 160.0
@export var interaction_radius: float = 40.0

@onready var interaction_area: Area2D = %InteractionArea

var _was_j_pressed: bool = false

func _ready() -> void:
	add_to_group("player")
	# Show placeholder body for demo (no art sprite)
	var placeholder = get_node_or_null("PlaceholderBody")
	if placeholder != null:
		placeholder.visible = true

func _physics_process(_delta: float) -> void:
	if _is_dialogue_active():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

func _process(_delta: float) -> void:
	var notebook = get_tree().get_first_node_in_group("notebook_ui")
	
	var toggle_notebook := false
	if Input.is_action_just_pressed("ui_focus_next"):
		toggle_notebook = true
	elif Input.is_physical_key_pressed(KEY_J) and not _was_j_pressed:
		toggle_notebook = true
	_was_j_pressed = Input.is_physical_key_pressed(KEY_J)

	if toggle_notebook:
		if _is_dialogue_active():
			return
		if notebook != null:
			if notebook.visible:
				notebook.close()
			else:
				notebook.open()
			return

	if notebook != null and notebook.visible:
		return

	if Input.is_action_just_pressed("interact"):
		if DialogueSystem.is_showing:
			DialogueSystem.advance()
			return

		var target := _get_closest_interaction_target()
		if target != null:
			target.interact()

func _get_closest_interaction_target() -> Area2D:
	var closest: Area2D = null
	var closest_distance := INF

	for area in interaction_area.get_overlapping_areas():
		if area.has_method("interact") and "can_interact" in area and area.can_interact:
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
