Library source for the Playstation
==================================


Overview
========

This is the start of some freely available libraries for the Playstation.
Currently only partial graphics support is available, though I am working
on more.

The example demo which comes with this source release shows how to use the
library, along with some of my other tools.


What is here
============

o   Source and executable for bin2src, a utility that can be used to turn a binary
    file into a R3000 ASM or a C source file, to be subsequently compiled or assembled
    and linked into an application.  I use this from a makefile to implement incbin
    where it is not available.
o   Source and library for libps.a, a replacement for the libps.a that comes with
    the Yaroze kit.  You can use your own library with the GNU tools that are
    supplied with the Yaroze kit, and download using your favourite method.  Since
    this is a library replacment, you don't need to download libps.exe to the
    Playstation first.  I suggest you use the header files as your documentation
    for now, since I have not written anything special.
o   Source and executable for a demo using the library, to get you started in the
    world of 3d Playstation graphics programming.


File list
=========

readme.txt                      This file

makefile                        Makefile for the library, builds lib\libps.a

bin2src\bin2src.c               Source for bin2src tool
bin2src\bin2src.dsp             VC5 project file for bin2src tool
bin2src\bin2src.dsw             VC5 project file for bin2src tool
bin2src\bin2src.exe             Console executable for bin2src tool
bin2src\bin2src.opt             VC5 project file for bin2src tool
bin2src\bin2src.plg             VC5 project file for bin2src tool

demo\doit.bat                   Builds and runs the demo using libps.a
demo\font.tim                   Font graphics used in the demo
demo\giuli_bd.tim               Car texture
demo\giuli_fr.tim               Car texture
demo\giuli_pl.tim               Car texture
demo\giuli_tl.tim               Car texture
demo\giuli_tr.tim               Car texture
demo\giuli_wn.tim               Car texture
demo\giulieta.tmd               Car object
demo\makefile                   Makefile for building the demo
demo\play.c                     Source for the demo
demo\play.psx                   Executable for the demo
demo\wall01.tim                 Background graphics used in the demo

include\gpu.h                   GPU header file for graphics operations
include\gte.h                   GTE header file for transform operations
include\hwreg.h                 Header file containing list of hardware regs
include\int.h                   INT header file for interrupt operations
include\psxtypes.h              Header file containing basic types
include\syscall.h               Header file for BIOS calls
include\tmd.h                   TMD header file for 3d object operations

lib\libps.a                     Produced library

src\_start.c                    Application startup code
src\gpu.s                       GPU source file for graphics operations
src\gte.s                       GTE source file for transform operations
src\int.s                       INT source file for interrupt operations
src\syscall.s                   Source file for providing access to BIOS calls
src\tmd.s                       TMD source file for 3d object operations


Things for the future
=====================

I am continually developing the libraries to bring in more functionality
as and when I figure out how stuff works.  Please be patient.

Things which are coming (eventually):

CD support.
Sound support.
MDEC support.
Serial I/O support.
Documentation.

Please Email any suggestions to rob_withey@hotmail.com


Rob Withey (19/01/1999)
