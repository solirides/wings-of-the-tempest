extends RigidBody3D
class_name Monument

@export var monument_name:String = "Monument"
@export var monument_effects: Array[MonumentEffect] = []
var is_activated = false
var activation_location:Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func activate_monument():
	if is_activated:
		return
	print("Monument %s activated" % monument_name)
	is_activated = true
	activation_location = global_position
	for effect in monument_effects:
		for modifier in effect.modifiers:
			effect.stat_to_modify.add_modifier(modifier)
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Boid:
		activate_monument()
