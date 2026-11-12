extends Area3D

func _on_body_entered( body: Node3D ) -> void:
	if body is Boid:
		Global.end_level();

func _ready() -> void:
	var chunk = Chunk.get_chunk_containing_global_position( global_position );
	if chunk:
		var size = chunk.get_global_size();
		%Mesh.mesh.size = Vector2( size.x, size.y );
		%Mesh.mesh.center_offset = size * Vector3( 0.5, 0.5, 0 );
