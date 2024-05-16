#pragma once

uniform vec4 resolution;
uniform float time;

uniform float sliders[32];
uniform vec4 buttons[32];

#define b_beat buttons[0]
#define Vertex_Button buttons[3]

//Logo Layer
#define LogoSlider sliders[2]
#define LogoButton buttons[3]

// #define Raytracing_Button buttons[]

#define Raytracing_Button buttons[9]
#define Raytracing_IndexOffset buttons[10]
#define Raytracing_IBL buttons[11]

#define Raytracing_SceneSlider sliders[6]
#define Raytracing_Slider sliders[7]

//TV_Layer
#define TV_StartButton buttons[12]
#define TV_SceneChange buttons[13]
#define TV_MoveButton buttons[14]

#define TV_FOVSlider sliders[8]

#define NoiseSlider sliders[13]

//Scene1
#define SceneButton buttons[6]


#define PixelFluid_Button buttons[18]
#define GlassFilter_Button buttons[19]
#define MFButton buttons[20]

//PostProcess
#define AbsorbSlider sliders[15]
#define Laplacian_Button buttons[21]
#define ParupunteFilter_Button button[22] //Dengerous
#define FakePixelFilter_Button buttons[23]
//#define ParupunteFilter_Button button[23] //Dengerous
