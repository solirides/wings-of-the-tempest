extends Node3D

@export var radius: float = 10;
@export var density: float = 3;
@export var offset: float = 3;

func add_tree( pos: Vector3 ) -> void:
	
	var chunk = Chunk.get_chunk_containing_global_position( pos );
	if not chunk:
		return;
	
	pos.y = chunk.get_height_global( chunk.heightmap_terrain, Vector2( pos.x, pos.z ) );
	print( pos );
	
	var new_tree: Node3D = %Sample.get_children().pick_random().duplicate();
	add_child( new_tree );
	new_tree.rotate_y( randf() * 2 * PI );
	new_tree.global_position = pos;

func _ready() -> void:
	
	%EditorSprite.visible = ChunkEditor.is_open;
	
	for xIdx in radius / density * 2: for yIdx in radius / density * 2:
		
		var x = xIdx * density - radius + fmod( radius, density );
		var y = yIdx * density - radius + fmod( radius, density );
		
		var tree_pos = global_position + Vector3( x, 0, y );
		
		if tree_pos.distance_squared_to( global_position ) <= radius * radius:
			add_tree( tree_pos + Vector3( randf() - 0.5, 0, randf() - 0.5 ) * offset );
