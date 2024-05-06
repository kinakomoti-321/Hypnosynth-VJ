
#define Toggle(a) float(int(a) % 2)
#define ToggleB(a) bool(int(a) % 2)


float smoothlerp(float z,float f){
    float fac = powEase(f,10);
    return mix(z,z+1,clamp(fac,0.0,1.0));
}

vec2 offsetCurl(vec2 uv,float power){
    return curlNoise2D(uv) * power;
}
