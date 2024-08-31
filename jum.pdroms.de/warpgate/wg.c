// wg.c			-- "WARPGATE"
// Jum Hig 2000
//

// Notes:
// 1. Clear all SPU buffer to 0 during SPU init (may stop clicks)

#include <psxtypes.h>
#include <syscall.h>
#include <gpu.h>
#include <int.h>
#include <tmd.h>
#include <font.h>
#include <libspu.h>				// for sound
#include <hitmud.h>				// for MODplayer
#include "pad.h"				// my pad defines :)
#include "wg.h"
#include "text.h"				// text data for story & credits
#include "colours.h"			// for colour-cycling

/* SPU sound buffer address for transfers from CPU */
#define SPU_SB_ADDR             ((PsxUInt16 *)0x1F801DA6)
#define SPU_DATA                ((PsxUInt16 *)0x1F801DA8)

#define BSPEED_X	100
#define BSPEED_Y	70

// incorporate landscape generator into this proggie :)
#include "land.h"				// landscape

// define texture map for sprites as external object
extern char sg256[];
extern char ninjakid[];

// and of course the MOD
extern char warpmod[];

// sound effects
extern char alfire[];			// 2544 bytes
extern char plfire[];			// 3776 bytes
extern char wark[];				// 18208 bytes
extern char warpin[];			// 40560 bytes
extern char lowfire[];			// 3776 bytes
extern char helpme[];			// 18032 bytes
extern char thankyou[];			// 10992 bytes
extern char splat[];			// 5856 bytes
extern char bnoise[];			// 50432 bytes
extern char explode1[];			// 31872 bytes

#define OT_LENGTH 5

static GsOT_TAG     zSortTable[2][1<<OT_LENGTH];   
static PACKET       cmdBuffer[2][2000];
/* Ordering table */
GsOT                worldOrderingTable[2];
PsxUInt32   		outputBufferIndex;
GsOT        		*ot;

#define SCREEN_WIDTH	320
#define SCREEN_HEIGHT	240

#define WORLD_WIDTH		524288

static HITMUD themod;

// primitives
DOT			pix;
LINE		line;
CILINE		ciline;
SPRITE		sprite, radar, panel;
SPRITE8		sprite8;
SPRITE16	sprite16;
TEXQUAD		testQuad;
COLOR		color = { 0, 0, 0, 0 };

// pad stuff
volatile PsxUInt8   padBuf1[34], padBuf2[34];
static PsxUInt8 	pad2, pad3;
static PsxUInt16	pad, prevpad;

//int i;					//integer used for counting
short quit;
int score;

#define MAX_OBJECTS	256
int obj_max;					// last object
WG_OBJECT obj[MAX_OBJECTS];
WG_OBJECT player;				// 2 player ???
uint window_x;

// texture coordinates for sprite bitmaps
TEXCOORDS texcoord[50] = {
	0, 0,		// empty
	0, 16,		// LANDER
	192, 48,	// MUTANT
	64, 16,		// BAITER
	64, 32,		// BOMBER
	64, 48,		// POD
	128, 16,	// SCHWARMA
	144, 0,		// FRAG
	192, 16,	// HOOMIN
	0, 64,		// SCORE
	128, 0,		// BULLET
	0, 48,		// MINE
	0, 0,		// PLAYER_RIGHT
	16, 0,		// PLAYER_LEFT
	64, 0,		// FLAME_RIGHT
	192, 0,		// FLAME_LEFT
	96, 64,		// SMART_BOMB
	112, 64,	// SHIPS_LEFT
	0, 0		//
};

// level sequencing stuff
int level;
OBJSEQ objseq;					// object sequence control
// level data
#include "levels.h"
// pointers to levels
OBJSEQ_EVENT *plevel[8] = {
	 level1, level2, level3, level4, level5, level6, level4, level4
}; 

// no of fragments per object
ushort num_frags[50] = {
	0,		// empty
	16,		// LANDER
	24,		// MUTANT
	28,		// BAITER
	28,		// BOMBER
	32,		// POD
	5,		// SCHWARMA
	0,		// FRAG
	7,		// HOOMIN
	0,		// SCORE
	0,		// BULLET
	0,		// MINE
	48,		// PLAYER_RIGHT
	48,		// PLAYER_LEFT
	0,		//
};

// score per object
ushort points[16] = {
	0,		// empty
	150,	// LANDER
	150,	// MUTANT
	200,	// BAITER
	250,	// BOMBER
	1000,	// POD
	150,	// SCHWARMA
	0,		// FRAG
	0,		// HOOMIN
	0,		// SCORE
	0,		// BULLET
	0		// MINE
};

// object colours in radar
COLOR dotcolour[16] = {
	{ 0, 0, 0, 0 },		// empty
	{ 0, 255, 0, 0 },	// LANDER
	{ 255, 255, 0, 0 },	// MUTANT
	{ 0, 0, 255, 0 },	// BAITER
	{ 255, 128, 0, 0 },	// BOMBER
	{ 255, 0, 0, 0 },	// POD
	{ 128, 0, 0, 0 },	// SCHWARMA
	{ 0, 0, 0, 0 },		// FRAG
	{ 128, 128, 128 },	// HOOMIN
	{ 0, 0, 0, 0 },		// SCORE
	{ 0, 0, 0, 0 },		// BULLET
	{ 128, 0, 255 },	// MINE
	{ 255, 255, 255 },	// PLAYER RIGHT
	{ 255, 255, 255 }	// PLAYER LEFT
};

// LASER object for player firing
#define NUMLASERS	4
LASER laser[NUMLASERS];

// stars setup
#define NUM_STARS	120
typedef struct {
	int x;
	int y;
	unsigned char r, g, b;
	unsigned char brightness;
} BG_STAR;

BG_STAR star[NUM_STARS];

// game variables
ushort starthuman, num_humans, humans_left;
ONSCREEN onscreen[1000];		// > 1000 objects onscreen will crash game!
int num_onscreen;
int num_landers_left;			// for checking for end-of-level

// SFX stuff
#define NUM_SAMPLES	10
#define ALIENFIRE	8
#define PLAYERFIRE	9
#define WARK		10
#define WARPIN		11
#define LOWFIRE		12
#define HELPME		13
#define THANKYOU	14
#define SPLAT		15
#define THRUST		16
#define EXPLODE1	17

SAMPLE sfx[NUM_SAMPLES] = {
//  data    sb_addr  len   pitch
	alfire, 0x10000, 2544, 0x1000,
	plfire, 0x11000, 3776, 0x1000,
	wark,	0x12000, 18208,0x1000,
	warpin, 0x17000, 40560,0x1000,
	lowfire,0x21000, 3776, 0x1000,
	helpme, 0x22000, 18032,0x1000,
	thankyou,0x27000,10992,0x1000,
	splat,	0x3A000, 5856, 0x1000,
	bnoise, 0x3C000, 50432,0x1000,
	explode1,0x49000,31872,0x600
};

// misc
char mystring[80];


/******** prototypes *********/
int main(void);
void InitAll(void);
void InitStars(void);
void DisplayAll(void);
void HandlePad(void);
int DoTitle(void);
int DoGame(void);
int DoStory(void);
int DoCredits(void);
int CheckHit(void);
void DoLand(ushort offset);
void DrawStars(ushort offset);
void DrawScore(int score, short l, short b);
void DrawSprite(ushort type, ushort x, ushort y, int frame);
void AddHumans(ushort numhumans);
int FindClosestHuman(uint x);
void InitLasers(void);
void DoLasers(void);
void DrawLasers(void);
void DoSmartBomb(void);
static void UpLoadImage(TIMHEADER *timhdr);
int DoStory(void);
int DoCredits(void);
int DoHiscore(void);
char *itoa(int n);

