/*	TMD model viewer example by Lameguy64
	2014 Meido-Tek Productions
	
	Demonstrates:
		- Rendering a TMD model with multiple primitive types using high-speed libgs functions.
		- Real-time lighting source calculation (oooh :O).
		- First-person camera.
		
	Controls:
		D-Pad			- Look around.
		Triangle/Cross 	- Move forward/backward.
		Square/Circle	- Strafe left/right.
		R1/R2			- Move lightbulb along the X axis
		L1/L2			- Move lightbulb along the Z axis
		Select+L1/L2	- Move lightbulb along the Y axis
		
*/

#include <sys/types.h>
#include <libetc.h>
#include <libgte.h>
#include <libgpu.h>
#include <libgs.h>


// TIM textures
#include "maritex.c"

// TMD models
#include "platform.c"
#include "bulb.c"
#include "marilyn.c"


// Maximum number of objects
#define MAX_OBJECTS 3


// Screen resolution and dither mode
#define SCREEN_XRES		640
#define SCREEN_YRES 	480
#define DITHER			1

#define CENTERX			SCREEN_XRES/2
#define CENTERY			SCREEN_YRES/2


// Increasing this value (max is 14) reduces sorting errors in certain cases
#define OT_LENGTH	12

#define OT_ENTRIES	1<<OT_LENGTH
#define PACKETMAX	2048


GsOT		myOT[2];						// OT handlers
GsOT_TAG	myOT_TAG[2][OT_ENTRIES];		// OT tables
PACKET		myPacketArea[2][PACKETMAX*24];	// Packet buffers
int			myActiveBuff=0;					// Page index counter


// Camera coordinates
struct {
	int		x,y,z;
	int		pan,til,rol;
	VECTOR	pos;
	SVECTOR rot;
	GsRVIEW2 view;
	GsCOORDINATE2 coord2;
} Camera = {0};


// Object handler
GsDOBJ2	Object[MAX_OBJECTS]={0};
int		ObjectCount=0;

// Lighting coordinates
GsF_LIGHT pslt[1];


// Prototypes
int main();

void CalculateCamera();
void PutObject(VECTOR pos, SVECTOR rot, GsDOBJ2 *obj);

int LinkModel(u_long *tmd, GsDOBJ2 *obj);
void LoadTexture(u_long *addr);

void init();
void PrepDisplay();
void Display();


