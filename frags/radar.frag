#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

const float PI = 3.14159265359;

float ploot(vec2 pos, float line) {
    float line_size = 0.02;
    return smoothstep(line-line_size, line, pos.y) -
            smoothstep(line, line + line_size, pos.y);
}

float circle(vec2 pos, float radius) {
    return step(radius, length(pos - vec2(0.5)));
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

mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}


void main(){
    vec2 st = gl_FragCoord.xy/u_resolution;

    vec3 color = vec3(0.0);

    st -= vec2(0.5);
    st = rotate(atan(sin(u_time), cos(u_time))) * st;
    st += vec2(0.5);

    vec2 translate = vec2(0.0, 0.0);
    st += translate * 0.5;

    color.r += box(st, vec2(0.4975, 0.0));
    gl_FragColor = vec4(color, 1.0);
}