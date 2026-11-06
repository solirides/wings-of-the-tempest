extends Control

@export_dir() var default_directory: String;
@export var type: String;

signal chosen( file: String );

func _text_input_toggled( toggled_on: bool ) -> void:
	%ScrollContainer.set_deferred( "visible", toggled_on );
	if toggled_on:
		create_suggestion_buttons( get_suggestions( "" ) );

func _text_input_changed( new_text: String ) -> void:
	
	var valid: = verify_file_type( new_text );
	chosen.emit( new_text if valid else "" );
	
	create_suggestion_buttons( get_suggestions( new_text ) );
	
	if valid:
		%TextInput.remove_theme_color_override( "font_color" );
	
	else:
		%TextInput.add_theme_color_override( "font_color", Color.PALE_VIOLET_RED );

func get_input() -> String:
	return %TextInput.text;

func set_input( text: String ) -> void:
	%TextInput.text = text;

func is_input_valid() -> bool:
	return verify_file_type( get_input() );



func verify_file_type( file_path: String ) -> bool:
	
	if ( not file_path.ends_with( ".tres" ) ) and ( not file_path.ends_with( ".tscn" ) ):
		return false;
	
	if not FileAccess.file_exists( file_path ):
		return false;
	
	var loaded_file = load( file_path );
	
	if loaded_file.get_script() == null:
		return loaded_file.is_class( type );
	
	return loaded_file.get_script().get_global_name() == type;

func compose_file_path( file_path: String, directory_path: String ) -> String:
	if directory_path.ends_with( "/" ):
		return directory_path + file_path;
	return directory_path + "/" + file_path;

func get_suggestions_from_directory( directory_path: String ) -> Array[ String ]:
	
	if not DirAccess.dir_exists_absolute( directory_path ):
		return [];
	
	var directory_stack: Array[ String ] = [ directory_path ];
	var result: Array[ String ];
	
	while not directory_stack.is_empty():
		
		var current_path: String = directory_stack.pop_back();
		var directory: = DirAccess.open( current_path );
		
		if not directory:
			continue;
		
		directory_stack.append_array(
			Array( directory.get_directories() ) \
				.map( compose_file_path.bind( current_path ) ) 
		);
		
		result.append_array( 
			Array( directory.get_files() ) \
				.map( compose_file_path.bind( current_path ) ) \
				.filter( verify_file_type ) 
		);
	
	return result;

func get_suggestions( current_path: String ) -> Array[ String ]:
	
	var result = get_suggestions_from_directory( current_path );
	for suggestion in get_suggestions_from_directory( default_directory ):
		if not suggestion in result:
			result.push_back( suggestion );
	return result;

func create_suggestion_buttons( suggestions: Array ) -> void:
	
	for child in %SuggestionContainer.get_children():
		child.queue_free();
	
	for suggestion in suggestions:
		var button = Button.new();
		button.text = suggestion;
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS;
		button.pressed.connect( fill_suggestion.bind( suggestion ) );
		%SuggestionContainer.add_child( button );

func fill_suggestion( suggestion: String ) -> void:
	%TextInput.text = suggestion;
	_text_input_changed( suggestion );
	%TextInput.release_focus();
