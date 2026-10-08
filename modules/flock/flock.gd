extends Node3D
class_name Flock



# How to use health system
# Currently, there are functions for registering damage (take_damage() and take_percent_damage()
# and healing (heal() and heal_percent()). take_damage() and heal() each take a specific value to subtract or
# add to the health respectively, while take_percent_damage() and heal_percent() each take a percent of the maximum health
# (as a decimal between 0 and 1) to subtract or add to the health respectively.  

# Flock Health Varibables and Signals
const MAX_HEALTH: float = 100.0
var health = MAX_HEALTH

# 9/27/26 So far I've only added a signal that is emitted whenever the health is equal to zero,
# but feel free to add more. Just make sure to invoke it only from the check_status() function in this script
signal health_reached_zero


# Getter functions for health, one retrieves the exact health and the other
# retrieves the percent of the max health the flock is currently at
func get_health() -> float:
	return health
func get_health_percent() -> float:
	return health / MAX_HEALTH
	

# Two different damage functions are defined here, one subtracts health directly and one subtracts a percentage
# of the maximum health	
func take_damage(damage: float) -> void:
	if (damage < 0 || health <= 0):
		print("Invalid damage argument or health has reached zero")
		return
	health -= damage
	check_status()

func take_percent_damage(percent_damage: float) -> void:
	if (percent_damage > 1.0 || percent_damage < 0 || health <= 0):
		print("Invalid damage argument or health has reached zero")
		return
	health -= percent_damage * MAX_HEALTH
	check_status()

func heal(health_healed : float) -> void:
	health += health_healed;
	check_status()

func heal_percent(heal_percent: float) -> void:
	if (heal_percent < 0 || heal_percent > 1):
		print("Invalid health argument")
		return
	health += heal_percent * MAX_HEALTH
	check_status()

func check_status() -> void:
	if (health <= 0):
		health = 0
		health_reached_zero.emit()
	elif (health >= MAX_HEALTH):
		health = MAX_HEALTH

signal hunger_changed

@export var num_boids: int = 10
@export var spawn_radius: float = 10.0
@export var cursor: MeshInstance3D

# only boids with movement controlled by the main flock, not subflocks
var boids: Array[Boid] = []
var boid_goal : Vector3
var boid_scene = preload("res://modules/flock/player_bird/player_bird.tscn")

@export var subflocks: Array[SubFlock] = []
# all boids including ones in subflocks
var all_boids: Array[Boid] = []

# Camera
@export var camera: Camera3D

# Hunger
@export var max_hunger: float = 100.0
@export var current_hunger: float = max_hunger
@export var starve_rate: float = 2.0
@export var starve_death_interval: float = 15.0
@export var speed_penalty_interval: float = 0.1



func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	
	if !all_boids.is_empty():
		for boid in all_boids:
			if boid.speed > boid.default_speed:
				boid.speed = max(boid.default_speed, boid.speed - speed_penalty_interval * delta)
		
		#in essence both of these if statements are decreasing the hunger
		if current_hunger > 0:
			current_hunger = max(0.0, current_hunger - starve_rate * delta)
			#print("hunger: " + str(current_hunger))
			#this code block inflicts speed penalties below 50 hunger
			if current_hunger < 50.0:
				for boid in all_boids:
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
				all_boids[0].kill_boid() #this line can be assumed 
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

func _on_boid_death(boid: Node, pos: Vector3):
	# the boid gets deleted in like one frame so idk if this var is useful
	Global.camera.shake.shake()

func remove_boid(boid: Boid):
	print(len(all_boids))
	boids.erase(boid)
	all_boids.erase(boid)
	print(len(all_boids))
	print("%s removed from %s" % [boid, boids])
	print("%s removed from %s" % [boid, all_boids])

func transfer_boids_to_flock(flock: Flock):
	for boid in all_boids:
		boid.transfer_to_flock(flock)
