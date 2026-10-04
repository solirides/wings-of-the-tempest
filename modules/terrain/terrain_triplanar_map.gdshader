shader_type spatial;

render_mode world_vertex_coords;

uniform sampler2D tex;

uniform vec4 tex_region = vec4( 0.0, 0.0, 1.0, 1.0 );
uniform vec2 tex_scale  = vec2( 1.0, 1.0 );

vec2 fit_to_texture( vec2 position ) {
	
	return mod( position / tex_scale, tex_region.zw ) + tex_region.xy;
}

void fragment() {
	
	vec2 UVx = fit_to_texture( VERTEX.yz );
	vec2 UVy = fit_to_texture( VERTEX.xz );
	vec2 UVz = fit_to_texture( VERTEX.xy );
	
	vec3 ALBEDOx = texture( tex, UVx ).xyz;
	vec3 ALBEDOy = texture( tex, UVy ).xyz;
	vec3 ALBEDOz = texture( tex, UVz ).xyz;
	
	ALBEDO = 
		ALBEDOx * NORMAL.x * NORMAL.x + 
		ALBEDOy * NORMAL.y * NORMAL.y + 
		ALBEDOz * NORMAL.z * NORMAL.z;
}