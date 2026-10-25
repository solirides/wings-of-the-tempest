extends Enemy 

@export var wander_timer: Timer
@export var wander_count: int = 4

# Circle Radius 
@export var circle_radius: float = 4.0

# How fast the seagull moves around the circle, in radians per second
@export var circle_speed: float = 1.0
@export var wander_range: float = 10
# The center point the seagull circles around
var circle_target: Vector3 = Vector3.ZERO
var speed_multiplier = 1
var theta = 0
var wander_n = 0

var target: Node3D
var steering: Vector3 = Vector3.ZERO

#@export var attack_radius: float = 1.5

func _ready() -> void:
	# Circle around wherever the seagull was placed in the editor
	circle_target = global_position
	set_state(EnemyState.WANDERING)
	print(state)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	linear_velocity = linear_velocity.lerp(steering * movement_speed, delta)
	linear_velocity = linear_velocity.limit_length(movement_speed)

func try_attack() -> bool:
	if target:
		if (target.global_position - self.global_position).length() <= attack_range:
			attack(target)
			return true
	return false

func attack_function(target: Node3D) -> bool:
	if target.is_in_group("food"):
		print("seagull eats food")
		target.consumed()
		target.queue_free()
		set_state(EnemyState.WANDERING)
		return true
	return false

func state_machine_process(delta: float):
	match state:
		EnemyState.IDLE:
			set_state(EnemyState.WANDERING)
		EnemyState.WANDERING:
			theta += circle_speed * delta
			var target_position = circle_target + \
					Vector3(sin(theta)*circle_radius, global_position.y, cos(theta)*circle_radius)
			steering = target_position - global_position
		EnemyState.TRACKING:
			pass
		EnemyState.ATTACKING:
			if target:
				var target_position = target.global_position
				steering = target_position - global_position
			else:
				# if target no longer exists, return to wandering
				set_state(EnemyState.WANDERING)
		EnemyState.RETREATING:
			pass

func set_state(state: EnemyState):
	self.state = state
	match state:
		EnemyState.IDLE:
			pass
		EnemyState.WANDERING:
			wander_n = 0
			set_random_circle_target()
			wander_timer.start()
		EnemyState.TRACKING:
			# try to find a target in range
			# if no target is found, return to wandering state
			var t = find_target()
			if t == null:
				set_state(EnemyState.WANDERING)
			else:
				set_state(EnemyState.ATTACKING)
		EnemyState.ATTACKING:
			pass
		EnemyState.RETREATING:
			pass

func _on_wander_timeout() -> void:
	wander_n += 1
	if wander_n >= wander_count:
		set_state(EnemyState.TRACKING)
	else:
		set_random_circle_target()
		wander_timer.start()

func set_random_circle_target():
	#print("pick new circling target")
	circle_target = global_position + Vector3(randf(), randf(), randf()) * wander_range
	

func find_target() -> Node3D:
	for n in get_tree().get_nodes_in_group("food"):
		if n.global_position.distance_to(self.global_position) <= track_range:
			target = n
			#print("target found")
			return target
	#print("target not found")
	return null
