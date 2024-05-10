#define Toggle(a) float(int(a) % 2)
#define ToggleB(a) bool(int(a) % 2)


float smoothlerp(float z,float f){
    float fac = powEase(f,10);
    return mix(z,z+1,clamp(fac,0.0,1.0));
}

vec2 offsetCurl(vec2 uv,float power){
    return curlNoise2D(uv) * power;
}

float beat(float t, float e){
    float s = sin(t * PI * 2.0 / e);
    return pow(s * s,8.0);
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

vec3 GetCameraDir(vec3 camera_ori,vec3 at_look, vec2 uv ,float Fov,float DOF,vec2 xi)
{
    vec3 camera_dir = normalize(at_look - camera_ori);
    float f = 1.0 / atan(Fov * TAU / 360.0f);

    vec3 tangent,binormal;
    tangentSpaceBasis(camera_dir,tangent,binormal);
    vec2 jitter = (xi*2.0 - 1.0) * DOF;
    camera_dir = normalize(camera_dir * f + (uv.x + jitter.x) * tangent + (uv.y + jitter.y) * binormal );
    return camera_dir;
}
