extends Node2D

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
				
	# Show placeholder visuals for counter
	var counter_placeholder = get_node_or_null("Counter/CounterVisual")
	if counter_placeholder is Polygon2D:
		counter_placeholder.visible = true

	_configure_shelves()
	_configure_npcs()

	# Instantiate NotebookUI dynamically
	var notebook_scene = load("res://Scenes/UI/NotebookUI.tscn")
	if notebook_scene != null:
		var notebook_instance = notebook_scene.instantiate()
		add_child(notebook_instance)

	# Create notebook open button (HUD)
	_create_notebook_button()

func _configure_shelves() -> void:
	# Show placeholder visuals for shelves (no art textures)
	for shelf in get_tree().get_nodes_in_group("vocabulary_shelf"):
		if shelf.has_method("refresh_context"):
			shelf.refresh_context()

func _configure_npcs() -> void:
	_configure_npc(
		$NPCs/ShopOwner,
		"林阿姨",
		"店長",
		false,
		["你好", "蘋果", "茶", "水"],
		[&"nihao", &"pingguo", &"cha", &"shui"]
	)
	_configure_npc(
		$NPCs/Assistant,
		"小安",
		"店員",
		true,
		["蘋果", "茶", "水", "蘋果"],
		[&"pingguo", &"cha", &"shui", &"pingguo"]
	)
	_configure_npc(
		$NPCs/CustomerA,
		"美美",
		"客人",
		true,
		["蘋果", "蘋果"],
		[&"pingguo", &"pingguo"]
	)
	_configure_npc(
		$NPCs/CustomerB,
		"阿明",
		"客人",
		true,
		["茶", "你好", "茶"],
		[&"cha", &"nihao", &"cha"]
	)
	_configure_npc(
		$NPCs/CustomerC,
		"小雨",
		"客人",
		true,
		["水", "你", "水"],
		[&"shui", &"ni", &"shui"]
	)

	_configure_interaction(
		$NPCs/ShopOwner/InteractionTarget,
		["你好", "我是人", "你是誰"],
		[&"nihao", &"wo", &"shei"]
	)
	_configure_interaction(
		$NPCs/Assistant/InteractionTarget,
		["蘋果", "茶", "水", "蘋果"],
		[&"pingguo", &"cha", &"shui", &"pingguo"]
	)
	_configure_interaction(
		$NPCs/CustomerA/InteractionTarget,
		["蘋果", "蘋果"],
		[&"pingguo", &"pingguo"]
	)
	_configure_interaction(
		$NPCs/CustomerB/InteractionTarget,
		["茶", "你好", "茶"],
		[&"cha", &"nihao", &"cha"]
	)
	_configure_interaction(
		$NPCs/CustomerC/InteractionTarget,
		["水", "你", "水"],
		[&"shui", &"ni", &"shui"]
	)

func _configure_interaction(target: Area2D, lines: Array, vocab_ids: Array) -> void:
	if target.has_method("set_dialogue"):
		target.set_dialogue(lines, vocab_ids)

func _configure_npc(npc: Node, npc_name: String, npc_identity: String, random_walk: bool, words: Array, vocab_ids: Array) -> void:
	if npc.has_method("set_profile"):
		npc.set_profile(npc_name, npc_identity, random_walk, words, vocab_ids)

func _create_notebook_button() -> void:
	var hud = CanvasLayer.new()
	hud.layer = 5
	add_child(hud)
	
	var btn = Button.new()
	btn.text = "📖 筆記本"
	btn.custom_minimum_size = Vector2(120, 40)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 0.0
	btn.anchor_bottom = 0.0
	btn.offset_left = -140
	btn.offset_top = 16
	btn.offset_right = -16
	btn.offset_bottom = 56
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.pressed.connect(_on_notebook_button_pressed)
	hud.add_child(btn)

func _on_notebook_button_pressed() -> void:
	var notebook = get_tree().get_first_node_in_group("notebook_ui")
	if notebook != null:
		if notebook.visible:
			notebook.close()
		else:
			notebook.open()
