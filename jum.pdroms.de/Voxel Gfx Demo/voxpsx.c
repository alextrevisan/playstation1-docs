// psx voxel landscape
// Jum Hig 2000

/*
TODO:
1. make sure image upload and palette are working
2. InitVox() and RenderVox() routines
3. Use GTE for calcs ???
*/

#include <psxtypes.h>
#include <syscall.h>
#include <gpu.h>
#include <int.h>
#include "pad.h"
#include "fixmath.h"

RECT display;
static TEXQUAD      bgQuad, fontQuad;
static CITEXQUAD	myQuad, anQuad;

#define OT_LENGTH 5

static GsOT_TAG     zSortTable[2][1<<OT_LENGTH];   
static PACKET       cmdBuffer[2][1000];
/* Ordering table */
GsOT                worldOrderingTable[2];
PsxUInt32   outputBufferIndex;
GsOT        *ot;

// height map, colour map and palette
extern char hmap[], cmap[], demotim[];

volatile PsxUInt8   padBuf1[34], padBuf2[34];
static PsxUInt8 pad2, pad3;
static PsxUInt32 VSC, oldVSC;


/** Various variables ****************************************/
#define WIDTH  256
#define HEIGHT 240

#define VOXWIDTH 	256
#define VOXHEIGHT	240
#define MAXDIST		256
#define FOCALDIST	(64<<16)
#define	SDF			(1<<16)				// spherical distortion factor
#define HVA			512				// half view angle
#define VOXSCALE	(10<<16)

PsxUInt8 *Img;						// pntr to blit buffer
int quit, eye_height;

static void
UpLoadImage(TIMHEADER *timhdr)
{
    TIMCLUT     *clut;
    TIMIMAGE    *image;

    /* Get the components of the image */
    clut = GPU_TIMGetClut(timhdr);
    image = GPU_TIMGetImage(timhdr);

    /* Load the image up to the playstation */
    if (clut)
    {
        GPU_LoadImageData(&clut->vRamPos, clut->clutData);
    }
    if (image)
    {
        GPU_LoadImageData(&image->vRamPos, image->imageData);
    }
}


/** InitPSX *****/
int InitPSX(void)
{
  int J,I;

  /* Open display */

// put PSX screen init here
	printf("Initializing PSX:\n  Opening display...");

    /* Initialise PAD stuff */
    InitPAD(padBuf1, 34, padBuf2, 34);
    StartPAD();

    /* Install the interrupt handler */
    INT_SetUpHandler();

    /* Sort out the GPU!!! */
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
    GPU_Reset(0);
    GPU_Init(256, 240, GsNONINTER, 0);
    GPU_DefDispBuff(0, 0, 0, 240);

    /* Load the font to VRAM */
    //InitFont(ninjakid, 8, 8, 16);

    /* Sync up the image uploads */
    GPU_DrawSync();
    GPU_EnableDisplay(1);

	GTE_Init(256,240);
	
	printf("\nCreating buffer...");
	Img = NULL;
	Img = (PsxUInt8 *) malloc(WIDTH * HEIGHT);
	if( Img == NULL) { 
		printf("FAILED\n");
		return (1); 
	}

	display.x = 320; display.y = 0;
	display.w = WIDTH; display.h = HEIGHT;
	GPU_LoadImageData(&display, Img);

	// upload palette (is with TIM file :)
	// piccy at 320,0  - clut at 0, 500
    UpLoadImage((TIMHEADER *)demotim);		// note char[] cast to TIMHEADER *
	

	// clear buffer
	memset(Img, 0x00, WIDTH*HEIGHT);

    /* Set up the order tables */
    worldOrderingTable[0].length = OT_LENGTH;
    worldOrderingTable[0].org = zSortTable[0];
    worldOrderingTable[1].length = OT_LENGTH;
    worldOrderingTable[1].org = zSortTable[1];

	return 0;
}

/** TrashMachine() *******************************************/
void TrashMachine(void)
{
	printf("Shutting down...\n");

	// not much to be done on PSX shutdown :)
	free(Img);
}


