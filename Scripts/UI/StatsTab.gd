extends Control
class_name StatsTab

@onready var placeholder_label: Label = %PlaceholderLabel

func _ready() -> void:
	placeholder_label.text = "屬性系統開發中"
