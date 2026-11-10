extends Control

var object_data: ChunkObjectData;

signal object_modified( object_data: ChunkObjectData );
signal object_deleted( object_data: ChunkObjectData );

@warning_ignore("shadowed_variable")
func create( object_data: ChunkObjectData ) -> void:
	self.object_data = object_data;
	%Name.text = object_data.object.name;
	%SpawnChanceInput.value = object_data.spawn_chance;
	%PositionInput.set_input( [ object_data.position[0], object_data.position[1] ] );

func _deleted() -> void:
	object_deleted.emit( object_data );
	object_modified.emit();
	visible = false;



func _position_submitted( value: float, index: int ) -> void:
	object_data.position[ index ] = value;
	object_modified.emit( object_data );

func _spawn_chance_changed( value: float ) -> void:
	%SpawnChanceLabel.text = "Spawn Chance: %d%%" % ( 100 * value );

func _spawn_chance_submitted( value: float ) -> void:
	object_data.spawn_chance = value;
