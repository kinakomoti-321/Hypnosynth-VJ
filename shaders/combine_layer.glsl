#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"


uniform sampler2D raytracing;
uniform sampler2D accumulate_layer;
uniform sampler2D scene1;
uniform sampler2D logo_layer;
uniform sampler2D vertex;
uniform sampler2D tv_layer;

uniform sampler2D combine_layer;

out vec4 Out_color;

#define Scene1Button buttons[3]

void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;

    vec4 color = texture(vertex,texuv);

    if(ToggleB(Scene1Button.w)){
        color = texture(scene1,texuv);
    }

    if(ToggleB(Raytracing_Button.w)){
        vec4 accumu = texture(accumulate_layer,texuv);
        accumu.xyz /= accumu.a;
        color = accumu;
    }

    //float p = NoiseSlider;
    //color =  (p < hash13(vec3(time,uv))) ? vec4(hash13(vec3(uv,time))) : color;
    
    // color = texture(tv_layer,texuv);     
    vec2 dxy = 1.0/resolution.xy;
    
    if(ToggleB(buttons[18].w) && ToggleB(b_beat.w)){
        float d1,d2;
        vec2 idx;
        ManhattanVoronoi2D(vec2(uv * 5.0 + floor(time) * 10.0),d1,d2,idx);
        vec2 velo = hash22(idx + vec2(100.0)) * 2.0 -1.0;
        ivec2 velo_int = ivec2(velo * sliders[12] * (100.0 + b_beat.y)  );

        color = texture(combine_layer,mod(texuv + vec2(velo_int * dxy),1.0));
    }




    Out_color = color;
}