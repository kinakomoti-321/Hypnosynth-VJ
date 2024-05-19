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

#define VertexRrandomSlider sliders[1]
#define VertexSceneSlider sliders[0]
//naosenakatta...
float ConvertBinaryToFloat(vec4 binary_col){
    uint b1 = uint(binary_col.r * 255.0 + 0.5);
    uint b2 = uint(binary_col.g * 255.0 + 0.5);
    uint b3 = uint(binary_col.b * 255.0 + 0.5);
    uint b4 = uint(binary_col.a * 255.0 + 0.5);

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
vec3 Sphere(float f){
    vec3 dir = vec3(0.0,1.0,0.0);
    dir.xy = rotate(dir.xy,f * PI * (7.0 +  mod(time * 0.0002 + hash11(b_beat.w),10.0)));
    dir.yz = rotate(dir.yz,f * PI * (4.0 + mod(time * 0.0001 + b_beat.w * 0.001,10.0)));

    return dir;
}


void main() {
    float factor = float(gl_VertexID) / vertex_count;

    vec3 test = hash31(float(gl_VertexID));

    float x = (test.x < 0.5) ? -1 : 1;
    float y = (test.y < 0.5) ? -1 : 1;
    float z = (test.z < 0.5) ? -1 : 1;

    int maxVertID =  int(100000);
    int VertID = (gl_VertexID < maxVertID) ? gl_VertexID : maxVertID ;

    vec3 rand = easeHash31(b_beat.w,b_beat.y,10);
    //vec3 p =GetVATPosition(uint(VertID)) * 0.1;
    // vec3 p = getBoxPosition(gl_VertexID) * 0.1;
    vec3 p = vec3(x,y,z) * 0.2;
    int Version = int(VertexSceneSlider * 3);
    if(Version == 1) p = Sphere(factor + time) * 0.3;
    float iTime = time;
    float randomness = stepFunc(VertexRrandomSlider,0.25) * 0.1;
    if(RedModeON){
        randomness = 1.0;
        iTime *= 10.0 *time;
    }
    p += randomness * (hash34(vec4(p,floor(iTime) + float(gl_VertexID))) * 2.0 - 1.0);
    p.xz = rotate(p.xz,rand.y * TAU * 1.5 + iTime * 0.1);
    p.yz = rotate(p.yz,rand.x * TAU * 1.5);

    float far_clip = 10.0 * rand.z;
    p.z -= rand.z;
    vec3 proj_p = vec3(p.xy,p.z/far_clip);
    proj_p.xy *= (1.0 - proj_p.z);
    gl_Position = vec4(proj_p, 1.0);


    vec3 col = vec3(1.0);
    v_color = vec4(col,1.0);
}
