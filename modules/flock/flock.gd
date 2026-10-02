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
@export var starve_rate: float = 2.0
@export var starve_death_interval: float = 15.0
@export var speed_penalty_interval: float = 0.1



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
	
	if !boids.is_empty():
		for boid in boids:
			if boid.speed > boid.default_speed:
				boid.speed = max(boid.default_speed, boid.speed - speed_penalty_interval * delta)
		
		#in essence both of these if statements are decreasing the hunger
		if current_hunger > 0:
			current_hunger = max(0.0, current_hunger - starve_rate * delta)
			print(current_hunger)
			#this code block inflicts speed penalties below 50 hunger
			if current_hunger < 50.0:
				for boid in boids:
					boid.speed = max(0.0, boid.speed - speed_penalty_interval * delta)
			
			hunger_changed.emit(current_hunger)
		else:
			#there is no speed penalty because you already ran out of hunger
			current_hunger = min(0.0, current_hunger - starve_rate * delta)
			hunger_changed.emit(current_hunger)
			
			#this if-statement will kill birds of starvation periodically
			if current_hunger < -starve_death_interval:
				print("starved")
				current_hunger = 0.0
				boids[0].remove_boid() #this line can be assumed 
				# to not trigger a bad memory access error because
				# the entire hunger update system depends on a boid existing

func eat(value: float) -> void:
	if (current_hunger < 0.0):
		current_hunger = 0.0

	for boid in boids:
		boid.speed += value * speed_penalty_interval
		#this line does imply that you can get a speed boost
		#beyond your default speed value, but that will
		#be corrected in the _process function
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
