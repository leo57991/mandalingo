extends Node3D

func _ready() -> void:
	_add_interface("res://Scenes/UI/NotebookUI.tscn")
	_add_interface("res://Scenes/UI/TelemetryConsentUI.tscn")
	_create_notebook_button()

func _add_interface(scene_path: String) -> void:
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene != null:
		add_child(packed_scene.instantiate())

func _create_notebook_button() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 5
	add_child(hud)

	var button := Button.new()
	button.custom_minimum_size = Vector2(48, 48)
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.offset_left = -64.0
	button.offset_top = 16.0
	button.offset_right = -16.0
	button.offset_bottom = 64.0
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	var icon := load("res://Assets/Sprites/book_icon.png") as Texture2D
	if icon != null:
		button.icon = icon
		button.expand_icon = true
	button.pressed.connect(_toggle_notebook)
	hud.add_child(button)

func _toggle_notebook() -> void:
	var notebook := get_tree().get_first_node_in_group("notebook_ui")
	if notebook == null or DialogueSystem.is_showing:
		return
	if notebook.visible:
		notebook.close()
	else:
		notebook.open()
