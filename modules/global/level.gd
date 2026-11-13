extends Node3D
class_name Level

func _ready() -> void:
	Global.world = self;
	ready.connect( Global.check_ready_nodes, CONNECT_ONE_SHOT );
	Global.end_screen_triggered = false
	# TODO: make better function for resetting the game
	
	Audio.play_music_track("lofi_beats_to_migrate_south_to")
	#Audio.play_music_track("not_music", false)
	
