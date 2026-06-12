extends StaticBody2D

@export var shelf_id: StringName
@export var object_vocab_id: StringName

@onready var interaction_target: Area2D = %InteractionTarget
@onready var object_hint: Label = %ObjectHint

func _ready() -> void:
	add_to_group("vocabulary_shelf")
	refresh_context()

func refresh_context() -> void:
	var word := VocabularyDatabase.get_chinese(object_vocab_id)
	if word.is_empty():
		word = String(object_vocab_id)

	object_hint.text = word
	interaction_target.display_name = String(shelf_id)
	if interaction_target.has_method("set_dialogue"):
		interaction_target.set_dialogue([word, word], [object_vocab_id, object_vocab_id])
	# TODO: Add contextual object animation, such as highlighting apples/tea/water.
