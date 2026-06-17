extends CanvasLayer

signal sequence_finished

var popup: PanelContainer
var active_lines: Array = []
var active_vocab_ids: Array = []
var line_index := 0
var is_showing := false
var active_location: String = ""

func _ready() -> void:
	layer = 15
	var popup_scene := preload("res://Scenes/UI/DialoguePopup.tscn")
	popup = popup_scene.instantiate()
	add_child(popup)
	popup.hide()

func show_lines(lines: Array, vocab_ids: Array = [], location: String = "") -> void:
	if lines.is_empty():
		return

	active_lines = lines
	active_vocab_ids = vocab_ids
	active_location = location
	line_index = 0
	is_showing = true
	_show_current_line()

func advance() -> void:
	if not is_showing:
		return

	line_index += 1
	if line_index >= active_lines.size():
		hide_dialogue()
		sequence_finished.emit()
		return

	_show_current_line()

func hide_dialogue() -> void:
	is_showing = false
	active_lines.clear()
	active_vocab_ids.clear()
	active_location = ""
	line_index = 0
	if popup != null:
		popup.hide()

func _show_current_line() -> void:
	var text := String(active_lines[line_index])
	var line_vocab_ids := _get_line_vocab_ids(line_index)
	var primary_vocab_id := _get_primary_vocab_id(line_vocab_ids)

	if popup != null:
		popup.show_chinese(text)

	VocabularyDatabase.mark_many_seen_from_dialogue(line_vocab_ids, active_location)
	if not String(primary_vocab_id).is_empty():
		AudioManager.play_vocabulary(primary_vocab_id, active_location)

func _get_line_vocab_ids(index: int) -> Array:
	if index >= active_vocab_ids.size():
		return []

	var raw_ids = active_vocab_ids[index]
	if raw_ids is Array:
		return raw_ids
	if String(raw_ids).is_empty():
		return []
	return [StringName(raw_ids)]

func _get_primary_vocab_id(ids: Array) -> StringName:
	if ids.is_empty():
		return &""
	return StringName(ids[ids.size() - 1])
