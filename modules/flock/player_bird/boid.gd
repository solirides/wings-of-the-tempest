extends CharacterBody3D
class_name Boid

@export var speed : float = 5
@export var perception_range : float = 8
@export var personal_space : float = 4

@export var seperate_weight : float = 2
@export var alignment_weight : float = 1
@export var cohesion_weight : float = 1
@export var goal_weight : float = 1.2

@export var repel_radius: float = 5.0
@export var repel_weight: float = 5.0

var flock: Flock
var vel : Vector3 = Vector3.ZERO
@export var steering_smoothness: float = 8.0
@export var rotation_smoothness: float = 8.0

func _ready() -> void:
	flock = get_parent() as Flock
	add_to_group("boids")

func repel() -> Vector3:
	var offset := global_position - flock.mouse_target
	offset.y = 0
	var distance := offset.length()
	
	if distance > repel_radius or distance < 0.001:
		return Vector3.ZERO
	return offset.normalized()

#seperation force calcualtions ... thx https://vanhunteradams.com/Pico/Animal_Movement/Boids-algorithm.html you FUCKERS, KILLYOURSELFES
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

func _physics_process(delta: float) -> void:
	#seeing whose arround who
	#var boids : Array = get_tree().get_nodes_in_group("boids")
	var boids: Array[Boid] = flock.boids
	var neighbors : Array = []
	
	for other in boids:
		if other == self :
			continue
		
		var distance_to_boids : float = global_position.distance_to(other.global_position)
		
		if distance_to_boids < perception_range:
			neighbors.append(other)
	
	var repel_force := Vector3.ZERO
	if Input.is_action_pressed("repel"):
		repel_force = repel() * repel_weight
	#heading towards the cursor
	var cursor_force : Vector3 = global_position.direction_to(flock.mouse_target) * goal_weight
	#seperation force
	var seperation_force : Vector3 = seperation(neighbors) * seperate_weight
	#alignment force
	var alignment_force : Vector3 = alignment(neighbors) * alignment_weight
	#cohesion_force
	var cohesion_force : Vector3 = cohesion(neighbors) * cohesion_weight
	
	
	#CEO of BOID pathing 🔥
	var boid_direction = (cursor_force + seperation_force + alignment_force + cohesion_force + repel_force).normalized()
	
	#print("I'm changing directions")
	
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
