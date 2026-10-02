shader_type spatial;

varying vec3 world_pos;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;

uniform vec4 color:source_color = vec4(0.048,0.191,0.379,1);
uniform float roughness = 0.1;
uniform float metallic = 1.0;
uniform sampler2D normal_map;
uniform sampler2D foam_texture;

uniform float timescale = 0.6;
uniform vec2 speed = vec2(0.1,0.1);
uniform float alpha:hint_range(0.0, 1.0, 0.01) = 0.6;

uniform float depth_scale = 40;
// width of foam gradient
uniform float foam_width = 0.5;
// width of additional solid foam at the water boundry
uniform float foam_bias = 0.5;
uniform vec3 foam_color : source_color = vec3(1.0);

// waves
// x and y = direction (will be normalized)
// z = steepness
// w = wavelength
uniform vec4 wave_a = vec4(1.0, 0.0, 0.25, 8);
uniform vec4 wave_b = vec4(1.0, 1.0, 0.15, 4.0);
uniform vec4 wave_c = vec4(0.0, 1.0, 0.1, 1.4);

vec3 calculate_gerstner(vec3 pos, float time, vec4 wave) {
	vec2 direction = normalize(wave.xy);
	float steepness = wave.z;
	float wavelength = wave.w;
	
	// k = wave number
	float k = 2.0*PI/wavelength;
	// c = phase speed
	float c = sqrt(9.8 / k);
	// f = phase
	float f = k*(dot(direction, pos.xz) - c*time);
	
	float a = steepness / k;
	
	return vec3(
		direction.x * a * cos(f),
		a * sin(f), 
		direction.y * a * cos(f)
	);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	float time = TIME * timescale;
	vec3 grid_pos = VERTEX;
	vec3 wave_offset = vec3(0.0);
	
	// Add displacement from each wave
	wave_offset += calculate_gerstner(grid_pos, time, wave_a);
	wave_offset += calculate_gerstner(grid_pos, time, wave_b);
	wave_offset += calculate_gerstner(grid_pos, time, wave_c);
	
	VERTEX += wave_offset;
	//POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float edge(float near, float far, float depth) {
	depth = 1.0 - 2.0 * depth;
	return near * far / (far + depth * (near - far));
}

void fragment() {
	vec2 uv = vec2(UV.x + TIME*speed.x, UV.y + TIME*speed.y);
	
	// get the depth of the object behind the water
	float depth = texture(depth_texture, SCREEN_UV).r;
	float linear_depth = 1.0 / (depth * INV_PROJECTION_MATRIX[2].w + INV_PROJECTION_MATRIX[3].w);
	
	// -VERTEX.z is the distance from camera
	float water_depth = -VERTEX.z;
	
	float depth_diff = linear_depth - water_depth;
	
	// depth_diff = 0, max foam
	// depth_diff >= foam_width, no foam
	// don't set foam_width to zero (or else...)
	float random_foam = 2.0 * texture(foam_texture, world_pos.xy).x;
	//float random_foam = 0.3 * sin(12.0*world_pos.x + TIME*4.0);
	//float random_foam = 10.0 * calculate_gerstner(world_pos, TIME, vec4(1,0,1,1)).x;
	float foam_linear_factor = clamp(1.0 - (depth_diff / foam_width) + foam_bias, 0.0, 1.0);
	float foam_mix_factor = clamp(1.0 * foam_linear_factor, 0, 1);
	//foam_factor *= texture(foam_texture, UV).x;
	
	vec3 water_color = vec3(linear_depth / depth_scale);
	ALBEDO = mix(water_color, foam_color, foam_mix_factor);
	
	vec4 normal = texture(normal_map, uv);
	NORMAL_MAP = normal.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	
	// transparency based on viewing angle
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	ALPHA = mix(alpha, 1.0, fresnel);
}
