shader_type canvas_item;

void fragment() {
	
	vec2 uv = UV;
	
	uv.y = uv.y + sin(uv.y*0.2)+sin(TIME*1.5)/300.0;
	
	vec4 col = texture(TEXTURE, uv);
	
	COLOR = col;
}