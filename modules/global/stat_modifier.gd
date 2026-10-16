extends Resource
class_name StatModifier

@export var name:String = ""
@export var modifier_value:float = 0
@export var modifier_type:ModifierType = ModifierType.ADD

enum ModifierType {
	ADD,
	MULTIPLY
}

func apply_modifier(value:float) -> float:
	match ModifierType:
		ModifierType.ADD:
			return value + modifier_value
		ModifierType.MULTIPLY:
			return value * modifier_value
	return value
