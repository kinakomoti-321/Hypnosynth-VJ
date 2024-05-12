float gaussDist(float r, float sigma){
    float sigma2 = sigma * sigma;
    return exp(-0.5* r * r / sigma2);
}

vec3 gaussian_blur(sampler2D tex,vec2 uv,vec2 uv_offset,float sigma){
    vec3 sum = vec3(0);
    for(int i = -15; i < 15; i++){
       sum += texture(tex,uv +uv_offset*i).xyz * gaussDist(float(abs(i)),sigma); 
    }
    return sum / 30.0;
}


vec3 Laplacian_filter(sampler2D tex,vec2 uv,vec2 uv_offset){
    vec3 sum = vec3(0);
    float offsetx = uv_offset.x;
    float offsety = uv_offset.y;
    for(int i = -1; i < 2; i++){
        for(int j = -1; j < 2; j++){
            vec2 offsets = vec2(offsetx * j,offsety * i);
            int index = i * 3 + j;
            float weight = (index == 4) ? -8.0 : 1.0;
            sum += texture(tex,uv + offsets).xyz * weight; 
        }
    }
    return sum;
}


vec3 magneticField(vec3 pp,vec3 mp,vec3 pos,float magne){
    vec3 moment = (pp - mp) * magne;
    vec3 r = pos - ((pp + mp) * 0.5);
    float len_r = dot(r,r);

    //1/r^3の項は省いている
    return moment - 3.0 * (dot(moment,r)) * r / len_r;
}

vec2 MagneticFilter(vec2 uv){
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

    vec3 magne_p = easeHash31(b_beat.w,b_beat.y,20.0) * 2.0 - 1.0 + vec3(sin(time),cos(time),0.0) * 0.5;
    vec3 magne_m = easeHash31(b_beat.w + 100.0,b_beat.y,20.0) * 2.0 - 1.0 + vec3(sin(time),cos(time),0.0) * 0.5; 
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

            // shoot_uv = ro.xy;
    shoot_uv = ro.xy;

    shoot_uv = (shoot_uv + 1.0) * 0.5;

    return shoot_uv;
    //MagneticFilter----------------------------------------
}