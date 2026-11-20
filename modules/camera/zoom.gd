extends Node3D


@export var camera_node: Camera3D

@export var base_fov: float = 75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var tween: Tween
func zoom_pulse(magnitude: float = -4, duration: float = 0.3, ratio: float = 3):
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera_node, "fov", base_fov + magnitude, duration * 1/(ratio + 1) ).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera_node, "fov", base_fov, duration * ratio/(ratio + 1) ).set_ease(Tween.EASE_IN_OUT)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_1"):
		print("debug pressed")
		zoom_pulse()
