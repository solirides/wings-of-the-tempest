extends Area3D


const STORM_DIRECTION: Vector3 = Vector3(0.7071, 0.0, 0.7071) #unit vector @ 45 degrees
const STORM_SPEED: float = 5.0 #Arbitray value for now
# could become a variable and increase speed?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Vector3(-25.0, 0.0, -25.0) #sets starting pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_storm(delta)

#Used to move storm across the level
#Could use a path in the future
func move_storm(delta: float) -> void:
	global_position += STORM_DIRECTION * STORM_SPEED * delta

#damages any boids within the hitbox
func damage_boid() -> void:
	pass
