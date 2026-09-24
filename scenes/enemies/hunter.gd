extends Node3D # Controls hunter.tscn 
# Constant variables with set data types 
@export var detection_range: float = 15.0 
@export var windup_time: float = 0.8
@export var fire_cooldown: float = 2.5
@export var bullet_scene: PackedScene

# Gets the arrowspawn and firecooldown once at the start 
@onready var arrow_spawn: Marker3D = $ArrowSpawn 
@onready var cooldown_timer: Timer = $FireCoolDown

# Initial target is null until a boid is found. 
var target: Node3D = null 
var is_winding_up:= false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets cooldown_timer equal to fire_cooldown variable at the start
	cooldown_timer.wait_time = fire_cooldown 
	cooldown_timer.one_shot = true 
	
func _physics_process(delta: float) -> void:
	# If hunter is already aimming skip everything below
	if is_winding_up: 
		return 
	# Look for the closest boid in its range 
	target = find_nearest_boid() 
	# If both target found and cooldown timer is done
	if target and cooldown_timer.is_stopped(): 
		# Rotate the hunter to face the boid
		look_at(target.global_position, Vector3.UP)
		# Starts the aim fire
		start_windup() 
		
func find_nearest_boid() -> Node3D: 
	var boids = get_tree().get_nodes_in_group("boids")
	var nearest: Node3D = null
	var nearest_dist := detection_range

	for boid in boids:
		# Updates to the nearest boid
		var dist = global_position.distance_to(boid.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = boid

	return nearest

func start_windup() -> void:
	# Lock onto target 
	is_winding_up = true
	# Pause
	await get_tree().create_timer(windup_time).timeout
	# Fire
	fire_bullet()
	# Reset 
	is_winding_up = false
	cooldown_timer.start()

func fire_bullet() -> void:
	# If there is no target do nothing 
	if not target or not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.launch(arrow_spawn.global_position, target.global_position)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
