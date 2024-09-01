# Run this makefile only with mingw32-make or msys' make.

# Notes:
#	- msys has problems launching DOS programs even if your OS can run them no problem.
#	- Dosbox is required since DMPSX.EXE is a DOS program and does not work on a 64-bit OS,
#	  you can easily change it to run DMPSX.EXE directly however without having to go
#	  through an emulator if your OS can run DOS programs directly.

TARGET  = main
ADDRESS	= 0x80010000

CFLAGS	= -O3 -Wall

all:

	ccpsx $(CFLAGS) -c tmdcel.c

	@echo @echo off >dosbox.bat
	@echo dmpsx.exe tmdcel.obj >>dosbox.bat
	@echo exit >>dosbox.bat
	"C:\Program Files (x86)\DOSBox-0.74\dosbox.exe" dosbox.bat
	@del dosbox.bat

	ccpsx -Xo$(ADDRESS) $(CFLAGS) main.c loadtim.c tmdcel.obj suzanne/suzanne.c celmap.c -o$(TARGET).cpe,$(TARGET).sym
	cpe2x $(TARGET).cpe
