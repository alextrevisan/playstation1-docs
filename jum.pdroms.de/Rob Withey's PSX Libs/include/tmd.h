#ifndef TMD_H
#define TMD_H

#include "psxtypes.h"
#include "gpu.h"

/********************/
/********************/
/* TMD object files */
/********************/
/********************/

typedef struct
{
    PsxUInt32   id;
    PsxUInt32   flags;
    PsxUInt32   numObjects;
}
TMDHEADER;

typedef struct
{
    PsxUInt16   x, y, z, pad;       /* Vertices of the objects */
}
TMDVERTEX;

typedef struct
{
    PsxUInt16   x, y, z, pad;       /* Normals of the object */
}
TMDNORMAL;

typedef struct
{
    PsxUInt8    oLen;               /* Word length of output buffer after processing */
    PsxUInt8    iLen;               /* Word length of input parameter data (after header) */
    PsxUInt8    flag;               /* Flags */
    PsxUInt8    mode;               /* Primitive type and options */
}
TMDPRIMHDR;

typedef struct
{
    TMDVERTEX   *vertexAddr;        /* Address of vertices *if FIXP, addr is fixed up) */
    PsxUInt32   numVertices;        /* Number of vertices */
    TMDNORMAL   *normalAddr;        /* Address of normals (if FIXP, addr is fixed up) */
    PsxUInt32   numNormals;         /* Number of normals */
    TMDPRIMHDR  *primitiveAddr;     /* Address of primitives (if FIXP, addr is fixed up) */
    PsxUInt32   numPrimitives;      /* Number of primitives */
    PsxUInt32   logScale;           /* 2^logScale is the scale value */
}
TMDOBJECT;

#define TMDHDR_FIXP         0x1L    /* This object's addresses have been fixed up */

#define TMDMODE_CODEMASK    0xE0    /* Mask for primitive type */
#define TMDMODE_OPTIONMASK  0x1F    /* Mask for options */
#define TMDMODE_CODESPRITE  0x60    /* This is a sprite */
#define TMDMODE_CODELINE    0x40    /* This is a line */
#define TMDMODE_CODEPOLY    0x20    /* This is a triangle or quadrilateral */

#define TMDFLAG_GRADUATION  0x10    /* This is a smooth shaded polygon */
#define TMDFLAG_4VERTICES   0x08    /* This is a quadrilateral */
#define TMDFLAG_TEXTURED    0x04    /* This is a textured polygon */
#define TMDFLAG_DOUBLESIDE  0x02    /* This is a double sided polygon */
#define TMDFLAG_LIT         0x01    /* This is a lit polygon */

TMDHEADER *TMD_FixUp(TMDHEADER *tmd);
TMDHEADER *TMD_Render(GsOT *orderTable, TMDHEADER *tmd,
                      MATRIX *ltm, PsxInt32 persp);

#endif /* TMD_H */

