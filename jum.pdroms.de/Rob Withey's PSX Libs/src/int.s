###############################################################################
# INTERRUPT STUFF #
###############################################################################

###############################################################################

	.rdata
	.align	4

	.globl	VSyncCount
VSyncCount:
	.word	0								# VSync counter

	.lcomm	IntJmpBuf,4096					# Jmp buf for the interrupt handler

	.lcomm	InterruptVectors,44				# 11 interrupt vectors
	.lcomm	VSyncVectors,32					# 8 VSync callback vectors
	.lcomm	DMACallbacks,32					# 8 DMA channel callback vectors

###############################################################################

	.text
	.set	noreorder
	.align	4

###############################################################################

	.globl	INT_GetVSyncCount
	.ent	INT_GetVSyncCount
INT_GetVSyncCount:
	LW		$2, VSyncCount
	JR		$31
	NOP
	.end	INT_GetVSyncCount

###############################################################################

	.globl	INT_SetMask
	.ent	INT_SetMask						# PsxUInt16 INT_SetMask(PsxUInt16 mask)
INT_SetMask:								# {
	LUI		$3, 0x1F80						#     PsxUInt16 oldMask = *1F801074;
	LHU		$2, 0x1074($3)					#
	SH		$4, 0x1074($3)					#     return(oldMask);
	NOR		$4, $0, $4
	JR		$31								#     *1F801074 = mask;
	SH		$4, 0x1070($3)					#     *1F801070 = ~mask;
	.end	INT_SetMask						# }

###############################################################################

	.globl	INT_SetUpHandler				# void INT_SetUpHandler(void)
	.ent	INT_SetUpHandler				# {
INT_SetUpHandler:							#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x14($29)					#
											#
	LUI		$2, 0x1F80						#     /* Turn off all the interrupts */
	SH		$0, 0x1074($2)					#     *0x1F801074 = 0;
	SH		$0, 0x1070($2)					#     *0x1F801070 = 0;
											#
	LI		$5, 0x33333333					#
	SW		$5, 0x10F0($2)					#     *0x1F8010F0 = 0x33333333;
											#
	LA		$4, InterruptVectors			#     /* Reset all the vectors */
	ADDU	$5, $0, $0						#     memset(&InterruptVectors, 0, 44);
	JAL		memset							#
	ADDIU	$6, $0, 0x2C					#
											#
	LA		$4, IntJmpBuf					#     memset(&IntJmpBuf, 0, 4096);
	LI		$6, 4096						#
	JAL		memset							#
	ADDU	$5, $0, $0						#     /* Set up a jump block */
											#     if (setjmp(&IntJmpBuf))
	LA		$4, IntJmpBuf					#     {
	JAL		setjmp							#         /* Ends up in here on interrupt */
	NOP										#         Int_Handler();
											#     }
											#
	BNE		$2, $0, Int_Handler				#     /* This branches if we got here as a */
											#     /* result of an interrupt generation */
											#
											#     /* Fill in the stack pointer */
	LA		$4, IntJmpBuf					#     IntJmpBuf[1] = &IntJmpBuf[0x3F8];
	ADDI	$2, $4, 0xFE0					#
	JAL		HookEntryInt					#     /* And set the vector */
	SW		$2, 0x4($4)						#     HookEntryInt(&IntJmpBuf);
											#
	JAL		ExitCriticalSection				#     ExitCriticalSection();
	NOP										#
											#
	JAL		Int_InitDMACallbacks			#     /* Set up the DMA handler */
	NOP										#     Int_InitDMACallbacks();
											#
	JAL		Int_InitVSyncCallbacks			#     /* And the VSync handler */
	NOP										#     Int_InitVSyncCallbacks();
											#
	LW		$31, 0x14($29)					#     return;
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
											#
Int_Handler:								# IntHandler:
	LUI		$2, 0x1F80						#
	LHU		$8, 0x1070($2)					#     PsxUInt16 reg = *(PsxUInt16 *)0x1F801070;
	LHU		$16, 0x1074($2)					#     PsxUInt16 mask = *(PsxUInt16 *)0x1F801074;
	LA		$17, InterruptVectors			#
	AND		$16, $16, $8					#     reg &= mask;
HandleInterrupts:							#     while (reg != 0)
	ORI		$18, $0, 0xB					#     {
	ORI		$19, $0, 0x1					#         PsxUInt16 bit = 1;
