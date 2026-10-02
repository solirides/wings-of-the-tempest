extends Node

# This global (Singleton) script is automatically loaded at runtime along with its scene.
# res://modules/global/global.tscn


var score:int = 0
var flock: Node
var camera: Node



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Global node ready")
	print("This is the root node of the Global scene: " + str(Global))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
