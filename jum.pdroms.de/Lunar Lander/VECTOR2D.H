// PSX Loony Lander vector stuff header file
// Jum Hig 10/1999


// Vector line primitive
typedef struct {
	PsxInt16 ls;			// line start vert index
	PsxInt16 le;			// line end vert index
	COLOR cs;			// line start colour
	COLOR ce;			// line end colour
} VecLine;

// Vector object struct
typedef struct {
	PsxUInt16 x;					// fix pt 10.6
	PsxUInt16 y;					// fix pt 10.6
	PsxInt16 rot;
	PsxInt16 scale;
	PsxUInt8 brightness;
	PsxInt16 numverts;
	PsxInt16 numlines;
	SVECTOR2D vtx[20];		// 20 vertices
	VecLine line[20];
} VecObj;

// Simple vector line struct (for explosions, landscape, etc)
// (basically a 1-line object)
typedef struct {
	PsxUInt16 x;					// fix pt 10.6
	PsxUInt16 y;					// fix pt 10.6
	PsxInt16 rot;
	PsxInt16 scale;
	PsxUInt8 brightness;
	SVECTOR2D vtx[2];		// 2 vertices, rel to prim x & y
	COLOR cs;
	COLOR ce;
} VecPrim;

// for vector letters
typedef struct {
	PsxUInt8 numlines;
	PsxUInt8 ls[8];
	PsxUInt8 le[8];
} VecLetter;
