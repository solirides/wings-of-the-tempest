extends CharacterBody3D
class_name Boid

@export var speed : float = 15
@export var perception_range : float = 8
@export var personal_space : float = 4

@export var seperate_weight : float = 2
@export var alignment_weight : float = 1
@export var cohesion_weight : float = 1
@export var goal_weight : float = 1.2
@export var stay_on_screen_weight : float = 999
@export var cam_moving_weight : float = 2.5


@export var repel_radius: float = 5.0
@export var repel_weight: float = 5.0

#coward shit
@export var flee_weight: float = 4.5
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

#TS makes the boids spin in a random direction so that they don't look so robotic.............. while in the stupid fucking split up mode.
var spin_direction: float = 1.0 if randf() > 0.5 else -1.0 

#stuff that was exported by the camera. THX gemini, I am lowkey retarded.
var cam_is_moving: bool:
	get: return Global.camera.cam_is_moving if (Global.camera and is_instance_valid(Global.camera)) else false

var move_direction: Vector3:
	get: return Global.camera.move_direction if (Global.camera and is_instance_valid(Global.camera)) else Vector3.ZERO

func _ready() -> void:
	flock = get_parent() as Flock
	add_to_group("boids")

func STAY_ON_SCREEN() -> Vector3 :
	
	var force : Vector3 = Vector3.ZERO
	
	var cam = Global.camera
	var window_size = get_viewport().get_visible_rect().size
	
	var margin := 100.0
	var boid_pos = cam.unproject_position(global_position)
	
	if (boid_pos.x < margin or boid_pos.x > window_size.x - margin or boid_pos.y < margin or boid_pos.y > window_size.y - margin):
		var center_world = cam.project_position(window_size * 0.5, cam.global_position.distance_to(global_position))
		center_world.y = 0
		force = global_position.direction_to(center_world).normalized()
	
	return force

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
		cursor_force = global_position.direction_to(flock.mouse_target) * goal_weight
	
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
	
	#When the cursor is in spread out/repel mode the boids have slightly modified behaviors
	if Input.is_action_pressed("repel"):
		repel_force = repel() * repel_weight
		#when the camera is not moving, boids in large groups should start spinning in place.
		var boid_subflock_spin_force : Vector3 = spinning(local_center(neighbors), neighbors) * spin_weight
		var spin_alignment = alignment_force * 0.2
		
		
		boid_direction = (seperation_force + spin_alignment + cohesion_force + repel_force + flee_force + stay_on_screen_force + camera_force + boid_subflock_spin_force).normalized()

	#THIS IS THE START OF THE BOID FOLLOWING THE CURSOR BEHAVIOR!
	else :
		boid_direction = (cursor_force + seperation_force + alignment_force + cohesion_force + repel_force + flee_force + stay_on_screen_force).normalized()
	
	#movement/"looking"
	# added lerp/slerp to get rid of some jitter
	boid_direction.y = 0
	if boid_direction.length_squared() > 0.001:
		boid_direction = boid_direction.normalized()
		vel = vel.lerp(boid_direction, steering_smoothness * delta)
		vel.y = 0
		vel = vel.normalized()
	
	velocity = vel * speed
	move_and_slide()
	#global_position += vel * speed * delta
	
	if vel.length_squared() > 0.001:
		var target_rotation = Transform3D().looking_at(vel, Vector3.UP).basis
		global_transform.basis = global_transform.basis.slerp(target_rotation, rotation_smoothness * delta)

func remove_boid():
	flock.boids.erase(self)
	queue_free()
	
#split up capability. I.G. when the mouse is repelling them they group up and spin in their own groups. These groups will head towards the direction the camera is moving if the person is still in split up mode.
