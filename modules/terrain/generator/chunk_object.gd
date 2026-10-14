extends Resource
class_name ChunkObject

enum HeightMode {
	FIXED,
	SNAP,
}

@export var scene: PackedScene;
@export var height_mode: HeightMode;
@export var height_offset: float;
