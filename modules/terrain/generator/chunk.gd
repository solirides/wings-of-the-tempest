extends Node3D
class_name Chunk

static var heightmap_debug_material: StandardMaterial3D = preload( "res://modules/terrain/test assets/heightmap_debug.tres" );

static var all: Array[ Chunk ];

## Returns the chunk which contains the global position. Returns NULL if no chunk is present at that position
static func get_chunk_containing_global_position( at_position: Vector3 ) -> Chunk:
	
	for chunk in all:
		if chunk.contains_coordinates_global( Vector2( at_position.x, at_position.z ) ):
			return chunk;
	
	return null;

## Returns the global position at the intersection between the global ray and all chunks' terrain. Returns Vector3.INF if no intersection is found
static func intersect( start: Vector3, end: Vector3, world: World3D ) -> Vector3:
	
	var space_state: = world.direct_space_state;
	var ray_query: = PhysicsRayQueryParameters3D.create( start, end, 4 );
	
	var ray_result: = space_state.intersect_ray( ray_query );
	
	if ray_result.is_empty():
		return Vector3.INF;
	
	return ray_result.position;



var terrain_size: Vector3i;
var terrain_scale: Vector3;
var boid_height: float;
var mesh_instance: MeshInstance3D;
var collision_instance: StaticBody3D;
var heightmap_terrain: Array3D;
var heightmap_accessibility: Array3D;
var heightmap_mesh_instance: MeshInstance3D;



## Return size of chunk in worldspace
func get_global_size() -> Vector3:
	return Vector3( terrain_size ) * terrain_scale;

## Set material used by the chunk's terrain mesh
func set_terrain_material( material: Material ) -> void:
	mesh_instance.material_override = material;



## Create terrain for this chunk based on a 3D grid of scalar voxel data
func create_terrain_mesh( scalar_field: Array3D ) -> void:
	
	var vertices: = await MarchingCube.generate_vertices_on_thread( scalar_field, 0.0, terrain_scale );
	var mesh: Mesh = MesherThread.generate_mesh( vertices, Mesh.PrimitiveType.PRIMITIVE_TRIANGLES );
	
	mesh_instance.set_deferred( "mesh", mesh );
	
	var shape: = ConcavePolygonShape3D.new();
	shape.set_faces( mesh.get_faces() );
	var shape_owner: = CollisionShape3D.new();
	shape_owner.shape = shape;
	
	collision_instance.collision_layer = 4; # Terrain layer
	collision_instance.call_deferred( "add_child", shape_owner, false, INTERNAL_MODE_FRONT );

## Create heightmap for this chunk based on a 3d grid of scalar voxel data
func create_heightmap( scalar_field: Array3D, height: int ) -> Array3D:
	var new_heightmap = Array3D.packedFloat32( Vector3i( terrain_size.x + 1, 1, terrain_size.z + 1 ) );
	var group = WorkerThreadPool.add_group_task( create_heightmap_at_position.bind( scalar_field, height, new_heightmap ), new_heightmap.get_length(), -1, false, "Heightmap Generation thread" );
	WorkerThreadPool.wait_for_group_task_completion( group );
	return new_heightmap;

## Create the heightmap at one horizontal postion. Used by threads when calling create_heightmap()
func create_heightmap_at_position( index: int, scalar_field: Array3D, height: int, this_heightmap: Array3D ) -> void:
	
	var horizontal = this_heightmap.get_position_at( index );
	
	# Remember previous scalar
	var prev_val: float;
	
	# Descending through the field...
	for y in range( height, 0, -1 ):
		
		# Get position
		var pos: = Vector3i( horizontal.x, y, horizontal.z );
		
		# Get value at position
		var val: float = scalar_field.get_at( pos );
		
		# If value indicates inside terrain...
		if val > 0:
			
			# If at top of field, set as top
			if y == scalar_field.get_size().y:
				this_heightmap.set_at( horizontal, y );
				break;
			
			# If exceeding accessible height, set as innaccessible
			if y == height:
				this_heightmap.set_at( horizontal, -1 );
				break
			
			# Otherwise, set to position proportional between this and last value
			this_heightmap.set_at( horizontal, 
				lerp( y, y + 1, val / ( val - prev_val ) )
			);
			break;
		
		prev_val = val;

## Create a mesh to draw the heightmap, for debugging purposes
func create_heightmap_mesh( this_heightmap: Array3D, resolution: float ) -> void:
	
	var vertices: PackedVector3Array;
	
	for iter: Vector3i in Rect3iIterator.new( Vector3i.ZERO, ( this_heightmap.get_size() - Vector3i( 1, 0, 1 ) ) * resolution ):
		var pos: = Vector3( iter ) / resolution * terrain_scale;
		if is_height_accessible( Vector2( pos.x, pos.z ) ):
			pos.y = get_height( this_heightmap, Vector2( pos.x, pos.z ) );
			vertices.append( pos * scale );
	
	var mesh: = await MesherThread.generate_mesh_on_thread( vertices, Mesh.PrimitiveType.PRIMITIVE_POINTS );
	heightmap_mesh_instance.set_deferred( "mesh", mesh );

## Create objects for this chunk based on a list of objects and vectors
func create_objects( objects: Array[ ChunkObjectData ], mirror_x: bool, mirror_z: bool ) -> void:
	
	for object_data: ChunkObjectData in objects:
		
		# If no scene provided, skip
		if not object_data.object:
			continue;
		
		# Instantiate scene
		var object_node: Node3D = object_data.object.scene.instantiate();
		
		# Overwrite any specified properties of the scene
		for property in object_data.object.property_overrides.keys():
			object_node.set( property, object_data.object.property_overrides[ property ] );
		
		# Set scene position
		object_node.position = get_position_of_object( object_data, mirror_x, mirror_z );
		
		# Add to chunk
		add_child( object_node );

