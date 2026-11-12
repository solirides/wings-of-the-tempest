shader_type spatial;

uniform vec2 checker_size;
uniform vec2 scroll_speed;
uniform vec4 checker_color_a: source_color;
uniform vec4 checker_color_b: source_color;

void fragment() {
	
	vec3 world_vertex = ( INV_VIEW_MATRIX * vec4( VERTEX, 1.0 ) ).xyz;
	vec2 sample_pos = world_vertex.xy + scroll_speed * TIME;
	
	vec2 checker_pos = floor( sample_pos / checker_size );
	int checker_index = int( checker_pos.x + checker_pos.y ) % 2;
	vec4 color = { checker_color_a, checker_color_b }[ checker_index ];
	
	float alpha_falloff = 1.0 - 2.0 * abs( UV.x - 0.5 );
	
	ALBEDO = color.rgb;
	ALPHA = color.a * alpha_falloff;
}

void light() {
	
	DIFFUSE_LIGHT = vec3( 1.0 );
}
