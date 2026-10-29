extends RigidBody3D
class_name Boid

# How to use health system
# Currently, there are functions for registering damage (take_damage() and take_percent_damage()
# and healing (heal() and heal_percent()). take_damage() and heal() each take a specific value to subtract or
# add to the health respectively, while take_percent_damage() and heal_percent() each take a percent of the maximum health
# (as a decimal between 0 and 1) to subtract or add to the health respectively.  

# Flock Health Variables and Signals
const MAX_HEALTH: float = 100.0
var health = MAX_HEALTH

# 9/27/26 So far I've only added a signal that is emitted whenever the health is equal to zero,
# but feel free to add more. Just make sure to invoke it only from the check_heath_status() function in this script
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
	check_heath_status()

func take_percent_damage(percent_damage: float) -> void:
	if (percent_damage > 1.0 || percent_damage < 0 || health <= 0):
		print("Invalid damage argument or health has reached zero")
		return
	health -= percent_damage * MAX_HEALTH
	check_heath_status()

func heal(health_healed : float) -> void:
	health += health_healed;
	check_heath_status()

func heal_percent(heal_percent: float) -> void:
	if (heal_percent < 0 || heal_percent > 1):
		print("Invalid health argument")
		return
	health += heal_percent * MAX_HEALTH
	check_heath_status()

func check_heath_status() -> void:
	if (health <= 0):
		health = 0
		health_reached_zero.emit()
	elif (health >= MAX_HEALTH):
		health = MAX_HEALTH

signal boid_died(boid: Node, pos: Vector3)

@onready var flock: Flock = get_parent()
@onready var properties = flock.boid_properties
#TS makes the boids spin in a random direction so that they don't look so robotic.............. while in the stupid fucking split up mode.
var spin_direction: float = 1.0 if randf() > 0.5 else -1.0 

#stuff that was exported by the camera. THX gemini, I am lowkey retarded.
var cam_is_moving: bool:
	get: return Global.camera.cam_is_moving if (Global.camera and is_instance_valid(Global.camera)) else false

var move_direction: Vector3:
	get: return Global.camera.move_direction if (Global.camera and is_instance_valid(Global.camera)) else Vector3.ZERO

var death_particles = preload("res://modules/flock/death_particles.tscn")
var death_queued = false

# keep track of force applied for display
# reset after every physics frame
var wind_force: Vector3 = Vector3.ZERO

@onready var food_detector: Area3D = $FoodDetector

func _ready() -> void:
	#flock = get_parent() as Flock
	add_to_group("boids")
	food_detector.area_entered.connect(_on_food_detector_area_entered)

func _physics_process(delta: float) -> void:
	if !death_queued:
		boid_movement(delta)

func _on_food_detector_area_entered(area: Area3D) -> void:
	# Area3D is a child of the Food root node
	var food: Food = area.get_parent()
	# this stops several boids from eating the same food in one physics frame
	if not food is Food or food.eaten:
		return
	flock.eat(food.hunger_value)
	food.consumed()

func STAY_ON_SCREEN() -> Vector3 :
	var force : Vector3 = Vector3.ZERO
	var cam = Global.camera
	var window_size = get_viewport().get_visible_rect().size
	var margin := 100.0
	var boid_pos = cam.camera_node.unproject_position(global_position)
	
	#This is messy as hell, I'm sorry. But the old way I used to do it made them clump up like CRAZY
	var off_left = boid_pos.x < margin
	var off_right = boid_pos.x > window_size.x - margin
	var off_top = boid_pos.y < margin
	var off_bottom = boid_pos.y > window_size.y - margin
	
	if not (off_left or off_right or off_top or off_bottom):
		return Vector3.ZERO

	var cam_right = cam.global_transform.basis.x
	cam_right.y = 0
	cam_right = cam_right.normalized()
	
	var cam_forward = -cam.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	if off_left:
		force += cam_right * ((margin - boid_pos.x) / margin)
	elif off_right:
		force -= cam_right * ((boid_pos.x - (window_size.x - margin)) / margin)

	if off_top:
		force -= cam_forward * ((margin - boid_pos.y) / margin)
	elif off_bottom:
		force += cam_forward * ((boid_pos.y - (window_size.y - margin)) / margin)

	force.y = 0
	return force.normalized()

