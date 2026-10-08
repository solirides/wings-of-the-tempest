extends Area3D # Controls bullet.tscn

# Adjustable flight settings
@export var flight_time: float = 0.8
@export var arc_height: float = 0.5
# How close the bullet needs to get to its target to count as a hit
@export var hit_radius: float = 0.6

# Tracks the bullet's flight from launch to landing
var start_pos: Vector3
var end_pos: Vector3
var elapsed: float = 0.0
# The boid this bullet is chasing, if it's still around
var target: Node3D = null

func launch(from: Vector3, to: Vector3, target_boid: Node3D = null) -> void:
	# Store where the bullet starts and where it's headed
	start_pos = from
	end_pos = to
	# Remember which boid we're after, so we can check for a hit later
	target = target_boid
	# Snap the bullet to the launch point right away
	global_position = from

func _physics_process(delta: float) -> void:
	# Track how long the bullet has been in the air
	elapsed += delta
	# Progress through the flight, from 0.0 at launch to 1.0 at landing
	var t = clamp(elapsed / flight_time, 0.0, 1.0)
	
	# Straight-line position between start and end at this point in time
	var flat_pos = start_pos.lerp(end_pos, t)
	# Add the arc on top, 0 at the start and end, tallest at the midpoint
	flat_pos.y += arc_height * 4.0 * t * (1.0 - t)
	global_position = flat_pos
	
	# If the boid's still alive and we're close enough, count it as a hit
	if is_instance_valid(target) and global_position.distance_to(target.global_position) <= hit_radius:
		target.kill_boid()
		queue_free()
		return
	
	# Once the flight is finished with no hit, remove the bullet
	if t >= 1.0:
		queue_free()
