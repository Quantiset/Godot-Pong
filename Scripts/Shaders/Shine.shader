shader_type canvas_item;

uniform float shine_length = 0.2;
uniform float offset = 0.5;
uniform float strength = 1.5;

uniform bool show_texture = true;

void fragment() {
	vec2 uv = UV;
	vec4 col = texture(TEXTURE, UV);
	float mask = float(show_texture);
	
	if (uv.x + uv.y > offset - shine_length && uv.x + uv.y < offset + shine_length) {
		mask = strength;
	}
	
	if (!show_texture) {col = vec4(1.)}
	
	COLOR = col * mask;
	
}