extends Resource
class_name ChunkDefinition

@export var size: Vector3i;
@export var terrain_height: int;
@export var terrain_objects: Dictionary[ ChunkTerrainObject, Vector2i ];

func create_terrain_data( state: ChunkGenState ) -> Array3D:
	
	var chunk_pos: Vector3i = Vector3i.RIGHT * size * state.chunk_index;
	
	var scalar_field: = Array3D.packedFloat32( size + Vector3i.ONE );
	
	for voxel in Rect3iIterator.new( Vector3i.ZERO, scalar_field.size ):
		
		var world_voxel = chunk_pos + voxel;
		
		# Get base noise value
		var value: float = ( state.noise.get_noise_2d( 10 * world_voxel.x, 10 * world_voxel.z ) * 0.5 + 0.5 ) \
			* terrain_height - world_voxel.y;
		
		# Get object data
		for object in terrain_objects.keys():
			
			# Get origin of object
			var object_origin = terrain_objects.get( object );
			var object_voxel = voxel - Vector3i( object_origin.x, 0, object_origin.y );
			
			# Transform value from object
			if object.is_in_bounds( object_voxel ):
				value = object.transform_voxel( object_voxel, value );
		
		# Set in field
		scalar_field.set_at( voxel, value );
	
	return scalar_field;
