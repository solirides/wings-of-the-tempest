extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_music_track("a_honk_in_the_park", true)
	#Audio.play_music_track("not_music", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1/level_1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