## Randomly exclude some objects based on their spawn chance
func randomize_objects( objects: Array[ ChunkObjectData ], state: ChunkGenState ) -> Array[ ChunkObjectData ]:
	return objects.filter( func( object_data ): return state.get_seeded_float() <= object_data.spawn_chance );

## Get the position at which the object would be placed on this chunk
func get_position_of_object( object_data: ChunkObjectData, mirror_x: bool, mirror_z: bool ) -> Vector3:
	
	# Initial coords
	var object_pos: = object_data.position;
	
	# Flip x axis if necessary
	if mirror_x:
		object_pos.x = get_global_size().x - object_pos.x;
	
	# Flip z axis if necessary
	if mirror_z:
		object_pos.y = get_global_size().z - object_pos.y;
	
	# Initial height
	var height: float = object_data.object.height_offset;
	
	# Snap offset
	if object_data.object.height_mode == ChunkObject.HeightMode.SNAP and contains_coordinates( object_data.position ):
		height += get_height( heightmap_terrain, object_pos );
	
	# Boid offset
	if object_data.object.height_mode == ChunkObject.HeightMode.ACCESSIBLE:
		height += boid_height;
	
	# Construct position
	return Vector3( object_pos.x, height, object_pos.y );




func create( definition: ChunkDefinition, state: ChunkGenState, consistency_mode: bool = false ) -> void:
	
	terrain_size = definition.terrain_size;
	terrain_scale = definition.terrain_scale;
	boid_height = definition.terrain_accessible_height;
	
	var mirror_x = not consistency_mode and definition.can_mirror_x and state.get_seeded_int() % 2;
	var mirror_z = not consistency_mode and definition.can_mirror_z and state.get_seeded_int() % 2;
	
	# Generate chunk using data from definition
	var terrain_data: = Array3D.packedFloat32( definition.terrain_size + Vector3i.ONE );
	
	# Create terrain
	definition.create_terrain_surface( terrain_data, state.chunk_sampler, position );
	definition.create_terrain_objects( terrain_data );
	
	# Create heightmaps
	heightmap_accessibility = create_heightmap( terrain_data, definition.terrain_accessible_height );
	heightmap_terrain = create_heightmap( terrain_data, definition.terrain_size.y );
	
	# Create objects
	var objects: = definition.get_objects();
	create_objects( objects if consistency_mode else randomize_objects( objects, state ), mirror_x, mirror_z );
	
	# Create mesh
	create_terrain_mesh( terrain_data );
	
	# DEBUG
	#chunk.create_heightmap_mesh( chunk.heightmap_terrain, 4 );

func _ready() -> void:
	
	#Create internal nodes
	mesh_instance = MeshInstance3D.new();
	add_child( mesh_instance, false, Node.INTERNAL_MODE_FRONT );
	heightmap_mesh_instance = MeshInstance3D.new();
	add_child( heightmap_mesh_instance, false, Node.INTERNAL_MODE_FRONT );
	collision_instance = StaticBody3D.new();
	add_child( collision_instance );

func _enter_tree() -> void:
	all.append( self );

func _exit_tree() -> void:
	all.erase( self );



## Determine if a pair of XZ coordinates relative to the chunk are within its boundaries
func contains_coordinates( coordinates: Vector2 ) -> bool:
	
	return \
		coordinates.x >= 0 and \
		coordinates.y >= 0 and \
		coordinates.x <= get_global_size().x and \
		coordinates.y <= get_global_size().z;

## Determine if a pair of XZ global coordinates are contained in the chunk
func contains_coordinates_global( coordinates: Vector2 ) -> bool:
	return contains_coordinates( coordinates - Vector2( global_position.x, global_position.z ) );

## Find vertical position using a heightmap at a horizontal position
func get_height( heightmap: Array3D, coordinates: Vector2 ) -> float:
	coordinates /= Vector2( terrain_scale.x, terrain_scale.z );
	assert( coordinates.x >= 0 and coordinates.y >= 0 and coordinates <= Vector2( heightmap.get_size().x, heightmap.get_size().y ), "Scaled coordinates " + str( coordinates ) + " are not within the heightmaps size of " + str( heightmap.get_size() ) );
	var integer: Vector2i = coordinates.floor();
	var fractional: = coordinates.posmod( 1.0 );
	var next: = ( integer + Vector2i.ONE ).min( Vector2i( heightmap.get_size().x, heightmap.get_size().z ) - Vector2i.ONE );
	return lerp( 
		lerp( 
			heightmap.get_at( Vector3i( integer.x, 0, integer.y ) ),
			heightmap.get_at( Vector3i( next.x, 0, integer.y ) ),
			fractional.x
		),
		lerp( 
			heightmap.get_at( Vector3i( integer.x, 0, next.y ) ),
			heightmap.get_at( Vector3i( next.x, 0, next.y ) ),
			fractional.x
		),
		fractional.y
	);

## Find vertical position using a heightmap at a horizontal position, in global coordinate space
func get_height_global( heightmap: Array3D, coordinates: Vector2 ) -> float:
	return get_height( heightmap, coordinates - Vector2( global_position.x, global_position.z ) ) + global_position.y;

## Check if position at accessible height is occluded by terrain
func is_height_accessible( coordinates: Vector2 ) -> bool:
	return get_height( heightmap_accessibility, coordinates ) >= 0;

## Check if position at accessible height is occluded by terrain, in global coordinate space
func is_height_accessible_global( coordinates: Vector2 ) -> bool:
	return is_height_accessible( coordinates - Vector2( global_position.x, global_position.z ) );
