extends Node3D
class_name Flock

# Camera
@export var camera_controller: Node

# Hunger
@export var enable_hunger_effects = true
@export var max_hunger: float = 100.0
@export var current_hunger: float = max_hunger
@export var starve_rate: float = 2.0
@export var starve_death_interval: float = 15.0
@export var speed_penalty_interval: float = 0.1
@export var min_hunger_speed_penalty: float = 0.7

@export var water_depletion_rate: float = 4.0

@export var num_boids: int = 10
@export var spawn_radius: float = 10.0
@export var cursor: Node3D
@export var subflocks: Array[Flock] = []

@export var boid_properties: BoidProperties = BoidProperties.new()

# only boids with movement controlled by the main flock, not subflocks
var boids: Array[Boid] = []
var flock_goal : Vector3
var land_goal : Vector3
var boid_scene = preload("res://modules/flock/player_bird/player_bird.tscn")

# all boids including ones in subflocks
var all_boids: Array[Boid] = []

signal hunger_changed(current_hunger:float)

#hydrate or die-drate
#Water is a whole flock resource
const WATER_CAPACITY: float = 100.0
var hydration = WATER_CAPACITY

var hunger_modifier: StatModifier = StatModifier.new("hunger_penalty", 1, StatModifier.ModifierType.MULTIPLY)

# Getter functions for water, one retrieves the exact water and the other
# retrieves the percent of the water capacity the flock is currently at
func get_hydration() -> float:
	return hydration
func get_hydration_percent() -> float:
	return hydration / WATER_CAPACITY

func take_percent_hydration(take_percent: float) -> void:
	if (take_percent > 1.0 || take_percent < 0 || hydration <= 0):
		print("Invalid water argument or hydration has reached zero")
		return
	hydration -= take_percent * WATER_CAPACITY
	check_hydration_status()

func give_percent_hydration(give_percent: float) -> void:
	if (give_percent < 0 || give_percent > 1):
		print("Invalid water argument")
		return
	hydration += give_percent * WATER_CAPACITY
	check_hydration_status()


func give_proportional_hydration(boids_num: int, proportion: float) -> void:
	hydration += proportion * WATER_CAPACITY * boids_num / len(all_boids)
	check_hydration_status()

func check_hydration_status() -> void:
	if (hydration <= 0):
		hydration = 0
		#health_reached_zero.emit()
	elif (hydration >= WATER_CAPACITY):
		hydration = WATER_CAPACITY

#This is such a JANK way of doing this but...

func _ready() -> void:
	global_position.y = boid_properties.flockMaxHeight
	boid_properties.speed.add_modifier(hunger_modifier) 
	

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
		print("I'm changing scatter states")
		

func swoop(state: bool):
	pass


func toggle_landing(state: bool = !boid_properties.flockIsFlying):
	
	land_goal = get_mouse_world_position(camera_controller.camera_node)
	
	if state == boid_properties.flockIsFlying:
		print("same landing state, returning")
		return
	#print(state)
	boid_properties.flockIsFlying = state
	#print(boid_properties.flockIsFlying)
	#This is SUPPOSED to run when the Boid are flying in the air and you want them to land.
	if boid_properties.flockIsFlying:
		print("RISE FROM YOUR GRAVES!!!!! EHEHEHEHEHEH")
		boid_properties.flockIsLanded = false
		boid_properties.flockIsFlying = true
	else:
		global_position.y = boid_properties.flockMaxHeight
		print("The boids are supposed to land now.")
		boid_properties.scatter = false
		boid_properties.default_state = true
		


#this updates the flocks global position on the ground.
func flock_landed() -> void :
	
	var above_chunk: Chunk = Chunk.get_chunk_containing_global_position( land_goal );
	
	#If the above_chunk.global_position is null, throws you out by setting boid_properties.flockIsFlying == true
	if !is_instance_valid(above_chunk) :
		print("above_chunk.global_position is null")
		global_position.y = boid_properties.flockMaxHeight
		boid_properties.flockIsFlying = !boid_properties.flockIsFlying
	
	else :
		var relative_position: = land_goal - above_chunk.global_position;
		var horizontal: = Vector2( relative_position.x, relative_position.z );
		
		if above_chunk and above_chunk.is_height_accessible( horizontal ):
			global_position.y = above_chunk.global_position.y + above_chunk.get_height( above_chunk.heightmap_accessibility, horizontal );
			boid_properties.flockIsLanded = true
			#print(global_position.y) #PLEASE disable this, this clutters stuff up SO fast.

	

func _process(delta: float) -> void:
	#this allows for the boid's main goal to be updated later on. Maybe for a better flock split system??????
	#This IS not perfect, if I want the boids to split into subflocks, I need to give them functionality to do so... in their OWN script!
	update_cursor()

func update_cursor():
	flock_goal = get_cursor_pos()
	#global_position = get_cursor_pos()
	if cursor:
		cursor.global_position = get_cursor_pos()

func _physics_process(delta: float) -> void:
	#print(Global.flock.hydration)
	
	if boid_properties.flockIsFlying:
		hydration -= delta * water_depletion_rate
	
	# if flock is attempting to land and hasn't found a landing spot yet
	if boid_properties.flockIsFlying == false :
		flock_landed()
	
	if enable_hunger_effects:
		process_hunger(delta)

func process_hunger(delta: float):
	#in essence both of these if statements are decreasing the hunger
	if current_hunger > 0:
		current_hunger = max(0.0, current_hunger - starve_rate * delta)
		if current_hunger < 90.0:
			for boid in all_boids:
				var new_speed_mult = lerp(min_hunger_speed_penalty, 1.0, current_hunger / max_hunger)
				#hunger_modifier.modifier_value = new_speed_mult
				var modifier = boid_properties.speed.get_modifier("hunger_penalty")
				if modifier:
					modifier.modifier_value = new_speed_mult
					boid_properties.speed.update_value()
		else:
			hunger_modifier.modifier_value = 1
		
	#kill birds of starvation periodically
	if current_hunger < -starve_death_interval:
		print("starved")
		current_hunger = 0.0
		if len(all_boids) > 0:
			all_boids[0].kill_boid()

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
