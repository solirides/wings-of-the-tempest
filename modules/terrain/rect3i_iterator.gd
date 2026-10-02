class_name Rect3iIterator

var start_pos: Vector3i;
var end_pos: Vector3i;

func _init( start: Vector3i, size: Vector3i ) -> void:
	start_pos = start;
	end_pos = start + size;

func _continue( current_pos ) -> bool:
	return current_pos.z < end_pos.z;

func _iter_init( iter ) -> bool:
	iter[0] = start_pos;
	return _continue( iter[0] );

func _iter_next( iter ) -> bool:
	iter[0].x += 1;
	if iter[0].x >= end_pos.x:
		iter[0].x = start_pos.x;
		iter[0].y += 1;
	if iter[0].y >= end_pos.y:
		iter[0].y = start_pos.y;
		iter[0].z += 1;
	return _continue( iter[0] );

func _iter_get( iter ) -> Vector3i:
	return iter;
