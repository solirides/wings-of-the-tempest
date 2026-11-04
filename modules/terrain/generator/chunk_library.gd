@tool
extends ChunkDecTreeSingle
class_name ChunkLibrary

const SYNCHRONIZED_PROPERTIES: PackedStringArray = [ 
	"terrain_size", 
	"terrain_scale", 
	"terrain_decorator_height", 
	"terrain_accessible_height" 
];

@export var terrain_material: Material;
@export var terrain_sampler: ChunkTerrainSampler;

@export_group( "Chunk Properties" )
@export var terrain_size: Vector3i;
@export var terrain_scale: Vector3;
@export var terrain_decorator_height: int;
@export var terrain_accessible_height: int;

## Get actual size of terrain area
func get_chunk_global_size() -> Vector3:
	return Vector3( terrain_size ) * terrain_scale;

func pick( state: ChunkGenState ) -> ChunkDefinition:
	return child.pick( state );

func _chunk_definition_added( leaf: ChunkDecTreeLeaf ) -> void:

	# Ensure that only definitions with matching Synchronized Properties are added to library
	if leaf.chunk:
		for property in SYNCHRONIZED_PROPERTIES:
			if leaf.chunk.get( property ) != get( property ):
				push_error( "Attempted to insert Chunk Definition with ", property, " of ", leaf.chunk.get( property ), " into Chunk Library with ", property, " of ", get( property ) );
				leaf.chunk = null;
