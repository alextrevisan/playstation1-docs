// Jum's pad.h
// 16-bit #defines for aggregate of pad[2] and pad[3]
// ie: (~padBuf1[2] << 8) |  (~padBuf1[3])

#define PAD_Up		0x1000
#define PAD_Down	0x4000
#define PAD_Left	0x8000
#define PAD_Right	0x2000
#define PAD_X		0x0040
#define PAD_Sqr		0x0080
#define PAD_Tri		0x0010
#define PAD_O		0x0020
#define PAD_L1      0x0004
#define PAD_L2      0x0001
#define PAD_R1      0x0008
#define PAD_R2      0x0002
#define PAD_Start   0x0800
#define PAD_Select  0x0100
