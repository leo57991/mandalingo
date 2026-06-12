extends CharacterBody2D

enum BehaviorState {
	IDLE,
	WALKING,
	SPEAKING,
	INTERACTING_WITH_OBJECT
}

@export var character_name: String = "NPC"
@export var identity: String = "人"
@export var behavior_state: BehaviorState = BehaviorState.IDLE
@export var can_random_walk: bool = true
@export var random_walk_bounds: Rect2 = Rect2(Vector2(-300, -170), Vector2(520, 330))
@export var walk_speed: float = 50.0
@export var spoken_words: Array = ["你好"]
@export var spoken_vocab_ids: Array = [&"nihao"]
@export var sprite_texture: Texture2D:
	set(val):
		sprite_texture = val
		_update_sprite()
@export var min_idle_time: float = 1.2
@export var max_idle_time: float = 3.2

@onready var name_label: Label = %NameLabel
@onready var identity_label: Label = %IdentityLabel
@onready var speech_bubble: PanelContainer = %SpeechBubble
@onready var speech_label: Label = %SpeechLabel
@onready var speech_timer: Timer = %SpeechTimer
@onready var sprite_2d: Sprite2D = %Sprite2D

var target_position := Vector2.ZERO
var idle_time_left := 0.0
var is_speaking := false
var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.randomize()
	target_position = global_position
	_refresh_labels()
	_hide_speech()
	speech_timer.timeout.connect(_hide_speech)
	_pick_next_idle_time()
	_update_sprite()

func _update_sprite() -> void:
	# Use get_node_or_null to prevent null errors during early init
	var s2d = get_node_or_null("Sprite2D")
	if s2d != null and sprite_texture != null:
		s2d.texture = sprite_texture
		var tex_size = sprite_texture.get_size()
		if tex_size.y > 0:
			var scale_factor = 48.0 / tex_size.y
			s2d.scale = Vector2(scale_factor, scale_factor)

func _physics_process(_delta: float) -> void:
	match behavior_state:
		BehaviorState.IDLE:
			_process_idle(_delta)
		BehaviorState.WALKING:
			_walk_to_random_target()
		BehaviorState.SPEAKING:
			velocity = Vector2.ZERO
		BehaviorState.INTERACTING_WITH_OBJECT:
			velocity = Vector2.ZERO

	move_and_slide()

func say(lines: Array, vocab_ids: Array = []) -> void:
	if lines.is_empty() or is_speaking:
		return

	is_speaking = true
	behavior_state = BehaviorState.SPEAKING
	for i in lines.size():
		display_word(String(lines[i]))
		if i < vocab_ids.size():
			AudioManager.play_vocabulary(StringName(vocab_ids[i]))
		await get_tree().create_timer(1.4).timeout
	is_speaking = false
	behavior_state = BehaviorState.IDLE
	_pick_next_idle_time()

func set_profile(npc_name: String, npc_identity: String, random_walk: bool, words: Array, vocab_ids: Array) -> void:
	character_name = npc_name
	identity = npc_identity
	can_random_walk = random_walk
	spoken_words = words
	spoken_vocab_ids = vocab_ids
	if is_node_ready():
		_refresh_labels()

func display_word(word: String) -> void:
	speech_label.text = word
	speech_bubble.show()
	speech_timer.start(2.0)

func _process_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	if not can_random_walk:
		return

	idle_time_left -= delta
	if idle_time_left <= 0.0:
		target_position = _random_point_in_bounds()
		behavior_state = BehaviorState.WALKING

func _walk_to_random_target() -> void:
	if not can_random_walk:
		velocity = Vector2.ZERO
		behavior_state = BehaviorState.IDLE
		return

	var offset := target_position - global_position
	if offset.length() < 6.0:
		velocity = Vector2.ZERO
		behavior_state = BehaviorState.IDLE
		_pick_next_idle_time()
		_maybe_say_idle_word()
		return

	velocity = offset.normalized() * walk_speed

func _maybe_say_idle_word() -> void:
	if spoken_words.is_empty():
		return

	var index := random.randi_range(0, spoken_words.size() - 1)
	display_word(spoken_words[index])
	if index < spoken_vocab_ids.size():
		AudioManager.play_vocabulary(spoken_vocab_ids[index])

func _random_point_in_bounds() -> Vector2:
	return Vector2(
		random.randf_range(random_walk_bounds.position.x, random_walk_bounds.end.x),
		random.randf_range(random_walk_bounds.position.y, random_walk_bounds.end.y)
	)

func _pick_next_idle_time() -> void:
	idle_time_left = random.randf_range(min_idle_time, max_idle_time)

func _refresh_labels() -> void:
	name_label.text = character_name
	identity_label.text = identity

func _hide_speech() -> void:
	speech_bubble.hide()
