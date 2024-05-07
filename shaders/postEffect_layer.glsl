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


void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;
    
    float percent = NoiseSlider;
    float noiseOn = float(percent < hash11(uv.y * time)); 

    float _noiseX = hash11(uv.y * time *3.0) * noiseOn;
    float _sinNosiseWidth = hash11(time *3.0) - 0.5;
    float _sinNosiseOffset = hash11(time + 1.0) - 0.5;
    float _sinNoiseScale = hash11(time *3.0) - 0.5;
    _sinNoiseScale  = (NoiseSlider < 0.5) ? 0.5 - NoiseSlider : 0.0;

    texuv.x += sin(uv.y * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;
    texuv.x += (hash11(floor(uv.y * 300.0) + time) - 0.5) * _noiseX ;

    vec2 Roffset = vec2(-0.01,0.0) * AbsorbSlider;
    vec2 Goffset = vec2(0.0,0.0) * AbsorbSlider;
    vec2 Boffset = vec2(0.01,0.0) * AbsorbSlider;

    //RGB
    float r = texture(bloom_combine, texuv + Roffset).x;
    float g = texture(bloom_combine, texuv + Goffset).y;
    float b = texture(bloom_combine, texuv + Boffset).z;

    vec3 col = texture(bloom_combine, texuv).xyz;
    col = vec3(r,g,b);

    if(ToggleB(Laplacian_Button.w)){
        vec2 offsets = 1.0 / resolution.xy;
        col = Laplacian_filter(bloom_combine,texuv,offsets);
    }
    Out_color = vec4(col,1.0);
}
