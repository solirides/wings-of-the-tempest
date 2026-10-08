extends Resource
class_name ChunkTerrainObject

@export var size: Vector3i;

var data: PackedByteArray;
@export_multiline( "monospace" ) var entry: String:
	set( value ):
		entry = value;
		data.clear();
		for chara in entry:
			if not chara in [ " ", "\n" ]:
				data.append( chara == "1" );



## Determine if voxel is in object
@warning_ignore( "unused_parameter" )
func is_in_bounds( position: Vector3i ) -> bool:
	return false;

## Get voxel data from object 
@warning_ignore( "unused_parameter" )
func transform_voxel( position: Vector3i, value: float ) -> float:
	return false;
