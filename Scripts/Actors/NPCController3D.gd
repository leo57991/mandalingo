extends StaticBody3D

@export var character_name := "小安"
@export var identity := "店員"
@export var speech_delay := 2.2

@onready var speech_bubble: Node3D = %SpeechBubble
@onready var speech_label: Label3D = %SpeechLabel

var is_speaking := false

func _ready() -> void:
	add_to_group("npc")
	speech_bubble.hide()

func can_start_dialogue() -> bool:
	return not is_speaking

func say(lines: Array, vocab_ids: Array = []) -> void:
	if lines.is_empty() or is_speaking:
		return
	_say_sequence(lines, vocab_ids)

func _say_sequence(lines: Array, vocab_ids: Array) -> void:
	is_speaking = true
	for index in lines.size():
		var vocab_id := StringName(vocab_ids[index]) if index < vocab_ids.size() else &""
		speech_label.text = String(lines[index])
		speech_bubble.show()
		if not String(vocab_id).is_empty():
			VocabularyDatabase.mark_seen_from_dialogue(vocab_id, character_name)
			AudioManager.play_vocabulary(vocab_id, character_name)
		await get_tree().create_timer(speech_delay).timeout
	speech_bubble.hide()
	is_speaking = false
