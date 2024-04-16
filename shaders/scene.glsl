#version 330

out vec4 color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"

void main() {
    vec2 uv = (gl_FragCoord.xy) / resolution.xy;

    ivec2 idx = ivec2(floor(uv * 1000.0));
    int id = idx.x * 1000 + idx.y;
    vec3 col = vec3(uv,0);

    col = hash31(float(id));


    
    color = vec4(col,1.0);
}
