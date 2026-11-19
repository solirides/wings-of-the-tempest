extends Node3D

# Press F to toggle free cam
# Press esc to toggle mouse capture mode (code is in Global)
# Avoid rotating the camera anchor. Rotate the Camera node instead.

@export var flock: Node3D
# for keeping boids on screen
@export var max_distance_to_flock = 20
#THX, https://gameidea.org/2024/12/13/how-to-make-an-rts-camera-system-in-godot/ I stole your shit
# for moving the camera with the screen edges
@export var edge_margin : float = 50
@export var cam_speed : float = 20
@export var accel_speed : float = 8
#@export_range(0, 1000) cam_zoom : float = 1
@export_range(0, 1000) var cam_zoom : float = 1
@export_range(0, 1000, 0.1) var zoom_speed: float = 4
@export_range(0, 1000) var min_zoom: float = 4
@export_range(0, 1000) var max_zoom: float = 60


#@onready var camera = $Elevation/Camera3D
#exporting sum shit for the BOID behavior.

@export var enable_post_processing: bool = true
@export var lock_to_axis: bool = true
@export var use_key_movement: bool = true
@export var use_mouse_movement: bool = true
@export var axis: Vector3 = Vector3(0,0,-1)
@export var mouse_sensitivity: float = 0.1
@export var hide_cursor: bool = false

@onready var camera_node:Camera3D = $Camera

var cam_is_moving: bool = false
#var move_direction: Vector3 = Vector3.ZERO
var camera_velocity: Vector3 = Vector3.ZERO

var free_cam_mode: bool = false
var free_cam_transform: Transform3D = Transform3D.IDENTITY

var last_mouse_pos: Vector2
var zoom : float = 64

@onready var target_position: Vector3 = camera_node.position
@onready var target_rotation: Vector3 = camera_node.rotation

