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
	var vocab_id := StringName()
	if line_index < active_vocab_ids.size():
		vocab_id = StringName(active_vocab_ids[line_index])

	if popup != null:
		popup.show_chinese(text)

	# Scan the displayed dialogue line for any Chinese characters to auto-discover them
	VocabularyDatabase.discover_words_in_text(text, active_location, vocab_id)

	if not String(vocab_id).is_empty():
		AudioManager.play_vocabulary(vocab_id, active_location)
