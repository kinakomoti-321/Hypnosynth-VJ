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
#define Crash buttons[19]

void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;
    
    // float glass_factor = 1.0;
    // int id = 0;
    // if(ToggleB(Crash.w)){
    //     float d = 1000.0;
    //     float d2 = 999.0;
    //     for(int i = 0; i < 16; i++){
    //         float theta = TAU * float(i) / 8.0;
    //         float radius = 0.1;
    //         vec2 p_pos = vec2(cos(theta),sin(theta)) * radius + hash21(i + b_beat.w * 16) * 0.02 + (hash21(b_beat.w) * 2.0 - 1.0 )* 0.4;
    //         vec2 glass_uv = uv + fract(simplexNoise(uv * 10.0) * 10.0) * 0.004;
    //         float dist = length(glass_uv - p_pos);

    //         if(d > dist){
    //             d2 = d;
    //             d = dist;
    //             id = i;
    //         }
    //         else if(d2 > dist){
    //             d2 = dist;
    //         }
    //     }

    //     texuv += (hash21(id) * 2.0 - 1.0) * 0.1;
    //     uv += (hash21(id) * 2.0 - 1.0) * 0.1;
    //     texuv = mod(texuv,1.0);

    //     glass_factor = d2 - d;
    // }

    // float percent = NoiseSlider;
    // float noiseOn = float(percent < hash11(uv.y * time)); 

    // float _noiseX = hash11(uv.y * time *3.0) * noiseOn;
    // float _sinNosiseWidth = hash11(time *3.0) - 0.5;
    // float _sinNosiseOffset = hash11(time + 1.0) - 0.5;
    // float _sinNoiseScale = hash11(time *3.0) - 0.5;
    // _sinNoiseScale  = (NoiseSlider < 0.5) ? 0.5 - NoiseSlider : 0.0;

    // // texuv.x += sin(uv.y * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;

    // if(ToggleB(Crash)){
    //     if(hash11(float(id)) < 0.5){
    //         texuv.x += (hash11(floor(uv.y * 300.0) + time) - 0.5) * _noiseX ;
    //         texuv.x += sin(uv.y * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;
    //     }else{
    //         texuv.y += (hash11(floor(uv.x * 300.0) + time) - 0.5) * _noiseX ;
    //         texuv.y += sin(uv.x * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;
    //     }
    // }
    // else{
    //     texuv.x += sin(uv.y * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;
    //     texuv.x += (hash11(floor(uv.y * 300.0) + time) - 0.5) * _noiseX ;
    // }

    // vec2 Roffset = vec2(-0.001,0.0);
    // vec2 Goffset = vec2(0.0,0.0);
    // vec2 Boffset = vec2(0.001,0.0);

    // //RGB
    // float r = texture(bloom_combine, texuv + Roffset).x;
    // float g = texture(bloom_combine, texuv + Goffset).y;
    // float b = texture(bloom_combine, texuv + Boffset).z;

    vec3 col = texture(bloom_combine, texuv).xyz;
    // col = vec3(r,g,b);

    if(ToggleB(Laplacian_Button.w)){
        vec2 offsets = 1.0 / resolution.xy;
        col = Laplacian_filter(bloom_combine,texuv,offsets);
    }


    if(ToggleB(FakePixelFilter_Button.w)){
        vec2 dxy = 1.0 / resolution.xy; 
        vec3 maxCol = vec3(0);
        int idx = 0;
        int Radius = 100;
        vec3 texCol; 
        for(int i = 0; i < Radius; i++){
            int dir_id = int(clamp(hash11(b_beat.w) * 5.0 + 2.0, .0,5.0)); //Out-of-Array Dengerous

            ivec2 dir[4] = {ivec2(0,i),ivec2(i,0),ivec2(0,-i),ivec2(-i,0)};
            ivec2 neighborCoordinate = ivec2(gl_FragCoord.xy) + dir[dir_id];
            vec2 tuv = vec2(neighborCoordinate) / resolution.xy;
            texCol = texture(bloom_combine,tuv).xyz;
            if(length(maxCol) < length(texCol)){
                maxCol = texCol;
                idx = i;
            }
        }
        col = texCol * maxCol * (Radius - idx) / Radius;
    }

    // if(ToggleB(Crash.w)){
    //     float u = uv.y;
    //     vec2 glass_uv = uv.yy;
    //     if(hash11(float(id) * 8.0 + b_beat.w) > 0.5){ 
    //         u = uv.x;
    //         glass_uv = uv.xx;
    //     }

    //     // u += hash11(floor(time * 20.0) + u * 100.0) * 100.0;  
    //     u = floor((u + hash11(id)) * 700.00);
    
    //     if(hash11(u) > 0.99 * NoiseSlider) col = texture(bloom_combine,mod(glass_uv,1.0)).xyz * hash31(u); 
    // }


    // col = mix(col,col - 0.2,vec3(step(glass_factor,0.0005)));

    //Matrix
    // col = pow(col,vec3(1.1,0.9,1.1));
    Out_color = vec4(col,1.0);
}
