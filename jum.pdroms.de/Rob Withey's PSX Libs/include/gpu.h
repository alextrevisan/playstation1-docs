#ifndef GPU_H
#define GPU_H

#include "psxtypes.h"

/****************/
/****************/
/* Order tables */
/****************/
/****************/

typedef struct
{
    unsigned    p : 24;             /* Pointer to next bit */
    unsigned    num : 8;            /* Length of this entry */
}
GsOT_TAG;

typedef struct
{
    PsxUInt16       length;         /* Bit length of the ordering table */
    GsOT_TAG        *org;           /* Pointer to the start of the ordering table */
    PsxUInt32       offset;         /* Z axis offset */
    PsxUInt32       point;          /* Z axis typical value */
    GsOT_TAG        *tag;           /* Pointer to current GsOT_TAG */
}
GsOT;

typedef struct
{
    /* This is just a useful chunk of memory - just happens to be big enough for
     * a gouraud shaded texture quadrangle plus a GsOT_TAG !!!??
     */
    PsxUInt32        buffer[13];
}
PACKET;

/***************************************/
/***************************************/
/* Internal structures for GPU library */
/***************************************/
/***************************************/

typedef struct
{
    RECT        disp;               /* Frame buffer display area */
    RECT        screen;             /* Output screen display area */
    PsxUInt8    isInterlaced;       /* 0-noninterlaced, 1-interlaced */
    PsxUInt8    isRGB24;            /* 0-16 bit mode, 1-24 bit mode */
    PsxUInt8    pad0, pad1;         /* System reserved */
}
DISPENV;

typedef struct
{
    GsOT_TAG    header;
    PsxUInt32   clipAreaStartCmd;
    PsxUInt32   clipAreaEndCmd;
    PsxUInt32   drawingOffsetCmd;
    PsxUInt32   drawingModeCmd;
    PsxUInt32   textureWindowCmd;
    PsxUInt32   priorityCmd;
}
DR_ENV;

typedef struct
{
    RECT        clip;               /* Drawing area */
    PsxUInt16   offset[2];          /* Drawing offset */
    RECT        texWindow;          /* Texture window */
    PsxUInt16   texPage;            /* Texture page initial value */
    PsxUInt8    dither;             /* 0-dither off, 1-dither on */
    PsxUInt8    displayDraw;        /* 0-permit drawing to display area */
                                    /* 1-disable drawing to display area */
    PsxUInt32   pad ;               /* Clear drawing area flag when env established */
    DR_ENV      drEnv;              /* Commands to set up the GPU */
}
DRAWENV;

/**********************************/
/**********************************/
/* GPU primitives command buffers */
/**********************************/
/**********************************/

typedef struct
{
    PsxUInt8    u, v;
}
TEXCOORDS;

typedef struct
{
    COLOR       color;
    SVECTOR2D   vert0, vert1;
}
LINE;

typedef struct
{
    COLOR       color0;
    SVECTOR2D   vert0;
    COLOR       color1;
    SVECTOR2D   vert1;
}
CILINE;

typedef struct
{
    COLOR       color;
    SVECTOR2D   vert0, vert1, vert2;
}
TRI;

typedef struct
{
    COLOR       color0;
    SVECTOR2D   vert0;
    COLOR       color1;
    SVECTOR2D   vert1;
    COLOR       color2;
    SVECTOR2D   vert2;
}
CITRI;

typedef struct
{
    COLOR       color;
    SVECTOR2D   vert0;
    TEXCOORDS   texCoords0;
    PsxUInt16   clutId;
    SVECTOR2D   vert1;
    TEXCOORDS   texCoords1;
    PsxUInt16   texPage;
    SVECTOR2D   vert2;
    TEXCOORDS   texCoords2;
    PsxUInt16   pad;
}
TEXTRI;

typedef struct
{
    COLOR       color0;
    SVECTOR2D   vert0;
    TEXCOORDS   texCoords0;
    PsxUInt16   clutId;
    COLOR       color1;
    SVECTOR2D   vert1;
    TEXCOORDS   texCoords1;
    PsxUInt16   texPage;
    COLOR       color2;
    SVECTOR2D   vert2;
    TEXCOORDS   texCoords2;
    PsxUInt16   pad;
}
CITEXTRI;

typedef struct
{
    COLOR       color;
    SVECTOR2D   vert0, vert1, vert2, vert3;
}
QUAD;

typedef struct
{
    COLOR       color0;
    SVECTOR2D   vert0;
    COLOR       color1;
    SVECTOR2D   vert1;
    COLOR       color2;
    SVECTOR2D   vert2;
    COLOR       color3;
    SVECTOR2D   vert3;
}
CIQUAD;

typedef struct
{
    COLOR       color;
    SVECTOR2D   vert0;
    TEXCOORDS   texCoords0;
    PsxUInt16   clutId;
    SVECTOR2D   vert1;
    TEXCOORDS   texCoords1;
    PsxUInt16   texPage;
    SVECTOR2D   vert2;
    TEXCOORDS   texCoords2;
    PsxUInt16   pad1;
    SVECTOR2D   vert3;
    TEXCOORDS   texCoords3;
    PsxUInt16   pad2;
}
TEXQUAD;

