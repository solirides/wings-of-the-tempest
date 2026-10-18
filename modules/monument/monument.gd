extends RigidBody3D
class_name Monument

@export var monument_name:String = "Monument"
@export var monument_effects: Array[MonumentEffect] = []
var is_activated = false
var activation_location:Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#var s = Stat.new("stat name", "", 123)
	#print(s.value)
	
	#print(Global.flock.boid_properties.speed.value)
	#Global.flock.boid_properties.speed.value += 100
	#print(Global.flock.boid_properties.speed.value)
	#print(Global.flock.boid_properties.get("speed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func activate_monument(state:bool = true):
	if is_activated == state:
		return
	print("Monument %s activated" % monument_name)
	is_activated = state
	if state:
		activation_location = global_position
		for effect in monument_effects:
			for modifier in effect.modifiers:
				if effect.stat_to_modify == null:
					if effect.path_to_stat == "":
						# no valid reference to a stat
						continue
					# look for the stat in flock.boid_properties
					var a = Global.flock.boid_properties.get(effect.path_to_stat)
					print(a)
					if a == null:
						continue
					effect.stat_to_modify = a
				print(effect.stat_to_modify.value)
				effect.stat_to_modify.add_modifier(modifier)
				print(effect.stat_to_modify.value)
		$OmniLight3D.visible = true
	else:
		
		$OmniLight3D.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Boid:
		activate_monument()
