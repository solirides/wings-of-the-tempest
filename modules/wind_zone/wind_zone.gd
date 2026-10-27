extends Area3D

enum WindMode {
	CONSTANT,
	RANDOM1D,
	RANDOM2D,
}

@export var wind_direction: Vector3 = Vector3.FORWARD
@export var mode: WindMode = WindMode.CONSTANT
@export var wind_strength: float = 20
#@export var random_range_x: Vector2 = Vector2(-10,10)
@export var random_range_z: Vector2 = Vector2(-10,10)
@export var random_rate: float = 1
@export var wind_map: Texture2D

var force = Vector3.ZERO
var target_wind = Vector3.ZERO
var rng := RandomNumberGenerator.new()
# in engine ticks msec
var next_wind_change = 0

@export var smoothing := 1.5
@export var timer: Timer
@export var particle_emitter: GPUParticles3D
@export var particle_attractor: GPUParticlesAttractor3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	pick_new_wind()
	#timer.wait_time = random_rate
	match mode:
		WindMode.RANDOM1D:
			timer.start()
		WindMode.RANDOM2D:
			timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("boids"):
			apply_wind(body, delta)
			

func apply_wind(body: PhysicsBody3D, delta):
	match mode:
		WindMode.CONSTANT:
			force = wind_strength * wind_direction.normalized()
		WindMode.RANDOM1D:
			# Smoothly move toward the next random wind value.
			var blend := 1.0 - exp(-smoothing * delta)
			force = lerp(force, target_wind, blend)
			particle_attractor.position = force.normalized() * 15
			#force = wind_strength * wind_direction.normalized() * \
				#wind_map.sample(Vector2(1, 0) * Time.get_ticks_msec() / 1000 * random_rate)
	#print(force)
	body.apply_central_force(force)
	# keep track of force applied for display
	body.wind_force += force

func pick_new_wind() -> void:
	match mode:
		WindMode.RANDOM1D:
			target_wind = wind_direction * wind_strength * rng.randf_range(random_range_z.x, random_range_z.y)
			

func _on_timer_timeout() -> void:
	pick_new_wind()
