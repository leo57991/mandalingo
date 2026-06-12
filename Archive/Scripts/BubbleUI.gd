extends Control

@onready var label = $Label
@onready var texture_rect = $TextureRect
@onready var timer = $Timer

func _ready() -> void:
	hide()
	timer.timeout.connect(hide)

func show_text(text_content: String) -> void:
	label.text = text_content
	texture_rect.hide()
	show()
	timer.start(3.0) # 3秒後隱藏

func show_text_and_image(text_content: String, img: Texture2D) -> void:
	label.text = text_content
	if img:
		texture_rect.texture = img
		texture_rect.show()
	else:
		texture_rect.hide()
	show()
	timer.start(3.0)
