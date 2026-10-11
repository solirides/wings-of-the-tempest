extends Flock
class_name SubFlock

# this class is used for diverting some of the boids into another flock
# while still sharing the same health, hunger, and other stats

@export var parent_flock: Flock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# override the _ready() function from Flock
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func remove_boid(boid: Boid):
	parent_flock.remove_boid(boid)
	super.remove_boid(boid)
