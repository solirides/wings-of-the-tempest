extends Node3D
class_name Food

@export var hunger_value: float = 25.0
@export var eat_particles: PackedScene
@export var edible_parts: Array[Node3D] = []
@export var consume_all: bool = false

@onready var area: Area3D = $Area3D

var eaten: bool = false

func consumed() -> void:
	if eaten:
		return
	eaten = true
	invoke_particles()
	if consume_all:
		queue_free()
		return
	for part in edible_parts:
		part.queue_free()
	# Stop boid's food_detector from noticing this area again
	area.set_deferred("monitorable", false)

func invoke_particles() -> void:
	if eat_particles:
		var fx: Node3D = eat_particles.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.global_position = global_position + Vector3.UP * 0.7