// ********************** MAIN ***********************
int main(void) {
	int i;
	
	InitAll();					//inits system (gfx & pads)

	// upload sprite texture page
	UpLoadImage((TIMHEADER *)sg256);

	// Flag MOD as not playing so that it starts up in Title
	themod.MasterVol = 0;

	

	// we loop through title, story and credits screens
	// until player presses start (2 is returned from Do_Title())
	while(1) {
		i = DoTitle();
		if(i == 2) { DoGame(); DoHiscore(); DoTitle(); }
		if(i != 2) DoStory(); else DoGame();
		i = DoTitle();
		if(i == 2) { DoGame(); DoHiscore(); DoTitle(); }
		if(i != 2) DoCredits(); else DoGame();
		i = DoTitle();
		if(i == 2) { DoGame(); DoHiscore(); DoTitle(); }
		if(i != 2) DoHiscore(); else DoGame();
	}
	
	return 0;
}

int DoGame(void) {
	int i, j, k, nob, levelcomplete, count, counter;
	int numlives, numsmartbombs;
	int flameframe;
	ushort lo;
	ushort prev_fire, prev_sb;
	char *pc;
	
	// setup sprite primitive
	sprite16.color.r = sprite16.color.g = sprite16.color.b = 128;
	sprite16.color.pad = 0x7c;	// 16x16 sprite GPU prim
	sprite16.vert.x = 40;
	sprite16.vert.y = 160;
    sprite16.texCoord.u = 0;
    sprite16.texCoord.v = 0;
    sprite16.clutId = GPU_CalcClutID(0, 481);

	// set up texture quad (just to set texture page!)
    testQuad.vert0.x = testQuad.vert1.x = 800;
    testQuad.vert0.y = testQuad.vert2.y = 0;
    testQuad.vert2.x = testQuad.vert3.x = 805;
    testQuad.vert1.y = testQuad.vert3.y = 5;
    testQuad.texCoords0.u = testQuad.texCoords1.u = 0;
    testQuad.texCoords0.v = testQuad.texCoords2.v = 0;
    testQuad.texCoords2.u = testQuad.texCoords3.u = 16;
    testQuad.texCoords1.v = testQuad.texCoords3.v = 16;

    // set up sprite for radar
	radar.color.r = radar.color.g = radar.color.b = 128;
	radar.color.pad = 0x7c;	// 16x16 sprite GPU prim
	radar.vert.x = 80;
	radar.vert.y = 0;
	radar.w = 160; radar.h = 32;
    radar.texCoord.u = 80;
    radar.texCoord.v = 96;
    radar.clutId = GPU_CalcClutID(0, 481);

    // set up sprite for radar
	panel.color.r = panel.color.g = panel.color.b = 96;
	panel.color.pad = 0x7c;	// 16x16 sprite GPU prim
	panel.vert.x = 0;
	panel.vert.y = 0;
	panel.w = 80; panel.h = 32;
    panel.texCoord.u = 0;
    panel.texCoord.v = 96;
    panel.clutId = GPU_CalcClutID(0, 481);

    // set up ciline for laser;
    ciline.color0.r = 64;
    ciline.color0.g = 0;
    ciline.color0.b = 0;
    ciline.color1.r = 255;
    ciline.color1.g = 255;
    ciline.color1.b = 0;

	// switch off MOD voices
    for(i=0; i<8; i++) SPU_VoiceVol(i, 0, 0);

	score = 0; level = 0; numlives = 3; numsmartbombs = 3;

	// main loop
    prev_fire = 0; prev_sb = 0;
    printf("\nStarting game loop...");
    //printf("\nFirst human object: %d   No. humans: %d", starthuman, num_humans); 
    //printf("\nobj_max = %d", obj_max);
	while (level < 8) {

		// set up level
		InitStars();
	    InitObjects();
		// set up player ( = object 0)
    	i = AddObject(PLAYER_RIGHT, 1000 << 8, 100 << 8);
    	obj[0].dx = 256; obj[0].dy = 0;
		InitSeq( plevel[level] );	// this level
		printf("Level sequencer set to level %d\n", level);
		InitLasers();
		starthuman = i+1;
		humans_left = num_humans = 10;				// always 10?
		AddHumans(num_humans);
		flameframe = 0;

		// set up THRUST noise
		SPU_VoiceVol(THRUST, 0x200, 0x200);
		SPU_VoicePitch(THRUST, 0x1000);
		SPU_VoiceADSR(THRUST, 20, 8, 10, 0, 10);	// no fade		
		SPU_VoiceOn(THRUST);

		// DEBUG
	    //printf("\nFirst human object: %d   No. humans: %d", starthuman, num_humans); 
    	//printf("\nobj_max = %d", obj_max);

		// level stuff
		levelcomplete = 1;					// state 1 = running, state 2 = end of level
		while(levelcomplete) {

			num_onscreen = 0;
			flameframe = (flameframe + 1) % 4;

        	// Set up the primitive buffers
        	outputBufferIndex = GPU_GetActiveBuff();
        	ot = &worldOrderingTable[outputBufferIndex];
        	GPU_ClearOt(0, 0, ot);
        	GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);

        	// ************ NOTE ABOUT SPRITES *************
        	// Sprites use "current" texture page, which is set
        	// by any command which has info about texture page
        	// THIS IS ALSO AFFECTED BY ORDER OF OBJECT IN ORDER TABLE
        	// so basically we have to make sure that the right texture
        	// page is accessed first (or be smart and use a texpage
        	// select command).
        	GPU_SortTexQuad(ot, 1, &testQuad);

			// this has to be here to be draw in front of panel
			DrawScore(score, numlives, numsmartbombs);		// draws score and lives and bombs

			GPU_SortSprite(ot, 2, &radar);
			panel.vert.x = 0;
			GPU_SortSprite(ot, 2, &panel);
			panel.vert.x = 240;
			GPU_SortSprite(ot, 2, &panel);
		
			// set object "window" to player x posn.
        	window_x = (obj[0].x - 38912 + obj[0].dx * 25) % 524288;

			// normal state only stuff
			if(levelcomplete == 1) {
	        	// update object sequencer
    	    	i = DoSeq();

        		// update object's positions and draw them
				nob = DoObjects();

			}
			
			i = DrawObjects();
			//printf("\nnum_objs: %d   num_landers_left: %d", nob, num_landers_left);

			// normal state only stuff
			if(levelcomplete == 1) {
				DoLasers();
				DrawLasers();
			}
			
			DoLand(window_x >> 8);			// draws landscape
			DrawStars(window_x >> 8);		// draws BG stars

			if(levelcomplete == 2) {
				// generate display
				SetCharLight(128, 128, 128);
				PrintString(ot, 3, 88, 80, "LEVEL    COMPLETE");
				pc = itoa(level+1) + 4;
				PrintString(ot, 3, 136, 80, pc);	// pc set up before
				j = counter / 20;
				if(j > count) j = count;
				for(i=0; i<j; i++) DrawSprite(HUMAN, 88 + i*10, 120, 0);
				counter++;
				// play counting sound and inc score
				if( ((counter % 20) == 0) && ( j < count ) ) {
					SPU_VoiceOn(SPLAT);
					score += 100;
				}
				if(counter == 500) {
					levelcomplete = 0;
					SPU_VoicePitch(SPLAT, 0x1000);
				}
			}

			//DisplayAll();

			// more normal state only stuff
			if( (levelcomplete == 1) && (obj[0].state == 1) ) {
				// handle controller
				HandlePad();					//this handles button presses on the controller pad 1
				if(pad & PAD_Select) quit = 1;
				// up + down
				if(pad & PAD_Down) {
					if(obj[0].dy != 512) obj[0].dy += 32;
				}
				else {
					if(pad & PAD_Up) {
						if(obj[0].dy != -512) obj[0].dy -= 32;
					}
					else {
						if(obj[0].dy > 0) obj[0].dy -= 32;
						else if(obj[0].dy < 0) obj[0].dy += 32;
					}
				}
				// left + right
				if(pad & PAD_Right) {
					obj[0].type = PLAYER_RIGHT;
					if(obj[0].dx < 1024) obj[0].dx += 32;
					SPU_VoiceVol(THRUST, 0x600, 0x400);
					sprite16.color.r = sprite16.color.g = sprite16.color.b = 128;
					DrawSprite(FLAME_RIGHT, ((obj[0].x - window_x) >> 8) - 16, obj[0].y >> 8, flameframe);

				}
				else {
					if(pad & PAD_Left) {
						obj[0].type = PLAYER_LEFT;
						if(obj[0].dx > -1024) obj[0].dx -= 32;
						SPU_VoiceVol(THRUST, 0x400, 0x600);
						sprite16.color.r = sprite16.color.g = sprite16.color.b = 128;
						DrawSprite(FLAME_LEFT, ((obj[0].x - window_x) >> 8) + 16, obj[0].y >> 8, flameframe);
					}
					else {
						// friction slowdown
						//if(obj[0].dx > 0) obj[0].dx -= 2;
						//else if(obj[0].dx < 0) obj[0].dx += 2;
						SPU_VoiceVol(THRUST, 0x200, 0x200);
					}
				}
		
				// fire
				if(pad & PAD_X) {
					if(!prev_fire) {
						// fire laser
						for(i=0; i<NUMLASERS; i++) {
							if(laser[i].y == 0) {
								SPU_VoiceOn(PLAYERFIRE);
								laser[i].y = (obj[0].y >> 8) + 5;
								laser[i].headx = 160 - obj[0].dx / 10;
								laser[i].tailx = laser[i].headx;
								if(obj[0].type == PLAYER_RIGHT) {
									laser[i].headdx = 16;
									laser[i].taildx = 8;
								}
								else {
									laser[i].headdx = -16;
									laser[i].taildx = -8;
								}
								i = 99;
							}
						}
						prev_fire = 1;
					}
				}
				else prev_fire = 0;

				// smart bomb
				if(pad & PAD_O) {
					if(!prev_sb) {
						// trigger smart bomb
						if(numsmartbombs) {
							DoSmartBomb();
							numsmartbombs--;
						}
						prev_sb = 1;
					}
				}
				else prev_sb = 0;

				// check for end-of-level
				if(num_landers_left == 0) {
					if(obj_max > 20) {			// did we have some objs already?
						levelcomplete = 3;
						//level++;
					}
				}

				// check for player hit
				i = CheckHit();
				//printf("CheckHit() = %d\n", i);
				if( i ) {
					j = onscreen[i].index;
					// is this a human?
					if( obj[j].type == HUMAN ) {
						// check if this human is falling
						if( obj[j].state == 3 ) {
							SPU_VoiceOn(THANKYOU);
							printf("Human %d caught!\n", j);
							obj[j].state == 4;		// switch human to caught mode
							obj[j].counter = 0xFFFF;
							obj[j].y = obj[0].y + 256;
							score += 200;
						}
					}
					else {
						// kill player and object bumped into
						obj[j].type = 0;			// kill enemy object
						
						obj[0].state = 2;			// first explode state
						obj[0].dy = 0;
						obj[0].counter = 16;		//
						SPU_VoiceOn(EXPLODE1);
						// create a few fragments
						for(j=0; j < 15; j++) {
							k = AddObject(FRAGMENT, obj[0].x, obj[0].y);
							if(k != -1) {
								obj[k].counter = 48;
								obj[k].state = 99;
								obj[k].dx = rand()%2048 - 1024;
								obj[k].dy = rand()%2048 - 1024;
							}
						} // next j
						numlives--;
						// exit if all lives finished
						if(numlives < 0) {
							levelcomplete = 0;
							level = 999;
						}

					}
				}
				
			} // end if levelcomplete == 1
			else
			{
				if(levelcomplete == 3) {
			
					// count number of humans remaining
					count = 0;
					for(i=0; i<=obj_max; i++) {
						if(obj[i].type == HUMAN) count++;
					}
// DEBUG
printf("%d humans left.\n", count);
					levelcomplete = 2;
					counter = 0;
					SPU_VoicePitch(SPLAT, 0x2000);    // higher splat for counting
					SPU_VoiceVol(THRUST, 0, 0);
				}
			}

			DisplayAll();

		} // wend levelcomplete

		level++;
		numsmartbombs++;				// get an extra smart bomb

	} // wend level < 40

	return 0;							// back to "main"
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

	// get pad aggregate value
	pad2 = ~padBuf1[2];
	pad3 = ~padBuf1[3];
	pad = (PsxUInt16)(pad2 << 8 |  pad3);
}



