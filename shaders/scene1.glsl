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

#define BPM 150
#define Beat time * BPM / 60

uniform sampler2D VAT_test;

#define LogoSlider sliders[2]
#define LogoButton1 buttons[4]


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
    //Front
    //------------

    int logo_index = int(LogoSlider * 5.0f);
    float beatTime = floor(time * 10.0 + 1.0);
    float beatTimef = fract(time * 10.0 + 1.0);
    vec2 logouv = tuv * 2.0 - 1.0;
    logouv *= 2.0;
    logouv += ((hash21(beatTime) * 2.0 - 1.0) * sliders[0]) * (beatTimef * 0.2 + 0.8);
    logouv = logouv * 0.5 + 0.5 ;
    //なんかいい感じ
    vec4 plogo = vec4(0);

    if(logo_index == 0){
        plogo = texture(PlotLogo,logouv);
    }
    else if(logo_index == 1){
       plogo = texture(PlotLogo,logouv+ offsetCurl((uv) * 5.0,0.5 ));
    }

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

    back_ground *= back_mask * sliders[1];

    col = mix(back_ground,vec3(1.0),plogo.w);

    color = vec4(col,1.0);
}
