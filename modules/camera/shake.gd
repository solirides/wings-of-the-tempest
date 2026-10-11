extends Node3D


var frequency = 0
var duration = 0
var amplitude = 0
var level = 0

@onready var camera = get_parent()
@onready var duration_timer = $Duration
@onready var frequency_timer = $Frequency

@onready var frequency_tween = Tween
@onready var duration_tween = Tween
@onready var tween = Tween

func _ready():
	pass

func shake(duration = 0.3, amplitude = 0.5, frequency = 24, level = 0):
	pass
	if level >= self.level:
		self.level = level
		self.amplitude = amplitude
		self.frequency = frequency
		self.duration = duration
		
		duration_timer.wait_time = duration
		duration_timer.start()
		frequency_timer.wait_time = 1.0 / float(frequency)
		frequency_timer.start()
		
		#print("shake")

func screenshake():
	var random = Vector2()
	random.x = randf_range(-amplitude, amplitude)
	random.y = randf_range(-amplitude, amplitude)
	
	tween = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(camera, "h_offset", random.x, 1.0 / frequency)
	tween.tween_property(camera, "v_offset", random.y, 1.0 / frequency)
	#tween.finished.connect(_on_tween_finished)
	
func reset():
	tween = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(camera, "h_offset", 0, 1.0 / frequency)
	tween.tween_property(camera, "v_offset", 0, 1.0 / frequency)
	#tween.finished.connect(_on_tween_finished)
	#camera.h_offset = 0
	#camera.v_offset = 0
	level = 0

func _on_tween_finished():
	tween.kill()

func _on_frequency_timeout() -> void:
	screenshake()
	#print("frequency")

func _on_duration_timeout() -> void:
	frequency_timer.stop()
	reset()
	#print("shake stop")
