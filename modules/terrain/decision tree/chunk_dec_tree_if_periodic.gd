@tool
extends ChunkDecTreeIf
class_name ChunkDecTreeIfPeriodic

## Length of repetition
@export var period: int;

## Beginning of succeed window
@export var phase: int = 0;

## Size of succeed window
@export var length: int = 1;

func condition( state: ChunkGenState ) -> bool:
	return ( state.chunk_index + phase ) % period < length;
