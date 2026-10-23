extends Node3D
class_name Chunk

static var heightmap_debug_material: StandardMaterial3D = preload( "res://modules/terrain/heightmap_debug.tres" );

static var all: Array[ Chunk ];

## Returns the chunk which contains the global position. Returns NULL if no chunk is present at that position
static func get_chunk_containing_global_position( at_position: Vector3 ) -> Chunk:
	
	for chunk in all:
		if at_position >= chunk.global_position and at_position < chunk.global_position + chunk.get_global_size():
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
	
	var mesh: = MarchingCube.generate_mesh( MarchingCube.generate_vertices( scalar_field, 0.0, terrain_scale ) );	
	mesh_instance.mesh = mesh;
	
	var shape: = ConcavePolygonShape3D.new();
	shape.set_faces( mesh.get_faces() );
	var shape_owner: = CollisionShape3D.new();
	shape_owner.shape = shape;
	
	collision_instance.add_child( shape_owner, false, INTERNAL_MODE_FRONT );
	collision_instance.collision_layer = 4; # Terrain layer

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
	
	#Create surface
	var surface_tool: = SurfaceTool.new();
	surface_tool.begin( Mesh.PRIMITIVE_POINTS );
	surface_tool.set_smooth_group( -1 );
	
	#Add vertices
	for iter: Vector3i in Rect3iIterator.new( Vector3i.ZERO, ( this_heightmap.get_size() - Vector3i( 1, 0, 1 ) ) * resolution ):
		var pos: = Vector3( iter ) / resolution * terrain_scale;
		if is_height_accessible( Vector2( pos.x, pos.z ) ):
			pos.y = get_height( this_heightmap, Vector2( pos.x, pos.z ) );
			surface_tool.add_vertex( pos * scale );
	
	surface_tool.index();
	return surface_tool.commit();

## Create objects for this chunk based on a list of objects and vectors
func create_objects( objects: Dictionary[ ChunkObject, Vector2 ] ) -> void:
	
	for object: ChunkObject in objects.keys():
		var object_pos: = objects[ object ];
		var object_node: Node3D = object.scene.instantiate();
		add_child( object_node );
		object_node.position = Vector3( object_pos.x, object.height_offset, object_pos.y );
		if object.height_mode == ChunkObject.HeightMode.SNAP:
			object_node.position.y += get_height( heightmap_terrain, Vector2( object_pos.x, object_pos.y ) );



func _init( definition: ChunkDefinition ) -> void:
	terrain_size = definition.terrain_size;
	terrain_scale = definition.terrain_scale;

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



## Find vertical position using a heightmap at a horizontal position
func get_height( heightmap: Array3D, coordinates: Vector2 ) -> float:
	coordinates /= Vector2( terrain_scale.x, terrain_scale.z );
	var integer: Vector2i = coordinates.floor();
	var fractional: = coordinates.posmod( 1.0 );
	return lerp( 
		lerp( 
			heightmap.get_at( Vector3i( integer.x, 0, integer.y ) ),
			heightmap.get_at( Vector3i( integer.x + 1, 0, integer.y ) ),
			fractional.x
		),
		lerp( 
			heightmap.get_at( Vector3i( integer.x, 0, integer.y + 1 ) ),
			heightmap.get_at( Vector3i( integer.x + 1, 0, integer.y + 1 ) ),
			fractional.x
		),
		fractional.y
	);

## Check if position at accessible height is occluded by terrain
func is_height_accessible( coordinates: Vector2 ) -> bool:
	return get_height( heightmap_accessibility, coordinates ) >= 0;
