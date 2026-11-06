extends Control

var object_data: ChunkObjectData;

signal object_modified;
signal object_deleted( object_data: ChunkObjectData );

@warning_ignore("shadowed_variable")
func create( object_data: ChunkObjectData ) -> void:
	self.object_data = object_data;
	%Name.text = object_data.object.name;
	%SpawnChanceInput.value = object_data.spawn_chance;
	%PosXInput.text = str( object_data.position.x );
	%PosYInput.text = str( object_data.position.y );

func _deleted() -> void:
	object_deleted.emit( object_data );
	object_modified.emit();
	visible = false;



func _pos_x_submitted( new_text: String ) -> void:
	if new_text.is_valid_float():
		object_data.position.x = new_text.to_float();
		object_modified.emit();

func _pos_y_submitted( new_text: String ) -> void:
	if new_text.is_valid_float():
		object_data.position.y = new_text.to_float();
		object_modified.emit();

func _pos_x_changed( new_text: String ) -> void:
	if new_text.is_valid_float():
		%PosXInput.remove_theme_color_override( "font_color" );
	else:
		%PosXInput.add_theme_color_override( "font_color", Color.PALE_VIOLET_RED );

func _pos_y_changed( new_text: String ) -> void:
	if new_text.is_valid_float():
		%PosYInput.remove_theme_color_override( "font_color" );
	else:
		%PosYInput.add_theme_color_override( "font_color", Color.PALE_VIOLET_RED );



func _spawn_chance_changed( value: float ) -> void:
	%SpawnChanceLabel.text = "Spawn Chance: %d%%" % ( 100 * value );

func _spawn_chance_submitted( value: bool ) -> void:
	object_data.spawn_chance = value;
	object_modified.emit();
