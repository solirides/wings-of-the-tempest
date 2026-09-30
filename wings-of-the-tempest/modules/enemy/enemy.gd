extends Node
class_name Enemy

@export var health = 10
@export var attack_damage = 1
@export var attack_speed = 4
var attack_ready = true
@export var attack_range = 3
var cooldown_timer: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if attack_ready:
		for n in Global.flock.boids:
			if n.global_position.distance_to(self.global_position) <= attack_range:
				attack(n)
				break

func attack(target: Node3D):
	print("enemy attack")
	attack_ready = false
	cooldown_timer = get_tree().create_timer(attack_speed)
	cooldown_timer.timeout.connect(recover_attack)
	attack_function(target)

func recover_attack():
	attack_ready = true

func attack_function(target: Node3D):
	# override this function
	print("calling empty attack function")

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		print("dead")
		queue_free()
