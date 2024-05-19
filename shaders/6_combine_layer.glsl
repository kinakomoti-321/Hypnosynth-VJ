#version 440

#pragma include "./shaders/common/uniforms.glsl"
#pragma include "./shaders/common/hash.glsl"
#pragma include "./shaders/common/noise.glsl"
#pragma include "./shaders/common/math.glsl"
#pragma include "./shaders/common/sdf.glsl"
#pragma include "./shaders/common/easing.glsl"
#pragma include "./shaders/common/benri.glsl"
#pragma include "./shaders/common/filter.glsl"

uniform sampler2D raytracing;
uniform sampler2D accumulate_layer;
uniform sampler2D scene1;
uniform sampler2D logo_layer;
uniform sampler2D vertex;
uniform sampler2D tv_layer;

uniform sampler2D ColorBar;

uniform sampler2D combine_layer;

uniform sampler2D NDI_0;
uniform sampler2D NDI_1;

out vec4 Out_color;

#define Scene1Button buttons[3]


void main() {
    vec2 uv =  (gl_FragCoord.xy - resolution.xy * 0.5) / resolution.y;
    vec2 texuv = gl_FragCoord.xy / resolution.xy;

    //MagneticFilter----------------------------------------
    if(ToggleB(MFButton.w)){
        vec2 shoot_uv = MagneticFilter(uv); 
        texuv = mod(shoot_uv,1.0);
    }
    //MagneticFilter----------------------------------------

    vec4 color = texture(vertex,texuv);
    
    if(ToggleB(SceneButton.w)){
        color = texture(scene1,texuv);
    }

    if(ToggleB(Raytracing_Button.w)){
        color = texture(accumulate_layer,texuv);
        color /= color.a;
        color *=1.5;
    }

    if(ColorBarON){
        color = texture(ColorBar,texuv);
    }
    if(ToggleB(Logo_MaskButton.w)){
        vec4 color_logo = texture(logo_layer,texuv);
        color = mix(color,color_logo,vec4(color_logo.a));
    }

    vec2 dxy = 1.0/resolution.xy;
    //Pixel Fluid 
    if(ToggleB(PixelFluid_Button.w) && ToggleB(b_beat.w)){
        float d1,d2;
        vec2 idx;
        ManhattanVoronoi2D(vec2(uv * 5.0 + floor(time) * 10.0),d1,d2,idx);
        vec2 velo = hash22(idx + vec2(100.0)) * 2.0 -1.0;
        ivec2 velo_int = ivec2(velo * sliders[12] * (100.0 + b_beat.y)  );

        texuv = gl_FragCoord.xy / resolution.xy;
        color = texture(combine_layer,mod(texuv + vec2(velo_int * dxy),1.0));
    }

    if(RedModeON){
        color.rgb *= vec3(1.0,0.1,0.1);
    }
    Out_color = color;
}