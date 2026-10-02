extends Node
class_name ChunkGenerator

@export var library: ChunkLibrary;
var current_state: ChunkGenState;



func pick_chunk_def( state: ChunkGenState ) -> ChunkDefinition:
	assert( library, "ChunkGenerator is missing ChunkLibrary" );
	return library.pick( state );

func create_chunk( state: ChunkGenState ) -> void:
	
	var chunk_def: = pick_chunk_def( state );
	
	#Create chunk in world
	var chunk: = Chunk.new();
	add_child( chunk );
	chunk.position.x = state.chunk_index * chunk_def.size.x;
	
	#Generate chunk using data from definition
	chunk.create_terrain( chunk_def.create_terrain_data( state ) );
	
	current_state._increment();



func _ready() -> void:
	
	#Initialize state, with Time used as random seed
	@warning_ignore("narrowing_conversion")
	current_state = ChunkGenState.new( Time.get_unix_time_from_system() );

#TEST
func _unhandled_input( event: InputEvent ) -> void:
	if event.is_action_pressed( "ui_accept" ):
		create_chunk( current_state );
