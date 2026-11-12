extends Node3D

@export var amplitude: float = 2
@export var time_scale: float = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	global_position.y = amplitude * sin(time_scale * now)
