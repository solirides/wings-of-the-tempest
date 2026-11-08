@tool
extends HBoxContainer
class_name FloatListInput

@export var element_count: int:
	set( value ):
		element_count = value;
		_element_count_updated();

@export_enum( "float:3", "int:2" ) var input_type: int;

signal input_changed( value: String, index: int );
signal input_submitted( value: String, index: int );
signal valid_input_submitted( value: float, index: int );

func is_valid_input( input: String ) -> bool:
	
	match input_type:
		
		TYPE_FLOAT:
			return input.is_valid_float();
		
		TYPE_INT:
			return input.is_valid_float();
	
	return true;

func set_input( new_input: Array ) -> void:
	
	for i in new_input.size():
		get_child( i ).text = str( new_input[ i ] );

func _element_count_updated() -> void:
	
	for child in get_children():
		child.queue_free();
	
	for i in element_count:
		var input: = LineEdit.new();
		input.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
		input.size_flags_vertical = Control.SIZE_EXPAND_FILL;
		input.text_changed.connect( _input_changed.bind( i ) );
		input.text_submitted.connect( _input_submitted.bind( i ) );
		add_child( input );

func _input_changed( value: String, index: int ) -> void:
	
	input_changed.emit( value, index );
	
	if is_valid_input( value ):
		get_child( index ).remove_theme_color_override( "font_color" );
	else:
		get_child( index ).add_theme_color_override( "font_color", Color.PALE_VIOLET_RED );

func _input_submitted( value: String, index: int ) -> void:
	
	input_submitted.emit( value, index );
	
	if is_valid_input( value ):
		valid_input_submitted.emit( value.to_float(), index );
