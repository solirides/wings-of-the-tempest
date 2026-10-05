extends RigidBody3D
class_name Boid
const default_speed : float = 5.0
@export var speed : float = 15
@export var min_speed : float = 2
@export var speed_scale_exp: float = 1.0
@export var perception_range : float = 8
@export var personal_space : float = 4

@export var seperate_weight : float = 2
@export var alignment_weight : float = 1
@export var cohesion_weight : float = 1
@export var goal_weight : float = 1.2
@export var stay_on_screen_weight : float = 2
@export var cam_moving_weight : float = 1.2


@export var repel_radius: float = 5.0
@export var repel_weight: float = 5.0

#coward shit
@export var flee_weight: float = 2.1
@export var is_fleeing: bool = false
@export var flee_timer: float = 0.0
@export var flee_duration: float = 3 #3 seconds
@export var flee_direction: Vector3 = Vector3.ZERO

#split up sub group stuff
@export var spin_weight : float = 1
@export var minimum_group_size : float = 5

var flock: Flock
var vel : Vector3 = Vector3.ZERO
@export var steering_smoothness: float = 8.0
@export var rotation_smoothness: float = 8.0

@export var steering_mode:STEERING_MODE = STEERING_MODE.LERP
@export var rotation_mode:ROTATION_MODE = ROTATION_MODE.LERP
@onready var food_detector: Area3D = $FoodDetector

enum STEERING_MODE {
	LERP,
	STEERING_FORCE
}

enum ROTATION_MODE {
	NONE,
	LERP
}

#TS makes the boids spin in a random direction so that they don't look so robotic.............. while in the stupid fucking split up mode.
var spin_direction: float = 1.0 if randf() > 0.5 else -1.0 

#stuff that was exported by the camera. THX gemini, I am lowkey retarded.
var cam_is_moving: bool:
	get: return Global.camera.cam_is_moving if (Global.camera and is_instance_valid(Global.camera)) else false

var move_direction: Vector3:
	get: return Global.camera.move_direction if (Global.camera and is_instance_valid(Global.camera)) else Vector3.ZERO

var death_particles = preload("res://modules/flock/death_particles.tscn")
var death_queued = false

signal boid_died(boid: Node, pos: Vector3)

func _ready() -> void:
	flock = get_parent() as Flock
	add_to_group("boids")
	food_detector.area_entered.connect(_on_food_detector_area_entered)
	
func _on_food_detector_area_entered(area: Area3D) -> void:
	# Area3D is a child of the Food root node
	var food: Food = area.get_parent()
	# this stops several boids from eating the same food in one physics frame
	if not food is Food or food.is_queued_for_deletion():
		return
	flock.eat(food.hunger_value)
	food.queue_free()

func STAY_ON_SCREEN() -> Vector3 :
	
	var force : Vector3 = Vector3.ZERO
	
	var cam = Global.camera
	var window_size = get_viewport().get_visible_rect().size
	
	var margin := 100.0
	var boid_pos = cam.unproject_position(global_position)
	
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
	var offset := global_position - flock.mouse_target
	offset.y = 0
	var distance := offset.length()
	
	if distance > repel_radius or distance < 0.001:
		return Vector3.ZERO
	
	#fleeing, only applicable when the "Flee Button" is pressed.
	if Input.is_action_pressed("repel") and not is_fleeing :
		is_fleeing = true
		flee_timer = flee_duration
		flee_direction = offset.normalized() 
	
	return offset.normalized()
	
#flee/cowards function...
func _flee(delta: float) -> Vector3 :
	flee_timer -= delta
	if flee_timer <= 0 :
		is_fleeing = false
		return Vector3.ZERO
	
	return flee_direction

#seperation force calcualtions ... thx https://vanhunteradams.com/Pico/Animal_Movement/Boids-algorithm.html
func seperation(neighbors : Array) -> Vector3 :
	var sep_force : Vector3 = Vector3.ZERO
	if neighbors.size() == 0:
		return sep_force
	
	for boid in neighbors :
		var distance : float = global_position.distance_to(boid.global_position)
		
		if distance < personal_space and distance > 0.1:
			var sep_direction = global_position - boid.global_position
			sep_force += sep_direction.normalized() / distance
	return sep_force

#alignment force
func alignment(neighbors : Array) -> Vector3 :
	var ali_force : Vector3 = Vector3.ZERO
	if neighbors.size() == 0:
		return ali_force
		
	for boid in neighbors :
		ali_force += boid.vel
	
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
	
	for boids in neighbors :
		center_force += boids.global_position
	
	center_force = center_force / neighbors.size()
	
	return center_force

func spinning(center: Vector3, neighbors: Array) -> Vector3:
	if neighbors.size() < minimum_group_size :
		return Vector3.ZERO
	
	var offset = global_position - center
	var tangent = Vector3(-offset.z, 0, offset.x).normalized()
	
	return tangent * spin_direction

#This is WHERE THE MAGIC BEGINS, NO MORE CALCULATING BORING ASS VECTOR SHITS!!!!!!!!!
func _physics_process(delta: float) -> void:
	if !death_queued:
		boid_movement(delta)

