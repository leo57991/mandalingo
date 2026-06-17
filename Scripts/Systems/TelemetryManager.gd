extends Node

signal event_recorded(payload: Dictionary)

const CONSENT_FILE := "user://telemetry_consent.cfg"
const CONSENT_SECTION := "telemetry"
const CONSENT_KEY := "consent"
const CONSENT_UNKNOWN := "unknown"
const CONSENT_ACCEPTED := "accepted"
const CONSENT_DECLINED := "declined"

var session_id := ""
var session_started_at_msec := 0
var consent_state := CONSENT_UNKNOWN
var _session_started := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	session_id = _create_session_id()
	session_started_at_msec = Time.get_ticks_msec()
	consent_state = _load_consent()
	if is_configured() and consent_state == CONSENT_ACCEPTED:
		call_deferred("_start_session")

func is_configured() -> bool:
	return bool(ProjectSettings.get_setting("telemetry/enabled", false)) and not _endpoint_url().is_empty()

func should_prompt_for_consent() -> bool:
	return is_configured() and consent_state == CONSENT_UNKNOWN

func set_consent(accepted: bool) -> void:
	consent_state = CONSENT_ACCEPTED if accepted else CONSENT_DECLINED
	_save_consent()
	if accepted:
		_start_session()

func record_event(event_name: String, properties: Dictionary = {}) -> void:
	if not is_configured() or consent_state != CONSENT_ACCEPTED:
		return
	if not _session_started and event_name != "session_start":
		_start_session()

	var payload := {
		"schema_version": 1,
		"source": "mandalingo",
		"build_id": String(ProjectSettings.get_setting("telemetry/build_id", "prototype-v0.1")),
		"session_id": session_id,
		"client_timestamp": Time.get_datetime_string_from_system(true),
		"elapsed_ms": Time.get_ticks_msec() - session_started_at_msec,
		"event_name": event_name,
		"properties": properties,
	}
	event_recorded.emit(payload)
	_send_web_event(payload)

func track_interaction(target_name: String, target_kind: String, vocab_ids: Array) -> void:
	var ids: Array[String] = []
	_collect_vocab_ids(vocab_ids, ids)
	record_event("interaction", {
		"target": target_name,
		"target_kind": target_kind,
		"vocab_ids": ids,
	})

func _collect_vocab_ids(raw_ids: Array, output: Array[String]) -> void:
	for vocab_id in raw_ids:
		if vocab_id is Array:
			_collect_vocab_ids(vocab_id, output)
		elif not String(vocab_id).is_empty():
			output.append(String(vocab_id))

func track_vocabulary_seen(vocab_id: StringName, seen_count: int, location: String) -> void:
	record_event("vocabulary_seen", {
		"vocab_id": String(vocab_id),
		"seen_count": seen_count,
		"location": location,
	})

func track_guess_updated(vocab_id: StringName, guess_length: int, has_guess: bool) -> void:
	record_event("guess_updated", {
		"vocab_id": String(vocab_id),
		"guess_length": guess_length,
		"has_guess": has_guess,
	})

func _start_session() -> void:
	if _session_started or not is_configured() or consent_state != CONSENT_ACCEPTED:
		return
	_session_started = true
	record_event("session_start", {
		"consent_version": int(ProjectSettings.get_setting("telemetry/consent_version", 1)),
	})

func _send_web_event(payload: Dictionary) -> void:
	if not OS.has_feature("web"):
		return

	var payload_text := JSON.stringify(payload)
	var script := "navigator.sendBeacon(%s, %s);" % [
		JSON.stringify(_endpoint_url()),
		JSON.stringify(payload_text),
	]
	JavaScriptBridge.eval(script, true)

func _endpoint_url() -> String:
	return String(ProjectSettings.get_setting("telemetry/endpoint_url", "")).strip_edges()

func _create_session_id() -> String:
	var random := RandomNumberGenerator.new()
	random.randomize()
	return "%s-%08x-%08x" % [
		Time.get_unix_time_from_system(),
		random.randi(),
		random.randi(),
	]

func _load_consent() -> String:
	var config := ConfigFile.new()
	if config.load(CONSENT_FILE) != OK:
		return CONSENT_UNKNOWN
	return String(config.get_value(CONSENT_SECTION, CONSENT_KEY, CONSENT_UNKNOWN))

func _save_consent() -> void:
	var config := ConfigFile.new()
	config.set_value(CONSENT_SECTION, CONSENT_KEY, consent_state)
	config.save(CONSENT_FILE)
