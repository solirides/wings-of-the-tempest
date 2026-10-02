extends Node3D

@onready var flock: Node3D = %Flock
@onready var hud: Control = %Hud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("current score: " + str(Global.score))
	hud.connect_to_player(flock)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
