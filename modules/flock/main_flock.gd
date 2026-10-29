extends Flock
class_name MainFlock

@export var split_boid_count: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() #If there is a better way to do this, please FIX THIS, but for right now...
			#this super() ensures that the flock.gd is at a height of 5, since the boid's position seems to be tied to the height of the flock.
	
	Global.flock = self
	# call Global.check_ready_nodes() once this ready function is finished
	connect("ready", Global.check_ready_nodes)
	
	for i in range(num_boids):
		var new_boid: Boid = boid_scene.instantiate()
		add_child(new_boid)
		
		new_boid.top_level = true
		
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(0.0, spawn_radius)
		new_boid.position = Vector3(
			cos(angle) * distance,
			boid_properties.flockMaxHeight, #the boids spawn at the same height as the flock
			sin(angle) * distance
		)

		boids.append(new_boid)
		new_boid.debug_flock_display(self)
		new_boid.boid_died.connect(_on_boid_death)
	# duplicate the array (do NOT pass by reference (or you will be very very sad when the code does not work))
	all_boids = boids.duplicate()
	#print(all_boids)
	

#I moved _process boid goal stuff into flocks own _process function!

#this is completely borked RN.
func split_flock(num: int, subflock:SubFlock):
	var b = boids.duplicate()
	b.shuffle()
	
	for boid in b.slice(0, num):
		boid.transfer_to_flock(subflock)
	
	# set subflock target
	subflock.flock_goal = get_mouse_world_position(camera_controller.camera_node)
	#print(subflock.boid_goal)
	

func regroup_flock():
	for subflock in subflocks:
		subflock.transfer_boids_to_flock(self)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("split_flock"):
		regroup_flock()
		split_flock(split_boid_count, subflocks[0])
	if event.is_action_pressed("swoop"):
		swoop(true)
	elif event.is_action_released("swoop"):
		swoop(false)
	if event.is_action_pressed("land"):
		print("land")
		toggle_landing()
