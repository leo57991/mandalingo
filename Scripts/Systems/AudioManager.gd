extends Node

@export var log_missing_audio: bool = false

var voice_player: AudioStreamPlayer

func _ready() -> void:
	voice_player = AudioStreamPlayer.new()
	voice_player.bus = "Master"
	add_child(voice_player)

func play_vocabulary(id: StringName) -> void:
	VocabularyDatabase.mark_learned(id)
	
	var path := VocabularyDatabase.get_audio_path(id)
	if path.is_empty():
		# TODO: Add recorded Chinese voice lines for vocabulary ids.
		return

	if not ResourceLoader.exists(path):
		if log_missing_audio:
			push_warning("Missing vocabulary audio for '%s': %s" % [id, path])
		return

	var stream := load(path)
	if stream is AudioStream:
		voice_player.stream = stream
		voice_player.play()

func play_audio_file(path: String) -> void:
	if path.is_empty():
		return

	if not ResourceLoader.exists(path):
		if log_missing_audio:
			push_warning("Missing audio file: %s" % path)
		return

	var stream := load(path)
	if stream is AudioStream:
		voice_player.stream = stream
		voice_player.play()
