// quick example of how to use the player in your own stuff

#include <psxtypes.h>
#include <int.h>
#include <gpu.h>
#include <tmd.h>

#define PALx
#define OT_LENGTH 5

static GsOT_TAG     zSortTable[2][1<<OT_LENGTH];   
static PACKET       cmdBuffer[2][3000];

/* The objects for the car */
extern char giuli_bd[], giuli_fr[], giuli_pl[], giuli_tl[];
extern char giuli_tr[], giuli_wn[], giulieta[];
extern char font[], wall01[];

static char greetz[] = "        THIS IS YOUR STANDARD ISSUE SCROLLER."
                       "        WELL HERE I AM WITH MY FIRST INTRO   "
                       "CODED ENTIRELY WITH MY OWN LIBRARIES USING INFO "
                       "FROM THE WEB    THIS REPRESENTS MANY MONTHS OF "
                       " MY WORK TO GET A GRAPHICS LIBRARY TOGETHER   "
                       "GRAPHICS STOLEN FROM VARIOUS PLACES    ALL CODE BY "
                       "ME    HI TO ANYONE WHO KNOWS ME    GREETZ (IN "
                       "NO PARTICULAR ORDER) TO _CHAOS_, NAPALM, HITMEN, "
                       "BITMASTER, BLACKBAG AND CREATURE    I CAN BE "
                       "CONTACTED AT ROB_WITHEY@HOTMAIL.COM    RIGHT    "
                       "TIME TO LOOP            ";
static PsxUInt32    greetzLen, sineOffset;

static TEXQUAD      bgQuad, fontQuad;

static TEXCOORDS    tc[256];

static void
SetUpTC(void)
{
    PsxUInt32   i;

    /* Initialise all as spaces */
    for (i = 0; i < 256; i++)
    {
        tc[i].u = tc[i].v = 0;
    }

    for (i = ' '; i <= 'Z'; i++)
    {
        PsxUInt32 offset = i - ' ';
        tc[i].u = (offset & 7) * 32;
        tc[i].v = (offset >> 3) * 32;
    }

    for (i = 'a'; i <= 'z'; i++)
    {
        PsxUInt32 offset = i - ('z' - 33);
        tc[i].u = (offset & 7) * 32;
        tc[i].v = (offset >> 3) * 32;
    }

    fontQuad.color.r = fontQuad.color.g = fontQuad.color.b = 255;

    fontQuad.clutId = GPU_CalcClutID(320, 256);
    fontQuad.texPage = GPU_CalcTexturePage(320, 0, 0);
}

static void
PrintChar(GsOT *ot, PsxUInt16 pos, PsxUInt16 pixPos, PsxUInt16 yPos,
          PsxUInt16 chr)
{
    fontQuad.texCoords0.u = fontQuad.texCoords1.u = tc[chr].u;
    fontQuad.texCoords0.v = fontQuad.texCoords2.v = tc[chr].v;
    fontQuad.texCoords2.u = fontQuad.texCoords3.u = tc[chr].u + 31;
    fontQuad.texCoords1.v = fontQuad.texCoords3.v = tc[chr].v + 31;

    fontQuad.vert0.x = fontQuad.vert1.x = pixPos;
    fontQuad.vert0.y = fontQuad.vert2.y = yPos;
    fontQuad.vert2.x = fontQuad.vert3.x = pixPos + 31;
    fontQuad.vert1.y = fontQuad.vert3.y = yPos + 31;

    GPU_SortTexQuad(ot, pos, &fontQuad);
}

static void
DrawGreetz(GsOT *ot, PsxUInt16 pos, char *greetz, PsxUInt32 charPos, PsxInt32 pixPos)
{
    while (pixPos < 320)
    {
        char        chr = greetz[charPos];
        PsxInt32    yPos = GTE_Sin((pixPos+sineOffset) * 16) / 128 + 150;
        PrintChar(ot, pos, pixPos, yPos, chr);

        pixPos += 32;
        charPos++;
        charPos %= greetzLen;
    }
}

