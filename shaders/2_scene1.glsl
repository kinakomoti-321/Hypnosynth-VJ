#version 330

out vec4 color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"

uniform sampler2D PlotLogo;
uniform sampler2D logo_layer;

#define BPM 150
#define Beat time * BPM / 60


uniform sampler2D VAT_test;

//https://www.shadertoy.com/view/7dlfWn
vec2 triangle_wave(vec2 a,float scale){
    return abs(fract((a + vec2(1.1,1.5))*scale)-.5);
}

#define Pi 3.141529

vec3 gem_pattern(vec2 uv,float offset,float iTime){
    vec3 col;
    vec2 uv1 = uv;
    float scale = 1.5;

    for(int i=0;i<6;i++)
    {
        uv = triangle_wave(uv + offset * 0.01,scale);
        uv = triangle_wave(uv.yx,scale) + triangle_wave(uv-1.5 + iTime * 0.1 + offset,scale);
        col.x = (uv.x + uv.y);
        col = abs(col.yzx - vec3(col.y * 0.4,col.x * 0.7,col.z * 0.3)) * abs(sin(min(time,Pi/2.0)));
    }
    
    return col;
}
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


void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec3 col = vec3(0);
    vec3 back_ground = vec3(0.0);

    //------------
    //Back
    //------------
    float split_n = RangeHash11(b_beat.w,1.0,10.0);
    vec2 noiseUV = kaleido_pmod(uv, int(split_n) * 2) * 1.0;
    // noiseUV = uv * 10.0;
    vec3 normal = getNormal(noiseUV,time * 0.1,int(RangeHash11(b_beat.w,6.0,8.0)));
    // vec3 lightDir = normalize(easeHash31(b_beat.w,b_beat.y,1000.0) * vec3(2.0,1.0,2.0) - vec3(1.0,0.0,1.0));
    vec3 lightDir = normalize(vec3(0,1,0));
    vec3 viewDir = normalize(vec3(-1,uv));
    vec3 halfDir = normalize(lightDir + viewDir);
    back_ground = saturate(vec3(pow(dot(halfDir,normal),10.0)));

    // if(ToggleB(b_beat.w)){
    //     col = vec3(cyclicNoise(vec3(noiseUV,time),int(10 * sliders[1]))) * 0.5;
    // }

    // float offset = smoothlerp(buttons[0].w,buttons[0].y) + time;
    // vec3 p = vec3(uv * 5 + offsetCurl((uv + beatTime) * 5.0,0.5 * Toggle(buttons[1].w)),offset * 1.0);
    //col = vec3(cyclicNoise(p,4)) * 0.5;

    vec4 logo_Mask = vec4(0.0);
    if(ToggleB(Logo_MaskButton.w - 1.0)) logo_Mask = texture(logo_layer,stepFunc(tuv,0.01)); 

    //-----
    //Mask
    //-----
    vec3 back_mask = vec3(0.0);
    vec2 mask_uv = uv;
    float sdf_mask = sdBox(uv,vec2(0.1,0.4));

    int counter = (int(b_beat.w)  % 3);
    float[3] weight = float[](-1.0,0.0,1.0);
    mask_uv.y *= -1.0 * weight[counter];
    mask_uv.x = repeat(mask_uv.x,1);
    sdf_mask = sdEquilateralTriangle(mask_uv,0.3);

    if(sdf_mask < 0.0){
        back_mask = vec3(1.0);
    }

    float iTime = time + b_beat.w + powEase(b_beat.y,10);
    if(RedModeON) iTime *= 10.0;

    if(int(b_beat.w) % 4 == 0) back_mask = vec3(1.0);
    if(ToggleB(Logo_MaskButton.w - 1.0)) back_mask += logo_Mask.x; 

    col = back_ground * back_mask;

    //inspire
    //https://www.shadertoy.com/view/wtlcR8
    int x = int(gl_FragCoord.x);
    int y = int(gl_FragCoord.y + time * 10.0);
    int r = (x+y)^(x-y);
    bool b = abs(r*r*r + y + int(iTime * (30.0 + logo_Mask.x * 100.0))) % int(hash11(b_beat.w) * 1892.0 + 500.0) < (1000 * sliders[5] + logo_Mask.x * 500);
    vec3 circuit_col = b? vec3(1.0) : vec3(0.0);

    if(ToggleB(SceneCircuit.w)) col = circuit_col;

    vec2 uvTriCircuit = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    float offset = 0.0;
    offset = logo_Mask.x;
    vec3 TriColor = gem_pattern(uvTriCircuit,offset,iTime);

    if(ToggleB(SceneTriCircuit.w)) {
        if(length(TriColor) > 0.9){
            col = vec3(TriColor.x);
        }
        else{
            col = vec3(0.0);
        }
    }
    

    color = vec4(col,1.0);
}