typedef struct
{
    COLOR       color0;
    SVECTOR2D   vert0;
    TEXCOORDS   texCoords0;
    PsxUInt16   clutId;
    COLOR       color1;
    SVECTOR2D   vert1;
    TEXCOORDS   texCoords1;
    PsxUInt16   texPage;
    COLOR       color2;
    SVECTOR2D   vert2;
    TEXCOORDS   texCoords2;
    PsxUInt16   pad1;
    COLOR       color3;
    SVECTOR2D   vert3;
    TEXCOORDS   texCoords3;
    PsxUInt16   pad2;
}
CITEXQUAD;

typedef struct
{
    COLOR       color;
    SVECTOR2D   pos, size;
}
BOXFILL;

/*******************/
/*******************/
/* TIM image files */
/*******************/
/*******************/

typedef struct
{
    PsxUInt32   id;                 /* Should be 0x00000010 */
    PsxUInt32   flags;              /* What kind of image is this? */
}
TIMHEADER;

typedef struct
{
    PsxUInt32   dataLen;            /* Len of clut block (inc. this word) */
    RECT        vRamPos;            /* Position clut is to be loaded into VRam */
    PsxUInt16   clutData[2];        /* May be 16 or 256 entries */
}
TIMCLUT;

typedef struct
{
    PsxUInt32   dataLen;            /* Len of pixel data block (inc. this word) */
    RECT        vRamPos;            /* Position pixel data is to be loaded into VRam */
    PsxUInt16   imageData[2];       /* Is usually more than 2 entries!!! */
}
TIMIMAGE;

#define TIMHDR_4BITCLUT     0
#define TIMHDR_8BITCLUT     1
#define TIMHDR_15BIT        2
#define TIMHDR_24BIT        3
#define TIMHDR_MIXED        4
#define TIMHDR_CLUTPRESENT  8

/*******/
/*******/
/* API */
/*******/
/*******/

#define MODE_PAL    1
#define GsNONINTER  0
#define GsINTER     1

/* Initialisation */
void        GPU_SetPAL(PsxInt32 palFlag);
PsxInt32    GPU_Reset(PsxInt32 mode);
PsxInt32    GPU_Init(PsxInt32 xRes, PsxInt32 yRes,
                     PsxInt32 intl, PsxInt32 depth24);

/* Buffer management */
void        GPU_DefDispBuff(PsxInt32 x0, PsxInt32 y0,
                            PsxInt32 x1, PsxInt32 y1);
PsxInt32    GPU_GetActiveBuff(void);
PsxInt32    GPU_VSync(void);
void        GPU_EnableDisplay(PsxInt32 enable);
void        GPU_FlipDisplay(void);

/* Dealing with images */
TIMCLUT     *GPU_TIMGetClut(TIMHEADER *tim);
TIMIMAGE    *GPU_TIMGetImage(TIMHEADER *tim);
void        GPU_LoadImageData(RECT *area, PsxUInt16 *imageData);

/* Get ready for filling the order table */
void        GPU_SetCmdWorkSpace(PACKET *memoryBuffer);
void        GPU_ClearOt(PsxUInt16 offset, PsxUInt16 point, GsOT *orderTable);

/* Shove things into the order table */
void        GPU_SortBoxFill(GsOT *orderTable, PsxUInt16 pos,
                            BOXFILL *boxFill);
void        GPU_SortClear(PsxUInt32 bufferIndex, GsOT *orderTable, COLOR *color);

void        GPU_SortLine(GsOT *orderTable, PsxUInt32 pos,
                         LINE *line);
void        GPU_SortCiLine(GsOT *orderTable, PsxUInt32 pos,
                           CILINE *ciLine);

void        GPU_SortTriangle(GsOT *orderTable, PsxUInt16 pos,
                             TRI *tri);
void        GPU_SortCiTriangle(GsOT *orderTable, PsxUInt16 pos,
                               CITRI *ciTri);
void        GPU_SortTexTriangle(GsOT *orderTable, PsxUInt16 pos,
                                TEXTRI *texTri);
void        GPU_SortCiTexTriangle(GsOT *orderTable, PsxUInt16 pos,
                                  CITEXTRI *ciTexTri);

void        GPU_SortQuad(GsOT *orderTable, PsxUInt16 pos,
                         QUAD *quad);
void        GPU_SortCiQuad(GsOT *orderTable, PsxUInt16 pos,
                           CIQUAD *ciQuad);
void        GPU_SortTexQuad(GsOT *orderTable, PsxUInt32 pos,
                            TEXQUAD *texQuad);
void        GPU_SortCiTexQuad(GsOT *orderTable, PsxUInt32 pos,
                              CITEXQUAD *ciTexQuad);

/* Figuring out commands for primitives */
PsxUInt16   GPU_CalcClutID(PsxUInt16 x, PsxUInt16 y);
PsxUInt16   GPU_CalcTexturePage(PsxUInt16 x, PsxUInt16 y, PsxUInt32 clutMode);

/* Drawing and making sure the order table is drawn */
void        GPU_DrawOt(GsOT *orderTable);
PsxInt32    GPU_DrawSync(void);

/* Dealing with images */
PsxUInt32   GPU_LoadImage(RECT *area, PsxUInt8 *data);
PsxUInt32   GPU_ClearImage(RECT *area, PsxUInt32 rgb);

#endif /* GPU_H */
