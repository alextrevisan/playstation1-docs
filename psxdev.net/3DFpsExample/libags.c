// Primitive sizes as u_longs
#define	POLY_F3_size	(sizeof(POLY_F3)+3)/4
#define	POLY_F4_size	(sizeof(POLY_F4)+3)/4
#define	POLY_FT3_size	(sizeof(POLY_FT3)+3)/4
#define POLY_FT4_size	(sizeof(POLY_FT4)+3)/4


// AGs structs
typedef struct {
	u_short	px,py;	// Image offset in the framebuffer
	u_short pw,ph;	// Image size
	u_short tpage;	// Framebuffer page ID of texture
	u_short mode;	// Color mode (0 - 4-bit, 1 - 8-bit, 2 - 16-bit, 3 - 24-bit)
	u_short cx,cy;	// Image CLUT offset in the framebuffer
	u_short clutid;	// TIM's CLUT ID
} AGsIMAGE;


int AGsLoadTim(u_long *timaddr, AGsIMAGE *paddr);


int AGsLoadTim(u_long *timaddr, AGsIMAGE *paddr) {
	
	/*
		0: 4-bit CLUT
		1: 8-bit CLUT
		2: 16-bit DIRECT
		3: 24-bit DIRECT
	*/
	
	TIM_IMAGE timinfo;
	
	// Get the TIM's header
	if (OpenTIM(timaddr) != 0) {
		#if DEBUG == 2
		printf("Error getting TIM info in address %x\n", timaddr);
		#endif
		return(1);
	}
	ReadTIM(&timinfo);
	
	#if DEBUG == 2
	printf("Info of TIM in %x:\n", timaddr);
	printf("   Pixel mode: %d\n", timinfo.mode&3);
	printf("   Texture Xpos: %d\n", timinfo.prect->x);
	printf("   Texture Ypos: %d\n", timinfo.prect->y);
	printf("   Texture Xdim: %d\n", timinfo.prect->w);
	printf("   Texture Ydim: %d\n", timinfo.prect->h);
	#endif
	
	// Upload the TIM image data to the framebuffer
	LoadImage(timinfo.prect, timinfo.paddr);
	DrawSync(0);
	
	// Set parameters for *paddr
	paddr->px = timinfo.prect->x;
	paddr->py = timinfo.prect->y;
	paddr->pw = timinfo.prect->w;
	paddr->ph = timinfo.prect->h;
	paddr->tpage = GetTPage(timinfo.mode, 0, timinfo.prect->x, timinfo.prect->y);
	
	// If TIM has a CLUT (if color depth is lower than 16-bit), upload it as well
	if ((timinfo.mode & 3) < 2) {
		LoadImage(timinfo.crect, timinfo.caddr);
		DrawSync(0);
		#if DEBUG == 2
		printf("   CLUT Xpos: %d\n", timinfo.crect->x);
		printf("   CLUT Ypos: %d\n", timinfo.crect->y);
		#endif
		paddr->cx = timinfo.crect->x;
		paddr->cy = timinfo.crect->y;
		paddr->clutid = GetClut(timinfo.crect->x, timinfo.crect->y);
	}
	
	return(0);
	
}