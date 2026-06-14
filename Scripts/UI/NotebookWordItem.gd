extends PanelContainer

@onready var chinese_label: Label = $HBox/ChineseCircle/ChineseLabel
@onready var stats_label: Label = $HBox/InfoVBox/StatsLabel
@onready var guess_edit: LineEdit = $HBox/GuessEdit
@onready var play_button: Button = $HBox/PlayButton

var vocab_entry: VocabularyEntry

func setup(entry: VocabularyEntry) -> void:
	vocab_entry = entry
	if entry.seen_count > 0:
		chinese_label.text = entry.chinese
		guess_edit.text = entry.user_guess
		guess_edit.editable = true
		guess_edit.placeholder_text = "輸入您的猜測..."
		var loc = entry.last_seen if not entry.last_seen.is_empty() else "無"
		stats_label.text = "看過 " + str(entry.seen_count) + " 次 | " + loc
		play_button.disabled = false
		play_button.visible = true
	else:
		chinese_label.text = "???"
		guess_edit.text = ""
		guess_edit.editable = false
		guess_edit.placeholder_text = "未解鎖 / Locked"
		stats_label.text = "看過 0 次 | 無"
		play_button.disabled = true
		play_button.visible = false

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	guess_edit.text_changed.connect(_on_guess_changed)

func _on_play_pressed() -> void:
	if vocab_entry != null:
		AudioManager.play_vocabulary(vocab_entry.id)

func _on_guess_changed(new_text: String) -> void:
	if vocab_entry != null:
		vocab_entry.user_guess = new_text
