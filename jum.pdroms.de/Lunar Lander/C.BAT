mipsgcc -v -I..\include -O2 -Xlinker -mpsx -o %1.psx %1.c ..\lib\libps.a
copy %1.psx c:\emulator\psx\psemupro