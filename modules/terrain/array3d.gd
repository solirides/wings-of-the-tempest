extends Object
class_name Array3D

var size: Vector3i;
var array: Variant;

@warning_ignore("shadowed_variable")
static func typed( size: Vector3i, base: Array = [], type: int = -1, class_type: String = "", script: Variant = null ) -> Array3D:
	return Array3D.new( size, Array( base, type, class_type, script ) );

@warning_ignore("shadowed_variable")
static func packedInt32( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedInt32Array( base ) );

@warning_ignore("shadowed_variable")
static func packedInt64( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedInt64Array( base ) );

@warning_ignore("shadowed_variable")
static func packedByte( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedByteArray( base ) );

@warning_ignore("shadowed_variable")
static func packedVector2( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedVector2Array( base ) );

@warning_ignore("shadowed_variable")
static func packedVector3( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedVector3Array( base ) );

@warning_ignore("shadowed_variable")
static func packedVector4( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedVector4Array( base ) );

@warning_ignore("shadowed_variable")
static func packedColor( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedColorArray( base ) );

@warning_ignore("shadowed_variable")
static func packedFloat32( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedFloat32Array( base ) );

@warning_ignore("shadowed_variable")
static func packedFloat64( size: Vector3i, base: Variant = [] ) -> Array3D:
	return Array3D.new( size, PackedFloat64Array( base ) );

@warning_ignore("shadowed_variable")
func _init( size: Vector3i, array: Variant ) -> void:
	self.size = size;
	self.array = array;
	self.array.resize( size.x * size.y * size.z );

func get_at( position: Vector3i ) -> Variant:
	return array.get( position.x + position.y * size.x + position.z * size.x * size.y );

func set_at( position: Vector3i, value: Variant ) -> void:
	array.set( position.x + position.y * size.x + position.z * size.x * size.y, value );

func get_size() -> Vector3i:
	return size;