/** PutImage() ***********************************************/
/** Copy image to VRAM.                             **/
/*************************************************************/
inline void PutImage(void)
{
	int i;
	
	// count frames between updates
	VSC = INT_GetVSyncCount();
	printf("frames %d  eye_height %d\n", VSC-oldVSC, eye_height);
	oldVSC = VSC;
	// blit buffer to VRAM
	GPU_LoadImageData(&display, Img);
	
}

/** Joysticks ************************************************/
/** Check for keyboard events, parse them, and modify       **/
/** joystick controller status                              **/
/*************************************************************/
void Joysticks(void)
{
  static PsxUInt16 pad;

  // get pad aggregate value
  pad2 = ~padBuf1[2];
  pad3 = ~padBuf1[3];
  pad = (PsxUInt16)(pad2 << 8 |  pad3);
// debug
//printf("Pad: %04X\n", pad);



	if(pad & PAD_Select) quit = 1;
	if(pad & PAD_Up) eye_height += 1;
	if(pad & PAD_Down) eye_height -= 1;
}

// render all lines of a voxelmap
void RenderVox(PsxUInt8 *voxbuffer, fixed ex, fixed ey,
	fixed ez, fixed eyerotn)
{
	int i, j, k, t1, t2, yline;
    fixed tx, ty , tdx, tdy;		// working texture co-ords
    fixed tp1x, tp1y, tp2x, tp2y;	// texture side co-ords and step
    fixed sy0;						// scanline, initial scanline
    fixed d, ph;						// dist to projected point
    fixed pp;							// scale / distance
    fixed fscreenwidth;
    int colgrad;			// colour & colour gradient
    unsigned char h, colour;
    int scanline;
    // for interpolating height map:
    unsigned char ix, iy;						// current "hexel"
    fixed fx, fy;					// current hexel "floor"
    fixed fhincellx, fhincelly;				// coo-rds of pt within hexel
    fixed ha, hb;							// intepolated heights
    fixed h1, h2, h3, h4;
	char *pstartvline8;
	PsxUInt8 *ppixel;
	int toppest[VOXWIDTH];

    fscreenwidth = itofix(VOXWIDTH);

	// find starting scanline using maxdist and current height
	//sy0 = (FOCALDIST * ez) / MAXDIST;

	// clear highest array
	for(i=0; i<VOXWIDTH; i++) {
		toppest[i] = 240;
	}

	// loop thru scanlines
	for(i = VOXHEIGHT / 2 -1; i > 3; i--) {

       	// find distance in texture at this scanline
		d = fdiv(fmul(FOCALDIST, ez), itofix(i));			// *** optimise

        // find left side tex pt
		tp1x = ex + fmul(d, GTE_Cos(eyerotn + HVA)<<4);
		tp1y = ey + fmul(d, GTE_Sin(eyerotn + HVA)<<4);

		// find right side view angle
		tp2x = ex + fmul(d, GTE_Cos(eyerotn - HVA)<<4);
		tp2y = ey + fmul(d, GTE_Sin(eyerotn - HVA)<<4);

        // find texture step value
        tdx = fdiv(fsub(tp2x, tp1x), fscreenwidth);
        tdy = fdiv(fsub(tp2y, tp1y), fscreenwidth);

		// render this scanline (optimise!)
        tx = tp1x; ty = tp1y;
        scanline =  i + VOXHEIGHT/2;
        //ppixel = voxbuffer + scanline*512;		// for floormapping
        //pp = fdiv(VOXSCALE, d);				// very slow!
        pp = VOXSCALE / (d>>16);

		// draw line without smoothing
        // PSX won't handle smoothing calc's as well!!!
        for(j = 0; j < VOXWIDTH; j++) {
        	// check if current pixel on heightmap
       		ix = tx >> 16;
       		iy = ty >> 16;
            //ix = ix & 255;			// clip maps
            //iy = iy & 255;
          	h = hmap[(iy << 8) + ix];
	        colour = cmap[(iy << 8) + ix];
            //t1 = scanline - fixtoi(fmul(pp, h<<16));	// calc height of line
	        t1 = scanline - fixtoi(pp * h);
			//if(t1 < 0) t1 = 0;						// clip to top of buffer

			// ------ floor-mapping code
			// *ppixel++ = colour;
	        // ------ end of floor-mapping code
			

			// ------ vertical line-drawing code
       	    // only draw if above highest currently visible point
           	// in this column
            if(toppest[j] > t1) {
            	iy = toppest[j] - t1;
				ppixel = voxbuffer + t1*512 + j;
				while(iy) { 
       	          	*ppixel = colour;
       	          	ppixel += 512;
       	          	iy--;
                }
           		toppest[j] = t1;
                //lastcol[j] = colour;			// was used for smoothing
            }
			// ------ end of vertical line-drawing code
            
			tx += tdx;							// careful - these are fixed-pt
			ty += tdy;
		}	// next j (next column)

	}	// next i (next row)


}

