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

// uniform sampler1D spectrum;
uniform sampler2D PlotLogo;

#define BPM 150
#define Beat time * BPM / 60

uniform sampler2D logo_layer;
uniform sampler2D VAT_test;
uniform sampler2D accumulate_layer;

uniform sampler1D samples;

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

vec3 sliderUI(vec2 uv, float u,vec2 size){
    float uid = sdBox(uv,size);
    float factor = (uv.y + size.y) / (2.0 * size.y);
    u = mod(u,1.01);
    vec3 col = vec3(0);
    if(uid < 0.0){
        if(abs(uid) < 0.003){
            col = vec3(1.0);
        }

        if(factor < u){
            col = vec3(1.0);
        }
    }

    return col;
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
    
    if(RedModeON){
        logouv *= 5.0;
        logouv = mod(logouv,1.0);
    }
    if(logo_index == 0){
        plogo = texture(PlotLogo,logouv);
    }
    else if(logo_index == 1){
        logouv+= offsetCurl((uv) * 5.0,0.5 );
        plogo = texture(PlotLogo,logouv);
    }
    else if(logo_index == 2){
        plogo = texture(PlotLogo,stepFunc(logouv,0.1));
    }
    else if(logo_index == 3){
        logouv *= 2.0;
        logouv.x = mod(logouv.x * 1.8,0.8);
        logouv.y -= 0.8;
        vec3 hatena =font(logouv,int(hash11(b_beat.w) * 80));
        plogo = vec4(hatena,hatena.x);
    }
    else if(logo_index == 4){
        logouv += (hash22(floor(logouv * 100.0)) * 2.0 - 1.0) * 0.1;
        plogo = texture(PlotLogo,logouv);
    }

    int channelID = 1;
    if(ToggleB(SceneButton.w)) channelID = 2;
    if(ToggleB(Raytracing_Button.w)) channelID = 3;



    if(logouv.x < 0.0 || logouv.x >= 0.999) plogo = vec4(0.0);

    vec2 uv_text = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;

    vec2 UIuv1 = uv_text;

    int text_index = int(mod(time_counter,4.0));

    uv_text += 0.5;
    vec2 uv1 = (uv_text) * 50.0;
    
    float log_time = time * 10.0;
    uv1.y -= floor(log_time) * 1.2;

    ivec2 index = ivec2(uv1 / vec2(0.8,1.2));
    uv1.x = mod(uv1.x,0.8);
    uv1.y = mod(uv1.y,1.2);
    
    int isLine = 10 - int(floor(log_time));
    bool line_mask = (float(LineMaxLength) * fract(log_time) > float(index.x)) ? true : false;

    vec2 rnd_index = vec2(hash11(float(index.y)),hash12(vec2(index)));
    int max_char = int(rnd_index.x * float(LineMaxLength));

    int char_index = int(rnd_index.y * 94.0 + sliders[3] * 10.0);
    // int char_index = int(rnd_index.y * 120.0); //Bug
    if(RedModeON) char_index = 63;
    char_index = (index.x < max_char) ? char_index : 0;
    vec3 text_col;
    text_col = vec3(font(uv1,char_index)) * 0.8; 


    if(isLine == index.y ) 
    {
        text_col *= float(line_mask);
    }
    else{
        text_col *= float(index.x < LineMaxLength);
        text_col *= float(index.y > isLine);
    }

    UIuv1 += vec2(0.45,0.0);
    float UV1_Window_sdf = sdBox(UIuv1,vec2(0.2,0.3));

    if(UV1_Window_sdf > 0.0){
        col = vec3(0.0);
    }
    else{
        col = text_col;
        col += vec3(float((1.0 - abs(UV1_Window_sdf)) > 0.999));
    }


    //--------------
    //UI
    //--------------
    vec2 UV23offset = vec2(-1.67,-1.1);
    vec2 UV2 = gl_FragCoord.xy / resolution.y;
    UV2 *= 1.5;
    UV2 += UV23offset;
    float sliders1 = smoothstep(0.0,1.0,sliders[2 + (channelID - 1) * 2] + hash11(time) * 0.1);
    float sliders2 = smoothstep(0.0,1.0,sliders[3 + (channelID - 1) * 2] + hash11(time + 1.0) * 0.1);

    float button1 = Toggle(buttons[3 + (channelID - 1) * 3].w);
    float button2 = Toggle(buttons[4 + (channelID - 1)* 3].w);
    float button3 = Toggle(buttons[5 + (channelID - 1)* 3].w);

    col += sliderUI(UV2 - vec2(0.075,-0.01) ,sliders1,vec2(0.03,0.08));
    col += sliderUI(UV2 - vec2(0.15,-0.01),sliders2,vec2(0.03,0.08));
    col += sliderUI(UV2 - vec2(-0.15,-0.06),button1,vec2(0.03));
    col += sliderUI(UV2- vec2(-0.075,-0.06),button2,vec2(0.03));
    col += sliderUI(UV2- vec2(-0.00,-0.06),button3,vec2(0.03));


    float UV2_sdf = sdBox(UV2,vec2(0.2,0.1));
    if(abs(UV2_sdf) < 0.001){
        col += vec3(1.0);
    }

    int chars[8] = int[](0,0,0,0,0,0,13,18);
    vec3 testcol = CharAndNumber(UV2 * 4.0 - vec2(0.4,-0.2),chars,int(b_beat.w));
    col += CharAndNumber(UV2*2.0 + vec2(0.35,0.15),chars,channelID);

    //counter
    chars = int[](0,13,25,31,24,30,15,28);
    col += CharAndNumber(UV2*2.0 + vec2(0.35,0.23),chars,int(b_beat.w));

    if(ToggleB(Raytracing_Button.w)){
        float sampling = texture(accumulate_layer,vec2(0.0)).w;
        chars = int[](0,0,0,0,0,29,26,26);
        col += CharAndNumber(UV2*2.0 + vec2(0.35,0.31),chars,int(sampling));
    }

    vec2 UV3 = gl_FragCoord.xy / resolution.y;
    UV3 *= 1.5;
    UV3 += UV23offset;
    UV3 += vec2(0.0,0.3);
    float UV3_sdf = sdBox(UV3,vec2(0.2));

    if(abs(UV3_sdf) < 0.001){
        col += vec3(1.0);
    }
    UV3 += vec2(0.03,0.0);
    chars = int[](0,13,25,31,24,30,15,28);
    float UV3Offset = 0.07;
    for(int i = 0; i < 8; i++){
        col += CharAndNumber(UV3*2.0 + vec2(0.35,UV3Offset * i),chars,int(i + b_beat.w));
    }


    if(ToggleB(UI_Button.w)){col = vec3(0.0);}

    //---------------------------------------

    // col *= vec3(0.0,0.7,0.0);
    if(ToggleB(LogoButton.w)){col = mix(col,vec3(1.0),plogo.w);}
    float alpha = (col.x > 0.0) ? 1.0 : 0.0;
    // float alpha = 1.0;
    // vec2 uv_spec = (gl_FragCoord.xy) / resolution.xy;
    // col = texture(samples,uv_spec.y * 1.0).rgb;
    color = vec4(col,alpha);
}
