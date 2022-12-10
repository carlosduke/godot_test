shader_type canvas_item;

const float PI = 3.14159265359;

float ploot(vec2 pos, float line) {
	return smoothstep(line - 0.2, line, pos.y) - smoothstep(line, line+0.2, pos.y);
}

mat2 rotate(float angle){
	return mat2(
		vec2(cos(angle), -sin(angle)),
		vec2(sin(angle), cos(angle))
	);
}

float box(vec2 pos, vec2 size) {
	vec2 shape = vec2(
		step(size.x, pos.x),
		step(size.y, pos.y)
	);
	
	shape *= vec2(
		step(size.x, 1.0-pos.x),
		step(size.y, 1.0-pos.y)
	);
	return shape.x * shape.y;
}

float circle(vec2 pos, float angle) {
	return step(angle, length(pos - vec2(0.5)));
}

void fragment() {
	//vec2 u_resolution = 1.0/SCREEN_PIXEL_SIZE;
	//vec2 st = FRAGCOORD.xy/u_resolution;
	vec2 st = UV;
	
	vec3 color = vec3(0.0);
	
	vec2 translate = vec2(0.0);
	st += translate * 0.5;	
	
	//color.r += box(st, vec2(0.3,0.3));
	//color.r += circle(st, 0.5);
	color = vec3(st.x);
	
	
	COLOR = vec4(UV, 0.5, 0.1);
}