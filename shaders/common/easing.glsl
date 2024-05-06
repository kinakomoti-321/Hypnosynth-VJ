float powEase(float x,float n){
    return 1.0 - pow(1.0 - clamp(x,0.0,1.0),n);
}

vec3 easeHash31(float idx,float x,float n){
    vec3 prePos = hash31(idx - 1.0);
    vec3 nowPos = hash31(idx);

    return mix(prePos,nowPos,vec3(powEase(x,n)));
}