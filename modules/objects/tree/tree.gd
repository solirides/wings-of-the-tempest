extends Node3D

func _body_entered( body: Node3D ) -> void:
		if body is Boid:
			body.soft_collision_factor += 1;

func _body_exited( body: Node3D ) -> void:
		if body is Boid:
			body.soft_collision_factor -= 1;
