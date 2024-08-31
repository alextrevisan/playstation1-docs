CFLAGS = -I./include -O2

OBJS =	_start.o \
	gpu.o \
	int.o \
	tmd.o \
	gte.o \
	syscall.o
   

libps.a: $(OBJS)
	del libps.a
	ar -cq libps.a $(OBJS)
	move libps.a lib\\libps.a

clean:
	del lib\libps.a
	del libps.a
	del _start.o
	del gpu.o
	del int.o
	del tmd.o
	del gte.o
	del syscall.o

_start.o: src/_start.c
	gcc $(CFLAGS) -c src/_start.c

gpu.o: src/gpu.s
	gcc $(CFLAGS) -c src/gpu.s

int.o: src/int.s
	gcc $(CFLAGS) -c src/int.s

tmd.o: src/tmd.s
	gcc $(CFLAGS) -c src/tmd.s

gte.o: src/gte.s
	gcc $(CFLAGS) -c src/gte.s

syscall.o: src/syscall.s
	gcc $(CFLAGS) -c src/syscall.s
