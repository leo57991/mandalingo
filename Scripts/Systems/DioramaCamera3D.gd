extends Camera3D
class_name DioramaCamera3D

@export_category("Target Follow")
@export var target_player: Node3D
@export_node_path("Node3D") var target_player_path: NodePath
@export_range(0.0, 20.0, 0.1) var follow_speed: float = 4.0
@export var camera_offset: Vector3 = Vector3(0.0, 1.5, 6.0)
@export var look_at_height_offset: float = 0.5

@export_category("Camera Limits")
@export var limit_left: float = -12.0
@export var limit_right: float = 12.0

@export_category("Diorama Visuals")
@export var enable_diorama_blur: bool = true
@export_range(0.0, 20.0, 0.1) var blur_transition_speed: float = 5.0
@export_range(0.0, 5.0, 0.05) var focus_margin: float = 0.5
@export_range(0.0, 1.0, 0.01) var blur_amount: float = 0.08

var _camera_attributes: CameraAttributesPractical

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if target_player == null and not target_player_path.is_empty():
		target_player = get_node_or_null(target_player_path) as Node3D
	if target_player == null:
		push_warning("DioramaCamera3D: target_player is not assigned; camera follow is disabled.")
	if limit_left > limit_right:
		push_warning("DioramaCamera3D: camera limits were reversed and have been normalized.")
		var original_left := limit_left
		limit_left = limit_right
		limit_right = original_left
	_setup_diorama_environment()
	TelemetryManager.record_event("shop_camera_initialized", {
		"limit_left": limit_left,
		"limit_right": limit_right,
		"enable_blur": enable_diorama_blur,
	})

func _physics_process(delta: float) -> void:
	if target_player == null:
		return
	_handle_camera_panning(delta)
	if enable_diorama_blur and _camera_attributes != null:
		_update_dynamic_focus(delta)

func _handle_camera_panning(delta: float) -> void:
	var target_x := clampf(
		target_player.global_position.x + camera_offset.x,
		limit_left,
		limit_right
	)
	var lerp_weight := clampf(follow_speed * delta, 0.0, 1.0)
	var smoothed_x := lerpf(global_position.x, target_x, lerp_weight)
	global_position = Vector3(
		clampf(smoothed_x, limit_left, limit_right),
		camera_offset.y,
		camera_offset.z
	)

	var focus_x := clampf(
		target_player.global_position.x,
		limit_left - camera_offset.x,
		limit_right - camera_offset.x
	)
	var look_at_target := Vector3(
		focus_x,
		target_player.global_position.y + look_at_height_offset,
		0.0
	)
	look_at(look_at_target, Vector3.UP)

func _setup_diorama_environment() -> void:
	if not enable_diorama_blur:
		attributes = null
		_camera_attributes = null
		return
	_camera_attributes = CameraAttributesPractical.new()
	_camera_attributes.dof_blur_amount = blur_amount
	_camera_attributes.dof_blur_far_enabled = true
	_camera_attributes.dof_blur_far_transition = 1.5
	_camera_attributes.dof_blur_near_enabled = true
	_camera_attributes.dof_blur_near_transition = 1.0
	attributes = _camera_attributes
	if target_player != null:
		var focus_distance := global_position.distance_to(target_player.global_position)
		_camera_attributes.dof_blur_far_distance = focus_distance + focus_margin
		_camera_attributes.dof_blur_near_distance = maxf(
			focus_distance - focus_margin,
			0.01
		)

func _update_dynamic_focus(delta: float) -> void:
	var focus_distance := global_position.distance_to(target_player.global_position)
	var target_far_distance := focus_distance + focus_margin
	var target_near_distance := maxf(focus_distance - focus_margin, 0.01)
	var lerp_weight := clampf(blur_transition_speed * delta, 0.0, 1.0)
	_camera_attributes.dof_blur_far_distance = lerpf(
		_camera_attributes.dof_blur_far_distance,
		target_far_distance,
		lerp_weight
	)
	_camera_attributes.dof_blur_near_distance = lerpf(
		_camera_attributes.dof_blur_near_distance,
		target_near_distance,
		lerp_weight
	)

func get_camera_attributes() -> CameraAttributesPractical:
	return _camera_attributes
