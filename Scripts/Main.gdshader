shader_type canvas_item;

uniform float strength: float = 1.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	COLOR = col*length(uv)*strength;
}