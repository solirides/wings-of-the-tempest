@tool
extends ChunkDecTreeSingle
class_name ChunkLibrary

@export var chunk_size: Vector2i;

func _chunk_definition_added( leaf: ChunkDecTreeLeaf ) -> void:
	if leaf.chunk and leaf.chunk.size != chunk_size:
		push_error( "Attempted to insert Chunk Definition of size ", leaf.chunk.size, " into Chunk Library of size ", chunk_size );
		leaf.chunk = null;
