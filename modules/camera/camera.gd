extends Camera3D

# Press F to toggle free cam=
# Press esc to toggle mouse capture mode (code is in Global)
#

@export var flock: Node3D
#THX, https://gameidea.org/2024/12/13/how-to-make-an-rts-camera-system-in-godot/ I stole your shit
@export var edge_margin : float = 50
@export var cam_speed : float = 20
@export var accel_speed : float = 8
#@export_range(0, 1000) cam_zoom : float = 1
@export_range(0, 1000) var cam_zoom : float = 1
@export_range(0, 1000, 0.1) var zoom_speed: float = 4
@export_range(0, 1000) var min_zoom: float = 10
@export_range(0, 1000) var max_zoom: float = 60


#@onready var camera = $Elevation/Camera3D
#exporting sum shit for the BOID behavior.

@export var enable_post_processing: bool = true
var cam_is_moving: bool = false
var move_direction: Vector3 = Vector3.ZERO
var camera_velocity: Vector3 = Vector3.ZERO
@export var mouse_sensitivity: float = 0.1

var free_cam_mode: bool = false
var free_cam_transform: Transform3D = Transform3D.IDENTITY


var last_mouse_pos: Vector2
var zoom : float = 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camera = self
	# call Global.check_ready_nodes() once this ready function is finished
	connect("ready", Global.check_ready_nodes)
	
	#Global.camera = self
	if projection == Camera3D.PROJECTION_ORTHOGONAL:
		zoom = size
	else:
		zoom = position.y
	
	$Shaders.visible = enable_post_processing
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("free_cam"):
		toggle_free_cam()
	if free_cam_mode == true and event is InputEventMouseMotion:
		# yaw
		self.global_rotation.y += deg_to_rad(-event.screen_relative.x * mouse_sensitivity)
		# pitch
		self.global_rotation.x +=deg_to_rad(-event.screen_relative.y * mouse_sensitivity)
		self.rotation.x = clamp(self.rotation.x, deg_to_rad(-90), deg_to_rad(90))

#this input statment is temporary/for debug only. I imagine that how far the camera is zoomed out will be based on how many boids are on screen.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed :
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += zoom_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if free_cam_mode:
		_free_cam_movement(delta)
	else:
		_cam_zoom(delta)
		_cam_movement(delta)

func _free_cam_movement(delta: float) -> void:
	var input_vec = Input.get_vector("free_cam_left","free_cam_right","free_cam_forward","free_cam_backward")
	var direction = global_transform.basis * Vector3(input_vec.x, 0, input_vec.y)
	direction = direction.normalized()
	var velocity = direction * cam_speed * delta
	
	global_position += velocity
	

#this feels jank as shit.... sorry. My tutorials way of doing cam movement didn't work.
func _cam_movement(delta: float) -> void :
	var mouse_pos := get_viewport().get_mouse_position()
	var window_size = get_viewport().get_visible_rect().size
	var move_dir = Vector3.ZERO
	
	#screen boundaries, for x
	if mouse_pos.x <= edge_margin:
		move_dir.x = -1.0 #moves left
		#print("I should be moving")
	elif mouse_pos.x >= window_size.x - edge_margin:
		move_dir.x = 1.0  #moves Right
		#print("I should be moving")
	
	#screen boundaries, for y
	if mouse_pos.y <= edge_margin:
		move_dir.z = 1.0 #Up or forward
		#print("I should be moving")
	elif mouse_pos.y >= window_size.y - edge_margin:
		move_dir.z = -1.0  #Down or fackward
		#print("I should be moving")
	
	
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	
	move_direction = (right * move_dir.x + forward * move_dir.z).normalized()
	
	camera_velocity = lerp(camera_velocity, move_direction, delta * accel_speed)
	
	global_position += camera_velocity * cam_speed * delta
	
	if move_dir != Vector3.ZERO :
		cam_is_moving = true
	
	else:
		cam_is_moving = false
		move_direction = Vector3.ZERO

#camera zoom. Right now it's tied to the scroll wheel, BUT it should be tied to how many boids are in your flock. I.G. for every 10 boids you have, the zoom get +10 or -10 (when you lose them)
#THIS SHIT IS BROKEN LMAO... I cant seem to get it to move in both the y and z direction at the same time... :(
func _cam_zoom(delta: float) -> void :
	zoom = clamp(zoom, min_zoom, max_zoom)
	
	if projection == Camera3D.PROJECTION_ORTHOGONAL:
		size = lerp(size, zoom, 10.0 * delta)
	else:
		position.y = lerp(position.y, zoom, 10.0 * delta)
		#position.z = lerp(position.z, zoom, 10.0 * delta)
		
		#how tf?


func toggle_free_cam(state: bool = !free_cam_mode):
	if free_cam_mode == state:
		# return if already in this state
		return
	free_cam_mode = state
	if free_cam_mode:
		# save the current transform of the camera
		free_cam_transform = global_transform
		# remove any roll from the camera
		global_rotation.z = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# load the transform of the camera before entering free cam
		global_transform = free_cam_transform
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