// update display
void DisplayAll(void) {
	GPU_DrawSync();
	GPU_VSync();
	GPU_FlipDisplay();
    GPU_SortClear(outputBufferIndex ^ 1, ot, &color);
    GPU_DrawOt(ot);
}

// Initialise GFX and PADS
void InitAll(void) {
	int i, J,I;

	printf("Initializing PSX:\n  Opening display...");

    // Initialise PAD stuff
    InitPAD(padBuf1, 34, padBuf2, 34);
    StartPAD();

    // Install the interrupt handler (for vsync and pads)
    INT_SetUpHandler();

	// check for PAL or NTSC mode and set as required
	// code from ogre
	// hopefully this will allow demo to work on both
	// PAL and NTSC machines
    printf("Detected video mode: "); 
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
    InitFont((TIMHEADER *)ninjakid, 8, 8, 16);

    /* Sync up the image uploads */
    GPU_DrawSync();
    GPU_EnableDisplay(1);

	GTE_Init(SCREEN_WIDTH, SCREEN_HEIGHT);
	
    /* Set up the order tables */
    worldOrderingTable[0].length = OT_LENGTH;
    worldOrderingTable[0].org = zSortTable[0];
    worldOrderingTable[1].length = OT_LENGTH;
    worldOrderingTable[1].org = zSortTable[1];

	// Initialise SPU (may be unneccessary)
	SPU_Reset();
	SPU_Init(0);
	SPU_Enable();
	i = SPU_Wait();

	// fill SPU with 0
	// do we need to set up SPU_CNTL first?
	printf("Zeroing SPU buffer...\n");	
	*SPU_SB_ADDR = 0;
	for(i=0;i<262144;i++) *SPU_DATA = 0;

	// upload samples into 2nd half of SPU mem
	// NB: sample lengths need to have 64 added (bug in SPU lib?)
	//void SPU_UploadData(PsxUInt32 *src_addr, PsxUInt32 sb_addr, PsxUInt32 size);
	for(i=0; i<NUM_SAMPLES; i++) {
		SPU_UploadData(sfx[i].data, sfx[i].sb_addr, sfx[i].length + 64);
		SPU_VoiceSetData(i+8, sfx[i].sb_addr);
		SPU_VoiceVol(i+8, 0x2000, 0x2000);
		SPU_VoicePitch(i+8, sfx[i].pitch);
	}
	// test
	SPU_Volume(0x2000, 0x2000);
	//SPU_VoiceOn(HELPME);
	
}


// initialise objects in object list
void InitObjects(void) {
	int i;

	obj_max = 0;
	for(i=0; i<MAX_OBJECTS; i++) {
		obj[i].type = 0;
		obj[i].x = 0;
		obj[i].y = 0;
		obj[i].state = 0;				// some default values
		obj[i].counter = 0;
		obj[i].d1 = 0;
		obj[i].d2 = 0;
		obj[i].d3 = 0;
		obj[i].frame = 0;
		obj[i].numframes = 1;
	}
}

// setup stars
void InitStars(void) {
	int i;

	for(i=0; i<NUM_STARS; i++) {
		star[i].x = rand() % 512;
		star[i].y = 34 + rand() % 144;
		star[i].r = rand() % 96;
		star[i].g = rand() % 64;
		star[i].b = rand() % 96;
		star[i].brightness = rand() % 256;
	}
}

