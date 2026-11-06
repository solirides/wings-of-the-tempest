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
	
	if not has_chunk_data():
		return;
	
	remove_chunk();
	
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

func remove_chunk() -> void:
	
	if chunk:
		chunk.queue_free();
	
	chunk = null;



func _ready() -> void:
	%TabContainer.visible = false;

func _process( delta: float ) -> void:
	
	# Rotate camera
	%CameraPivot.rotate_y( 0.1 * delta );

func _updated_chunk() -> void:
	set_chunk();
	%TabContainer.visible = chunk != null;



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
		chunk_library = load( file );

func _chunk_def_chosen( file: String ) -> void:
	if file != "":
		chunk_definition = load( file );



func _library_material_chosen( file: String ) -> void:
	if file != "":
		chunk_library.terrain_material = load( file );
		_updated_chunk();
