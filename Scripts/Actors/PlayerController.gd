extends CharacterBody2D

@export var speed: float = 160.0
@export var interaction_radius: float = 40.0

@onready var interaction_area: Area2D = %InteractionArea

func _ready() -> void:
	add_to_group("player")
	var sprite_2d = get_node_or_null("Sprite2D")
	if sprite_2d != null:
		var tex = preload("res://Assets/Sprites/player.png")
		if tex is Texture2D:
			sprite_2d.texture = tex
			var tex_size = tex.get_size()
			if tex_size.y > 0:
				var scale_factor = 48.0 / tex_size.y
				sprite_2d.scale = Vector2(scale_factor, scale_factor)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

func _process(_delta: float) -> void:
	var notebook = get_tree().get_first_node_in_group("notebook_ui")
	
	if Input.is_action_just_pressed("ui_focus_next"):
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