// add an object to the object list
// ---> this is a pretty clumsy way to handle
// objects. A better way may be to keep track of
// the lowest free object. ???
int AddObject(ushort type, uint x0, uint y0) {
	int i, retval;

	// can reserve the lowest few objects for player and
	// lasers etc
	retval = -1;
	// - find place to add object
	for(i=0; i<MAX_OBJECTS; i++) {
		if(!obj[i].type) {					// object type = 0
			// add object to list here
			// and set default values
			obj[i].type = type;
			obj[i].x = x0;
			obj[i].y = y0;
			obj[i].dy = 0;					// prevents funnies
			obj[i].dx = 0;					//
			obj[i].state = 0;				// some default values
			obj[i].counter = 48;			// good val for warp-in
			obj[i].d3 = 0xFFFF;				// switch off shooting
			obj[i].frame = 0;
			obj[i].numframes = 1;
			// type-specific init here
			switch(type) {
				case LANDER :
					obj[i].d3 = 240;
					obj[i].numframes = 4;
					break;
				case MUTANT :
					break;
				case BAITER :
					obj[i].d3 = 240;
					obj[i].numframes = 4;
					break;
				case BOMBER :
					obj[i].d3 = 300;
					obj[i].numframes = 8;			// 8 frames for bomber!!!
					break;
				case MINE :
					obj[i].state = 1;				// no warp-in for mines
					obj[i].numframes = 4;
					break;
				case POD :
					obj[i].counter = 60;
					obj[i].numframes = 4;
					break;
				case SWARMER :
					obj[i].state = 1;				// no warp-in for swarmers
					obj[i].counter = 0xFFFF;
					obj[i].numframes = 4;
					break;
				case HUMAN :
					obj[i].numframes = 4;
					break;
				case FRAGMENT :
					break;
				case BULLET :
					obj[i].state = 1;				// no warp-in for bullets
					break;
			} // end switch
			retval = i;						// return index
			if(i > obj_max) obj_max = i;	// update hi index
			i = 9999;						// bomb out of loop 
		}
	}

	// if not succesful, return -1
	return retval;
}

// check if player has been hit
int CheckHit(void) {
	int i, j, k, n, o, t;
	int x, y;

	x = onscreen[0].x;		// get player's position
	y = onscreen[0].y;

	// check if player has hit anything
	for(j=1; j<num_onscreen; j++) {
		// check vertical overlap
		if(abs(y - onscreen[j].y) < 8) {
			// check horizontal overlap
			if(abs(x - onscreen[j].x) < 12) {
				// hit!
				return j;
			} // end if x coincide
			
		} // end if y coincide
	} // next j

	return 0;
}


// Draw all objects in the object list
int DrawObjects(void) {
	int i, c, count, pdx;
	ushort type;
	uint dx, y;

	pix.color.r = pix.color.g = 255;
	pix.color.b = 0;

	pdx = obj[0].dx * 25;
	
	// draw objects that are active
	count = 0;
	for(i=0; i<=obj_max; i++) {
		if(obj[i].type) {					// object type > 0
			// draw object in radar first (no fragments though)
			if( (obj[i].type != FRAGMENT) && (obj[i].type != BULLET) ) {
				dx = ((obj[i].x + 262144 - (obj[0].x + pdx)) % WORLD_WIDTH) / 3276; 			
				pix.vert.x = dx+80;
				pix.vert.y = obj[i].y >> 11;
				pix.color.r = dotcolour[obj[i].type].r;
				pix.color.g = dotcolour[obj[i].type].g;
				pix.color.b = dotcolour[obj[i].type].b;
				GPU_SortDot(ot, 4, &pix);
			}

			// find out if object onscreen
			obj[i].onscreen = 0;
			type = obj[i].type;
			// clip to window
			if(obj[i].x < window_x) dx = (obj[i].x + 524288) - window_x;
			else dx = obj[i].x - window_x;
			dx = dx >> 8;
			if(dx < 320) {
				obj[i].onscreen = 1;		// flag as onscreen
				y = obj[i].y >> 8;
				// NB: replace this with a call to DrawSprite()
				// create test sprite
//				sprite16.color.r = sprite16.color.g = sprite16.color.b = 128;
//				sprite16.color.pad = 0x7c;	// 16x16 sprite GPU prim
				switch(obj[i].state) {
					case 0 :	// warping in
						c = obj[i].counter;
						dx += 3; y += 3;
						if( c < 47 ) {
							DrawSprite(FRAGMENT, dx-c, y-c, 0);
							DrawSprite(FRAGMENT, dx, y-c, 0);
							DrawSprite(FRAGMENT, dx+c, y-c, 0);
							DrawSprite(FRAGMENT, dx-c, y, 0);
							DrawSprite(FRAGMENT, dx+c, y, 0);
							DrawSprite(FRAGMENT, dx-c, y+c, 0);
							DrawSprite(FRAGMENT, dx, y+c, 0);
							DrawSprite(FRAGMENT, dx+c, y+c, 0);
						}
						break;
					case 99 :	// exploding
						c = obj[i].counter * 3;
						sprite16.color.r = sprite16.color.g = sprite16.color.b = c;
						DrawSprite(type, dx, y, 0);
						break;
					default :	// normal
						sprite16.color.r = sprite16.color.g = sprite16.color.b = 128;
						DrawSprite(type, dx, y, obj[i].frame);
						// add this object to list of onscreen objects
						// (for later use in collision detection)
						onscreen[num_onscreen].index = i;
						onscreen[num_onscreen].x = dx;
						onscreen[num_onscreen].y = y;
						num_onscreen++;
						
						break;
				}
				count++;
			}
		}
	}

	return count;
}

// score/lives/bombs display
void DrawScore(int s, short l, short b) {
	int i;

	sprite16.color.r = sprite16.color.g = sprite16.color.b = 64;

	// draw lives
	for(i=0; i<l; i++) {
		DrawSprite(SHIPS_LEFT, i*10, 4, 0);
	}

	// draw smart bombs
	for(i=0; i<b; i++) {
		DrawSprite(SMART_BOMB, 66, 26 - i*5, 0);
	}

	// draw score
	// will have to do some funky texpage stuff here!
	PrintString(ot, 3, 2, 16, itoa(s));
}

// stick a sprite in OT for rendering
void DrawSprite(ushort type, ushort x, ushort y, int frame) {
	sprite16.vert.x = x;
	sprite16.vert.y = y;
    sprite16.texCoord.u = texcoord[type].u + frame * 16;		// look-up for object bitmap
    sprite16.texCoord.v = texcoord[type].v;
    // hey -optimise this!!!!
    sprite16.clutId = GPU_CalcClutID(0, 481);
	// texpage is "in environment (last used?)
	GPU_SortSprite16(ot, 2, &sprite16);
}

