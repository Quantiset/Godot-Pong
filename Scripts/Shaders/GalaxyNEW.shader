shader_type canvas_item;

uniform sampler2D NOISE_PATTERN;
uniform vec3 COLOR_;

void fragment() {
	float noise_value = texture(NOISE_PATTERN, UV).x;
	COLOR = vec4(COLOR_,clamp(noise_value-0.5-sin(TIME/10.0)*0.05,0.0,0.5)*2.0);
}