#version 330

out vec4 color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"


uniform sampler2D celler;
void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec4 prevTex = texture(celler,tuv);

    int Frame = int(prevTex.w);
    vec3 col = prevTex.xyz;
    if(prevTex.w < 1.0){
        Frame = 0;
        if(gl_FragCoord.x >= 99.0 && gl_FragCoord.x <= 100.0 && gl_FragCoord.y >= 99.0 && gl_FragCoord.y <= 100.0){
            col = vec3(1.0);
        }
    }

    vec2 uv_offset = 1.0 / resolution.xy;
    vec4 c1 = texture(celler,tuv + vec2(-1.0,0.0) * uv_offset);
    vec4 c2 = texture(celler,tuv + vec2(1.0,0.0) * uv_offset);
    vec4 c3 = texture(celler,tuv + vec2(0.0,1.0) * uv_offset);
    vec4 c4 = texture(celler,tuv + vec2(0.0,-1.0) * uv_offset);

    if(c1.x > 0.0 ||c2.x > 0.0 ||c3.x > 0.0 ||c4.x > 0.0){
        col = vec3(1.0);
    }



    Frame += 1;


    color = vec4(col, float(Frame));
}
