extends RuneJudge
class_name WordToSentenceJudge

var spell_patterns: Array[SpellPattern] = []

func _init(patterns: Array[SpellPattern] = []) -> void:
	spell_patterns = patterns.duplicate()

func evaluate(sequence: Array[StringName]) -> RuneJudgeResult:
	for pattern in spell_patterns:
		if _matches_pattern(sequence, pattern):
			return RuneJudgeResult.new(
				true,
				pattern.spell_id,
				1.0,
				pattern.spell_name_english
			)
	return RuneJudgeResult.new(false, &"", 0.0, "Words do not match a known spell")

func _matches_pattern(sequence: Array[StringName], pattern: SpellPattern) -> bool:
	if pattern == null or not pattern.is_valid_pattern():
		return false
	if sequence.size() != pattern.slot_pattern.size():
		return false
	for index in sequence.size():
		var allowed_fillers := pattern.get_fillers(pattern.slot_pattern[index])
		if not allowed_fillers.has(sequence[index]) and not allowed_fillers.has(String(sequence[index])):
			return false
	return true
