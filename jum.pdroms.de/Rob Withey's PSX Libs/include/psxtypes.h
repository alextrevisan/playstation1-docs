/* Playstation types */

#ifndef PSXTYPES_H
#define PSXTYPES_H

#ifndef NULL
#define NULL ((void *)0)
#endif /* NULL */

#ifndef FALSE
#define FALSE 0
#endif /* FALSE */

#ifndef TRUE
#define TRUE 1
#endif /* TRUE */

typedef signed char     PsxInt8;
typedef unsigned char   PsxUInt8;
typedef signed short    PsxInt16;
typedef unsigned short  PsxUInt16;
typedef signed int      PsxInt32;
typedef unsigned int    PsxUInt32;

typedef struct
{
    PsxUInt16   x, y, w, h;
}
RECT;

typedef struct
{
    PsxUInt8    r, g, b, pad;
}
COLOR;

typedef struct
{
    PsxInt16    x, y;
}
SVECTOR2D;

typedef struct
{
    PsxInt16    x, y, z, pad;
}
SVECTOR3D;

typedef struct
{
    PsxInt32    x, y, z;
}
VECTOR3D;

typedef struct
{
    PsxInt16    m[3][3];                    /* These are 4.12 */
    PsxInt16    pad;
    PsxInt32    t[3];                       /* These are 20.12 */
}
MATRIX;

#endif /* PSXTYPES_h */
