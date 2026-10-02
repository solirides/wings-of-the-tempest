extends Node3D

#@onready var flock: Node3D = %Flock
#@onready var hud: Control = %Hud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.world = self
	# call Global.check_ready_nodes() once this ready function is finished
	connect("ready", Global.check_ready_nodes)
	
	print("current score: " + str(Global.score))
	# connecting the flock to hud is now handled in the hud script

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func end_level():
	Global.hud.show_end_screen()
	
