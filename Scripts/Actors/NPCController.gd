extends CharacterBody2D

enum BehaviorState {
	IDLE,
	WALKING,
	SPEAKING,
	INTERACTING_WITH_OBJECT
}

const BUBBLE_ABOVE_TOP := -54.0
const BUBBLE_ABOVE_BOTTOM := -24.0
const BUBBLE_BELOW_TOP := 24.0
const BUBBLE_BELOW_BOTTOM := 54.0
const BUBBLE_SCREEN_MARGIN := 12.0

@export var character_name: String = "NPC"
@export var identity: String = "角色"
@export var behavior_state: BehaviorState = BehaviorState.IDLE
@export var can_random_walk: bool = true
@export var random_walk_bounds: Rect2 = Rect2(Vector2(-300, -170), Vector2(380, 330))
@export var walk_speed: float = 50.0
@export var speech_delay: float = 1.4
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
	add_to_group("npc")
	random.randomize()
	target_position = global_position
	_refresh_labels()
	_hide_speech()
	speech_timer.timeout.connect(_hide_speech)
	_pick_next_idle_time()
	_update_sprite()

func _update_sprite() -> void:
	# Demo mode: show placeholder body, don't load art sprites
	var placeholder = get_node_or_null("PlaceholderBody")
	if placeholder != null:
		placeholder.visible = true

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
	if lines.is_empty() or not can_start_dialogue():
		return

	is_speaking = true
	behavior_state = BehaviorState.SPEAKING
	for i in lines.size():
		var line_vocab_ids := _get_line_vocab_ids(vocab_ids, i)
		var primary_vocab_id := _get_primary_vocab_id(line_vocab_ids)
		display_word(String(lines[i]), line_vocab_ids)
		if not String(primary_vocab_id).is_empty():
			AudioManager.play_vocabulary(primary_vocab_id, character_name)
		await get_tree().create_timer(speech_delay).timeout
	is_speaking = false
	behavior_state = BehaviorState.IDLE
	_pick_next_idle_time()

func can_start_dialogue() -> bool:
	return not is_speaking

func set_profile(npc_name: String, npc_identity: String, random_walk: bool, words: Array, vocab_ids: Array, delay: float = 1.4, bounds: Rect2 = Rect2()) -> void:
	character_name = npc_name
	identity = npc_identity
	can_random_walk = random_walk
	spoken_words = words
	spoken_vocab_ids = vocab_ids
	speech_delay = delay
	if bounds.size.x > 0 and bounds.size.y > 0:
		random_walk_bounds = bounds
	if is_node_ready():
		_refresh_labels()

func display_word(word: String, vocab_ids: Variant = []) -> void:
	speech_label.text = word
	_position_speech_bubble()
	speech_bubble.show()
	speech_timer.start(max(1.5, speech_delay - 0.5))
	VocabularyDatabase.mark_many_seen_from_dialogue(_normalize_vocab_ids(vocab_ids), character_name)

func _get_line_vocab_ids(all_vocab_ids: Array, index: int) -> Array:
	if index >= all_vocab_ids.size():
		return []
	return _normalize_vocab_ids(all_vocab_ids[index])

func _normalize_vocab_ids(raw_ids: Variant) -> Array:
	if raw_ids is Array:
		return raw_ids
	if String(raw_ids).is_empty():
		return []
	return [StringName(raw_ids)]

func _get_primary_vocab_id(ids: Array) -> StringName:
	if ids.is_empty():
		return &""
	return StringName(ids[ids.size() - 1])

func _position_speech_bubble() -> void:
	var canvas_transform := get_global_transform_with_canvas()
	var npc_screen_position := canvas_transform * Vector2.ZERO
	var vertical_scale := canvas_transform.y.length()
	var use_below := (
		npc_screen_position.y + BUBBLE_ABOVE_TOP * vertical_scale
		< BUBBLE_SCREEN_MARGIN
	)

	speech_bubble.offset_top = BUBBLE_BELOW_TOP if use_below else BUBBLE_ABOVE_TOP
	speech_bubble.offset_bottom = BUBBLE_BELOW_BOTTOM if use_below else BUBBLE_ABOVE_BOTTOM

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
		return

	velocity = offset.normalized() * walk_speed

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
