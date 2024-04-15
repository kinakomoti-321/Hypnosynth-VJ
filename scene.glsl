#version 140

out vec4 color;

#pragma include "./commons/common.glsl"

void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec3 col = vec3(uv,1.0);
    color = vec4(col,1.0);
}
