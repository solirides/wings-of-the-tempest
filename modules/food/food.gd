extends Node3D

@export var hunger_value: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("food")
