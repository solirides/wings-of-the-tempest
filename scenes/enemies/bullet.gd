extends Area3D # Controls bullet.tscn

# Adjustable flight settings
@export var flight_time: float = 0.8
@export var arc_height: float = 0.5
# How close the bullet needs to get to a boid to count as a hit
@export var hit_radius: float = 0.6
# How many dots to draw along the path
@export var trail_dots: int = 8
# Radius of each dot
@export var dot_radius: float = 0.1

# The bullet's mesh, hidden while the hunter is charging
@onready var bullet_mesh: MeshInstance3D = $MeshInstance3D

# Tracks the bullet's flight from launch to landing
var start_pos: Vector3
var end_pos: Vector3
var elapsed: float = 0.0
# The boid this bullet was aimed at
var target: Node3D = null
# The dots showing the path ahead of the bullet
var dots: Array[MeshInstance3D] = []
# False while the hunter is charging, true once the bullet is in the air
var flying: bool = false

func _ready() -> void:
	# Hide the bullet itself until it's fired
	bullet_mesh.visible = false
	# Build the dots once
	make_trail()

func make_trail() -> void:
	# One sphere mesh shared by every dot
	var dot_mesh := SphereMesh.new()
	dot_mesh.radius = dot_radius
	dot_mesh.height = dot_radius * 2.0
	for i in trail_dots:
		var dot := MeshInstance3D.new()
		dot.mesh = dot_mesh
		# Keep the dot in the world instead of moving with the bullet
		dot.top_level = true
		add_child(dot)
		dots.append(dot)

func aim(from: Vector3, to: Vector3, target_boid: Node3D = null) -> void:
	# Update the planned path while the hunter is charging
	start_pos = from
	end_pos = to
	target = target_boid
	global_position = from
	# Move every dot onto the new path
	for i in dots.size():
		# How far along the flight this dot sits
		var t := float(i + 1) / trail_dots
		# Same math the bullet uses, so the dots sit on its path
		var pos := start_pos.lerp(end_pos, t)
		pos.y += arc_height * 4.0 * t * (1.0 - t)
		dots[i].global_position = pos

func launch(from: Vector3, to: Vector3, target_boid: Node3D = null) -> void:
	# Lock in the final path, then start flying
	aim(from, to, target_boid)
	flying = true
	bullet_mesh.visible = true

func _physics_process(delta: float) -> void:
	# Do nothing until the bullet is fired
	if not flying:
		return
	# Track how long the bullet has been in the air
	elapsed += delta
	# Progress through the flight, from 0.0 at launch to 1.0 at landing
	var t = clamp(elapsed / flight_time, 0.0, 1.0)
	
	# Hide the dots the bullet has already passed
	for i in dots.size():
		dots[i].visible = float(i + 1) / trail_dots > t
	
	# Straight-line position between start and end at this point in time
	var flat_pos = start_pos.lerp(end_pos, t)
	# Add the arc on top, 0 at the start and end, tallest at the midpoint
	flat_pos.y += arc_height * 4.0 * t * (1.0 - t)
	# Point the bullet the way it's moving
	var direction = flat_pos - global_position
	if direction.length_squared() > 0.0001 and abs(direction.normalized().y) < 0.99:
		look_at(flat_pos, Vector3.UP)
	global_position = flat_pos
	
	# Hit any living boid the arrow passes close to
	for boid in get_tree().get_nodes_in_group("boids"):
		if boid.death_queued:
			continue
		if global_position.distance_to(boid.global_position) <= hit_radius:
			boid.kill_boid()
			queue_free()
			return
	
	# Once the flight is finished with no hit, remove the bullet
	if t >= 1.0:
		queue_free()
