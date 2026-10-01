extends Camera3D


<<<<<<< Updated upstream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
=======
@export var flock: Node3D
#THX, https://gameidea.org/2024/12/13/how-to-make-an-rts-camera-system-in-godot/ I stole your shit
@export var edge_margin : float = 50
@export var cam_speed : float = 20
#@export_range(0, 1000) cam_zoom : float = 1
@export_range(0, 1000) var cam_zoom : float = 1
@export_range(0, 1000, 0.1) var zoom_speed: float = 4
@export_range(0, 1000) var min_zoom: float = 10
@export_range(0, 1000) var max_zoom: float = 60


#@onready var camera = $Elevation/Camera3D
#exporting sum shit for the BOID behavior.
@export var cam_is_moving: bool = false
@export var move_direction: Vector3 = Vector3.ZERO


var last_mouse_pos: Vector2
var zoom : float = 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camera = self
	if projection == Camera3D.PROJECTION_ORTHOGONAL:
		zoom = size
	else:
		zoom = position.y
>>>>>>> Stashed changes

#this input statment is temporary/for debug only. I imagine that how far the camera is zoomed out will be based on how many boids are on screen.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed :
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += zoom_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
<<<<<<< Updated upstream
	pass
=======
	_cam_zoom(delta)
	_cam_movement(delta)

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
	
	if move_dir != Vector3.ZERO :
		cam_is_moving = true
		var forward = -global_transform.basis.z
		var right = global_transform.basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		
		
		move_direction = (right * move_dir.x + forward * move_dir.z).normalized()
		
		global_position += move_direction * cam_speed * delta
	else :
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
>>>>>>> Stashed changes