func boid_movement(delta: float):
	#seeing whose arround who
	#var boids : Array = get_tree().get_nodes_in_group("boids")
	
	#biggest change yet IMO, they no longer target the cursor if the camera is moving!
	var camera_force : Vector3 = Vector3.ZERO
	if cam_is_moving :
		camera_force = move_direction * cam_moving_weight
	
	var boids: Array[Boid] = flock.boids
	var neighbors : Array = []
	
	for other in boids:
		if other == self :
			continue
		
		var distance_to_boids : float = global_position.distance_to(other.global_position)
		
		if distance_to_boids < perception_range:
			neighbors.append(other)
	
	var repel_force := Vector3.ZERO
	var cursor_force : = Vector3.ZERO

		
	var flee_force := Vector3.ZERO 
	if is_fleeing :
		flee_force = _flee(delta) * flee_weight
	
	else :
		#heading towards the cursor
		cursor_force = global_position.direction_to(flock.mouse_target) * goal_weight
	
	#seperation force
	var seperation_force : Vector3 = seperation(neighbors) * seperate_weight
	#alignment force
	var alignment_force : Vector3 = alignment(neighbors) * alignment_weight
	#cohesion_force
	var cohesion_force : Vector3 = cohesion(neighbors) * cohesion_weight
	#staying on the freaking screen
	var stay_on_screen_force : Vector3 = STAY_ON_SCREEN() * stay_on_screen_weight
	
	#CEO of BOID pathing 🔥
	var boid_direction : Vector3 = Vector3.ZERO
	boid_direction = (seperation_force + cohesion_force + repel_force + flee_force + stay_on_screen_force)
	
	#When the cursor is in spread out/repel mode the boids have slightly modified behaviors
	if Input.is_action_pressed("repel"):
		repel_force = repel() * repel_weight
		#when the camera is not moving, boids in large groups should start spinning in place.
		var boid_subflock_spin_force : Vector3 = Vector3.ZERO
		
		if cam_is_moving == false :
			boid_subflock_spin_force = spinning(local_center(neighbors), neighbors) * spin_weight
		var spin_alignment = alignment_force * 0.2
		
		
		boid_direction += spin_alignment + camera_force + boid_subflock_spin_force

	#THIS IS THE START OF THE BOID FOLLOWING THE CURSOR BEHAVIOR!
	else :
		boid_direction += cursor_force + alignment_force
	boid_direction = boid_direction.normalized()
	
	var velocity_to_add = Vector3.ZERO
	#movement/"looking"
	# added lerp/slerp to get rid of some jitter
	match steering_mode:
		STEERING_MODE.LERP:
			boid_direction.y = 0
			if boid_direction.length_squared() > 0.001:
				boid_direction = boid_direction.normalized()
				vel = vel.lerp(boid_direction, steering_smoothness * delta)
				vel.y = 0
				vel = vel.normalized()
			
			linear_velocity = vel * speed
			#velocity_to_add = vel * speed
			#apply_central_force((velocity_to_add - linear_velocity) * mass)
		STEERING_MODE.STEERING_FORCE:
			boid_direction.y = 0
			if boid_direction.length_squared() > 0.001:
				boid_direction = boid_direction.normalized()
			var desired_velocity = boid_direction * speed
			var steering = desired_velocity - linear_velocity
			var speed_scaled = pow(steering.length() / desired_velocity.length(), speed_scale_exp) * desired_velocity.length()
			steering = steering.normalized() * speed_scaled
			steering.y = 0
			#steering.normalized() * speed
			
			#steering = steering.limit_length(delta * steering_smoothness)
			
			#velocity_to_add += steering
			#velocity_to_add = velocity_to_add.limit_length(speed)
			steering = steering.limit_length(speed)
			# why is there no limit_length for minimum length???
			if linear_velocity.length() < min_speed:
				steering = steering.normalized() * min_speed
			
			vel = steering.normalized()
			apply_central_force(steering * mass)
	
	#move_and_slide()
	
	# rotate node for display
	match rotation_mode:
		ROTATION_MODE.LERP:
			if vel.length_squared() > 0.001:
				var target_rotation = Transform3D().looking_at(vel, Vector3.UP).basis
				global_transform.basis = global_transform.basis.slerp(target_rotation, rotation_smoothness * delta)
		ROTATION_MODE.NONE:
			# no interpolation
			if linear_velocity.length_squared() > 0.001:
				var target_pos = global_position + linear_velocity
				look_at(target_pos, Vector3.UP)

func remove_boid(death_animation: bool = true):
	# prevent this function from running multiple times
	if death_queued:
		return
	death_queued = true
	flock.boids.erase(self)
	if death_animation:
		var instance = death_particles.instantiate()
		#get_tree().root.add_child(instance)
		add_child(instance)
		instance.global_position = self.global_position
		instance.start_animation()
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 1.0)
		tween.tween_callback(queue_free)
	
	boid_died.emit(self, global_position)
	
