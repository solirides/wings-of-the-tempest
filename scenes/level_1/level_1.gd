extends Node3D

#@onready var flock: Node3D = %Flock
#@onready var hud: Control = %Hud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("current score: " + str(Global.score))
	# connecting the flock to hud is now handled in the hud script

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
