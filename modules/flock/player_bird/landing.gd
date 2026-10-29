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
	
	var chunk = Chunk.get_chunk_containing_global_position(boid.global_position)
	if boid.global_position.y < (chunk.global_position.y - 0.1):
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
	boid.properties.speed.value = 5
	boid.properties.min_speed.value = 1
	
	# Goofy funny stuff to show the boids are landed
	model.rotation.x = deg_to_rad(90) 
	hitbox.rotation.x = deg_to_rad(90)
	
	if boid.global_position.distance_to(boid.flock.flock_goal) < 1:
		boid.properties.speed.value = 0
		
	print(boid.properties.speed, " that was speed, this is height: ", boid.global_position.y)
	
	#for neighbor in boid.neighbors:
		#if neighbor and is_instance_valid(neighbor):
			#if boid.global_position.distance_to(neighbor.global_position) < 4:
				#if neighbor.properties.speed.value == 0:
				#	boid.properties.speed.value = 0
					#break
