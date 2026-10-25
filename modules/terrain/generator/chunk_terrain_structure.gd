extends ChunkTerrainObject
class_name ChunkTerrainStructure

@export var height: int;

func get_bounds() -> Vector3i:
	return size;

func get_height() -> int:
	return height;

func transform_voxel( position: Vector3i, value: float ) -> float:
	
	position.y -= height;
	
	var index: int = position.x + size.x * position.z + size.x * size.z * position.y;
	return max( data[ index ], value );
