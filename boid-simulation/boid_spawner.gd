extends Node3D

@export var boid : PackedScene

var num_spawned = 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_SPACE:
			num_spawned += 1
			print("Is it a bird? Is it a plane? No, it's a BOID! Spawned: " , num_spawned)
			spawn_boid()

func spawn_boid() -> void :
	var another_one = boid.instantiate()
	add_child(another_one)
