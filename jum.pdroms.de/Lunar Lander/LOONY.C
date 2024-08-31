// James 1st Playstation game
// h-car
#include	<syscall.h>
#include	<psxtypes.h>
#include	<int.h>
#include	<gpu.h>
#include	<gte.h>
#include	<tmd.h>
#include "vector2d.h"
#include "loony.h"

#define NUM_STARS	10
#define OT_LENGTH	5

// z-sorting and primitive (packet) buffer stuff
static GsOT_TAG zSortTable[2][1<<OT_LENGTH];
static PACKET primbuf[2][3000];
static GsOT *ot;               // pntr to OT

// define primitives
static BOXFILL myBox;
static CILINE myLine;
static CITRI myTri, myTri2;
static QUAD bgQuad;
static TEXQUAD myTexQuad;
static VecObj ship;
static VecObj star;
static VecObj land;
static VecObj pad;
static VecObj flame;
static VecObj rock;
static VecObj vec_letter;
static VecPrim vprim[20];
static Fragment frag[20];
static PsxUInt16 star_x[50], star_y[50];
static PsxUInt8 surface[320];
static VecLetter Letter[64] = {
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	1,		1, 0, 0, 0, 0, 0, 0, 0,		7, 0, 0, 0, 0, 0, 0, 0,	// 1
	5,		0, 2, 4,10, 8, 0, 0, 0, 	2, 4,10, 8, 6, 0, 0, 0,	// 2
	4, 		0, 2, 6,10, 0, 0, 0, 0,		2, 6, 8, 4, 0, 0, 0, 0,	// 3
	3, 		0, 10,2, 0, 0, 0, 0, 0,		10,4, 6, 0, 0, 0, 0, 0,	// 4
	5,		2, 0,10, 4, 6, 0, 0, 0,		0,10, 4, 6, 8, 0, 0, 0,	// 5
	5,		2, 0, 8, 6, 4, 0, 0, 0,		0, 8, 6, 4,10, 0, 0, 0,	// 6
	2, 		0, 2, 0, 0, 0, 0, 0, 0,		2, 6, 0, 0, 0, 0, 0, 0,	// 7
	5,		0, 2, 6, 8, 4, 0, 0, 0,		2, 6, 8, 0,10, 0, 0, 0,	// 8
	4, 		6, 2, 0,10, 0, 0, 0, 0,		2, 0,10, 4, 0, 0, 0, 0,	// 9
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// 0
	5,		8,10, 1, 4, 4, 0, 0, 0,		10,1, 4, 6,10, 0, 0, 0,	// A
	8,		0,10, 8, 0, 1, 3, 9, 5,		8, 4, 6, 1, 3, 4, 5, 6,	// B
	3,		2, 0, 8, 0, 0, 0, 0, 0,		0, 8, 6, 0, 0, 0, 0, 0,	// C
	6,		0, 8, 7, 5, 3, 1, 0, 0,		8, 7, 5, 3, 1, 0, 0, 0,	// D
	4,		2, 0, 8, 9, 0, 0, 0, 0,		0, 8, 6,10, 0, 0, 0, 0,	// E
	3,		2, 0, 9, 0, 0, 0, 0, 0,		0, 8,10, 0, 0, 0, 0, 0,	// F
	5,		2, 0, 8, 6, 4, 0, 0, 0,		0, 8, 6, 4, 9, 0, 0, 0,	// G
	3,		0, 2, 4, 0, 0, 0, 0, 0,		8, 6,10, 0, 0, 0, 0, 0,	// H
	3,		0, 8, 1, 0, 0, 0, 0, 0,		2, 6, 7, 0, 0, 0, 0, 0,	// I
	3,		2, 6, 8, 0, 0, 0, 0, 0,		6, 8,10, 0, 0, 0, 0, 0,	// J
	4,		0,10, 9, 9, 0, 0, 0, 0,		8, 9, 2, 6, 0, 0, 0, 0,	// K
	2,		0, 8, 0, 0, 0, 0, 0, 0,		8, 6, 0, 0, 0, 0, 0, 0,	// L
	4,		8, 0, 9, 2, 0, 0, 0, 0,		0, 9, 2, 6, 0, 0, 0, 0,	// M
	3,		8, 0, 6, 0, 0, 0, 0, 0,		0, 6, 2, 0, 0, 0, 0, 0,	// N
	4,		0, 2, 6, 8, 0, 0, 0, 0,		2, 6, 8, 0, 0, 0, 0, 0,	// O
	4,		9, 0, 2, 4, 0, 0, 0, 0,		0, 2, 4,10, 0, 0, 0, 0,	// P
	6, 		0, 2, 4, 7, 8, 9, 0, 0,		2, 4, 7, 8, 0, 6, 0, 0,	// Q
	5,		8, 0, 2, 4, 9, 0, 0, 0,		0, 2, 4,10, 6, 0, 0, 0,	// R
	5,		2, 0,10, 4, 6, 0, 0, 0,		0,10, 4, 6, 8, 0, 0, 0,	// S
	2,		0, 1, 0, 0, 0, 0, 0, 0,		2, 7, 0, 0, 0, 0, 0, 0,	// T
	3,		0, 8, 6, 0, 0, 0, 0, 0,		8, 6, 2, 0, 0, 0, 0, 0,	// U
	4,		0,10, 7, 4, 0, 0, 0, 0,		10,7, 4, 2, 0, 0, 0, 0,	// V
	4,		0, 8, 9, 6, 0, 0, 0, 0,		8, 9, 6, 2, 0, 0, 0, 0,	// W
	2,		0, 8, 0, 0, 0, 0, 0, 0,		6, 2, 0, 0, 0, 0, 0, 0,	// X
	3,		0, 9, 9, 0, 0, 0, 0, 0,		9, 2, 7, 0, 0, 0, 0, 0,	// Y
	3,		0, 2, 8, 0, 0, 0, 0, 0,		2, 8, 6, 0, 0, 0, 0, 0, // Z
};

