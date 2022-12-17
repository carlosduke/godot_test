#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform sampler2D tex0;

void main(){
    vec2 coord = gl_FragCoord.xy/u_resolution;
    vec4 texture = texture2D(tex0, coord);
    
    vec2 uv = (gl_FragCoord.xy-.5*u_resolution)/u_resolution.y;
    vec2 uvm = (u_mouse / u_resolution);
    uvm = -1. * uvm +.5 ;
    vec3 color = texture.rgb;

    texture.a = .0;

    //Ponto de luz...
    texture.a += smoothstep(.1,.05, length(uv - vec2(.4)));
    texture.a += smoothstep(.1,.05, length(uv - vec2(-.4)));
    texture.a += smoothstep(.1,.05, length(uv - vec2(.3, -.2)));
    texture.a += smoothstep(.1,.05, length(uv - vec2(0.)));
    texture.a += smoothstep(.1,.05, length(uv - vec2(-.3, .2)));
    
    //mouse
    texture.a += smoothstep(.2,.05, length(uv + uvm));
    gl_FragColor = texture;
}