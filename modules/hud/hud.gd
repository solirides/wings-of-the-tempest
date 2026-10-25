extends Control

@onready var hunger_bar: TextureProgressBar = %HungerBar
@onready var water_bar: TextureProgressBar = %WaterBar
@onready var end_screen = $LevelEndScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.hud = self
	# call Global.check_ready_nodes() once this ready function is finished
	connect("ready", Global.check_ready_nodes)
	# call _on_main_nodes_ready() when Global emits the signal
	Global.connect("main_nodes_ready", self._on_main_nodes_ready)
	
	end_screen.visible = false

func _on_main_nodes_ready():
	#print("on main nodes ready")
	connect_to_player(Global.flock)

func _physics_process(delta: float) -> void:
	if Global.flock:
		hunger_bar.value = Global.flock.current_hunger
		#water_bar.value = Global.flock.water

func connect_to_player(player: Node3D) -> void:
	player.hunger_changed.connect(_on_hunger_changed)

func _on_hunger_changed(current: float) -> void:
	# this only triggers when the flock eats something, not for passive starving
	pass
	#hunger_bar.value = current

func show_end_screen():
	end_screen.update_stats()
	end_screen.visible = true
