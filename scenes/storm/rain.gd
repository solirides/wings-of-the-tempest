extends Area3D

const HYDRATION_AMOUNT: float = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rain_water(delta)

func rain_water(delta: float) -> void:
	var overlapping_bodies: Array[Node3D] = get_overlapping_bodies()
	for n in overlapping_bodies:
		#print("In for loop!")
		if  n is Boid:
			# give water proportional to the number of boids in the rain zone
			Global.flock.give_proportional_hydration(1, HYDRATION_AMOUNT * delta)
			#Global.flock.give_percent_hydration(HYRDRATE_BOID)
			#print("boid hydrated!")
