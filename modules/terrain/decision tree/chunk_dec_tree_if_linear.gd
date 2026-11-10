@tool
extends ChunkDecTreeIf
class_name ChunkDecTreeIfLinear

## Comparison to be performed
@export_enum( "Equal", "Not Equal", "Less Than", "Greater Than", "Less or Equal", "Greater or Equal" ) var operation: String = "Equal";

## Compared index
@export var operand: int;

func condition( state: ChunkGenState ) -> bool:
	match operation:
		"Equal":
			return state.chunk_index == operand;
		"Not Equal":
			return state.chunk_index != operand;
		"Less Than":
			return state.chunk_index < operand;
		"Greater Than":
			return state.chunk_index > operand;
		"Less or Equal":
			return state.chunk_index <= operand;
		"Greater or Equal":
			return state.chunk_index >= operand;
	return false;
