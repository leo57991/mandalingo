extends CanvasLayer
class_name NotebookUI

@onready var word_list: VBoxContainer = %WordList
@onready var close_button: Button = %CloseButton

var word_item_scene := preload("res://Scenes/UI/NotebookWordItem.tscn")
var _was_paused := false

func _ready() -> void:
	add_to_group("notebook_ui")
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	close_button.pressed.connect(close)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_J or event.is_action_pressed("ui_focus_next"):
			close()
			get_viewport().set_input_as_handled()

func open() -> void:
	if visible or _is_dialogue_active():
		return
	AudioManager.play_audio_file("res://Assets/SFX/notebook_flip.ogg")
	_was_paused = get_tree().paused
	visible = true
	get_tree().paused = true
	_populate_words()
	TelemetryManager.record_event("notebook_opened", {
		"visible_word_count": word_list.get_child_count(),
	})

func close() -> void:
	if not visible:
		return
	AudioManager.play_audio_file("res://Assets/SFX/notebook_flip.ogg")
	visible = false
	get_tree().paused = _was_paused

func _populate_words() -> void:
	# Clear existing
	for child in word_list.get_children():
		word_list.remove_child(child)
		child.queue_free()
	
	# Get all vocabulary resources
	var entries = VocabularyDatabase.entries.values()
	
	# Filter for only seen entries (only seen words float/appear in the list)
	var seen_entries = []
	for entry in entries:
		if entry.seen_count > 0:
			seen_entries.append(entry)
	
	# Sort them by id
	seen_entries.sort_custom(func(a, b): return a.id < b.id)
	
	for entry in seen_entries:
		var item = word_item_scene.instantiate()
		word_list.add_child(item)
		item.setup(entry)

func _is_dialogue_active() -> bool:
	if DialogueSystem.is_showing:
		return true
	for npc in get_tree().get_nodes_in_group("npc"):
		if "is_speaking" in npc and npc.is_speaking:
			return true
	return false
