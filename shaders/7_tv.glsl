#version 440

out vec4 out_color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"
#pragma include "./shaders/common/filter.glsl"

uniform sampler2D raytracing;
uniform sampler2D accumulate_layer;
uniform sampler2D scene1;
uniform sampler2D logo_layer;
uniform sampler2D vertex;
uniform sampler2D tv_layer;
uniform sampler2D combine_layer;

#define TVSize 2.1
uint seed;

uint PCGHash()
{
    seed = seed * 747796405u + 2891336453u;
    uint state = seed;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

float rnd1()
{
    return PCGHash() / float(0xFFFFFFFFU);    
}

vec2 rnd2(){
    return vec2(rnd1(),rnd1());
}

vec3 Movie(vec2 texuv,vec3 tv_index){

    vec3 col;
    vec2 uv = texuv * 2.0 - 1.0;

    float glass_factor = 1.0;
    int id = 0;
    if(ToggleB(GlassFilter_Button.w)){
        float d = 1000.0;
        float d2 = 999.0;
        for(int i = 0; i < 16; i++){
            float theta = TAU * float(i) / 8.0;
            float radius = 0.1;
            vec2 p_pos = vec2(cos(theta),sin(theta)) * radius + hash21(i + b_beat.w * 16) * 0.02 + (hash21(b_beat.w) * 2.0 - 1.0 )* 0.4;
            vec2 glass_uv = uv + fract(simplexNoise(uv * 10.0) * 10.0) * 0.004;
            float dist = length(glass_uv - p_pos);

            if(d > dist){
                d2 = d;
                d = dist;
                id = i;
            }
            else if(d2 > dist){
                d2 = dist;
            }
        }

        texuv += (hash21(id) * 2.0 - 1.0) * 0.1;
        uv += (hash21(id) * 2.0 - 1.0) * 0.1;
        texuv = mod(texuv,1.0);

        glass_factor = d2 - d;
    }

    vec3 exception = vec3(1.0);
    if(uv.x < -1.0||uv.x > 1.0 || uv.y < -1.0||uv.y > 1.0 ) exception = vec3(0.0);

    float percent = NoiseSlider;
    float noiseOn = float(percent < hash11(uv.y * time)); 

    float beatPin = Beat(b_beat.y,2.0);
    float _noiseX = hash11(uv.y * time *3.0) * noiseOn  * (beatPin + 0.01);
    float _sinNosiseWidth = hash11(time *3.0) - 0.5;
    float _sinNosiseOffset = hash11(time + 1.0) - 0.5;
    float _sinNoiseScale = hash11(time *3.0) - 0.5;
    _sinNoiseScale  = (1.0 - NoiseSlider) * (beatPin * 0.1);

    // texuv.x += sin(uv.y * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;

    if(ToggleB(GlassFilter_Button.w)){
        if(hash11(float(id)) < 0.5){
            texuv.x += (hash11(floor(uv.y * 300.0) + time) - 0.5) * _noiseX ;
            texuv.x += sin(uv.y * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;
        }else{
            texuv.y += (hash11(floor(uv.x * 300.0) + time) - 0.5) * _noiseX ;
            texuv.y += sin(uv.x * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;
        }
    }
    else{
        texuv.x += sin(uv.y * _sinNoiseScale + _sinNosiseOffset) * _sinNoiseScale;
        texuv.x += (hash11(floor(uv.y * 300.0) + time) - 0.5) * _noiseX ;
    }


    float absorbPower = 0.1 + step(glass_factor,0.001) + pow(length(uv),2.0) * 0.02;
    vec2 Roffset = vec2(-0.01,0.0) *absorbPower;
    vec2 Goffset = vec2(0.0,0.0) * absorbPower;
    vec2 Boffset = vec2(0.01,0.0) * absorbPower;

    //RGB
    float r = texture(combine_layer, texuv + Roffset).x;
    float g = texture(combine_layer, texuv + Goffset).y;
    float b = texture(combine_layer, texuv + Boffset).z;

    // vec3 col = texture(bloom_combine, texuv).xyz;
    col = vec3(r,g,b);

    if(ToggleB(GlassFilter_Button.w)){
        float u = uv.y;
        vec2 glass_uv = uv.yy;
        if(hash11(float(id) * 8.0 + b_beat.w) > 0.5){ 
            u = uv.x;
            glass_uv = uv.xx;
        }

        // u += hash11(floor(time * 20.0) + u * 100.0) * 100.0;  
        u = floor((u + hash11(id)) * 700.00);
    
        if(hash11(u) > 0.95 * NoiseSlider) col = texture(combine_layer,mod(glass_uv,1.0)).xyz * hash31(u); 
    }


    col = mix(col,col - 0.2,vec3(step(glass_factor,0.0005)));
    // col = col * (1.0 + 0.6 * step(sin((texuv.y + hash11(texuv.x + time) * 0.01) * 2.0 + time),-0.99));
    col *= exception;

    //col = logo_col.xyz; 
    return col;
}

struct SDFInfo{
    int index;
    vec2 uv;
    vec3 TV_index;
};

float tv_map(vec3 p,inout SDFInfo info){

    vec3 tv_d = p;
    // tv_d.yz = repeat(tv_d.yz,2.0);
    float d1 = sdBox(tv_d,vec3(1.0));
    float d2 = sdBox(tv_d-vec3(1,0.0,0.0),vec3(0.85,0.825,0.9));
    float d3 = sdBox(tv_d-vec3(0.15,0.0,0.0),vec3(0.85));

    // d = d1;
    float d = opSubtraction(d2,d1);
    d -= 0.05;
    info.index = 0;
    info.index = (d > d3) ? 1 : info.index;
    d = opUnion(d3,d);

    info.uv = vec2(1.0);

    vec2 tv_uv = p.zy * 1.1;
    tv_uv.y /= 0.8;

    float distort_r = length(tv_uv);
    tv_uv *= 1.0 + distort_r * distort_r * 0.1;

    tv_uv.x = -tv_uv.x;
    tv_uv = (tv_uv + 1.0) * 0.5;
    info.uv = tv_uv;

    return d;
}


float map(vec3 p,inout SDFInfo info){
    
    p.yz -= 1.05;
    // int tv_index = int(hash13(floor(p / 2.1)) * 10000.0);
    info.TV_index = floor(p / 2.1);
    p.yz = repeat(p.yz,2.1);
    
    float d = tv_map(p,info);

    return d;
}

vec3 getnormal(vec3 p){
    vec2 eps = vec2(0.001,0.0);
    SDFInfo dammy;

    return normalize(vec3(
        map(p + eps.xyy,dammy) - map(p - eps.xyy,dammy),
        map(p + eps.yxy,dammy) - map(p - eps.yxy,dammy),
        map(p + eps.yyx,dammy) - map(p - eps.yyx,dammy)
    ));
} 

vec3 tebureOffset(vec2 pos,float stime){
    float x = cyclicNoise(vec3(pos,stime),2) * 2.0 - 1.0; 
    float y = cyclicNoise(vec3(pos + 1.0,stime),2) * 2.0 - 1.0; 
    float z = cyclicNoise(vec3(pos + 2.0,stime),2) * 2.0 - 1.0; 
    return vec3(x,y,z);
}

void main() {
    seed = uint(time * 64) * uint(gl_FragCoord.x + gl_FragCoord.y * resolution.x);
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;

    // float distort_r = length(uv);
    // uv *= 1.0 + distort_r * distort_r * 1.0;

    // vec3 prePos = hash31(b_beat.w - 1.0) * 10.0; 
    // vec3 nowPos = hash31(b_beat.w) * 10.0;
    // vec3 ro = mix(prePos,nowPos, vec3(clamp(powEase(b_beat.y,20.0),0.0,1.0)));

    vec3 ro = vec3(1.6,0.0,0.0);

    if(ToggleB(TV_StartButton.w)){
        ro = mix(ro,vec3(5.0,0.0,0.0),TV_FOVSlider);
        ro += tebureOffset(ro.yz,time) * 0.2 * smoothstep(0,1,TV_FOVSlider);
    }

    vec3 transform = vec3(0,0,TVSize * b_beat.w);
    vec3 prePos = floor(hash31(b_beat.w - 1.0) * 3.0) * TVSize; 
    prePos -= transform - vec3(0,0,TVSize);
    vec3 nowPos = floor(hash31(b_beat.w) * 3.0) * TVSize;
    nowPos -= transform;

    vec3 test =  mix(prePos,nowPos, vec3(clamp(powEase(b_beat.y,10.0),0.0,1.0)));
    vec3 offset = vec3(0.0,test.y,test.z );

    //vec3 ro = vec3(0,0,-10);
    vec3 atlook = vec3(0.0);

    if(ToggleB(TV_MoveButton.w)){    
        ro += offset; 
        atlook += offset;   
    }
    // ro.x += 1.0;
    // ro.z -= time * 100.0;
    // atlook -= time * 100.0;

    vec3 rd = GetCameraDir(ro,atlook,uv,10000.0,0.001,rnd2());

    vec3 pos = ro;
    float d = 0.0;
    float total_d = 0.0;
    vec3 col = vec3(0.0);
    SDFInfo info;
    for(int i = 0; i < 100; i++){
        d = map(pos,info);
        total_d +=d;

        if(d < 0.001){
            // col = getnormal(pos);
            if(info.index == 1){
                col = vec3(info.uv,0.0);
                col = Movie(info.uv,info.TV_index);
            }
            else{
                
            }

            break;
        } 
        pos = ro + total_d * rd;
    }

    out_color = vec4(col,1.0);
}