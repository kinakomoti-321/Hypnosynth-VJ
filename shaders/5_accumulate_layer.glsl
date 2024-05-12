#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"

uniform sampler2D raytracing;
uniform sampler2D accumulate_layer;

out vec4 Out_color;

void main(){
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;
    
    vec4 col;
    vec4 raytre = texture(raytracing,tuv);
    col = raytre;

    if(b_beat.y > 0.05){ 
        vec4 acum =  texture(accumulate_layer,tuv);
        float weight = saturate(acum.a / 10.0);
        acum.xyz *= weight;
        col += acum;
    }

    Out_color =  col;
}