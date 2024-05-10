#version 440

out vec4 out_color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"


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

float map(vec3 p,inout int index){
    float d = 10000.0;

    vec3 tv_d = p;
    tv_d.yz = repeat(tv_d.yz,2.0);
    float d1 = sdBox(tv_d,vec3(1.0));
    float d2 = sdBox(tv_d-vec3(1,0.0,0.0),vec3(0.8));
    float d3 = sdBox(tv_d,vec3(0.8));

    // d = d1;
    d = opSubtraction(d2,d1);
    d -= 0.05;
    index = 0;
    index = (d > d3) ? 1 : index;
    d = opUnion(d3,d);

    return d;
}

vec3 getnormal(vec3 p){
    vec2 eps = vec2(0.001,0.0);
    int dammy = 0;

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


    vec3 prePos = hash31(b_beat.w - 1.0) * 10.0; 
    vec3 nowPos = hash31(b_beat.w) * 10.0;
    vec3 ro = mix(prePos,nowPos, vec3(clamp(powEase(b_beat.y,20.0),0.0,1.0)));
    //vec3 ro = vec3(0,0,-10);
    vec3 atlook = vec3(0.0);
    
    ro.x += 1.0;
    ro.z -= time * 100.0;
    atlook -= time * 100.0;

    vec3 rd = GetCameraDir(ro,atlook,uv,10000.0,0.001,rnd2());

    vec3 pos = ro;
    float d = 0.0;
    float total_d = 0.0;
    vec3 col = vec3(0.0);

    for(int i = 0; i < 100; i++){
        int idx;
        d = map(pos,idx);
        total_d +=d;

        if(d < 0.001){
            col = getnormal(pos);
            if(idx == 1) col = vec3(0.0);
            break;
        } 
        pos = ro + total_d * rd;
    }

    out_color = vec4(col,1.0);
}