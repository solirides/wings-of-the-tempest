extends Node3D
class_name Enemy

# This class is extended by specific enemy scripts
# and contains shared things like health, attack handling, etc
# Try to keep this class modular and extensible

@export var health = 10
@export var attack_damage = 1
# Time in seconds between attacks
@export var attack_speed = 1.0
@export var attack_range = 3.0
@export var track_range = 15.0

@export var movement_speed = 3.0

var attack_ready = true

func _physics_process(_delta: float) -> void:
	if attack_ready:
		try_attack()

func try_attack():
	# default behavior: attacks the first boid it finds in range.
	# subclasses can override this
	for n in Global.flock.boids:
		if n.global_position.distance_to(self.global_position) <= attack_range:
			attack(n)
			break


func attack(target: Node3D):
	attack_ready = false
	# call the attack behavior defined by the subclass inheriting this class
	attack_function(target)
	
	# handle cooldown
	await get_tree().create_timer(attack_speed).timeout
	attack_ready = true

func attack_function(_target: Node3D):
	# override this function in the subclass
	pass

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