static void
PrintString(GsOT *ot, PsxUInt16 pos, PsxUInt16 xPos, PsxUInt16 yPos, char *string)
{
    while ((xPos < 320 ) && *string)
    {
        PrintChar(ot, pos, xPos, yPos, *string);

        string++;
        xPos += 32;
    }
}

static void
InitBG(void)
{
    bgQuad.color.r = bgQuad.color.g = bgQuad.color.b = 255;

    bgQuad.vert0.x = bgQuad.vert1.x = 0;
    bgQuad.vert0.y = bgQuad.vert2.y = 0;
    bgQuad.vert2.x = bgQuad.vert3.x = 320;
    bgQuad.vert1.y = bgQuad.vert3.y = 240;

    bgQuad.clutId = GPU_CalcClutID(384, 256);
    bgQuad.texPage = GPU_CalcTexturePage(384, 0, 1);
}

static void
DrawBackGround(GsOT *ot, PsxInt32 offsetX, PsxInt32 offsetY)
{
    offsetX = offsetX & 127;
    offsetY = offsetY & 127;

    bgQuad.texCoords0.u = bgQuad.texCoords1.u = offsetX;
    bgQuad.texCoords0.v = bgQuad.texCoords2.v = offsetY;
    bgQuad.texCoords2.u = bgQuad.texCoords3.u = offsetX | 128;
    bgQuad.texCoords1.v = bgQuad.texCoords3.v = offsetY | 128;

    GPU_SortTexQuad(ot, 2, &bgQuad);
}

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

