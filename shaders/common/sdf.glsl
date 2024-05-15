//SDFs
//https://iquilezles.org/articles/distfunctions/

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdLink( vec3 p, float le, float r1, float r2 )
{
  vec3 q = vec3( p.x, max(abs(p.y)-le,0.0), p.z );
  return length(vec2(length(q.xy)-r1,q.z)) - r2;
}

float sdPlane( vec3 p, vec3 n, float h )
{
  return dot(p,n) + h;
}



float dMenger(vec3 z0,vec3 beta,vec3 offset, float scale){
    vec4 z = vec4(z0,1.0);
    z.xyz = mod(z.xyz,beta.y) - beta.y/2.0 ;
    z.xy = pmod(z.xy,beta.z);
    for(int n = 0; n < 4; n ++){
        z = abs(z);

        if(z.x < z.y) z.xy = z.yx;
        if(z.x < z.z) z.xz = z.zx;
        if(z.y < z.z) z.yz = z.zy;

        z *= scale;
        z.xyz -= offset * (scale - 1.0);
        if(z.z < -0.5 * offset.z * (scale - 1.0)) z.z += offset.z * (scale -1.0);
    }
    return (length(max(abs(z.xyz)-vec3(1.0,1.0,1.0),0.0)) - 0.05) / z.w;
}


//2D SDF
//https://iquilezles.org/articles/distfunctions2d/
float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

//SDF Operator
//https://iquilezles.org/articles/distfunctions/
float opUnion( float d1, float d2 )
{
    return min(d1,d2);
}
float opSubtraction( float d1, float d2 )
{
    return max(-d1,d2);
}
float opIntersection( float d1, float d2 )
{
    return max(d1,d2);
}
float opXor(float d1, float d2 )
{
    return max(min(d1,d2),-max(d1,d2));
}