// Update all objects in the object list
int DoObjects(void) {
	int i, j, n, count;

	num_landers_left = 0;					// reset lander/mutant count
	
	// update draw objects that are active
	count = 0;
	for(i=0; i<=obj_max; i++) {
		if(obj[i].type) {					// object type > 0
			// check for warp-in sound
			if(obj[i].state == 0) {
				if(obj[i].counter == 46) {
					if(obj[i].onscreen) SPU_VoiceOn(WARPIN);
				}
			}
			// do object-specific behaviour
			switch(obj[i].type) {
				case PLAYER_RIGHT :
				case PLAYER_LEFT :
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					// clip player to play area vertically
					if(obj[i].y > 56320) { obj[i].y = 56320; obj[i].dy = 0; }
					else if(obj[i].y < 8192) { obj[i].y = 8192; obj[i].dy = 0; }
					// do state stuff
					switch(obj[i].state) {
						case 0 :			// warp-in
							if(!obj[i].counter) {
								obj[i].state++;		// switch to normal after warp in
								obj[i].counter = 0xFFFF;
							}
						break;
						case 1 :			// normal state
							break;
						case 2 :			// first explode state
							// do bigger explosion if counter run out
							if(!obj[i].counter) {
								SPU_VoiceOnMask( (1 << EXPLODE1) | (1 << PLAYERFIRE) | (1 << SPLAT) );
								// create a few fragments
								for(j=0; j < 45; j++) {
									n = AddObject(FRAGMENT, obj[0].x, obj[0].y);
									if(n != -1) {
										obj[n].counter = 48;
										obj[n].state = 99;
										obj[n].dx = rand()%2048 - 1024;
										obj[n].dy = rand()%2048 - 1024;
									}
								} // next j
								obj[i].state = 0;
								obj[i].counter = 200;
							} // end if
							if(obj[i].dx > 0) obj[i].dx -= 32;
							else obj[i].dx += 32;
							break;
						case 3 :			// 2nd explode state
							// if counter expired, go back into game
							if(!obj[i].counter) {
								obj[i].x = 1000 << 8;
								obj[i].y = 100 << 8;
								obj[i].state = 0;
								obj[i].counter = 48;
							}
							if(obj[i].dx > 0) obj[i].dx -= 8;
							else obj[i].dx += 8;
							break;
					} // end switch state
					break;
				case LANDER :
					// Lander behaviour: abduct humans
					num_landers_left++;
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					if(obj[i].y > 56000) obj[i].dy = -32;
					if(!obj[i].counter) {
						obj[i].state++;		// switch to normal after warp in
						// do state *change* init
						switch(obj[i].state) {
							case 1 :		// diagonal down
								obj[i].counter = rand()%200 + 100;
								obj[i].dy = 64;
								obj[i].dx = rand()%512 - 256;
								break;
							case 2 :		// wander horizontally
								obj[i].counter = rand()%400 + 400;
								obj[i].dy = 0;
								break;
							case 3 :		// find closest human
								obj[i].counter = 1;
								n = FindClosestHuman(obj[i].x);
								// if no humans, then revert to state 2
								// below will clock over to state 2 on next
								// update
								if(n == -1)	obj[i].state = 1;
								else {
									// set target human in d1 state var
									obj[i].d1 = n;
								}
								break;
							case 4 :		// align with human
								// keep on wandering horizontally until
								// we are over human
								obj[i].counter = 0xFFFF;
								break;
							case 5 :		// descend to human
								obj[i].counter = 0xFFFF;
								// init vertical movement
								obj[i].dx = 0;
								obj[i].dy = 64;
								break;
							case 6 :		// ascend with human
								obj[i].counter = 0xFFFF;
								// move up
								obj[i].dy = -48;
								// set human info
								n = obj[i].d1;
								obj[n].d1 = i;			// tell human to hang on this lander
								obj[n].state = 2;		// tell human it's being abducted
								// sound effect
								if(obj[i].onscreen) SPU_VoiceOn(HELPME);
								break;
						} // end switch state
						
					}
					// check for shooting (LANDER)
					obj[i].d3--;
					if(!obj[i].d3) {
						obj[i].d3 = rand()%300 + 100;
						if(obj[i].onscreen) {
							// shoot
							n = AddObject(BULLET, obj[i].x, obj[i].y);
							if(n != -1) {
								SPU_VoiceOn(ALIENFIRE);
								// frickin mission here!
								// sort out dx
								if(obj[i].x > obj[0].x) obj[n].dx = obj[i].dx - (obj[i].x - obj[0].x) / BSPEED_X;
								else obj[n].dx = obj[i].dx + (obj[0].x - obj[i].x) / BSPEED_X;
								// sort out dy
								if(obj[i].y > obj[0].y) obj[n].dy = obj[i].dy - (obj[i].y - obj[0].y) / BSPEED_Y;
								else obj[n].dy = obj[i].dy + (obj[0].y - obj[i].y) / BSPEED_Y;

								obj[n].counter = 180;
								//printf("\nbullet: n=%d  dx=%d  dy=%d\n", n, obj[n].dx, obj[n].dy);
							}
							else printf("\ncannot add bullet!");
						}
					}
					// do state-specific stuff
					switch(obj[i].state) {
						case 4 :		// align with human
							// keep on wandering horizontally until
							// we are over human
							n = obj[i].d1;
							if(abs(obj[i].x - obj[n].x) < 768) {
								// switch to next state on next update
								obj[i].counter = 1;
							}
							break;
						case 5 :		// descend to human
							// move downwards until just above human
							n = obj[i].d1;
							if((obj[n].y - obj[i].y) < 2048) {
								// switch to next state
								obj[i].counter = 1;
							}
							break;
						case 6 :		// ascend with human
							// attach human to lander
							n = obj[i].d1;
							obj[n].y = obj[i].y + 2048;
							// if hit the roof, then turn lander into
							// mutant, and kill human
							if(obj[i].y < 8192) {
								obj[i].type = MUTANT;
								obj[i].state = 0;
								obj[i].dy = 64;
								obj[i].counter = 60;
								// kill human
								obj[n].type = 0;
								// sound effect
								SPU_VoiceOn(WARK);
							}
							break;
					} // end switch
					break;
				case MUTANT :
					// Mutant behaviour: seek 'n destroy player
					num_landers_left++;
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					if(obj[i].y > 56000) obj[i].dy = -64;
					else if(obj[i].y < 8192) obj[i].dy = 64;
					// do state change stuff
					if(!obj[i].counter) {
						obj[i].state++;		// switch to normal after warp in
						// do state *change* init
						switch(obj[i].state) {
							case 1 :		// normal state
								obj[i].counter = 0xFFFF;
								obj[i].dy = 64;
								obj[i].dx = 0;
								break;
						} // end switch
					}
					// do state-specific stuff
					switch(obj[i].state) {
						case 1 :			// normal state
							// only seek player if he's alive
							if( obj[0].state == 1 ) {
								// seek horizontally
								if(obj[i].x > obj[0].x) {
									if(obj[i].dx > -512) obj[i].dx -= 16;
								}
								else {
									if(obj[i].dx < 512) obj[i].dx += 16;
								}
								// seek vertically
								if(obj[i].y > obj[0].y) {
									if(obj[i].dy > -128) obj[i].dy -= 8;
								}
								else {
									if(obj[i].dy < 128) obj[i].dy += 8;
								}
								// update fire countdown
								obj[i].d3--;
							}
							break;
					} // end switch
					// check for shooting (MUTANT)
					if(!obj[i].d3) {
						obj[i].d3 = rand()%200 + 60;
						if(obj[i].onscreen) {
							SPU_VoiceOn(ALIENFIRE);
							// shoot
							n = AddObject(BULLET, obj[i].x, obj[i].y);
							if(n != -1) {
								// frickin mission here!
								// sort out dx
								if(obj[i].x > obj[0].x) obj[n].dx = obj[i].dx - (obj[i].x - obj[0].x) / BSPEED_X;
								else obj[n].dx = obj[i].dx + (obj[0].x - obj[i].x) / BSPEED_X;
								// sort out dy
								if(obj[i].y > obj[0].y) obj[n].dy = obj[i].dy - (obj[i].y - obj[0].y) / BSPEED_Y;
								else obj[n].dy = obj[i].dy + (obj[0].y - obj[i].y) / BSPEED_Y;

								obj[n].counter = 180;
								//printf("\nbullet: n=%d  dx=%d  dy=%d\n", n, obj[n].dx, obj[n].dy);
							}
							else printf("\ncannot add bullet!");
						}
					}
					break;
				case BAITER :
					// Baiter behaviour: cut 'n paste from mutant for now...
					// ( a little faster than mutant)
					num_landers_left++;
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					if(obj[i].y > 56000) obj[i].dy = -64;
					else if(obj[i].y < 8192) obj[i].dy = 64;
					// do state change stuff
					if(!obj[i].counter) {
						obj[i].state++;		// switch to normal after warp in
						// do state *change* init
						switch(obj[i].state) {
							case 1 :		// normal state
								obj[i].counter = 0xFFFF;
								obj[i].dy = 64;
								obj[i].dx = 0;
								break;
						} // end switch
					}
					// do state-specific stuff
					switch(obj[i].state) {
						case 1 :			// normal state
							// seek horizontally if player is active
							if( obj[0].state == 1 ) {
								if(obj[i].x > obj[0].x) {
									if(obj[i].dx > -768) obj[i].dx -= 16;
								}
								else {
									if(obj[i].dx < 768) obj[i].dx += 16;
								}
								// seek vertically
								if(obj[i].y > obj[0].y) {
									if(obj[i].dy > -128) obj[i].dy -= 8;
								}
								else {
									if(obj[i].dy < 128) obj[i].dy += 8;
								}
								// update fire countdown
								obj[i].d3--;
							}
							break;
					} // end switch
					// check for shooting (BAITER)
					if(!obj[i].d3) {
						obj[i].d3 = rand()%120 + 40;
						if(obj[i].onscreen) {
							SPU_VoiceOn(ALIENFIRE);
							// shoot
							n = AddObject(BULLET, obj[i].x, obj[i].y);
							if(n != -1) {
								// frickin mission here!
								// sort out dx
								if(obj[i].x > obj[0].x) obj[n].dx = obj[i].dx - (obj[i].x - obj[0].x) / BSPEED_X;
								else obj[n].dx = obj[i].dx + (obj[0].x - obj[i].x) / BSPEED_X;
								// sort out dy
								if(obj[i].y > obj[0].y) obj[n].dy = obj[i].dy - (obj[i].y - obj[0].y) / BSPEED_Y;
								else obj[n].dy = obj[i].dy + (obj[0].y - obj[i].y) / BSPEED_Y;

								obj[n].counter = 180;
								//printf("\nbullet: n=%d  dx=%d  dy=%d\n", n, obj[n].dx, obj[n].dy);
							}
							else printf("\ncannot add bullet!");
						}
					}
					break;
				case BOMBER :
					// Bomber behaviour: move sideways, move slowly up and down
					num_landers_left++;
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					if(obj[i].y > 56000) obj[i].dy = -32;
					else if(obj[i].y < 8192) obj[i].dy = 32;
					if(!obj[i].counter) {
						obj[i].state++;		// switch to normal after warp in
						// do state *change* init
						switch(obj[i].state) {
							case 1 :		// normal - move slightly diagonal
								obj[i].counter = 0xFFFF;
								obj[i].dy = 32;
								obj[i].dx = 256;
								break;
						} // end switch state
					}
					// check for dropping mines
					obj[i].d3--;
					if(!obj[i].d3) {
						obj[i].d3 = 40;			// space mines evenly
						if(obj[i].onscreen) {
							// drop mine
							n = AddObject(MINE, obj[i].x, obj[i].y);
							if(n != -1) {
								obj[n].counter = 300;
								//printf("\nbullet: n=%d  dx=%d  dy=%d\n", n, obj[n].dx, obj[n].dy);
							}
							else printf("\ncannot add bullet!");
						}
					}
					break;
					
				case HUMAN	:
					switch(obj[i].state) {
						case 2 :			// being abducted
							// check if abducting lander has been killed
							// if so, then tell human to fall
							n = obj[i].d1;
							if(obj[n].type == 0) {
								obj[i].state = 3;
								obj[i].dy = 0;
							}
							break;
						case 3 :			// falling
							obj[i].y += obj[i].dy;
							obj[i].dy += 4;
							if(obj[i].y > 55000) obj[i].state = 1;
							break;
						case 4 :			// being carried by player
							obj[i].y = obj[0].y + 256;
							obj[i].x = obj[0].x;
							// dropped off?
							if(obj[i].y > 55000) {
								obj[i].state = 1;
								score += 500;
							}
							break;
					} // end switch
					break;
				case FRAGMENT :
					// switch off if counter expired
					if(!obj[i].counter) obj[i].type = 0;
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					if(obj[i].y > 56000) obj[i].type = 0;
					break;					
				case BULLET :
					// switch off if counter expired
					if(!obj[i].counter) obj[i].type = 0;
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					if(obj[i].y > 56000) obj[i].type = 0;
					break;					
				case MINE :
					// switch off if counter expired
					if(!obj[i].counter) obj[i].type = 0;
					break;
					
				case POD :
					// Pod behaviour: do nothing, trigger some swarmers in state 2
					num_landers_left++;
					// do state change stuff
					if(!obj[i].counter) {
						obj[i].state++;		// switch to normal after warp in
						// do state *change* init
						switch(obj[i].state) {
							case 1 :		// normal state
								obj[i].counter = 0xFFFF;
								break;
							case 2 :		// destroyed - spawn swarmers
								obj[i].counter = 60;
								break;
						} // end switch
					}
					// do state-specific stuff
					switch(obj[i].state) {
						case 1 :			// normal state
							break;
					} // end switch
					break;					

				case SWARMER :
					// Swarmer behaviour: cut 'n paste from mutant for now...
					// ( a little faster than mutant)
					num_landers_left++;
					obj[i].x += obj[i].dx;
					obj[i].x = obj[i].x % 524288;
					obj[i].y += obj[i].dy;
					if(obj[i].y > 56000) obj[i].dy = -64;
					else if(obj[i].y < 8192) obj[i].dy = 64;
					// do state-specific stuff
					switch(obj[i].state) {
						case 1 :			// normal state
							// seek horizontally if player is active
							if( obj[0].state == 1 ) {
								if(obj[i].x > obj[0].x) {
									if(obj[i].dx > -768) obj[i].dx -= 16;
								}
								else {
									if(obj[i].dx < 768) obj[i].dx += 16;
								}
								// seek vertically
								if(obj[i].y > obj[0].y) {
									if(obj[i].dy > -128) obj[i].dy -= 8;
								}
								else {
									if(obj[i].dy < 128) obj[i].dy += 8;
								}
							}
							break;
					} // end switch
					break;

			} // end switch

			// update object's counter and anim frame counter
			if(obj[i].counter) obj[i].counter--;
			if(!(obj[i].counter % 8)) {
				obj[i].frame = ++obj[i].frame % obj[i].numframes;
			}
			count++;
		}
	}

	return count;
}

