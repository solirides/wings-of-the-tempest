extends Node

# This global (Singleton) script is automatically loaded at runtime along with its scene.
# res://modules/global/global.tscn

# Scoring system
var score: int = 0
const FOOD_FACTOR = 1;
const MONUMENT_FACTOR = 1;
 
var game_is_paused = false
var reached_end = false

# Generally try to use these variables in Global to get references to these nodes. (or use the % prefix)
# This way we only have to make sure they exist here.
var flock: Node
var camera: Node
var hud: Node
var world: Node
var time_elapsed: float
# Emitted when the flock, camera, and hud variables have all been set
# Each main node sets their respective variable to themself in their ready function
# The ready signal of these nodes are also connected to call check_ready_nodes() here
signal main_nodes_ready
var ready_emitted = false

# Health system has been moved to the flock script res://modules/flock/flock.gd

# Signal that is emitted when score is updated
signal score_modified

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Global node ready")
	print("This is the root node of the Global scene: " + str(Global))
	get_tree().connect("scene_changed", _on_scene_changed)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

#func connect_node(node: Node, variable):
	#if node:
		#variable = node
	#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_is_paused == false:
		time_elapsed += delta

func check_ready_nodes():
	var ready = true
	for n in [flock, camera, hud, world]:
		if n == null:
			print("Global checking for main nodes.")
			ready = false
	if ready and ready_emitted == false:
		print("All main nodes are ready")
		main_nodes_ready.emit()
		ready_emitted = true
	


func _on_scene_changed():
	ready_emitted = false
	

func _input(event: InputEvent) -> void:
	# press esc to cycle through mouse capture modes
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	if event.is_action_pressed("escape"):
		Global.pause_gameplay()
	#if event.is_action_pressed("escape"):
		#print("escape pressed")
		#match Input.mouse_mode:
			#Input.MOUSE_MODE_CONFINED:
				#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			#Input.MOUSE_MODE_VISIBLE:
				#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			#_:
				#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			##Input.MOUSE_MODE_CAPTURED:
				##Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if event.is_action_pressed("debug_restart"):
		print("debug restart")
		start_scene_change("res://scenes/main_menu/main_menu.tscn")
	if event.is_action_pressed("debug_pause"):
		pause_gameplay()
	
func AddScore(score_to_add: int) -> void:
	score += score_to_add
	score_modified.emit()

func end_level() -> void:
	if (!reached_end):
		Audio.play_sfx_track("level complete")
		hud.show_end_screen()
		reached_end = true

func start_scene_change(scene:String):
	ResourceLoader.load_threaded_request(scene)
	$TransitionScreen.await_scene_change(scene)
	#pause_gameplay(false)

func quit_game():
	$TransitionScreen.fade_animation(true, 0.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func game_over():
	pass
	

func pause_gameplay(state: bool = !game_is_paused):
	if state == game_is_paused:
		return
	game_is_paused = state
	
	if game_is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	if world:
		# pause the world node
		if state:
			world.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			world.process_mode = Node.PROCESS_MODE_INHERIT
	
	if hud:
		hud.pause_menu.visible = state
	
	
