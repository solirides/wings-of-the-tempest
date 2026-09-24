extends Control

@onready var hunger_bar: TextureProgressBar = %HungerBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func connect_to_player(player: Node3D) -> void:
	player.hunger_changed.connect(_on_hunger_changed)

func _on_hunger_changed(current: float) -> void:
	hunger_bar.value = current
