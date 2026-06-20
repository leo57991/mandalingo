extends RuneJudge
class_name CharToWordJudge

var word_sequences: Dictionary = {}

func _init(sequences: Dictionary = {}) -> void:
	word_sequences = sequences.duplicate(true)

func evaluate(sequence: Array[StringName]) -> RuneJudgeResult:
	for vocab_id: Variant in word_sequences:
		var expected: Variant = word_sequences[vocab_id]
		if expected is Array and _sequences_match(sequence, expected):
			return RuneJudgeResult.new(true, StringName(vocab_id), 1.0, "Word formed")
	return RuneJudgeResult.new(false, &"", 0.0, "Characters do not form a known word")

func _sequences_match(actual: Array[StringName], expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in actual.size():
		if actual[index] != StringName(expected[index]):
			return false
	return true