// Main stuff
int main() {
	
	int i,PadStatus;
	int Accel;
	
	// Object coordinates
	VECTOR	plat_pos={0};
	SVECTOR	plat_rot={0};
	
	VECTOR	obj_pos={0};
	SVECTOR	obj_rot={0};
	
	VECTOR	bulb_pos={0};
	SVECTOR	bulb_rot={0};
	
	// Player coordinates
	struct {
		int x,xv;
		int y,yv;
		int z,zv;
		int pan,panv;
		int til,tilv;
	} Player = {0};
	
	
	// Init everything
	init();
	
	
	// Load the texture for our test model
	LoadTexture((u_long*)tim_maritex);
	
	// Link the TMD models
	ObjectCount += LinkModel((u_long*)tmd_platform, &Object[0]);	// Platform
	ObjectCount += LinkModel((u_long*)tmd_bulb, &Object[1]);		// Light bulb (as a light source reference)
	ObjectCount += LinkModel((u_long*)tmd_marilyn, &Object[2]);		// The test model
	
	Object[0].attribute |= GsDIV1;	// Set 2x2 sub-division for the platform to reduce clipping errors
	for(i=2; i<ObjectCount; i++) {
		Object[2].attribute = 0;		// Re-enable lighting for the test model
	}
	
	
	// Default camera/player position
	Player.x = ONE*-640;
	Player.y = ONE*510;
	Player.z = ONE*800;
	
	Player.pan = -660;
	Player.til = -245;
	
	
	// Object positions
	plat_pos.vy = 1024;
	bulb_pos.vz = -800;
	bulb_pos.vy = -400;
	obj_pos.vy = 400;
	
	
	while(1) {
		
		PadStatus = PadRead(0);
		
		
		// Player look
		if (PadStatus & PADLup)		Player.tilv += 4;
		if (PadStatus & PADLdown)	Player.tilv -= 4;
		if (PadStatus & PADLleft)	Player.panv -= 4;
		if (PadStatus & PADLright)	Player.panv += 4;
	
		// Player movement
		if (PadStatus & PADRup) {	// Forward
			Accel = ccos(Player.til);
			Player.zv -= ((ccos(Player.pan)*Accel)/ONE)*2;
			Player.xv -= ((csin(Player.pan)*Accel)/ONE)*2;
			Player.yv += (csin(Player.til)*2);
		}

		if (PadStatus & PADRdown) {	// Backward
			Accel = ccos(Player.til);
			Player.zv += ((ccos(Player.pan)*Accel)/ONE)*2;
			Player.xv += ((csin(Player.pan)*Accel)/ONE)*2;
			Player.yv -= (csin(Player.til)*2);
		}
		
		if (PadStatus & PADRleft) { // Strafe left
			Player.zv -= (csin(Player.pan)*2);
			Player.xv += (ccos(Player.pan)*2);
		}

		if (PadStatus & PADRright) { // Strafe right
			Player.zv += (csin(Player.pan)*2);
			Player.xv -= (ccos(Player.pan)*2);
		}
		
		// Calculate player coordinates according to the velocities
		Player.x += Player.xv;
		Player.y += Player.yv;
		Player.z += Player.zv;
		Player.pan += Player.panv;
		Player.til += Player.tilv;
		
		Player.xv *=0.9f;
		Player.yv *=0.9f;
		Player.zv *=0.9f;
		Player.panv *=0.9f;
		Player.tilv *=0.9f;
		
		
		// Translate player coordinates for the camera
		Camera.pos.vx = Player.x/ONE;
		Camera.pos.vy = Player.y/ONE;
		Camera.pos.vz = Player.z/ONE;
		Camera.rot.vy = -Player.pan;
		Camera.rot.vx = -Player.til;
		
		
		// Light source/bulb movement
		if (PadStatus & PADselect) {
			if (PadStatus & PADL1) bulb_pos.vy -= 16;
			if (PadStatus & PADL2) bulb_pos.vy += 16;
		} else {
			if (PadStatus & PADL1) bulb_pos.vz -= 16;
			if (PadStatus & PADL2) bulb_pos.vz += 16;
		}
		if (PadStatus & PADR1) bulb_pos.vx -= 16;
		if (PadStatus & PADR2) bulb_pos.vx += 16;
		
		
		// Prepare for rendering
		PrepDisplay();
		
		
		// Print banner and camera stats
		FntPrint("\n\n\n TMD EXAMPLE BY LAMEGUY64\n 2014 MEIDO-TEK PRODUCTIONS\n -\n");
		FntPrint(" CX:%d CY:%d CZ:%d\n", Camera.pos.vx, Camera.pos.vy, Camera.pos.vz);
		FntPrint(" CP:%d CT:%d CR:%d\n", Camera.rot.vy, Camera.rot.vx, Camera.rot.vz);
		
		
		// Calculate the camera and viewpoint matrix
		CalculateCamera();
		
		
		// Set the light source coordinates
		pslt[0].vx = -(bulb_pos.vx);
		pslt[0].vy = -(bulb_pos.vy);
		pslt[0].vz = -(bulb_pos.vz);
		
		pslt[0].r =	0xff;	pslt[0].g = 0xff;	pslt[0].b = 0xff;
		GsSetFlatLight(0, &pslt[0]);
		
		
		// Rotate the object
		//obj_rot.vx += 4;
		obj_rot.vy += 4;
		
		
		// Sort the platform and bulb objects
		PutObject(plat_pos, plat_rot, &Object[0]);
		PutObject(bulb_pos, bulb_rot, &Object[1]);
		
		// Sort our test object(s)
		for(i=2; i<ObjectCount; i++) {	// This for-loop is not needed but its here for TMDs with multiple models
			PutObject(obj_pos, obj_rot, &Object[i]);
		}
		
		
		// Display the new frame
		Display();
		
	}
	
}


void CalculateCamera() {
	
	// This function simply calculates the viewpoint matrix based on the camera coordinates...
	// It must be called on every frame before drawing any objects.
	
	VECTOR	vec;
	GsVIEW2 view;
	
	// Copy the camera (base) matrix for the viewpoint matrix
	view.view = Camera.coord2.coord;
	view.super = WORLD;
	
	// I really can't explain how this works but I found it in one of the ZIMEN examples
	RotMatrix(&Camera.rot, &view.view);
	ApplyMatrixLV(&view.view, &Camera.pos, &vec);
	TransMatrix(&view.view, &vec);
	
	// Set the viewpoint matrix to the GTE
	GsSetView2(&view);
	
}

void PutObject(VECTOR pos, SVECTOR rot, GsDOBJ2 *obj) {
	
	/*	This function draws (or sorts) a TMD model linked to a GsDOBJ2 structure... All
		matrix calculations are done automatically for simplified object placement.
		
		Parameters:
			pos 	- Object position.
			rot		- Object orientation.
			*obj	- Pointer to a GsDOBJ2 structure that is linked to a TMD model.
			
	*/
	
	MATRIX lmtx,omtx;
	GsCOORDINATE2 coord;
	
	// Copy the camera (base) matrix for the model
	coord = Camera.coord2;
	
	// Rotate and translate the matrix according to the specified coordinates
	RotMatrix(&rot, &omtx);
	TransMatrix(&omtx, &pos);
	CompMatrixLV(&Camera.coord2.coord, &omtx, &coord.coord);
	coord.flg = 0;
	
	// Apply coordinate matrix to the object
	obj->coord2 = &coord;
	
	// Calculate Local-World (for lighting) and Local-Screen (for projection) matrices and set both to the GTE
	GsGetLws(obj->coord2, &lmtx, &omtx);
	GsSetLightMatrix(&lmtx);
	GsSetLsMatrix(&omtx);
	
	// Sort the object!
	GsSortObject4(obj, &myOT[myActiveBuff], 14-OT_LENGTH, getScratchAddr(0));
	
}


