extends Resource
class_name Sound

@export var sound_name: String
@export var audio_stream: AudioStream
@export var default_volume: float

#func _init(sound_name: String, audio_stream: AudioStream, default_volume: float = 0):
	#self.sound_name = sound_name
	#self.audio_stream = audio_stream
	#self.default_volume = default_volume
