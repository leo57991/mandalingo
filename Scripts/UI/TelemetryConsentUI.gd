extends CanvasLayer

var _was_paused := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	if not TelemetryManager.should_prompt_for_consent():
		queue_free()
		return

	_was_paused = get_tree().paused
	get_tree().paused = true
	_build_interface()

func _build_interface() -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.03, 0.03, 0.04, 0.82)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-250, -145)
	panel.size = Vector2(500, 290)
	overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Anonymous playtest data"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	content.add_child(title)

	var description := Label.new()
	description.text = (
		"Help improve this language-learning prototype by sharing anonymous gameplay events.\n\n"
		+ "We record interactions, words encountered, timing, and whether a notebook guess was entered. "
		+ "We do not send the guess text, your name, email, or browsing history."
	)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(440, 120)
	content.add_child(description)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	content.add_child(buttons)

	var decline_button := Button.new()
	decline_button.text = "No thanks"
	decline_button.custom_minimum_size = Vector2(150, 44)
	decline_button.pressed.connect(_on_consent_selected.bind(false))
	buttons.add_child(decline_button)

	var accept_button := Button.new()
	accept_button.text = "Share anonymous data"
	accept_button.custom_minimum_size = Vector2(210, 44)
	accept_button.pressed.connect(_on_consent_selected.bind(true))
	buttons.add_child(accept_button)

func _on_consent_selected(accepted: bool) -> void:
	TelemetryManager.set_consent(accepted)
	get_tree().paused = _was_paused
	queue_free()
