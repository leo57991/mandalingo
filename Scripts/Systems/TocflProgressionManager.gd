extends Node
class_name TocflProgressionManager

signal level_unlocked(level: String)

const LEVEL_ORDER: Array[String] = [
	"Prep1", "Prep2", "A1", "A2", "B1", "B2", "C1", "C2",
]
const LEVEL_UP_THRESHOLD := 0.6

@export var spell_patterns: Array[SpellPattern] = []
var current_level := "Prep1"
var _mastered_spell_ids: Array[StringName] = []

func _ready() -> void:
	add_to_group("tocfl_progression_manager")

func record_spell_success(spell_id: StringName) -> bool:
	if spell_id.is_empty() or _mastered_spell_ids.has(spell_id):
		return false
	_mastered_spell_ids.append(spell_id)
	return _check_level_up()

func is_spell_mastered(spell_id: StringName) -> bool:
	return _mastered_spell_ids.has(spell_id)

func get_level_progress(level: String = current_level) -> float:
	var level_spell_ids := _get_spell_ids_for_level(level)
	if level_spell_ids.is_empty():
		return 0.0
	var mastered_count := 0
	for spell_id in level_spell_ids:
		if _mastered_spell_ids.has(spell_id):
			mastered_count += 1
	return float(mastered_count) / float(level_spell_ids.size())

func _check_level_up() -> bool:
	if get_level_progress() < LEVEL_UP_THRESHOLD:
		return false
	var level_index := LEVEL_ORDER.find(current_level)
	if level_index < 0 or level_index >= LEVEL_ORDER.size() - 1:
		return false
	var previous_level := current_level
	current_level = LEVEL_ORDER[level_index + 1]
	level_unlocked.emit(current_level)
	var data_manager := get_node_or_null("/root/DataManager")
	if data_manager != null:
		data_manager.record_player_event("tocfl_level_unlocked", {
			"context": {"previous_level": previous_level},
			"details": {
				"level": current_level,
				"threshold": LEVEL_UP_THRESHOLD,
			},
		})
	else:
		push_warning("TocflProgressionManager could not record the level unlock because DataManager is unavailable.")
	return true

func _get_spell_ids_for_level(level: String) -> Array[StringName]:
	var result: Array[StringName] = []
	for pattern in spell_patterns:
		if pattern != null and pattern.tocfl_level == level and not result.has(pattern.spell_id):
			result.append(pattern.spell_id)
	return result
