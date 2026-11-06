extends Resource
class_name ChunkObjectData

@export var object: ChunkObject;
@export var position: Vector2;
@export_range( 0, 1 ) var spawn_chance: float = 1;
