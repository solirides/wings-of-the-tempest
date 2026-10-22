extends ChunkTerrainObject
class_name ChunkTerrainHeightMap

@export_enum( "Add", "Sub", "Min", "Max" ) var operation: int;

func get_bounds() -> Vector3i:
	return Vector3i( size.x, -1, size.z );

func get_height() -> int:
	return 0;

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
