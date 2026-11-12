extends Control


func enable_vignette(state: bool):
	$Vignette.visible = state

func change_vignette_color(color: Color):
	$Vignette.material.set_shader_parameter("color", color)
