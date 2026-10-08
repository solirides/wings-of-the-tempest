extends Node

# This global (Singleton) script is automatically loaded at runtime along with its scene.
# res://modules/global/global.tscn


var score: int = 0
# Generally try to use these variables in Global to get references to these nodes. (or use the % prefix)
# This way we only have to make sure they exist here.
var flock: Node
var camera: Node
var hud: Node
var world: Node

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
	get_tree().connect("scene_changed", _on_scene_changed)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

#func connect_node(node: Node, variable):
	#if node:
		#variable = node
	#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_ready_nodes():
	var ready = true
	for n in [flock, camera, hud, world]:
		if n == null:
			print("Global checking for main nodes.")
			ready = false
	if ready and ready_emitted == false:
		print("All main nodes are ready")
		main_nodes_ready.emit()
		ready_emitted = true
	


func _on_scene_changed():
	ready_emitted = false
	

func _input(event: InputEvent) -> void:
	# press esc to cycle through mouse capture modes
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	if event.is_action_pressed("escape"):
		print("fdggdf")
		match Input.mouse_mode:
			Input.MOUSE_MODE_CONFINED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			_:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			#Input.MOUSE_MODE_CAPTURED:
				#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