static int temp;
static int temp2;


// routine to upload TIM file to VRAM
static void UpLoadImage(TIMHEADER *timhdr) {
	TIMCLUT *clut;
	TIMIMAGE *image;


	// get components of image
	clut = GPU_TIMGetClut(timhdr);
	image = GPU_TIMGetImage(timhdr);

	// upload image to PSX VRAM
	if(clut) {
		GPU_LoadImageData(&clut->vRamPos, clut->clutData);
		printf("Uploaded clut data.");
	}
	if(image) {
		GPU_LoadImageData(&image->vRamPos, image->imageData);
		printf("Uploaded image data.");
	}
}

static void MakeVectorObjects(void);
static void DrawStars(void);
static void SetStar(int i);
static void MakeLand(void);
static void MakeExplosion(PsxInt16 dx, PsxInt16 dy);
void Vec_DrawObj(GsOT *pot, PsxUInt32 pos, VecObj *obj);
void Vec_DrawPrim(GsOT *pot, PsxUInt32 pos, VecPrim *prim);
void Vec_DrawLetter(GsOT *pot, PsxUInt32 pos, PsxUInt8 ascii, PsxUInt32 x, PsxUInt32 y, VecObj *obj);
void Vec_DrawLetterScale(GsOT *pot, PsxUInt32 pos, PsxUInt8 ascii, PsxUInt32 x, PsxUInt32 y, PsxInt16 scale, VecObj *obj);
void Vec_Print(GsOT *pot, PsxUInt32 pos, char *string, PsxUInt32 x, PsxUInt32 y, VecObj *obj);
void Vec_PrintScale(GsOT *pot, PsxUInt32 pos, char *string, PsxUInt32 x, PsxUInt32 y, PsxInt16 scale, PsxInt16 spacing, VecObj *obj);

