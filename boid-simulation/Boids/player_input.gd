extends CharacterBody3D

@export var cam : Camera3D

func _physics_process(delta: float) -> void:

	var mousePos := get_viewport().get_mouse_position()
	
	#print("Your mouse is here, asshole: " , mousePos)
	pass
	
	var rayStart :Vector3 = cam.project_ray_origin(mousePos)
	var direction :Vector3 = cam.project_ray_normal(mousePos)
	
	var plane := Plane(Vector3.UP)
	
	var position3dspace = plane.intersects_ray(rayStart, direction)
	
	if position3dspace:
		global_position.x = position3dspace.x
		global_position.z = position3dspace.z
