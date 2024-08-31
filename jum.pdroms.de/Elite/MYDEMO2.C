// James' 2nd Playstation demo
#include	<syscall.h>
#include	<psxtypes.h>
#include	<int.h>
#include	<gpu.h>
#include	<tmd.h>
#include	"..\sound\libspu.h"

#define DEBUG

#define OT_LENGTH	5


static GsOT_TAG zSortTable[1<<OT_LENGTH];
static PACKET cmdBuffer[300];

// TIM refs for linker
extern char elitefon[];
extern char title[];
extern char title2[];
extern char cockpit[];
extern char cockpit2[];

// 3D objects ref for linker  
extern char cobra[];
extern char gecko[];
extern char krait[];
extern char moray[];
extern char e3d[];
extern char l3d[];
extern char i3d[];
extern char t3d[];

// the MOD
extern char bludan[];

// half sine wave (for scrolltext)
extern unsigned char halfsine[];

// define primitives
static BOXFILL myBox;
static CILINE myLine;
static CITRI myTri, myTri2;
static QUAD bgQuad;
static TEXQUAD myTexQuad;
static TEXQUAD myTexQuad2;
static TEXQUAD TQ1;

static TEXCOORDS tc[8];

static HITMUD mymod;

static char scrolltext[] = "                    "
	"FINALLY... MY SECOND PSX DEMO                    "
	"--- E L I T E ---                   "
	"IT TOOK LONGER THAN I THOUGHT, BECAUSE "
	"I *WANTED* SOUND AND HAD TO THEREFORE "
	"WRITE A SOUND AND M*O*D LIBRARY =)              "
	"BASICALLY I WANTED TO DO SIMPLE 3D MODELS "
	"AND SOUND IN THIS DEMO, AND I WAS LOOKING "
	"AT ELITE RUNNING ON AN AMIGA EMULATOR, AND "
	"I THOUGHT IT WOULD BE COOL IF ELITE MADE "
	"IT TO THE PSX, AND WELL, HERE IT IS (SORT OF :)"
	"                THE MUSIC I HAD TO CONVERT BY "
	"HAND FROM A MIDI SCORE SHEET INTO A M*O*D FILE, "
	"BUT I DON'T KNOW WHAT IT'S GOING TO SOUND LIKE "
	"THRU MY NEW MODPLAYER (HEAVILY 'INFLUENCED' BY "
	"SILPHEED'S :)                     GREETINGS TO "
	"LUKA (HOPE YOU'RE STILL MOD'ING MAN!) DANZIG "
	"AND ROB WITHEY.                      THAT'S "
	"ABOUT IT FOR MY SCROLLER, CAN'T THINK OF MORE "
	"JUNK TO WRITE. MAYBE MY NEXT PROJECT WILL "
	"BE A LITTLE GAME...  :)                   "
	"                           ";         

int temp;
int temp2;

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

