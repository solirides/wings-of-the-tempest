extends Control

@onready var hunger_bar: TextureProgressBar = %HungerBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hunger_bar.max_value = Global.MAX_HUNGER
	hunger_bar.value = Global.current_hunger
	Global.hunger_changed.connect(_on_hunger_changed)

func _on_hunger_changed(current: float) -> void:
	hunger_bar.value = current
