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