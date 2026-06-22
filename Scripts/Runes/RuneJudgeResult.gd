extends RefCounted
class_name RuneJudgeResult

var success: bool
var result_id: StringName
var confidence: float
var feedback: String

func _init(
	result_success: bool = false,
	resolved_id: StringName = &"",
	result_confidence: float = 0.0,
	result_feedback: String = ""
) -> void:
	success = result_success
	result_id = resolved_id
	confidence = clampf(result_confidence, 0.0, 1.0)
	feedback = result_feedback
