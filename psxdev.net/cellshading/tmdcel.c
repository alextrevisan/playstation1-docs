#include "tmdcel.h"

/**
 * NOTE: This file must be compiled as a separate .obj file which then should
 * be passed through DMPSX.EXE for the GTE macros to actually work.
 */

void SortTMDcel(GsOT* ot, TMDcelObj* obj, int otEntries) {

	int		p,v0,v1,v2;
	long	flag,nclip,pri;
	CVECTOR	srcCol;

	char* 		primTemp = (char*)obj->modelAddr->prim_addr;
	POLY_FT3*	poly     = (POLY_FT3*)GsOUT_PACKET_P;

    // Use cel-shading map resolution as source colors
    // (we'll be using the resulting vertex colors as texcoords for cel-shading)
	srcCol.r = obj->mapXsize;
	srcCol.g = obj->mapYsize;
	srcCol.b = 0;

    // Render the model
	for(p=0; p<obj->modelAddr->prim_count; p++) {

        // GTE macros don't like arithmetic in their arguments so we have to do this
		v0 = ((TMDprimSFNT*)(primTemp+4))->v0;
		v1 = ((TMDprimSFNT*)(primTemp+4))->v1;
		v2 = ((TMDprimSFNT*)(primTemp+4))->v2;

		// Load 3D vertices to the GTE registers
		gte_ldv3(
			&obj->modelAddr->vert_addr[v0],
			&obj->modelAddr->vert_addr[v1],
			&obj->modelAddr->vert_addr[v2]
		);
		// Rotate, translate and perspective transformation
		gte_rtpt();
		// Retrieve flag result from GTE
		gte_stflg(&flag);
		// Normal clip
		gte_nclip();

        // Test if flag is greater than 0 (near-z clip check)
		if (flag > 0) {

			// Retrieve nclip (also opz) result from GTE
			gte_stopz(&nclip);

			// If nclip is negative, it means we're looking at the back of the
			// polygon (in other words, this is where back-face culling detection takes place)
			if (nclip > 0) {

				// Average Z values of vertexes (OTZ)
				gte_avsz3();
				// Retrieve OTZ value from GTE (for z-sorting)
				gte_stotz(&pri);

				// Only sort primitive if its within the range of the OT
				if (pri > 0 && pri < otEntries) {

					// Retrieve resulting 2D vertex coords from the GTE and store it directly into
					// our primitive for speed.
					gte_stsxy3(
                        (long*)&poly->x0,
                        (long*)&poly->x1,
                        (long*)&poly->x2
                    );

					// Perform light source calculation
					v0 = ((TMDprimSFNT*)(primTemp+4))->n0;
					v1 = ((TMDprimSFNT*)(primTemp+4))->n1;
					v2 = ((TMDprimSFNT*)(primTemp+4))->n2;
					srcCol.cd = 0x24;
					// Load base color to GTE registers
					gte_ldrgb(&srcCol);
					// Load normal vectors to GTE registers
					gte_ldv3(
						&obj->modelAddr->norm_addr[v0],
						&obj->modelAddr->norm_addr[v1],
						&obj->modelAddr->norm_addr[v2]
					);
					// Normal Color Color Triple light calculation
					gte_ncct();
					// Retrieve resulting color values and set them directly as texcoords
					// for speed.
					gte_strgb3(
                        &poly->u0,
                        &poly->u1,
                        &poly->u2
                    );

					// Make sure the texcoords do not exceed our cel-shading map otherwise we'll see
					// glitches in the brighter parts of the model
					if (poly->u0 > obj->mapXsize) poly->u0 = obj->mapXsize;
					if (poly->u1 > obj->mapXsize) poly->u1 = obj->mapXsize;
					if (poly->u2 > obj->mapXsize) poly->u2 = obj->mapXsize;
					if (poly->v0 > obj->mapYsize) poly->v0 = obj->mapYsize;
					if (poly->v1 > obj->mapYsize) poly->v1 = obj->mapYsize;
					if (poly->v2 > obj->mapYsize) poly->v2 = obj->mapYsize;

					// Set tag and code values to the primitive (required to work properly)
					poly->tag	= 0x7001000;
					poly->code	= 0x24;

					// Set TPage, CLUT and primitive color
					poly->tpage	= obj->mapTPage;
					poly->clut	= obj->mapClutID;
					poly->pad1	= 0;
					poly->r0 = poly->g0 = poly->b0 = 128;

					// Sort primitive to OT
					addPrim(ot->org+pri, poly);

				}

			}

		}

		// Go to next primitive
		primTemp += 20;
		poly++;

	}

	// Update packet pointer of libgs to current
	GsOUT_PACKET_P = (PACKET*)poly;

}
