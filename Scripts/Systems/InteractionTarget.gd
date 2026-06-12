extends Area2D
class_name InteractionTarget

@export var display_name: String = ""
@export var lines: Array = []
@export var vocab_ids: Array = []
@export var auto_speak_on_enter: bool = false

var can_interact := true
var player_nearby := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact() -> void:
	if not can_interact:
		return
	var speaker := get_parent()
	if speaker != null and speaker.has_method("say"):
		speaker.say(lines, vocab_ids)
		return
	DialogueSystem.show_lines(lines, vocab_ids)

func set_dialogue(new_lines: Array, new_vocab_ids: Array = []) -> void:
	lines = new_lines
	vocab_ids = new_vocab_ids

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if auto_speak_on_enter:
			interact()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
