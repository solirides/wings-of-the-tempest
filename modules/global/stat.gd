@tool
extends Resource
class_name Stat

@export var name:String = "stat"
@export var description:String = "stat description" 
@export var base_value:float = 1
@export var modifiers:Array[StatModifier] = []
@export var value:float = base_value

@export var max_value:float = INF
@export var min_value:float = -INF

func _init(p_name:String = "", p_description:String = "", \
		p_base_value:float = 0, p_min_value:float = -INF, p_max_value:float = INF, \
		p_modifiers:Array[StatModifier] = [], p_value:float = p_base_value) -> void:
	name = p_name
	description = p_description
	value = p_value
	base_value = p_base_value
	modifiers = p_modifiers
	max_value = p_max_value
	min_value = p_min_value

# recalculate the value of the stat with all modifiers
func update_value():
	# reset value to base value
	value = base_value
	# apply all modifiers to the value in order
	for m in modifiers:
		value = m.apply_modifier(value)
	# clamp value at the end
	value = clamp(value, min_value, max_value)

# Add and apply a modifier to the stat.
# Adding modifiers one at a time may result in a different value
# from update_value() due to the clamping.
func add_modifier(modifier:StatModifier):
	modifiers.append(modifier)
	value = modifier.apply_modifier(value)
	value = clamp(value, min_value, max_value)

func remove_modifier(name: String):
	for modifier in modifiers:
		if modifier.name == name:
			modifiers.erase(modifier)
			#print("modifier found and removed")
			break
	update_value()

func get_modifier(name: String) -> StatModifier:
	for modifier in modifiers:
		if modifier.name == name:
			return modifier
	return null
