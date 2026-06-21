extends CanvasLayer
class_name StatusMenuUI

signal opened
signal closed

@onready var tab_container: TabContainer = %TabContainer
@onready var close_button: Button = %CloseButton

var _was_paused := false

func _ready() -> void:
	add_to_group("status_menu_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	close_button.pressed.connect(close)
	tab_container.tab_changed.connect(_on_tab_changed)
	tab_container.set_tab_title(0, "裝備")
	tab_container.set_tab_title(1, "屬性")
	tab_container.set_tab_title(2, "法術")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_I:
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()

func open() -> void:
	if visible:
		return
	_was_paused = get_tree().paused
	visible = true
	get_tree().paused = true
	_record_event("status_menu_opened", {})
	opened.emit()

func close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = _was_paused
	_record_event("status_menu_closed", {})
	closed.emit()

func _on_tab_changed(tab_index: int) -> void:
	if not visible or tab_index < 0 or tab_index >= tab_container.get_tab_count():
		return
	_record_event("status_menu_tab_changed", {
		"tab_name": tab_container.get_tab_title(tab_index),
	})

func _record_event(event_name: String, properties: Dictionary) -> void:
	var telemetry_manager := get_node_or_null("/root/TelemetryManager")
	if telemetry_manager != null:
		telemetry_manager.record_event(event_name, properties)
