extends Control
class_name SpellsTab

signal spell_challenge_requested(spell_id: StringName)

const SPELL_DIRECTORY := "res://Data/Spells"

@onready var spell_list: VBoxContainer = %SpellList
@onready var empty_label: Label = %EmptyLabel

var spell_patterns: Array[SpellPattern] = []
var _progression_manager: TocflProgressionManager
var _buttons_by_spell_id: Dictionary[StringName, Button] = {}

func _ready() -> void:
	_progression_manager = _find_progression_manager()
	_load_spell_patterns()
	if _progression_manager != null and not _progression_manager.level_unlocked.is_connected(_on_level_unlocked):
		_progression_manager.level_unlocked.connect(_on_level_unlocked)
	refresh()

func refresh() -> void:
	for child in spell_list.get_children():
		child.queue_free()
	_buttons_by_spell_id.clear()

	empty_label.visible = spell_patterns.is_empty()
	for pattern in spell_patterns:
		if pattern == null:
			continue
		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 56.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = "%s　%s" % [pattern.spell_name_chinese, _status_text(pattern)]
		button.disabled = not _can_challenge(pattern)
		button.tooltip_text = _status_text(pattern)
		button.pressed.connect(_on_spell_pressed.bind(pattern.spell_id))
		spell_list.add_child(button)
		_buttons_by_spell_id[pattern.spell_id] = button

func get_spell_button(spell_id: StringName) -> Button:
	return _buttons_by_spell_id.get(spell_id)

func _load_spell_patterns() -> void:
	spell_patterns.clear()
	var directory := DirAccess.open(SPELL_DIRECTORY)
	if directory == null:
		push_warning("Spell directory is missing: %s" % SPELL_DIRECTORY)
		return

	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".tres.remap")):
			var clean_name := file_name.trim_suffix(".remap")
			var pattern := load("%s/%s" % [SPELL_DIRECTORY, clean_name]) as SpellPattern
			if pattern != null:
				spell_patterns.append(pattern)
		file_name = directory.get_next()
	directory.list_dir_end()
	spell_patterns.sort_custom(func(a: SpellPattern, b: SpellPattern) -> bool: return a.spell_id < b.spell_id)

func _find_progression_manager() -> TocflProgressionManager:
	return get_tree().get_first_node_in_group("tocfl_progression_manager") as TocflProgressionManager

func _can_challenge(pattern: SpellPattern) -> bool:
	if _progression_manager == null:
		return false
	return not _is_level_locked(pattern) and not _progression_manager.is_spell_mastered(pattern.spell_id)

func _status_text(pattern: SpellPattern) -> String:
	if _progression_manager == null or _is_level_locked(pattern):
		return "等級不足"
	if _progression_manager.is_spell_mastered(pattern.spell_id):
		return "已掌握"
	return "未掌握，可挑戰"

func _is_level_locked(pattern: SpellPattern) -> bool:
	if _progression_manager == null:
		return true
	var required_index := TocflProgressionManager.LEVEL_ORDER.find(pattern.required_tocfl_level)
	var current_index := TocflProgressionManager.LEVEL_ORDER.find(_progression_manager.current_level)
	return required_index < 0 or current_index < 0 or required_index > current_index

func _on_spell_pressed(spell_id: StringName) -> void:
	var button := get_spell_button(spell_id)
	if button == null or button.disabled:
		return
	_record_event("spell_challenge_started", {"spell_id": String(spell_id)})
	spell_challenge_requested.emit(spell_id)

func _on_level_unlocked(_level: String) -> void:
	refresh()

func _record_event(event_name: String, properties: Dictionary) -> void:
	var telemetry_manager := get_node_or_null("/root/TelemetryManager")
	if telemetry_manager != null:
		telemetry_manager.record_event(event_name, properties)