HandleAnotherInt:							#         PsxUInt32 *vector = InterruptVectors;
	BEQ		$16, $0, ExitIntHandler			#
	AND		$8, $16, $19					#         for (i = 0; i < 11; i++)
	BEQ		$8, $0, DontHandleThisInt		#         {
	ADDIU	$18, $18, 0xFFFF				#             if (reg & bit)
	LW		$8, 0x0000($17)					#             {   if (!reg) break;
	NOR		$9, $0, $19						#                 *(PsxUInt16 *)0x1F801070 = ~bit;
	LUI		$2, 0x1F80						#                 reg &= ~bit;
	SH		$0, 0x1070($2)					#                 if (*vector)
	BEQ		$8, $0, DontHandleThisInt		#                 {
	AND		$16, $16, $9					#                     *vector();
	JALR	$31, $8							#                 }
	NOP										#             }
DontHandleThisInt:							#             bit <<= 1;
	SLL		$19, $19, 0x01					#             vector++;
	BNE		$18, $0, HandleAnotherInt		#         }
	ADDIU	$17, $17, 0x4					#
											#
	J		Int_Handler						#     }
	NOP										#
											#
ExitIntHandler:								#     /* Leave the interrupt handler */
	J		ReturnFromException				#     ReturnFromException();
	NOP										#
	.end	INT_SetUpHandler				# }

###############################################################################

	.globl	INT_ResetHandler				# void INT_ResetHandler(void)
	.ent	INT_ResetHandler				# {
