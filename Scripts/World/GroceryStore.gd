extends Node2D

func _ready() -> void:
	# Load and setup floor visual
	var floor_sprite = get_node_or_null("Floor")
	if floor_sprite is Sprite2D:
		var tex = preload("res://Assets/Sprites/floor.png")
		if tex is Texture2D:
			floor_sprite.texture = tex
			var tex_size = tex.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				floor_sprite.scale = Vector2(720.0 / tex_size.x, 480.0 / tex_size.y)
				
	# Load and setup counter visual
	var counter_sprite = get_node_or_null("Counter/CounterVisual")
	if counter_sprite is Sprite2D:
		var tex = preload("res://Assets/Sprites/counter.png")
		if tex is Texture2D:
			counter_sprite.texture = tex
			var tex_size = tex.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				counter_sprite.scale = Vector2(120.0 / tex_size.x, 250.0 / tex_size.y)

	_configure_shelves()
	_configure_npcs()

	# Instantiate NotebookUI dynamically
	var notebook_scene = load("res://Scenes/UI/NotebookUI.tscn")
	if notebook_scene != null:
		var notebook_instance = notebook_scene.instantiate()
		add_child(notebook_instance)

func _configure_shelves() -> void:
	var shelf_apples = get_node_or_null("Shelves/ShelfApples")
	if shelf_apples != null:
		shelf_apples.shelf_texture = preload("res://Assets/Sprites/shelf_a.png")
		shelf_apples.item_texture = preload("res://Assets/Sprites/apple.png")
		
	var shelf_tea = get_node_or_null("Shelves/ShelfTea")
	if shelf_tea != null:
		shelf_tea.shelf_texture = preload("res://Assets/Sprites/shelf_a.png")
		shelf_tea.item_texture = preload("res://Assets/Sprites/tea.png")
		
	var shelf_water = get_node_or_null("Shelves/ShelfWater")
	if shelf_water != null:
		shelf_water.shelf_texture = preload("res://Assets/Sprites/shelf_a.png")
		shelf_water.item_texture = preload("res://Assets/Sprites/water.png")

	for shelf in get_tree().get_nodes_in_group("vocabulary_shelf"):
		if shelf.has_method("refresh_context"):
			shelf.refresh_context()

func _configure_npcs() -> void:
	# Assign textures
	var shop_owner = get_node_or_null("NPCs/ShopOwner")
	if shop_owner != null:
		shop_owner.sprite_texture = preload("res://Assets/Sprites/shop_owner.png")
		
	var assistant = get_node_or_null("NPCs/Assistant")
	if assistant != null:
		assistant.sprite_texture = preload("res://Assets/Sprites/assistant.png")
		
	var customer_a = get_node_or_null("NPCs/CustomerA")
	if customer_a != null:
		customer_a.sprite_texture = preload("res://Assets/Sprites/customer_a.png")
		
	var customer_b = get_node_or_null("NPCs/CustomerB")
	if customer_b != null:
		customer_b.sprite_texture = preload("res://Assets/Sprites/customer_b.png")
		
	var customer_c = get_node_or_null("NPCs/CustomerC")
	if customer_c != null:
		customer_c.sprite_texture = preload("res://Assets/Sprites/customer_c.png")

	_configure_npc(
		shop_owner,
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
