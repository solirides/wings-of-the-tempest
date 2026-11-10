extends Node

@export var sounds: PackedStringArray = [
	"goose-flock1",
	"goose_1",
	"goose_2",
	"goose_3",
	"goose_4",
	"ambient_forest_1",
]

# delays for all sounds
@export_range(0.1, 3600.0, 0.1) var min_delay_between_sounds = 1.0
@export_range(0.1, 3600.0, 0.1) var max_delay_between_sounds = 20.0

# individual sound cooldowns in seconds
@export var sound_cooldowns: Dictionary = {
	"goose-flock1": 31.0,
	"goose_1": 3.0,
	"goose_2": 3.0,
	"goose_3": 3.0,
	"goose_4": 3.0,
	"ambient_forest_1": 48.0,
}

# the chance for the sound to be played when it is ready
@export var sound_chance: Dictionary = {
	"goose-flock1": 1.0,
	"goose_1": 0.3,
	"goose_2": 0.3,
	"goose_3": 0.3,
	"goose_4": 0.3,
	"ambient_forest_1": 1.0,
}

# each category of sounds shares a cooldown
@export var sound_categories: Dictionary = {
	"goose_honks": ["goose_1", "goose_2", "goose_3", "goose_4"],
}

@export var category_cooldowns: Dictionary = {
	"goose_honks": 3.0,
}


var last_played: Dictionary = {}
var last_category_played: Dictionary = {}
var last_loop_call = 0
var loop_delta = 0.1

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	_play_ambient_loop()

func _play_ambient_loop():
	
	var now = Time.get_ticks_msec() / 1000.0
	var eligible: Array[String] = []
	var next_available_time = INF
	
	for sound in sounds:
		var sound_available_at = (float(last_played.get(sound, -INF)) + float(sound_cooldowns.get(sound, 0.0)))
		
		var category := get_sound_category(sound)
		var category_available_at = -INF
		if category != "":
			category_available_at = (float(last_category_played.get(category, -INF)) + float(category_cooldowns.get(category, 0.0)))
		
		var available_at = max(sound_available_at, category_available_at)
		if now >= available_at:
			eligible.append(sound)
		else:
			next_available_time = min(next_available_time, available_at)
	
		#print(last_played.get(sound, -INF))
	
	
	
	#print(randf())
	#print(0.8 * loop_time / loop_delta)
	
	if eligible.is_empty():
		if next_available_time < INF:
			await get_tree().create_timer(max(loop_delta, next_available_time - now)).timeout
			return
	
	var sound = eligible[randi_range(0, len(eligible) - 1)]
	var loop_time = now - last_loop_call
	last_loop_call = now
	# chance to play the sound per second if it is ready
	var chance = sound_chance.get(sound, 1.0)
	var play_the_sound_actually = randf() < chance *  loop_time / loop_delta
	
	if play_the_sound_actually == false:
		await get_tree().create_timer(loop_delta).timeout
	
	Audio.play_sfx_track(sound)
	
	var played_at = now
	#print(played_at)
	var category = get_sound_category(sound)
	
	last_played[sound] = played_at
	
	if category != "":
		last_category_played[category] = played_at



func get_sound_category(sound: String) -> String:
	for category in sound_categories:
		if sound in sound_categories[category]:
			return str(category)
	return ""
