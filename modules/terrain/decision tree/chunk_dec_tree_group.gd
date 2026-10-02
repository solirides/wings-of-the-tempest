@abstract
@tool
extends ChunkDecTree
class_name ChunkDecTreeGroup

@export var children: Array[ ChunkDecTree ]:
	set( value ):
		
		#Update value
		children = value;
		
		#Connect signals for each branch
		for element in value:
			if element and not element.chunk_definition_added.is_connected( _chunk_definition_added ):
				element.chunk_definition_added.connect( _chunk_definition_added );
