extends StaticBody2D

@export var shelf_id: StringName
@export var object_vocab_id: StringName
@export var shelf_texture: Texture2D:
	set(val):
		shelf_texture = val
		_update_shelf_sprite()

@export var item_texture: Texture2D:
	set(val):
		item_texture = val
		_update_item_sprite()

@onready var interaction_target: Area2D = %InteractionTarget
@onready var object_hint: Label = %ObjectHint
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var item_sprites: Array[Sprite2D] = [
	$ItemLeft,
	$ItemCenter,
	$ItemRight,
]

func _ready() -> void:
	add_to_group("vocabulary_shelf")
	refresh_context()
	_update_shelf_sprite()
	_update_item_sprite()

func _update_shelf_sprite() -> void:
	var placeholder = get_node_or_null("PlaceholderShelf")
	if placeholder != null:
		placeholder.visible = shelf_texture == null

	sprite_2d.texture = shelf_texture
	sprite_2d.visible = shelf_texture != null

func _update_item_sprite() -> void:
	if not is_node_ready():
		return

	for item_sprite in item_sprites:
		item_sprite.texture = item_texture
		item_sprite.visible = item_texture != null

func refresh_context() -> void:
	var word := VocabularyDatabase.get_chinese(object_vocab_id)
	# Hide the hint label — no text visible until player interacts
	object_hint.visible = false
	
	var shelf_name := String(shelf_id)
	if shelf_id == &"shelf_apples":
		shelf_name = "蘋果貨架"
	elif shelf_id == &"shelf_tea":
		shelf_name = "茶葉貨架"
	elif shelf_id == &"shelf_water":
		shelf_name = "水貨架"
		
	interaction_target.display_name = shelf_name
	if interaction_target.has_method("set_dialogue") and not word.is_empty():
		interaction_target.set_dialogue([word, word], [[object_vocab_id], [object_vocab_id]])
