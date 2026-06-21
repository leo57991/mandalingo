extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var telemetry_manager: Node = root.get_node("TelemetryManager")
	var original_consent: String = telemetry_manager.consent_state
	var original_session_started: bool = telemetry_manager._session_started
	telemetry_manager.consent_state = telemetry_manager.CONSENT_ACCEPTED
	telemetry_manager._session_started = true

	var recorded_events: Array[String] = []
	var event_listener := func(payload: Dictionary) -> void:
		recorded_events.append(String(payload.get("event_name", "")))
	telemetry_manager.event_recorded.connect(event_listener)

	var packed_scene := load("res://Scenes/UI/StatusMenuUI.tscn") as PackedScene
	var menu := packed_scene.instantiate() as StatusMenuUI
	root.add_child(menu)
	await process_frame

	var tab_container := menu.get_node("Control/PanelContainer/MarginContainer/VBoxContainer/TabContainer") as TabContainer
	var equipment_tab := tab_container.get_child(0) as EquipmentTab
	var stats_tab := tab_container.get_child(1) as StatsTab
	var spells_tab := tab_container.get_child(2) as SpellsTab
	var progression := menu.get_node("TocflProgressionManager") as TocflProgressionManager

	_expect(not menu.visible, "Status menu starts hidden")
	_expect(tab_container.get_tab_count() == 3, "Status menu has three independent tabs")
	_expect(equipment_tab.placeholder_label.text == "裝備系統開發中", "Equipment tab is an explicit placeholder")
	_expect(stats_tab.placeholder_label.text == "屬性系統開發中", "Stats tab is an explicit placeholder")

	var inventory_key := InputEventKey.new()
	inventory_key.keycode = KEY_I
	inventory_key.pressed = true
	menu._unhandled_input(inventory_key)
	_expect(menu.visible and paused, "I opens the status menu and pauses the game")
	_expect(recorded_events.has("status_menu_opened"), "Opening records telemetry")

	tab_container.current_tab = 2
	await process_frame
	_expect(recorded_events.has("status_menu_tab_changed"), "Changing tabs records telemetry")

	var spell_button := spells_tab.get_spell_button(&"identify_apple")
	_expect(spell_button != null and not spell_button.disabled, "Current-level unmastered spell is challengeable")
	_expect("未掌握，可挑戰" in spell_button.text, "Challengeable spell shows its status")

	var requested_spells: Array[StringName] = []
	spells_tab.spell_challenge_requested.connect(
		func(spell_id: StringName) -> void: requested_spells.append(spell_id)
	)
	spell_button.pressed.emit()
	_expect(requested_spells == [&"identify_apple"], "Spell click emits the challenge request")
	_expect(recorded_events.has("spell_challenge_started"), "Spell click records telemetry")

	progression.record_spell_success(&"identify_apple")
	spells_tab.refresh()
	spell_button = spells_tab.get_spell_button(&"identify_apple")
	_expect(spell_button.disabled and "已掌握" in spell_button.text, "Mastered spell cannot be challenged again")

	var locked_pattern := SpellPattern.new()
	locked_pattern.spell_id = &"locked_test_spell"
	locked_pattern.spell_name_chinese = "封印術"
	locked_pattern.tocfl_level = "A1"
	spells_tab.spell_patterns.append(locked_pattern)
	spells_tab.refresh()
	var locked_button := spells_tab.get_spell_button(&"locked_test_spell")
	_expect(locked_button.disabled and "等級不足" in locked_button.text, "Higher-level spell is locked")

	menu._unhandled_input(inventory_key)
	_expect(not menu.visible and not paused, "I closes the menu and restores the previous pause state")
	_expect(recorded_events.has("status_menu_closed"), "Closing records telemetry")

	telemetry_manager.event_recorded.disconnect(event_listener)
	telemetry_manager.consent_state = original_consent
	telemetry_manager._session_started = original_session_started
	menu.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		failures.append(description)
		push_error("FAIL: %s" % description)

func _finish() -> void:
	if failures.is_empty():
		print("Status menu test passed.")
		quit(0)
		return
	print("Status menu test failed (%d): %s" % [failures.size(), failures])
	quit(1)
