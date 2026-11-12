extends Node3D
class_name Level

func _ready() -> void:
	Global.world = self;
	ready.connect( Global.check_ready_nodes, CONNECT_ONE_SHOT );
	
	Audio.play_music_track("a_honk_in_the_park")
