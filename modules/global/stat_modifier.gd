extends Resource
class_name StatModifier

@export var name:String = ""
@export var modifier_value:float = 0
@export var modifier_type:ModifierType = ModifierType.MULTIPLY
# time in engine ticks when the modifier expires
# NOT FULLY IMPLEMENTED YET
@export var expiration_time:int = -1

enum ModifierType {
	ADD,
	MULTIPLY
}

func _init(p_name: String = "name", p_value: float = 1, p_type: ModifierType = ModifierType.MULTIPLY, p_expiration_time: int = 0) -> void:
	name = p_name
	modifier_value = p_value
	modifier_type = p_type
	expiration_time = p_expiration_time

func apply_modifier(value:float) -> float:
	match modifier_type:
		ModifierType.ADD:
			return value + modifier_value
		ModifierType.MULTIPLY:
			return value * modifier_value
	return value
