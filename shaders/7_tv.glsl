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

vec3 Movie(vec2 texuv){
    texuv = mod(texuv,1.0);
    vec3 col;
    vec2 uv = texuv * 2.0 - 1.0;

    vec4 logo_col = texture(combine_layer,texuv);
    col = logo_col.xyz; 
    return col;
}

struct SDFInfo{
    int index;
    vec2 uv;
};

float map(vec3 p,inout SDFInfo info){
    float d = 10000.0;

    vec3 tv_d = p;
    // tv_d.yz = repeat(tv_d.yz,2.0);
    float d1 = sdBox(tv_d,vec3(1.0));
    float d2 = sdBox(tv_d-vec3(1,0.0,0.0),vec3(0.85));
    float d3 = sdBox(tv_d-vec3(0.2,0.0,0.0),vec3(0.85));

    // d = d1;
    d = opSubtraction(d2,d1);
    d -= 0.05;
    info.index = 0;
    info.index = (d > d3) ? 1 : info.index;
    d = opUnion(d3,d);

    info.uv = vec2(1.0);

    vec2 tv_uv = p.zy * 1.3;
    tv_uv.y /= 0.7;

    float distort_r = length(tv_uv);
    tv_uv *= 1.0 + distort_r * distort_r * 0.02;

    tv_uv.x = -tv_uv.x;
    tv_uv = (tv_uv + 1.0) * 0.5;
    info.uv = tv_uv;

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


void main() {
    seed = uint(time * 64) * uint(gl_FragCoord.x + gl_FragCoord.y * resolution.x);
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;

    // float distort_r = length(uv);
    // uv *= 1.0 + distort_r * distort_r * 1.0;

    // vec3 prePos = hash31(b_beat.w - 1.0) * 10.0; 
    // vec3 nowPos = hash31(b_beat.w) * 10.0;
    // vec3 ro = mix(prePos,nowPos, vec3(clamp(powEase(b_beat.y,20.0),0.0,1.0)));
    vec3 ro = vec3(1.55,0.0,0.0);
    //vec3 ro = vec3(0,0,-10);
    vec3 atlook = vec3(0.0);
    
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
            col = getnormal(pos);
            if(info.index == 1){
                col = vec3(info.uv,0.0);
                col = Movie(info.uv);
            }
            break;
        } 
        pos = ro + total_d * rd;
    }

    out_color = vec4(col,1.0);
}