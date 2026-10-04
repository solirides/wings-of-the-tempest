extends Enemy # Controls hunter.tscn 
# Constant variables with set data types 
#@export var detection_range: float = 15.0 
@export var windup_time: float = 0.8
#@export var fire_cooldown: float = 4.0
@export var bullet_scene: PackedScene

# Gets the arrowspawn and firecooldown once at the start 
@onready var arrow_spawn: Marker3D = $ArrowSpawn 
#@onready var cooldown_timer: Timer = $FireCoolDown
# The rod that points at the target right before the hunter fires
@onready var aim_indicator: MeshInstance3D = $AimIndicator

# Initial target is null until a boid is found. 
#var target: Node3D = null 
# The boid the hunter is aiming at while winding up
var current_target: Node3D = null
var is_winding_up:= false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets cooldown_timer equal to fire_cooldown variable at the start
	#cooldown_timer.wait_time = fire_cooldown 
	#cooldown_timer.one_shot = true 
	# Hide the aim rod until the hunter starts aiming
	aim_indicator.visible = false
	
func _physics_process(delta: float) -> void:
	# If hunter is already aimming skip everything below
	if is_winding_up: 
		# Keep facing the boid so the aim rod points where the shot will go
		if is_instance_valid(current_target):
			look_at(current_target.global_position, Vector3.UP)
		return 
	# Look for the closest boid in its range 
	if attack_ready:
		var target = find_nearest_boid()
		if target:
			look_at(target.global_position, Vector3.UP)
			# call the attack handler defined in the Enemy class
			attack(target)
		
func find_nearest_boid() -> Node3D: 
	var boids = get_tree().get_nodes_in_group("boids")
	var nearest: Node3D = null
	var nearest_dist = track_range

	for boid in boids:
		# Skip boids that are already dying so the hunter doesn't waste a shot on them
		if boid.death_queued:
			continue
		# Updates to the nearest boid
		var dist = global_position.distance_to(boid.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = boid

	return nearest

func attack_function(target: Node3D) -> void:
	# Lock onto target 
	is_winding_up = true
	# Remember who we're aiming at so the rod can keep following them
	current_target = target
	# Show the aim rod as a warning that a shot is coming
	aim_indicator.visible = true
	# Pause
	await get_tree().create_timer(windup_time).timeout
	# Warning is over, hide the aim rod
	aim_indicator.visible = false
	# Fire
	# the bird may be deleted between the time that the attack is started and the bullet is fired
	if target:
		fire_bullet(target)
	# Reset 
	is_winding_up = false
	current_target = null
	#cooldown_timer.start()

func fire_bullet(target: Node3D) -> void:
	if not target or not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.launch(arrow_spawn.global_position, target.global_position, target)
