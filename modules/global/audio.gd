extends Node

@export var master_volume: float = 1.0
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0
@onready var music_player = $MusicStreamPlayer
@onready var sfx_node = $SFX
@onready var music_node = $Music

@export var musics: Array[Sound] = []
var musics_by_name: Dictionary = {}
var current_music_track = ""
var loop_music: bool = true

@export var sounds: Array[Sound] = []
var sounds_by_name: Dictionary = {}

var sound_stream_players: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_sound_dictionary()
	print("global audio scene loaded!")
	#play_sfx_track("test_sound_1")
	#var audio_stream = load("res://assets/sounds/test_sound.mp3")
	#play_music_track(audio_stream, -5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# ambient sound moved to world scene
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
		
	for music in musics:
		musics_by_name[music.sound_name] = music

func play_sfx_track(
		sound_name: String, 
		volume_db: float = sounds_by_name[sound_name].default_volume
	):
	# note: each AudioStreamPlayer only has one volume.
	# Multiple sounds played in one stream will all be at the same volume.
	# 
	#sound_stream_players[sound_name].volume_db = volume_db
	if sound_name in sound_stream_players:
		sound_stream_players[sound_name].play()
		#print("playing sound: %s" % sound_name)
	else:
		pass
		#print("invalid sound name: %s" % sound_name)

func play_music_track(
		music_name: String, loop: bool = true, 
		volume_db: float = musics_by_name[music_name].default_volume
	):
	var sound: Sound = musics_by_name[music_name]
	#var music_player = $MusicStreamPlayer
	music_player.stream = sound.audio_stream
	music_player.volume_db = volume_db
	music_player.play()
	current_music_track = music_name
	loop_music = loop

func set_bus_volume(bus_name:String = "Master", volume_db:float = 0):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, volume_db)


func _on_music_stream_player_finished() -> void:
	if loop_music:
		music_player.play()
	else:
		current_music_track = ""
