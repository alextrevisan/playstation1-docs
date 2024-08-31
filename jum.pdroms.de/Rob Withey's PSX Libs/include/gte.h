#ifndef GTE_H
#define GTE_H

#include "psxtypes.h"

/* GTE operations */
void        GTE_Init(PsxUInt32 screenWidth, PsxUInt32 screenHeight);
void        GTE_SetOffset(PsxInt16 x, PsxInt16 y);
void        GTE_SetFogColor(PsxUInt8 r, PsxUInt8 g, PsxUInt8 b);

void        GTE_SV3Scale(SVECTOR3D *vectOut, SVECTOR3D *vectIn,
                         PsxUInt16 scale, PsxUInt32 quantity);
void        GTE_SV3XForm(SVECTOR3D *vectOut, SVECTOR3D *vectIn,
                         MATRIX *mat, PsxUInt32 quantity);
void        GTE_V3XForm(VECTOR3D *vectOut, VECTOR3D *vectIn,
                        MATRIX *mat, PsxUInt32 quantity);

void        GTE_MatMul(MATRIX *matOut, MATRIX *matIn1, MATRIX *matIn2);
void        GTE_IsPolyFront(SVECTOR2D *vert0, SVECTOR2D *vert1, SVECTOR2D *vert2);
PsxUInt32   GTE_AverageZ3(PsxInt32 z1, PsxInt32 z2, PsxInt32 z3);
PsxUInt32   GTE_AverageZ4(PsxInt32 z1, PsxInt32 z2, PsxInt32 z3, PsxInt32 z4);

void        GTE_ParallelProject(SVECTOR2D *vertOut, SVECTOR3D *vertIn, PsxUInt32 quantity);

/* General matrix operations */
void        GTE_MatrixSetIdentity(MATRIX *matrix);

/* General maths operations */
PsxInt16    GTE_Sin(PsxInt16 angle);
PsxInt16    GTE_Cos(PsxInt16 angle);

#endif /* GTE_H */
