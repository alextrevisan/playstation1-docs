// loony.h
// header file for loony.c (doh!)
// Jum Hig 1999
//

typedef struct {
	PsxUInt32 x;
	PsxUInt32 y;
	PsxInt16 dx;
	PsxInt16 dy;
	PsxInt16 drot;
	PsxUInt8 ttl;				// decay time
} Fragment;