int main(int argc,char **argv)
{

	int			i, j, k, n;
	SVECTOR2D	posn;
	PsxUInt32	dxrot, dyrot, dzrot, xrot, yrot, zrot;
	MATRIX		ltm, matrix;
	PsxInt16 	sine, cosine;
	PsxInt16	dist;
	PsxInt16	LetrDist[5];
	PsxInt16	LetrOffset[5] = { -208, -104 , 0, 104, 208 };
	COLOR clr_color = { 0, 0, 0, 0};
	char ctemp, cx, cy, cx1, cy1;
	PsxInt16	scrollindex = 0;
	PsxInt16	scrolloffset = 15;
	unsigned char	uc;

	// ordering table
	GsOT    worldOrderTable;
	GsOT *ot;               // pntr to OT

	// what about "ResetCallBack()"

	// install interrupt handler
	INT_SetUpHandler();


	k = 0;
	posn.x = 1; posn.y = 100;
	// set up CiLine
	myLine.color0.r = myLine.color0.g = myLine.color0.b = 100;
	myLine.vert0.x = 20; myLine.vert0.y = 10;
	myLine.color1.r = myLine.color1.g = myLine.color1.b = 220;        // set up triangle 1
	myLine.vert1.x = 50; myLine.vert1.y = 199;

	// set up Box
	myBox.color.r = myBox.color.g = myBox.color.b = 33;
	myBox.pos.x = 10; myBox.pos.y = 10;
	myBox.size.x = 620; myBox.size.y = 220;


        // set up background quad
        bgQuad.color.r = 255;
        bgQuad.color.g = bgQuad.color.b = 25;
        bgQuad.vert0.x = bgQuad.vert1.x = 20;
        bgQuad.vert0.y = bgQuad.vert2.y = 20;
        bgQuad.vert2.x = bgQuad.vert3.x = 300;
        bgQuad.vert1.y = bgQuad.vert3.y = 220;

	// set up background quads
	myTexQuad.color.r = 255;
	myTexQuad.color.g = myTexQuad.color.b = 255;
	myTexQuad.vert0.x = myTexQuad.vert1.x = 0;
	myTexQuad.vert0.y = myTexQuad.vert2.y = 20;
	myTexQuad.vert2.x = myTexQuad.vert3.x = 255;
	myTexQuad.vert1.y = myTexQuad.vert3.y = 219;
	myTexQuad.texCoords0.u = 0;
	myTexQuad.texCoords0.v = 0;
	myTexQuad.texCoords1.u = 0;
	myTexQuad.texCoords1.v = 199;
	myTexQuad.texCoords2.u = 255;
	myTexQuad.texCoords2.v = 0;
	myTexQuad.texCoords3.u = 255;
	myTexQuad.texCoords3.v = 199;
	myTexQuad.clutId = GPU_CalcClutID(0,481);
	myTexQuad.texPage = GPU_CalcTexturePage(448,0,0);
	
	myTexQuad2.color.r = 255;
	myTexQuad2.color.g = myTexQuad2.color.b = 255;
	myTexQuad2.vert0.x = myTexQuad2.vert1.x = 255;
	myTexQuad2.vert0.y = myTexQuad2.vert2.y = 20;
	myTexQuad2.vert2.x = myTexQuad2.vert3.x = 318;
	myTexQuad2.vert1.y = myTexQuad2.vert3.y = 219;
	myTexQuad2.texCoords0.u = 0;
	myTexQuad2.texCoords0.v = 0;
	myTexQuad2.texCoords1.u = 0;
	myTexQuad2.texCoords1.v = 199;
	myTexQuad2.texCoords2.u = 63;
	myTexQuad2.texCoords2.v = 0;
	myTexQuad2.texCoords3.u = 63;
	myTexQuad2.texCoords3.v = 199;
	myTexQuad2.clutId = GPU_CalcClutID(0,481);
	myTexQuad2.texPage = GPU_CalcTexturePage(512,0,0);

	// tex quad for letters (scroll text)
	TQ1.color.r = 255;
	TQ1.color.g = TQ1.color.b = 255;
	TQ1.vert0.x = TQ1.vert1.x = 200;
	TQ1.vert0.y = TQ1.vert2.y = 160;
	TQ1.vert2.x = TQ1.vert3.x = 319;
	TQ1.vert1.y = TQ1.vert3.y = 219;
	TQ1.texCoords0.u = 0;
	TQ1.texCoords0.v = 0;
	TQ1.texCoords1.u = 0;
	TQ1.texCoords1.v = 63;
	TQ1.texCoords2.u = 63;
	TQ1.texCoords2.v = 0;
	TQ1.texCoords3.u = 63;
	TQ1.texCoords3.v = 63;
	TQ1.clutId = GPU_CalcClutID(0,482);
	TQ1.texPage = GPU_CalcTexturePage(576,0,0);

	// check for PAL or NTSC mode and set as required
	// code from ogre
	// hopefully this will allow demo to work on both
	// PAL and NTSC machines
	if (*(char *)0xbfc7ff52=='E') {
		printf("PAL MODE\n");		//PAL MODE
		GPU_SetPAL(1);
	}
	else {
		printf("NTSC MODE\n");		// NTSC MODE
		GPU_SetPAL(0);
	}
	
	// bypass a lot of probably neccessary stuff
	// and do GPU init stuff

	GPU_Reset(0);		// cold reset ???
	GPU_Init(320, 240, GsNONINTER, 0);
	GPU_DefDispBuff(0, 0, 0, 240);		// was 0 0 0 240

	// Init GTE for 3D (matrices)
	GTE_Init(320, 240);

	// Mess with the palette
    GPU_TIMGetClut((TIMHEADER *)cockpit)->clutData[0] = 0;

	// upload graphic data and wait till finished
	UpLoadImage((TIMHEADER *)title);
	UpLoadImage((TIMHEADER *)title2);
	UpLoadImage((TIMHEADER *)cockpit2);
	UpLoadImage((TIMHEADER *)cockpit);
	UpLoadImage((TIMHEADER *)elitefon);
	GPU_DrawSync();

        // set up order table
        worldOrderTable.length = OT_LENGTH;
        worldOrderTable.org = zSortTable;

	// enable display and wait for GPU
	GPU_EnableDisplay(1);
	GPU_DrawSync();

	// initialise sound
	SPU_Reset();
	SPU_Init();
	SPU_Enable();
	i = SPU_Wait();
	printf("SPU_Wait returned %d.\n", i);
	
	// Init MOD player
	InitMOD(&mymod, bludan, 0x1010);

	// display title page
	for(i=0; i<255; i++) {
            ot = &worldOrderTable;
            GPU_ClearOt(0, 0, ot);
            GPU_SetCmdWorkSpace(cmdBuffer);

            GPU_DrawSync();
            GPU_VSync();
            GPU_FlipDisplay();
		
			if(i<128) {
				myTexQuad.color.r = i*2;
				myTexQuad.color.g = myTexQuad.color.b = i*2;
				myTexQuad2.color.r = i*2;
				myTexQuad2.color.g = myTexQuad2.color.b = i*2;
			}
			GPU_SortTexQuad(ot, 0, &myTexQuad);
			GPU_SortTexQuad(ot, 0, &myTexQuad2);

			// Process buffer
        	GPU_DrawOt(ot);
	}

	// set texQuads to cockpit
	myTexQuad.color.r = myTexQuad.color.g = myTexQuad.color.b = 255;
	myTexQuad.clutId = GPU_CalcClutID(0,480);
	myTexQuad.texPage = GPU_CalcTexturePage(320,0,0);

	myTexQuad2.color.r = myTexQuad2.color.g = myTexQuad2.color.b = 255;
	myTexQuad2.clutId = GPU_CalcClutID(0,480);
	myTexQuad2.texPage = GPU_CalcTexturePage(384,0,0);

	// endless love, I mean loop...
	while(TRUE) {
	dxrot = dyrot = dzrot = 0;
	xrot = yrot = zrot = 0;
	// show title letters
	LetrDist[0] = 0x3F00;
	LetrDist[1] = 0x4F00;
	LetrDist[2] = 0x5F00;
	LetrDist[3] = 0x6F00;
	LetrDist[4] = 0x7F00;
	j = 0; k = 0;
	cosine = 0x2;
	for(k=0; k<1200; k++) {
	// play this frame
		PollMOD(&mymod);
        ot = &worldOrderTable;
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer);

        GPU_DrawSync();
        GPU_VSync();
        GPU_FlipDisplay();

       	// set up clear 
       	GPU_SortClear(k % 2, ot, &clr_color);

		xrot += 16;

		// Rotate letters about y axis
		sine = GTE_Sin(yrot);
		cosine = GTE_Cos(yrot);
		GTE_MatrixSetIdentity(&ltm);
		ltm.m[0][0] = ltm.m[2][2] = cosine;
		ltm.m[0][2] = sine;
		ltm.m[2][0] = -sine;

		// Rotate letters about x axis
		sine = GTE_Sin(xrot);
		cosine = GTE_Cos(xrot);		
		GTE_MatrixSetIdentity(&matrix);
		matrix.m[1][1] = matrix.m[2][2] = cosine;
		matrix.m[1][2] = sine;
		matrix.m[2][1] = -sine;
		GTE_MatMul(&ltm, &ltm, &matrix);

		// scale letters (to half original size)
		sine = 2048;
		GTE_MatrixSetIdentity(&matrix);
		matrix.m[0][0] = matrix.m[1][1] = matrix.m[2][2] = sine;
		GTE_MatMul(&ltm, &ltm, &matrix);

		// for every letter
        for(i=0; i<5; i++) {


			// set translation vector for object
			ltm.t[0] = LetrOffset[i];
			ltm.t[1] = -80;
        	ltm.t[2] = LetrDist[i];

			cosine += 1;
		
			// draw the object (if not out of range)
			if(LetrDist[i] < 0x4000) {
				switch(i) {
					case 0 :		
						TMD_Render(ot, (TMDHEADER *)e3d, &ltm, TRUE);
						break;
					case 1 :
						TMD_Render(ot, (TMDHEADER *)l3d, &ltm, TRUE);
						break;
					case 2 :
						TMD_Render(ot, (TMDHEADER *)i3d, &ltm, TRUE);
						break;
					case 3 :
						TMD_Render(ot, (TMDHEADER *)t3d, &ltm, TRUE);
						break;
					case 4 :
						TMD_Render(ot, (TMDHEADER *)e3d, &ltm, TRUE);
						break;
				} // end switch
			} // end if in range




			// control zooming of letters        
			if(k>1050) LetrDist[i] += 128;
			else {
				if(LetrDist[i]>0x800) LetrDist[i] -= 64;
			}
			//if(i>1660) dist += 42;
        }	// next i

		// draw scrolltext letters
        for(i=0; i<20; i++) {
        	ctemp = scrolltext[scrollindex + i] - 32;
        	cx = (ctemp % 16) * 16 + 2;
        	cy = (ctemp / 16) * 16 + 3;

			TQ1.color.r = TQ1.color.g = TQ1.color.b = halfsine[i*16+scrolloffset];
			TQ1.vert0.x = TQ1.vert1.x = i * 16 + scrolloffset;
			TQ1.vert0.y = TQ1.vert2.y = 222;
			TQ1.vert2.x = TQ1.vert3.x = i * 16 + 15 + scrolloffset;
			TQ1.vert1.y = TQ1.vert3.y = 239;
			TQ1.texCoords0.u = cx;
			TQ1.texCoords0.v = cy;
			TQ1.texCoords1.u = cx;
			TQ1.texCoords1.v = cy + 11;
			TQ1.texCoords2.u = cx + 11;
			TQ1.texCoords2.v = cy;
			TQ1.texCoords3.u = cx + 11;
			TQ1.texCoords3.v = cy + 11;

			GPU_SortTexQuad(ot, 11, &TQ1);
        }
        scrolloffset--;
        if(scrolloffset == -16) {
        	scrolloffset = 0;
        	scrollindex++;
        	if(scrollindex == 925) scrollindex = 0;
        }
        
		// draw background
		GPU_SortTexQuad(ot, 4, &myTexQuad);
		GPU_SortTexQuad(ot, 10, &myTexQuad2);
		
		// Process buffer
       	GPU_DrawOt(ot);
	}	// next k        
	
	// show ships
	j = 0; k = 0;
	dist = 0x2000;
	cosine = 0x2;
	//TQ1.color.r = TQ1.color.g = TQ1.color.b = 255;
	for(k=0; k<4; k++) {
		dist = 0x3F00;
        for(i=0; i<2000; i++) {

        	PollMOD(&mymod);
            ot = &worldOrderTable;
            GPU_ClearOt(0, 0, ot);
            GPU_SetCmdWorkSpace(cmdBuffer);

            GPU_DrawSync();
            GPU_VSync();
            GPU_FlipDisplay();

			yrot += 16;
			zrot += 8;
			xrot += 4;

			// Rotate ufo about y axis
			sine = GTE_Sin(yrot);
			cosine = GTE_Cos(yrot);
			GTE_MatrixSetIdentity(&ltm);
			ltm.m[0][0] = ltm.m[2][2] = cosine;
			ltm.m[0][2] = sine;
			ltm.m[2][0] = -sine;

			// Rotate ufo about x axis
			sine = GTE_Sin(xrot);
			cosine = GTE_Cos(xrot);		
			GTE_MatrixSetIdentity(&matrix);
			matrix.m[1][1] = matrix.m[2][2] = cosine;
			matrix.m[1][2] = sine;
			matrix.m[2][1] = -sine;
			GTE_MatMul(&ltm, &ltm, &matrix);


			// Rotate ufo about z axis
			sine = GTE_Sin(zrot);
			cosine = GTE_Cos(zrot);		
			GTE_MatrixSetIdentity(&matrix);
			matrix.m[0][0] = matrix.m[1][1] = cosine;
			matrix.m[0][1] = sine;
			matrix.m[1][0] = -sine;
			GTE_MatMul(&ltm, &ltm, &matrix);


			// scale object
			sine = 4096;
			GTE_MatrixSetIdentity(&matrix);
			matrix.m[0][0] = matrix.m[1][1] = matrix.m[2][2] = sine;
			GTE_MatMul(&ltm, &ltm, &matrix);

			// set translation vector for object
			ltm.t[0] = 0;
			ltm.t[1] = -80;
        	ltm.t[2] = dist;

			cosine += 1;
		

            // draw background & line
        	// set up clear 
        	GPU_SortClear(i % 2, ot, &clr_color);
			//GPU_SortBoxFill(ot, 2, &myBox);
			//bgQuad.color.r = i;
			//GPU_SortCiLine(ot, 20, &myLine);
		
			// draw the object
			switch(k) {
				case 0 :		
					TMD_Render(ot, (TMDHEADER *)cobra, &ltm, TRUE);
					break;
				case 1 :
					TMD_Render(ot, (TMDHEADER *)gecko, &ltm, TRUE);
					break;
				case 2 :
					TMD_Render(ot, (TMDHEADER *)krait, &ltm, TRUE);
					break;
				case 3 :
					TMD_Render(ot, (TMDHEADER *)moray, &ltm, TRUE);
					break;
			} // end switch

		// draw scrolltext letters
        for(j=0; j<20; j++) {
        	ctemp = scrolltext[scrollindex + j] - 32;
        	cx = (ctemp % 16) * 16 + 2;
        	cy = (ctemp / 16) * 16 + 3;

			//uc = halfsine[j*16+scrolloffset] >> 4;
			TQ1.color.r = TQ1.color.g = TQ1.color.b = halfsine[j*16+scrolloffset];
			uc = TQ1.color.r >> 4;
			TQ1.vert0.x = TQ1.vert1.x = j * 16 + scrolloffset;
			TQ1.vert0.y = TQ1.vert2.y = 229 - uc;
			TQ1.vert2.x = TQ1.vert3.x = j * 16 + 15 + scrolloffset;
			TQ1.vert1.y = TQ1.vert3.y = 230 + uc;
			TQ1.texCoords0.u = cx;
			TQ1.texCoords0.v = cy;
			TQ1.texCoords1.u = cx;
			TQ1.texCoords1.v = cy + 11;
			TQ1.texCoords2.u = cx + 11;
			TQ1.texCoords2.v = cy;
			TQ1.texCoords3.u = cx + 11;
			TQ1.texCoords3.v = cy + 11;

			GPU_SortTexQuad(ot, 11, &TQ1);
        }
        scrolloffset--;
        if(scrolloffset == -16) {
        	scrolloffset = 0;
        	scrollindex++;
			if(scrollindex == 925) scrollindex = 0;
        }
        
			GPU_SortTexQuad(ot, 4, &myTexQuad);
			GPU_SortTexQuad(ot, 10, &myTexQuad2);
			
			// Process buffer
        	GPU_DrawOt(ot);


			// zoom in / zoom out        
			if(i<340) dist -= 42;
			if(i>1660) dist += 42;
        }	// next i
	}	// next k        
	}	// wend
        INT_ResetHandler();


        temp2 = 27;
        temp = temp2++;
        printf("%u\t",temp);
        printf("Hello there Jamie!\n");

	// check for PAL or NTSC mode.   by ogre.

	if (*(char *)0xbfc7ff52=='E')
		printf("PAL MODE\n");		//PAL MODE
	else
		printf("NTSC MODE\n");		// NTSC MODE

	return 0;
}