#I see, I'm going to change this so that if they get within this repel radius, they call the "flee" function, which forces the boid to fly a set distance 180 
func repel() -> Vector3:
	var offset := global_position - flock.flock_goal
	offset.y = 0
	var distance := offset.length()
	
	if distance > properties.repel_radius.value or distance < 0.001:
		return Vector3.ZERO
	
	if not properties.is_fleeing:
		properties.is_fleeing = true
		properties.flee_timer = properties.flee_duration.value
		properties.flee_direction = offset.normalized() 
	#if is_nan(offset.x):
		#print(offset)
		#print(global_position)
		#print(flock.boid_goal)
		
	return offset.normalized()

#flee/cowards function...
func _flee(delta: float) -> Vector3 :
	properties.flee_timer -= delta
	if properties.flee_timer <= 0 :
		properties.is_fleeing = false
		return Vector3.ZERO
	
	return properties.flee_direction

#seperation force calcualtions ... thx https://vanhunteradams.com/Pico/Animal_Movement/Boids-algorithm.html
func seperation(neighbors : Array) -> Vector3 :
	var sep_force : Vector3 = Vector3.ZERO
	if neighbors.size() == 0:
		return sep_force
	
	for boid in neighbors :
		var distance : float = global_position.distance_to(boid.global_position)
		if distance < properties.personal_space.value and distance > 0.1:
			var sep_direction = global_position - boid.global_position
			sep_force += sep_direction.normalized() / distance
	return sep_force

#alignment force
func alignment(neighbors : Array) -> Vector3 :
	var ali_force : Vector3 = Vector3.ZERO
	if neighbors.size() == 0:
		return ali_force
		
	for boid in neighbors :
		ali_force += boid.linear_velocity
	
	ali_force = (ali_force / neighbors.size()).normalized()
	return ali_force

#Cohesion force
func cohesion(neighbors : Array) -> Vector3 :
	var coh_force : Vector3 = Vector3.ZERO
	if neighbors.size() == 0:
		return coh_force
	
	for bird in neighbors :
		coh_force += bird.global_position
	
	coh_force /= neighbors.size()
	coh_force = global_position.direction_to(coh_force)
	return coh_force

#This is for the new force stuff related to the "repel mode shit"

#finding the center of a local flock
func local_center(neighbors: Array) -> Vector3 :
	var center_force : Vector3 = Vector3.ZERO
	if neighbors.size() == 0:
		return global_position
	
	for boid in neighbors :
		center_force += boid.global_position
	
	center_force = center_force / neighbors.size()
	return center_force

var debug_count : int = 0
func spinning(center: Vector3, neighbors: Array) -> Vector3:
	if neighbors.size() < properties.minimum_group_size.value :
		return Vector3.ZERO
	
	var offset = global_position - center
	var tangent = Vector3(-offset.z, 0, offset.x).normalized()
	return tangent * spin_direction

#This is WHERE THE MAGIC BEGINS, NO MORE CALCULATING BORING ASS VECTOR SHITS!!!!!!!!!

