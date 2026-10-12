extends Node

@export var master_volume: float = 1.0
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0
@onready var music_stream = $MusicStreamPlayer
@onready var sfx_node = $SFX


@export var sounds: Array[Sound] = []
var sounds_by_name: Dictionary = {}
var sound_stream_players: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_sound_dictionary()
	print("global audio scene loaded!")
	play_sfx_track("test_sound_1")
	#var audio_stream = load("res://assets/sounds/test_sound.mp3")
	#play_music_track(audio_stream, -5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_sound_dictionary():
	# dynamically load and create the audio stream players for each Sound resource
	for sound in sounds:
		sounds_by_name[sound.sound_name] = sound
		var player = AudioStreamPlayer.new()
		player.stream = sound.audio_stream
		player.volume_db = sound.default_volume
		sfx_node.add_child(player)
		sound_stream_players[sound.sound_name] = player

func play_sfx_track(sound_name: String, \
		volume_db: float = sounds_by_name[sound_name].default_volume):
	# note: each AudioStreamPlayer only has one volume.
	# Multiple sounds played in one stream will all be at the same volume.
	# 
	#sound_stream_players[sound_name].volume_db = volume_db
	sound_stream_players[sound_name].play()

func play_music_track(audio_stream: AudioStream, volume_db: float = 0):
	music_stream.stream = audio_stream
	music_stream.volume_db = volume_db
	music_stream.play()

func set_bus_volume(bus_name:String = "Master", volume_db:float = 0):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, volume_db)
