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


vec2 seed;

float map(vec3 p){
    float d = 10000.0;
    d = sdBox(p,vec3(1,1,1));
    return d;
}

vec3 getnormal(vec3 p){
    vec2 eps = vec2(0.001,0.0);

    return normalize(vec3(
        map(p + eps.xyy) - map(p - eps.xyy),
        map(p + eps.yxy) - map(p - eps.yxy),
        map(p + eps.yyx) - map(p - eps.yyx)
    ));
} 

struct intersectInfo{
    vec3 pos;
    vec3 normal;
    float dist;
    bool is_hit;
    vec3 emission;
    vec3 basecol;
    vec2 roughness;
};

bool raymarching(vec3 ro,vec3 rd,inout intersectInfo){
    vec3 pos = ro;
    float total_d = 0;  

    vec3 col = vec3(0);
    intersectInfo info;

    for(int i = 0; i < 100; i++){
        float d = map(pos);

        if(d < 0.01){
            intersectInfo.pos = pos;
            intersectInfo.normal = getnormal(pos);
            intersectInfo.basecol = vec3(0.8);
            intersectInfo.roughness = vec2(0.5);
            intersectInfo.emission = vec3(0.0);

            return true;
            break;
        } 

        pos += d * rd;
        total_d += d;
    }
    return false;
}

void tangentSpaceBasis(vec3 normal,inout vec3 t,inout vec3 b){
    if (abs(normal.y) < 0.9)
    {
        t = cross(normal, vec3(0, 1, 0));
    }
    else
    {
        t = cross(normal, vec3(0, 0, -1));
    }
    t = normalize(t);
    b = cross(t, normal);
    b = normalize(b);
}

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

vec3 GGX(vec3 wo,inout vec3 wi,vec3 F0,vec2 xi,float alpha_x,float alpha_y,inout float pdf){

    vec3 normal = vec3(0,1,0);
    vec3 wm = visibleNormalSample(wo,xi,alpha_x,alpha_y);
    wi = reflect(wm,normal);

    if(wm.y < 0){
        pdf = 1.0;
        return vec3(0);
    }

    float idotn = abs(wi.y);
    float odotn = abs(wo.y);
    float idotm = abs(dot(wm,wi));

    float ggxD = ggx_D(wm,alpha_x,alpha_y);
    float ggxG = ggx_G(wo,wi,alpha_x,alpha_y);
    vec3 ggxF = Fresnel(F0,idotm);

    vec3 BSDF = 0.25 * ggxF * ggxD * ggxG /(idotn * odotn);

    return BSDF;
}

void main(){
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec3 ro = vec3(0,0,-10);
    vec3 rd = normalize(vec3(uv,1));

    vec3 col = raymarching(ro,rd);

    color = vec4(col,1.0);
}