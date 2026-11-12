extends Node3D
class_name Landing

enum STATE {FLYING, LANDING, LANDED, RISING}
enum landedSTATE {MOVE, STOP}

var current_state : STATE = STATE.FLYING
var groundedState : landedSTATE = landedSTATE.MOVE
@onready var boid : Boid = get_parent()
@onready var model = boid.get_node("bird")
@onready var hitbox = boid.get_node("CollisionShape3D")

var last_flock_state = BoidProperties.FLOCK_STATE.FLYING

func _physics_process(delta: float) -> void:
	if boid == null:
		queue_free()
		return
	match boid.properties.flock_state:
		BoidProperties.FLOCK_STATE.FLYING:
			if last_flock_state == BoidProperties.FLOCK_STATE.SWOOPING:
				# TODO: replace with StatModifier
				boid.properties.speed.value = 15
				boid.properties.min_speed.value = 5
				current_state = STATE.RISING
		BoidProperties.FLOCK_STATE.SWOOPING:
			if last_flock_state == BoidProperties.FLOCK_STATE.FLYING:
				current_state = STATE.LANDING
	last_flock_state = boid.properties.flock_state
	#if boid.properties.flockIsLanded:
		#if current_state == STATE.FLYING:
			#current_state = STATE.LANDING
			#
	#if boid.properties.flockIsFlying:
		#if current_state == STATE.LANDED or current_state == STATE.LANDING:
			#boid.properties.speed.value = 15
			#boid.properties.min_speed.value = 5
			#current_state = STATE.RISING

	match current_state:
		STATE.FLYING:
			pass
		STATE.LANDING:
			landing(delta)
		STATE.LANDED:
			landed(delta)
		STATE.RISING:
			rising(delta)

func landing(delta: float) -> void:
	var target_pitch_rad : float = deg_to_rad(boid.properties.landing_angle)
	var original_angle : Basis = boid.global_basis
	
	var new_angle : Basis = original_angle.rotated(original_angle.x.normalized(), -target_pitch_rad)
	boid.global_basis = boid.global_basis.slerp(new_angle, boid.properties.rotation_smoothness.value * delta)
	
	var forward_dir = -boid.global_basis.z 
	boid.global_position += forward_dir * boid.properties.speed.value * delta
	
	var terrain_height = touch_grass() 
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
		current_state = STATE.FLYING
	
func landed(delta: float) -> void:
	#model.rotation.x = deg_to_rad(90) 
	#hitbox.rotation.x = deg_to_rad(90)
	
	boid.global_position.y = touch_grass()
	
	match groundedState:
		landedSTATE.MOVE:
			if boid.global_position.distance_to(boid.flock.flock_goal) > 5:
				boid.properties.speed.value = 1
				boid.properties.min_speed.value = 0.1
			else:
				groundedState = landedSTATE.STOP
		landedSTATE.STOP:
			if not is_any_boid_near_goal() :
				groundedState = landedSTATE.MOVE
			elif boid.global_position.distance_to(boid.flock.flock_goal) < 5 or stopped_boid_neighbors():
				boid.properties.speed.value = 0
				boid.properties.min_speed.value = 0
				boid.move_direction = Vector3.ZERO
				boid.linear_velocity = Vector3.ZERO
			else:
				groundedState = landedSTATE.MOVE

#checks if any neighboring boids are stopped and then stops the boid.
func stopped_boid_neighbors() -> bool:
	for neighbor in boid.flock.boids: 
		if neighbor == boid:
			continue 
			
		var neighbor_landing = neighbor.get_node_or_null("Landing")
		if neighbor_landing and neighbor_landing.groundedState == landedSTATE.STOP:
			if boid.global_position.distance_to(neighbor.global_position) < 10:
				return true
	return false

# Checks if ANY boid in is within 5m of the boid_goal
func is_any_boid_near_goal() -> bool:
	for neighbor in boid.flock.boids:
		if neighbor.global_position.distance_to(boid.flock.flock_goal) < 5:
			return true
	return false

#helper function which updates the boids y-pos based on the terrain height.
func touch_grass() -> float:
	var above_chunk = Chunk.get_chunk_containing_global_position(boid.global_position)
	if !is_instance_valid(above_chunk):
		print("Failed to land at position: ", global_position)
		return boid.properties.flockMaxHeight 
	
	var relative_position: Vector3 = boid.global_position - above_chunk.global_position
	var horizontal := Vector2(relative_position.x, relative_position.z)
	
	if above_chunk.is_height_accessible(horizontal):
		var terrain_height = above_chunk.global_position.y + above_chunk.get_height(above_chunk.heightmap_accessibility, horizontal)
		return terrain_height
	
	return boid.properties.flockMaxHeight
