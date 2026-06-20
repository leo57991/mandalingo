extends Resource
class_name SpellPattern

@export var spell_id: StringName
@export var spell_name_chinese: String
@export var spell_name_english: String
@export_enum("Prep1", "Prep2", "A1", "A2", "B1", "B2", "C1", "C2") var required_tocfl_level: String = "Prep1"
@export var slot_pattern: Array[StringName] = []
@export var slot_fillers: Dictionary = {}

func is_valid_pattern() -> bool:
	if spell_id.is_empty() or slot_pattern.is_empty():
		return false
	for slot_name in slot_pattern:
		var fillers: Variant = _get_fillers(slot_name)
		if not fillers is Array or fillers.is_empty():
			return false
	return true

func get_fillers(slot_name: StringName) -> Array:
	var fillers: Variant = _get_fillers(slot_name)
	return fillers if fillers is Array else []

func _get_fillers(slot_name: StringName) -> Variant:
	if slot_fillers.has(slot_name):
		return slot_fillers[slot_name]
	return slot_fillers.get(String(slot_name), [])
