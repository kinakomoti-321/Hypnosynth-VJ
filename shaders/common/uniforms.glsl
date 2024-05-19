#pragma once

uniform vec4 resolution;
uniform float time;

uniform float sliders[32];
uniform vec4 buttons[32];

#define b_beat buttons[0]
#define Vertex_Button buttons[3]

#define RedMode buttons[1]
#define RedModeON ToggleB(RedMode.w)&&(int(b_beat.w) % 4 == 0)

//Logo Layer
#define LogoSlider sliders[2]
#define LogoButton buttons[3]
#define UI_Button buttons[4]
#define Logo_MaskButton buttons[5]

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

#define ScreenRandamize buttons[15]
#define ScreenUVchange buttons[17]
#define TV_FOVSlider sliders[8]
#define ScreenOffsetSlider sliders[10]
#define ScreenPaternSlider sliders[11]

#define NoiseSlider 1.0 - sliders[13]

//Scene1
#define SceneButton buttons[6]
#define SceneCircuit buttons[7]


#define PixelFluid_Button buttons[18]
#define GlassFilter_Button buttons[19]
#define MFButton buttons[20]


//PostProcess
// #define AbsorbSlider sliders[15]
#define Global_slider sliders[15]
#define Laplacian_Button buttons[21]
#define ParupunteFilter_Button button[22] //Dengerous
#define FakePixelFilter_Button buttons[23]
//#define ParupunteFilter_Button button[23] //Dengerous
