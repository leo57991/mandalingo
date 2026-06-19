extends Area3D
class_name InteractionTarget3D

@export var display_name := ""
@export var lines: Array[String] = []
@export var vocab_ids: Array[StringName] = []

func interact() -> void:
	var speaker := get_parent()
	if speaker != null and speaker.has_method("can_start_dialogue") and not speaker.can_start_dialogue():
		return

	var target_kind := "npc" if speaker != null and speaker.has_method("say") else "object"
	var telemetry_name := display_name
	if target_kind == "npc" and "character_name" in speaker:
		telemetry_name = speaker.character_name
	TelemetryManager.track_interaction(telemetry_name, target_kind, vocab_ids)

	if speaker != null and speaker.has_method("say"):
		speaker.say(lines, vocab_ids)
		return
	DialogueSystem.show_lines(lines, vocab_ids, display_name)
