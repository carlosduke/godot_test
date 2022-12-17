#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

float box (vec2 pos, vec2 size) {
    size -= size*.5;
    return 
        step(-size.x, pos.x) * step(pos.x, size.x)
        * step(-size.y, pos.y) * step(pos.y, size.y)
        ;
}

float cross (vec2 pos, vec2 size){
    vec2 v = size;
    v.x *= .05;

    vec2 h = size;
    h.y *= .05;
    return box(pos,v) + box(pos, h);
}

float circle(vec2 pos, float radius) {
    return length(pos) * radius;
}

void main(){
    vec2 uv = gl_FragCoord.xy/u_resolution;
    vec3 color = vec3(0.0);

    vec2 uvq = 2.0 * fract(uv*2.)-1.0;


    vec2 b = vec2(.3, .3);

    vec2 translate = vec2(.0);//vec2(sin(u_time), cos(u_time));
    //translate = vec2(.0);
    translate = translate*.5;

    uvq += translate;
    color = vec3(
        cross(uvq, b)
        * 1.-step(.50, length(uvq))
        + circle(uvq, .5)
    );
    //color += step(.2, length(uvq));
    gl_FragColor = vec4(color, 1.0);
}