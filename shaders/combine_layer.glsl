#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"


uniform sampler2D raytracing;
uniform sampler2D accumulate_layer;
uniform sampler2D scene1;
uniform sampler2D logo_layer;
uniform sampler2D vertex;
uniform sampler2D tv_layer;

uniform sampler2D combine_layer;

uniform sampler2D NDI_0;
uniform sampler2D NDI_1;

out vec4 Out_color;

#define Scene1Button buttons[3]

    //magnetic dipole
vec3 magneticField(vec3 pp,vec3 mp,vec3 pos,float magne){
    vec3 moment = (pp - mp) * magne;
    vec3 r = pos - ((pp + mp) * 0.5);
    float len_r = dot(r,r);

    //1/r^3の項は省いている
    return moment - 3.0 * (dot(moment,r)) * r / len_r;
}

void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;


    // float z = 1;
    // uv =  gl_FragCoord.xy / resolution.xy;
    // uv = uv * 2.0 - 1.0;

    // vec3 ro = vec3(uv * 3.0,0.0);
    // vec3 rd = normalize(vec3(uv,z) - ro);
    // float dt = 0.02;
    // vec3 velocity = rd * 1.0;

    // ro += rd * hash12(uv) * 0.01;
    // vec2 shoot_uv;
    // bool hit = false;

    // vec3 magne_p = easeHash31(b_beat.w,b_beat.y,20.0) * 2.0 - 1.0 + vec3(sin(time),cos(time),0.0) * 0.5;
    // vec3 magne_m = easeHash31(b_beat.w + 100.0,b_beat.y,20.0) * 2.0 - 1.0 + vec3(sin(time),cos(time),0.0) * 0.5; 
    // float magne_power = easeHash31(b_beat.w + 50.0,b_beat.y,20.0).y * 1.2;

    // for(int i = 0; i < 400; i++){
    //     ro += velocity * dt;
    //     if(ro.z > z){
    //         shoot_uv = ro.xy;
    //         hit = true;
    //         break;
    //     }

    //     vec3 B = magneticField(vec3(magne_p.xy,magne_p.z - 1.0),vec3(magne_m.xy,magne_m.z - 1.0),ro,magne_power);
    //     vec3 Lorentz_force = cross(velocity,B);
    //     velocity += Lorentz_force * dt;
    // }

    //         // shoot_uv = ro.xy;
    // shoot_uv = ro.xy;

    // shoot_uv = (shoot_uv + 1.0) * 0.5;

    // texuv = mod(shoot_uv,1.0);
    
    vec4 color = texture(vertex,texuv);

    if(ToggleB(Scene1Button.w)){
        color = texture(scene1,texuv);
    }

    if(ToggleB(Raytracing_Button.w)){
        vec4 accumu = texture(accumulate_layer,texuv);
        accumu.xyz /= accumu.a;
        color = accumu;
    }

    //color = texture(NDI_0,texuv);
    //float p = NoiseSlider;
    //color =  (p < hash13(vec3(time,uv))) ? vec4(hash13(vec3(uv,time))) : color;
    
    color = texture(logo_layer,gl_FragCoord.xy / resolution.xy);
    // color = texture(tv_layer,texuv);     
    vec2 dxy = 1.0/resolution.xy;
    
    if(ToggleB(buttons[18].w) && ToggleB(b_beat.w)){
        float d1,d2;
        vec2 idx;
        ManhattanVoronoi2D(vec2(uv * 5.0 + floor(time) * 10.0),d1,d2,idx);
        vec2 velo = hash22(idx + vec2(100.0)) * 2.0 -1.0;
        ivec2 velo_int = ivec2(velo * sliders[12] * (100.0 + b_beat.y)  );

        texuv = gl_FragCoord.xy / resolution.xy;
        color = texture(combine_layer,mod(texuv + vec2(velo_int * dxy),1.0));
    }

    // if(!hit) color = vec4(hash12(uv + time)) * 0.0;
    color = texture(tv_layer,gl_FragCoord.xy / resolution.xy);
    Out_color = color;
}