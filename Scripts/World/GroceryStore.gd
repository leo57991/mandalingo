extends Node2D

const COUNTER_TEXTURE := preload("res://Assets/Sprites/counter_table.png")
const APPLE_ITEM_TEXTURE := preload("res://Assets/Sprites/Items/apple_pixel.png")
const TEA_ITEM_TEXTURE := preload("res://Assets/Sprites/Items/tea_pixel.png")
const WATER_ITEM_TEXTURE := preload("res://Assets/Sprites/Items/water_pixel.png")
const SHOP_OWNER_INTERACTION_SIZE := Vector2(156, 110)
const SHOP_OWNER_INTERACTION_OFFSET := Vector2(-58, 0)

func _ready() -> void:
	# Load and setup floor visual only (keep art for floor)
	var floor_sprite = get_node_or_null("Floor")
	if floor_sprite is Sprite2D:
		var tex = preload("res://Assets/Sprites/floor.png")
		if tex is Texture2D:
			floor_sprite.texture = tex
			var tex_size = tex.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				floor_sprite.scale = Vector2(720.0 / tex_size.x, 480.0 / tex_size.y)
				
	# Setup counter visual
	var counter_sprite = get_node_or_null("Counter/CounterVisual")
	if counter_sprite is Sprite2D:
		counter_sprite.texture = COUNTER_TEXTURE
		var tex_size := COUNTER_TEXTURE.get_size()
		if tex_size.x > 0:
			var uniform_scale := 144.0 / tex_size.x
			counter_sprite.scale = Vector2.ONE * uniform_scale

	_configure_shelves()
	_configure_npcs()

	# Instantiate NotebookUI dynamically
	var notebook_scene = load("res://Scenes/UI/NotebookUI.tscn")
	if notebook_scene != null:
		var notebook_instance = notebook_scene.instantiate()
		add_child(notebook_instance)

	var consent_scene = load("res://Scenes/UI/TelemetryConsentUI.tscn")
	if consent_scene != null:
		add_child(consent_scene.instantiate())

	# Create notebook open button (HUD)
	_create_notebook_button()

func _configure_shelves() -> void:
	for shelf in get_tree().get_nodes_in_group("vocabulary_shelf"):
		if "shelf_id" in shelf and "item_texture" in shelf:
			match shelf.shelf_id:
				&"shelf_apples":
					shelf.item_texture = APPLE_ITEM_TEXTURE
				&"shelf_tea":
					shelf.item_texture = TEA_ITEM_TEXTURE
				&"shelf_water":
					shelf.item_texture = WATER_ITEM_TEXTURE
		if shelf.has_method("refresh_context"):
			shelf.refresh_context()

func _configure_npcs() -> void:
	# Set NPC starting positions
	$NPCs/Assistant.position = Vector2(-280, -80)
	$NPCs/CustomerB.position = Vector2(-280, 10)
	$NPCs/CustomerC.position = Vector2(-280, 100)
	$NPCs/CustomerA.position = Vector2(160, 190) # entrance (bottom right)
	_configure_shop_owner_interaction()

	_configure_npc(
		$NPCs/ShopOwner,
		"林阿姨",
		"店長",
		false,
		["你好", "蘋果", "茶", "水"],
		[&"nihao", &"pingguo", &"cha", &"shui"],
		1.4
	)
	_configure_npc(
		$NPCs/Assistant,
		"小安",
		"店員",
		true,
		["你好", "這是蘋果"],
		[&"nihao", &"pingguo"],
		3.0,
		Rect2(-330, -120, 90, 80)
	)
	_configure_npc(
		$NPCs/CustomerA,
		"美美",
		"客人",
		false, # Stationary next to entrance
		["你好"],
		[&"nihao"],
		1.4
	)
	_configure_npc(
		$NPCs/CustomerB,
		"阿明",
		"客人",
		true,
		["你好", "這是茶"],
		[&"nihao", &"cha"],
		3.0,
		Rect2(-330, -30, 90, 80)
	)
	_configure_npc(
		$NPCs/CustomerC,
		"小雨",
		"客人",
		true,
		["你好", "這是水"],
		[&"nihao", &"shui"],
		3.0,
		Rect2(-330, 60, 90, 80)
	)

	_configure_interaction(
		$NPCs/ShopOwner/InteractionTarget,
		["你好", "我是人", "你是誰"],
		[&"nihao", &"wo", &"shei"]
	)
	_configure_interaction(
		$NPCs/Assistant/InteractionTarget,
		["你好", "這是蘋果"],
		[&"nihao", &"pingguo"]
	)
	_configure_interaction(
		$NPCs/CustomerA/InteractionTarget,
		["你好"],
		[&"nihao"]
	)
	_configure_interaction(
		$NPCs/CustomerB/InteractionTarget,
		["你好", "這是茶"],
		[&"nihao", &"cha"]
	)
	_configure_interaction(
		$NPCs/CustomerC/InteractionTarget,
		["你好", "這是水"],
		[&"nihao", &"shui"]
	)

