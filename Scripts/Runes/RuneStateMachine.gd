extends Node
class_name RuneStateMachine

signal state_changed(previous_state: State, current_state: State)
signal judgement_completed(result: RuneJudgeResult)

enum State {
	IDLE,
	COLLECTING,
	JUDGING,
	SUCCESS,
	FAILURE,
}

var state: State = State.IDLE
var current_judge: RuneJudge
var current_context: Dictionary = {}

func begin_input(judge: RuneJudge, context: Dictionary = {}) -> bool:
	if judge == null or state != State.IDLE:
		return false
	current_judge = judge
	current_context = context.duplicate(true)
	_transition_to(State.COLLECTING)
	return true

func submit_input(sequence: Array[StringName]) -> RuneJudgeResult:
	if state != State.COLLECTING or current_judge == null:
		return RuneJudgeResult.new(false, &"", 0.0, "Rune input is not active")

	_transition_to(State.JUDGING)
	var result := current_judge.evaluate(sequence)
	_transition_to(State.SUCCESS if result.success else State.FAILURE)
	_record_judgement(sequence, result)
	judgement_completed.emit(result)
	_reset()
	return result

func cancel_input() -> void:
	if state != State.IDLE:
		_reset()

func _record_judgement(sequence: Array[StringName], result: RuneJudgeResult) -> void:
	var data_manager := get_node_or_null("/root/DataManager")
	if data_manager == null:
		push_warning("RuneStateMachine could not record events because DataManager is unavailable.")
		return
	var serialized_sequence: Array[String] = []
	for value in sequence:
		serialized_sequence.append(String(value))
	var details := {
		"sequence": serialized_sequence,
		"success": result.success,
		"result_id": String(result.result_id),
		"confidence": result.confidence,
	}
	data_manager.record_player_event("rune_judgement", {
		"vocab_id": String(result.result_id),
		"location": String(current_context.get("location", "")),
		"context": current_context,
		"details": details,
	})
	if result.success:
		data_manager.record_player_event("rune_spell_success", {
			"vocab_id": String(result.result_id),
			"location": String(current_context.get("location", "")),
			"context": current_context,
			"details": details,
		})

func _reset() -> void:
	current_judge = null
	current_context.clear()
	_transition_to(State.IDLE)

func _transition_to(next_state: State) -> void:
	if state == next_state:
		return
	var previous_state := state
	state = next_state
	state_changed.emit(previous_state, state)
