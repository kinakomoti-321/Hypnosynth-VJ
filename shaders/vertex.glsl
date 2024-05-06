#version 330

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"

uniform int vertex_count;

out vec4 v_color;

uniform sampler2D VAT_test;

uniform vec4 VAT_test_res;

float ConvertBinaryToFloat(vec4 binary_col){
    uint b1 = uint(binary_col.r * 255.0);
    uint b2 = uint(binary_col.g * 255.0);
    uint b3 = uint(binary_col.b * 255.0);
    uint b4 = uint(binary_col.a * 255.0);

    uint f = uint(0);
    f |= b1;
    f |= b2 << 8;
    f |= b3 << 16;
    f |= b4 << 24;

    return  uintBitsToFloat(f);
}
vec3 GetVATPosition(uint vertID){
    uint width = uint(VAT_test_res.x);
    uint height = uint(VAT_test_res.y);
    vertID *= uint(4);

    uvec2 id_vec = uvec2(vertID % width, vertID / width);
    vec2 texUV;
    texUV.x = (float(id_vec.x)) / (float(width));
    texUV.y = (float(id_vec.y)) / (float(height));

    vec2 uvOffset;
    uvOffset.x = float(id_vec.x) / float(width);
    uvOffset.y = 0.0; 

    vec4 binary_col_x = texture(VAT_test,texUV);
    vec4 binary_col_y = texture(VAT_test,texUV + uvOffset);
    vec4 binary_col_z = texture(VAT_test,texUV + uvOffset * 2);
    float x = ConvertBinaryToFloat(binary_col_x); 
    float y = ConvertBinaryToFloat(binary_col_y); 
    float z = ConvertBinaryToFloat(binary_col_z); 

    vec3 position = vec3(x,y,z); 
    return position;
}

void main() {
    float factor = float(gl_VertexID) / vertex_count;
    float far_clip = 1.0;

    vec3 test = hash31(float(gl_VertexID));

    float x = (test.x < 0.5) ? -1 : 1;
    float y = (test.y < 0.5) ? -1 : 1;
    float z = (test.z < 0.5) ? -1 : 1;

    int maxVertID =  int(time);
    int VertID = (gl_VertexID < maxVertID) ? gl_VertexID : maxVertID ;

    vec3 p =GetVATPosition(uint(VertID)) * 0.2;
    p.xz = rotate(p.xz,time);


    vec3 proj_p = vec3(p.xy,p.z/far_clip);
    proj_p.xy *= (1.0 - proj_p.z);
    gl_Position = vec4(proj_p, 1.0);


    vec3 col = vec3(1.0);
    v_color = vec4(col,1.0);
}
