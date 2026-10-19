extends Node3D
class_name ChunkGenerator

@export var tracked_node: Node3D:
	set( value ):
		value.moved.connect( _tracked_node_moved, CONNECT_APPEND_SOURCE_OBJECT  );
@export var tracking_buffer: float;

@export var library: ChunkLibrary;
@export var direction: Vector3;
var current_state: ChunkGenState;



func pick_chunk_def( state: ChunkGenState ) -> ChunkDefinition:
	assert( library, "ChunkGenerator is missing ChunkLibrary" );
	return library.pick( state );

func get_state_chunk_position( state: ChunkGenState ) -> Vector3:
	return library.get_chunk_global_size() * ( state.chunk_index * direction + Vector3.ZERO.min( direction.sign() ) );

func create_chunk( state: ChunkGenState ) -> void:
	
	var chunk_def: = pick_chunk_def( state );
	
	# Create chunk in world
	var chunk: = Chunk.new( chunk_def );
	add_child( chunk );
	chunk.set_terrain_material( library.terrain_material );
	chunk.position = get_state_chunk_position( state );
	
	# Generate chunk using data from definition
	var terrain_data: = chunk_def.create_terrain_data( state, chunk.position );
	chunk.create_terrain( terrain_data );
	chunk.create_heightmap( terrain_data );
	
	# DEBUG Create heightmap mesh
	chunk.create_heightmap_mesh( 4 );
	
	# Create chunk objects (must have created heightmap)
	chunk.create_objects( chunk_def.get_objects() );
	
	current_state._increment();



func _ready() -> void:
	
	#Initialize state, with Time used as random seed
	@warning_ignore("narrowing_conversion")
	current_state = ChunkGenState.new( Time.get_unix_time_from_system() );

#TEST
func _unhandled_input( event: InputEvent ) -> void:
	if event.is_action_pressed( "ui_accept" ):
		create_chunk( current_state );

func _tracked_node_moved( node: Node3D ) -> void:
	while ( node.position * direction ).length() + tracking_buffer > get_state_chunk_position( current_state ).length():
		create_chunk( current_state );
