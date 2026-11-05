extends Node3D
class_name ChunkEditor

var terrain_seed: int = 0;
var chunk_library: ChunkLibrary;
var chunk_definition: ChunkDefinition;

var chunk: Chunk;

func has_chunk_data() -> bool:
	return chunk_library and chunk_library.terrain_sampler and chunk_definition;

func create_chunk() -> void:
	
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

func remove_chunk() -> void:
	
	if chunk:
		chunk.queue_free();
	
	chunk = null;
