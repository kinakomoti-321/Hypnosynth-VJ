#version 400

out vec4 color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"
#pragma include "./shaders/common/constant.glsl"


uniform sampler2D raytracing;

uint seed;

int scene_number = 0;
int caostic = 0;

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

float ifs_box(vec3 p,float time){
    float d = 1000.0;
    vec3 p1 = p;
    p1 -= vec3(0.0,0.0,0.0);
    p1.xy = rotate(p1.xy,time);
    p1.yz = rotate(p1.yz,time);
    
    p1 = abs(p1) - vec3(1.0,0.0,0.1);
    p1.xy = rotate(p1.xy,time);
    p1.yz = rotate(p1.yz,time * 2.0 + 2.1);

    for(int i = 0; i < 4; i++){
        float dt = sdBox(p1,vec3(0.2,2.0,0.5));
        p1 = abs(p1 - vec3(100.0)) - vec3(1.0,0.0,1.0);
        p1.xy = rotate(p1.xy,time);
        p1.yz = rotate(p1.yz,time * 2.0 + 2.1);

        d = min(dt,d);
    } 
    return d;
}

// 0:Normal Lambert 1:Light,
vec3 basecolor[10] = vec3[](vec3(0.8),vec3(0.8),vec3(0.8,0.2,0.2),
vec3(0.2,0.8,0.2),vec3(1.0),vec3(0.8),
vec3(0.2,0.2,0.8),vec3(1.0),vec3(0.8,0.8,0.0),vec3(1.0));

vec3 emission[10] = vec3[](vec3(0.0),vec3(3.0),vec3(0.0),
vec3(0.0),vec3(0.0),vec3(0.8,0.8,1.0),
vec3(0.0),vec3(0.0),vec3(0.0),vec3(1.0,0.2,0.2));

float roughness[10] = float[](0.0,0.0,0.01,0.0,0.03,0.0,0.05,0.0,0.2,0.0);
float metallic[10] = float[](0.0,0.0,0.0,0.0,1.0,0.0,1.0,0.0,1.0,0.0);


float map_cornelbox(vec3 p, inout int index){
    if(caostic >= 1){
        p.x = repeat(p.x,2.0);
        p.y = repeat(p.y,2.0);
    }

    float d1 = sdBox(p,vec3(1.0)); 
    float d2 = sdBox(p - vec3(0.0,0.0,0.4),vec3(1.2,0.8,1.2)); 
    float d3 = sdBox(p - vec3(1.0,0.0,0.0),vec3(0.1,1.0,1.0)); 
    float d4 = sdBox(p + vec3(1.0,0.0,0.0),vec3(0.1,1.0,1.0)); 
    float d5 = sdBox(p - vec3(0.0,0.8,0.0),vec3(0.5,0.05,0.5)); 

    vec3 p_box = p;
    p_box += vec3(0.4,0.5,0.0);
    p_box.xz = rotate(p_box.xz,PI * 0.25);
    float d6 = sdBox(p_box,vec3(0.2,0.3,0.2) * 1.4);
    vec3 p_box2 = p;
    p_box2 += vec3(-0.3,0.6,-0.3);
    p_box2.xz = rotate(p_box2.xz,PI * 0.25);
    float d7 = sdBox(p_box2,vec3(0.2) * 1.2);
    float d;

    d = opSubtraction(d2,d1);
    index = 0;

    index = (d > d3) ? 2 : index;
    d = opUnion(d,d3);
    index = (d > d4) ? 3 : index;
    d = opUnion(d,d4);
    index = (d > d5) ? 1 : index;
    d = opUnion(d,d5); 
    
    d6 = opUnion(d7,d6);
    index = (d > d6) ? 0 : index;
    d = opUnion(d,d6);
    return d; 
}

float scene2_map(vec3 p, inout int index){
    vec3 p1 = p;
    float d1 = sdBox(p1,vec3(20.0,10.0,20.0)); 
    float d2 = sdBox(p1,vec3(19.0,9.0,19.0)); 

    vec3 p2 = p;
    p2.xy = repeat(p2.xy,5.0);
    float d3 = sdBox(p2,vec3(1.0)); 

    float d = opSubtraction(d2,d1);
    index = (d3 < d) ? 1:0;
    d = opUnion(d,d3);
    return d;
}

