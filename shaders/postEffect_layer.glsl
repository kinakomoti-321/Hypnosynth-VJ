#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"
#pragma include "./shaders/common/filter.glsl"

out vec4 Out_color;

uniform sampler2D bloom_combine;

#define Inverse_Button buttons[18]
#define Laplacian_Button buttons[19]

void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;
    
    vec2 offsets = 1.0 / resolution.xy;

    vec3 col = texture(bloom_combine, texuv).xyz;

    if(ToggleB(Laplacian_Button.w)){
        col = Laplacian_filter(bloom_combine,texuv,offsets);
    }
    Out_color = vec4(col,1.0);
}
