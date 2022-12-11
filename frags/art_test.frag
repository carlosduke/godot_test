#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float Xor(float a, float b) {
    return a*(1.0-b)+b*(1.0-a);
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / u_resolution.y;//min(u_resolution.y, u_resolution.x);
    //vec2 uv = gl_FragCoord.xy / u_resolution;
    //0.5 * u_resolution ex. original 800x600, novo: 400x300
    //gl_FragCoord.xy - res/2: antes 0x0 ate 800x600, novo: -400x-300 ate 400x300
    //nova pos;u_resolution.y: normalizar -1 ate 1

    float t_rotate = u_time * .05;
    float a = atan(sin(t_rotate), cos(t_rotate));
    float s = sin(a);
    float c = cos(a);
    uv *= mat2(c, -s, s, c);
    float parts = 10.0;//sin(u_time) * 100.0;
    vec2 mult_size = uv*parts;

    vec2 gv = fract(mult_size)-.5;
    vec2 id = floor(mult_size); //Identifica cada quadra como id unico.

    //frac(uv*5.0): Divide a tela em 5x5 em blocos 0 ate 1
    //frac-.5: centraliza

    vec3 color = vec3(0.0);

    //Circle
    float d = length(gv);
    //Com coordenadas normalizadas -1 ate 1 d diminui ate chegar ao centro que é 0.
    
    //float m = d;//smoothstep(0.5, 0.0, d);
    float m = smoothstep(.4, 0.2, d);
    // 0.4 inicio de smoothstep, posicao mais afastada do centro
    // 0.2 fim do smoothstep, posicao mais proxima do centro

    
    float t = u_time * 2.0;
    float dist = length(id);
    //dist = id.x * id.y;
    float diff_c = dist * 30.0;
    //Centro da tela

    m = 0.0;
    for(float y = -1.0; y <= 1.0; y++) {
        for(float x = -1.0; x <= 1.0; x++) {
            vec2 offset = vec2(x,y);

            d = length(gv - offset);
            //Trata o conjunto de pixel como uma grade x por x
            //calcula a posição em um bloco de 3x3 apartir do quadrado base.

            dist = length(id + offset);
            diff_c = dist * 0.3;

            //float r = mix(.3, 1.5, sin(t + diff_c)*.5 + .5);
            float r = mix(.3, 1.5, sin(diff_c-t)*.5 + .5);
            //ainda não entendi bem como funciona o mix
            // coloca os limites para imagem entre 0.3 e 0.5, anima com o tempo (sin utime) e normaliza para o centro *.5 + .5

            //sin(t + c_screen * 3.0): anima em tempos diferentes do centro para as bordas.



            //m += smoothstep(r, r*.9, d)*.3;
            //m += smoothstep(r, r*.5, d);
            m = Xor(m, smoothstep(r, r*.9, d));
            //Quantos circulos estão se sobrepondo.
        }
    }


    //color.rg = gv;
    color += m;//mod(m, 2.);
    gl_FragColor = vec4(color, 1.0);
}