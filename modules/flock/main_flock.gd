extends Flock
class_name MainFlock

@export var split_boid_count: int = 5
#@export var subflocks: Array[SubFlock] = []
@export var swoop_max_duration: float = 0.5
@export var swoop_cooldown: float = 1.0
@onready var swoop_duration_timer = Timer.new()
@onready var swoop_cooldown_timer = Timer.new()
@onready var split_input_timer = Timer.new()
@onready var swoop_input_timer = Timer.new()

# internal variables for keeping track of input
var split_action_short = true
var swoop_action_short = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() #If there is a better way to do this, please FIX THIS, but for right now...
			#this super() ensures that the flock.gd is at a height of 5, since the boid's position seems to be tied to the height of the flock.
	
	split_input_timer.one_shot = true
	swoop_input_timer.one_shot = true
	self.add_child(split_input_timer)
	self.add_child(swoop_input_timer)
	swoop_duration_timer.one_shot = true
	swoop_cooldown_timer.one_shot = true
	add_child(swoop_duration_timer)
	add_child(swoop_cooldown_timer)
	swoop_duration_timer.timeout.connect(_on_swoop_duration_timeout)
	
	split_input_timer.timeout.connect(_on_split_input_timer_timeout)
	swoop_input_timer.timeout.connect(_on_swoop_input_timer_timeout)
	
	
	Global.flock = self
	# call Global.check_ready_nodes() once this ready function is finished
	connect("ready", Global.check_ready_nodes)
	
	for i in range(num_boids):
		var new_boid:Boid = boid_scene.instantiate()
		add_child(new_boid)
		
		# make boid position independent of parent node (flock node)
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
	

func _physics_process(delta: float) -> void:
	super(delta)
	
	if all_boids.size() == 0:
		print("game over")
		Global.game_over()

#I moved _process boid goal stuff into flocks own _process function!

func split_flock(num: int, subflock: SubFlock):
	var b = boids.duplicate()
	b.shuffle()
	
	for boid: Boid in b.slice(0, num):
		#print(boid)
		boid.transfer_to_flock(subflock)
	
	# set subflock target
	subflock.flock_goal = get_cursor_pos()
	subflock.update_cursor()
	
# thank golly goodness I found out how to override functions in godot
func handle_swoop_request(should_swoop: bool):
	if should_swoop and not swoop_cooldown_timer.is_stopped():
		print("still on cooldown")
		return
	
	var was_swooping: bool = (boid_properties.flock_state == BoidProperties.FLOCK_STATE.SWOOPING)
	super(should_swoop)
	var is_swooping: bool = (boid_properties.flock_state == BoidProperties.FLOCK_STATE.SWOOPING)
	if is_swooping and not was_swooping:
		# perhaps add option to cancel swoop later on
		swoop_duration_timer.start(swoop_max_duration)
	elif was_swooping and not is_swooping:
		swoop_duration_timer.stop()
		swoop_cooldown_timer.start(swoop_cooldown)

func regroup_flock():
	for subflock in subflocks:
		subflock.transfer_boids_to_flock(self)
		subflock.hide_cursor()

func _on_split_input_timer_timeout():
	#print("split action timeout")
	split_action_short = false
	print("split flock long action")
	# disable scattering
	handle_repel_request(false)
	
	regroup_flock()
	

func _on_swoop_input_timer_timeout():
	print("swoop action timeout")
	swoop_action_short = false
	handle_swoop_request(true)
	
func _on_swoop_duration_timeout():
	print("swoop duration ended")
	handle_swoop_request(false)


#
#func begin_swoop():
	#pass
#
#func end_swoop():
	#pass



# flock.gd is inherited by both MainFlock and SubFlock,
# so input for flock splitting would be more annoying to handle in flock.gd
# Maybe move to a separate input handler later.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("split_flock"):
		#print("split flock action pressed")
		split_action_short = true
		#split_input_timer = get_tree().create_timer(0.5)
		split_input_timer.start(0.3)
		
	if event.is_action_released("split_flock"):
		if split_action_short:
			print("split flock short action")
			split_input_timer.stop()
			# disable scattering
			handle_repel_request(false)
			# keep at least split_boid_count in the main flock
			var count = max(0, min(split_boid_count, len(boids) - split_boid_count) ) 
			split_flock(count, subflocks[0])
		else:
			pass
	
	if event.is_action_pressed("swoop"):
		#print("swoop action pressed")
		swoop_action_short = true
		#swoop_input_timer = get_tree().create_timer(0.5)
		swoop_input_timer.start(0.3)
		
	if event.is_action_released("swoop"):
		if swoop_action_short:
			swoop_input_timer.stop()
			handle_repel_request()
		else:
			handle_swoop_request(false)
		
