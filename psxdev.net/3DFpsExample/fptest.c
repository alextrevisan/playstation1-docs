/*	First-person 3D example by Lameguy64
	2014 Meido-Tek Productions
	
	Demonstrates:
		- Using a primitive OT to draw graphics without libgs.
		- Uses the GTE to do all 3D calculations.
		- Texture mapping with subdivision (to reduce distortion).
		- Using a VSync callback to drive game logic (for frame skipping)
		- Fog.
	
	Bug:
		- Seams appear between quads that have a different LOD level.
	
	Controls:
		D-Pad							- Look.
		Triangle/Square/Circle/Cross	- Move.
		R1/R2							- Strafe up/down.
		Select							- Reset camera position.
	
*/

#include <sys/types.h>
#include <libgte.h>
#include <libgpu.h>
#include <libetc.h>
#include <stdio.h>

// My little library for loading TIMs easily (and a few other things)
#include "libags.c"

// Our mesh of quads and basic wall texture
#include "quadmap.c"
#include "wall.c"


#define DEBUG		0


#define OT_LENGTH	10				// OT precision/size
#define OT_ENTRIES	1<<OT_LENGTH
#define MAX_PRIMS	16384			// Primitive area size


// Screen resolution
#define SCREENXRES	320
#define SCREENYRES	240

// Calculate center of screen
#define CENTERX		SCREENXRES/2
#define CENTERY		SCREENYRES/2


// Stuff for display and rendering
DISPENV 	disp;
DRAWENV 	draw;
RECT		ClearRect	={ 0, 0, SCREENXRES, SCREENYRES };

u_long		myOT[2][OT_ENTRIES];	// Ordering table (contains pointers to primitives)
u_long		myPrims[2][MAX_PRIMS];	// Primitive list (can contain various primitive types)
u_long		*myPrimPtr=0;			// Next primitive pointer
int			ActivePage=0;	

// Camera stuff
typedef struct {
	int		x,xv;
	int		y,yv;
	int		z,zv;
	int		pan,panv;
	int		til,tilv;
	int		rol;
	
	VECTOR	pos;
	SVECTOR rot;
	SVECTOR	dvs;
	
	MATRIX	mat;
} CAMERA;

CAMERA		camera={0};


// Global variables
AGsIMAGE	texture;
int			PadStatus;


// Prototypes
int main();
void Init();
void ApplyCamera(CAMERA *cam);
void CallbackFunc();


int main() {
	
	
	POLY_FT4	*myPrimTempT;
	
	long	i, p, t, OTz, OTc, Flag, nclip;
	int		NumPrims;
	
	DIVPOLYGON4	div={0};
	CVECTOR	ColTemp;
	
	
	// Texture coordinates
	struct {
		char	u;
		char	v;
		u_short page;
	} tp[4] = {
		0	,	0	,	0,	// u, v, clutid
		63	,	0	,	0,	// u, v, tpage
		0	,	63	,	0,	// u, v, dummy
		63	,	63	,	0	// u, v, dummy
	};
	

	Init();
	
	tp[0].page = texture.clutid;
	tp[1].page = texture.tpage;
	
	
	// Setup fog
	SetFarColor(0, 0, 0);
	SetFogNearFar(2500, 6000, SCREENXRES);
	
	
	// Set the screen resolution to the 'div' environment
	div.pih = SCREENXRES;
	div.piv = SCREENYRES;
	
	
	// Set game logic function to VSync callback
	VSyncCallback(CallbackFunc);
	
	
	// Main loop
	while (1) {
		
		// Render the banner (FntPrint is always on top because it is not part of the OT)
		FntPrint("\n\n 3D FPS EXAMPLE BY LAMEGUY64\n 2014 MEIDO-TEK PRODUCTIONS\n");
		
		
		// Toggle buffer index
		ActivePage = (ActivePage + 1) & 1;
		

		// Clear the current OT
		ClearOTagR(&myOT[ActivePage][0], OT_ENTRIES);
		myPrimPtr = &myPrims[ActivePage][0];
		
		
		// Convert and set the camera coords
		camera.pos.vx = -(camera.x/ONE);
		camera.pos.vy = -(camera.y/ONE);
		camera.pos.vz = -(camera.z/ONE);
		
		camera.rot.vx = camera.til;
		camera.rot.vy = -camera.pan;
		
		
		// Apply camera matrix
		ApplyCamera(&camera);
		
		t=0; NumPrims=0;
		for (i=0; i<quad_count; i++) {
			
			myPrimTempT = (POLY_FT4*)myPrimPtr;
			
			nclip = RotAverageNclip4(
				&quad_mesh[t], &quad_mesh[t+1], &quad_mesh[t+2], &quad_mesh[t+3], 
				(long*)&myPrimTempT->x0, (long*)&myPrimTempT->x1, 
				(long*)&myPrimTempT->x3, (long*)&myPrimTempT->x2,
				&p, &OTz, &Flag);
			
			
			if ((nclip > 0) && (OTz > 0)) {
				
				SetPolyFT4(myPrimTempT);
				quad_color[i].cd = myPrimTempT->code;
				OTc = OTz>>(14-OT_LENGTH);
				
				// High LOD level (subdivided)
				if (OTc < 15) {
					
					if (OTc > 5) div.ndiv = 1; else div.ndiv = 2;
					
					DivideFT4(
						&quad_mesh[t], &quad_mesh[t+1], &quad_mesh[t+3], &quad_mesh[t+2], 
						(u_long*)&tp[0], (u_long*)&tp[1], (u_long*)&tp[2], (u_long*)&tp[3],
						&quad_color[i],
						myPrimTempT, &myOT[ActivePage][OTc],
						&div);
					
					// Increment primitive list pointer
					myPrimPtr += POLY_FT4_size*((1<<(div.ndiv))<<(div.ndiv));
					NumPrims += ((1<<(div.ndiv))<<(div.ndiv));
					
				// Low LOD level (no subdivision)
				} else if (OTc < 48) {
					
					myPrimTempT->u0 = tp[0].u;	myPrimTempT->v0 = tp[0].v;
					myPrimTempT->u1 = tp[1].u;	myPrimTempT->v1 = tp[1].v;
					myPrimTempT->u2 = tp[2].u;	myPrimTempT->v2 = tp[2].v;
					myPrimTempT->u3 = tp[3].u;	myPrimTempT->v3 = tp[3].v;
					myPrimTempT->clut	= tp[0].page;
					myPrimTempT->tpage	= tp[1].page;
					
					DpqColor(&quad_color[i], p, &ColTemp);
					setRGB0(myPrimTempT, ColTemp.r, ColTemp.g, ColTemp.b);
					
					addPrim(&myOT[ActivePage][OTc], myPrimTempT);
					
					myPrimPtr += POLY_FT4_size;
					NumPrims += 1;
				
				}				
				
			}
			
			t+=4;
			
		}
		
		
		// Prepare to switch buffers
		SetDefDispEnv(&disp, 0, 256*ActivePage, SCREENXRES, SCREENYRES);
		SetDefDrawEnv(&draw, 0, 256*(1-ActivePage), SCREENXRES, SCREENYRES);
		
		
		// Wait for all drawing to finish and wait for VSync
		while(DrawSync(1));
		VSync(0);
		
		
		// Switch display buffers
		PutDispEnv(&disp);
		PutDrawEnv(&draw);
		
		// Clear the drawing buffer before drawing the next frame
		ClearRect.y = 256*(1-ActivePage);
		ClearImage(&ClearRect, 0, 0, 0);
		
		// Begin drawing the new frame
		DrawOTag(&myOT[ActivePage][OT_ENTRIES-1]);
		FntFlush(0);
		
		SetDispMask(1);
		
	}
	
}

