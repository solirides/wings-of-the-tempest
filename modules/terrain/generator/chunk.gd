extends Node3D
class_name Chunk

var mesh_instance: MeshInstance3D;

## Set material used by the chunk's terrain mesh
func set_terrain_material( material: Material ) -> void:
	mesh_instance.material_override = material;

## Create terrain for this chunk based on a 3D grid of scalar voxel data
func create_terrain( scalar_field: Array3D ) -> void:
	mesh_instance.mesh = MarchingCube.generate_mesh( MarchingCube.generate_vertices( scalar_field, 0.0 ) );

## Creates a quick and dirty plane with a random heightmap
func test_generation( noise: Noise ) -> void:
	
	var test_field: = Array3D.packedFloat32( Vector3i.ONE * 17 );
	
	for pos in Rect3iIterator.new( position, test_field.get_size() ):
		test_field.set_at( Vector3( pos ) - position, 4.0 * noise.get_noise_2d( 10 * pos.x, 10 * pos.z ) - pos.y + 10 );
	#	test_field.set_at( pos, noise.get_noise_3d( 10 * pos.x, 10 * pos.z, 10 * pos.y ) );
	
	create_terrain( test_field );



func _ready() -> void:
	
	#Create mesh node
	mesh_instance = MeshInstance3D.new();
	add_child( mesh_instance, false, Node.INTERNAL_MODE_FRONT );
