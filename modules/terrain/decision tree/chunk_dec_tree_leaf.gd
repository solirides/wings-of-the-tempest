@tool
extends ChunkDecTree
class_name ChunkDecTreeLeaf

@export var chunk: ChunkDefinition:
	set( value ):
		
		#Update value
		chunk = value;
		
		#Send signal
		_chunk_definition_added( self );

func pick( _state: ChunkGenState ) -> ChunkDefinition:
	
	#Choose chunk
	return chunk;
