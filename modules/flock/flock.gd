extends Node3D
class_name Flock




# Camera
@export var camera_controller: Node

# Hunger
@export var max_hunger: float = 100.0
@export var current_hunger: float = max_hunger
@export var starve_rate: float = 2.0
@export var starve_death_interval: float = 15.0
@export var speed_penalty_interval: float = 0.1

@export var num_boids: int = 10
@export var spawn_radius: float = 10.0
@export var cursor: MeshInstance3D
@export var subflocks: Array[SubFlock] = []

@export var boid_properties: BoidProperties = BoidProperties.new()

# only boids with movement controlled by the main flock, not subflocks
var boids: Array[Boid] = []
var boid_goal : Vector3
var boid_scene = preload("res://modules/flock/player_bird/player_bird.tscn")

# all boids including ones in subflocks
var all_boids: Array[Boid] = []

signal hunger_changed

func _ready() -> void:
	pass

#Use this to handle any button presses which would change the state of the boids... for now, I'm thinking scatter mode and landing
func _unhandled_input(event: InputEvent) -> void:
	
	#THIS changes causses the boids to repel... ALSO NO LONGER A HOLD THING!!!!
	if event.is_action_pressed("repel") :
		boid_properties.scatter = !boid_properties.scatter
		boid_properties.default_state = !boid_properties.default_state
		print("I'm chaning scatter states")
	
	

func _physics_process(delta: float) -> void:
	
	if current_hunger > 50.0:
		boid_properties.speed = max(boid_properties.min_speed, boid_properties.speed - speed_penalty_interval * delta)
	
#in essence both of these if statements are decreasing the hunger
#if current_hunger > 0:
	#current_hunger = max(0.0, current_hunger - starve_rate * delta)
	#print("hunger: " + str(current_hunger))
	#this code block inflicts speed penalties below 50 hunger
	#if current_hunger < 50.0:
		#for boid in all_boids:
			#boid.speed = max(0.0, boid.speed - speed_penalty_interval * delta)
	
	#hunger_changed.emit(current_hunger)
#else:
	#there is no speed penalty because you already ran out of hunger
	#current_hunger = min(0.0, current_hunger - starve_rate * delta)
	#hunger_changed.emit(current_hunger)
	
	#this if-statement will kill birds of starvation periodically
	if current_hunger < -starve_death_interval:
		print("starved")
		current_hunger = 0.0
		all_boids[0].kill_boid() #this line can be assumed 
		# to not trigger a bad memory access error because
		# the entire hunger update system depends on a boid existing

func eat(value: float) -> void:
	if (current_hunger < 0.0):
		current_hunger = 0.0

	
	boid_properties.speed += value * speed_penalty_interval
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

func _on_boid_death(boid: Node, pos: Vector3):
	# the boid gets deleted in like one frame so idk if this var is useful
	Global.camera.shake.shake()

func remove_boid(boid: Boid):
	#print(len(all_boids))
	boids.erase(boid)
	all_boids.erase(boid)
	#print(len(all_boids))
	#print("%s removed from %s" % [boid, boids])
	#print("%s removed from %s" % [boid, all_boids])

func transfer_boids_to_flock(flock: Flock):
	for boid in all_boids:
		boid.transfer_to_flock(flock)
