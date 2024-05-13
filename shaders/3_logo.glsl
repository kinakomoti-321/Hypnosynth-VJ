#version 330

out vec4 color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"
#pragma include "./shaders/common/font.glsl"

uniform sampler2D PlotLogo;

#define BPM 150
#define Beat time * BPM / 60

uniform sampler2D VAT_test;

#define Log_Button buttons[4]
#define Logo_CaosSlider sliders[4]


vec3 getNormal(vec2 uv,float offset,int octaves){
    vec2 eps = vec2(0.001,0.0);
    int dammy = 0;

    vec3 pos = vec3(uv,offset);
    //dx 
    float dxz = cyclicNoise(pos + eps.xyy,octaves) - cyclicNoise(pos - eps.xyy,octaves);
    float dyz = cyclicNoise(pos + eps.yxy,octaves) - cyclicNoise(pos - eps.yxy,octaves);

    vec3 divX = vec3(eps.x * 2.0,0.0,dxz);
    vec3 divY = vec3(0.0,eps.x * 2.0,dyz);

    vec3 t = normalize(cross(divX,divY));
    return t.xzy;
}


void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec3 col = vec3(0);
    vec3 back_ground = vec3(0.0);

    int logo_index = int(LogoSlider * 5.0f);

    //------------
    //Front
    //------------
    float time_counter = floor(time * 2.0);

    float beatTime = floor(time * 10.0 + 1.0);
    float beatTimef = fract(time * 10.0 + 1.0);
    vec2 logouv = tuv * 2.0 - 1.0;
    logouv *= mix(1.0,hash11(time_counter) * 1.0 + 0.45,sliders[3] + 0.1);
    logouv *= 2.0;
    logouv += ((hash21(beatTime) * 2.0 - 1.0) * sliders[3]) * (beatTimef * 0.2 + 0.8);
    logouv = logouv * 0.5 + 0.5 ;
    //なんかいい感じ

    vec4 plogo;
    logouv.y /= 0.7;
    if(logo_index == 0){
        plogo = texture(PlotLogo,logouv);
    }
    else if(logo_index == 1){
        logouv+= offsetCurl((uv) * 5.0,0.5 );
        plogo = texture(PlotLogo,logouv);
    }

    if(logouv.x < 0.0 || logouv.x >= 0.999) plogo = vec4(0.0);

    vec2 uv_text = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;

    int text_index = int(mod(time_counter,4.0));

    if(text_index == 1){
        uv_text.x = abs(uv_text.x) - 1.0;
    }
    else if(text_index == 2){
        uv_text -= 1.0;
        uv_text += hash22(floor(uv_text * 10.0));
    }
    else if(text_index == 3){
        if(gl_FragCoord.x / resolution.x > 0.5)
        {
            uv_text.x = 1.0 - abs(uv_text.x) - 1.0;
            uv_text.y = -uv_text.y;
        }
    }
    else if(text_index == 4){
        uv_text -= 1.0;
        uv_text += hash22(floor(uv_text * 10.0));
    }


    uv_text += 1.0;
    vec2 uv1 = (uv_text) * 40.0;
    
    float log_time = time * 10.0;
    uv1.y -= floor(log_time) * 1.2;

    ivec2 index = ivec2(uv1 / vec2(0.8,1.2));
    uv1.x = mod(uv1.x,0.8);
    uv1.y = mod(uv1.y,1.2);
    
    int isLine = 10 - int(floor(log_time));
    bool line_mask = (float(LineMaxLength) * fract(log_time) > float(index.x)) ? true : false;

    vec2 rnd_index = vec2(hash11(float(index.y)),hash12(vec2(index)));
    int max_char = int(rnd_index.x * float(LineMaxLength));

    int char_index = int(rnd_index.y * 94.0);
    //int char_index = int(rnd_index.y * 100.0); //Bug


    char_index = (index.x < max_char) ? char_index : 0;

    col = vec3(font(uv1,char_index)) * 0.8; 

    if(isLine == index.y) 
    {
        col *= float(line_mask);
    }
    else{
        col *= float(index.x < LineMaxLength);
        col *= float(index.y > isLine);
    }

    if(ToggleB(Log_Button.w)){col = vec3(0.0);}

    // col *= vec3(0.0,0.7,0.0);
    col = mix(col,vec3(1.0),plogo.w);

    float alpha = (col.x > 0.0) ? 1.0 : 0.0;
    color = vec4(col,alpha);
}
