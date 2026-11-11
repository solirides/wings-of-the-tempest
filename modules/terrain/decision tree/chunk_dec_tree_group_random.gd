@tool
extends ChunkDecTreeGroup
class_name ChunkDecTreeGroupRandom

func pick( state: ChunkGenState ) -> ChunkDefinition:
	if children.is_empty():
		return null;
	return children[ state.get_seeded_int() % children.size() ].pick( state );
