extends Enemy


func attack_function(target: Node3D):
	# this is not fair lol
	target.remove_boid()
	
