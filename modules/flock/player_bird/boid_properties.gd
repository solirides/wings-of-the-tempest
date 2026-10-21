@tool
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

@export var speed : Stat                 = Stat.new("speed",                 "", 15)
@export var min_speed : Stat             = Stat.new("min_speed",             "", 5)
@export var speed_scale_exp : Stat       = Stat.new("speed_scale_exp",       "", 0.3)
@export var perception_range : Stat      = Stat.new("perception_range",      "", 8)
@export var personal_space : Stat        = Stat.new("personal_space",        "", 4)

@export var seperate_weight : Stat       = Stat.new("seperate_weight",       "", 4)
@export var alignment_weight : Stat      = Stat.new("alignment_weight",      "", 1)
@export var cohesion_weight : Stat       = Stat.new("cohesion_weight",       "", 1)
@export var goal_weight : Stat           = Stat.new("goal_weight",           "", 1.2)
@export var stay_on_screen_weight : Stat = Stat.new("stay_on_screen_weight", "", 2)
@export var cam_moving_weight : Stat     = Stat.new("cam_moving_weight",     "", 1.2)

@export var repel_radius : Stat          = Stat.new("repel_radius",          "", 5.0)
@export var repel_weight : Stat          = Stat.new("repel_weight",          "", 5.0)

# coward shit
@export var flee_weight : Stat           = Stat.new("flee_weight",           "", 2.1)
@export var is_fleeing : bool = false
@export var flee_timer: float = 0.0
@export var flee_duration : Stat         = Stat.new("flee_duration",         "", 3)   # 3 seconds
@export var flee_direction : Vector3 = Vector3.ZERO

# split up sub group stuff
@export var spin_weight : Stat           = Stat.new("spin_weight",           "", 1)
@export var minimum_group_size : Stat    = Stat.new("minimum_group_size",    "", 5)

@export var steering_smoothness : Stat   = Stat.new("steering_smoothness",   "", 8.0)
@export var rotation_smoothness : Stat   = Stat.new("rotation_smoothness",   "", 8.0)
@export var steering_strength : Stat     = Stat.new("steering_strength",     "", 8.0)
@export var steering_mode : STEERING_MODE = STEERING_MODE.LERP
@export var rotation_mode : ROTATION_MODE = ROTATION_MODE.LERP_TO_VELOCITY
