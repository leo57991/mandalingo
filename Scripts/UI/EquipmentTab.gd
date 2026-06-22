extends Control
class_name EquipmentTab

@onready var placeholder_label: Label = %PlaceholderLabel

func _ready() -> void:
	placeholder_label.text = "裝備系統開發中"
