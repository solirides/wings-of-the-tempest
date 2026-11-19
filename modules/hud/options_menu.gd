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
	Global.camera.lock_to_axis = %CameraModeOption.get_item_id(index)
