extends Enemy # Controls hunter.tscn 
# Constant variables with set data types 
#@export var detection_range: float = 15.0 
@export var windup_time: float = 0.8
#@export var fire_cooldown: float = 4.0
@export var bullet_scene: PackedScene
# 0 aims at where the boid is now, 1 aims at where it will be when the arrow lands
@export var lead_amount: float = 1.0
# If true, aim at the most packed together boid instead of the nearest
@export var target_clusters: bool = true
# How close boids have to be to count as the same cluster
@export var cluster_radius: float = 3.0

# Gets the arrowspawn and firecooldown once at the start 
@onready var arrow_spawn: Marker3D = $ArrowSpawn 
#@onready var cooldown_timer: Timer = $FireCoolDown
# The rod that points at the target right before the hunter fires
@onready var aim_indicator: MeshInstance3D = $AimIndicator

# Initial target is null until a boid is found. 
#var target: Node3D = null 
# The boid the hunter is aiming at while winding up
var current_target: Node3D = null
# The bullet being charged, it shows the dotted path before it fires
var charging_bullet = null
var is_winding_up:= false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets cooldown_timer equal to fire_cooldown variable at the start
	#cooldown_timer.wait_time = fire_cooldown 
	#cooldown_timer.one_shot = true 
	# Hide the aim rod until the hunter starts aiming
	aim_indicator.visible = false
	is_grounded = true
	
func _physics_process(delta: float) -> void:
	# If hunter is already aimming skip everything below
	if is_winding_up:
		#print("hunter winding up")
		# Keep facing where the boid will be so the aim rod points where the shot will go
		if is_instance_valid(current_target):
			var aim_point = predict_position(current_target)
			look_at(aim_point, Vector3.UP)
			# Keep the dotted path lined up with the boid
			if is_instance_valid(charging_bullet):
				charging_bullet.aim(arrow_spawn.global_position, aim_point, current_target)
		return 
	# Look for a boid in its range 
	if attack_ready:
		var target = find_target()
		if target:
			look_at(target.global_position, Vector3.UP)
			# call the attack handler defined in the Enemy class
			attack(target)

func find_target() -> Node3D:
	# Pick the target the way the Inspector setting says
	if target_clusters:
		return find_cluster_target()
	return find_nearest_boid()

func find_cluster_target() -> Node3D:
	var boids = get_tree().get_nodes_in_group("boids")
	var best: Node3D = null
	var best_count := -1
	for boid in boids:
		# Skip dying boids and boids out of range
		if boid.death_queued:
			continue
		if global_position.distance_to(boid.global_position) > track_range:
			continue
		# Skip boids hidden behind terrain
		if not has_line_of_sight(boid):
			continue
		# Count how many other boids are packed around this one
		var count := 0
		for other in boids:
			if other != boid and not other.death_queued and boid.global_position.distance_to(other.global_position) <= cluster_radius:
				count += 1
		# Keep the boid with the most neighbors
		if count > best_count:
			best_count = count
			best = boid
	return best

func predict_position(target: Node3D) -> Vector3:
	# Without a bullet there's no flight time to lead by
	if not is_instance_valid(charging_bullet):
		return target.global_position
	# Where the boid will be when the arrow lands
	return target.global_position + target.linear_velocity * charging_bullet.flight_time * lead_amount
		
func find_nearest_boid() -> Node3D: 
	var boids = get_tree().get_nodes_in_group("boids")
	var nearest: Node3D = null
	var nearest_dist = track_range

	for boid in boids:
		# Skip boids that are already dying so the hunter doesn't waste a shot on them
		if boid.death_queued:
			continue
		# Updates to the nearest boid if the hunter can see it
		var dist = global_position.distance_to(boid.global_position)
		if dist < nearest_dist and has_line_of_sight(boid):
			nearest_dist = dist
			nearest = boid

	return nearest

func attack_function(target: Node3D) -> bool:
	var success: bool = false
	# Lock onto target 
	is_winding_up = true
	# Remember who we're aiming at so the rod can keep following them
	current_target = target
	# Show the aim rod as a warning that a shot is coming
	aim_indicator.visible = true
	# Make the bullet now so its dotted path shows while charging
	if bullet_scene:
		charging_bullet = bullet_scene.instantiate()
		# Parent it to the hunter so it goes away if the hunter does
		add_child(charging_bullet)
		charging_bullet.aim(arrow_spawn.global_position, predict_position(target), target)
	# Pause
	await get_tree().create_timer(windup_time).timeout
	# Warning is over, hide the aim rod
	aim_indicator.visible = false
	# Fire
	# the bird may be deleted between the time that the attack is started and the bullet is fired
	if is_instance_valid(target) and has_line_of_sight(target):
		fire_bullet(target)
		success = true
	elif is_instance_valid(charging_bullet):
		# Target is gone or out of sight, so throw the charging bullet away
		charging_bullet.queue_free()
	# Reset 
	is_winding_up = false
	current_target = null
	charging_bullet = null
	#cooldown_timer.start()
	return success

func fire_bullet(target: Node3D) -> void:
	if not target or not is_instance_valid(charging_bullet):
		return
	# Put the bullet in the world so it stops following the hunter
	charging_bullet.reparent(get_tree().current_scene)
	charging_bullet.launch(arrow_spawn.global_position, predict_position(target), target)

func has_line_of_sight(target: Node3D) -> bool:
	# Ray from the bow to the boid, ignoring the hunter itself
	var query = PhysicsRayQueryParameters3D.create(arrow_spawn.global_position, target.global_position)
	query.exclude = [get_rid()]
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	# Clear if nothing is in the way or it hits a boid first
	return hit.is_empty() or hit.collider.is_in_group("boids")
