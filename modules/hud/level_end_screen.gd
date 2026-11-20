extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_stats():
	var label = $VBoxContainer/Stats
	label.text = "summary:\n"
	label.text += "score: %s\n" % Global.score_calc()
	label.text += "flock size: %s\n" % len(Global.flock.boids)
	#label.text += "something something"
