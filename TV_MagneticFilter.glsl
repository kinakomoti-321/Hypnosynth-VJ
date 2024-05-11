#version 330

out vec4 color;

#pragma include "./common/uniforms.glsl"
#pragma include "./common/sdf.glsl"
#pragma include "./common/hash.glsl"
#pragma include "./common/easing.glsl"

uniform sampler2D NDI_test;

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
    vec3 col = vec3(uv,0.0);

    float z = 1;
    uv =  gl_FragCoord.xy / resolution.xy;
    uv = uv * 2.0 - 1.0;

    vec3 ro = vec3(uv * 3.0,0.0);
    vec3 rd = normalize(vec3(uv,z) - ro);
    float dt = 0.02;
    vec3 velocity = rd * 1.0;

    ro += rd * hash12(uv) * 0.01;
    vec2 shoot_uv;
    bool hit = false;

    vec3 magne_p = easeHash31(b_beat.w,b_beat.y,20.0) * 2.0 - 1.0;
    vec3 magne_m = easeHash31(b_beat.w + 100.0,b_beat.y,20.0) * 2.0 - 1.0;
    float magne_power = easeHash31(b_beat.w + 50.0,b_beat.y,20.0).y * 1.2;

    for(int i = 0; i < 400; i++){
        ro += velocity * dt;
        if(ro.z > z){
            shoot_uv = ro.xy;
            hit = true;
            break;
        }

        vec3 B = magneticField(vec3(magne_p.xy,magne_p.z - 1.0),vec3(magne_m.xy,magne_m.z - 1.0),ro,magne_power);
        vec3 Lorentz_force = cross(velocity,B);
        velocity += Lorentz_force * dt;
    }

    shoot_uv = (shoot_uv + 1.0) * 0.5;
    col = texture(NDI_test,mod(shoot_uv,1.0)).xyz;
    if(!hit) col = vec3(0.0);
    // col = vec3(shoot_uv,0.0);
    color = vec4(col,1.0);
}