// draw landscape
// (in radar too)
void DoLand(ushort offset) {
	ushort i;
	ushort o;

	o = offset;

	pix.color.r = 255;
	pix.color.g = 0;
	pix.color.b = 0;
	for(i=0; i<SCREEN_WIDTH; i++) {
		pix.vert.x = i;
		pix.vert.y = land[o & 0x07FF];
        GPU_SortDot(ot, 1, &pix);
        o++;
	}

	// draw radar
	o = offset & 0xFFFE;
	for(i=0; i<160; i+=2) {
		pix.vert.x = i+80;
		pix.vert.y = land[(o+1184) & 0x07FE] >> 3;
		GPU_SortDot(ot, 4, &pix);
		o+= 26;
	}
	
}

// draw stars
void DrawStars(ushort offset) {
	ushort i, o, dx, b;
	

	o = offset / 4;

	for(i=0; i<NUM_STARS; i++) {
		// clip to window
		if(star[i].x < o) dx = (star[i].x + 512) - o;
		else dx = star[i].x - o;
		if(dx < 320) {
			b = star[i].brightness++;
			pix.color.r = (star[i].r * b) >> 6;			// hacky stuff!
			pix.color.g = (star[i].g * b) >> 6;
			pix.color.b = (star[i].b * b) >> 6;
			pix.vert.x = dx;
			pix.vert.y = star[i].y;
        	GPU_SortDot(ot, 1, &pix);
		}
	}

}


