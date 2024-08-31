/* Startup code for Playstation */

#include <psxtypes.h>
#include <syscall.h>

extern PsxUInt32 _fbss[];
extern PsxUInt32 _end[];
extern PsxUInt32 _gp[];
register PsxUInt32 *gp asm("gp");

extern void main(void);

_start()
{
    PsxUInt32   *addr;
    PsxUInt32   size = 0x1FFFFF - (((PsxUInt32)_end) & 0xFFFFFF);

    for (addr = _fbss; addr < _end; *addr++ = 0)
        ;

    gp = _gp;

    InitHeap((void *)_end, size);
    
    main();
}

__main()
{
}
