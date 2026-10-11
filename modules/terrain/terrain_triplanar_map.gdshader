shader_type spatial;

uniform sampler2D tex;

uniform vec4 tex_region = vec4( 0.0, 0.0, 1.0, 1.0 );
uniform vec2 tex_scale  = vec2( 1.0, 1.0 );

vec2 fit_to_texture( vec2 position ) {
	
	return mod( position / tex_scale, tex_region.zw ) + tex_region.xy;
}

void fragment() {
	
	vec3 world_vertex = ( INV_VIEW_MATRIX * vec4( VERTEX, 1.0 ) ).xyz;
	vec3 world_normal = ( INV_VIEW_MATRIX * vec4( NORMAL, 0.0 ) ).xyz;
	
	vec2 UVx = fit_to_texture( world_vertex.yz );
	vec2 UVy = fit_to_texture( world_vertex.xz );
	vec2 UVz = fit_to_texture( world_vertex.xy );
	
	vec3 ALBEDOx = texture( tex, UVx ).xyz;
	vec3 ALBEDOy = texture( tex, UVy ).xyz;
	vec3 ALBEDOz = texture( tex, UVz ).xyz;
	/*
	vec3 ALBEDOx = vec3( 1.0, 0.0, 0.0 );
	vec3 ALBEDOy = vec3( 0.0, 1.0, 0.0 );
	vec3 ALBEDOz = vec3( 0.0, 0.0, 1.0 );
	*/
	ALBEDO = 
		ALBEDOx * world_normal.x * world_normal.x + 
		ALBEDOy * world_normal.y * world_normal.y + 
		ALBEDOz * world_normal.z * world_normal.z;
}