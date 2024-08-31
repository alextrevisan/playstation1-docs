// stars.c
// Jum Hig 2000
// converted from starfield.c
//

#include <psxtypes.h>
#include <syscall.h>
#include <gpu.h>
#include <int.h>
#include <tmd.h>
#include "pad.h"				// my pad defines :)

RECT display;					// pixel buffer RECT

// define lifecube as external object
extern char lifecube[];


#define OT_LENGTH 5

static GsOT_TAG     zSortTable[2][1<<OT_LENGTH];   
static PACKET       cmdBuffer[2][2000];
/* Ordering table */
GsOT                worldOrderingTable[2];
PsxUInt32   		outputBufferIndex;
GsOT        		*ot;

#define SCREEN_WIDTH	320
#define SCREEN_HEIGHT	240

typedef struct{
	int x;					//star structure - has and x, y and z coordinate
	int y;
	int z;
	int x_old;				// previous star screen positions
	int y_old;	
	CILINE line;			// CILINE structure that makes a star "pixel"
}Star;

SVECTOR2D ship_pos;				// just holds ship's x and y position

#define MAX_STARS	300
#define star_w		8000	//determines the width of the area that stars 'appear' in
Star myStars[MAX_STARS];

// the life array and buffer array
#define LX	48
#define LY	48
extern char array[LX][LY];
static char array2[LX][LY];
PsxUInt8 *Img;						// pntr to blit buffer

TEXQUAD		lifeQuad;	// texture quad for life stuff
COLOR		color = { 0, 0, 0, 0 };

// pad stuff
volatile PsxUInt8   padBuf1[34], padBuf2[34];
static PsxUInt8 	pad2, pad3;

int i;					//integer used for counting
u_long pad;
int speed=4;
int quit;
int bg_on = 0;

/******** prototypes *********/
int main(void);
void InitAll(void);
void DisplayAll(void);
void InitStarField(void);
void DoStarField(void);
void HandlePad(void);
void InitLife(void);
void do_life(void);

static void UpLoadImage(TIMHEADER *timhdr);


// ********************** MAIN ***********************
int main(void) {
	PsxUInt32	obi, dxrot, dyrot, dzrot, xrot, yrot, zrot;
	MATRIX		ltm, matrix;
	PsxInt16 	sine, cosine;
	PsxInt16	dist;
	
	InitAll();					//inits system (gfx & pads)
	InitLife();
	InitStarField();			//inits starfield

	// main loop
    quit = 0;
    xrot = 0; yrot = 0; zrot = 0;
    dist = 0x1800;
    
    printf("\nStarting MAIN loop...");
	while (!quit) {
		
		// rotate scale lifecube
		yrot += 16;
		zrot += 8;
		xrot += 4;

        // Set up the primitive buffers
        outputBufferIndex = GPU_GetActiveBuff();
        ot = &worldOrderingTable[outputBufferIndex];
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);
		if(bg_on) GPU_SortTexQuad(ot, 0, &lifeQuad);
		DoStarField();			//this adds the starfield to the OT and moves the stars
		do_life();

		// Rotate cube about y axis
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

		// set translation for 1st TMD and render
		ltm.t[0] = 800;
		ltm.t[1] = 500;
       	ltm.t[2] = dist;
		// render lifecube TMD
		TMD_Render(ot, (TMDHEADER *)lifecube, &ltm, TRUE);

		// set translation for 2nd TMD and render
		ltm.t[0] = -800;
		TMD_Render(ot, (TMDHEADER *)lifecube, &ltm, TRUE);

		//FntPrint("speed=%d",speed);
		DisplayAll();
		HandlePad();					//this handles button presses on the controller pad 1
	}
}

// upload TIM to VRAM
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

