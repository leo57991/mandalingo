extends HBoxContainer

@onready var chinese_label: Label = $ChineseLabel
@onready var pinyin_label: Label = $PinyinLabel
@onready var guess_edit: LineEdit = $GuessEdit
@onready var seen_label: Label = $SeenLabel
@onready var location_label: Label = $LocationLabel
@onready var play_button: Button = $PlayButton

var vocab_entry: VocabularyEntry

func setup(entry: VocabularyEntry) -> void:
	vocab_entry = entry
	if entry.seen_count > 0:
		chinese_label.text = entry.chinese
		pinyin_label.text = "(" + entry.pinyin + ")"
		guess_edit.text = entry.user_guess
		guess_edit.editable = true
		guess_edit.placeholder_text = "輸入您的猜測..."
		seen_label.text = str(entry.seen_count) + " 次"
		location_label.text = entry.last_seen if not entry.last_seen.is_empty() else "無"
		play_button.disabled = false
		play_button.visible = true
	else:
		chinese_label.text = "???"
		pinyin_label.text = ""
		guess_edit.text = ""
		guess_edit.editable = false
		guess_edit.placeholder_text = "未解鎖 / Locked"
		seen_label.text = "0 次"
		location_label.text = "無"
		play_button.disabled = true
		play_button.visible = false

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	guess_edit.text_changed.connect(_on_guess_changed)

func _on_play_pressed() -> void:
	if vocab_entry != null:
		# Pass location context as notebook so it doesn't count as seeing it in the wild again
		AudioManager.play_vocabulary(vocab_entry.id)

func _on_guess_changed(new_text: String) -> void:
	if vocab_entry != null:
		vocab_entry.user_guess = new_text
