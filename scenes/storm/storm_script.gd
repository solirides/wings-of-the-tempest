extends Area3D

@export var storm_direction: Vector3 = Vector3(-0.7071, 0.0, -0.7071) #unit vector @ 45 degrees
@export var storm_speed: float = 4 #Arbitray value for now 5.0
@export var storm_damage: float = 0.001 
#percent of MAX_HEALTH that gets taken away every frame a boid is in the storm

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#global_position = Vector3(-25.0, 0.0, -25.0) #sets starting pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_storm(delta)
	damage_boid()

#Used to move storm across the level
#Could use a path in the future
func move_storm(delta: float) -> void:
	global_position += storm_direction * storm_speed * delta

#damages any boids within the hitbox
func damage_boid() -> void:
	var overlapping_bodies: Array[Node3D] = get_overlapping_bodies()
	#print('in damage function!')
	for n in overlapping_bodies:
		#print("In for loop!")
		if  n is Boid:
			n.take_percent_damage(storm_damage)
			#print("Boid Damaged!")
			#print(n.get_health())