// read pads
void HandlePad(void) {
	static PsxUInt16 pad;

	// get pad aggregate value
	pad2 = ~padBuf1[2];
	pad3 = ~padBuf1[3];
	pad = (PsxUInt16)(pad2 << 8 |  pad3);

	if(pad & PAD_Select) quit = 1;
	if(pad & PAD_Tri) if(speed<15) speed++; // increase starfield speed
	if(pad & PAD_X) if(speed>1) speed--;	//this decreases starfield speed
	bg_on = 0;
	if(pad & PAD_O) bg_on = 1;
}

void InitStarField(void) {
	//inits starfield
	unsigned char r, g, b;
	
	srand(77);					//init the randomiser (for creating random star allocations)
	
	for(i=0; i<MAX_STARS; i++) {			//this bit sets up each 'star' (MAX_STARS number of them)
		myStars[i].x=star_w-(rand()*(2*star_w))/(32767+1);	//set stars x-coordinate
		myStars[i].y=star_w-(rand()*(2*star_w))/(32767+1);	//set stars y-coordinate
		myStars[i].z=(rand()*(200))/(32767+1)+1;			//set stars z-coordinate 1-81 (cant be zero since +1)
		// randomly colour stars with tails a darker shade
		r = rand()%128 + 127;
		g = rand()%128 + 127;
		b = rand()%128 + 127;
		myStars[i].line.color1.r=r;
		myStars[i].line.color1.g=g;
		myStars[i].line.color1.b=b;
		myStars[i].line.color0.r=r>>1;
		myStars[i].line.color0.g=g>>1;
		myStars[i].line.color0.b=b>>1;
	} // end for
}

void DoStarField(void) {
	//this is what makes the stars 'move', it also adds the stars to the OT
	int x,y,z;
	int x_old, y_old;
	
	for(i=1;i<MAX_STARS;i++) {

		//if the star has reached you then recycle it
		if (myStars[i].z < 15) {
			myStars[i].z += 200;
			myStars[i].x = star_w-(rand()*(2*star_w))/(32767+1);	//set stars x-coordinate
			myStars[i].y = star_w-(rand()*(2*star_w))/(32767+1);	//set stars y-coordinate
			// reset tail of star
			x=(myStars[i].x) / (myStars[i].z);		//sets x value of stars
			y=(myStars[i].y) / (myStars[i].z);		//sets y value of stars
			//set tail of star
			myStars[i].x_old = x + SCREEN_WIDTH / 2;
			myStars[i].y_old = y + SCREEN_HEIGHT / 2;
		}
		
		//divide by c so that as star gets closer it seems to move faster past you
		x=(myStars[i].x) / (myStars[i].z);		//sets x value of stars
		y=(myStars[i].y) / (myStars[i].z);		//sets y value of stars
		myStars[i].z-=speed;				//moves stars toward you
		myStars[i].line.vert1.x=x+SCREEN_WIDTH/2;			//centres starfields x value onscreen
		myStars[i].line.vert1.y=y+SCREEN_HEIGHT/2;		//centres starfields y value onscreen
		myStars[i].line.vert0.x=myStars[i].x_old;
		myStars[i].line.vert0.y=myStars[i].y_old;

		//set tail of star to head of star (for next frame)
		myStars[i].x_old = myStars[i].line.vert1.x;
		myStars[i].y_old = myStars[i].line.vert1.y;

		// prevent drawing on other buffer
		if(myStars[i].y_old < 240) {
			GPU_SortCiLine(ot, 1, &myStars[i].line);	// sorts star into OT
		}
	}
}

void DisplayAll(void) {
	GPU_DrawSync();
	GPU_VSync();
	GPU_FlipDisplay();
    GPU_SortClear(outputBufferIndex ^ 1, ot, &color);
    GPU_DrawOt(ot);
    
	// upload pixel buffer to VRAM
    GPU_DrawSync();					// we NEED this!
	GPU_LoadImageData(&display, (PsxUInt16 *)Img);
}