int main(int argc,char **argv)
{

    int		i, j, k, level, gravity;
	SVECTOR2D	posn;
	PsxUInt32	dxrot, dyrot, dzrot, xrot, yrot, zrot;
	PsxInt16	dx, dy, drot;
	MATRIX		ltm, matrix;
	PsxInt16 	sine, cosine, scale;
	PsxInt16	dist;
	COLOR clr_color = 	{ 0, 0, 0, 0};
	// buffers for pad data
	volatile PsxUInt8 	padBuf1[34], padBuf2[34];
	PsxUInt8	p1, p2;
	PsxUInt8	thrust;
	PsxUInt8	exploded, landed;				// exploded, landed flags
	PsxUInt16	fuel;
	
	// ordering tables for both buffers
	GsOT    world_OT[2];
	PsxUInt32 current_buffer;

	//ResetCallBack();

	// pad stuff	(do we need this for vsync? (or other way round?))
	InitPAD(padBuf1, 34, padBuf2, 34);
	StartPAD();

	// install interrupt handler
	INT_SetUpHandler();

	k = 0;
	posn.x = 1; posn.y = 100;
	// set up CiLine
	myLine.color0.r = 255;
	myLine.color0.g = 0;
	myLine.color0.b = 0;
	myLine.vert0.x = 40; myLine.vert0.y = 230;
	myLine.color1.r = 0;
	myLine.color1.g = 255;
	myLine.color1.b = 0;
	myLine.vert1.x = 200; myLine.vert1.y = 230;

	// set up Box
	myBox.color.r = myBox.color.g = myBox.color.b = 33;
	myBox.pos.x = 10; myBox.pos.y = 10;
	myBox.size.x = 620; myBox.size.y = 220;


        // set up background quad
        bgQuad.color.r = 255;
        bgQuad.color.g = bgQuad.color.b = 25;
        bgQuad.vert0.x = bgQuad.vert1.x = 120;
        bgQuad.vert0.y = bgQuad.vert2.y = 110;
        bgQuad.vert2.x = bgQuad.vert3.x = 200;
        bgQuad.vert1.y = bgQuad.vert3.y = 130;


	// make vector object
	MakeVectorObjects();
	dx = 32;									// 1/2 pix per frame
	dy = 0;

	// bypass a lot of probably neccessary stuff
	// and do GPU init stuff
	GPU_SetPAL(1);								// 0 = NTSC, 1 = PAL
	GPU_Reset(0);		// cold reset ???
	GPU_Init(320, 240, GsNONINTER, 0);
	GPU_DefDispBuff(0, 0, 0, 240);		// was 0 0 0 240

	// Init GTE for 3D (matrices)
	GTE_Init(320, 240);

	// upload sprite data and wait till finished
	//UpLoadImage((TIMHEADER *)sprites);
	//GPU_DrawSync();

	// set up order table
    world_OT[0].length = OT_LENGTH;
    world_OT[0].org = zSortTable[0];
    world_OT[1].length = OT_LENGTH;
    world_OT[1].org = zSortTable[1];

	// enable display and wait for GPU
	GPU_EnableDisplay(1);
	GPU_DrawSync();	

	//************** TITLE SCREEN ***************
	// loop until START pressed
	j = 0; k = 0;
	flame.x = ship.x = 15500;
	padBuf1[2] = 0xFF;
    while((padBuf1[2] & 0x08)) {
		// Draw title screen
   		current_buffer = GPU_GetActiveBuff();
   		ot = &world_OT[current_buffer];
    	GPU_SetCmdWorkSpace(primbuf[current_buffer]);
    	GPU_ClearOt(0, 0, ot);

    	// set up clear and print 
    	GPU_SortClear(current_buffer, ot, &clr_color);
    	// print title in increasing brightness
    	if(j < 255) vec_letter.brightness = j++;
    	else Vec_PrintScale(ot, 2, "JUM HIG 1999", 104, 200, 2048, 10, &vec_letter);
    	
		Vec_PrintScale(ot, 4, "LANDER", 80, 240 - j/2, 8000, 32, &vec_letter);

		// Draw Lander
		flame.y = ship.y = k;
		if(k < 6196) {
			k += 16;
			Vec_DrawObj(ot, 3, &flame);
		}
		Vec_DrawObj(ot, 3, &ship);

		// Render this frame
    	GPU_DrawOt(ot);						// test
		GPU_DrawSync();
    	GPU_VSync();
    	GPU_FlipDisplay();
    }
    // wait for START key released
    while((~padBuf1[2] & 0x08));

    // set double gravity if X pressed when starting
    if(~padBuf1[3] & 0x40) gravity = 2;
    else gravity = 1;

	//********************** MAIN GAME LOOP **********************
    for(level=0; level < 20; level++) {
	j = 0; k = 0; dx = 64; dy = 0;
	exploded = 0; landed = 0;
	fuel = 500;
	ship.x = 1280; ship.y = 800;
	rock.y = 0xFFFFF000; rock.x = rand()%20000;
	vec_letter.brightness = 255;
	// make landscape
	MakeLand();
	// loop until START pressed
	padBuf1[2] = 0xFF;
	padBuf1[3] = 0xFF;
    while(!landed | (padBuf1[3] & 0x10)) {

    	thrust = 0;

    	// get pad to more useable form
    	p1 = ~padBuf1[2]; p2 = ~padBuf1[3];

    	// get dir. pad
    	drot = 0;
    	if(p1 & 0x80) drot = 64;
    	if(p1 & 0x20) drot = -64;

    	// get buttons
    	if(p2 & 0x40) thrust = 1;			// thrust on
    	if(p2 & 0x80) {
    		exploded = 1;			// explode ship
    		MakeExplosion(dx, dy);
    	}
    	
		// sort out GPU buffer stuff
    	current_buffer = GPU_GetActiveBuff();
    	ot = &world_OT[current_buffer];
        GPU_SetCmdWorkSpace(primbuf[current_buffer]);
        GPU_ClearOt(0, 0, ot);

		// draw background & line
        // set up clear 
        GPU_SortClear(current_buffer, ot, &clr_color);
        // draw fuel line
        myLine.vert1.x = 40 + (fuel >> 2);
		GPU_SortCiLine(ot, 4, &myLine);
		Vec_PrintScale(ot, 2, "FUEL", 4, 230, 2048, 9, &vec_letter);
		
		Vec_DrawObj(ot, 3, &land);

		// draw ship vector obj
		if(!exploded) {
			Vec_DrawObj(ot, 3, &ship);
		}
		else {
			for(i=0; i<18; i++) {
				frag[i].x += frag[i].dx;
				frag[i].y += frag[i].dy;
				frag[i].dy += 1;
				if(frag[i].ttl) {
					frag[i].ttl--;
					vprim[i].x = frag[i].x;
					vprim[i].y = frag[i].y;
					vprim[i].rot += frag[i].drot;
					Vec_DrawPrim(ot, 2, &vprim[i]);
				}
			}
		}
		flame.x = ship.x;
		flame.y = ship.y;
		flame.rot = ship.rot;
		// thrust if fuel in tanks
		if(thrust && fuel) {
			Vec_DrawObj(ot, 3, &flame);
			dx -= GTE_Sin(ship.rot) / 1024;
			dy -= GTE_Cos(ship.rot) / 1024;
			fuel--;
			flame.scale = rand()%2048 + 2047;
		}

		// move ship
		if(!landed) {
			ship.x += dx;
			ship.y += dy; dy += gravity;
			ship.rot += drot;
		}
		else {
			// landed, not crashed
			if(landed == 1)	Vec_PrintScale(ot, 2, "GOOD LANDING", 100, 80, 2048, 10, &vec_letter);
		}
		
		//land.x += dx;
		//vprim.x += dx;
		DrawStars();
		star.rot += 24;

		// debug - trace surface height
		star.x = j * 64;
		star.y = surface[j] * 64;
		Vec_DrawObj(ot, 3, &star);
		j++; if(j == 320) j = 0;

		// move rock
		rock.y += 40;
		rock.rot += 10;
		i = rock.x >> 6;
		if((rock.y >> 6) > surface[i]) {
			if((rock.y >> 6) < 250) {
				rock.y = -3000;
				rock.x = rand()%20000;
			}
		}
		Vec_DrawObj(ot, 3, &rock);

		// check for contact with surface
		i = ship.x >> 6;
		if(((ship.y >> 6) > surface[i]) && !exploded) {
			// check if over landing pad
			if((i < land.brightness) && (i > land.brightness - 20)) {
				// check downward speed
				if(dy < 48) {
					// check rotation
					if(abs(ship.rot) < 256) {
						// LANDED!
						landed = 1; ship.rot = 0; dy = 0; dx = 0;
					}
					else exploded = 1;
				}
				else exploded = 1;
			}
			else exploded = 1;
			
			// check if exploded (landed failed)
			if(exploded) MakeExplosion(0, -32);
		}
		if(exploded) {
			landed = 2;
			Vec_PrintScale(ot, 2, "YOU CRASHED", 105, 80, 2048, 10, &vec_letter);
		}
		
		// Render this frame
        GPU_DrawOt(ot);						// test
		GPU_DrawSync();
        GPU_VSync();
        GPU_FlipDisplay();
        
	}
	

    }	// next level
	// shutdown
    INT_ResetHandler();
    StopPAD();


    temp2 = 27;
    temp = temp2++;
    printf("%u\t", land.x);
    printf("Hello there Jamie!\n");

	// check for PAL or NTSC mode.   by ogre.

	if (*(char *)0xbfc7ff52=='E')
		printf("PAL MODE\n");		//PAL MODE
	else
		printf("NTSC MODE\n");		// NTSC MODE

	return 0;
}

