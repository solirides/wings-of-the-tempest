extends Area3D # Controls bullet.tscn

# Adjustable flight settings
@export var flight_time: float = 1.5
@export var arc_height: float = 2.0

# Tracks the bullet's flight from launch to landing
var start_pos: Vector3
var end_pos: Vector3
var elapsed: float = 0.0

func launch(from: Vector3, to: Vector3) -> void:
	# Store where the bullet starts and where it's headed
	start_pos = from
	end_pos = to
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

	# Once the flight is finished, remove the bullet
	if t >= 1.0:
		queue_free()
