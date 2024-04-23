#version 330

out vec4 color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"

uniform sampler2D tex;

void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec3 col = vec3(0);

    if(sdBox(vec2(uv.x,uv.y),vec2(0.25)) < 0.0){
        col = vec3(1);
    }

    // vec4 tex = texture(tex,tuv);
    //color = vec4(col + tex.xyz * 0.8,1.0);
    float offset = buttons[0].x;
    vec3 p = vec3(uv * 5,offset);
    col = vec3(cyclicNoise(p));
    
    color = vec4(col,1.0);
}
