extends PanelContainer

@onready var chinese_label: Label = $HBox/ChineseCircle/ChineseLabel
@onready var stats_label: Label = $HBox/InfoVBox/StatsLabel
@onready var guess_edit: LineEdit = $HBox/GuessEdit
@onready var play_button: Button = $HBox/PlayButton

var vocab_entry: VocabularyEntry
var _last_reported_guess := ""

func setup(entry: VocabularyEntry) -> void:
	vocab_entry = entry
	_last_reported_guess = entry.user_guess
	if entry.seen_count > 0:
		chinese_label.text = entry.chinese
		guess_edit.text = entry.user_guess
		guess_edit.editable = true
		guess_edit.placeholder_text = "Enter your guess..."
		
		var raw_loc = entry.last_seen if not entry.last_seen.is_empty() else "無"
		var loc := ""
		match raw_loc:
			"林阿姨": loc = "Auntie Lin"
			"小安": loc = "Xiao An"
			"美美": loc = "Mei Mei"
			"阿明": loc = "Ah Ming"
			"小雨": loc = "Xiao Yu"
			"蘋果貨架": loc = "Apple Shelf"
			"茶葉貨架": loc = "Tea Shelf"
			"水貨架": loc = "Water Shelf"
			"無", "": loc = "None"
			_: loc = raw_loc
		
		var times_str = "time" if entry.seen_count == 1 else "times"
		stats_label.text = "Seen " + str(entry.seen_count) + " " + times_str + " | " + loc
		play_button.disabled = false
		play_button.visible = true
	else:
		chinese_label.text = "???"
		guess_edit.text = ""
		guess_edit.editable = false
		guess_edit.placeholder_text = "未解鎖 / Locked"
		stats_label.text = "Seen 0 times | None"
		play_button.disabled = true
		play_button.visible = false

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	guess_edit.text_changed.connect(_on_guess_changed)
	guess_edit.focus_exited.connect(_report_guess_update)
	guess_edit.text_submitted.connect(_on_guess_submitted)

func _on_play_pressed() -> void:
	if vocab_entry != null:
		AudioManager.play_vocabulary(vocab_entry.id, "", false)

func _on_guess_changed(new_text: String) -> void:
	if vocab_entry != null:
		vocab_entry.user_guess = new_text

func _on_guess_submitted(_new_text: String) -> void:
	_report_guess_update()

func _report_guess_update() -> void:
	if vocab_entry == null or vocab_entry.user_guess == _last_reported_guess:
		return
	_last_reported_guess = vocab_entry.user_guess
	TelemetryManager.track_guess_updated(
		vocab_entry.id,
		vocab_entry.user_guess.length(),
		not vocab_entry.user_guess.strip_edges().is_empty()
	)
