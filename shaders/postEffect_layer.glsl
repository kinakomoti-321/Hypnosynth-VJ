#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"
#pragma include "./shaders/common/filter.glsl"

uniform sampler2D combine_layer;
// uniform sampler2D bloom_layer;
uniform sampler2D bloom_gauss;

out vec4 Out_color;
uniform vec3 tint;


void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;
    vec3 col = texture(combine_layer, texuv).xyz;
    //col = texture(bloom_layer, texuv).xyz;

    vec2 uv_offset = 1.0 / resolution.xy;
    uv_offset.x = 0;
    float sigma = 20.0;
    vec3 bloom_light = gaussian_blur(bloom_gauss,texuv,uv_offset,sigma) * 0.5;

    col += bloom_light;

    Out_color = vec4(col,1.0);
}
