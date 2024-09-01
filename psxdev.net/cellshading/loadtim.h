#ifndef _LOADTIM_H
#define _LOADTIM_H

#include <sys/types.h>
#include <libgte.h>
#include <libgpu.h>

typedef struct {
	u_short	px,py;	// Image offset in the framebuffer
	u_short pw,ph;	// Image size
	u_short tpage;	// Framebuffer page ID of texture
	u_short mode;	// Color mode (0 - 4-bit, 1 - 8-bit, 2 - 16-bit, 3 - 24-bit)
	u_short cx,cy;	// Image CLUT offset in the framebuffer
	u_short clutid;	// TIM's CLUT ID
} TimIMAGE;

int LoadTim(u_long *timaddr, TimIMAGE *paddr);

#endif // _LOADTIM_H