static void SetStar(int i) {
	star.x = star_x[i];
	star.y = star_y[i];

}

static void DrawStars(void) {
	int i;
	for(i=0; i < NUM_STARS; i++) {
		//vprim[i].x += 100;
		//vprim[i].rot += 128;
		//Vec_DrawPrim(ot, 10, &vprim[i]);
		star.x = star_x[i];
		star.y = star_y[i];
		Vec_DrawObj(ot, 4, &star);
		star_x[i] = (star_x[i] + 8) % 20480;
	}
}

// create random landscape
static void MakeLand(void) {
	int i, j, dy;
	
	for(i=0; i<16; i++) {
		land.vtx[i].x = i * 20;
		land.vtx[i].y = rand()%60;
		land.line[i].ls = i;
		land.line[i].le = i+1;
		land.line[i].cs.r = 255;
		land.line[i].cs.g = 255;
		land.line[i].cs.b = 0;
		land.line[i].ce.r = 255;
		land.line[i].ce.g = 128;
		land.line[i].ce.b = 0;
	}
	land.vtx[i].x = i * 20;
	land.vtx[i].y = rand()%60;

	// make a flat landing spot
	i = rand()%14 + 2;
	land.vtx[i].y = land.vtx[i-1].y;
	land.line[i-1].cs.r = 255;
	land.line[i-1].cs.g = 255;
	land.line[i-1].cs.b = 255;
	land.line[i-1].ce.r = 255;
	land.line[i-1].ce.g = 255;
	land.line[i-1].ce.b = 255;

	// store landing spot in brightness field
	land.brightness = i * 20;

	// generate surface height map
	for(i=0; i<16; i++) {
		dy = land.vtx[i+1].y - land.vtx[i].y;
		for(j=0; j<20; j++) {
			surface[i*20+j] = 156 + land.vtx[i].y + ((dy * j) / 20);
		}
	}

}

// explode ship (generate fragments)
void MakeExplosion(PsxInt16 dx, PsxInt16 dy) {
	int i;
    for(i=0; i<18; i++) {
    	frag[i].x = ship.x;
    	frag[i].y = ship.y;
    	frag[i].dx = dx + rand()%128 - 64;
    	frag[i].dy = dy + rand()%128 - 64;
    	frag[i].drot = rand()%512 - 256;
    	frag[i].ttl = rand()%64 + 63;
    }
}

