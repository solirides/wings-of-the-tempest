extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_music_track("a_honk_in_the_park", true)
	#Audio.play_music_track("not_music", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	Audio.play_sfx_track("test_sound_1")
	Global.start_scene_change("res://scenes/level_1/level_1.tscn")


func _on_quit_pressed() -> void:
	Global.quit_game()
	#get_tree().quit()
	