// init humans
// ie: place numhumans humans on random positions on landscape
void AddHumans(ushort numhumans) {
	int i, j;
	uint x0, y0;

	for(i=0; i<numhumans; i++) {
		//put human on flat spot
		x0 = rand()%2046;
		while(land[x0] != land[x0+2]) {
			x0 = rand()%2046;
		}
		y0 = (land[x0] - 7) << 8;
		x0 = x0 << 8;
		//printf("adding human at %d, %d\n", x0, y0);
		j = AddObject(HUMAN, x0, y0);
		//printf("j = %d\n", j);
		if(j != -1) {
			obj[j].counter = 0xFFFF;
			obj[j].dx = 0;
			obj[j].dy = 0;
			obj[j].state = 1;		// skip warp-in
		}
	}
}

// Find human closest to x-coordinate
int FindClosestHuman(uint x) {
	int i, n;
	uint dist, mindist;

	mindist = WORLD_WIDTH;		// 524288
	n = -1;
	for(i=0; i<obj_max; i++) {
		if(obj[i].type == HUMAN) {
			dist = abs(x - obj[i].x);
			//printf("dist = %u\n", dist);
			if(dist < mindist) { mindist = dist; n = i; }
		}
	}

	//printf("Closest human: %d\n", n);
	return n;
}

// init sequencer
void InitSeq(OBJSEQ_EVENT *p) {
	objseq.p_event = p;
	objseq.ticks = 0;
	objseq.numevents = 0;
}

// update sequencer
ushort DoSeq(void) {
	int i;
	OBJSEQ_EVENT *p;

	// while we have an event scheduled
	while(objseq.ticks == objseq.p_event->ticks) {
		p = objseq.p_event;
		// kick off event
		switch(p->type) {
			case LANDER :
			    i = AddObject(LANDER, p->x0 << 8, p->y0 << 8);
				break;
			case MUTANT :
				break;
			case BAITER :
			case BOMBER :
			case POD :
			    i = AddObject(p->type, p->x0 << 8, p->y0 << 8);
				break;
		} // end switch
				
		// update event pointer
		objseq.p_event++;
	}
	
	// update ticks
	objseq.ticks++;
	
	return objseq.ticks;
}

// setup lasers
void InitLasers(void) {
	int i;

	for(i=0; i<NUMLASERS; i++) laser[i].y = 0;
}

// update lasers
void DoLasers(void) {
	int i, j, k, n, o, t;
	int dy;
	for(i=0; i<NUMLASERS; i++) {
		if(laser[i].y) {
			laser[i].headx += laser[i].headdx;
			laser[i].tailx += laser[i].taildx;
			// switch off if offscreen
			if(laser[i].tailx > 320) laser[i].y = 0;

			// check if this laser has hit anything
			for(j=1; j<num_onscreen; j++) {
				// check vertical overlap
				dy = laser[i].y - onscreen[j].y;
				if( (dy < 9) && (dy > -1) ) {
					// check horizontal overlap
					if(abs(laser[i].headx - onscreen[j].x + 4) < 16) {
						// hit!
						n = onscreen[j].index;
						t = num_frags[obj[n].type];

						if( (obj[n].type == MINE) || (obj[n].type == BULLET) ) break;
						SPU_VoiceOn(EXPLODE1);
						score += points[obj[n].type];
						
						// do object specific stuff
						switch(obj[n].type) {
							case POD :					// spawn swarmers
								// generate some swarmers,
								// with a bit of spread, other wise they get
								// killed by the laser
								for(k=0; k < 7; k++) {
									o = AddObject(	SWARMER,
													obj[n].x + rand()%4096 - 2048,
												 	obj[n].y + rand()%8192 - 4096);
									if(o != -1) {
										obj[o].dx = rand()%1024 - 512;
										obj[o].dy = rand()%1024 - 512;
									}
								} // next k
							    break;
						} // end switch
						
						// switch off this object
						obj[n].type = 0;
						// generate some fragments
						for(k=0; k < t; k++) {
							o = AddObject(FRAGMENT, obj[n].x, obj[n].y);
							if(o != -1) {
								obj[o].counter = 48;
								obj[o].state = 99;
								obj[o].dx = rand()%2048 - 1024;
								obj[o].dy = rand()%2048 - 1024;
							}
						} // next k

						
					}
				}
			} // next j
			
		} // end if laser active
	} // next i
}

// draw lasers
void DrawLasers(void) {
	int i;
	for(i=0; i<NUMLASERS; i++) {
		if(laser[i].y) {
			ciline.vert0.y = ciline.vert1.y = laser[i].y;
			ciline.vert0.x = laser[i].tailx;
			ciline.vert1.x = laser[i].headx;
			GPU_SortCiLine(ot, 3, &ciline);
		}
	}
}

// trigger smart bomb
void DoSmartBomb(void) {
	int i, j, k, n, o, t;

	//SPU_VoiceOn(EXPLODE1);

	// kill anything onscreen
	for(j=1; j<num_onscreen; j++) {
		// hit!
		n = onscreen[j].index;
		
		// don't kill fragments
		if( obj[n].type != FRAGMENT ) {
			t = num_frags[obj[n].type];

			score += points[obj[n].type];
						
			// do object specific stuff
			switch(obj[n].type) {
				case POD :					// spawn swarmers
					// generate some swarmers,
					for(k=0; k < 7; k++) {
						o = AddObject(	SWARMER,
								obj[n].x + rand()%4096 - 2048,
							 	obj[n].y + rand()%8192 - 4096);
						if(o != -1) {
							obj[o].dx = rand()%1024 - 512;
							obj[o].dy = rand()%1024 - 512;
						}
					} // next k
					break;
			} // end switch
						
			// switch off this object
			obj[n].type = 0;
			
			// generate some fragments
			for(k=0; k < t; k++) {
				o = AddObject(FRAGMENT, obj[n].x, obj[n].y);
				if(o != -1) {
					obj[o].counter = 48;
					obj[o].state = 99;
					obj[o].dx = rand()%2048 - 1024;
					obj[o].dy = rand()%2048 - 1024;
				}
			} // next k
		} // end if not fragment
	} // next j
}


