#pragma once

uniform vec4 resolution;
uniform float time;

uniform float sliders[32];
uniform vec4 buttons[32];

#define b_beat buttons[0]
#define Raytracing_Button buttons[9]
#define Vertex_Button buttons[3]

//Logo Layer
#define LogoSlider sliders[2]
#define LogoButton1 buttons[4]

// #define Raytracing_Button buttons[]

//TV_Layer
#define NoiseSlider sliders[14]

//TV Filter

//PostProcess
#define AbsorbSlider sliders[15]
#define Laplacian_Button buttons[21]
#define FakePixelFilter_Button buttons[22]
//#define ParupunteFilter_Button button[23] //Dengerous
#define PixelFluid_Button buttons[23]