extends Node


var score:int = 0
var flock: Node
var camera: Node



# How to use health system
# Currently, there are functions for registering damage (take_damage() and take_percent_damage()
# and healing (heal() and heal_percent()). take_damage() and heal() each take a specific value to subtract or
# add to the health respectively, while take_percent_damage() and heal_percent() each take a percent of the maximum health
# (as a decimal between 0 and 1) to subtract or add to the health respectively.  

# Flock Health Varibables and Signals
const MAX_HEALTH: float = 100.0
var health = MAX_HEALTH

# 9/27/26 So far I've only added a signal that is emitted whenever the health is equal to zero,
# but feel free to add more. Just make sure to invoke it only from the check_status() function in this script
signal health_reached_zero


var flock: Node
var camera: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
		
	
	
