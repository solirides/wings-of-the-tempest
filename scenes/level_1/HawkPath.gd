extends Path3D


@onready var path_follow = $PathFollow3D
@onready var hawk = $PathFollow3D/Hawk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	path_follow.progress += delta * hawk.movement_speed
	
