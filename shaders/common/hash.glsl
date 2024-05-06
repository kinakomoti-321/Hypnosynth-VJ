//IntegerHash by IQ
//https://www.shadertoy.com/view/XlXcW4
//https://www.shadertoy.com/view/4tXyWN


#define C_HASH 2309480282U 

float hash11( float p )
{
    uint x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x);
    x = C_HASH * ((x>>8U)^x);
    x = C_HASH * ((x>>8U)^x);
    
    return float(x)*(1.0/float(0xffffffffU));
}

vec2 hash21( float p )
{
    uvec2 x = floatBitsToUint(vec2(p,230));
    x = C_HASH * ((x>>8U)^x.yx);
    x = C_HASH * ((x>>8U)^x.yx);
    x = C_HASH * ((x>>8U)^x.yx);
    
    return vec2(x)*(1.0/float(0xffffffffU));
}

vec3 hash31( float p )
{
    uvec3 x = floatBitsToUint(vec3(p,390,503));
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    
    return vec3(x)*(1.0/float(0xffffffffU));
}

vec4 hash41( float p )
{
    uvec4 x = floatBitsToUint(vec4(p,129,439,94593));
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    return vec4(x)*(1.0/float(0xffffffffU));
}


float hash12( vec2 p )
{
    uvec2 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yx);
    x = C_HASH * ((x>>8U)^x.yx);
    x = C_HASH * ((x>>8U)^x.yx);
    
    return float(x.x)*(1.0/float(0xffffffffU));
}

vec2 hash22( vec2 p )
{
    uvec2 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yx);
    x = C_HASH * ((x>>8U)^x.yx);
    x = C_HASH * ((x>>8U)^x.yx);
    
    return vec2(x)*(1.0/float(0xffffffffU));
}

vec3 hash32( vec2 p )
{
    uvec3 x = floatBitsToUint(vec3(p,129));
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    
    return vec3(x)*(1.0/float(0xffffffffU));
}

vec4 hash42( vec2 p )
{
    uvec4 x = floatBitsToUint(vec4(p,193,492));
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    return vec4(x)*(1.0/float(0xffffffffU));
}

float hash13(vec3 p){
    uvec3 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    
    return float(x.x)*(1.0/float(0xffffffffU));
}

vec2 hash23(vec3 p){
    uvec3 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    
    return vec2(x.xy)*(1.0/float(0xffffffffU));
}

vec3 hash33( vec3 p )
{
    uvec3 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    x = C_HASH * ((x>>8U)^x.yzx);
    
    return vec3(x)*(1.0/float(0xffffffffU));
}

vec4 hash43( vec3 p )
{
    uvec4 x = floatBitsToUint(vec4(p,1930));
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    return vec4(x)*(1.0/float(0xffffffffU));
}

float hash14( vec4 p )
{
    uvec4 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    return float(x.x)*(1.0/float(0xffffffffU));
}

vec2 hash24( vec4 p )
{
    uvec4 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    return vec2(x.xy)*(1.0/float(0xffffffffU));
}

vec3 hash34( vec4 p )
{
    uvec4 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    return vec3(x.xyz)*(1.0/float(0xffffffffU));
}

vec4 hash44( vec4 p )
{
    uvec4 x = floatBitsToUint(p);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    x = C_HASH * ((x>>8U)^x.yzwx);
    return vec4(x)*(1.0/float(0xffffffffU));
}


#define RangeHash11(x,a,b) mix(a,b,hash11(x))