extends Camera3D


@export var rotation_speed: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position = global_position.rotated(Vector3.UP, rotation_speed * delta)
	global_basis = global_basis.rotated(Vector3.UP, rotation_speed * delta)
