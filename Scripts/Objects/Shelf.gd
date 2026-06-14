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
	# Demo mode: show placeholder, don't load art sprite
	var placeholder = get_node_or_null("PlaceholderShelf")
	if placeholder != null:
		placeholder.visible = true

func _update_item_sprite() -> void:
	# Demo mode: don't load item art sprite
	pass

func refresh_context() -> void:
	var word := VocabularyDatabase.get_chinese(object_vocab_id)
	# Hide the hint label — no text visible until player interacts
	object_hint.visible = false
	interaction_target.display_name = String(shelf_id)
	if interaction_target.has_method("set_dialogue") and not word.is_empty():
		interaction_target.set_dialogue([word, word], [object_vocab_id, object_vocab_id])
