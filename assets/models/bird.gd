extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var anim = $AnimationPlayer
	
	# randomize animation speed
	var speed = randf_range(1.0, 1.8)
	anim.play("Action", -1, speed)
	
	# randomize starting point of animation
	var l = anim.get_animation("Action").length
	var start_time = randf_range(0, l)
	anim.seek(start_time)
	
	
	#print(anim.get_animation_list())
	#print(anim.get_current_animation_length())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