// define a test vector object
static void MakeVectorObjects(void) {
	PsxUInt16 i;

// the ship
	ship.x = 1240;
	ship.y = 512;
	ship.numverts = 4;
	ship.numlines = 4;
	ship.scale = 4096;				// 4096 = scale * 1.0
	ship.rot = 0;
	ship.vtx[0].x = 0;
	ship.vtx[0].y = -10;
	ship.vtx[1].x = 4;
	ship.vtx[1].y = 4;
	ship.vtx[2].x = 0;
	ship.vtx[2].y = 2;
	ship.vtx[3].x = -4;
	ship.vtx[3].y = 4;
	ship.line[0].ls = 0;
	ship.line[0].le = 1;
	ship.line[0].cs.r = 196;
	ship.line[0].cs.g = 196;
	ship.line[0].cs.b = 255;
	ship.line[0].ce.r = 255;
	ship.line[0].ce.g = 255;
	ship.line[0].ce.b = 255;
	ship.line[1].ls = 1;
	ship.line[1].le = 2;
	ship.line[1].cs.r = 255;
	ship.line[1].cs.g = 255;
	ship.line[1].cs.b = 255;
	ship.line[1].ce.r = 255;
	ship.line[1].ce.g = 128;
	ship.line[1].ce.b = 64;
	ship.line[2].ls = 2;
	ship.line[2].le = 3;
	ship.line[2].cs.r = 255;
	ship.line[2].cs.g = 128;
	ship.line[2].cs.b = 64;
	ship.line[2].ce.r = 255;
	ship.line[2].ce.g = 255;
	ship.line[2].ce.b = 255;
	ship.line[3].ls = 3;
	ship.line[3].le = 0;
	ship.line[3].cs.r = 255;
	ship.line[3].cs.g = 255;
	ship.line[3].cs.b = 255;
	ship.line[3].ce.r = 196;
	ship.line[3].ce.g = 196;
	ship.line[3].ce.b = 255;

// the flame
	flame.x = 0;
	flame.y = 0;
	flame.numverts = 5;
	flame.numlines = 4;
	flame.scale = 4096;				// 4096 = scale * 1.0
	flame.rot = 0;
	flame.vtx[0].x = 2;
	flame.vtx[0].y = 4;
	flame.vtx[1].x = 3;
	flame.vtx[1].y = 7;
	flame.vtx[2].x = 0;
	flame.vtx[2].y = 16;
	flame.vtx[3].x = -3;
	flame.vtx[3].y = 7;
	flame.vtx[4].x = -2;
	flame.vtx[4].y = 4;
	flame.line[0].ls = 0;
	flame.line[0].le = 1;
	flame.line[0].cs.r = 128;
	flame.line[0].cs.g = 64;
	flame.line[0].cs.b = 0;
	flame.line[0].ce.r = 196;
	flame.line[0].ce.g = 196;
	flame.line[0].ce.b = 0;
	flame.line[1].ls = 1;
	flame.line[1].le = 2;
	flame.line[1].cs.r = 196;
	flame.line[1].cs.g = 196;
	flame.line[1].cs.b = 0;
	flame.line[1].ce.r = 128;
	flame.line[1].ce.g = 64;
	flame.line[1].ce.b = 0;
	flame.line[2].ls = 2;
	flame.line[2].le = 3;
	flame.line[2].cs.r = 128;
	flame.line[2].cs.g = 64;
	flame.line[2].cs.b = 0;
	flame.line[2].ce.r = 196;
	flame.line[2].ce.g = 196;
	flame.line[2].ce.b = 0;
	flame.line[3].ls = 3;
	flame.line[3].le = 4;
	flame.line[3].cs.r = 196;
	flame.line[3].cs.g = 196;
	flame.line[3].cs.b = 0;
	flame.line[3].ce.r = 128;
	flame.line[3].ce.g = 64;
	flame.line[3].ce.b = 0;

// a star
		star.x = rand()%20480;			// fix pt 10.6
		star.y = rand()%15360;			// fix pt 10.6
		star.numverts = 5;
		star.numlines = 4;
		star.scale = 2048;				// 4096 = scale * 1.0
		star.rot = 0;
		star.vtx[0].x = 0;
		star.vtx[0].y = 0;
		star.vtx[1].x = 0;
		star.vtx[1].y = -7;
		star.vtx[2].x = 7;
		star.vtx[2].y = 0;
		star.vtx[3].x = 0;
		star.vtx[3].y = 7;
		star.vtx[4].x = -7;
		star.vtx[4].y = 0;
		star.line[0].ls = 0;
		star.line[0].le = 1;
		star.line[0].cs.r = 255;
		star.line[0].cs.g = 255;
		star.line[0].cs.b = 0;
		star.line[0].ce.r = 64;
		star.line[0].ce.g = 0;
		star.line[0].ce.b = 0;
		star.line[1].ls = 0;
		star.line[1].le = 2;
		star.line[1].cs.r = 255;
		star.line[1].cs.g = 255;
		star.line[1].cs.b = 0;
		star.line[1].ce.r = 64;
		star.line[1].ce.g = 0;
		star.line[1].ce.b = 0;
		star.line[2].ls = 0;
		star.line[2].le = 3;
		star.line[2].cs.r = 255;
		star.line[2].cs.g = 255;
		star.line[2].cs.b = 0;
		star.line[2].ce.r = 64;
		star.line[2].ce.g = 0;
		star.line[2].ce.b = 0;
		star.line[3].ls = 0;
		star.line[3].le = 4;
		star.line[3].cs.r = 255;
		star.line[3].cs.g = 255;
		star.line[3].cs.b = 0;
		star.line[3].ce.r = 64;
		star.line[3].ce.g = 0;
		star.line[3].ce.b = 0;

		// set up stars
		for(i=0; i<50; i++) {
			star_x[i] = rand()%20480;
			star_y[i] = rand()%10000;
		}

// a vector letter (template for Alphanumeric vector letter drawing)
	vec_letter.x = 0;
	vec_letter.y = 0;
	vec_letter.numverts = 11;
	vec_letter.numlines = 0;
	vec_letter.scale = 4096;				// 4096 = scale * 1.0
	vec_letter.rot = 0;
	vec_letter.brightness = 255;
	vec_letter.vtx[0].x = -5;
	vec_letter.vtx[0].y = -6;
	vec_letter.vtx[1].x = 0;
	vec_letter.vtx[1].y = -6;
	vec_letter.vtx[2].x = 5;
	vec_letter.vtx[2].y = -6;
	vec_letter.vtx[3].x = 5;
	vec_letter.vtx[3].y = -3;
	vec_letter.vtx[4].x = 5;
	vec_letter.vtx[4].y = 0;
	vec_letter.vtx[5].x = 5;
	vec_letter.vtx[5].y = 3;
	vec_letter.vtx[6].x = 5;
	vec_letter.vtx[6].y = 6;
	vec_letter.vtx[7].x = 0;
	vec_letter.vtx[7].y = 6;
	vec_letter.vtx[8].x = -5;
	vec_letter.vtx[8].y = 6;
	vec_letter.vtx[9].x = 0;
	vec_letter.vtx[9].y = 0;
	vec_letter.vtx[10].x = -5;
	vec_letter.vtx[10].y = 0;
	for(i=0; i<8; i++) {
		vec_letter.line[i].cs.r = 255;
		vec_letter.line[i].cs.g = 255;
		vec_letter.line[i].cs.b = 255;
		vec_letter.line[i].ce.r = 255;
		vec_letter.line[i].ce.g = 255;
		vec_letter.line[i].ce.b = 255;
	}

// a land
		land.x = 0;					// fix pt 10.6
		land.y = 160 << 6;			// fix pt 10.6
		land.numverts = 17;
		land.numlines = 16;
		land.scale = 4096;				// 4096 = scale * 1.0
		land.rot = 0;

// a landing pad
		pad.numverts = 4;
		pad.numlines = 2;
		pad.scale = 4096;				// 4096 = scale * 1.0
		pad.rot = 0;
		pad.vtx[0].x = -7;
		pad.vtx[0].y = 0;
		pad.vtx[1].x = 7;
		pad.vtx[1].y = 0;
		pad.vtx[2].x = -7;
		pad.vtx[2].y = 1;
		pad.vtx[3].x = 7;
		pad.vtx[3].y = 1;
		pad.line[0].ls = 0;
		pad.line[0].le = 1;
		pad.line[0].cs.r = 255;
		pad.line[0].cs.g = 255;
		pad.line[0].cs.b = 255;
		pad.line[0].ce.r = 255;
		pad.line[0].ce.g = 255;
		pad.line[0].ce.b = 255;
		pad.line[1].ls = 2;
		pad.line[1].le = 3;
		pad.line[1].cs.r = 196;
		pad.line[1].cs.g = 196;
		pad.line[1].cs.b = 196;
		pad.line[1].ce.r = 196;
		pad.line[1].ce.g = 196;
		pad.line[1].ce.b = 196;

// a rock
		rock.numverts = 11;
		rock.numlines = 10;
		rock.scale = 1024;				// 4096 = scale * 1.0
		rock.rot = 0;
		rock.vtx[0].x = -8;
		rock.vtx[0].y = -2;
		rock.vtx[1].x = -11;
		rock.vtx[1].y = -12;
		rock.vtx[2].x = -3;
		rock.vtx[2].y = -17;
		rock.vtx[3].x = 11;
		rock.vtx[3].y = -15;
		rock.vtx[4].x = 11;
		rock.vtx[4].y = -5;
		rock.vtx[5].x = 21;
		rock.vtx[5].y = -1;
		rock.vtx[6].x = 13;
		rock.vtx[6].y = 10;
		rock.vtx[7].x = 2;
		rock.vtx[7].y = 10;
		rock.vtx[8].x = -6;
		rock.vtx[8].y = 15;
		rock.vtx[9].x = -18;
		rock.vtx[9].y = 6;
		rock.vtx[10].x = -10;
		rock.vtx[10].y = -8;
		rock.line[0].ls = 0;
		rock.line[0].le = 1;
		rock.line[0].cs.r = 255;
		rock.line[0].cs.g = 255;
		rock.line[0].cs.b = 255;
		rock.line[0].ce.r = 255;
		rock.line[0].ce.g = 255;
		rock.line[0].ce.b = 255;
		rock.line[1].ls = 1;
		rock.line[1].le = 2;
		rock.line[1].cs.r = 196;
		rock.line[1].cs.g = 196;
		rock.line[1].cs.b = 196;
		rock.line[1].ce.r = 196;
		rock.line[1].ce.g = 196;
		rock.line[1].ce.b = 196;
		rock.line[2].ls = 2;
		rock.line[2].le = 3;
		rock.line[2].cs.r = 255;
		rock.line[2].cs.g = 255;
		rock.line[2].cs.b = 255;
		rock.line[2].ce.r = 255;
		rock.line[2].ce.g = 255;
		rock.line[2].ce.b = 255;
		rock.line[3].ls = 3;
		rock.line[3].le = 4;
		rock.line[3].cs.r = 255;
		rock.line[3].cs.g = 255;
		rock.line[3].cs.b = 255;
		rock.line[3].ce.r = 255;
		rock.line[3].ce.g = 255;
		rock.line[3].ce.b = 255;
		rock.line[4].ls = 4;
		rock.line[4].le = 5;
		rock.line[4].cs.r = 255;
		rock.line[4].cs.g = 255;
		rock.line[4].cs.b = 255;
		rock.line[4].ce.r = 255;
		rock.line[4].ce.g = 255;
		rock.line[4].ce.b = 255;
		rock.line[5].ls = 5;
		rock.line[5].le = 6;
		rock.line[5].cs.r = 255;
		rock.line[5].cs.g = 255;
		rock.line[5].cs.b = 255;
		rock.line[5].ce.r = 255;
		rock.line[5].ce.g = 255;
		rock.line[5].ce.b = 255;
		rock.line[6].ls = 6;
		rock.line[6].le = 7;
		rock.line[6].cs.r = 255;
		rock.line[6].cs.g = 255;
		rock.line[6].cs.b = 255;
		rock.line[6].ce.r = 255;
		rock.line[6].ce.g = 255;
		rock.line[6].ce.b = 255;
		rock.line[7].ls = 7;
		rock.line[7].le = 8;
		rock.line[7].cs.r = 255;
		rock.line[7].cs.g = 255;
		rock.line[7].cs.b = 255;
		rock.line[7].ce.r = 255;
		rock.line[7].ce.g = 255;
		rock.line[7].ce.b = 255;
		rock.line[8].ls = 8;
		rock.line[8].le = 9;
		rock.line[8].cs.r = 255;
		rock.line[8].cs.g = 255;
		rock.line[8].cs.b = 255;
		rock.line[8].ce.r = 255;
		rock.line[8].ce.g = 255;
		rock.line[8].ce.b = 255;
		rock.line[9].ls = 9;
		rock.line[9].le = 10;
		rock.line[9].cs.r = 255;
		rock.line[9].cs.g = 255;
		rock.line[9].cs.b = 255;
		rock.line[9].ce.r = 255;
		rock.line[9].ce.g = 255;
		rock.line[9].ce.b = 255;

// vector primitives
		for(i=0; i<20; i++) {
			vprim[i].x = rand() % 24000;
			vprim[i].y = rand() % 15000;
			vprim[i].rot = 0;
			vprim[i].scale = 2048;
			vprim[i].vtx[0].x = 3;
			vprim[i].vtx[0].y = 3;
			vprim[i].vtx[1].x = -3;
			vprim[i].vtx[1].y = -3;
			vprim[i].cs.r = 255;
			vprim[i].cs.g = 255;
			vprim[i].cs.b = 255;
			vprim[i].ce.r = 128;
			vprim[i].ce.g = 128;
			vprim[i].ce.b = 128;
		}
		


}


