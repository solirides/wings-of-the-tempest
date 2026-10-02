extends Enemy 

# Circle Radius 
@export var circle_radius: float = 4.0

# How fast the hawk moves around the circle, in radians per second
@export var circle_speed: float = 1.0

# How close a boid has to get before the hawk attacks it
#@export var attack_radius: float = 1.5

# The center point the hawk circles around, set once at spawn
var center: Vector3
# Current angle along the circle, in radians
var angle: float = 0.0

func _ready() -> void:
	# Circle around wherever the hawk was placed in the editor
	center = global_position

#func attack_nearby_boids() -> void:
	#var boids = get_tree().get_nodes_in_group("boids")
	#for boid in boids:
		#if global_position.distance_to(boid.global_position) <= attack_radius:
			#boid.remove_boid()

func _physics_process(delta: float) -> void:
	# Advance along the circle
	angle += circle_speed * delta
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * circle_radius
	global_position = center + offset
	
	# Face the direction of travel (tangent to the circle)
	var tangent := Vector3(-sin(angle), 0.0, cos(angle))
	if tangent.length_squared() > 0.001:
		look_at(global_position + tangent, Vector3.UP)
	
	# handle attack
	super._physics_process(delta)

func attack_function(target: Node3D):
	# override function from Enemy class
	if target.is_in_group("boids"):
		target.remove_boid()
