extends Resource
class_name ChunkDefinition

@export var terrain_size: Vector3i;
@export var terrain_scale: Vector3;
@export var terrain_decorator_height: int;
@export var terrain_accessible_height: int;
@export var objects: Dictionary[ ChunkObject, Vector2 ];
@export var terrain_objects: Dictionary[ ChunkTerrainObject, Vector2i ];

func create_terrain_surface( scalar_field: Array3D, state: ChunkGenState, chunk_position: Vector3 ) -> void:
	
	var group: = WorkerThreadPool.add_group_task( create_terrain_surface_at_voxel.bind( scalar_field, state, chunk_position ), scalar_field.get_length(), -1, false, "Chunk Generation thread" );
	WorkerThreadPool.wait_for_group_task_completion( group );

func create_terrain_surface_at_voxel( index: int, scalar_field: Array3D, state: ChunkGenState, chunk_position: Vector3 ) -> void:
	
	var voxel = scalar_field.get_position_at( index );
	
	var world_voxel = Vector3i( chunk_position / terrain_scale ) + voxel;
	
	# Get decorator noise value
	var value: float = ( state.noise.get_noise_2d( 10 * world_voxel.x, 10 * world_voxel.z ) * 0.5 + 0.5 ) \
		* terrain_decorator_height - world_voxel.y;
	
	# Set in field
	scalar_field.set_at( voxel, value );

func create_terrain_objects( scalar_field: Array3D ) -> void:
	
	# Get object data
	for object: ChunkTerrainObject in terrain_objects.keys():
		
		var bounds: = object.get_bounds();
		for axis in 3: if bounds[axis] < 0: bounds[axis] = terrain_size[axis];
		
		for voxel in Rect3iIterator.new( Vector3i.ZERO, bounds ):
			
			var object_origin = terrain_objects.get( object );
			var chunk_voxel = voxel + Vector3i( object_origin.x, object.get_height(), object_origin.y );
			
			scalar_field.set_at( chunk_voxel, object.transform_voxel( voxel, scalar_field.get_at( chunk_voxel ) ) );

func get_objects() -> Dictionary[ ChunkObject, Vector2 ]:
	return objects;

func get_size() -> Vector3i:
	return terrain_size;