// Draw a Vector Object
void Vec_DrawObj(GsOT *pot, PsxUInt32 pos, VecObj *obj) {
	PsxUInt8 i;
	PsxUInt8 v1, v2;
	static CILINE tline;
	MATRIX mx_scale, mx_rot, mx_final;
	SVECTOR3D vec_in[20];
	SVECTOR3D vec_out[20];
	PsxInt16 sin, cos;

	// set up matrix for rotation and scaling
	// set up scale matrix (NB: 0 < scale < 8095 ???)
	GTE_MatrixSetIdentity(&mx_scale);
	mx_scale.m[0][0] = mx_scale.m[1][1] = mx_scale.m[2][2] = obj->scale;

	// set up rotation matrix
	// (rotate about z axis) (NB: PI = 2048, 4096 = 2*PI)
	sin = GTE_Sin(obj->rot);
	cos = GTE_Cos(obj->rot);		
	GTE_MatrixSetIdentity(&mx_rot);
	mx_rot.m[0][0] = mx_rot.m[1][1] = cos;
	mx_rot.m[0][1] = sin;
	mx_rot.m[1][0] = -sin;

	// concatenate
	GTE_MatMul(&mx_final, &mx_rot, &mx_scale);

	// set translation vector
	mx_final.t[0] = mx_final.t[1] = mx_final.t[2] = 0;

	// load input vectors
	for(i=0; i < obj->numverts; i++) {
		vec_in[i].x = obj->vtx[i].x;
		vec_in[i].y = obj->vtx[i].y;
		vec_in[i].z = 0;
		vec_in[i].pad = 0;
	}
	
	// rotate and scale vertices
	GTE_SV3XForm(&vec_out[0], &vec_in[0], &mx_final, obj->numverts);


	// output lines to the order table
	for(i=0; i < obj->numlines; i++) {
		tline.color0.r = obj->line[i].cs.r;
		tline.color0.g = obj->line[i].cs.g;
		tline.color0.b = obj->line[i].cs.b;
		tline.color1.r = obj->line[i].ce.r;
		tline.color1.g = obj->line[i].ce.g;
		tline.color1.b = obj->line[i].ce.b;
		v1 = obj->line[i].ls;
		v2 = obj->line[i].le;
//		tline.vert0.x = (obj->x >> 6) + obj->vtx[v1].x;
//		tline.vert0.y = (obj->y >> 6) + obj->vtx[v1].y;
//		tline.vert1.x = (obj->x >> 6) + obj->vtx[v2].x;
//		tline.vert1.y = (obj->y >> 6) + obj->vtx[v2].y;
		tline.vert0.x = (obj->x >> 6) + vec_out[v1].x;
		tline.vert0.y = (obj->y >> 6) + vec_out[v1].y;
		tline.vert1.x = (obj->x >> 6) + vec_out[v2].x;
		tline.vert1.y = (obj->y >> 6) + vec_out[v2].y;
	
		GPU_SortCiLine(pot, pos, &tline);
	} // next line

///// DEBUG
//tline.color0.r = 255;
//tline.color0.g = 255;
//tline.color0.b = 255;
//tline.color1.r = 128;
//tline.color1.g = 128;
//tline.color1.b = 128;
//tline.vert0.x = 20;
//tline.vert0.y = 90;
//tline.vert1.x = 100;
//tline.vert1.y = 10;
//GPU_SortCiLine(pot, pos, &tline);
}

