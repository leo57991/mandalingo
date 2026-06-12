extends Area2D

@export var is_interactable: bool = true
@export var character_name: String = "村民"
@export var passive_text: String = "你好" # 文字對話氣泡內容
@export var active_text: String = "蘋果"
@export var prompt_image: Texture2D # 情境提示圖片

var player_in_range: bool = false
@onready var bubble_ui = $BubbleUI # 假設 NPC 節點下有一個 BubbleUI (對話氣泡) 子節點

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if bubble_ui:
		bubble_ui.hide()

func _process(_delta: float) -> void:
	if is_interactable and player_in_range:
		# 支援按下 E 鍵互動，或是可以另外加入滑鼠點擊偵測
		if Input.is_action_just_pressed("interact"):
			trigger_active_dialogue()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		if not is_interactable:
			# 不能互動的 NPC 自動說話 (被動對話)
			trigger_passive_dialogue()
		else:
			# 如果可以互動，也許顯示一個 "E" 的小提示 (MVP先省略)
			pass

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		if bubble_ui:
			bubble_ui.hide()

func trigger_passive_dialogue() -> void:
	if bubble_ui:
		bubble_ui.show_text(passive_text)

func trigger_active_dialogue() -> void:
	if bubble_ui:
		bubble_ui.show_text_and_image(active_text, prompt_image)
