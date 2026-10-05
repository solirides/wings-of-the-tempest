extends Area3D


@export var wind_direction: Vector3 = Vector3.FORWARD
@export var wind_strength: float = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("boids"):
			apply_wind(body)
			

func apply_wind(body: PhysicsBody3D):
	body.apply_central_force(wind_strength * wind_direction.normalized())
