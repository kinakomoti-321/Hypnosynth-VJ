#pragma once

uniform vec4 resolution;
uniform float time;

uniform float sliders[32];
uniform vec4 buttons[32];

#define b_beat buttons[0]
#define Raytracing_Button buttons[9]
#define Vertex_Button buttons[3]

#define Laplacian_Button buttons[21]
#define NoiseSlider sliders[14]
#define AbsorbSlider sliders[15]