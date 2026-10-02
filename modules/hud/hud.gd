extends Control

@onready var hunger_bar: TextureProgressBar = %HungerBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.hud = self
	# call Global.check_ready_nodes() once this ready function is finished
	connect("ready", Global.check_ready_nodes)
	# call _on_main_nodes_ready() when Global emits the signal
	Global.connect("main_nodes_ready", self._on_main_nodes_ready)

func _on_main_nodes_ready():
	print("on main nodes ready")
	connect_to_player(Global.flock)

func connect_to_player(player: Node3D) -> void:
	player.hunger_changed.connect(_on_hunger_changed)

func _on_hunger_changed(current: float) -> void:
	hunger_bar.value = current