void InitAll(void) {
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
    GPU_Init(SCREEN_WIDTH, SCREEN_HEIGHT, GsNONINTER, 0);
    GPU_DefDispBuff(0, 0, 0, SCREEN_HEIGHT);

    /* Load the font to VRAM */
    //InitFont(ninjakid, 8, 8, 16);

    /* Sync up the image uploads */
    GPU_DrawSync();
    GPU_EnableDisplay(1);

	GTE_Init(SCREEN_WIDTH, SCREEN_HEIGHT);
	
    /* Set up the order tables */
    worldOrderingTable[0].length = OT_LENGTH;
    worldOrderingTable[0].org = zSortTable[0];
    worldOrderingTable[1].length = OT_LENGTH;
    worldOrderingTable[1].org = zSortTable[1];

	printf("\nCreating 64x64 pixel buffer...");
	Img = NULL;
	Img = (PsxUInt8 *) malloc(LX * LY);
	if( Img == NULL) { 
		printf("FAILED\n");
		exit(1); 
	}

	// set up RECT for blit
	display.x = 320; display.y = 0;
	display.w = LX/2; display.h = LY;
	printf("\nUploading pixel buffer...");
	GPU_LoadImageData(&display, (PsxUInt16 *)Img);
	
}

// Set up life quad coordinates etc
void InitLife(void) {
	
	lifeQuad.color.r = lifeQuad.color.g = lifeQuad.color.b = 200;
    lifeQuad.vert0.x = lifeQuad.vert1.x = 0;
    lifeQuad.vert0.y = lifeQuad.vert2.y = 0;
    lifeQuad.vert2.x = lifeQuad.vert3.x = SCREEN_WIDTH;
    lifeQuad.vert1.y = lifeQuad.vert3.y = SCREEN_HEIGHT;
    lifeQuad.texCoords0.u = lifeQuad.texCoords1.u = 0;
    lifeQuad.texCoords0.v = lifeQuad.texCoords2.v = 0;
    lifeQuad.texCoords2.u = lifeQuad.texCoords3.u = 47;
    lifeQuad.texCoords1.v = lifeQuad.texCoords3.v = 47;
    lifeQuad.clutId = GPU_CalcClutID(0, 480);
    lifeQuad.texPage = GPU_CalcTexturePage(320, 0, 1);	 // 1 = 8bit
}


// draw life pattern to buffer and update
// NB: lots of room for OPTIMISATION!
void do_life(void) {
	int i, j, k;
	PsxUInt8 *p;
	PsxUInt8 *p1;

	p = (PsxUInt8 *)Img;
	p1 = (PsxUInt8 *)array;

	// copy array to pixel buffer
	// (copies 90 degrees, wrong, but faster)
	for(i=0; i<LX; i++) {
		k = i*LY;
		for(j=0; j<LY; j++) {
	    	Img[k+j] = array[i][j];
		}
	}
	
	// copy array to array2
   	for(i=0; i<LX; i++) {
   		for(j=0; j<LY; j++) {
   			array2[i][j] = array[i][j];
   		}
   	}

   	// process every cell in array
   	for(i=0; i<LX; i++) {
   		for(j=0; j<LY; j++) {
   			// count neighbours
   			k = 0;
   			if(array[(i-1)%LX][j] == 1) k += 1;
   			if(array[(i+1)%LX][j] == 1) k += 1;
   			if(array[i][(j-1)%LY] == 1) k += 1;
   			if(array[i][(j+1)%LY] == 1) k += 1;
   			if(array[(i-1)%LX][(j-1)%LY] == 1) k += 1;
   			if(array[(i+1)%LX][(j-1)%LY] == 1) k += 1;
   			if(array[(i-1)%LX][(j+1)%LY] == 1) k += 1;
   			if(array[(i+1)%LX][(j+1)%LY] == 1) k += 1;
   			// decide if live or dies
			if(k == 3) array2[i][j] = 1;
			else if(k != 2) array2[i][j] = 0;
   		}	// next j
   	}	// next i

	// copy array2 to array
   	for(i=0; i<LX; i++) {
   		for(j=0; j<LY; j++) {
   			array[i][j] = array2[i][j];
   		}
   	}

}

