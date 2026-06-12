extends PanelContainer
class_name DialoguePopup

@onready var chinese_label: Label = %ChineseLabel
@onready var hint_label: Label = %HintLabel

func _ready() -> void:
	hide()

func show_chinese(text: String) -> void:
	chinese_label.text = text
	hint_label.text = "E"
	show()

func clear() -> void:
	chinese_label.text = ""
	hide()
