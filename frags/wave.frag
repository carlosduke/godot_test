#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

const float PI = 3.14;

float poligon(vec2 pos, float radius, float sides){
    pos = pos * 2.0 - 1.0;
    float angle = atan(pos.x, pos.y);
    float slice = PI*2.0 / sides;
    return step(radius, cos(floor(0.5 + angle / slice) * slice - angle) * length(pos));
}

float circle(vec2 pos, float radius) {
    return step(radius, length(pos - vec2(0.5)));
}

vec2 translate_mouse(vec2 pos){
    vec2 coordM = u_mouse / u_resolution;

    vec2 trans = vec2(0.0);
    trans = coordM*-2.0+1.0;
    pos += trans*0.5;
    return pos;
}

mat2 scale(vec2 scale) {
    return mat2(scale.x, 0.0, 0.0, scale.y);
}

mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

vec3 forms(vec2 pos){
    vec2 translation = vec2(0.0,  0.0);

    //translation = vec2(sin(u_time), cos(u_time));
    pos += translation*0.5;
    //coordM += translation * 0.5;
    
    //coordM += translation * 0.5;

    vec3 color = vec3(0.0);
    color.r += 1.0-circle(pos, 0.1);
    color.b += 1.0 - poligon(pos, 0.5, 6.0);
    //color.b = 1.0-circle(coordM, 0.1); 
    return color;
}

vec3 followMouse(vec2 coord) {
    vec2 trans = vec2(0.0);
    trans = vec2(sin(u_time)*0.3, cos(u_time)*0.3);
    coord += trans * -0.5;
    coord = translate_mouse(coord);
    vec3 color = vec3(0.0);
    color.r = 1.0-circle(coord, 0.05);
    return color;
}

vec3 scaleCircle(vec2 coord) {
    vec2 translation = vec2(0.0);
    coord += translation * 0.5;

    coord -= vec2(0.5);
    coord = scale(vec2(sin(u_time * .05))) * coord;
    coord += vec2(0.5);

    vec3 color = vec3(0.0);
    color.r = 1.0-circle(coord, 0.05);

    return color;
}

vec3 rotatePoligon(vec2 coord) {
    vec2 translation = vec2(-sin(u_time) * 0.3, cos(u_time) * 0.3);
    coord += translation * 0.5;

    coord = translate_mouse(coord);

    coord -= vec2(0.5);
    coord = rotate(-atan(sin(u_time), cos(u_time))) * coord;
    coord += vec2(0.5);

    vec3 color = vec3(0.0);
    color.r = 1.0-poligon(coord, 0.05, 6.0);

    return color;
}

void main(){
    //vec2 coord = gl_FragCoord.xy/u_resolution;
    vec2 coord = gl_FragCoord.xy / u_resolution;
    vec3 color = vec3(0.0);
   
    //color = rotatePoligon(coord);
    color += sin(coord.x * 50.0 + cos(u_time + coord.y*20.0)) * 2.0;
    gl_FragColor = vec4(color, 1.0);
}