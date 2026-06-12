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
@onready var item_sprite: Sprite2D = $ItemSprite

func _ready() -> void:
	add_to_group("vocabulary_shelf")
	refresh_context()
	_update_shelf_sprite()
	_update_item_sprite()

func _update_shelf_sprite() -> void:
	var s2d = get_node_or_null("Sprite2D")
	if s2d != null and shelf_texture != null:
		s2d.texture = shelf_texture
		var tex_size = shelf_texture.get_size()
		if tex_size.x > 0:
			var scale_factor = 144.0 / tex_size.x
			s2d.scale = Vector2(scale_factor, scale_factor)

func _update_item_sprite() -> void:
	var isprite = get_node_or_null("ItemSprite")
	if isprite != null and item_texture != null:
		isprite.texture = item_texture
		var tex_size = item_texture.get_size()
		if tex_size.y > 0:
			var scale_factor = 32.0 / tex_size.y
			isprite.scale = Vector2(scale_factor, scale_factor)

func refresh_context() -> void:
	var word := VocabularyDatabase.get_chinese(object_vocab_id)
	if word.is_empty():
		word = String(object_vocab_id)

	object_hint.text = word
	interaction_target.display_name = String(shelf_id)
	if interaction_target.has_method("set_dialogue"):
		interaction_target.set_dialogue([word, word], [object_vocab_id, object_vocab_id])
	# TODO: Add contextual object animation, such as highlighting apples/tea/water.
