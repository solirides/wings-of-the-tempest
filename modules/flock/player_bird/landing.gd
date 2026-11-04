extends Node3D
class_name Landing

enum STATE {FLYING, LANDING, LANDED, RISING}

var current_state : STATE = STATE.FLYING
@onready var boid : Boid = get_parent()
@onready var model = boid.get_node("bird")
@onready var hitbox = boid.get_node("CollisionShape3D")

func _physics_process(delta: float) -> void:
	#print("IS landing running?")
	#print(current_state)
	if boid == null:
		queue_free()
		return
	if boid.properties.flockIsLanded:
		if current_state == STATE.FLYING:
			current_state = STATE.LANDING
			
	if boid.properties.flockIsFlying:
		if current_state == STATE.LANDED or current_state == STATE.LANDING:
			boid.properties.speed.value = 15
			boid.properties.min_speed.value = 5
			current_state = STATE.RISING

	#Execute logic depending on what state the boid is currently in
	match current_state:
		STATE.FLYING:
			#print("flying")
			pass
			
		STATE.LANDING:
			#print("I am landing")
			landing(delta)
			
		STATE.LANDED:
			#print("I've landed")
			landed(delta)
			
		STATE.RISING:
			#print("I'm rising into the sky!!!!!!!")
			rising(delta)

# FUN FUNCTION STUFF!!!
func landing(delta: float) -> void:
	var target_pitch_rad : float = deg_to_rad(boid.properties.landing_angle)
	var original_angle : Basis = boid.global_basis
	
	var new_angle : Basis = original_angle.rotated(original_angle.x.normalized(), -target_pitch_rad)
	boid.global_basis = boid.global_basis.slerp(new_angle, boid.properties.rotation_smoothness.value * delta)
	
	var forward_dir = -boid.global_basis.z 
	boid.global_position += forward_dir * boid.properties.speed.value * delta
	
	var terrain_height = touch_grass() #touch grass is a helper function because DEAR GOD!!!!!!!!!!!!
	if boid.global_position.y <= (terrain_height + 0.1):
		current_state = STATE.LANDED
	
func rising(delta: float) -> void:
	var target_pitch_rad : float = deg_to_rad(45)
	var original_angle : Basis = boid.global_basis
	
	var new_angle : Basis = original_angle.rotated(original_angle.x.normalized(), target_pitch_rad)
	global_basis = boid.global_basis.slerp(new_angle, boid.properties.rotation_smoothness.value * delta)
	
	var forward_dir = -boid.global_basis.z
	boid.global_position += forward_dir * boid.properties.speed.value * delta
	boid.global_position.y += boid.properties.speed.value * 0.5 * delta
	
	if boid.global_position.y >= boid.properties.flockMaxHeight:
		#boid.global_basis = global_basis.slerp(original_angle, boid.properties.rotation_smoothness.value * delta)
		current_state = STATE.FLYING
	
func landed(delta: float) -> void:
	
	# Goofy funny stuff to show the boids are landed, doesn't work :(
	model.rotation.x = deg_to_rad(90) 
	hitbox.rotation.x = deg_to_rad(90)
	
	boid.global_position.y = touch_grass()
	
	if boid.global_position.distance_to(boid.flock.flock_goal) > 5:
		boid.properties.speed.value = 1
		boid.properties.min_speed.value = 0.1
		
	else :
		#print("I am within 1 meter of the goal")
		boid.properties.speed.value = 0
		boid.properties.min_speed.value = 0
		boid.move_direction = Vector3.ZERO
		boid.linear_velocity = Vector3.ZERO
		
		#print("Speed right after setting: ", boid.properties.speed.value) #WHY THE FUCK IS THIS NOT DOING ANYTHING?
		
	#print(boid.properties.speed, " that was speed, this is height: ", boid.global_position.y)

#Helper function which should keep the boids stuck to the ground.
func touch_grass() -> float:
	var above_chunk = Chunk.get_chunk_containing_global_position(boid.global_position)
	if !is_instance_valid(above_chunk) :
		print("Failed to land at position: ", global_position )
		return boid.flockMaxHeight #This is not ideal since it still crashes... but uhhhh
	
	var relative_position: Vector3 = boid.global_position - above_chunk.global_position;
	var horizontal: = Vector2( relative_position.x, relative_position.z );
	
	if above_chunk.is_height_accessible( horizontal ):
		var terrain_height = above_chunk.global_position.y + above_chunk.get_height( above_chunk.heightmap_accessibility, horizontal );
		return terrain_height
	
	return boid.flockMaxHeight
