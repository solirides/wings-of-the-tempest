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
	chunk.create( chunk_definition, ChunkGenState.new( terrain_seed, chunk_library.terrain_sampler ), false );
	
	# Freeze chunk
	chunk.process_mode = Node.PROCESS_MODE_DISABLED;
	
	populate_editor_values();

func remove_chunk() -> void:
	
	if chunk:
		chunk.queue_free();
	
	chunk = null;

func populate_editor_values() -> void:
	
	# Position chunk
	chunk.position = chunk.get_global_size() * Vector3( -0.5, 0, -0.5 );
	
	# Position camera
	var chunk_size: = chunk.get_global_size();
	%Camera.position = Vector3( 0, chunk_size.y * 1.5, max( chunk_size.x, chunk_size.z ) * 0.75 );
	
	# Show height planes
	%BoidHeightPlane.visible = true;
	%DecorHeightPlane.visible = true;
	
	# Scale height planes
	%BoidHeightPlane.scale = chunk.get_global_size();
	%DecorHeightPlane.scale = chunk.get_global_size();
	
	# Position height planes
	%BoidHeightPlane.position.y = chunk.position.y + chunk_definition.terrain_accessible_height;
	%DecorHeightPlane.position.y = chunk.position.y + chunk_definition.terrain_decorator_height;
	
	# Init object list
	%ObjectSubmenu.visible = false;
	create_chunk_object_buttons();
	
	# Chunk vals
	%ChunkSizeInput.set_input( [ chunk_definition.get_size()[0], chunk_definition.get_size()[1], chunk_definition.get_size()[2] ] );
	%ChunkScaleInput.set_input( [ chunk_definition.get_scale()[0], chunk_definition.get_scale()[1], chunk_definition.get_scale()[2] ] );
	%ChunkHDecorInput.set_input( [ chunk_definition.terrain_decorator_height ] );
	%ChunkHBoidInput.set_input( [ chunk_definition.terrain_accessible_height ] );
	
	# Lib vals
	%LibSizeInput.set_input( [ chunk_library.terrain_size[0], chunk_library.terrain_size[1], chunk_library.terrain_size[2] ] );
	%LibScaleInput.set_input( [ chunk_library.terrain_scale[0], chunk_library.terrain_scale[1], chunk_library.terrain_scale[2] ] );
	%LibHDecorInput.set_input( [ chunk_library.terrain_decorator_height ] );
	%LibHBoidInput.set_input( [ chunk_library.terrain_accessible_height ] );



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
	%BoidHeightPlane.visible = false;
	%DecorHeightPlane.visible = false;

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



func _new_library() -> void:
	chunk_library = ChunkLibrary.new();
	set_chunk();

func _new_definition() -> void:
	chunk_definition = ChunkDefinition.new();
	if chunk_library:
		_set_size_from_library();
	set_chunk();

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

func _chunk_lib_updated( _file: String, _valid: bool ) -> void:
	%ChunkLibInput.set_text_modulate( Color.GRAY );

func _chunk_def_updated( _file: String, _valid: bool ) -> void:
	%ChunkDefInput.set_text_modulate( Color.GRAY );

func _chunk_lib_chosen( file: String ) -> void:
	if file != "":
		chunk_library = ResourceLoader.load( file, "", ResourceLoader.CACHE_MODE_REPLACE );
		%ChunkLibInput.set_text_modulate( Color.WHITE );

func _chunk_def_chosen( file: String ) -> void:
	if file != "":
		chunk_definition = ResourceLoader.load( file, "", ResourceLoader.CACHE_MODE_REPLACE );
		%ChunkDefInput.set_text_modulate( Color.WHITE );



func _chunk_size_submitted( value: int, index: int ) -> void:
	chunk_definition.terrain_size[ index ] = value;
	set_chunk();

func _chunk_scale_submitted( value: float, index: int ) -> void:
	chunk_definition.terrain_scale[ index ] = value;
	set_chunk();

func _chunk_decor_height_submitted( value: int, _index: int ) -> void:
	chunk_definition.terrain_decorator_height = value;
	set_chunk();

func _chunk_boid_height_submitted( value: int, _index: int ) -> void:
	chunk_definition.terrain_accessible_height = value;
	set_chunk();

func _library_size_submitted( value: int, index: int ) -> void:
	chunk_library.terrain_size[ index ] = value;

func _library_scale_submitted( value: float, index: int ) -> void:
	chunk_library.terrain_scale[ index ] = value;

func _library_decor_height_submitted( value: int, _index: int ) -> void:
	chunk_library.terrain_decorator_height = value;

func _library_boid_height_submitted( value: int, _index: int ) -> void:
	chunk_library.terrain_accessible_height = value;

func _set_size_from_library() -> void:
	chunk_definition.terrain_size = chunk_library.terrain_size;
	chunk_definition.terrain_scale = chunk_library.terrain_scale;
	chunk_definition.terrain_accessible_height = chunk_library.terrain_accessible_height;
	chunk_definition.terrain_decorator_height = chunk_library.terrain_decorator_height;
	set_chunk();



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
