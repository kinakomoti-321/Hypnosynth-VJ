
#define FontWidth 8
#define FontHeight 8
#define LineMaxLength 40


ivec2 font_data[94] = ivec2[](
    //0
    ivec2(0x00000000,0x00000000), //space

    //1~10
    ivec2(0x7e91897e,0x00000000), //0
    ivec2(0x01ff4121,0x00000000), //1
    ivec2(0x71898543,0x00000000), //2
    ivec2(0x6e919142,0x00000000), //3
    ivec2(0x08ff4838,0x00000000), //4
    ivec2(0x8e9191f2,0x00000000), //5
    ivec2(0x0e91916e,0x00000000), //6
    ivec2(0xc0b08f80,0x00000000), //7
    ivec2(0x6e91916e,0x00000000), //8
    ivec2(0x6e919162,0x00000000), //9

    //11~36
    ivec2(0x1e11110e,0x00000001), //a
    ivec2(0x0e11117f,0x00000000), //b
    ivec2(0x0a11110e,0x00000000), //c
    ivec2(0x7f11110e,0x00000000), //d
    ivec2(0x0815150e,0x00000000), //e
    ivec2(0x48483f08,0x00000000), //f
    ivec2(0x3e494930,0x00000000), //g
    ivec2(0x0708087f,0x00000000), //h
    ivec2(0x012f0900,0x00000000), //i
    ivec2(0x5e111102,0x00000000), //j
    ivec2(0x000b047f,0x00000000), //k
    ivec2(0x017f4100,0x00000000), //l
    ivec2(0x0807080f,0x00000007), //m
    ivec2(0x0708080f,0x00000000), //n
    ivec2(0x06090906,0x00000000), //o
    ivec2(0x1824243f,0x00000000), //p
    ivec2(0x3f242418,0x00000000), //q
    ivec2(0x0010081f,0x00000000), //r
    ivec2(0x0012150d,0x00000000), //s
    ivec2(0x11113e10,0x00000000), //t
    ivec2(0x0f01010e,0x00000000), //u
    ivec2(0x000e010e,0x00000000), //v
    ivec2(0x010e010e,0x0000000f), //w
    ivec2(0x0a040a11,0x00000011), //x
    ivec2(0x3e090930,0x00000000), //y
    ivec2(0x00191513,0x00000000), //z

    //36~63
    ivec2(0x7f88887f,0x00000000), //A
    ivec2(0x6e9191ff,0x00000000), //B
    ivec2(0x4281817e,0x00000000), //C
    ivec2(0x7e8181ff,0x00000000), //D
    ivec2(0x919191ff,0x00000000), //E
    ivec2(0x909090ff,0x00000000), //F
    ivec2(0x4685817e,0x00000000), //G
    ivec2(0xff1010ff,0x00000000), //H
    ivec2(0x0081ff81,0x00000000), //I
    ivec2(0x80fe8182,0x00000000), //J
    ivec2(0x413608ff,0x00000000), //K
    ivec2(0x010101ff,0x00000000), //L
    ivec2(0x601060ff,0x000000ff), //M
    ivec2(0x0c1060ff,0x000000ff), //N
    ivec2(0x7e81817e,0x00000000), //O
    ivec2(0x609090ff,0x00000000), //P
    ivec2(0x7f83817e,0x00000001), //Q
    ivec2(0x619698ff,0x00000000), //R
    ivec2(0x4e919162,0x00000000), //S
    ivec2(0x80ff8080,0x00000080), //T
    ivec2(0xfe0101fe,0x00000000), //U
    ivec2(0x0e010ef0,0x000000f0), //V
    ivec2(0x031c03fc,0x000000fc), //W
    ivec2(0x340834c3,0x000000c3), //X
    ivec2(0x300f30c0,0x000000c0), //Y
    ivec2(0xe1918d83,0x00000081), //Z

    //63~
    ivec2(0x00007d00,0x00000000), //!
    ivec2(0x60006000,0x00000000), //"
    ivec2(0x3f123f12,0x00000012), //#
    ivec2(0x52ff5224,0x0000000c), //$
    ivec2(0x33086661,0x00000043), //%
    ivec2(0x374d5926,0x00000001), //&
    ivec2(0x00006000,0x00000000), //'
    ivec2(0x0081423c,0x00000000), //(
    ivec2(0x003c4281,0x00000000), //)
    ivec2(0x00143814,0x00000000), //*
    ivec2(0x00103810,0x00000000), //+
    ivec2(0x00020100,0x00000000), //,
    ivec2(0x08080808,0x00000000), //-
    ivec2(0x00000100,0x00000000), //.
    ivec2(0x30080601,0x00000040), ///
    ivec2(0x00240000,0x00000000), //:
    ivec2(0x00240200,0x00000000), //;
    ivec2(0x41221408,0x00000000), //<
    ivec2(0x00141414,0x00000000), //=
    ivec2(0x08142241,0x00000000), //>
    ivec2(0xa999423c,0x0000007c), //@
    ivec2(0x008181ff,0x00000000), //[
    ivec2(0x06083040,0x00000001), //\
    ivec2(0x00000000,0x00000000), //] 何故か表示されない
    ivec2(0x00ff8181,0x00000000), //]
    ivec2(0x20402010,0x00000010), //^
    ivec2(0x01010101,0x00000000), //_
    ivec2(0x40408080,0x00000000), //`
    ivec2(0x41413608,0x00000000), //{
    ivec2(0x00ff0000,0x00000000), //|
    ivec2(0x08364141,0x00000000), //}
    ivec2(0x08101008,0x00000010) //~

);

vec3 font(vec2 uv,int id){
    vec2 uv1 = uv;
    uv = uv * 8.0;
    ivec2 texel = ivec2(uv);
    int bit_offset = texel.x * FontWidth + texel.y;

    int s,t;
    s = font_data[id].x;
    t = font_data[id].y;

    int tex = 0;
    
    if(bit_offset <= 31){
        s = s >> bit_offset;
        s = s & 0x00000001;
        tex = s;
    }
    else{
        t = t >> (bit_offset - 32);
        t = t & 0x00000001;
        tex = t;
    }

    tex = (abs(uv1.x - 0.5) < 0.5 && abs(uv1.y - 0.5) < 0.5) ? tex : 0;
    return vec3(tex); 
}

// vec3 channel(vec2 uv, int i){
     
// }

vec3 CharAndNumber(vec2 text_uv,in int chars[8],int number){
    text_uv *= 20.0;

    float width_font = 0.65;
    int offset = int(text_uv.x / width_font);
    int line = int(text_uv.y / 1.1);
    text_uv = mod(text_uv,vec2(width_font,1.1));

    int font_index = 0;
    if(offset < 8){
        font_index = chars[offset];
    }
    else if(offset == 8){
        font_index = 78;
    }
    else if(offset <= 11 && offset > 8){
        int number_offset = 11 - offset;
        int pows = (number / int(pow(10.0,float(number_offset)))) % 10;   
        font_index = pows + 1;
    }

    if(RedModeON) font_index = 63;

    vec3 col = font(text_uv,font_index);

    // col = vec3(float(line) / 10.0);
    
    //col = vec3(text_uv,1.0);

    if(line != 5) col = vec3(0.0);
    if(offset < 0 || offset > 12) col = vec3(0.0);
    return col;
}