float map(vec3 p,inout int index){
    float d = 10000.0;
    vec3 p1 = p;
    int index1 = 1;

    if(caostic >= 2){
        p.yz = rotate(p.yz,p.x * (floor(hash11(b_beat.w + 1.0) * float(caostic - 1.0)) * 0.1) + b_beat.w);
        p.xz = rotate(p.xz,p.y * (floor(hash11(b_beat.w) * float(caostic - 1.0)) * 0.3) + b_beat.w);
    }

    if(scene_number == 0){
        d = map_cornelbox(p,index);
    }
    else{
        d = scene2_map(p,index);
    }
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

struct IntersectInfo{
    vec3 pos;
    vec3 normal;
    float dist;
    bool is_hit;
    vec3 emission;
    vec3 basecol;
    float metallic;
    vec2 roughness;
};

#define RAYMARCHING_DEPTH 200
bool raymarching(vec3 ro,vec3 rd,inout IntersectInfo info){
    vec3 pos = ro;
    float total_d = 0;  

    vec3 col = vec3(0);

    for(int i = 0; i < RAYMARCHING_DEPTH; i++){
        int index;
        float d = map(pos,index);

        if(d < 0.0001){
            if(ToggleB(Raytracing_IndexOffset.w)){
                index = int(mod(b_beat.w + (index),4));
            }
            info.pos = pos;
            info.normal = getnormal(pos);
            info.dist = total_d;
            info.basecol = basecolor[index];
            info.roughness = vec2(roughness[index]);
            info.metallic = metallic[index];
            info.emission = emission[index];

            if(ToggleB(Raytracing_IndexOffset.w)){
                info.basecol = vec3(1.0);
                info.roughness = vec2(1.0);
                info.metallic = 1.0;
                // info.roughness = vec2(cyclicNoise(info.pos *2.0,5));
                info.roughness = vec2(0.1);
            }
            return true;

            break;
        } 

        pos += d * rd;
        total_d += d;
    }
    return false;
}

// void tangentSpaceBasis(vec3 normal,inout vec3 t,inout vec3 b){
//     if (abs(normal.y) < 0.9)
//     {
//         t = cross(normal, vec3(0, 1, 0));
//     }
//     else
//     {
//         t = cross(normal, vec3(0, 0, -1));
//     }
//     t = normalize(t);
//     b = cross(t, normal);
//     b = normalize(b);
// }

vec3 worldtoLoacal(vec3 v,vec3 lx, vec3 ly,vec3 lz){
    return vec3(v.x * lx.x + v.y* lx.y + v.z * lx.z,
                 v.x * ly.x + v.y * ly.y + v.z * ly.z,
                 v.x * lz.x + v.y * lz.y + v.z * lz.z);
}

vec3 localToWorld(const vec3 v, const vec3 lx, const vec3 ly,
                   const vec3 lz)
{
    return vec3(v.x * lx.x + v.y * ly.x + v.z * lz.x,
                 v.x * lx.y + v.y * ly.y + v.z * lz.y,
                 v.x * lx.z + v.y * ly.z + v.z * lz.z);
}

//Y-up GGX
float ggx_D(vec3 m,float alpha_x,float alpha_y){
    float delta = m.x * m.x / (alpha_x * alpha_x) + m.y * m.y + m.z * m.z / (alpha_y * alpha_y) ;
    return 1.0 / (PI * alpha_x * alpha_y * delta * delta);
}

float ggx_Lambda(vec3 v,float alpha_x, float alpha_y){
    float delta = 1.0 + (alpha_x * alpha_x * v.x * v.x + alpha_y * alpha_y * v.z * v.z) / (v.y * v.y);
    return 0.5 * (-1.0 + sqrt(max(delta,0.0)));
}

float ggx_G(vec3 wo,vec3 wi,float alpha_x,float alpha_y){
    return 1.0 / (1.0 + ggx_Lambda(wo,alpha_x,alpha_y)+ ggx_Lambda(wi,alpha_x,alpha_y));
}

float ggx_G1(vec3 wo,float alpha_x,float alpha_y){
    return 1.0 / (1.0 + ggx_Lambda(wo,alpha_x,alpha_y));
}

vec3 Fresnel(vec3 F0, float cosine){
    float delta = (1.0 - cosine);
    return F0 + (vec3(1.0) - F0) * delta * delta * delta * delta * delta;
}

vec3 visibleNormalSample(vec3 wo,vec2 u,float alpha_x,float alpha_y){
    vec3 wi = normalize(vec3(wo.x * alpha_x, wo.y, wo.z * alpha_y));

    float phi = 2.0f * PI * u.x;
    float z = fma((1.0f - u.y), (1.0f + wi.z), -wi.z);
    float sinTheta = sqrt(clamp(1.0f - z * z, 0.0f, 1.0f));
    float x = sinTheta * cos(phi);
    float y = sinTheta * sin(phi);
    vec3 c = vec3(x, y, z);
    vec3 h = c + wi;
    
    return normalize(vec3(wo.x * alpha_x, max(wo.y,0.0), wo.z * alpha_y));
}

vec3 WalterSampling(vec2 xi,float alpha){
    float phi = TAU * xi.x;
    float theta = atan(alpha * sqrt(xi.y) / (sqrt(1.0 - xi.y)));
    return vec3(sin(theta) * cos(phi),cos(theta),sin(theta) * sin(phi));
}

vec3 MicrofacetBRDF(vec3 wo,inout vec3 wi,vec3 F0,float alpha_x,float alpha_y){
    alpha_x = alpha_x * alpha_x;
    alpha_y = alpha_y * alpha_y;
    vec3 normal = vec3(0,1,0);

    //vec3 wm = visibleNormalSample(wo,rnd2(),alpha_x,alpha_y);
    vec3 wm = WalterSampling(rnd2(),alpha_x);
    wi = reflect(-wo,wm);

    if(wm.y < 0){
        return vec3(0);
    }

    float idotn = abs(wi.y);
    float odotn = abs(wo.y);
    float idotm = abs(dot(wm,wi));
    float mdotn = abs(wm.y);

    //float ggxD = ggx_D(wm,alpha_x,alpha_y);
    float ggxG = ggx_G(wo,wi,alpha_x,alpha_y);
    vec3 ggxF = Fresnel(F0,idotm);

    vec3 BSDF = 0.25f *  ggxF * ggxG / (odotn * mdotn); 

    // wi = reflect(-wo,normal);
    // vec3 ggxF = Fresnel(F0,wo.y);
    // vec3 BSDF = ggxF;
    return BSDF;
}

vec3 cosineSampling(vec2 uv){
    float theta = acos(1.0 - 2.0f * uv.x) * 0.5;
    float phi = 2.0 * PI * uv.y;
    return vec3(sin(theta) * cos(phi),cos(theta),sin(theta) * sin(phi));
}

vec3 LambertBRDF(vec3 wo,inout vec3 wi,vec3 basecol){
    wi = cosineSampling(rnd2()); 
    return basecol;
}

vec3 pathtrace(vec3 ro,vec3 rd){
    vec3 ray_ori = ro;
    vec3 ray_dir = rd;
    vec3 LTE = vec3(0);
    vec3 throughput = vec3(1);
    int MAXDEPTH = 5;
    float rossian_p = 1.0;
    for(int depth = 0; depth < 5; depth++){
        rossian_p = clamp(max(max(throughput.x,throughput.y),throughput.z),0.0,1.0);
        if(rossian_p < rnd1()){
            break;
        }
    
        throughput /= rossian_p;

        IntersectInfo info;
        if(!raymarching(ray_ori,ray_dir,info)){
            if(depth != 0){
                LTE += throughput * pow(clamp(ray_dir.y,0.0,1.0),10.0);
            }
            break;
        }

        // throughput *= exp(-info.dist * 0.025);

        if(length(info.emission) > 0.1){
            LTE = throughput * info.emission * (dot(info.normal,-ray_dir)*0.5 + 0.5);
            break;
        }


        vec3 normal = info.normal;
        vec3 t,b;

        tangentSpaceBasis(normal,t,b);

        vec3 local_wo = worldtoLoacal(-ray_dir,t,normal,b);

        vec3 local_wi;

        vec3 bsdf;
        if(info.metallic < 0.5){
            bsdf = LambertBRDF(local_wo,local_wi,info.basecol);
        }
        else{
            bsdf = MicrofacetBRDF(local_wo,local_wi,info.basecol,info.roughness.x,info.roughness.y);
        }

        throughput *= bsdf;


        vec3 wi = localToWorld(local_wi,t,normal,b); 
        ray_ori = info.pos + wi * 0.001;
        ray_dir = wi;
    }

    return LTE;
}

void main(){
    seed = uint(time * 64) * uint(gl_FragCoord.x + gl_FragCoord.y * resolution.x);
    vec2 uv = ((gl_FragCoord.xy + rnd2()) - resolution.xy * 0.5) / resolution.y;
    //vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;
    
    caostic = int(Raytracing_Slider * 4);

    scene_number = 0;
    vec2 rotuv = uv * rot(hash11(b_beat.w) * TAU);
    // if(rotuv.x > 0.0){
    //     scene_number = 1;
    // }

    vec3 prePos = hash31(b_beat.w - 1.0); 
    vec3 nowPos = hash31(b_beat.w);

    vec3 ro = mix(prePos,nowPos, vec3(clamp(powEase(b_beat.y,20.0),0.0,1.0)));
    ro = (ro * 2.0) - 1.0;
    float range = 2.0;
    if(caostic > 0) range = 10.0;
    ro *= range;
    ro.z = abs(ro.z) + range;
    // ro = vec3(0,0,6);
    vec3 atlook = vec3(0.0);

    vec3 rd = GetCameraDir(ro,atlook,uv,90.0 * hash11(b_beat.w),0.000,rnd2());

    vec3 col = vec3(0.0);
    
    if(ToggleB(Raytracing_Button.w)){
        col = pathtrace(ro,rd);
    }

    vec4 accmu_tex = texture(raytracing,tuv);
    vec4 finish_col = vec4(col,1.0);

    // if(buttons[0].y > 0.1){
    //     finish_col = vec4(col,1.0) + accmu_tex;
    // }

    // finish_col = (abs(rotuv.x) < 0.002) ? vec4(0.0)  : finish_col;

    color = finish_col;
}