extends RuneJudge
class_name CharToWordJudge

var word_sequences: Dictionary = {}
var _lookup: Dictionary = {}

func _init(sequences: Dictionary = {}) -> void:
	word_sequences = sequences.duplicate(true)
	for vocab_id: Variant in word_sequences:
		var expected: Variant = word_sequences[vocab_id]
		if expected is Array:
			_lookup[_sequence_key(expected)] = StringName(vocab_id)

func evaluate(sequence: Array[StringName]) -> RuneJudgeResult:
	var vocab_id: StringName = _lookup.get(_sequence_key(sequence), &"")
	if not vocab_id.is_empty():
		return RuneJudgeResult.new(true, vocab_id, 1.0, "Word formed")
	return RuneJudgeResult.new(false, &"", 0.0, "Characters do not form a known word")

func _sequence_key(sequence: Array) -> String:
	var parts := PackedStringArray()
	for value: Variant in sequence:
		parts.append(String(value))
	return "|".join(parts)
