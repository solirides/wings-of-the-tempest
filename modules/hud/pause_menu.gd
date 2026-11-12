extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = Global.game_is_paused


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_pressed() -> void:
	Global.pause_gameplay(false)
	self.visible = false


func _on_quit_pressed() -> void:
	Global.start_scene_change("res://scenes/main_menu/main_menu.tscn")
