# This is a makefile for the Stars demo
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
OBJECTS	= stars.o lifecube.o array.o 
LINKER = -Xlinker -mpsx

# Make the standard distribution: ColEm and tools.
all:	stars

stars:	${OBJECTS}
	${CC} ${CFLAGS} ${LINKER} -o $@ ${OBJECTS} ${LIBDIR}/libps.a

# Clean up.
clean:
	del stars.o

# Dependencies for the object files.
stars.o:	stars.c pad.h