func boid_movement(delta: float):
	var camera_force : Vector3 = Vector3.ZERO
	if cam_is_moving :
		camera_force = move_direction * properties.cam_moving_weight.value
	
	var boids: Array[Boid] = flock.boids
	var neighbors : Array = []
	
	for other in boids:
		if other == self :
			continue
		var distance_to_boids : float = global_position.distance_to(other.global_position)
		if distance_to_boids < properties.perception_range.value:
			neighbors.append(other)
	
	var repel_force := Vector3.ZERO
	var goal_force : = Vector3.ZERO
	var flee_force := Vector3.ZERO 
	
	if properties.is_fleeing :
		flee_force = _flee(delta) * properties.flee_weight.value
	else :
		#heading towards the cursor/goal
		goal_force = global_position.direction_to(flock.flock_goal) * properties.goal_weight.value
	
	#seperation force
	var seperation_force : Vector3 = seperation(neighbors) * properties.seperate_weight.value
	#alignment force
	var alignment_force : Vector3 = alignment(neighbors) * properties.alignment_weight.value
	#cohesion_force
	var cohesion_force : Vector3 = cohesion(neighbors) * properties.cohesion_weight.value
	#staying on the freaking screen
	var stay_on_screen_force : Vector3 = STAY_ON_SCREEN() * properties.stay_on_screen_weight.value
	
	#CEO of BOID pathing 🔥
	# boid_direction is the combined target direction of the boid
	#print(str(self))
	var boid_direction : Vector3 = Vector3.ZERO
	boid_direction = (seperation_force + cohesion_force + flee_force + stay_on_screen_force)
	#print(boid_direction)
	
	#When the cursor is in spread out/repel mode the boids have slightly modified behaviors
	#the boids can ONLY SEPERATE IN THE AIR.
	if properties.scatter && (properties.flockIsLanded == false):
		repel_force = repel() * properties.repel_weight.value
		#when the camera is not moving, boids in large groups should start spinning in place.
		var boid_subflock_spin_force : Vector3 = Vector3.ZERO
		if cam_is_moving == false :
			boid_subflock_spin_force = spinning(local_center(neighbors), neighbors) * properties.spin_weight.value
		var spin_alignment = alignment_force * 0.2
		boid_direction += spin_alignment + camera_force + boid_subflock_spin_force + repel_force
	else :
		# goal force is normalized and scaled by the goal weight earlier in this function
		boid_direction += goal_force + alignment_force

	boid_direction.y = 0
	boid_direction = boid_direction.normalized()
	
	# The steering mode is the function that changes the boid's velocity according to boid_direction
	# They provide different modes of interpolation
	# (since directly setting the velocity to boid_direction looks unnatural)
	match properties.steering_mode:
		BoidProperties.STEERING_MODE.LERP:
			# The original steering mode. Simply lerp to the desired velocity from the current one.
			var vel: Vector3 = Vector3.ZERO
			if boid_direction.length_squared() > 0.001:
				vel = linear_velocity.lerp(boid_direction*properties.speed.value, properties.steering_smoothness.value * delta)
				vel.y = 0
				vel = vel.normalized() * properties.speed.value
			linear_velocity = vel
		BoidProperties.STEERING_MODE.STEERING_FORCE:
			var speed_bias = 1.5 # Does not change min or max speeds. Higher values make boids prefer higher speeds.
			var desired_velocity = boid_direction * properties.speed.value * speed_bias
			var steering = desired_velocity - linear_velocity
			#var speed_scaled = speed
			#if desired_velocity.length() != 0:
				##speed_scaled = pow(steering.length() / desired_velocity.length(), speed_scale_exp) * desired_velocity.length()
				#speed_scaled = speed
			#if is_nan(speed_scaled):
				#printerr("speed_scaled is NAN!!!!!")
				#speed_scaled = 0
			#steering.y = 0
			#print("printing")
			if steering != Vector3.ZERO:
				steering = steering.normalized() * clamp(steering.length(), properties.min_speed.value, speed_bias*properties.speed.value)
				#print(steering.length())
				#steering = steering.normalized() * speed
			else:
				# force the boid to go forward at min speed
				steering = -global_basis.z.normalized() * properties.min_speed.value
			
			apply_central_force(steering * mass)
			
			# clamp the speed to be between min speed and max speed
			linear_velocity = linear_velocity.normalized() * clamp(linear_velocity.length(), properties.min_speed.value, properties.speed.value)
			
			#print(linear_velocity.length())
			
			
		BoidProperties.STEERING_MODE.CONSTANT_SPEED:
			# Maintain a constant speed for the boid. Lerp for rotation.
			# Apply forces perpendicular to the velocity to turn the boid without affecting its speed.
			var target_dir = boid_direction.normalized()
			var current_dir = linear_velocity.normalized()
			if linear_velocity == Vector3.ZERO:
				# Make the boid move forward at constant speed in the direction it is facing
				linear_velocity = -global_basis.z * properties.speed.value
			else:
				var current_angle = target_dir.signed_angle_to(current_dir, Vector3.UP)
				var new_angle: float = lerp(current_angle, 0.0, properties.steering_strength.value * delta)
				linear_velocity = properties.speed.value * target_dir.rotated(Vector3.UP, new_angle)
			# ensure speed is constant
			linear_velocity = linear_velocity.normalized() * properties.speed.value
		BoidProperties.STEERING_MODE.CONSTANT_EVERYTHING:
			# constant linear speed and turning speed
			var target_dir = boid_direction.normalized()
			var current_dir = linear_velocity.normalized()
			if linear_velocity == Vector3.ZERO:
				# Make the boid move forward at constant speed in the direction it is facing
				linear_velocity = -global_basis.z * properties.speed.value
			else:
				var angle_to_target = linear_velocity.signed_angle_to(target_dir, Vector3.UP)
				if properties.steering_strength.value * delta >= abs(angle_to_target):
					linear_velocity = linear_velocity.length() * target_dir
				else:
					linear_velocity = linear_velocity.rotated(Vector3.UP, sign(angle_to_target) * properties.steering_strength.value * delta)
				#linear_velocity = lerp(angle_to_target, delta)
				#apply_torque(Vector3.UP * steering_strength * angle_to_target * inertia)
				#print(Vector3.UP * steering_strength * angle_to_target)
			linear_velocity = linear_velocity.normalized() * properties.speed.value
			#print(linear_velocity.length())
			
	
	# rotate node for display
	match properties.rotation_mode:
		BoidProperties.ROTATION_MODE.LERP_TO_VELOCITY:
			if linear_velocity.length_squared() > 0.001:
				# cancel the velocity contribution from wind
				var own_velocity = linear_velocity - wind_force*delta
				var target_rotation = Transform3D.IDENTITY.looking_at(own_velocity, Vector3.UP).basis
				target_rotation = target_rotation.orthonormalized()
				global_transform.basis = global_transform.basis.slerp(target_rotation, properties.rotation_smoothness.value * delta)
		BoidProperties.ROTATION_MODE.LERP_TO_GOAL:
			if boid_direction.length_squared() > 0.001:
				var target_rotation = Transform3D.IDENTITY.looking_at(boid_direction, Vector3.UP).basis
				target_rotation = target_rotation.orthonormalized()
				global_transform.basis = global_transform.basis.slerp(target_rotation, properties.rotation_smoothness.value * delta)
		BoidProperties.ROTATION_MODE.SNAP_TO_VELOCITY:
			if linear_velocity.length_squared() > 0.001:
				var target_pos = global_position + linear_velocity
				look_at(target_pos, Vector3.UP)
	
	wind_force = Vector3.ZERO
	

