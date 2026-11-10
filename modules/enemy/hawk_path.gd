extends Path3D

@export var flight_speed: float = 1.0;

func _physics_process( delta: float ) -> void:
	%HawkPathFollower.progress_ratio += delta * flight_speed;
