#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/color.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"
#pragma include "./shaders/common/filter.glsl"

uniform sampler2D bloom_layer;

out vec4 Out_color;

void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec4 color = vec4(0); 

    vec2 uv_offset = 1.0 / resolution.xy;
    uv_offset.y = 0;
    float sigma = 20.0;

    color.xyz = gaussian_blur(bloom_layer,tuv,uv_offset,sigma);

    Out_color = color; 
}