@onready var shake = $Camera/Shake
@onready var shaders = $Camera/Shaders

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camera = self
	# call Global.check_ready_nodes() once this ready function is finished
	connect("ready", Global.check_ready_nodes)
	
	#Global.camera = self
	if camera_node.projection == Camera3D.PROJECTION_ORTHOGONAL:
		zoom = camera_node.size
	else:
		zoom = self.global_position.distance_to(camera_node.global_position)
		
	if hide_cursor:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Just use the exported variable, for goodness sake!
	zoom = cam_zoom;
	
	$Camera/Shaders.visible = enable_post_processing
	
	set_notify_transform( true );

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("free_cam"):
		#toggle_free_cam()
		print("free cam disabled for now")
	if free_cam_mode == true and event is InputEventMouseMotion:
		# yaw
		target_rotation.y += deg_to_rad(-event.screen_relative.x * mouse_sensitivity)
		# pitch
		target_rotation.x +=deg_to_rad(-event.screen_relative.y * mouse_sensitivity)
		target_rotation.x = clamp(target_rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if event.is_action_pressed("post_processing"):
		enable_post_processing = !enable_post_processing
		$Camera/Shaders.visible = enable_post_processing
		shake.shake()
	if event.is_action_pressed("toggle_camera_lock"):
		lock_to_axis = !lock_to_axis

#this input statment is temporary/for debug only. I imagine that how far the camera is zoomed out will be based on how many boids are on screen.
func _unhandled_input(event: InputEvent) -> void:
	# control camera zoom
	var zoom_direction: int = 0
	if event.is_action_pressed("zoom_in"):
		zoom_direction = -1
	elif event.is_action_pressed("zoom_out"):
		zoom_direction = 1
	zoom += zoom_speed * zoom_direction;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if free_cam_mode:
		_free_cam_movement(delta)
	else:
		_cam_zoom(delta)
		_cam_movement(delta)
		
		#this ties the height of the camera to the FLOCK? Maybe change? IDK it makes sense for now.
		if flock and is_instance_valid(flock) :
			global_position.y = lerp(global_position.y, flock.global_position.y, delta * 5.0)
		
	camera_node.position = lerp(camera_node.position, target_position, delta * zoom_speed)
	camera_node.rotation = lerp(camera_node.rotation, target_rotation, delta * zoom_speed)

func _free_cam_movement(delta: float) -> void:
	var input_vec = Input.get_vector("free_cam_left","free_cam_right","free_cam_forward","free_cam_backward")
	var direction = camera_node.global_transform.basis * Vector3(input_vec.x, 0, input_vec.y)
	direction = direction.normalized()
	var velocity = direction * cam_speed * delta
	
	target_position += velocity
	#camera_node.global_position += velocity
	

func _cam_movement(delta: float) -> void :
	var move_dir: Vector3 = Vector3.ZERO
	if use_mouse_movement:
		move_dir += get_cam_dir_from_mouse()
	if use_key_movement:
		move_dir += get_cam_dir_from_keys()
	move_dir = move_dir.limit_length(1.0)
	
	# keep boids on screen
	if Global.flock:
		# project center of screen to a point on the flock flying height
		var screen_center := get_viewport().get_visible_rect().size / 2.0
		var ray_origin := camera_node.project_ray_origin(screen_center)
		var ray_direction := camera_node.project_ray_normal(screen_center)
		var t = (Global.flock.global_position.y - ray_origin.y) / ray_direction.y
		var view_center = ray_origin + ray_direction * t
		
		var flock_pos = Global.flock.get_center_of_mass()
		var distance_factor = (flock_pos - view_center) / max_distance_to_flock 
		if distance_factor.length() > 1:
			print("applying force to camera to keep boids on screen")
			var force_scale = 0.1
			# apply a force that scales linearly with distance, starting from zero at max_distance_to_flock
			var force = (distance_factor.length() - 1) * distance_factor.normalized() * force_scale
			# respect the lock_to_axis parameter
			if lock_to_axis:
				force = force.project(axis)
			self.camera_velocity += force
			
	var forward = -camera_node.global_transform.basis.z.normalized()
	
	
	camera_velocity = lerp(camera_velocity, move_dir, delta * accel_speed)
	# change position of the anchor (this node)
	global_position += camera_velocity * cam_speed * delta
	
	if move_dir != Vector3.ZERO:
		cam_is_moving = true
	else:
		cam_is_moving = false

func get_cam_dir_from_keys() -> Vector3:
	var input_vec = Input.get_vector("free_cam_left","free_cam_right","free_cam_forward","free_cam_backward")
	
	var forward = -camera_node.global_transform.basis.z.normalized()
	var right = camera_node.global_transform.basis.x.normalized()
	
	var move_direction: Vector3 = camera_node.global_transform.basis * Vector3(input_vec.x, 0, input_vec.y).normalized()
	if lock_to_axis:
		# project movement vectors to the fixed axis
		# normalize so it moves at full speed
		move_direction = move_direction.project(axis).normalized()
	else:
		# project the movement vectors to the ground plane
		move_direction = move_direction.project(Vector3.FORWARD)
	
	return move_direction
	


func get_cam_dir_from_mouse() -> Vector3 :
	var mouse_pos := get_viewport().get_mouse_position()
	var window_size = get_viewport().get_visible_rect().size
	var input_vec = Vector3.ZERO
	
	#screen boundaries, for x
	if mouse_pos.x <= edge_margin:
		input_vec.x = -1.0 #moves left
		#print("I should be moving")
	elif mouse_pos.x >= window_size.x - edge_margin:
		input_vec.x = 1.0  #moves Right
		#print("I should be moving")
	
	#screen boundaries, for y
	if mouse_pos.y <= edge_margin:
		input_vec.z = 1.0 #Up or forward
		#print("I should be moving")
	elif mouse_pos.y >= window_size.y - edge_margin:
		input_vec.z = -1.0  #Down or fackward
		#print("I should be moving")
	
	# get the vectors of the screen's forward and right in 3d space
	var forward = -camera_node.global_transform.basis.z.normalized()
	var right = camera_node.global_transform.basis.x.normalized()
	var move_direction: Vector3 = (right * input_vec.x + forward * input_vec.z).normalized()
	if lock_to_axis:
		# project movement vectors to the fixed axis
		move_direction = move_direction.project(axis).normalized()
	else:
		# project the movement vectors to the ground plane
		move_direction = move_direction.project(Vector3.FORWARD)
		#print(move_direction)
	
	return move_direction


#camera zoom. Right now it's tied to the scroll wheel, BUT it should be tied to how many boids are in your flock. I.G. for every 10 boids you have, the zoom get +10 or -10 (when you lose them)
#THIS SHIT IS BROKEN LMAO... I cant seem to get it to move in both the y and z direction at the same time... :(
func _cam_zoom(delta: float) -> void :
	zoom = clamp(zoom, min_zoom, max_zoom)
	
	if camera_node.projection == Camera3D.PROJECTION_ORTHOGONAL:
		camera_node.size = lerp(camera_node.size, zoom, 10.0 * delta)
	else:
		#position.y = lerp(position.y, zoom, 10.0 * delta)
		# get the vector pointing opposite of the view direction
		var camera_back: Vector3 = camera_node.global_basis.z
		# set the camera node's position to be
		# some distance from the anchor according to zoom
		#target_position = camera_back * zoom + self.global_position
		target_position = camera_back * zoom
		#camera_node.global_position = lerp(camera_node.global_position, target_position, delta * zoom_speed)

func toggle_free_cam(state: bool = !free_cam_mode):
	if free_cam_mode == state:
		# return if already in this state
		return
	free_cam_mode = state
	if free_cam_mode:
		# save the current transform of the camera
		free_cam_transform = camera_node.transform
		# remove any roll from the camera
		global_rotation.z = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# unlock the movement
		lock_to_axis = false
	else:
		# load the transform of the camera when exiting freecam
		#camera_node.transform = free_cam_transform
		target_position = free_cam_transform.origin
		target_rotation = free_cam_transform.basis.get_euler()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		# lock the movement
		lock_to_axis = true

# Emit signal when moved, so other nodes (ie terrain generation) can detect it
signal moved;
func _notification( what: int ) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		moved.emit();
