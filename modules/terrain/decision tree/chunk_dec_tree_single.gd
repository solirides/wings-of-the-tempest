@abstract
@tool
extends ChunkDecTree
class_name ChunkDecTreeSingle

@export var child: ChunkDecTree:
	set( value ):
		
		#Update value
		child = value;
		
		#Connect signals
		if child and not child.chunk_definition_added.is_connected( _chunk_definition_added ):
			child.chunk_definition_added.connect( _chunk_definition_added );