INT_ResetHandler:							#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x14($29)					#
											#
	JAL		EnterCriticalSection			#     EnterCriticalSection();
	NOP										#
											#
	LUI		$2, 0x1F80						#     /* Turn off the interrupts */
	SH		$0, 0x1074($2)					#     *(PsxUInt16 *)0x1F801074 = 0;
	SH		$0, 0x1070($2)					#     *(PsxUInt16 *)0x1F801070 = 0;
											#
	JAL		ResetEntryInt					#     /* Reset the vector */
	NOP										#     ResetEntryInt();
											#
	JAL		ExitCriticalSection				#     ExitCriticalSection();
	NOP										#
											#
	LW		$31, 0x14($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	INT_ResetHandler				# }

###############################################################################

	.globl	INT_SetVector
	.ent	INT_SetVector					# FnPoint INT_SetVector(PsxUInt32 intNum,
INT_SetVector:								#                       FnPoint vect)
	ADDIU	$29, $29, 0xFFD8				# {
	SW		$31, 0x24($29)					#     FnPoint oldVect = InterruptVectors[intNum];
	SW		$20, 0x20($29)					#     /* This will hold oldVect */
	SW		$18, 0x18($29)					#     /* This will hold vect */
	SW		$17, 0x14($29)					#     /* This will hold intNum */
											#
	ADDU	$17, $4, $0						#
	ADDU	$18, $5, $0						#
											#
	LA		$5, InterruptVectors			#
	SLL		$2, $17, 0x2					#
	ADDU	$4, $2, $5						#
	LW		$20, 0x0($4)					#
											#     PsxUInt16 intBit;
	LUI		$2, 0x1F80						#     PsxUInt16 mask = *0x1F801074;
	LHU		$8, 0x1074($2)					#
	SH		$0, 0x1074($2)					#     *0x1F801074 = 0;
											#
	SW		$18, 0x0($4)					#     InterruptVectors[intNum] = vect;
	ADDIU	$3, $0, 0x1						#     intBit = 1 << intNum;
	SLLV	$3, $3, $17						#
	BNE		$18, $0, DoneIntMasks			#     mask |= intBit;
	OR		$8, $8, $3						#     if (!vect)
											#     {
	NOR		$3, $0, $3						#         mask &= ~intBit;
	AND		$8, $8, $3						#     }
DoneIntMasks:								#
	LUI		$2, 0x1F80						#     *0x1F801074 = mask;
	SH		$8, 0x1074($2)					#
											#     /* Reset the interrupt */
	SH		$3, 0x1070($2)					#     *0x1F801070 = ~(1 << intNum);
											#
	LA		$2, ExtraIntSetup				#
	SLL		$17, $17, 0x2					#
	ADDU	$2, $2, $17						#
	LW		$2, 0x0($2)						#
	NOP
	JR		$2
	NOP

ExtraIntSetup0:
	JAL		ChangeClearPAD					#     ChangeClearPAD(vect ? 1 : 0);
	SLTIU	$4, $18, 0x1					#
	ADDIU	$4, $0, 0x3						#
	JAL		ChangeClearRCnt					#     ChangeClearRCnt(3, vect ? 1 : 0);
	SLTIU	$5, $18, 0x1					#
	J		ExitIntSetup					#

ExtraIntSetup4:								#
	ADDU	$4, $0, $0						#
	JAL		ChangeClearRCnt					#     ChangeClearRCnt(0, vect ? 1 : 0);
	SLTIU	$5, $18, 0x1					#
	J		ExitIntSetup					#

ExtraIntSetup5:								#
	ADDIU	$4, $0, 0x1						#     ChangeClearRCnt(1, vect ? 1 : 0);
	JAL		ChangeClearRCnt					#
	SLTIU	$5, $18, 0x1					#
	J		ExitIntSetup					#

ExtraIntSetup6:								#
	ADDIU	$4, $0, 0x2						#     ChangeClearRCnt(2, vect ? 1 : 0);
	JAL		ChangeClearRCnt					#
	SLTIU	$5, $18, 0x1					#

ExitIntSetup:								#
	ADDU	$2, $20, $0						#
	LW		$31, 0x24($29)					#
	LW		$20, 0x20($29)					#
	LW		$18, 0x18($29)					#
	LW		$17, 0x14($29)					#
	JR		$31								#     return(oldVect);
	ADDIU	$29, $29, 0x28					#
	.end	INT_SetVector					# }

ExtraIntSetup:
	.word	ExtraIntSetup0
	.word	ExitIntSetup
	.word	ExitIntSetup
	.word	ExitIntSetup
	.word	ExtraIntSetup4
	.word	ExtraIntSetup5
	.word	ExtraIntSetup6
	.word	ExitIntSetup
	.word	ExitIntSetup
	.word	ExitIntSetup
	.word	ExitIntSetup
	.word	ExitIntSetup

###############################################################################

	.ent	Int_InitVSyncCallbacks			# void Int_InitVSyncCallbacks(void)
Int_InitVSyncCallbacks:						# {
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	SW		$0, VSyncCount					#     VSyncCount = 0;
											#
	LA		$4, VSyncVectors				#     memset(&VSyncVectors, 0, 32);
	ADDU	$5, $0, $0						#
	JAL		memset							#
	ADDIU	$6, $0, 0x20					#
											#
	LA		$5, Int_VSyncIntHandler			#     INT_SetVector(0, Int_VSyncIntHandler);
	JAL		INT_SetVector					#
	ADDU	$4, $0, $0						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	Int_InitVSyncCallbacks			# }

###############################################################################

	.ent	Int_VSyncIntHandler				# void Int_VSyncIntHandler(void)
Int_VSyncIntHandler:						# {
	ADDIU	$29, $29, 0xFFE0				#     PsxInt	i;
	SW		$17, 0x14($29)					#     VSyncCB	*cb;
	SW		$16, 0x10($29)					#

	LW		$2, VSyncCount					#     VSyncCount++;
	SW		$31, 0x18($29)					#
	ADDIU	$2, $2, 0x1						#
	SW		$2, VSyncCount					#

	LA		$16, VSyncVectors				#     cb = &VSyncVectors;
	ADDU	$17, $0, 0x8					#     i = 8;
AnotherVSyncVector:							#     while (i--)
	LW		$2, 0x0($16)					#     {
	ADDIU	$16, $16, 0x4					#         if (*cb)
	BEQ		$2, $0, VSyncVectorIsZero		#         {
	ADDIU	$17, $17, 0xFFFF				#             *cb();
	JALR	$31, $2							#         }
	NOP										#         cb++;
VSyncVectorIsZero:							#     }
	BNE		$17, $0, AnotherVSyncVector		#
	NOP										#
	LW		$31, 0x18($29)					#
	LW		$17, 0x14($29)					#
	LW		$16, 0x10($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x20					#
	.end	Int_VSyncIntHandler				# }

###############################################################################

	.globl	INT_SetVSyncCallback			# VSyncCB INT_SetVSyncCallback(PsxInt32 vectNum,
	.ent	INT_SetVSyncCallback			#                              VSyncCB vect)
INT_SetVSyncCallback:						# {
	LA		$2, VSyncVectors				#     VSyncCB oldVect = VSyncVectors[vectNum];
	SLL		$4, $4, 0x2						#
	ADDU	$4, $4, $2						#     VSyncVectors[vectNum] = vect;
	LW		$2, 0x0($4)						#

	LUI		$2, 0x1F80						#     /* Kick the interrupt */
	LHU		$3, 0x1074($2)					#
	NOP										#
	SH		$3, 0x1074($2)					#

	JR		$31								#
	SW		$5, 0x0($4)						#
	.end	INT_SetVSyncCallback			# }

###############################################################################

	.ent	Int_InitDMACallbacks			# void Int_InitDMACallbacks(void)
Int_InitDMACallbacks:						# {
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	LA		$4, DMACallbacks				#     memset(&DMACallbacks, 0, 32);
	ADDU	$5, $0, $0						#
	JAL		memset							#
	ADDIU	$6, $0, 0x20					#
											#
	LUI		$2, 0x1F80						#     *0x1F8010F4 = 0;
	SW		$0, 0x10F4($2)					#
											#
	LA		$5, Int_DMAIntHandler			#     INT_SetVector(3, Int_DMAIntHandler);
	JAL		INT_SetVector					#
	ADDIU	$4, $0, 0x3						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	Int_InitDMACallbacks			# }

###############################################################################

	.ent	Int_DMAIntHandler				# void Int_DMAIntHandler(void)
Int_DMAIntHandler:							# {
	ADDIU	$29, $29, 0xFFD0				#     PsxUInt32 chanFlag, bit;
	SW		$31, 0x28($29)					#
	SW		$18, 0x18($29)					# /* This will hold the vector array pointer */
	SW		$17, 0x14($29)					# /* This will hold the channel flag */
	SW		$16, 0x10($29)					# /* This will hold the counter */
CheckDMAChannels:							#
	LUI		$2, 0x1F80						#
	LW		$2, 0x10F4($2)					#     /* Find out which channels to handle */
	LI		$16, 0x01000000					#     bit = 0x01000000;
	SRL		$2, $2, 0x18					#     
	ANDI	$17, $2, 0x7F					#     while (chanFlag = (*0x1F8010F4 >> 24) & 0x7F)
	BEQ		$17, $0, NoMoreDMAChannels		#     {
	LA		$18, DMACallbacks				#
CheckAnotherDMAChan:						#
	ANDI	$2, $17, 0x1					#         if (chanFlag & 1)
	BEQ		$2, $0, DontCallDMACallback		#         {
											#
	LUI		$4, 0x1F80						#
	LW		$3, 0x10F4($4)					#             *0x1F8010F4 &= (bit | 0xFFFFFF);
	LI		$5, 0xFFFFFF					#
	OR		$2, $16, $5						#
	AND		$3, $3, $2						#
	SW		$3, 0x10F4($4)					#
											#             /* Call the callback */
	LW		$2, 0x0($18)					#             DMACallbacks[chan]();
	NOP										#         }
	BEQ		$2, $0, DontCallDMACallback		#         bit <<= 1;
	NOP										#         chanFlag >>= 1;
	JALR	$31, $2							#
	NOP										#
DontCallDMACallback:						#
	ADDIU	$18, $18, 0x4					#
	SLL		$16, $16, 0x1					#
	BNE		$17, $0, CheckAnotherDMAChan	#     }
	SRL		$17, $17, 0x1					#
	J		CheckDMAChannels				#
	NOP										#
NoMoreDMAChannels:							#
	LW		$31, 0x28($29)					#
	LW		$18, 0x18($29)					#
	LW		$17, 0x14($29)					#
	LW		$16, 0x10($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x30					#
	.end	Int_DMAIntHandler				# }

###############################################################################

	.globl	INT_SetDMACallback
	.ent	INT_SetDMACallback				# PsxUInt32 INT_SetDMACallback(PsxUInt32 index,
INT_SetDMACallback:							#                              PsxUInt32 val)
	LUI		$6, 0x1F80						# {
	LHU		$3, 0x1074($6)					#     /* Kick the interrupt */
	NOP										#
	SH		$3, 0x1074($6)					#

	LA		$3, DMACallbacks				#     PsxUInt32 oldVal = DMACallbacks[index];
	SLL		$4, $4, 0x2						#     PsxUInt32 icr;
	ADDU	$3, $3, $4						#     PsxUInt32 bitToSet;
	LW		$2, 0x0($3)						#
	SW		$5, 0x0($3)						#     DMACallbacks[index] = val;
											#
	LW		$3, 0x10F4($6)					#     icr = *0x1F8010F4;
											#
	LI		$7, 0x00FFFFFF					#     icr &= 0xFFFFFF;
	AND		$3, $3, $7						#
											#
	LI		$7, 0x00800000					#     icr |= 0x800000;
	OR		$3, $3, $7						#
											#
	LUI		$7, 0x1							#     bitToSet = 0x10000 << index;
	SLLV	$7, $7, $6						#
											#     icr |= bitToSet;
	BNE		$5, $0, EnableDMACallback		#     if (val == 0)
	OR		$3, $3, $7						#     {
											#
	NOR		$7, $0, $7						#         icr &= ~bitToSet;
	AND		$3, $3, $7						#     }
EnableDMACallback:							#     *0x1F8010F4 = icr;
	JR		$31								#     return (oldVal);
	SW		$3, 0x10F4($6)					#
	.end	INT_SetDMACallback				# }

###############################################################################
