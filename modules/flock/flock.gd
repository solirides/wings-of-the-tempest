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
var flock_goal : Vector3
var boid_scene = preload("res://modules/flock/player_bird/player_bird.tscn")

# all boids including ones in subflocks
var all_boids: Array[Boid] = []

signal hunger_changed

#This is such a JANK way of doing this but...
var flockMaxHeight = 5
func _ready() -> void:
	global_position.y = flockMaxHeight 

#Use this to handle any button presses which would change the state of the boids... for now, I'm thinking scatter mode and landing
func _unhandled_input(event: InputEvent) -> void:
	
	#THIS changes causses the boids to repel... ALSO NO LONGER A HOLD THING!!!!
	if event.is_action_pressed("repel") :
		if boid_properties.flockIsLanded :
			print("You cannot scatter while the boids are meant to be landed!")
			boid_properties.scatter = false
		else:
			# toggle boid scattering mode
			boid_properties.scatter = !boid_properties.scatter
			boid_properties.default_state = !boid_properties.default_state
		print("I'm chaning scatter states")
		
	#This detects if 
	if event.is_action_pressed("land") :
		
		#This is SUPPOSED to run when the Boid are flying in the air and you want them to land.
		if boid_properties.flockIsFlying:
			print("The boids are supposed to land now.")
			boid_properties.flockIsFlying = false
			# do not set flockIsLanded until it actually lands
			#boid_properties.flockIsLanded = false
			boid_properties.scatter = false
			boid_properties.default_state = true
		#This is should run when the Boids are landed and you want them to get their lard asses in the air.
		#elif boid_properties.flockIsLanded:
		else:
			print("RISE FROM YOUR GRAVES!!!!! EHEHEHEHEHEH")
			boid_properties.flockIsLanded = false
			boid_properties.flockIsFlying = true
			
			global_position.y = flockMaxHeight
	
#This function will always update the flocks position to the nearest piece of terrain.
@export var groundRay : RayCast3D
func attempt_landing() -> void :
	groundRay.global_position = get_center_of_mass(boids)
	groundRay.target_position = Vector3(0, -100, 0)
	groundRay.force_raycast_update()
	
	if groundRay.is_colliding() :
		print("found something to land on")
		var collisionPoint = groundRay.get_collision_point()
		
		global_position.y = collisionPoint.y
		boid_properties.flockIsLanded = true
		
	else :
		print("Didn't see anything, sorry!")
		#global_position.y = flockMaxHeight

func _process(delta: float) -> void:
	#this allows for the boid's main goal to be updated later on. Maybe for a better flock split system??????
	#This IS not perfect, if I want the boids to split into subflocks, I need to give them functionality to do so... in their OWN script!
	flock_goal = get_cursor_pos()
	global_position = get_cursor_pos()
	if cursor:
		cursor.global_position = get_cursor_pos()

func _physics_process(delta: float) -> void:
	
	# if flock is attempting to land and hasn't found a landing spot yet
	if boid_properties.flockIsFlying == false and boid_properties.flockIsLanded == false:
		# try to find something to land on
		attempt_landing()
	
	if current_hunger > 50.0:
		boid_properties.speed.value = max(boid_properties.min_speed.value, boid_properties.speed.value - speed_penalty_interval * delta)
	
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

	
	boid_properties.speed.value += value * speed_penalty_interval
	#this line does imply that you can get a speed boost
	#beyond your default speed value, but that will
	#be corrected in the _process function
	current_hunger = min(current_hunger + value, max_hunger)
	hunger_changed.emit(current_hunger)
	
func get_mouse_world_position(camera: Camera3D) -> Vector3:
	var mouse_pos := get_viewport().get_mouse_position()

	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)
	
	var flock_x := global_position.x
	var flock_z := global_position.z
	var flock_y := global_position.y
	
	if abs(ray_direction.y) < 0.0001:
		return ray_origin
	
	var t = (flock_y - ray_origin.y) / ray_direction.y
	return ray_origin + ray_direction * t
	
#This should send the position of the mouse to anything that needs it, without having to send for the camera.
func get_cursor_pos() -> Vector3 :
	return get_mouse_world_position(camera_controller.camera_node)

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