// MAIN
int main(void) {
    COLOR               color = {64, 0, 0, 0};
	int i, x;
	PsxUInt16 *p;

	InitPSX();

    myQuad.color0.r = myQuad.color0.g = 40;
    myQuad.color0.b = 40;
    myQuad.color1.r = myQuad.color1.g = myQuad.color1.b = 128;
    myQuad.color2.r = myQuad.color2.g = 40;
    myQuad.color2.b = 40;
    myQuad.color3.r = myQuad.color3.g = myQuad.color3.b = 128;
    myQuad.vert0.x = myQuad.vert1.x = 0;
    myQuad.vert0.y = myQuad.vert2.y = 0;
    myQuad.vert2.x = myQuad.vert3.x = 256;
    myQuad.vert1.y = myQuad.vert3.y = 240;
    myQuad.texCoords0.u = myQuad.texCoords1.u = 0;
    myQuad.texCoords0.v = myQuad.texCoords2.v = 0;
    myQuad.texCoords2.u = myQuad.texCoords3.u = 255;
    myQuad.texCoords1.v = myQuad.texCoords3.v = 239;
    myQuad.clutId = GPU_CalcClutID(0, 500);
    myQuad.texPage = GPU_CalcTexturePage(320, 0, 1);

	// this quad is unused in height-mapping demo
    anQuad.color0.r = anQuad.color0.g = anQuad.color0.b = 128;
    anQuad.color1.r = anQuad.color1.g = anQuad.color1.b = 40;
    anQuad.color2.r = anQuad.color2.g = anQuad.color2.b = 128;
    anQuad.color3.r = anQuad.color3.g = anQuad.color3.b = 40;
    anQuad.vert0.x = anQuad.vert1.x = 0;
    anQuad.vert0.y = anQuad.vert2.y = 0;
    anQuad.vert2.x = anQuad.vert3.x = 256;
    anQuad.vert1.y = anQuad.vert3.y = 120;
    anQuad.texCoords0.u = anQuad.texCoords1.u = 0;
    anQuad.texCoords0.v = anQuad.texCoords2.v = 239;
    anQuad.texCoords2.u = anQuad.texCoords3.u = 255;
    anQuad.texCoords1.v = anQuad.texCoords3.v = 121;
    anQuad.clutId = GPU_CalcClutID(0, 500);
    anQuad.texPage = GPU_CalcTexturePage(320, 0, 1);

	quit = 0;
	eye_height = 50;
	x = 0;
	while(!quit) {
		x += 1;

//		RenderVox(PsxUInt16 *voxbuffer, fixed ex, fixed ey,
//					fixed ez, fixed eyerotn)
		// render voxel to buffer
		RenderVox(Img, itofix(x), itofix(30), itofix(eye_height), itofix(0));

		// upload buffer to texture page
		PutImage();

		// clear buffer (NB: memset very slow!)
		//memset(Img, 0x00, WIDTH*HEIGHT);
		p = (PsxUInt16 *)Img;
		for(i=61440;i;i--) *p++ = 0;

        // Set up the primitive buffers
        outputBufferIndex = GPU_GetActiveBuff();
        ot = &worldOrderingTable[outputBufferIndex];
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);

        // Set up the clear for the next frame
        //GPU_SortClear(outputBufferIndex ^ 1, ot, &color);

		// draw texture quad to screen 
	    GPU_SortCiTexQuad(ot, 2, &myQuad);
	    //GPU_SortCiTexQuad(ot, 2, &anQuad);

        GPU_DrawSync();
        //GPU_VSync();
        GPU_FlipDisplay();

        // draw prim buffers
        GPU_DrawOt(ot);

        Joysticks();			// read joypad
	} // wend

	return 0;
}
