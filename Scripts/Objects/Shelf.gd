extends StaticBody2D

@export var shelf_id: StringName
@export var object_vocab_id: StringName
@export var shelf_texture: Texture2D
@export var item_texture: Texture2D

@onready var interaction_target: Area2D = %InteractionTarget
@onready var object_hint: Label = %ObjectHint
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var item_sprite: Sprite2D = $ItemSprite

func _ready() -> void:
	add_to_group("vocabulary_shelf")
	refresh_context()
	
	if shelf_texture != null and sprite_2d != null:
		sprite_2d.texture = shelf_texture
		var tex_size = shelf_texture.get_size()
		if tex_size.x > 0:
			var scale_factor = 144.0 / tex_size.x
			sprite_2d.scale = Vector2(scale_factor, scale_factor)
			
	if item_texture != null and item_sprite != null:
		item_sprite.texture = item_texture
		var tex_size = item_texture.get_size()
		if tex_size.y > 0:
			var scale_factor = 32.0 / tex_size.y
			item_sprite.scale = Vector2(scale_factor, scale_factor)

func refresh_context() -> void:
	var word := VocabularyDatabase.get_chinese(object_vocab_id)
	if word.is_empty():
		word = String(object_vocab_id)

	object_hint.text = word
	interaction_target.display_name = String(shelf_id)
	if interaction_target.has_method("set_dialogue"):
		interaction_target.set_dialogue([word, word], [object_vocab_id, object_vocab_id])
	# TODO: Add contextual object animation, such as highlighting apples/tea/water.