// Draw a Vector "primitive"
void Vec_DrawPrim(GsOT *pot, PsxUInt32 pos, VecPrim *prim) {
	short i;
	CILINE tline;
	MATRIX mx_scale, mx_rot, mx_final;
	SVECTOR3D vec_in[5];
	SVECTOR3D vec_out[5];
	PsxInt16 sin, cos;

	// set up matrix for rotation and scaling
	// set up scale matrix (NB: 0 < scale < 8095 ???)
	GTE_MatrixSetIdentity(&mx_scale);
	mx_scale.m[0][0] = mx_scale.m[1][1] = mx_scale.m[2][2] = prim->scale;

	// set up rotation matrix
	// (rotate about z axis) (NB: PI = 2048, 4096 = 2*PI)
	sin = GTE_Sin(prim->rot);
	cos = GTE_Cos(prim->rot);		
	GTE_MatrixSetIdentity(&mx_rot);
	mx_rot.m[0][0] = mx_rot.m[1][1] = cos;
	mx_rot.m[0][1] = sin;
	mx_rot.m[1][0] = -sin;

	// concatenate
	GTE_MatMul(&mx_final, &mx_rot, &mx_scale);

	// fix translation vector
	mx_final.t[0] = mx_final.t[1] = mx_final.t[2] = 0;

	// load input vectors
	for(i=0; i < 2; i++) {
		vec_in[i].x = prim->vtx[i].x;
		vec_in[i].y = prim->vtx[i].y;
		vec_in[i].z = 0;
		vec_in[i].pad = 0;
	}
	
	// rotate and scale vertices
	GTE_SV3XForm(&vec_out[0], &vec_in[0], &mx_final, 3);

	// output the line to the order table
	tline.color0.r = prim->cs.r;
	tline.color0.g = prim->cs.g;
	tline.color0.b = prim->cs.b;
	tline.color1.r = prim->ce.r;
	tline.color1.g = prim->ce.g;
	tline.color1.b = prim->ce.b;
	tline.vert0.x = (prim->x >> 6) + vec_out[0].x;
	tline.vert0.y = (prim->y >> 6) + vec_out[0].y;
	tline.vert1.x = (prim->x >> 6) + vec_out[1].x;
	tline.vert1.y = (prim->y >> 6) + vec_out[1].y;
	
	GPU_SortCiLine(pot, pos, &tline);
}


