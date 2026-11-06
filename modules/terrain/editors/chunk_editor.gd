extends Node3D

var terrain_seed: int = 0:
	set( value ):
		terrain_seed = value;
		_updated_chunk();
var chunk_library: ChunkLibrary:
	set( value ):
		chunk_library = value;
		_updated_chunk();
var chunk_definition: ChunkDefinition:
	set( value ):
		chunk_definition = value;
		_updated_chunk();

var chunk: Chunk;



func has_chunk_data() -> bool:
	return chunk_library and chunk_library.terrain_sampler and chunk_definition;

func set_chunk() -> void:
	
	remove_chunk();
	
	if not has_chunk_data():
		return;
	
	# Copy sampler so we can insert test values
	var sampler: = chunk_library.terrain_sampler.duplicate();
	sampler.set_seed( terrain_seed );
	
	# Create chunk
	chunk = Chunk.new();
	add_child( chunk );
	chunk.set_terrain_material( chunk_library.terrain_material );
	chunk.create( chunk_library.terrain_sampler, chunk_definition );
	
	# Freeze chunk
	chunk.process_mode = Node.PROCESS_MODE_DISABLED;
	
	# Position objects
	chunk.position = chunk.get_global_size() * Vector3( -0.5, 0, -0.5 );
	%Camera.position = Vector3( 0, 1.5, 0.75 ) * chunk.get_global_size();
	
	# Setup
	%ObjectSubmenu.visible = false;
	create_chunk_object_buttons();

func remove_chunk() -> void:
	
	if chunk:
		chunk.queue_free();
	
	chunk = null;



func create_chunk_object_buttons() -> void:
	
	for child in %ChunkObjContainer.get_children():
		child.queue_free();
	
	if not chunk_definition:
		return;
	
	for object_data in chunk_definition.get_objects():
		var button: = Button.new();
		button.text = "Empty" if not object_data.object else object_data.object.name;
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS;
		button.pressed.connect( open_chunk_object_editor.bind( object_data ) );
		%ChunkObjContainer.add_child( button );

func open_chunk_object_editor( object_data: ChunkObjectData ) -> void:
	%ObjectSubmenu.visible = true;
	%ObjectSubmenu.create( object_data );



func _ready() -> void:
	%TabContainer.visible = false;
	%QuickMenu.visible = false;
	%ObjectSubmenu.visible = false;

func _process( delta: float ) -> void:
	
	# Rotate camera
	%CameraPivot.rotate_y( 0.1 * delta );
	
	# Point to selected object
	if %ObjectSubmenu.object_data:
		var object_data = %ObjectSubmenu.object_data;
		var object_position = chunk.global_position + Vector3( object_data.position.x, chunk.get_height_of_object( object_data ), object_data.position.y );
		var screen_position = %Camera.unproject_position( object_position );
		%ObjectPointer.set_point_position( 0, screen_position - %ObjectPointer.get_parent().global_position );
		%ObjectPointer.visible = not %Camera.is_position_behind( object_position );

func _updated_chunk() -> void:
	set_chunk();
	%TabContainer.visible = chunk != null;
	%QuickMenu.visible = chunk != null;

func _pause_chunk() -> void:
	if chunk.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
		chunk.process_mode = ProcessMode.PROCESS_MODE_ALWAYS;
	else:
		chunk.process_mode = ProcessMode.PROCESS_MODE_DISABLED;



func _save_library() -> void:
	
	var filepath: String = %ChunkLibInput.get_input();
	
	if not filepath.begins_with( "res://" ):
		return;
	
	ResourceSaver.save( chunk_library, filepath );
	%ChunkLibInput._text_input_changed( %ChunkLibInput.get_input() );

func _save_definition() -> void:
	
	var filepath: String = %ChunkDefInput.get_input();
	
	if not filepath.begins_with( "res://" ):
		return;
	
	ResourceSaver.save( chunk_definition, filepath );
	%ChunkDefInput._text_input_changed( %ChunkDefInput.get_input() );

func _chunk_lib_chosen( file: String ) -> void:
	if file != "":
		chunk_library = ResourceLoader.load( file, "", ResourceLoader.CACHE_MODE_REPLACE );

func _chunk_def_chosen( file: String ) -> void:
	if file != "":
		chunk_definition = ResourceLoader.load( file, "", ResourceLoader.CACHE_MODE_REPLACE );



func _chunk_object_updated() -> void:
	set_chunk();

func _chunk_object_erased( object_data: ChunkObjectData ) -> void:
	chunk_definition.objects.erase( object_data );

func _chunk_object_add() -> void:
	if %ObjInput.is_input_valid():
		var object_data: = ChunkObjectData.new();
		object_data.object = load( %ObjInput.get_input() );
		chunk_definition.objects.append( object_data );
		set_chunk();



func _library_material_chosen( file: String ) -> void:
	if file != "":
		chunk_library.terrain_material = load( file );
		_updated_chunk();
