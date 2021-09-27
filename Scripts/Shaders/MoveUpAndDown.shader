shader_type canvas_item;

void fragment() {
	
	vec2 uv = UV;
	
	uv.y += sin(TIME*1.5)/300.0;
	
	vec4 col = texture(TEXTURE, uv);
	
	COLOR = col;
}