extends RefCounted
class_name RuneJudge

func evaluate(_sequence: Array[StringName]) -> RuneJudgeResult:
	push_error("RuneJudge.evaluate() must be implemented by a concrete judge.")
	return RuneJudgeResult.new(false, &"", 0.0, "No judge implementation")
