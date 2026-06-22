extends RefCounted
class_name InteractableReactionMatcher

static func build_lookup(reactions: Array[InteractableReaction]) -> Dictionary:
	var lookup: Dictionary = {}
	for reaction: InteractableReaction in reactions:
		if reaction == null or reaction.trigger_sequence.is_empty():
			continue
		lookup[_sequence_key(reaction.trigger_sequence)] = reaction
	return lookup

static func match(
	submitted: Array[StringName],
	lookup: Dictionary
) -> InteractableReaction:
	return lookup.get(_sequence_key(submitted), null) as InteractableReaction

static func build_fallback_log(
	submitted: Array[StringName],
	vocab_db: Node,
	template: String
) -> String:
	var element := "Unknown"
	if not submitted.is_empty():
		element = String(submitted[0])
		if vocab_db != null:
			var entry := vocab_db.entries.get(submitted[0], null) as VocabularyEntry
			if entry != null and not entry.english_internal.is_empty():
				element = entry.english_internal
	return template.replace("{element}", element)

static func _sequence_key(sequence: Array[StringName]) -> String:
	var parts := PackedStringArray()
	for value: StringName in sequence:
		parts.append(String(value))
	return "|".join(parts)
