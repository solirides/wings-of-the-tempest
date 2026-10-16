extends Enemy 

@export var wander_timer: Timer

# Circle Radius 
@export var circle_radius: float = 4.0

# How fast the hawk moves around the circle, in radians per second
@export var circle_speed: float = 1.0
@export var wander_range: float = 10
# The center point the seagull circles around
var circle_target: Vector3 = Vector3.ZERO
var speed_multiplier = 1
var theta = 0

@export var attack_radius: float = 1.5

func _ready() -> void:
	# Circle around wherever the hawk was placed in the editor
	circle_target = global_position

func _physics_process(delta: float) -> void:
	#state_machine_process()
	super._physics_process(delta)

func attack_function(circle_target: Node3D):
	# override function from Enemy class
	if circle_target.is_in_group("boids"):
		#print("kill circle_target")
		circle_target.kill_boid()

func state_machine_process(delta: float):
	match state:
		EnemyState.IDLE:
			state = EnemyState.WANDERING
			wander_timer.start()
		EnemyState.WANDERING:
			theta += circle_speed * delta
			var target_position = circle_target + Vector3(sin(theta), global_position.y, cos(theta))
			linear_velocity = target_position - global_position
			linear_velocity *= movement_speed
		EnemyState.TRACKING:
			pass
		EnemyState.ATTACKING:
			pass
		EnemyState.RETREATING:
			pass


func _on_wander_timeout() -> void:
	wander_timer.start()

func set_random_circle_target():
	circle_target = global_position + Vector3(randf(), randf(), randf()) * wander_range
	
