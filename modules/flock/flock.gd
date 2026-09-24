extends Node3D
class_name Flock

signal hunger_changed

@export var num_boids: int = 10
@export var spawn_radius: float = 10.0
@onready var cursor: MeshInstance3D = $MeshInstance3D2

var boids: Array[Boid] = []
var mouse_target : Vector3
var boid_scene = preload("res://modules/flock/player_bird/player_bird.tscn")

# Camera
@export var camera: Camera3D

# Hunger
@export var max_hunger: float = 100.0
@export var current_hunger: float = max_hunger
@export var starve_rate: float = 1.0

func _ready() -> void:
	Global.flock = self
	
	# keeps the mouse within the game window
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	for i in range(num_boids):
		var new_boid: Boid = boid_scene.instantiate()

		add_child(new_boid)
		
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(0.0, spawn_radius)

		new_boid.position = Vector3(
			cos(angle) * distance,
			0.0,
			sin(angle) * distance
		)

		boids.append(new_boid)


func _process(delta: float) -> void:
	# hold esc to let mouse go beyond the game window
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	if Input.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	mouse_target = get_mouse_world_position(camera)
	cursor.global_position = mouse_target
	
	if current_hunger > 0:
		current_hunger = max(current_hunger - starve_rate * delta, 0.0)
		hunger_changed.emit(current_hunger)

func eat(value: float) -> void:
	current_hunger = min(current_hunger + value, max_hunger)
	hunger_changed.emit(current_hunger)
	
func get_mouse_world_position(camera: Camera3D) -> Vector3:
	var mouse_pos := get_viewport().get_mouse_position()

	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)

	var flock_y := global_position.y
	if abs(ray_direction.y) < 0.0001:
		return ray_origin
	
	var t = (flock_y - ray_origin.y) / ray_direction.y
	return ray_origin + ray_direction * t

func get_center_of_mass(nodes: Array = boids) -> Vector3:
	if nodes.is_empty():
		return Vector3.ZERO
	
	var total_position := Vector3.ZERO
	for n in nodes:
		total_position += n.global_position
		
	return total_position / float(nodes.size())