void Init() {
	
	// Reset the GPU and initialize the controller
	ResetGraph(0);
	PadInit(0);
	
	
	// Load the texture
	AGsLoadTim((u_long*)tim_texture, &texture);
	
	
	// Init font system
	FntLoad(960, 0);
	FntOpen(0, 0, SCREENXRES, SCREENYRES, 0, 512);
	
	
	// Initialize and setup the GTE
	InitGeom();
	SetGeomOffset(CENTERX, CENTERY);
	SetGeomScreen(CENTERX);
	
	
	// Set the display and draw environments
	SetDefDispEnv(&disp, 0, 0, SCREENXRES, SCREENYRES);
	SetDefDrawEnv(&draw, 0, 256, SCREENXRES, SCREENYRES);
	
	
	// Set the new display/drawing environments
	VSync(0);
	PutDispEnv(&disp);
	PutDrawEnv(&draw);
	ClearImage(&ClearRect, 0, 0, 0);
	
}

void ApplyCamera(CAMERA *cam) {
	
	// I really can't explain this, found it in one ofthe ZIMEN PsyQ examples
	
	VECTOR	vec;
	
	RotMatrix(&cam->rot, &cam->mat);
	
	ApplyMatrixLV(&cam->mat, &cam->pos, &vec);	
	
	TransMatrix(&cam->mat, &vec);
	SetRotMatrix(&cam->mat);
	SetTransMatrix(&cam->mat);
	
}

void CallbackFunc() {
	
	/*
		This is where game logic is driven which will be tied to a
		VSync callback so that the game logic will always run at 60FPS
		regardless of the renderer's performance to simulate frameskipping.
	*/
	
	// Read pad status
	PadStatus = PadRead(0);
	
	// Camera panning
	if (PadStatus & PADLup)		camera.tilv -= 4;
	if (PadStatus & PADLdown)	camera.tilv += 4;
	if (PadStatus & PADLleft)	camera.panv -= 4;
	if (PadStatus & PADLright)	camera.panv += 4;
	
	// Camera movement
	if (PadStatus & PADRup) {
		camera.zv += ((ccos(camera.pan)*((float)ccos(camera.til)/ONE))*1);
		camera.xv += ((csin(camera.pan)*((float)ccos(camera.til)/ONE))*1);
		camera.yv += (csin(camera.til)*1);
	}

	if (PadStatus & PADRdown) {
		camera.zv -= ((ccos(camera.pan)*((float)ccos(camera.til)/ONE))*1);
		camera.xv -= ((csin(camera.pan)*((float)ccos(camera.til)/ONE))*1);
		camera.yv -= (csin(camera.til)*1);
	}
	
	if (PadStatus & PADRleft) {
		camera.zv += (csin(camera.pan)*1);
		camera.xv -= (ccos(camera.pan)*1);
	}

	if (PadStatus & PADRright) {
		camera.zv -= (csin(camera.pan)*1);
		camera.xv += (ccos(camera.pan)*1);
	}
	
	if (PadStatus & PADR1)	camera.yv -= ONE*1;
	if (PadStatus & PADR2)	camera.yv += ONE*1;
	
	// Reset
	if (PadStatus & PADselect) {
		camera.x = camera.y = camera.z = 0;
		camera.pan = camera.til = camera.rol = 0;
		camera.panv = camera.tilv = 0;
		camera.xv = 0;
		camera.yv = 0;
		camera.zv = 0;
	}
	
	camera.x += camera.xv;
	camera.y += camera.yv;
	camera.z += camera.zv;
	camera.pan += camera.panv;
	camera.til += camera.tilv;
	
	camera.xv *=0.9f;
	camera.yv *=0.9f;
	camera.zv *=0.9f;
	camera.panv *=0.9f;
	camera.tilv *=0.9f;
	
}