@abstract
@tool
extends ChunkDecTree
class_name ChunkDecTreeIf

@export var succeed: ChunkDecTree:
	set( value ):
		
		#Update value
		succeed = value;
		
		#Connect signals
		if succeed and not succeed.chunk_definition_added.is_connected( _chunk_definition_added ):
			succeed.chunk_definition_added.connect( _chunk_definition_added );

@export var fail: ChunkDecTree:
	set( value ):
		
		#Update value
		fail = value;
		
		#Connect signals
		if fail and not fail.chunk_definition_added.is_connected( _chunk_definition_added ):
			fail.chunk_definition_added.connect( _chunk_definition_added );

func pick( state: ChunkGenState ) -> ChunkDefinition:
	
	#If condition passes, pick from succeed tree
	if condition( state ):
		return succeed.pick( state );
	
	#Else, pick from fail tree
	return fail.pick( state );

## Returns whether the pass or fail branch should be picked
@warning_ignore("unused_parameter")
func condition( state: ChunkGenState ) -> bool:
	return false;
