
mat2 rot(float a){
    return mat2(cos(a),-sin(a),sin(a),cos(a));
}

//https://iquilezles.org/articles/smin/
vec2 smoothMin(float a, float b, float k){
    float h = 1.0 - min( abs(a-b)/(6.0*k), 1.0 );
    float w = h*h*h;
    float m = w*0.5;
    float s = w*k; 
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}