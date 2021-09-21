shader_type canvas_item;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	color.a = length(uv)/5.0;
	COLOR = color;
}