shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D gradient;
uniform bool use_gradient = true;
uniform int steps = 8;
uniform float gamma = 1.5;

float luminance(vec3 color) {
	return 0.2126*color.r + 0.7152*color.g + 0.0722*color.b;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	float lum = luminance(screen_color);
	vec3 posterized = screen_color;
	if (use_gradient) {
		posterized = texture(gradient, vec2(lum) ).rgb;
	}
	else {
		float scaled_lum = pow(lum, gamma);
		float new_lum = floor(float(steps)*scaled_lum) / float(steps);
		posterized = new_lum/lum * screen_color;
	}
	COLOR = vec4(posterized, 1.0);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
