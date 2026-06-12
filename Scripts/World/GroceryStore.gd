extends Node2D

func _ready() -> void:
	# TODO: Add ambient store audio once audio direction exists.
	# TODO: Add playtest logging for voluntary repeated interactions.
	_configure_shelves()
	_configure_npcs()

func _configure_shelves() -> void:
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
