extends Node3D

#@onready var flock: Node3D = %Flock
#@onready var hud: Control = %Hud

func _ready() -> void:
	Global.world = self
	connect("ready", Global.check_ready_nodes)
