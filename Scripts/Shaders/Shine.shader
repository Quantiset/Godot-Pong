shader_type canvas_item;

uniform float shine_length = 0.2;
uniform float offset = 0.5;
uniform float strength = 1.5;

void fragment() {
	vec2 uv = UV;
	vec4 col = texture(TEXTURE, UV);
	float mask = 1.0;
	
	if (uv.x + uv.y > offset - shine_length && uv.x + uv.y < offset + shine_length) {
		mask = strength;
	}
	
	COLOR = col * mask;
	
}