// ******************** TITLE SCREEN *********************
int DoTitle(void) {
	int i;
	uint x1, x2;
	uint flasher;
	unsigned char r, g, b;
	
	// set up test quad for title texture
	testQuad.color.r = 128;
	testQuad.color.g = 128;
	testQuad.color.b = 128;
	i = (SCREEN_WIDTH-240) / 2;
    testQuad.vert0.x = testQuad.vert1.x = i;
    testQuad.vert0.y = testQuad.vert2.y = 0;
    testQuad.vert2.x = testQuad.vert3.x = i + 240;
    testQuad.vert1.y = testQuad.vert3.y = 127;
    testQuad.texCoords0.u = testQuad.texCoords1.u = 0;
    testQuad.texCoords0.v = testQuad.texCoords2.v = 128;
    testQuad.texCoords2.u = testQuad.texCoords3.u = 240;
    testQuad.texCoords1.v = testQuad.texCoords3.v = 255;
    testQuad.clutId = GPU_CalcClutID(0, 481);
    testQuad.texPage = GPU_CalcTexturePage(448, 0, 1);	 // 1 = 8bit

/* - JH - don't draw sprites on title screen
	// setup sprite primitive
	sprite16.color.r = sprite16.color.g = sprite16.color.b = 128;
	sprite16.color.pad = 0x7c;	// 16x16 sprite GPU prim
	sprite16.vert.x = 0;
	sprite16.vert.y = 0;
    sprite16.texCoord.u = 0;
    sprite16.texCoord.v = 0;
    sprite16.clutId = GPU_CalcClutID(0, 481);
	// texpage for sprite is last used textpage
	
	// set up some objects for title screen
	InitObjects();
    // space objects
    x1 = (SCREEN_WIDTH / 6);
    x2 = x1 * 3;
    AddObject(LANDER, x1 << 8, 180 << 8);
    AddObject(MUTANT, x2 << 8, 180 << 8);
    AddObject(BAITER, x1 << 8, 200 << 8);
    AddObject(BOMBER, x2 << 8, 200 << 8);
	for(i=0;i<4;i++) {
		obj[i].state = 1;			// skip warp in
		obj[i].counter = 20000;	// very long count
	}
*/

	// Start sound and MOD stuff if not already playing
	// ie: if not looping title/credits/story
	if(themod.MasterVol == 0) {

/*
		// Initialise SPU (may be unneccessary)
		SPU_Reset();
		SPU_Init(0);
		SPU_Enable();
		i = SPU_Wait();
*/
		// Initialise the MOD
		// MOD can be 4, 6 or 8 track Protracker module 
		InitMOD(&themod, (unsigned char *)warpmod, 0x2000);

		// set MOD master volume to 75%
		themod.MasterVol = 48;
	}


	// main loop
    quit = 0;
    flasher = 0;
    printf("\nTitle loop...");
	while (!quit) {

		// have to reset this, otherwise onscreen struct overruns mem!
		num_onscreen = 0;
		
        // Set up the primitive buffers
        outputBufferIndex = GPU_GetActiveBuff();
        ot = &worldOrderingTable[outputBufferIndex];
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);

		// TITLE: fade texquad red component in to 128,
        // then hit other colours 128
        GPU_SortTexQuad(ot, 1, &testQuad);
		// draw object list
		//i = DrawObjects();
		//printf("%d objects drawn\n", i);

		r = (colourtable[flasher & 255] >> 17) & 0x7F;
		g = (colourtable[flasher & 255] >> 9) & 0x7F;
		b = (colourtable[flasher & 255] >> 1) & 0x7F;
		SetCharLight(r, g, b);
		PrintString(ot, 3, 112, 172, "PRESS START");

		SetCharLight(200, 200, 200);
		PrintString(ot, 3, 92, 144, "BY JUM HIG 2000");
		// TODO: replace this with graphic from y2kode site
		PrintString(ot, 3, 96, 220,  "WWW.Y2KODE.COM");		
		PrintString(ot, 3, 88, 228, "WWW.LIK-SANG.COM");		
		
		DisplayAll();
		
		// handle pad
		prevpad = pad;
		HandlePad();				//this handles button presses on the controller pad 1
		if(pad & PAD_Start) {
			// handles key_up/key_down
			if(!(prevpad & PAD_Start)) quit = 2;		// Start game
		}

		// update counter used for flasher and timeout
		flasher++;
		if(flasher == 600) quit = 1;		// timeout title
		
		// update MOD
		PollMOD(&themod);
	}

	// we should actually fade out screen and sound here
	if(quit == 2) {
		// signal that MOD is not playing (for when we get back
		// to title screen)
		themod.MasterVol = 0;
	}

printf("exiting title: quit = %d\n", quit);
	return(quit);
}

// ******************** STORY SCREEN *********************
// TODO: fade-scroll STORY text (24 chars/line) up screen		- DONE
// TODO: story pics on the side (zoomed sprites ???)
int DoStory(void) {
	int i;
	int y_offset;
	unsigned char t;
	char *pdata;
	char *pc;

    quit = 0;
    pdata = story;		// uh...
    y_offset = 11;		// lines spaced 12 pixels
    printf("\nStory loop...");
	while (!quit) {

		// have to reset this, otherwise onscreen struct overruns mem!
		num_onscreen = 0;
		
        // Set up the primitive buffers
        outputBufferIndex = GPU_GetActiveBuff();
        ot = &worldOrderingTable[outputBufferIndex];
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);

		pc = pdata;				// point to first line "onscreen"
		for(i=0; i<12; i++) {
			// set brightness of this line
			t = fadetable[i*12 + y_offset] >> 1;
			SetCharLight(t>>1,t>>1,t); 
			PrintString(ot, 3, 64, i*12 + 48 + y_offset, pc);
			pc += 25;			// point to next line
		}
		if(*pc == 0) quit = 1;	// end of scroller
		y_offset--;
		if(y_offset == -1) {
			y_offset = 11;
			pdata += 25;
		}
					
		DisplayAll();
		for(i=0; i<3; i++) {
			PollMOD(&themod);
			GPU_VSync();
		}
		
		// handle pad
		prevpad = pad;
		HandlePad();				//this handles button presses on the controller pad 1
		if(pad & PAD_Start) {
			// handles key_up/key_down
			if(!(prevpad & PAD_Start)) quit = 1;
		}

		PollMOD(&themod);
	}

	return 0;
}

// ******************* CREDITS SCREEN ********************
// TODO: print "CREDITS" at top (with underline)
//       fade-scroll credits text (24 char lines)
int DoCredits(void) {
	int i;
	int y_offset;
	unsigned char t;
	char *pdata;
	char *pc;

    quit = 0;
    pdata = credits;	// uh...
    y_offset = 11;		// 12 pixel line spacing
    
    printf("\nCredits loop...");
	while (!quit) {

		// have to reset this, otherwise onscreen struct overruns mem!
		num_onscreen = 0;
		
        // Set up the primitive buffers
        outputBufferIndex = GPU_GetActiveBuff();
        ot = &worldOrderingTable[outputBufferIndex];
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);

		PrintString(ot, 3, 64, 8, "--------CREDITS---------");
		
		pc = pdata;				// point to first line "onscreen"
		for(i=0; i<12; i++) {
			// set brightness of this line
			t = fadetable[i*12 + y_offset];
			SetCharLight(t>>1,t>>1,t>>1); 
			PrintString(ot, 3, 64, i*12 + 48 + y_offset, pc);
			pc += 25;			// point to next line
		}
		if(*pc == 0) quit = 1;	// end of scroller
		y_offset--;
		if(y_offset == -1) {
			y_offset = 11;
			pdata += 25;
		}
		
		DisplayAll();
		for(i=0; i<3; i++) {
			PollMOD(&themod);
			GPU_VSync();
		}
		
		// handle pad
		prevpad = pad;
		HandlePad();				//this handles button presses on the controller pad 1
		if(pad & PAD_Start) {
			// handles key_up/key_down
			if(!(prevpad & PAD_Start)) quit = 1;
		}
		
		PollMOD(&themod);
	}
	return 0;
}

// ******************* HISCORE SCREEN ********************
// TODO: print "HISCORE" at top (with underline)
//       colour-cycle HISCORE (24 char lines)
int DoHiscore(void) {
	int i;
	int counter, c1;
	unsigned char t;
	char *pc;
	unsigned char r, g, b;

    quit = 150;
    counter = 0;

    printf("\nHiscore loop...");
	while (quit) {

		quit--;			// used as counter

        // Set up the primitive buffers
        outputBufferIndex = GPU_GetActiveBuff();
        ot = &worldOrderingTable[outputBufferIndex];
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);

		c1 = counter; 
		pc = hstext;			// point to first line
		for(i=0; i<12; i++) {
			r = (colourtable[c1 & 255] >> 17) & 0x7F;
			g = (colourtable[c1 & 255] >> 9) & 0x7F;
			b = (colourtable[c1 & 255] >> 1) & 0x7F;
			SetCharLight(r, g, b);
			c1++;
			PrintString(ot, 3, 64, i*12 + 48, pc);
			pc += 25;			// point to next line
		}
		
		DisplayAll();
		for(i=0; i<3; i++) {
			PollMOD(&themod);
			GPU_VSync();
		}

		
		// handle pad
		prevpad = pad;
		HandlePad();				//this handles button presses on the controller pad 1
		if(pad & PAD_Start) {
			// handles key_up/key_down
			if(!(prevpad & PAD_Start)) quit = 0;
		}
		
		PollMOD(&themod);
		counter++;
	}
	return 0;
}


// int to string (6 chars)
char *itoa(int n) {

	mystring[0] = ((n % 1000000) / 100000) + 48;
	mystring[1] = ((n % 100000) / 10000) + 48;
	mystring[2] = ((n % 10000) / 1000) + 48;
	mystring[3] = ((n % 1000) / 100) + 48;
	mystring[4] = ((n % 100) / 10) + 48;
	mystring[5] = (n % 10) + 48;
	mystring[6] = 0;
	
	return mystring;
}