int LinkModel(u_long *tmd, GsDOBJ2 *obj) {
	
	/*	This function prepares the specified TMD model for drawing and then
		links it to a GsDOBJ2 structure so it can be drawn using GsSortObject4().
		
		By default, light source calculation is disabled but can be re-enabled by
		simply setting the attribute variable in your GsDOBJ2 structure to 0.
		
		Parameters:
			*tmd - Pointer to a TMD model file loaded in memory.
			*obj - Pointer to an empty GsDOBJ2 structure.
	
		Returns:
			Number of objects found inside the TMD file.
			
	*/
	
	u_long *dop;
	int i,NumObj;
	
	// Copy pointer to TMD file so that the original pointer won't get destroyed
	dop = tmd;
	
	// Skip header and then remap the addresses inside the TMD file
	dop++; GsMapModelingData(dop);
	
	// Get object count
	dop++; NumObj = *dop;

	// Link object handler with the specified TMD
	dop++;
	for(i=0; i<NumObj; i++) {
		GsLinkObject4((u_long)dop, &obj[i], i);
		obj[i].attribute = (1<<6);	// Disables light source calculation
	}
	
	// Return the object count found inside the TMD
	return(NumObj);
	
}
void LoadTexture(u_long *addr) {
	
	// A simple TIM loader... Not much to explain
	
	RECT rect;
	GsIMAGE tim;
	
	// Get TIM information
	GsGetTimInfo((addr+1), &tim);
	
	// Load the texture image
	rect.x = tim.px;	rect.y = tim.py;
	rect.w = tim.pw;	rect.h = tim.ph;
	LoadImage(&rect, tim.pixel);
	DrawSync(0);
	
	// Load the CLUT (if present)
	if ((tim.pmode>>3) & 0x01) {
		rect.x = tim.cx;	rect.y = tim.cy;
		rect.w = tim.cw;	rect.h = tim.ch;
		LoadImage(&rect, tim.clut);
		DrawSync(0);
	}
	
}


void init() {
	
	SVECTOR VScale={0};
	
	// Initialize the GS
	ResetGraph(0);
	if (SCREEN_YRES <= 240) {
		GsInitGraph(SCREEN_XRES, SCREEN_YRES, GsOFSGPU|GsNONINTER, DITHER, 0);
		GsDefDispBuff(0, 0, 0, 256);
	} else {
		GsInitGraph(SCREEN_XRES, SCREEN_YRES, GsOFSGPU|GsINTER, DITHER, 0);	
		GsDefDispBuff(0, 0, 0, 0);
	}
	
	// Prepare the ordering tables
	myOT[0].length	=OT_LENGTH;
	myOT[1].length	=OT_LENGTH;
	myOT[0].org		=myOT_TAG[0];
	myOT[1].org		=myOT_TAG[1];
	
	GsClearOt(0, 0, &myOT[0]);
	GsClearOt(0, 0, &myOT[1]);
	
	
	// Initialize debug font stream
	FntLoad(960, 0);
	FntOpen(-CENTERX, -CENTERY, SCREEN_XRES, SCREEN_YRES, 0, 512);
	
	
	// Setup 3D and projection matrix
	GsInit3D();
	GsSetProjection(CENTERX);
	
	
	// Initialize coordinates for the camera (it will be used as a base for future matrix calculations)
	GsInitCoordinate2(WORLD, &Camera.coord2);
	
	
	// Set ambient color (for lighting)
	GsSetAmbient(ONE/4, ONE/4, ONE/4);
	
	// Set default lighting mode
	GsSetLightMode(0);
	
	
	// Initialize controller
	PadInit(0);
	
}

void PrepDisplay() {
	
	// Get active buffer ID and clear the OT to be processed for the next frame
	myActiveBuff = GsGetActiveBuff();
	GsSetWorkBase((PACKET*)myPacketArea[myActiveBuff]);
	GsClearOt(0, 0, &myOT[myActiveBuff]);
	
}
void Display() {
	
	// Flush the font stream
	FntFlush(-1);
	
	// Wait for VSync, switch buffers, and draw the new frame.
	VSync(0);
	GsSwapDispBuff();
	GsSortClear(0, 64, 0, &myOT[myActiveBuff]);
	GsDrawOt(&myOT[myActiveBuff]);
	
}