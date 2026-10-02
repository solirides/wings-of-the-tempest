extends Node

# This global (Singleton) script is automatically loaded at runtime along with its scene.
# res://modules/global/global.tscn


var score:int = 0
# Generally try to use these variables in Global to get references to these nodes. (or use the % prefix)
# This way we only have to make sure they exist here.
var flock: Node
var camera: Node
var hud: Node

# Emitted when the flock, camera, and hud variables have all been set
# Each main node sets their respective variable to themself in their ready function
# The ready signal of these nodes are also connected to call check_ready_nodes() here
signal main_nodes_ready
var ready_emitted = false

# Health system has been moved to the flock script res://modules/flock/flock.gd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Global node ready")
	print("This is the root node of the Global scene: " + str(Global))

#func connect_node(node: Node, variable):
	#if node:
		#variable = node
	#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_ready_nodes():
	var ready = true
	for n in [flock, camera, hud]:
		if n == null:
			print("Global checking for main nodes.")
			ready = false
	if ready and ready_emitted == false:
		print("All main nodes are ready")
		main_nodes_ready.emit()
		ready_emitted = true
