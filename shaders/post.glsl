#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"


uniform sampler2D tex;
uniform sampler2D celler;

out vec4 color;
uniform vec3 tint;

void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;
    // vec3 col = texture(tex, uv).xyz;
    vec3 col = texture(tex, texuv).xyz;

    //col = mix(col, 1.0 - col,float(int(buttons[1].w) % 2));
    vec2 curl = curlNoise2D(uv * 5.0);
    //col = texture(tex, texuv + curl *  buttons[1].x * sliders[1]).xyz;
    if(bool(Toggle(buttons[24].w))){
        float gridsize = 500.0 * (1.0 - sliders[10]);
        vec2 deg_texuv = floor(gridsize * texuv) / gridsize;
        vec2 grid_uv = fract(gridsize * texuv);
        grid_uv = grid_uv * 2.0 - 1.0;
        grid_uv +=  0.5* (hash22(deg_texuv) * 2.0 - 1.0);

        col = texture(tex, deg_texuv).xyz;
        // col = vec3(grid_uv,0.0);
        if(length(grid_uv) > 0.5){
            col = vec3(0.0);
        }
    }
    // vec2 texi = floor(texuv * gridsize);
    // vec2 texf = fract(texuv * gridsize);

    color = vec4(col,1.0);
}
