extends Node3D
class_name Chunk

var mesh_instance: MeshInstance3D;

## Create terrain for this chunk based on a 3D grid of scalar voxel data
func create_terrain( scalar_field: Array3D ) -> void:
	mesh_instance.mesh = MarchingCube.generate_mesh( MarchingCube.generate_vertices( scalar_field, -10.0 ) );



func _ready() -> void:
	
	#Create mesh node
	mesh_instance = MeshInstance3D.new();
	add_child( mesh_instance, false, Node.INTERNAL_MODE_FRONT );
	
	#TEST
	var noise: = FastNoiseLite.new();
	var test_field: = Array3D.packedFloat32( Vector3i.ONE * 16 );
	for pos in Rect3iIterator.new( Vector3i.ZERO, test_field.get_size() ):
		test_field.set_at( pos, 4.0 * noise.get_noise_2d( 10 * pos.x, 10 * pos.z ) - pos.y );
	create_terrain( test_field );
