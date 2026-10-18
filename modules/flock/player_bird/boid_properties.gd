extends Resource
class_name BoidProperties


enum STEERING_MODE {
	LERP,
	STEERING_FORCE,
	CONSTANT_SPEED,
	CONSTANT_EVERYTHING
}

enum ROTATION_MODE {
	SNAP_TO_VELOCITY,
	LERP_TO_VELOCITY,
	LERP_TO_GOAL
}

@export var speed : float = 15
@export var min_speed : float = 5
@export var speed_scale_exp: float = 0.3
@export var perception_range : float = 8
@export var personal_space : float = 4

@export var seperate_weight : float = 4
@export var alignment_weight : float = 1
@export var cohesion_weight : float = 1
@export var goal_weight : float = 1.2
@export var stay_on_screen_weight : float = 2
@export var cam_moving_weight : float = 1.2

@export var repel_radius: float = 5.0
@export var repel_weight: float = 5.0

@export var default_state: bool = true

#coward shit
@export var flee_weight: float = 2.1
@export var is_fleeing: bool = false
@export var flee_timer: float = 0.0
@export var flee_duration: float = 3 #3 seconds
@export var flee_direction: Vector3 = Vector3.ZERO

#split up sub group stuff
@export var spin_weight : float = 1
@export var minimum_group_size : float = 5
@export var scatter : bool = false

@export var steering_smoothness: float = 8.0
@export var rotation_smoothness: float = 8.0
@export var steering_strength: float = 8.0
@export var steering_mode: STEERING_MODE = STEERING_MODE.LERP
@export var rotation_mode: ROTATION_MODE = ROTATION_MODE.LERP_TO_VELOCITY
