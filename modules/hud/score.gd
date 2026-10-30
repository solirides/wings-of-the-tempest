extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.score_modified.connect(UpdateScore)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func UpdateScore() -> void:
	text = "Score: " + str(Global.score)
