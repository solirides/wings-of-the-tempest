extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is Boid:
			print("applying soft collision")
			body.soft_collision_factor += 1

func _on_body_entered(body: Node3D) -> void:
	pass
