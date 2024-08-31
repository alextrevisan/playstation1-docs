#ifndef INT_H
#define INT_H

#include "psxtypes.h"

/* Types */
typedef void (*VSyncCB)(void);
typedef void (*DMACB)(void);
typedef void (*IntCB)(void);

/* Global VSync counter */
extern PsxUInt32 VSyncCount;

/* Functions */
PsxUInt32   INT_GetVSyncCount(void);
PsxUInt16   INT_SetMask(PsxUInt16 newMask);
void        INT_SetUpHandler(void);
void        INT_ResetHandler(void);
IntCB       INT_SetVector(PsxUInt32 intNum, IntCB cb);
VSyncCB     INT_SetVSyncCallback(PsxUInt32 vectNum, VSyncCB cb);
DMACB       INT_SetDMACallBack(PsxUInt32 channel, DMACB cb);

#endif /* INT_H */
