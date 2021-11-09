shader_type canvas_item;



uniform vec4 NEBULA_COLOR: hint_color = vec4(0.15, 0.3, 0.5, 0.7);


void fragment() {
	
	//vec2 mask = (vec2(0.5) - UV) ;
	vec3 mask = texture(TEXTURE, UV).rgb / 2.;
	//COLOR = vec4(vec3(length(mask)), 1.);
	
	COLOR = NEBULA_COLOR * length(mask);
	
}