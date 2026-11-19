extends Control

func _ready() -> void:
	self.visible = false

func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	pass
	#Global.pause_gameplay(false)
	#self.visible = false

func _on_visibility_changed() -> void:
	if Global.camera:
		%CameraModeOption.selected = %CameraModeOption.get_item_index(Global.camera.lock_to_axis == true)

func _on_camera_mode_option_item_selected(index: int) -> void:
	print("camera mode selected")
	#print(Global.camera.lock_to_axis)
	print(%CameraModeOption.get_item_id(index))
	if Global.camera:
		Global.camera.lock_to_axis = %CameraModeOption.get_item_id(index)


func _on_music_slider_value_changed(value: float) -> void:
	var db = -60 + 60 * value / 100.0
	Audio.set_bus_volume("Music", db)
	print(AudioServer.get_bus_volume_db(1))


func _on_sfx_slider_value_changed(value: float) -> void:
	#var db = 10 * log(value / 100) / log(10)
	var db = -60 + 60 * value / 100.0
	Audio.set_bus_volume("Sfx", db)
	print(AudioServer.get_bus_volume_db(2))
