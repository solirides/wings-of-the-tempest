extends Area3D

const HYRDRATE_BOID: float = 0.001

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rain_water()

func rain_water() -> void:
	var overlapping_bodies: Array[Node3D] = get_overlapping_bodies()
	for n in overlapping_bodies:
		#print("In for loop!")
		if  n is Boid:
			Global.flock.give_percent_hydration(HYRDRATE_BOID)
			#print("boid hydrated!")
