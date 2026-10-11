extends ChunkTerrainObject
class_name ChunkTerrainHeightMap

@export_enum( "Add", "Sub", "Min", "Max" ) var operation: int;

func is_in_bounds( position: Vector3i ) -> bool:
	return position.x >= 0 and position.z >= 0 and \
		position.x < size.x and position.z < size.z;

# TODO Temporary methed for reading voxel data. Will be replaced with new editing method
func transform_voxel( position: Vector3i, value: float ) -> float:
	
	var index: int = position.x + position.z * size.x;
	var sample: float = data[ index ];
	
	match operation:
		
		0: # ADD
			return value + sample;
		
		1: # SUB
			return value - sample;
		
		2: # MIN
			return min( value, sample - position.y );
		
		3: # MAX
			return max( value, sample - position.y );
	
	# Default
	return value;
