extends Resource
class_name ChunkObject

enum HeightMode {
	FIXED,
	SNAP,
	ACCESSIBLE,
}

@export var name: String;
@export var scene: PackedScene;
@export var height_mode: HeightMode;
@export var height_offset: float;
