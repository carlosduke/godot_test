#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float ploot(vec2 st, float pct){
    return smoothstep(pct - 0.02, pct, st.y) - 
    smoothstep(pct, pct+0.02, st.y);
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    vec3 color = vec3(0.0);

    // float x = step(0.5, st.x);
    float x = smoothstep(0.1, 0.9, st.x);
    // float pct = ploot(st, pow(st.x, 2.0));
    float pct = ploot(st, x);
    color = vec3(x);

    color = (1.0-pct)*color + pct*vec3(1.0,0.0,0.0);
    
    
    gl_FragColor = vec4(color, 1.0);
}