shader_type canvas_item;

uniform float strength= 1.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	vec4 col = texture(TEXTURE, UV);
	
	COLOR = col*strength/length(uv);
}