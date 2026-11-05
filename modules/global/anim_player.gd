extends Node3D

@export var anim_player: AnimationPlayer
@export var anim_speed: float
@export var anim_name: String
@export var playing: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playing = true
	anim_speed = randf_range(1.0, 1.8)
	var l = anim_player.get_animation(anim_name).length
	var start_time = randf_range(0, l)
	anim_player.seek(start_time)
	print("ran")
	play_anim()

func play_anim() -> void:
	if (playing):
		anim_player.play(anim_name, -1, anim_speed)
		
func stop_anim() -> void:
	playing = false