void Vec_DrawLetter(GsOT *pot, PsxUInt32 pos, PsxUInt8 ascii, PsxUInt32 x, PsxUInt32 y, VecObj *obj) {
	PsxUInt8 i;
	PsxUInt8 v1, v2;
	static CILINE tline;

	// convert ascii value to our letter data index 
	ascii -= 48;

	// preset some stuff
	tline.color0.r = (obj->line[0].cs.r * obj->brightness) >> 8;
	tline.color0.g = (obj->line[0].cs.g * obj->brightness) >> 8;
	tline.color0.b = (obj->line[0].cs.b * obj->brightness) >> 8;
	tline.color1.r = (obj->line[0].ce.r * obj->brightness) >> 8;
	tline.color1.g = (obj->line[0].ce.g * obj->brightness) >> 8;
	tline.color1.b = (obj->line[0].ce.b * obj->brightness) >> 8;

	// output lines to the order table
	for(i=0; i < Letter[ascii].numlines; i++) {
		v1 = Letter[ascii].ls[i];
		v2 = Letter[ascii].le[i];
		tline.vert0.x = x + obj->vtx[v1].x;
		tline.vert0.y = y + obj->vtx[v1].y;
		tline.vert1.x = x + obj->vtx[v2].x;
		tline.vert1.y = y + obj->vtx[v2].y;

		GPU_SortCiLine(pot, pos, &tline);
	} // next line

}

// print a scaled character
void Vec_DrawLetterScale(GsOT *pot, PsxUInt32 pos, PsxUInt8 ascii, PsxUInt32 x, PsxUInt32 y, PsxInt16 scale, VecObj *obj)
{
	PsxUInt8 i;
	PsxUInt8 v1, v2;
	static CILINE tline;
	MATRIX mx_scale;
	SVECTOR3D vec_in[16];
	SVECTOR3D vec_out[16];

	// convert ascii value to our letter data index 
	ascii -= 48;

	// set up matrix for scaling
	// set up scale matrix (NB: 0 < scale < 8095 ???)
	GTE_MatrixSetIdentity(&mx_scale);
	mx_scale.m[0][0] = mx_scale.m[1][1] = mx_scale.m[2][2] = scale;

	// fix translation vector
	mx_scale.t[0] = mx_scale.t[1] = mx_scale.t[2] = 0;

	// load input vectors
	for(i=0; i < 16; i++) {
		vec_in[i].x = obj->vtx[i].x;
		vec_in[i].y = obj->vtx[i].y;
		vec_in[i].z = 0;
		vec_in[i].pad = 0;
	}
	
	// rotate and scale vertices
	GTE_SV3XForm(&vec_out[0], &vec_in[0], &mx_scale, 11);

	// preset some stuff
	tline.color0.r = (obj->line[0].cs.r * obj->brightness) >> 8;
	tline.color0.g = (obj->line[0].cs.g * obj->brightness) >> 8;
	tline.color0.b = (obj->line[0].cs.b * obj->brightness) >> 8;
	tline.color1.r = (obj->line[0].ce.r * obj->brightness) >> 8;
	tline.color1.g = (obj->line[0].ce.g * obj->brightness) >> 8;
	tline.color1.b = (obj->line[0].ce.b * obj->brightness) >> 8;

	// output lines to the order table
	for(i=0; i < Letter[ascii].numlines; i++) {
		v1 = Letter[ascii].ls[i];
		v2 = Letter[ascii].le[i];
		tline.vert0.x = x + vec_out[v1].x;
		tline.vert0.y = y + vec_out[v1].y;
		tline.vert1.x = x + vec_out[v2].x;
		tline.vert1.y = y + vec_out[v2].y;
	
		GPU_SortCiLine(pot, pos, &tline);
	} // next line
}
	
// draw a string of vector characters
void Vec_Print(GsOT *pot, PsxUInt32 pos, char *string, PsxUInt32 x, PsxUInt32 y, VecObj *obj)
{
	while ((x < 320) && *string) {
		if(*string > 47) Vec_DrawLetter(pot, pos, *string, x, y, obj);
		string++;
		x += 15;
	}
}

// draw a string of scaled vector characters
void Vec_PrintScale(GsOT *pot, PsxUInt32 pos, char *string, PsxUInt32 x, PsxUInt32 y, PsxInt16 scale, PsxInt16 spacing, VecObj *obj)
{
	while ((x < 320) && *string) {
		if(*string > 47) Vec_DrawLetterScale(pot, pos, *string, x, y, scale, obj);
		string++;
		x += spacing;
	}
}
	

	
	
