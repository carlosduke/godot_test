#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

void main(){
    vec2 coord = 6.0 * gl_FragCoord.xy/u_resolution;
    vec3 color = vec3(0.0);

    for(int i = 1; i <= 8; i++){
        float v = float(i);
        coord += vec2(
            0.7 / v * sin(coord.y + u_time + 0.3) + 0.8,
            0.4 / v * sin(coord.x + u_time + 0.3) + 1.6
        );
    }
    

    color = vec3(
        0.5 * sin(coord.x) + 0.5,
        0.5 * sin(coord.y) + 0.5,
        sin(coord.x + coord.y)
    );
    gl_FragColor = vec4(color, 1.0);
}