func _configure_shop_owner_interaction() -> void:
	var interaction_shape: CollisionShape2D = (
		$NPCs/ShopOwner/InteractionTarget/InteractionShape
	)
	var counter_reach := RectangleShape2D.new()
	counter_reach.size = SHOP_OWNER_INTERACTION_SIZE
	interaction_shape.position = SHOP_OWNER_INTERACTION_OFFSET
	interaction_shape.shape = counter_reach

func _configure_interaction(target: Area2D, lines: Array, vocab_ids: Array) -> void:
	if target.has_method("set_dialogue"):
		target.set_dialogue(lines, vocab_ids)

func _configure_npc(npc: Node, npc_name: String, npc_identity: String, random_walk: bool, words: Array, vocab_ids: Array, delay: float = 1.4, bounds: Rect2 = Rect2()) -> void:
	if npc.has_method("set_profile"):
		npc.set_profile(npc_name, npc_identity, random_walk, words, vocab_ids, delay, bounds)

func _create_notebook_button() -> void:
	var hud = CanvasLayer.new()
	hud.layer = 5
	add_child(hud)
	
	var base_control = Control.new()
	base_control.name = "HUDBase"
	base_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(base_control)
	
	var btn = Button.new()
	btn.text = "" # No text, icon only
	
	var icon_tex = load("res://Assets/Sprites/book_icon.png")
	if icon_tex is Texture2D:
		btn.icon = icon_tex
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	btn.custom_minimum_size = Vector2(48, 48)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 0.0
	btn.anchor_bottom = 0.0
	btn.offset_left = -64
	btn.offset_top = 16
	btn.offset_right = -16
	btn.offset_bottom = 64
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create circular styling
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.15, 0.15, 0.15, 0.7)
	style_normal.corner_radius_top_left = 24
	style_normal.corner_radius_top_right = 24
	style_normal.corner_radius_bottom_left = 24
	style_normal.corner_radius_bottom_right = 24
	style_normal.set_content_margin_all(0)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.25, 0.25, 0.25, 0.8)
	style_hover.corner_radius_top_left = 24
	style_hover.corner_radius_top_right = 24
	style_hover.corner_radius_bottom_left = 24
	style_hover.corner_radius_bottom_right = 24
	style_hover.set_content_margin_all(0)
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style_pressed.corner_radius_top_left = 24
	style_pressed.corner_radius_top_right = 24
	style_pressed.corner_radius_bottom_left = 24
	style_pressed.corner_radius_bottom_right = 24
	style_pressed.set_content_margin_all(0)
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_stylebox_override("focus", style_normal) # Keep same as normal on focus
	
	btn.pressed.connect(_on_notebook_button_pressed)
	base_control.add_child(btn)

func _on_notebook_button_pressed() -> void:
	var notebook = get_tree().get_first_node_in_group("notebook_ui")
	if notebook != null:
		if notebook.visible:
			notebook.close()
		else:
			notebook.open()
