#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"


uniform sampler2D scene1;
uniform sampler2D raytracing;
uniform sampler2D accumulate_layer;

out vec4 Out_color;

#define Raytracing_Button buttons[9]

void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;

    vec4 color = texture(scene1,texuv);
    // color = texture(raytracing,texuv);
    // color.xyz /= color.a;
    if(ToggleB(Raytracing_Button.w)){
        vec4 accumu = texture(accumulate_layer,texuv);
        accumu.xyz /= accumu.a;
        color = accumu;
    }
    
    Out_color = color;
}