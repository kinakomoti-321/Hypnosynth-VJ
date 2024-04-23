#version 330

out vec4 color;

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"

uniform sampler2D tex;
uniform sampler2D PlotLogo;

#define BPM 150
#define Beat time * BPM / 60

void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 tuv = (gl_FragCoord.xy) / resolution.xy;

    vec3 col = vec3(0);

    if(sdBox(vec2(uv.x,uv.y),vec2(0.25)) < 0.0){
        col = vec3(1);
    }

    
    float beatTime = floor(time * 10.0 + 1.0);
    float beatTimef = fract(time * 10.0 + 1.0);
    vec2 logouv = tuv * 2.0 - 1.0;
    logouv *= 2.0;
    logouv += ((hash21(beatTime) * 2.0 - 1.0) * sliders[0]) * (beatTimef * 0.2 + 0.8);
    logouv = logouv * 0.5 + 0.5 ;
    //なんかいい感じ
    vec4 plogo = texture(PlotLogo,logouv+ offsetCurl((uv) * 5.0,0.5 * Toggle(buttons[1].w)));
    col = mix(col,plogo.xyz,plogo.w);
    // col = vec3(logouv,0.0);

    float offset = smoothlerp(buttons[0].w,buttons[0].y) + time;
    vec3 p = vec3(uv * 5 + offsetCurl((uv + beatTime) * 5.0,0.5 * Toggle(buttons[1].w)),offset * 1.0);
    col = vec3(cyclicNoise(p)) * 0.5;

    col = mix(col,vec3(1.0),plogo.w);

    color = vec4(col,1.0);
}
