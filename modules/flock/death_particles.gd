extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	one_shot = true
	emitting = false

func start_animation():
	one_shot = true
	emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_finished() -> void:
	queue_free()
