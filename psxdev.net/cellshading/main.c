/** Cel-shaded TMD model rendering example by Lameguy64
 *  2015 Meido-Tek Productions
 *
 *  This program demonstrates cel-shaded TMD rendering on the PlayStation
 *  using the same cel-shading technique used in many games by using vertex
 *  colors after passing through light source calculation as texture coords
 *  and a 32x32 cel-shader map of 3 shade levels. It also uses low-level GTE
 *  macros for fast model rendering.
 *
 *  Controls:
 *      D-Pad           - Rotate model.
 *      Cross/Triangle  - Move model in or out in the scene.
 *      Square/Circle   - Move model left or right in the scene.
 *      R1/R2           - Move model up or down in the scene.
 *
 */

#include <stdio.h>
#include <sys/types.h>
#include <libetc.h>
#include <libgte.h>
#include <libgpu.h>
#include <libgs.h>
#include <libsn.h>
#include <inline_c.h>


#include "config.h"
#include "loadtim.h"
#include "tmdstruct.h"
#include "tmdcel.h"


// Ordering table and packet buffer stuff
GsOT	 myOT[2];
GsOT_TAG myOT_TAG[2][OT_ENTRIES];
PACKET   myPacketBuff[2][PACKETMAX2];
int		 myActiveBuff;


// Include the external data arrays into our main program
extern u_char tim_celmap[];     // 32x32x4 3-tone cel-shading TIM
extern u_char tmd_suzanne[];    // Suzanne TMD model (contains 968 triangles)


// Some function prototypes
void init();
void PrepDisplay();
void Display();


// Main function
int main(int argc, char *argv[]) {

    // For gamepad input
	int pad;

    // Model matrix and rotation/translation vectors
    MATRIX	Matrix;
	SVECTOR	Rotate= { 0, 0, 0 };
	VECTOR	Trans = { 0, 0, SCREEN_CENTERX*2, 0 };

    // Light source position and color
	GsF_LIGHT   lightPos;

    // For the TIM loader
    TimIMAGE texImage;

	// For my custom cel-shaded TMD renderer function
	TMDcelObj object;


    // Init system
	init();


    // Load cel-shader texture to VRAM
    LoadTim((u_long*)tim_celmap, &texImage);


    // Prepare TMD model
	GsMapModelingData(((u_long*)tmd_suzanne)+1);

	// Prepare TMDcelObj structure
	object.modelAddr	= (TMDaddr*)(tmd_suzanne+12);   // Pointer to TMD's vertex, normal and primitive addresses (see filefrmt.pdf)
	object.mapTPage		= texImage.tpage;               // Cel-shader map's TPage
	object.mapClutID	= texImage.clutid;              // Cel-shader map's CLUT
	object.mapXsize		= 31;                           // X size of cel-shader texture map (must be 1 less than the actual value)
	object.mapYsize		= 31;                           // Y size of cel-shader texture map (must be 1 less than the actual value)


    // Set ambient color for the lighting system (0 since we want vertex colors to be 0-31)
    GsSetAmbient(0, 0, 0);

	// Set lighting mode
	GsSetLightMode(0);

    // Set light source 0 to the top-left corner of the model
    lightPos.vx = ONE;
    lightPos.vy = ONE;
    lightPos.vz = ONE;
    lightPos.r = lightPos.g = lightPos.b = 191;
    GsSetFlatLight(0, &lightPos);


    // Main loop
	while(1) {

        // Parse input and stuff
		pad = PadRead(0);

		if (pad & PADLup)
			Rotate.vx -= 16;
		if (pad & PADLdown)
			Rotate.vx += 16;
		if (pad & PADLleft)
			Rotate.vz -= 16;
		if (pad & PADLright)
			Rotate.vz += 16;

		if (pad & PADRup)
			Trans.vz += 8;
		if (pad & PADRdown)
			Trans.vz -= 8;
		if (pad & PADRleft)
			Trans.vx -= 8;
		if (pad & PADRright)
			Trans.vx += 8;
		if (pad & PADR1)
			Trans.vy -= 8;
		if (pad & PADR2)
			Trans.vy += 8;


        // Set rotation and translation vectors to the model matrix
		RotMatrix(&Rotate, &Matrix);
		TransMatrix(&Matrix, &Trans);


        // Prepare rendering
		PrepDisplay();


        // Set rotation and translation matrices
		SetRotMatrix(&Matrix);
		SetTransMatrix(&Matrix);


		// Set light matrix
		GsSetLightMatrix(&Matrix);


		// Set the GTE geometry offset to the center of the screen
        // (this controls the center offset of projected 2D coords outputted from the GTE
        // without affecting the GPU offset)
		gte_SetGeomOffset(SCREEN_CENTERX, SCREEN_CENTERY);

        // Sort TMD model with cel-shading
		SortTMDcel(&myOT[myActiveBuff], &object, OT_ENTRIES);


        // Print simple banner message
        FntPrint("\n\nCEL-SHADED TMD RENDERING EXAMPLE\nBY LAMEGUY64\n\n");
        FntPrint("2015 - MEIDO-TEK PRODUCTIONS\n");


        // Display stuff
		Display();

	}

}

void init() {

    // Typical libgs init stuff

	RECT clearRect = { 0, 0, SCREEN_XRES, SCREEN_YRES*2 };

	ResetGraph(0);
	GsInitGraph(SCREEN_XRES, SCREEN_YRES, GsNONINTER|GsOFSGPU, SCREEN_DITHER, 0);
	SetDispMask(0);

	#if SCREEN_YRES>256
	GsDefDispBuff(0, 0, 0, 0);
	#else
	GsDefDispBuff(0, 0, 0, SCREEN_YRES);
	#endif

	GsInit3D();
	GsSetProjection(SCREEN_CENTERX);
	GsSetOrign(0, 0);

	myOT[0].length = myOT[1].length = OT_LENGTH;
	myOT[0].org = myOT_TAG[0];
	myOT[1].org = myOT_TAG[1];

	FntLoad(960, 0);
	FntOpen(0, 0, SCREEN_XRES, SCREEN_YRES, 0, 200);

	ClearImage(&clearRect, 0, 100, 0);

	PadInit(0);

}

void PrepDisplay() {

    // Prepares the ordering table and packet buffers for rendering

	myActiveBuff = GsGetActiveBuff();
	GsSetWorkBase(myPacketBuff[myActiveBuff]);
	GsClearOt(0, 0, &myOT[myActiveBuff]);

}

void Display() {

    // Flush font buffer
	FntFlush(-1);

	// Wait for all drawing to finish before processing the next OT
	DrawSync(0);

    // VSync, switch buffers, finalize OT and then draw it
	VSync(0);
	GsSwapDispBuff();
	GsSortClear(0, 50, 100, &myOT[myActiveBuff]);
	GsDrawOt(&myOT[myActiveBuff]);
	SetDispMask(1);

}
