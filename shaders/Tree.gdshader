shader_type canvas_item;
uniform vec2 mouse_position;

const float PI = 3.14159265359;

float ploot(vec2 st, float pct){
	return smoothstep(pct-0.02, pct, st.y) - smoothstep(pct, pct+0.02, st.y);
}

float draw(vec2 st) {
	//quad1
	float draw = (1.0 - step(0.05, st.x)) - (1.0 - step(0.85, st.y));
	
	//quad2
	draw += step(0.07, st.x) - step(0.15, st.x);
	
	//quad3
	draw += (1.0 - step(0.83, st.y)) - (1.0-step(0.7, st.y));
	return draw;
}

float circle(vec2 _st, float radius){
	vec2 dist = _st-vec2(0.5);
	return 1.0 - smoothstep(
		radius-(radius*0.01),
		radius + (radius*0.01),
		dot(dist, dist)*10.0
	);
}

float box(vec2 st, vec2 size) {
	size = vec2(0.5) - size*0.5;
	vec2 uv = smoothstep(size, size + vec2(0.01), st);
	uv *= smoothstep(size, size+vec2(0.01), vec2(1.0)-st);
	return uv.x*uv.y;
}

float crosx(vec2 st, float size) {
	return box(st, vec2(size, size/4.0)) + box(st, vec2(size/4.0, size));
}

void fragment() {
	vec2 u_resolution = 1.0/SCREEN_PIXEL_SIZE;
	vec2 st = 6.0 * FRAGCOORD.xy/u_resolution;
	
	vec3 color = vec3(0.0);
	
	for (int i = 1; i <= 8; i++){
		float v = float(i);
		st += vec2(
			0.7 / v * sin(st.y + TIME + 0.3) + 0.8,
			0.3 / v * cos(st.x + TIME + 0.3) + 0.16
		);
	}
	
	
	color = vec3(
		0.5 * sin(st.x) + 0.5,
		0.5 * sin(st.y) + 0.5,
		sin(st.x + st.y)
	);
	
	
	COLOR = vec4(color, 1.0);
}