extends Enemy # Controls crab.tscn

# How far the crab wanders from where it spawned
@export var wander_range: float = 4.0
# How long the crab waits at each wander spot
@export var wander_pause: float = 1.5
# How far from home it will chase a boid before giving up
@export var leash_range: float = 10.0
# Boids higher than this above the crab are out of reach
@export var reach_height: float = 1.5
# How long the crab puffs up before the pinch lands
@export var pinch_windup: float = 0.6
# Speed boost while chasing a boid
@export var chase_speed_mult: float = 1.5
# Stick to the terrain while walking
@export var follow_terrain: bool = true
# How high the crab sits above the ground
@export var ground_offset: float = 0.2
# Tallest ledge the crab can walk up or down
@export var step_height: float = 1.0

# The crab's body, swap in the 3D model here later
@onready var body: Node3D = $Body

# Where the crab spawned
var home: Vector3
# Spot the crab walks to while wandering
var wander_spot: Vector3
# The boid being chased
var chase_target: Node3D = null
# Time left before walking to the next wander spot
var pause_left: float = 0.0

func _ready() -> void:
	is_grounded = true
	# Wait a frame so terrain spawning can place the crab first
	set_home.call_deferred()

func set_home() -> void:
	# Wander around wherever the crab ended up
	home = global_position
	set_state(EnemyState.WANDERING)

func _physics_process(delta: float) -> void:
	# Stay on top of the terrain
	if follow_terrain:
		var ground_y := ground_height_at(global_position)
		if not is_nan(ground_y):
			global_position.y = ground_y
	# Runs the state machine and attack check in Enemy
	super._physics_process(delta)

func state_machine_process(delta: float):
	match state:
		EnemyState.WANDERING:
			# Chase any boid low enough to grab
			var found := find_target()
			if found:
				chase_target = found
				set_state(EnemyState.TRACKING)
				return
			# Wait a bit at each spot before moving on
			if pause_left > 0.0:
				pause_left -= delta
			elif scuttle_toward(wander_spot, movement_speed, delta):
				pick_wander_spot()
				pause_left = wander_pause
		EnemyState.TRACKING:
			# Give up if the boid is gone, flew up, or got too far from home
			if not is_valid_target(chase_target) or flat_distance(home, global_position) > leash_range:
				set_state(EnemyState.RETREATING)
				return
			scuttle_toward(chase_target.global_position, movement_speed * chase_speed_mult, delta)
		EnemyState.ATTACKING:
			# Hold still while pinching
			pass
		EnemyState.RETREATING:
			# Head home, then go back to wandering
			if scuttle_toward(home, movement_speed, delta):
				set_state(EnemyState.WANDERING)

func set_state(new_state: EnemyState):
	state = new_state
	match state:
		EnemyState.WANDERING:
			chase_target = null
			pick_wander_spot()
		EnemyState.RETREATING:
			chase_target = null

func pick_wander_spot() -> void:
	# Random spot near home
	var angle := randf() * TAU
	var dist := randf() * wander_range
	wander_spot = home + Vector3(cos(angle), 0.0, sin(angle)) * dist

func find_target() -> Node3D:
	var nearest: Node3D = null
	var nearest_dist: float = track_range
	for boid in get_tree().get_nodes_in_group("boids"):
		# Skip boids it can't reach
		if not is_valid_target(boid):
			continue
		# Keep the closest one
		var dist := flat_distance(global_position, boid.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = boid
	return nearest

func is_valid_target(boid: Node3D) -> bool:
	# Gone or already dying
	if not is_instance_valid(boid) or boid.death_queued:
		return false
	# Too high for the crab to reach
	return boid.global_position.y - global_position.y <= reach_height

func try_attack() -> bool:
	# Only pinch the boid it's chasing once it's close
	if state == EnemyState.TRACKING and is_valid_target(chase_target):
		if flat_distance(global_position, chase_target.global_position) <= attack_range:
			attack(chase_target)
			return true
	return false

func attack_function(target: Node3D) -> bool:
	var success := false
	# Stop and puff up as a warning
	set_state(EnemyState.ATTACKING)
	raise_claws()
	await get_tree().create_timer(pinch_windup).timeout
	# The boid may have flown off or died during the windup
	if is_valid_target(target) and flat_distance(global_position, target.global_position) <= attack_range * 1.5:
		target.kill_boid()
		success = true
	# Scuttle home after every pinch
	set_state(EnemyState.RETREATING)
	return success

func raise_claws() -> void:
	# Puff up, then snap back when the pinch lands
	var tween := create_tween()
	tween.tween_property(body, "scale", Vector3.ONE * 1.3, pinch_windup)
	tween.tween_property(body, "scale", Vector3.ONE, 0.1)

# Moves toward a point, returns true once there or blocked
func scuttle_toward(point: Vector3, speed: float, delta: float) -> bool:
	var to_point := point - global_position
	to_point.y = 0.0
	var dist := to_point.length()
	if dist < 0.2:
		return true
	var dir := to_point / dist
	var next := global_position + dir * minf(speed * delta, dist)
	if follow_terrain:
		var ground_y := ground_height_at(next)
		# Stop at cliffs and the edge of the terrain
		if is_nan(ground_y) or absf(ground_y - global_position.y) > step_height:
			return true
		next.y = ground_y
	global_position = next
	# Face sideways so it walks like a crab
	look_at(global_position + dir.cross(Vector3.UP), Vector3.UP)
	return false

func ground_height_at(point: Vector3) -> float:
	# Ray straight down onto the terrain, NAN if there is none
	var hit := Chunk.intersect(point + Vector3.UP * step_height, point + Vector3.DOWN * 50.0, get_world_3d())
	if hit.is_finite():
		return hit.y + ground_offset
	return NAN

func flat_distance(a: Vector3, b: Vector3) -> float:
	# Distance along the ground, ignoring height
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
