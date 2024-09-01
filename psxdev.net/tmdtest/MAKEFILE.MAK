all:
	del tmdtest.exe

	ccpsx -O3 -Xo$80010000 tmdtest.c -otmdtest.cpe
	cpe2x tmdtest.cpe

	del tmdtest.cpe