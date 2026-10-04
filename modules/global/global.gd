extends Node

var score: int = 0
@export var flock: Flock
var camera: Node

# How to use health system
# Currently, there are functions for registering damage (take_damage() and take_percent_damage()
# and healing (heal() and heal_percent()). take_damage() and heal() each take a specific value to subtract or
# add to the health respectively, while take_percent_damage() and heal_percent() each take a percent of the maximum health
# (as a decimal between 0 and 1) to subtract or add to the health respectively.  

# Flock Health Variables and Signals
const MAX_HEALTH: float = 100.0
var health = MAX_HEALTH

# 9/27/26 So far I've only added a signal that is emitted whenever the health is equal to zero,
# but feel free to add more. Just make sure to invoke it only from the check_status() function in this script
signal health_reached_zero

# Flock Hunger Variables and Signals
signal hunger_changed(current: float)

const MAX_HUNGER: float = 100.0
var current_hunger: float = MAX_HUNGER
var starve_rate: float = 2.0
var starve_death_interval: float = 15.0
var speed_penalty_interval: float = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Ensure flock is not messed with during main menu when it doesn't exist yet
	if flock == null or not is_instance_valid(flock) or flock.boids.is_empty():
		return

	for boid in flock.boids:
		if boid.speed > boid.default_speed:
			boid.speed = max(boid.default_speed, boid.speed - speed_penalty_interval * delta)

	if current_hunger > 0:
		current_hunger = max(0.0, current_hunger - starve_rate * delta)
		
		# speed penalties below 50 hunger
		if current_hunger < 50.0:
			for boid in flock.boids:
				boid.speed = max(0.0, boid.speed - speed_penalty_interval * delta)
	else:
		# no speed penalty because you already ran out of hunger
		current_hunger = min(0.0, current_hunger - starve_rate * delta)
		# kill birds of starvation periodically
		if current_hunger < -starve_death_interval:
			#print("starved")
			current_hunger = 0.0
			# No null access here since we check if boids is empty beforehand
			flock.boids[0].remove_boid()

	hunger_changed.emit(current_hunger)


func eat(value: float) -> void:
	if flock == null or not is_instance_valid(flock):
		return
	if current_hunger < 0.0:
		current_hunger = 0.0

	for boid in flock.boids:
		# can boost past default speed; however, this is corrected in _process
		boid.speed += value * speed_penalty_interval
	current_hunger = min(current_hunger + value, MAX_HUNGER)
	hunger_changed.emit(current_hunger)


# Call when starting or restarting a level, since autoload global state 
# persists between scenes
func reset_hunger() -> void:
	current_hunger = MAX_HUNGER
	hunger_changed.emit(current_hunger)

# Getter functions for health, one retrieves the exact health and the other
# retrieves the percent of the max health the flock is currently at
func get_health() -> float:
	return health
func get_health_percent() -> float:
	return health / MAX_HEALTH
	

# Two different damage functions are defined here, one subtracts health directly and one subtracts a percentage
# of the maximum health	
func take_damage(damage: float) -> void:
	if (damage < 0 || health <= 0):
		print("Invalid damage argument or health has reached zero")
		return
	health -= damage
	check_status()

func take_percent_damage(percent_damage: float) -> void:
	if (percent_damage > 1.0 || percent_damage < 0 || health <= 0):
		print("Invalid damage argument or health has reached zero")
		return
	health -= percent_damage * MAX_HEALTH
	check_status()

func heal(health_healed : float) -> void:
	health += health_healed;
	check_status()

@warning_ignore("shadowed_variable")
func heal_percent(heal_percent: float) -> void:
	if (heal_percent < 0 || heal_percent > 1):
		print("Invalid health argument")
		return
	health += heal_percent * MAX_HEALTH
	check_status()
	

func check_status() -> void:
	if (health <= 0):
		health = 0
		health_reached_zero.emit()
	elif (health >= MAX_HEALTH):
		health = MAX_HEALTH
