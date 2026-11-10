extends Enemy 

func attack_function(target: Node3D) -> bool:
	# override function from Enemy class
	if target.is_in_group("boids"):
		#print("kill target")
		target.kill_boid()
		return true
	return false