func kill_boid(death_animation: bool = true):
	# prevent this function from running multiple times
	if death_queued:
		return
	death_queued = true
	flock.remove_boid(self)
	
	if death_animation:
		var instance = death_particles.instantiate()
		add_child(instance)
		instance.global_position = self.global_position
		instance.start_animation()
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 1.0)
		tween.tween_callback(queue_free)
	
	boid_died.emit(self, global_position)

# Move the boid to a new flock and adjust the boids and all_boids variables accordingly.
# This boid should be in the boids variable of only the subflock if split.
# This boid should be in all_boids for the main flock even when in a subflock.
func transfer_to_flock(new_flock: Flock):
	if new_flock == flock:
		return
	flock.boids.erase(self)
	flock.all_boids.erase(self)
	if self not in new_flock.boids:
		new_flock.boids.append(self)
	if self not in new_flock.all_boids:
		new_flock.all_boids.append(self)
	if new_flock in flock.subflocks:
		flock.all_boids.append(self)
	
	flock = new_flock
	debug_flock_display(new_flock)

func debug_flock_display(flock: Flock):
	# for debug
	$Label3D.text = str(flock)
	var random = RandomNumberGenerator.new()
	random.seed = flock.get_instance_id()
	$MeshInstance3D.mesh = $MeshInstance3D.mesh.duplicate()
	$MeshInstance3D.mesh.material = $MeshInstance3D.mesh.material.duplicate()
	$MeshInstance3D.mesh.material.albedo_color = Color.from_hsv(random.randf(), 0.5, 1.0)
	
	
