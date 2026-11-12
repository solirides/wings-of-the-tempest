extends Node

@export var anim_player: AnimationPlayer
@export var anim_speed: float = -1
@export var anim_name: String
@export var playing: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playing = true
	if anim_speed < 0:
		anim_speed = randf_range(1.0, 1.8)
	# look for AnimationPlayer on each boid
	if anim_player == null:
		var found := find_children("*", "AnimationPlayer", true, false)
		if not found.is_empty():
			anim_player = found[0]
	if anim_player == null:
		return
	if anim_name.is_empty():
		var names := anim_player.get_animation_list()
		if names.is_empty():
			return
		anim_name = names[0]
	if not anim_player.has_animation(anim_name):
		return
	var anim := anim_player.get_animation(anim_name)
	anim.loop_mode = Animation.LOOP_LINEAR
	play_anim()
	# randomize where animation starts
	anim_player.seek(randf_range(0.0, anim.length), true)

func play_anim() -> void:
	if playing:
		anim_player.play(anim_name, -1, anim_speed)
		
func stop_anim() -> void:
	playing = false
