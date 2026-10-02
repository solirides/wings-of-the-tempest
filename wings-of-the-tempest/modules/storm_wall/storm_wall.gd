extends Node3D


@export var mesh: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mesh.rotate(Vector3(1,0,0), 1 * delta)
	print(mesh.global_rotation)
