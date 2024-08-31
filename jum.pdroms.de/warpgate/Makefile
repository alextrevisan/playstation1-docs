# This is the makefile for "Warpgate"
#
# These are the compiler name, #defines, and the flags used to
# build. Always set flags for the highest possible speed   
# optimization. For GCC compiler, it will be
#             
#        -O3 -fomit-frame-pointer
#             
# use mipsgcc for PSX
CC	= mipsgcc
DEFINES	= #-DDEBUG
CFLAGS	= -O2 ${DEFINES}
INCDIR = ../include
LIBDIR = ../lib
OBJECTS	= wg.o sg256.o ninjakid.o warpmod.o sfx.a
LINKER = -Xlinker -mpsx

# Make the standard distribution: ColEm and tools.
all:	wg

wg:	${OBJECTS}
	${CC} ${CFLAGS} ${LINKER} -o $@ ${OBJECTS} ${LIBDIR}/libps.a

# Clean up.
clean:
	del wg.o

# Dependencies for the object files.
wg.o:	wg.c wg.h pad.h

sg256.o:	sg256.tim
	tim2o sg256
	del sg256.c

ninjakid.o:	ninjakid.tim
	tim2o ninjakid
	del ninjakid.c