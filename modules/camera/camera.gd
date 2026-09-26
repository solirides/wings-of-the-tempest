extends Camera3D


@export var flock: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camera = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print(flock.get_center_of_mass())
	
