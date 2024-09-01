#include <sys/types.h>
#include <libgte.h>
#include <libgpu.h>
#include <libgs.h>
#include <inline_c.h>

#include "tmdstruct.h"


/** TMDcelObj Struct:
 *
 *  Structure of TMD parameters for the SortTMDcel() function.
 *
 *  Variables:
 *
 * 	    TMDaddr* modelAddr          - Pointer to a TMD's data pointers.
 *	    u_short  mapTPage           - TPage value of cel-shader map
 *	    u_short  mapClutID          - CLUT ID value of cel-shader map
 *	    u_char	 mapXsize,mapYsize  - Resolution of cel-shader map in pixels
 *                                    (must be 1 pixel less than the actual value)
 */
typedef struct {
	TMDaddr* modelAddr;
	u_short  mapTPage;
	u_short  mapClutID;
	u_char	 mapXsize,mapYsize;
} TMDcelObj;


/** SortTMDcel() Function:
 *
 *  Sorts a TMD with cel-shading into the specified ordering table. It
 *  only supports TMDs containing untextured gouraud shaded triangles
 *  only and it does not check for incompatible primitive types.
 *
 *  You may want to customize this function to suit your needs...
 *
 *  Parameters:
 *
 *      void SortTMDcel(
 *          GsOT* ot,       - Pointer to valid GsOT struct
 *          TMDcelObj* obj, - Pointer to TMDcelObj struct
 *          int otEntries   - Maximum number of entries in OT
 *      );
 *
 *  Returns:
 *
 *      None.
 *
 */

void SortTMDcel(GsOT* ot, TMDcelObj* obj, int otEntries);
