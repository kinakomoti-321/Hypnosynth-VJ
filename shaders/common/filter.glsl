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