@tool
extends ChunkDecTreeSingle
class_name ChunkLibrary

const SYNCHRONIZED_PROPERTIES: PackedStringArray = [ "size", "terrain_height" ];

@export var terrain_material: Material;

@export_group( "Chunk Properties" )
@export var size: Vector3i;
@export var terrain_height: int;

func _chunk_definition_added( leaf: ChunkDecTreeLeaf ) -> void:

	# Ensure that only definitions with matching Synchronized Properties are added to library
	if leaf.chunk:
		for property in SYNCHRONIZED_PROPERTIES:
			if leaf.chunk.get( property ) != get( property ):
				push_error( "Attempted to insert Chunk Definition with ", property, " of ", leaf.chunk.get( property ), " into Chunk Library with ", property, " of ", get( property ) );
				leaf.chunk = null;

func pick( state: ChunkGenState ) -> ChunkDefinition:
	return child.pick( state );
