extends HBoxContainer

@onready var chinese_label: Label = $ChineseLabel
@onready var pinyin_label: Label = $PinyinLabel
@onready var english_label: Label = $EnglishLabel
@onready var play_button: Button = $PlayButton

var vocab_id: StringName

func setup(entry: VocabularyEntry) -> void:
	vocab_id = entry.id
	if entry.learned:
		chinese_label.text = entry.chinese
		pinyin_label.text = "(" + entry.pinyin + ")"
		english_label.text = entry.english_internal
		play_button.disabled = false
		play_button.visible = true
	else:
		chinese_label.text = "???"
		pinyin_label.text = ""
		english_label.text = "[ 未解鎖 / Locked ]"
		play_button.disabled = true
		play_button.visible = false

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	AudioManager.play_vocabulary(vocab_id)
