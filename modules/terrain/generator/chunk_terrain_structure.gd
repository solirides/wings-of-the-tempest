extends ChunkTerrainObject
class_name ChunkTerrainStructure

@export var height: int;

func is_in_bounds( position: Vector3i ) -> bool:
	
	return position.x >= 0 and position.y >= 0 and position.z >= 0 and \
		position.x < size.x and position.y < size.y and position.z < size.z;

# TODO Temporary methed for reading voxel data. Will be replaced with new editing method
func transform_voxel( position: Vector3i, value: float ) -> float:
	
	position.y -= height;
	
	var index: int = position.x + size.x * position.z + size.x * size.z * position.y;
	return max( data[ index ], value );
