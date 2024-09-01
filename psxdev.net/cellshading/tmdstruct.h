#ifndef TMD_STRUCT_H
#define TMD_STRUCT_H

#include <sys/types.h>

typedef struct {
	u_long id;
	u_long flags;
	u_long nobj;
} TMDheader;

typedef struct {
	SVECTOR* vert_addr;
	u_long vert_count;
	SVECTOR* norm_addr;
	u_long norm_count;
	u_long* prim_addr;
	u_long prim_count;
	long scale;
} TMDaddr;

typedef struct {
	u_char mode;
	u_char flag;
	u_char llen;
	u_char olen;
} TMDprimHead;

typedef struct {
	u_char r,g,b;
	u_char mode;
	u_short n0,v0;
	u_short n1,v1;
	u_short n2,v2;
} TMDprimSFNT;

#endif
