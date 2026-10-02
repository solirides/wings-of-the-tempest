extends Node3D

var cursor : Node3D

@export var speed : float = 5
@export var perception_range : float = 8
@export var personal_space : float = 4

@export var seperate : float = 2
@export var alignment : float = 1
@export var cohesion : float = 1
@export var goal : float = 1.2

@onready var ray_cast : RayCast3D = $RayCast3D

var velocity : Vector3 = Vector3.ZERO

func _ready() -> void:
	cursor = get_tree().get_first_node_in_group("boid_movement") as Node3D
	add_to_group("boids")
	print("Found cursor: " , cursor)

#seperation force calcualtions ... thx https://vanhunteradams.com/Pico/Animal_Movement/Boids-algorithm.html you FUCKERS, KILLYOURSELFES
func _divorceForce(neighbors : Array) -> Vector3 :
	var sep_force : Vector3 = Vector3.ZERO
	
	for boid in neighbors :
		var distance : float = global_position.distance_to(boid.global_position)
		
		if distance < personal_space :
			var sep_direction = global_position - boid.global_position
			sep_force += sep_direction.normalized() / distance
	
	return sep_force

#alignment force
func _oneGOAL(neighbors : Array) -> Vector3 :
	var ali_force : Vector3 = Vector3.ZERO
	
	for boid in neighbors :
		ali_force += boid.velocity
	
	ali_force = (ali_force / neighbors.size()).normalized()
	
	return ali_force

#Cohesion force
func _L4D(neighbors : Array) -> Vector3 :
	var coh_force : Vector3 = Vector3.ZERO
	
	for bird in neighbors :
		coh_force += bird.global_position
	
	coh_force /= neighbors.size()
	coh_force = global_position.direction_to(coh_force)
	
	return coh_force

#the FUNNNNNNNNNNN
func _process(delta: float) -> void:
	
	#seeing whose arround who
	var boids : Array = get_tree().get_nodes_in_group("boids")
	var neighbors : Array = []
	
	for other in boids:
		if other == self :
			continue
		
		var distance_to_boids : float = global_position.distance_to(other.global_position)
		
		if distance_to_boids < perception_range:
			neighbors.append(other)
	
	#heading towards the cursor
	var cursor_force : Vector3 = global_position.direction_to(cursor.global_position) * goal
	#seperation force
	var seperation_force : Vector3 = _divorceForce(neighbors) * seperate
	#alignment force
	var alignment_force : Vector3 = _oneGOAL(neighbors) * alignment
	#cohesion_force
	var cohesion_force : Vector3 = _L4D(neighbors) * cohesion
	
	#CEO of BOID pathing
	var boid_Direction = (cursor_force + seperation_force + alignment_force + cohesion_force).normalized()
	#print("I'm changing directions")
	
	#movement/"looking"
	global_position += boid_Direction * speed * delta
	if boid_Direction.length_squared() > 0.001:
		look_at(global_position + boid_Direction, Vector3.UP)
	
