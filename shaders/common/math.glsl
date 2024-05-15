#pragma include "./shaders/common/constant.glsl"

#define saturate(x) clamp(x,0.0,1.0)

#define repeat(x,a) mod(x,a) - a * 0.5;

#define stepFunc(x,a) floor(x / a) * a
mat2 rot(float a){
    return mat2(cos(a),-sin(a),sin(a),cos(a));
}

//Rotate
vec2 rotate(vec2 v, float a) {
    float s = sin(a);
    float c = cos(a);
    mat2 m = mat2(c, -s, s, c);
    return m * v;
}


vec2 pmod(vec2 p, float r)
{
    float a = atan(p.x, p.y) + PI / r;
    // "+ pi / r" means shortcut of "+ ((pi2 / r) * 0.5)".
    // so we want to get half angles of circle splitted by r.

    float n = TAU / r;
    a = floor(a / n) * n;
    // floor(a / n) means calculating ID.

    return p * rot(-a);
}

//https://iquilezles.org/articles/smin/
vec2 smoothMin(float a, float b, float k){
    float h = 1.0 - min( abs(a-b)/(6.0*k), 1.0 );
    float w = h*h*h;
    float m = w*0.5;
    float s = w*k; 
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}

vec2 kaleido_pmod(vec2 p, float r)
{
    float a = atan(-p.x, -p.y) + PI;

    float n = TAU / r;
    float ID = floor(a / n);

    p.x *= (int(ID) % 2 == 0) ? 1.0 : -1.0;
    float b = atan(-p.x, -p.y) + PI;
    ID = floor(b/n);
    b = ID*n;

    return rotate(p,-b);
}