int main(int argv, char *argc[])
{
    PsxUInt32           palFlag = 0;
    COLOR               color = {0, 0, 0, 0};
    volatile PsxUInt8   padBuf1[34], padBuf2[34];
    /* Scrolling background */
    PsxInt32            deltaBgX, deltaBgY, bgX, bgY;
    /* Spinning object */
    PsxUInt32           deltaXPos, deltaYPos, deltaZPos, xPos, yPos, zPos;
    /* Scrolling text */
    PsxUInt32           greetzPos;
    /* Ordering table */
    GsOT                worldOrderingTable[2];

    /* And we might want to do some PAD stuff */
    InitPAD(padBuf1, 34, padBuf2, 34);
    StartPAD();

    /* Install the interrupt handler */
    INT_SetUpHandler();

    /* Sort out the GPU!!! */
    GPU_SetPAL(palFlag);
    GPU_Reset(0);

    GPU_Init(320, 240, GsNONINTER, 0);
    GPU_DefDispBuff(0, 0, 0, 240);

    /* Get ready for some GTE stuff!!! */
    GTE_Init(320, 240);

    /* Mess with the palette */
    GPU_TIMGetClut((TIMHEADER *)font)->clutData[15] = 0;

    /* Load the images */
    UpLoadImage((TIMHEADER *)giuli_bd);
    UpLoadImage((TIMHEADER *)giuli_fr);
    UpLoadImage((TIMHEADER *)giuli_pl);
    UpLoadImage((TIMHEADER *)giuli_tl);
    UpLoadImage((TIMHEADER *)giuli_tr);
    UpLoadImage((TIMHEADER *)giuli_wn);
    UpLoadImage((TIMHEADER *)font);
    UpLoadImage((TIMHEADER *)wall01);

    /* Sync up the image uploads */
    GPU_DrawSync();

    /* Set up the order tables */
    worldOrderingTable[0].length = OT_LENGTH;
    worldOrderingTable[0].org = zSortTable[0];
    worldOrderingTable[1].length = OT_LENGTH;
    worldOrderingTable[1].org = zSortTable[1];

    /* This is the efficient way to do things.  Whilst the
     * previous screen is being rendering, we are calculating
     * the next one.  Hence we gain maximum parallelism
     * between the GTE,CPU and GPU.  (This can be seen from
     * the fact that we sync the previous draw and flip the
     * display just before we start the next frame rendering).
     */

    /* Set up the scroller */
    greetzLen = sizeof(greetz);
    greetzPos = 0;
    sineOffset = 0;
    SetUpTC();

    deltaBgX = deltaBgY = 0;
    bgX = bgY = 0;
    InitBG();

    deltaXPos = deltaYPos = deltaZPos = 0;
    xPos = yPos = zPos = 0;

    padBuf1[2] = 255;
    padBuf1[3] = 255;
    while ((padBuf1[2] & 0x9))
    {
        PsxUInt32   outputBufferIndex;
        GsOT        *ot;
        MATRIX      ltm, matrix;
        PsxInt16    sine, cosine;

        if ((~padBuf1[3]) & 0x40)
        {
            palFlag ^= MODE_PAL;
            GPU_SetPAL(palFlag);
            GPU_Reset(0);

            GPU_Init(320, 240, GsNONINTER, 0);
            GPU_DefDispBuff(0, 0, 0, 240);

            /* Get ready for some GTE stuff!!! */
            GTE_Init(320, 240);
            /* Wait for button to come up again */
            while ((~padBuf1[3]) & 0x40)
                ;
        }

        /* Set up the buffers */
        outputBufferIndex = GPU_GetActiveBuff();
        ot = &worldOrderingTable[outputBufferIndex];
        GPU_ClearOt(0, 0, ot);
        GPU_SetCmdWorkSpace(cmdBuffer[outputBufferIndex]);

        /* Set up the clear for the next frame */
        GPU_SortClear(outputBufferIndex ^ 1, ot, &color);

        deltaXPos += 0x4;
        deltaYPos += 0x14;
        deltaZPos += 0x18;

        xPos += GTE_Sin(deltaXPos) >> 7;
        yPos += GTE_Sin(deltaYPos) >> 7;
        zPos += GTE_Sin(deltaZPos) >> 7;

        /* Rotate about y axis */
        sine = GTE_Sin(yPos);
        cosine = GTE_Cos(yPos);
        GTE_MatrixSetIdentity(&ltm);
        ltm.m[0][0] = ltm.m[2][2] = cosine;
        ltm.m[0][2] = sine;
        ltm.m[2][0] = -sine;

        /* Rotate about x axis */
        sine = GTE_Sin(xPos);
        cosine = GTE_Cos(xPos);
        GTE_MatrixSetIdentity(&matrix);
        matrix.m[1][1] = matrix.m[2][2] = cosine;
        matrix.m[1][2] = sine;
        matrix.m[2][1] = -sine;
        GTE_MatMul(&ltm, &ltm, &matrix);

        /* Rotate about z axis */
        sine = GTE_Sin(zPos);
        cosine = GTE_Cos(zPos);
        GTE_MatrixSetIdentity(&matrix);
        matrix.m[0][0] = matrix.m[1][1] = cosine;
        matrix.m[0][1] = sine;
        matrix.m[1][0] = -sine;
        GTE_MatMul(&ltm, &ltm, &matrix);

        /* Scale */
        sine = 10000;
        GTE_MatrixSetIdentity(&matrix);
        matrix.m[0][0] = matrix.m[1][1] = matrix.m[2][2] = sine;
        GTE_MatMul(&ltm, &ltm, &matrix);

        /* Set translation vector for cube */
        ltm.t[0] = 0;
        ltm.t[1] = 0;
        ltm.t[2] = 0x1000;

        /* Render it */
        TMD_Render(ot, (TMDHEADER *)giulieta, &ltm, TRUE);

        GPU_DrawSync();
        GPU_VSync();
        GPU_FlipDisplay();

        deltaBgX += 19;
        deltaBgY += 42;

        bgX += GTE_Sin(deltaBgX >> 1);
        bgY += GTE_Sin(deltaBgY >> 1);

        /* Draw the background */
        DrawBackGround(ot, bgX >> 10, bgY >> 10);

        /* Draw the scroller */
        DrawGreetz(ot, 4, greetz, greetzPos >> 5, 0 - (greetzPos & 31));

        /* Process the buffers (in the background, of course) */
        GPU_DrawOt(ot);

        greetzPos += 2;
        greetzPos %= (greetzLen << 5);

        sineOffset -= 2;
    }

    INT_ResetHandler();

    StopPAD();

    return 0;
}
