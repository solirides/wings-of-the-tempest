extends Resource
class_name ChunkDefinition

@export var size: Vector3i;

func create_terrain_data( state: ChunkGenState ) -> Array3D:
	
	var chunk_pos: Vector3i = Vector3i.RIGHT * size * state.chunk_index;
	
	var scalar_field: = Array3D.packedFloat32( size + Vector3i.ONE );
	
	for voxel in Rect3iIterator.new( Vector3i.ZERO, scalar_field.size ):
		var world_voxel = chunk_pos + voxel;
		scalar_field.set_at( voxel, 4 * state.noise.get_noise_2d( 10 * world_voxel.x, 10 * world_voxel.z ) - world_voxel.y + 10.0 );
	
	return scalar_field;
