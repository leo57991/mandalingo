extends CharacterBody3D
class_name PlayerController25D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var fixed_z_position: float = 0.0

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _ready() -> void:
	# Ensure the player starts on the locked 2.5D depth plane.
	global_position.z = fixed_z_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_direction: Vector2 = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)
	var direction: Vector3 = Vector3(input_direction.x, 0.0, 0.0)

	if direction != Vector3.ZERO:
		velocity.x = direction.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)

	velocity.z = 0.0

	move_and_slide()
	global_position.z = fixed_z_position
