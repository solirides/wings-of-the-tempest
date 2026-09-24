@abstract
@tool
extends Resource
class_name ChunkDecTree

signal chunk_definition_added( leaf: ChunkDecTreeLeaf );

## Selects a leaf based on the rulesets of child branches
@warning_ignore( "unused_parameter" )
func pick( state: ChunkGenState ) -> ChunkDefinition:
	return null;

## Executes when a Chunk Definition is added to a leaf of a child tree
func _chunk_definition_added( leaf: ChunkDecTreeLeaf ) -> void:
	
	#Propogate signal upward
	chunk_definition_added.emit( leaf );
