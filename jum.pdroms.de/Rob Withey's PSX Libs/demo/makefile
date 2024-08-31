CFLAGS = -I../include -O2

# Our only target
all: play.psx

# How to link it all together
play.psx: play.o giulieta.lib font.o wall01.o
        gcc $(CFLAGS) -Xlinker -oplay.psx play.o giulieta.lib font.o wall01.o
	eco2exe play.psx

# Lib up the car data files
giulieta.lib: giuli_bd.o giuli_fr.o giuli_pl.o giuli_tl.o giuli_tr.o giuli_wn.o giulieta.o
	del giulieta.lib
	ar -cq giulieta.lib giuli_bd.o giuli_fr.o giuli_pl.o giuli_tl.o giuli_tr.o giuli_wn.o giulieta.o

# How to compile the files
play.o: play.c
	gcc $(CFLAGS) -c play.c

giuli_bd.o: giuli_bd.tim
	bin2src -Figiuli_bd.tim -Fogiuli_bd.c -Lgiuli_bd -C
	gcc $(CFLAGS) -c giuli_bd.c

giuli_fr.o: giuli_fr.tim
	bin2src -Figiuli_fr.tim -Fogiuli_fr.c -Lgiuli_fr -C
	gcc $(CFLAGS) -c giuli_fr.c

giuli_pl.o: giuli_pl.tim
	bin2src -Figiuli_pl.tim -Fogiuli_pl.c -Lgiuli_pl -C
	gcc $(CFLAGS) -c giuli_pl.c

giuli_tl.o: giuli_tl.tim
	bin2src -Figiuli_tl.tim -Fogiuli_tl.c -Lgiuli_tl -C
	gcc $(CFLAGS) -c giuli_tl.c

giuli_tr.o: giuli_tr.tim
	bin2src -Figiuli_tr.tim -Fogiuli_tr.c -Lgiuli_tr -C
	gcc $(CFLAGS) -c giuli_tr.c

giuli_wn.o: giuli_wn.tim
	bin2src -Figiuli_wn.tim -Fogiuli_wn.c -Lgiuli_wn -C
	gcc $(CFLAGS) -c giuli_wn.c

giulieta.o: giulieta.tmd
	bin2src -Figiulieta.tmd -Fogiulieta.c -Lgiulieta -C
	gcc $(CFLAGS) -c giulieta.c

font.o: font.tim
	bin2src -Fifont.tim -Fofont.c -Lfont -C
	gcc $(CFLAGS) -c font.c

wall01.o: wall01.tim
	bin2src -Fiwall01.tim -Fowall01.c -Lwall01 -C
	gcc $(CFLAGS) -c wall01.c

clean:
	del play.psx
        del play.o
#        del giulieta.lib
#        del giuli_bd.o
#        del giuli_fr.o
#        del giuli_pl.o
#        del giuli_tl.o
#        del giuli_tr.o
#        del giuli_wn.o
#        del giulieta.o 
#        del font.o
#        del wall01.o
