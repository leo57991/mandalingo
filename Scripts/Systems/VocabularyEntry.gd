extends Resource
class_name VocabularyEntry

@export var id: StringName
@export var chinese: String
@export var pinyin: String
@export var english_internal: String
@export_file("*.wav", "*.ogg", "*.mp3") var audio_file: String
@export var learned: bool = false

@export var seen_count: int = 0
@export var last_seen: String = ""
@export var user_guess: String = ""

func has_audio() -> bool:
	return not audio_file.is_empty()
