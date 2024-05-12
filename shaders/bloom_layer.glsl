#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/color.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"


uniform sampler2D combine_layer;

out vec4 Out_color;

void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec4 color = texture(combine_layer,tuv);
    float threashold = 0.0;
    if(GetRadicance(color.xyz) < threashold){
        color = vec4(0.0);
    }
    Out_color = color; 
}