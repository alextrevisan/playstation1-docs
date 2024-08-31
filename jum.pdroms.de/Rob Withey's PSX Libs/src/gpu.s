###############################################################################

	.rdata
	.align	2
VSyncTimeOutString:		.ascii	"GPU_VSync: timeout\n\000"

###############################################################################

PalFlag:				.byte	0
GPUType:				.byte	0

	.align	2

VRAMHeight:				.hword	0

###############################################################################

	.align	4

DispEnvDispX:			.word	0
DispEnvDispW:			.word	0
DispEnvScrnX:			.word	0
DispEnvScrnW:			.word	0
DispEnvIsInter:			.byte	0
DispEnvIsRGB24:			.byte	0

###############################################################################

	.align	2

VRAMConfigSize:			.hword	0x200, 0x400, 0x400, 0x200, 0x400

###############################################################################

	.align	4

# Terminator for the order table
OrderTableTerminator:	.word	0x00FFFFFF

###############################################################################

	.align	4

	.lcomm	WatchDogVSyncCount,4			# Primary watchdog counter
	.lcomm	WatchDogTimeout,4				# Secondary watchdog counter
	.lcomm	QueTail,4						# Push onto the tail
	.lcomm	QueHead,4						# Pop from the head
	.lcomm	TmpIntMaskStore1,4				# Temp storage for int mask
	.lcomm	TmpIntMaskStore2,4				# Temp storage for int mask
	.lcomm	TmpIntMaskStore3,4				# Temp storage for int mask

	.lcomm	CmdBufferAddress,4				# Buffer for filling order tables

	.lcomm	StateCache,256					# This caches values written to GPU1
	.lcomm	QueBuffer,64*64					# Que buffer (64 * 64 byte entries)

###############################################################################

	.align	4

# Some command blocks for the GPU
CommandBlock1Header:	.word	0
CommandBlock1Word1:		.word	0
CommandBlock1Word2:		.word	0
CommandBlock1Word3:		.word	0
CommandBlock1Word4:		.word	0
CommandBlock1Word5:		.word	0
CommandBlock1Word6:		.word	0
CommandBlock1Word7:		.word	0
CommandBlock1Word8:		.word	0

CommandBlock2Header:	.word	0
CommandBlock2Word1:		.word	0
CommandBlock2Word2:		.word	0
CommandBlock2Word3:		.word	0

###############################################################################

	.align	4

# The clear commands (one for each buffer)
ClearOT0:				.word	0x03000000	# The pointer and block length
ClearCol0:				.word	0x02000000	# The color and blockfill command
ClearPos0:				.word	0			# The clear pos
ClearSize0:				.word	0			# The clear size

###############################################################################

	.align	4

ClearOT1:				.word	0x03000000	# The pointer and block length
ClearCol1:				.word	0x02000000	# The color and blockfill command
ClearPos1:				.word	0			# The clear pos
ClearSize1:				.word	0			# The clear size

###############################################################################

	.align	4

DisplayOffset0:			.word	0			# Offset for buffer 0
DisplayOffset1:			.word	0			# Offset for buffer 1

###############################################################################

	.align	4

DrawEnvClipX:			.word	0			# Clip rectangle
DrawEnvClipW:			.word	0			#
DrawEnvOffsetX:			.word	0			# Draw offset
DrawEnvTexWinX:			.word	0			# Texture window
DrawEnvTexWinW:			.word	0			#
DrawEnvTPage:			.hword	0			# Texture page
DrawEnvDither:			.byte	0			# Dither enable
DrawEnvDisplayDraw:		.byte	0			# Display draw enable
						.word	0			# USED TO BE CLEAR DRAW ENV FLAG AND COLOR
DrawEnvDrEnv:			.word	0x06FFFFFF	# GsOT_TAG (for DMA transfer)
						.word	0			# ClipAreaStartCommand
						.word	0			# ClipAreaEndCommand
						.word	0			# DrawingOffsetCommand
						.word	0			# DrawingModeCommand
						.word	0			# TextureWindowCommand
						.word	0			# PriorityCommand

###############################################################################

	.align	4

TmpDispEnvDispX:		.word	0			# Display position
TmpDispEnvDispW:		.word	0			# Display size
TmpDispEnvScrnX:		.hword	0			# Display screen pos x
TmpDispEnvScrnY:		.hword	0			# Display screen pos y
TmpDispEnvScrnW:		.word	0			# Display screen size
TmpDispEnvIsInter:		.byte	0			# Interlaced enable
TmpDispEnvIsRGB24:		.byte	0			# 24 bit enable

###############################################################################

	.align	2

BufferIndex:			.hword	0			# 0 or 1 - index of current double buffer

	.align	4

FrameCounter:			.word	0			# Count the display flips

###############################################################################

	.align 4

ScreenSize:				.word	0			# Width and height of screen in pixels

	.text
	.set	noreorder
	.align	4

###############################################################################

	.globl	GPU_Reset						# PsxUInt8 GPU_Reset(PsxInt32 mode)
	.ent	GPU_Reset						# {
GPU_Reset:									#     /* returns debug type */
	ADDIU	$29, $29, 0xFFE0				#
	SW		$17, 0x14($29)					#
	SW		$31, 0x18($29)					#
	ADDU	$17, $4, $0						#
	ANDI	$3, $17, 0x7					#
											#
	BEQ		$3, $0, LargeReset				#
	ADDIU	$2, $0, 0x3						#     switch (mode & 7)
	BEQ		$3, $2, LargeReset				#     {
	ADDIU	$2, $0, 0x5						#         {
	BNE		$3, $2, SmallReset				# 
LargeReset:									#
	LA		$4, GPUType						#             memset(&GPUType, 0,
	ADDU	$5, $0, $0						#                    VRamConfigSize -
	LA		$6, VRAMConfigSize				#                    GPUType);
	JAL		memset							#
	SUB		$6, $6, $4						#
											#
	JAL		Gpu_Fn800161E0					#             GPUType = Gpu_Fn800161E0(mode);
	ADDU	$4, $17, $0						#
	SB		$2, GPUType						#
											#
	ANDI	$2, $2, 0xFF					#
	SLL		$2, $2, 0x1						#
											#
	LA		$3, VRAMConfigSize				#
	ADDU	$3, $3, $2						#             VRAMHeight = VRAMConfigSize[GPUType].y;
	LH		$2, 0x0($3)						#
	NOP										#
	SH		$2, VRAMHeight					#
											#
	LA		$4, DispEnvDispX				#             /* Clear disp env structure */
	ADDIU	$5, $0, 0xFFFF					#             memset(&DispEnvDispX, -1, 20);
	JAL		memset							#
	ADDIU	$6, $0, 0x12					#
											#
	LBU		$2, GPUType						#             return(GPUType);
	J		ExitGPU_Reset					#         }
	NOP										#
SmallReset:									#         default:
	JAL		Gpu_Fn800161E0					#         {
	ADDIU	$4, $0, 0x1						#             return(Gpu_Fn800161E0(1));
ExitGPU_Reset:								#         }
	LW		$31, 0x18($29)					#
	LW		$17, 0x14($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x20					#     }
	.end	GPU_Reset						# }

###############################################################################

	.globl	GPU_EnableDisplay				# void GPU_EnableDisplay(PsxInt32 enable)
	.ent	GPU_EnableDisplay				# {
GPU_EnableDisplay:							#     PsxUInt32 ctrlWrd;
	ADDIU	$29, $29, 0xFFE0				#
	SW		$31, 0x18($29)					#     if (!enable)
	BNE		$4, $0, WriteDisplayMask		#     {
	LUI		$4, 0x0300						#
											#         /* Invalidate display structure */
	LA		$4, DispEnvDispX				#         memset(&DispEnvDispX, -1, 20);
	ADDIU	$5, $0, 0xFFFF					#
	JAL		memset							#         /* Disable display */
	ADDIU	$6, $0, 0x14					#         ctrlWrd = 0x3000001;
											#     }
	ORI		$4, $4, 0x1						#     else
WriteDisplayMask:							#     {
	JAL		Gpu_WriteGPU1					#         /* Enable display */
	NOP										#         ctrlWrd = 0x3000000;
	LW		$31, 0x18($29)					#     }
	ADDIU	$29, $29, 0x20					#     Gpu_WriteGPU1(ctrlWrd);
	JR		$31								#
	NOP										#
	.end	GPU_EnableDisplay				# }

###############################################################################

	.ent	Gpu_ClearOTagR					# GsOT_TAG *Gpu_ClearOTagR(GsOT_TAG *org,
Gpu_ClearOTagR:								#                          PsxUInt32 length)
	ADDIU	$29, $29, 0xFFE0				# {
	SW		$16, 0x10($29)					#
	SW		$31, 0x18($29)					#
											#
	JAL		Gpu_DoDMAOTClear				#     Gpu_DoDMAOTClear(org, length);
	ADDU	$16, $4, $0						#
											#
	LI		$4, 0xFFFFFF					#     /* Terminate the order table list */
	ADDU	$2, $16, $0						#     org->p = &OrderTableTerminator & 0xFFFFFF;
	LA		$3, OrderTableTerminator		#
	AND		$3, $3, $4						#
	SW		$3, 0x0($2)						#
											#
	LW		$31, 0x18($29)					#
	LW		$16, 0x10($29)					#
	JR		$31								#     return(org);
	ADDIU	$29, $29, 0x20					#
	.end	Gpu_ClearOTagR					# }

###############################################################################

	.ent	Gpu_PutDrawEnv					# void Gpu_PutDrawEnv(DRAWENV *drawEnv)
Gpu_PutDrawEnv:								# {
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x14($29)					#
	SW		$17, 0x10($29)					#
											#
	ADDU	$17, $4, $0						#
											#
	ADDU	$5, $17, $0						#     Gpu_ConvDrawEnvToGPUCmds(&drawEnv->drEnv,
	JAL		Gpu_ConvDrawEnvToGPUCmds		#                              drawEnv);
	ADDU	$4, $17, 0x1C					#
											#
	LA		$4, Gpu_DoDMATransfer			#     /* Ship it */
	ADDIU	$5, $17, 0x1C					#     Gpu_EnqueOp(Gpu_DoDMATransfer,
	ADDIU	$6, $0, 0x40					#                 &drawEnv->drEnv,
	JAL		Gpu_EnqueOp						#                 28, 0);
	ADDU	$7, $0, $0						#
											#
	ADDU	$2, $17, $0						#     return(drawEnv);
	LW		$31, 0x14($29)					#
	LW		$17, 0x10($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x18					#
	.end	Gpu_PutDrawEnv					# }

###############################################################################

	.ent	Gpu_PutDispEnv					# Gpu_PutDispEnv(DISPENV *dispEnv)
Gpu_PutDispEnv:								# {
	ADDIU	$29, $29, 0xFFD8				#     PsxUInt32 dispOffset;
	SW		$16, 0x10($29)					#
	SW		$17, 0x14($29)					#
	SW		$18, 0x18($29)					#
	SW		$31, 0x20($29)					#
											#
	LBU		$2, GPUType						#     if (GPUType <= 2)
	ADDU	$16, $4, $0						#     {
											#
	SLTIU	$2, $2, 0x3						#
	BEQ		$2, $0, Label800144B0			#
	NOP										#
											#
	JAL		Gpu_Fn8001521C					#         dispOffset = (dispEnv->disp.y&0xFFF << 12) |
	ADDU	$4, $16, $0						#                      (Gpu_Fn8001521C(dispEnv) &0xFFF);
	LHU		$3, 0x2($16)					#
	ANDI	$2, $2, 0xFFF					#
	ANDI	$3, $3, 0xFFF					#     }
	J		AssembleDisplayOffset			#     else
	SLL		$3, $3, 0xC						#     {
Label800144B0:								#         dispOffset = (dispEnv->disp.y&0x3FF << 10) |
	LHU		$2, 0x0($16)					#                      (dispEnv->disp.x&0x3FF);
	LHU		$3, 0x2($16)					#     }
	ANDI	$2, $2, 0x3FF					#
	ANDI	$3, $3, 0x3FF					#
	SLL		$3, $3, 0xA						#
AssembleDisplayOffset:						#
	OR		$3, $3, $2						#
	LI		$4, 0x05000000					#     Gpu_WriteGPU1(0x05000000 | dispOffset);
	JAL		Gpu_WriteGPU1					#
	OR		$4, $4, $3						#
											#
	LW		$2, DispEnvScrnX				#     if ((dispEnv->screen.x != DispEnvScrnX) ||
	LW		$3, 0x8($16)					#         (dispEnv->screen.y != DispEnvScrnY) ||
	LW		$4, DispEnvScrnW				#         (dispEnv->screen.w != DispEnvScrnW) ||
	LW		$5, 0xC($16)					#         (dispEnv->screen.h != DispEnvScrnH))
											#     {
	XOR		$2, $2, $3						#         PsxInt32 left, right, top, bottom;
	XOR		$4, $4, $5						#
	OR		$2, $2, $4						#
	BEQ		$2, $0, DontUpdateDispEnvScrn	#
											#
											#         /* Deal with screen.x and screen.y */
	LH		$3, 0x8($16)					#         left = (screen.x * 10) + 608;
	LBU		$8, PalFlag						#
	SLL		$4, $3, 0x2						#
	ADDU	$3, $3, $4						#
	SLL		$3, $3, 0x1						#
	ADDIU	$3, $3, 0x260					#
											#
	LH		$4, 0xA($16)					#         top = (screen.y + PAL ? 19 : 16);
	BEQ		$8, $0, ItsNTSC1				#
	ADDIU	$17, $4, 0x10					#
	ADDIU	$17, $4, 0x13					#
ItsNTSC1:									#
											#         /* Deal with screen.w */
	LH		$5, 0xC($16)					#         if (screen.w)
	NOP										#         {
	BEQ		$5, $0, ScreenWProcessed		#             right = left + screen.w * 10;
	ADDIU	$6, $3, 0xA00					#         }
											#         else
	SLL		$2, $5, 0x2						#         {
	ADDU	$2, $2, $5						#             right = left + 256 * 10;
	SLL		$2, $2, 0x1						#         }
	ADDU	$6, $3, $2						#
ScreenWProcessed:							#
											#         /* Deal with screen.h */
	LH		$2, 0xE($16)					#         bottom = top + screen.h ? screen.h : 240;
	NOP										#
	BNE		$2, $0, ScreenHProcessed		#
	ADDU	$18, $17, $2					#
	ADDIU	$18, $17, 0xF0					#
ScreenHProcessed:							#
											#
	SLTI	$2, $3, 0x1F4					#         if (left < 500)
	BNE		$2, $0, LeftClamped				#             left = 500;
	ADDIU	$5, $0, 0x1F4					#         else if (left > 3290)
	SLTI	$2, $3, 0xCDB					#             left = 3290;
	BEQ		$2, $0, LeftClamped				#
	ADDIU	$5, $0, 0xCDA					#
	ADDU	$5, $3, $0						#
LeftClamped:								#
	ADDU	$3, $5, $0						#
											#
	ADDIU	$5, $3, 0x50					#         if (right < left + 80)
	SLT		$2, $6, $5						#             right = left + 80;
	BNE		$2, $0, RightClamped			#         else if (right > 3290)
	SLTI	$2, $6, 0xCDB					#             right = 3290;
	BEQ		$2, $0, RightClamped			#
	ADDIU	$5, $0, 0xCDA					#
	ADDU	$5, $6, $0						#
RightClamped:								#
	ADDU	$6, $5, $0						#
											#
	SLTI	$2, $17, 0x10					#         if (top < 16)
	BNE		$2, $0, TopClamped				#             top = 16;
	ADDIU	$4, $0, 0x10					#         else if (top > PAL ? 310 : 256)
	BEQ		$8, $0, ClampTopNTSC			#             top = PAL ? 310 : 256;
	ADDIU	$4, $0, 0x100					#
	ADDIU	$4, $0, 0x136					#
ClampTopNTSC:								#
	SLT		$2, $17, $4						#
	BEQ		$2, $0, TopClamped				#
	NOP										#
	ADDU	$4, $17, $0						#
TopClamped:									#
	ADDU	$17, $4, $0						#
											#
	ADDIU	$5, $17, 0x2					#         if (bottom < top + 2)
	SLT		$2, $18, $5						#             bottom = top + 2;
	BNE		$2, $0, BottomClamped			#         else if (bottom > PAL ? 312 : 258)
	NOP										#             bottom = PAL ? 312 : 258;
	BEQ		$8, $0, ClampBottomNTSC			#
	ADDIU	$5, $0, 0x102					#
	ADDIU	$5, $0, 0x138					#
ClampBottomNTSC:							#
	SLT		$2, $18, $5						#
	BEQ		$2, $0, BottomClamped			#
	NOP										#
	ADDU	$5, $18, $0						#
BottomClamped:								#
	ADDU	$18, $5, $0						#
											#
	ANDI	$2, $6, 0xFFF					#         Gpu_WriteGPU1(0x6000000 |
	SLL		$2, $2, 0xC						#                       (left & 0xFFF) |
	ANDI	$4, $3, 0xFFF					#                       ((right & 0xFFF) << 12));
	LI		$3, 0x06000000					#
	OR		$4, $4, $3						#
	JAL		Gpu_WriteGPU1					#
	OR		$4, $2, $4						#
											#
	ANDI	$2, $18, 0x3FF					#         Gpu_WriteGPU1(0x7000000 |
	SLL		$2, $2, 0xA						#                       (top & 0x3FF) |
	ANDI	$4, $17, 0x3FF					#                       ((bottom & 0x3FF) << 10));
	LI		$3, 0x07000000					#
	OR		$4, $4, $3						#
	JAL		Gpu_WriteGPU1					#
	OR		$4, $2, $4						#
											#     }
DontUpdateDispEnvScrn:						#
	LW		$2, DispEnvIsInter				#     if ((dispEnv->isInterlaced != DispEnvIsInter) ||
	LW		$3, 0x10($16)					#         (dispEnv->disp.x != DispEnvDispX) ||
	LW		$4, DispEnvDispX				#         (dispEnv->disp.y != DispEnvDispY) ||
	LW		$5, 0x0($16)					#         (dispEnv->disp.w != DispEnvDispW) ||
	LW		$8, DispEnvDispW				#         (dispEnv->disp.h != DispEnvDispH))
	LW		$9, 0x4($16)					#     {
											#
	XOR		$2, $2, $3						#
	XOR		$4, $4, $5						#
	XOR		$8, $8, $9						#
											#
	OR		$2, $2, $4						#
	OR		$2, $2, $8						#
											#
	BEQ		$2, $0, DontUpdateDispEnvDisp	#
	NOP										#
											#
	LI		$4, 0x08000000					#         PsxUInt32 cmd = 0x08000000;
											#
	LBU		$8, PalFlag						#         /* First do some flag bits */
	LB		$9, 0x11($16)					#
	LB		$10, 0x10($16)					#
	LH		$3, 0x4($16)					#
											#
	SLL		$8, $8, 0x3						#         /* Pal selection flag */
	OR		$4, $4, $8						#         cmd |= PalFlag << 3;
											#
	SLL		$9, $9, 4						#         /* 24 bit selection flag */
	OR		$4, $4, $9						#         cmd |= isrgb24 << 4;
											#
	SLL		$10, $10, 5						#         /* Interlaced flag */
	OR		$4, $4, $10						#         cmd |= isinter << 5;
											#
	SLTI	$2, $3, 0x119					#         if (disp.w <= 280)
	BNE		$2, $0, ORInWidth				#         {
	ADD		$9, $0, $0						#             cmd |= 0x0;
											#         }
	SLTI	$2, $3, 0x161					#         else if (disp.w <= 352)
	BNE		$2, $0, ORInWidth				#         {
	ADDI	$9, $0, 0x1						#             cmd |= 0x1;
											#         }
	SLTI	$2, $3, 0x191					#         else if (disp.w <= 400)
	BNE		$2, $0, ORInWidth				#         {
	ADDI	$9, $0, 0x40					#             cmd |= 0x40;
											#         }
	SLTI	$2, $3, 0x231					#         else if (disp.w <= 560)
	BNE		$2, $0, ORInWidth				#         {
	ADDI	$9, $0, 0x2						#             cmd |= 0x2;
											#         }
	ADDI	$9, $0, 0x3						#         else
											#         {
											#             cmd |= 0x3;
ORInWidth:									#         }
	OR		$4, $4, $9						#
											#         if (PalFlag)
	LBU		$8, PalFlag						#         {
	LH		$3, 0x6($16)					#             if (disp.h > 288)
	BNE		$8, $0, CheckPALHeight			#                 cmd |= 0x24;
	SLTI	$2, $3, 0x121					#         }
	SLTI	$2, $3, 0x101					#         else if (disp.h > 256)
CheckPALHeight:								#         {
	BNE		$2, $0, NotHighScreen			#             cmd |= 0x24;
	NOP										#         }
	ORI		$4, $4, 0x24					#
NotHighScreen:								#
	JAL		Gpu_WriteGPU1					#         Gpu_WriteGPU1(cmd);
	NOP										#     }
											#
DontUpdateDispEnvDisp:						#
	LA		$4, DispEnvDispX				#     memcpy(DispEnvDispX, dispEnv, sizeof(dispEnv));
	ADDU	$5, $16, $0						#
	JAL		memcpy							#
	ADDIU	$6, $0, 0x12					#
											#
	ADDU	$2, $16, $0						#     return(dispEnv);
	LW		$31, 0x20($29)					#
	LW		$18, 0x18($29)					#
	LW		$17, 0x14($29)					#
	LW		$16, 0x10($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x28					#
	.end	Gpu_PutDispEnv					# }

###############################################################################

	.ent	Gpu_ConvDrawEnvToGPUCmds		# void Gpu_ConvDrawEnvToGPUCmds(DR_ENV drEnv,
Gpu_ConvDrawEnvToGPUCmds:					#                               DRAWENV drawEnv)
	ADDIU	$29, $29, 0xFFC0				# {
	SW		$16, 0x30($29)					#
	ADDU	$16, $5, $0						#
	SW		$17, 0x34($29)					#
	ADDU	$17, $4, $0						#
	SW		$31, 0x38($29)					#
											#
	LH		$4, 0x0($16)					#     drEnv->clipAreaStartCmd =
	JAL		Gpu_CalcClipAreaStartCmd		#         Gpu_CalcClipAreaStartCmd(drawEnv->clip.x,
	LH		$5, 0x2($16)					#                                  drawEnv->clip.y);
	SW		$2, 0x4($17)					#
											#
	LHU		$4, 0x4($16)					#
	LHU		$2, 0x0($16)					#
	ADDIU	$4, $4, 0xFFFF					#
	ADDU	$4, $4, $2						#
	SLL		$4, $4, 0x10					#
	SRA		$4, $4, 0x10					#
	LHU		$5, 0x2($16)					#
	LHU		$2, 0x6($16)					#
	ADDIU	$5, $5, 0xFFFF					#
	ADDU	$5, $5, $2						#
	SLL		$5, $5, 0x10					#
	JAL		Gpu_CalcClipAreaEndCmd			#     drEnv->clipAreaEndCmd =
	SRA		$5, $5, 0x10					#         Gpu_CalcClipAreaEndCmd(drawEnv->clip.x + drawEnv->clip.w - 1,
	SW		$2, 0x8($17)					#                                drawEnv->clip.y + drawEnv->clip.h - 1);
											#
	LH		$4, 0x8($16)					#     drEnv->drawingOffsetCmd = 
	JAL		Gpu_CalcDrawingOffsetCmd		#         Gpu_CalcDrawingOffsetCmd(drawEnv->offset[0], drawEnv->offset[1]);
	LH		$5, 0xA($16)					#
	SW		$2, 0xC($17)					#
											#
	LBU		$4, 0x17($16)					#     drEnv->drawingModeCmd =
	LBU		$5, 0x16($16)					#         Gpu_CalcDrawingModeCmd(drawEnv->displayDraw,
	JAL		Gpu_CalcDrawingModeCmd			#                                drawEnv->dither,
	LHU		$6, 0x14($16)					#                                drawEnv->texPage);
	SW		$2, 0x10($17)					#
											#
	JAL		Gpu_CalcTexWindowCmd			#     drEnv->textureWindowCmd =
	ADDIU	$4, $16, 0xC					#         Gpu_CalcTexWindowCmd(&drawEnv->texWindow);
	SW		$2, 0x14($17)					#
											#
	LI		$2, 0xE6000000					#     drEnv->priorityCmd = 0xE6000000;
	SW		$2, 0x18($17)					#
											#
	LW		$31, 0x38($29)					#
	LW		$17, 0x34($29)					#
	LW		$16, 0x30($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x40					#
	.end	Gpu_ConvDrawEnvToGPUCmds		#

###############################################################################

	.ent	Gpu_CalcDrawingModeCmd			# PsxUInt32 Gpu_CalcDrawingModeCmd(PsxUInt8 dfe,
Gpu_CalcDrawingModeCmd:						#                                  PsxUInt8 dtd,
	LBU		$2, GPUType						#                                  PsxUInt16 tpage)
	NOP										# {
	SLTIU	$2, $2, 0x3						#     PsxUInt cmd = 0xE1000000;
	BEQ		$2, $0, Label80014F9C			#
	NOP										#
	BEQ		$5, $0, Label80014F8C			#     if (GPUType > 2)
	LUI		$3, 0xE100						#     {
	ORI		$3, $3, 0x800					#         if (dtd)
Label80014F8C:								#             cmd |= 0x800
	BEQ		$4, $0, Label80014FB4			#         if (dfe)
	ANDI	$2, $6, 0x27FF					#             cmd |= 0x1000;
	J		Label80014FB4					#         cmd |= (tpage & 0x27FF);
	ORI		$2, $2, 0x1000					#
											#     }
Label80014F9C:								#     else
	BEQ		$5, $0, Label80014FA8			#     {
	LUI		$3, 0xE100						#         if (dtd)
	ORI		$3, $3, 0x200					#             cmd |= 0x200;
Label80014FA8:								#         if (dfe)
	BEQ		$4, $0, Label80014FB4			#             cmd |= 0x400;
	ANDI	$2, $6, 0x9FF					#         cmd |= (tpage & 0x9FF);
	ORI		$2, $2, 0x400					#
											#
Label80014FB4:								#     }
	JR		$31								#
	OR		$2, $3, $2						#     return(cmd);
	.end	Gpu_CalcDrawingModeCmd			# }

###############################################################################

	.ent	Gpu_CalcClipAreaStartCmd		# PsxUInt32 Gpu_CalcClipAreaStartCmd(PsxUInt16 x,
Gpu_CalcClipAreaStartCmd:					#                                    PsxUInt16 y)
	SLL		$4, $4, 0x10					# {
	SRA		$4, $4, 0x10					#     PsxUInt32 cmd;
	BLTZ	$4, ClipAreaLeftClamped			#     if (x < 0)
	ADDU	$3, $0, $0						#         x = 0;
	ORI		$3, $0, 0x3FF					#     else if (x > 1023)
	SLT		$2, $3, $4						#         x = 1023;
	BNE		$2, $0, ClipAreaLeftClamped		#
	NOP										#
	ADDU	$3, $4, $0						#
ClipAreaLeftClamped:						#
	ADDU	$4, $3, $0						#
											#
	SLL		$5, $5, 0x10					#
	SRA		$5, $5, 0x10					#
	BLTZ	$5, ClipAreaTopClamped			#     if (y < 0)
	ADDU	$3, $0, $0						#         y = 0;
	LH		$3, VRAMHeight					#     else if (y > (VRAMHeight - 1))
	NOP										#         y = VRAMHeight-1;
	ADDIU	$3, $3, 0xFFFF					#
	SLT		$2, $3, $5						#
	BNE		$2, $0, ClipAreaTopClamped		#
	NOP										#
	ADDU	$3, $5, $0						#
ClipAreaTopClamped:							#
	ADDU	$5, $3, $0
											#
	LBU		$2, GPUType						#     if (GPUType > 2)
	NOP										#     {
	SLTIU	$2, $2, 0x3						#         cmd = ((y & 0x3FF) << 10) | x & 0x3FF;
	BNE		$2, $0, Label80015068			#     }
	ANDI	$3, $5, 0xFFF					#     else
	ANDI	$3, $5, 0x3FF					#     {
	SLL		$3, $3, 0xA						#         cmd = ((y & 0xFFF) << 12) | x & 0xFFF;
	J		Label80015070					#     }
	ANDI	$2, $4, 0x3FF					#
Label80015068:								#
	SLL		$3, $3, 0xC						#
	ANDI	$2, $4, 0xFFF					#
Label80015070:								#
	LI		$4, 0xE3000000					#     cmd |= 0xE3000000;
	OR		$2, $2, $4						#
	JR		$31								#
	OR		$2, $3, $2						#     return(cmd);
	.end	Gpu_CalcClipAreaStartCmd		# }

###############################################################################

	.ent	Gpu_CalcClipAreaEndCmd			# PsxUInt32 Gpu_CalcClipAreaEndCmd(PsxUInt16 x,
Gpu_CalcClipAreaEndCmd:						#                                  PsxUInt16 y)
	SLL		$4, $4, 0x10					#
	SRA		$4, $4, 0x10					#
	BLTZ	$4, ClipAreaRightClamped		#     if (x < 0)
	ADDU	$3, $0, $0						#         x = 0;
	ORI		$3, $0, 0x3FF					#     else if (x > 1023)
	SLT		$2, $3, $4						#         x = 1023;
	BNE		$2, $0, ClipAreaRightClamped	#
	NOP										#
	ADDU	$3, $4, $0						#
ClipAreaRightClamped:						#
	ADDU	$4, $3, $0						#
											#
	SLL		$5, $5, 0x10					#     if (y < 0)
	SRA		$5, $5, 0x10					#         y = 0;
	BLTZ	$5, ClipAreaBottomClamped		#     if (y > (VRAMHeight - 1))
	ADDU	$3, $0, $0						#         y = VRAMHeight - 1;
	LH		$3, VRAMHeight					#
	NOP										#
	ADDIU	$3, $3, 0xFFFF					#
	SLT		$2, $3, $5						#
	BEQ		$2, $0, ClipAreaBottomClamped	#
	NOP										#
	ADDU	$3, $5, $0						#
ClipAreaBottomClamped:						#
	ADDU	$5, $3, $0						#
											#     if (GPUType > 2)
	LBU		$2, GPUType						#     {
	NOP										#         cmd = ((y & 0x3FF) << 10) | x & 0x3FF;
	SLTIU	$2, $2, 0x3						#     }
	BNE		$2, $0, Label80015134			#     else
	ANDI	$3, $5, 0xFFF					#     {
	ANDI	$3, $5, 0x3FF					#         cmd = ((y & 0xFFF) << 12) | x & 0xFFF;
	SLL		$3, $3, 0xA						#     }
	J		Label8001513C					#
	ANDI	$2, $4, 0x3FF					#
Label80015134:								#
	SLL		$3, $3, 0xC						#
	ANDI	$2, $4, 0xFFF					#
Label8001513C:								#
	LI		$4, 0xE4000000					#     cmd |= 0xE4000000;
	OR		$2, $2, $4						#
	JR		$31								#
	OR		$2, $3, $2						#     return(cmd);
	.end	Gpu_CalcClipAreaEndCmd			# }

###############################################################################

	.ent	Gpu_CalcDrawingOffsetCmd		# PsxUInt32 Gpu_CalcDrawingOffsetCmd(PsxUInt16 x,
Gpu_CalcDrawingOffsetCmd:					#                                    PsxUInt16 y)
	LBU		$2, GPUType						# {
	NOP										#     PsxUInt32 cmd;
	SLTIU	$2, $2, 0x3						#
	BNE		$2, $0, Label80015180			#     if (GPUType > 2)
	ANDI	$3, $5, 0xFFF					#     {
	ANDI	$3, $5, 0x7FF					#         cmd = ((y & 0x7FF) << 11) | x & 0x7FF;
	SLL		$3, $3, 0xB						#     }
	J		Label80015188					#     else
	ANDI	$2, $4, 0x7FF					#     {
Label80015180:								#         cmd = ((y & 0xFFF) << 12) | x & 0xFFF;
	SLL		$3, $3, 0xC						#     }
	ANDI	$2, $4, 0xFFF					#
Label80015188:								#
	LI		$4, 0xE5000000					#     cmd |= 0xE5000000;
	OR		$2, $2, $4						#
	JR		$31								#
	OR		$2, $3, $2						#     return(cmd);
	.end	Gpu_CalcDrawingOffsetCmd		# }

###############################################################################

	.ent	Gpu_CalcTexWindowCmd			# PsxUInt32 Gpu_CalcTexWindowCmd(RECT *win)
Gpu_CalcTexWindowCmd:						# {
	LBU		$5, 0x0($4)						#     PsxUInt32 cmd;
	LBU		$2, 0x2($4)						#
	LH		$6, 0x4($4)						#
	LH		$3, 0x6($4)						#
											#
	SRL		$5, $5, 0x3						#     PsxUInt32 x = (win->x & 255) >> 3;
											#
	SRL		$2, $2, 0x3						#     PsxUInt32 y = (win->y & 255) >> 3;
											#
	SUBU	$6, $0, $6						#     PsxUInt32 w = (((0 - win->w) & 255) >> 3);
	ANDI	$6, $6, 0xFF					#
	SRA		$6, $6, 0x3						#
											#
	SUBU	$3, $0, $3						#     PsxUInt32 h = (((0 - win->h) & 255) >> 3);
	ANDI	$3, $3, 0xFF					#
	SRA		$3, $3, 0x3						#
											#
	SLL		$3, $3, 0x5						#
	SLL		$5, $5, 0xA						#
	SLL		$2, $2, 0xF						#
											#
	LI		$4, 0xE2000000					#     cmd = 0xE2000000 | y << 15
	OR		$5, $5, $4						#                      | x << 10
	OR		$2, $2, $5						#                      | h << 5
	OR		$2, $2, $3						#                      | w;
	JR		$31								#
	OR		$2, $2, $6						#     return(cmd)
	.end	Gpu_CalcTexWindowCmd			# }

###############################################################################

	.ent	Gpu_Fn8001521C					# PsxUInt16 Gpu_Fn8001521C(DISPENV *dispEnv)
Gpu_Fn8001521C:								# {
	LBU		$3, GPUType						#
	ADDIU	$2, $0, 0x2						#
	BNE		$3, $2, Label800152C4			#     if (GPUType == 2)
	LH		$2, 0x0($4)						#     {
											#         return((dispEnv->disp.x +
	NOP										#                 (dispEnv->disp.x < 0) ? 1 : 0) >> 1);
	SLL		$2, $2, 0x10					#
	SRA		$3, $2, 0x10					#     }
	SRL		$2, $2, 0x1F					#     else
	ADDU	$3, $3, $2						#     {
	SRA		$2, $3, 0x1						#         return(dispEnv->disp.x);
Label800152C4:								#     }
	JR		$31								#
	NOP										#
	.end	Gpu_Fn8001521C					# }

###############################################################################

	.ent	Gpu_DoDMAOTClear				# void Gpu_DoDMAOTClear(GsOT_TAG *org,
Gpu_DoDMAOTClear:							#                       PsxUInt32 length)
	ADDIU	$29, $29, 0xFFE0				# {
	SW		$31, 0x18($29)					#
											#
	LUI		$8, 0x1F80						#     *0x1F8010F0 |= 0x08000000;
	LW		$2, 0x10F0($8)					#
	LI		$3, 0x08000000					#
	OR		$2, $2, $3						#
	SW		$2, 0x10F0($8)					#
											#
	SW		$0, 0x10E8($8)					#     *0x1F8010E8 = 0;
											#
	SLL		$2, $5, 0x2						#
	ADDIU	$2, $2, 0xFFFC					#
	ADDU	$4, $4, $2						#
	SW		$4, 0x10E0($8)					#     *0x1F8010E0 = ((PsxUInt32)org + (length<<2) - 4);
											#
	SW		$5, 0x10E4($8)					#     *0x1F8010E4 = length;
											#
	LI		$3, 0x11000002					#     *0x1F8010E8 = 0x11000002;
	SW		$3, 0x10E8($8)					#
											#
	JAL		Gpu_SetWatchDogTimer			#     Gpu_SetWatchDogTimer();
	NOP										#
											#
WaitForOtClear:								#
	LUI		$2, 0x1F80						#     while (*0x1F8010E8 & 0x01000000)
	LW		$2, 0x10E8($2)					#     {
	LI		$3, 0x01000000					#
	AND		$2, $2, $3						#
	BEQ		$2, $0, ExitOtClear				#
	NOP										#
	JAL		Gpu_CheckWatchDogTimer			#         if (Gpu_CheckWatchDogTimer())
	NOP										#
	BEQ		$2, $0, WaitForOtClear			#         {
	NOP										#             return;
ExitOtClear:								#         }
	LW		$31, 0x18($29)					#     }
	ADDIU	$29, $29, 0x20					#
	JR		$31								#     return;
	NOP										#
	.end	Gpu_DoDMAOTClear				# }

###############################################################################

	.globl	GPU_ClearImage					# PsxUInt32 GPU_ClearImage(RECT *area,
	.ent	GPU_ClearImage					#                          PsxUInt32 rgb)
GPU_ClearImage:								# {
	ADDIU	$29, $29, 0xFFC0				#
	ADDU	$8, $4, $0						#
	ADDU	$9, $5, $0						#
	SW		$31, 0x38($29)					#
	SW		$17, 0x34($29)					#     if (area->w < 0)
	SW		$16, 0x30($29)					#         area->w = 0;
											#
	LH		$4, 0x4($8)						#
	NOP										#     if (area->w > 1023)
	BLTZ	$4, Label8001541C				#         area->w = 1023;
	ADDU	$3, $0, $0						#
	OR		$3, $0, 0x3FF					#
	SLT		$2, $3, $4						#
	BNE		$2, $0, Label8001541C			#
	NOP										#
	ADDU	$3, $4, $0						#
Label8001541C:								#
	SH		$3, 0x4($8)						#
											#
	LH		$5, 0x6($8)						#     if (area->h < 0)
	NOP										#         area->h = 0;
	BLTZ	$5, Label80015458				#
	ADDU	$3, $0, $0						#
	LH		$3, VRAMHeight					#     if (area->h > (VRAMHeight - 1))
	NOP										#         area->h = VRAMHeight - 1;
	ADDU	$3, $3, 0xFFFF					#
	SLT		$2, $3, $5						#
	BNE		$2, $0, Label80015458			#
	NOP										#
	ADDU	$3, $5, $0						#
Label80015458:								#
	SH		$3, 0x6($8)						#
											#
	LHU		$2, 0x0($8)						#     if ((area->x & 0x3F) ||
	LHU		$3, 0x4($8)						#         (area->w & 0x3F))
	NOP										#     {
	OR		$2, $2, $3						#         /* Use free style tile
	ANDI	$2, $2, 0x3F					#          * for non aligned clear
	BEQ		$2, $0, UseBlockFill			#          */
	NOP										#
											#         /* Link onto second OT element */
	LI		$5, 0xFFFFFF					#         CommandBlock1Header = 0x08000000 |
	LA		$6, CommandBlock2Header			#                               (&CommandBlock2Header & 0x00FFFFFF);
	AND		$2, $6, $5						#
	LI		$3, 0x08000000					#
	OR		$2, $2, $3						#
	SW		$2, CommandBlock1Header			#
											#         /* Clip start */
	LI		$16, 0xE3000000					#         CommandBlock1Word1 = 0xE3000000;
	SW		$16, CommandBlock1Word1			#
											#         /* Clip end */
	LI		$4, 0xE4FFFFFF					#         CommandBlock1Word2 = 0xE4FFFFFF;
	SW		$4, CommandBlock1Word2			#
											#         /* Drawing offset */
	LI		$17, 0xE5000000					#         CommandBlock1Word3 = 0xE5000000;
	SW		$17, CommandBlock1Word3			#
											#         /* Priority? */
	LI		$2, 0xE6000000					#         CommandBlock1Word4 = 0xE6000000;
	SW		$2, CommandBlock1Word4			#
											#         /* Draw mode */
	LUI		$2, 0x1F80						#         CommandBlock1Word5 = 0xE1000000 |
	LW		$4, 0x1814($2)					#                              (rgb < 0) 0x400 : 0 |
	SRL		$2, $9, 0x1F					#                              (*0x1F801814 & 0x7FF);
	SLL		$2, $2, 0xA						#
	LI		$3, 0xE1000000					#
	OR		$2, $2, $3						#
	ANDI	$4, $4, 0x7FF					#
	OR		$4, $4, $2						#
	SW		$4, CommandBlock1Word5			#
											#         /* Color and command */
	AND		$5, $9, $5						#         CommandBlock1Word6 = 0x60000000 |
	LI		$3, 0x60000000					#                              (rgb & 0xFFFFFF);
	OR		$5, $5, $3						#
	SW		$5, CommandBlock1Word6			#
											#         /* X and Y */
	LW		$3, 0x0($8)						#         CommandBlock1Word7 = *(PsxUInt32 *)&rect->x;
	LW		$4, 0x4($8)						#
	SW		$3, CommandBlock1Word7			#         /* W and H */
	SW		$4, CommandBlock1Word8			#         CommandBlock1Word8 = *(PsxUInt32 *)&rect->w;
											#
	LI		$7, 0x03FFFFFF					#         /* The second block restores state */
	SW		$7, CommandBlock2Header			#         CommandBlock2Header = 0x03FFFFFF
											#
	JAL		Gpu_GetCmdVal					#         /* Restore clip start */
	ADDIU	$4, $0, 0x3						#         CommandBlock2Word1 = 0xE3000000 | Gpu_GetCmdVal(3);
	OR		$2, $2, $16						#
	SW		$2, CommandBlock2Word1			#
											#         /* Restore clip end */
	JAL		Gpu_GetCmdVal					#         CommandBlock2Word2 = 0xE4000000 | Gpu_GetCmdVal(4);
	ADDIU	$4, $0, 0x4						#
	LI		$3, 0xE4000000					#
	OR		$2, $2, $3						#
	SW		$2, CommandBlock2Word2			#
											#         /* Restore drawing offset */
	JAL		Gpu_GetCmdVal					#         CommandBlock2Word3 = 0xE5000000 | |Gpu_GetCmdVal(5);
	ADDIU	$4, $0, 0x5						#
	LI		$3, 0xE5000000					#
	OR		$2, $2, $3						#
	SW		$2, CommandBlock2Word3			#
											#     }
	J		ShipTheClearCmd					#     else
	NOP										#     {
UseBlockFill:								#         /* Length of commands, and terminator */
	LI		$2, 0x05FFFFFF					#         CommandBlock1Header = 0x05FFFFFF;
	SW		$2, CommandBlock1Header			#
											#         /* Priority? */
	LI		$2, 0xE6000000					#         CommandBlock1Word1 = 0xE6000000;
	SW		$2, CommandBlock1Word1			#
											#         /* Draw mode */
	LUI		$2, 0x1F80						#         CommandBlock1Word2 = 0xE1000000 |
	LW		$4, 0x1814($2)					#                              (rgb < 0) ? 0x400 : 0 |
	SRL		$2, $9, 0x1F					#                              (*0x1F801814 & 0x7FF);
	SLL		$2, $2, 0xA						#
	LI		$3, 0xE1000000					#
	OR		$2, $2, $3						#
	ANDI	$4, $4, 0x7FF					#
	OR		$4, $4, $2						#
	SW		$4, CommandBlock1Word2			#
											#         /* Command header and color */
	LI		$3, 0xFFFFFF					#         CommandBlock1Word3 = 0x02000000 | (rgb & 0xFFFFFF);
	AND		$3, $9, $3						#
	LI		$5, 0x02000000					#
	OR		$3, $3, $5						#
	SW		$3, CommandBlock1Word3			#
											#         /* X and Y */
	LW		$3, 0x0($8)						#         CommandBlock1Word4 = *(PsxUInt32 *)&rect->x;
	LW		$4, 0x4($8)						#
	SW		$3, CommandBlock1Word4			#         /* W and H */
	SW		$4, CommandBlock1Word5			#         CommandBlock1Word5 = *(PsxUInt32 *)&rect->w;
											#     }
ShipTheClearCmd:							#
	LA		$4, CommandBlock1Header			#
	JAL		Gpu_DoDMATransfer				#     Gpu_DoDMATransfer(&CommandBlock1Header);
	NOP										#
											#
	ADDU	$2, $0, $0						#     return (0);
	LW		$31, 0x38($29)					#
	LW		$17, 0x34($29)					#
	LW		$16, 0x30($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x40					#
	.end	GPU_ClearImage					# }

###############################################################################

	.ent	Gpu_LoadImageSection			# void Gpu_LoadImageSection(RECT *rect, PsxUInt32 *data)
Gpu_LoadImageSection:						# {
	ADDIU	$29, $29, 0xFFB0				#     PsxInt32 numPixels;
	SW		$31, 0x48($29)					#     PsxInt32 extraWords;
	SW		$20, 0x40($29)					#     PsxInt32 dmaBlocks;
	SW		$19, 0x3C($29)					#
	SW		$18, 0x38($29)					#
	SW		$17, 0x34($29)					#
	SW		$16, 0x30($29)					#
	ADDU	$17, $4, $0						#
	ADDU	$18, $5, $0						#
	JAL		Gpu_SetWatchDogTimer			#     Gpu_SetWatchDogTimer();
	NOP										#
											#     /* Clamp the width */
	LH		$5, 0x4($17)					#     if (rect->w < 0)
	NOP										#     {
	BLTZ	$5, DestRectXOK					#         rect->w = 0;
	ADDU	$3, $0, $0						#     }
											#     else if (rect->w > 1024)
	OR		$3, $0, 0x400					#     {
	SLT		$2, $3, $5						#         rect->w = 1024;
	BNE		$2, $0, DestRectXOK				#     }
	NOP										#
	ADDU	$3, $5, $0						#
DestRectXOK:								#
	SH		$3, 0x4($17)					#
											#     /* Clamp the height */
	LH		$5, 0x6($17)					#     if (rect->h < 0)
	NOP										#     {
	BLTZ	$5, DestRectYOK					#         rect->h = 0;
	ADDU	$4, $0, $0						#     }
											#     else if (rect->h > VRAMHeight)
	LH		$4, VRAMHeight					#     {
	NOP										#         rect->h = VRAMHeight;
	SLT		$2, $4, $5						#     }
	BNE		$2, $0, DestRectYOK				#
	NOP										#
	ADDU	$4, $5, $0						#
DestRectYOK:								#
	SH		$4, 0x6($17)					#
											#
	MULT	$3, $4							#     numPixels = (rect->w * rect->h);
	NOP										#
	MFLO	$3								#
											#
	SRA		$4, $3, 0x1						#     if ((numPixels / 2) < 1)
	BLEZ	$4, ExitGpu_LoadImageSection	#     {
	ADDIU	$2, $0, 0xFFFF					#         return(-1);
											#     }
	SRA		$20, $3, 0x5					#
	SLL		$2, $20, 0x4					#     dmaBlocks = numPixels / 32;
	SUBU	$16, $4, $2						#     extraWords = (numPixels / 2) - (dmaBlocks * 16);
	LUI		$2, 0x1F80						#
WaitForReadyForImage:						#     while ((*0x1F801814 & 0x04000000) == 0)
	LW		$2, 0x1814($2)					#     {
	LI		$19, 0x04000000					#
	AND		$2, $2, $19						#
	BNE		$2, $0, ReadyForImage			#
	NOP										#
	JAL		Gpu_CheckWatchDogTimer			#         if (Gpu_CheckWatchDogTimer())
	NOP										#         {
	BNE		$2, $0, ExitGpu_LoadImageSection#             return(-1);
	ADDIU	$2, $0, 0xFFFF					#         }
	J		WaitForReadyForImage			#
	LUI		$2, 0x1F80						#     }
											#
ReadyForImage:								#     /* Accept some commands using I/O */
	LUI		$3, 0x1F80						#
											#
	LI		$2, 0x4000000					#     *0x1F801814 = 0x04000000;
	SW		$2, 0x1814($3)					#
											#     /* Flush cache */
	LI		$2, 0x1000000					#     *0x1F801810 = 0x01000000;
	SW		$2, 0x1810($3)					#
											#     /* We are uploading */
	LI		$4, 0xA0000000					#     *0x1F801810 = 0xA0000000;
	SW		$4, 0x1810($3)					#
											#     /* Send destination X and Y */
	LW		$2, 0x0($17)					#     *0x1F801810 = (rect->y << 16) | rect->x;
	LW		$4, 0x4($17)					#
	SW		$2, 0x1810($3)					#     /* Send destination W and H */
	SW		$4, 0x1810($3)					#     *0x1F801810 = (rect->h << 16) | rect->w;
											#
DoExtraWords:								#     while (extraWords--)
	BEQ		$16, $0, DoneExtraWords			#     {
	ADDIU	$16, $16, 0xFFFF				#         *0x1F801810 = *data++;
	LW		$2, 0x0($18)					#     }
	ADDIU	$18, $18, 0x4					#
	J		DoExtraWords					#
	SW		$2, 0x1810($3)					#
											#
DoneExtraWords:								#     if (dmaBlocks)
	BEQ		$20, $0, NoDMATransfer			#     {
											#         /* Set up for DMA transfer for the rest */
	LI		$2, 0x4000002					#         *0x1F801814 = 0x4000002;
	SW		$2, 0x1814($3)					#
											#         /* Set the address */
	SW		$18, 0x10A0($3)					#         *GPUDMA_MEMADDER = param2;
											#
	SLL		$2, $20, 0x10					#         /* Set the length of the transfer */
	ORI		$2, $2, 0x10					#         *GPUDMA_BCR = (dmaBlocks << 16) | 0x10;
	SW		$2, 0x10A4($3)					#
											#         /* Do the transfer */
	LI		$4, 0x01000201					#         *GPUDMA_CHCR = 0x01000201;
	SW		$4, 0x10A8($3)					#
											#     }
NoDMATransfer:								#
	ADDU	$2, $0, $0						#     return(0);
ExitGpu_LoadImageSection:					#
	LW		$31, 0x48($29)					#
	LW		$20, 0x40($29)					#
	LW		$19, 0x3C($29)					#
	LW		$18, 0x38($29)					#
	LW		$17, 0x34($29)					#
	LW		$16, 0x30($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x50					#
	.end	Gpu_LoadImageSection			# }

###############################################################################

	.ent	Gpu_WriteGPU1					# void Gpu_WriteGPU1(PsxUInt32 cmd)
Gpu_WriteGPU1:								# {
	LUI		$2, 0x1F80						#
	SW		$4, 0x1814($2)					#     *0x1F801814 = cmd;
	SRL		$2, $4, 0x18					#
	LA		$3, StateCache					#
	ADDU	$3, $3, $2						#
	JR		$31								#
	SB		$4, 0x0($3)						#     StateCache[cmd >> 24] = cmd & 0xFF;
	.end	Gpu_WriteGPU1					# }

###############################################################################

	.ent	Gpu_DoDMATransfer				# void Gpu_DoDMATransfer(PsxUInt32 addr)
Gpu_DoDMATransfer:							# {
	LUI		$2, 0x1F80						#
											#
	LI		$3, 0x4000002					#
	SW		$3, 0x1814($2)					#     *0x1F801814 = 0x4000002;
											#
	SW		$4, 0x10A0($2)					#     *0x1F8010A0 = addr;
	SW		$0, 0x10A4($2)					#     *0x1F8010A4 = 0;
	LI		$3, 0x1000401					#
											#
	JR		$31								#
	SW		$3, 0x10A8($2)					#     *0x1F8010A8 = 0x1000401;
	.end	Gpu_DoDMATransfer				# }

###############################################################################

	.ent	Gpu_GetCmdVal					# PsxUInt32 Gpu_GetCmdVal(PsxUInt32 param)
Gpu_GetCmdVal:								# {
	LI		$2, 0x10000000					#     *0x1F801814 = 0x10000000 | param1;
	LUI		$3, 0x1F80						#
	OR		$4, $4, $2						#
	SW		$4, 0x1814($3)					#
											#
	LW		$3, 0x1810($3)					#     return (*0x1F801810 & 0xFFFFFF);
	LI		$2, 0xFFFFFF					#
	JR		$31								#
	AND		$2, $2, $3						#
	.end	Gpu_GetCmdVal					# }

###############################################################################

	.ent	Gpu_EnqueOp						# PsxInt32 Gpu_EnqueOp(FnPoint fn,
Gpu_EnqueOp:								#                      PsxUInt32 *addr,
	ADDIU	$29, $29, 0xFFD8				#                      copyBytes, param2)
	SW		$19, 0x1C($29)					# {
	SW		$16, 0x10($29)					#
	SW		$17, 0x14($29)					#
	SW		$18, 0x18($29)					#
	SW		$31, 0x20($29)					#
											#
	ADDU	$19, $4, $0						#
	ADDU	$16, $5, $0						#
	ADDU	$17, $6, $0						#
	ADDU	$18, $7, $0						#
											#
	JAL		Gpu_SetWatchDogTimer			#     Gpu_SetWatchDogTimer();
	NOP										#
	J		CheckQueForFull					#
	NOP										#
QueIsFull:									#     while ((QueTail+1) & 0x3F == QueHead)
	JAL		Gpu_CheckWatchDogTimer			#     {
	NOP										#         if (Gpu_CheckWatchDogTimer())
	BNE		$2, $0, ExitGpu_EnqueOp			#         {
	ADDIU	$2, $0, 0xFFFF					#             return(-1);
	JAL		Gpu_ProcessQuedOp				#         }
	NOP										#         Gpu_ProcessQuedOp();
CheckQueForFull:							#     }
	LW		$2, QueTail						#
	LW		$3, QueHead						#
	ADDIU	$2, $2, 0x1						#
	ANDI	$2, $2, 0x3F					#
	BEQ		$2, $3, QueIsFull				#
	NOP										#
											#
	JAL		INT_SetMask						#     TmpIntMaskStore3 = INT_SetMask(0);
	ADDU	$4, $0, $0						#
	SW		$2, TmpIntMaskStore3			#
											#
#	J		QueOpForLater
#	NOP

	LW		$3, QueTail						#     /* If the queue is empty and DMA idle, 
	LW		$2, QueHead						#      * then dispatch it directly.
	NOP										#      */
	BNE		$3, $2, QueOpForLater			#     if ((QueTail == QueHead) &&
	LUI		$2, 0x1F80						#          ((*0x1F8010A8 & 0x01000000) == 0))
	LW		$2, 0x10A8($2)					#     {
	LI		$3, 0x01000000					#
	AND		$2, $2, $3						#
	BNE		$2, $0, QueOpForLater			#
DispatchOpImmediately:						#
											#         /* Wait for the GPU to become idle */
	LUI		$3, 0x1F80						#         while ((*0x1F801814 & 0x4000000) == 0)
	LI		$5, 0x4000000					#             ;
GPUNotIdleYet:								#
	LW		$2, 0x1814($3)					#
	NOP										#
	AND		$2, $2, $5						#
	BEQ		$2, $0, GPUNotIdleYet			#
											#         /* Dispatch it */
	ADDU	$4, $16, $0						#         fn(addr, param2);
	JALR	$31, $19						#
	ADDU	$5, $18, $0						#
											#
	LW		$4, TmpIntMaskStore3			#
	JAL		INT_SetMask						#         INT_SetMask(TmpIntMaskStore3);
	NOP										#
											#
	J		ExitGpu_EnqueOp					#         return(0);
	ADDU	$2, $0, $0						#     }
QueOpForLater:								#
	LA		$5, Gpu_ProcessQuedOp			#     INT_SetDMACallback(2, Gpu_ProcessQuedOp);
	JAL		INT_SetDMACallback				#
	ADDIU	$4, $0, 0x2						#
											#
	LW		$3, QueTail						#     PsxUInt32		*queEl = &QueBuffer[QueTail * 64];
	LA		$7, QueBuffer					#
	SLL		$2, $3, 0x6						#
	ADDU	$7, $7, $2						#
											#
	BEQ		$17, $0, DontCopyOp				#     if (copyBytes != 0)
											#     {
	ADDIU	$4, $7, 0xC						#         PsxUInt32 *destBuf = &queEl[3];
											#
	ADDIU	$2, $17, 0x3					#         PsxUInt32 numWords = (copyBytes + 3) >> 2;
	SRA		$2, $2, 0x2						#
	ADDU	$6, $16, $0						#         PsxUInt32 *srceBuf = addr;
CopyOp:										#
	BEQ		$2, $0, DoneCopyOp				#         while (numWords--)
	ADDIU	$2, $2, 0xFFFF					#         {
	LW		$5, 0x0($6)						#             *destBuf++ = *srceBuf++;
	ADDIU	$6, $6, 0x4						#         }
	SW		$5, 0x0($4)						#
	J		CopyOp							#
	ADDIU	$4, $4, 0x4						#
											#
DoneCopyOp:									#
	ADDIU	$2, $7, 0xC						#         /* Fill in address of dest buffer */
											#         queEl[1] = &queEl[3];
	SW		$2, 0x4($7)						#
	J		Label80015E40					#     }
	NOP										#     else
DontCopyOp:									#     {
	SW		$16, 0x4($7)					#         queEl[1] = addr;
Label80015E40:								#     }
	SW		$18, 0x8($7)					#     queEl[2] = param2;
	SW		$19, 0x0($7)					#     queEl[0] = fn;
											#
	LW		$2, QueTail						#     QueTail = (QueTail + 1) & 0x3F
	LW		$4, TmpIntMaskStore3			#
	ADDIU	$2, $2, 0x1						#
	ANDI	$2, $2, 0x3F					#
	SW		$2, QueTail						#
	JAL		INT_SetMask						#     INT_SetMask(TmpIntMaskStore3);
	NOP										#
											#
	JAL		Gpu_ProcessQuedOp				#     Gpu_ProcessQuedOp();
	NOP										#
	ADDU	$2, $0, $0						#     return (0);
ExitGpu_EnqueOp:							#
	LW		$31, 0x20($29)					#
	LW		$19, 0x1C($29)					#
	LW		$18, 0x18($29)					#
	LW		$17, 0x14($29)					#
	LW		$16, 0x10($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x28					#
	.end	Gpu_EnqueOp						# }

###############################################################################

	.ent	Gpu_ProcessQuedOp				# void Gpu_ProcessQuedOp(void)
Gpu_ProcessQuedOp:							# {
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x14($29)					#
											#
	LUI		$2, 0x1F80						#
	LW		$2, 0x10A8($2)					#     if ((*0x1F8010A8 & 0x01000000) == 0)
	LI		$3, 0x01000000					#     {
	AND		$2, $2, $3						#
	BNE		$2, $0, ExitProcessQuadGPUOp	#
	NOP										#
											#
	JAL		INT_SetMask						#         TmpIntMaskStore1 = INT_SetMask(0);
	ADDU	$4, $0, $0						#
	SW		$2, TmpIntMaskStore1			#
CanWeShipAnOp:								#
											#         /* Must be something in the que */
	LW		$4, QueTail						#         while ((QueHead != QueTail) &&
	LW		$3, QueHead						#             ((*0x1F8010A8 & 0x01000000)) == 0)
	NOP										#         {
	BEQ		$4, $3, CantShipAnOp			#
	LUI		$2, 0x1F80						#
	LW		$2, 0x10A8($2)					#
	LI		$3, 0x01000000					#
	AND		$2, $2, $3						#
	BNE		$2, $0, CantShipAnOp			#
											#             /* Will this empty the queue */
	LW		$2, QueHead						#             if (((QueHead + 1) & 0x3F) == QueTail)
	LW		$3, QueTail						#             {
	ADDIU	$2, $2, 0x1						#
	ANDI	$2, $2, 0x3F					#                 /* We can turn off DMA int */
	LA		$5, Gpu_ProcessQuedOp			#                 INT_SetDMACallback(2, 0);
	BNE		$2, $3, DontDisableDMACb		#             }
	NOP										#             else
	ADDU	$5, $0, $0						#             {
DontDisableDMACb:							#                 /* Give it a kick */
	JAL		INT_SetDMACallback				#                 INT_SetDMACallback(2, Gpu_ProcessQuedOp);
	ADDIU	$4, $0, 0x2						#             }
											#             /* Wait for GPU to become idle */
	LUI		$3, 0x1F80						#             while((*0x1F801814 & 0x04000000) == 0)
Label80015FCC:								#                 ;
	LW		$2, 0x1814($3)					#
	LUI		$4, 0x0400						#
	AND		$2, $2, $4						#
	BEQ		$2, $0, Label80015FCC			#
											#
Label80015FE0:								#
	LW		$3, QueHead						#             PsxUInt32 *queEl = &QueBuffer[QueHead*64];
	LA		$6, QueBuffer					#
	SLL		$3, $3, 0x6						#
	ADDU	$6, $6, $3						#
											#
	LW		$2, 0x0($6)						#
	LW		$4, 0x4($6)						#
	JALR	$31, $2							#             queEl[0](queEl[1], queEl[2]);
	LW		$5, 0x8($6)						#
											#
	LW		$2, QueHead						#             QueHead = (QueHead + 1) & 0x3F;
	NOP										#
	ADDIU	$2, $2, 0x1						#
	ANDI	$2, $2, 0x3F					#
	SW		$2, QueHead						#
											#
	J		CanWeShipAnOp					#
	NOP										#         }
											#
CantShipAnOp:								#
	LW		$4, TmpIntMaskStore1			#         INT_SetMask(TmpIntMaskStore1);
	JAL		INT_SetMask						#
	NOP										#
ExitProcessQuadGPUOp:						#    }
	LW		$31, 0x14($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	Gpu_ProcessQuedOp				# }

###############################################################################

	.ent	Gpu_Fn800161E0					# PsxUInt32 Gpu_Fn800161E0(PsxUInt32 param)
Gpu_Fn800161E0:								# {
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x14($29)					#
	SW		$16, 0x10($29)					#
	ADDU	$16, $4, $0						#
											#
	JAL		INT_SetMask						#     TmpIntMaskStore2 = INT_SetMask(0);
	ADDU	$4, $0, $0						#
	SW		$2, TmpIntMaskStore2			#
											#
	SW		$0, QueHead						#     QueHead = 0;
	SW		$0, QueTail						#     QueTail = 0;
											#
	ANDI	$4, $16, 0x7					#
											#
	ADDIU	$2, $0, 0x1						#
	BEQ		$4, $2, Label800162B8			#     {
											#
	ADDIU	$2, $0, 0x3						#
	BEQ		$4, $2, Label800162B8			#
											#
	ADDIU	$2, $0, 0x0						#
	BEQ		$4, $2, Label80016254			#
											#
	ADDIU	$2, $0, 0x5						#
	BNE		$4, $2, Label80016304			#
											#     if ((param&7) == 0 || (param&7) == 5)
Label80016254:								#     {
	LUI		$3, 0x1F80						#
	ADDIU	$2, $0, 0x401					#
	SW		$2, 0x10A8($3)					#         *0x1F8010A8 = 0x401;
											#
	LW		$2, 0x10F0($3)					#         *0x1F8010F0 |=  0x800;
	NOP										#
	ORI		$2, $2, 0x800					#
	SW		$2, 0x10F0($3)					#
											#
	SW		$0, 0x1814($3)					#         *0x1F801814 = 0x0;
											#
	LA		$4, StateCache					#
	ADDU	$5, $0, $0						#         /* Clear the state cache */
	JAL		memset							#         memset(&StateCache, 0, 256);
	ADDIU	$6, $0, 256						#
											#
	LA		$4, QueBuffer					#
	ADDU	$5, $0, $0						#         /* Clear the QueBuffer */
	JAL		memset							#         memset(&QueBuffer, 0, 64*64);
	ADDIU	$6, $0, 64*64					#
											#
	J		Label80016304					#     }
	NOP										#     else if ((param&7) == 1 || (param&7) == 3)
Label800162B8:								#     {
	LUI		$3, 0x1F80						#
	ADDIU	$2, $0, 0x401					#
	SW		$2, 0x10A8($3)					#         *0x1F8010A8 = 0x401;
											#
	LW		$2, 0x10F0($3)					#
	NOP										#
	ORI		$2, $2, 0x800					#
	SW		$2, 0x0($3)						#         *0x1F801080 |= 0x800;
											#
	LI		$2, 0x2000000					#
	SW		$2, 0x1814($3)					#         *0x1F801814 = 0x2000000;
											#
	LI		$2, 0x1000000					#
	SW		$2, 0x1814($3)					#
											#         *0x1F801814 = 0x1000000;     }
Label80016304:								#     }
	LW		$4, TmpIntMaskStore2			#
	JAL		INT_SetMask						#     INT_SetMask(TmpIntMaskStore2);
	NOP										#
											#
	ANDI	$2, $16, 0x7					#     if (param&7)
	BNE		$2, $0, ExitGpu_Fn800161E0		#     {
	ADDU	$2, $0, $0						#         return(0);
	JAL		Gpu_GetType						#     }
	ADDU	$4, $16, $0						#     else
ExitGpu_Fn800161E0:							#     {
	LW		$31, 0x14($29)					#         return(Gpu_GetType(param));
	LW		$16, 0x10($29)					#     }
	JR		$31								#
	ADDIU	$29, $29, 0x18					#
	.end	Gpu_Fn800161E0					# }

###############################################################################

	.globl	GPU_DrawSync					# PsxInt32 GPU_DrawSync(void)
	.ent	GPU_DrawSync					# {
GPU_DrawSync:								#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x14($29)					#
	JAL		Gpu_SetWatchDogTimer			#     /* Wait for it all to cease */
	NOP										#     Gpu_SetWatchDogTimer()
											#
IsQueEmptyYet:								#     /* Wait for que to empty */
	LW		$3, QueTail						#     while (QueTail != QueHead)
	LW		$2, QueHead						#     {
	NOP										#         Gpu_ProcessQuedOp();
	BEQ		$3, $2, QueIsEmptyNow			#         if (Gpu_CheckWatchDogTimer())
	NOP										#         {
	JAL		Gpu_ProcessQuedOp				#             return(-1);
	NOP										#         }
	JAL		Gpu_CheckWatchDogTimer			#     }
	NOP										#
	BNE		$2, $0, ExitDrawSync			#
	ADDIU	$2, $0, 0xFFFF					#
	J		IsQueEmptyYet					#
	NOP										#
											#
GPUNotAllFinishedYet:						#
	JAL		Gpu_CheckWatchDogTimer			#
	NOP										#
	BNE		$2, $0, ExitDrawSync			#
	ADDIU	$2, $0, 0xFFFF					#     /* Wait for DMA to complete
QueIsEmptyNow:								#      * and GPU to be idle
	LUI		$4, 0x1F80						#      */
	LW		$2, 0x10A8($4)					#
	LI		$3, 0x01000000					#     while ((*0x1F8010A8 & 0x01000000) ||
	AND		$2, $2, $3						#            (*0x1F801814 & 0x04000000))
	BNE		$2, $0, GPUNotAllFinishedYet	#     {
	NOP										#         if (Gpu_CheckWatchDogTimer())
											#         {
	LW		$2, 0x1814($4)					#             return(-1);
	LI		$3, 0x04000000					#         }
	AND		$2, $2, $3						#     }
	BEQ		$2, $0, GPUNotAllFinishedYet	#
	ADDU	$2, $0, $0						#     return (0);
											#
ExitDrawSync:								#
	LW		$31, 0x14($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_DrawSync					# }

###############################################################################

	.ent	Gpu_SetWatchDogTimer			# void Gpu_SetWatchDogTimer(void)
Gpu_SetWatchDogTimer:						# {
	LW		$2, VSyncCount					#     WatchDogVSyncCount = VSyncCount + 240;
	SW		$0, WatchDogTimeout				#     WatchDogTimeout = 0;
	ADDIU	$2, $2, 0xF0					#
	SW		$2, WatchDogVSyncCount			#
											#
	JR		$31								#
	NOP										#
	.end	Gpu_SetWatchDogTimer			# }

###############################################################################

	.ent	Gpu_CheckWatchDogTimer			# PsxUInt32 Gpu_CheckWatchDogTimer(void)
Gpu_CheckWatchDogTimer:						# {
	ADDIU	$29, $29, 0xFFE0				#
	SW		$31, 0x18($29)					#
											#
	LW		$2, VSyncCount					#
	LW		$3, WatchDogVSyncCount			#     if (VSyncCount < WatchDogVSyncCount)
	NOP										#     {
	SLT		$3, $3, $2						#         if (++WatchDogTimeout < 0x000F0000)
	BNE		$3, $0, WatchDogHasTimedOut		#         {
	NOP										#             return(0);
	LW		$3, WatchDogTimeout				#         }
	NOP										#     }
	ADDIU	$2, $3, 0x1						#
	SW		$2, WatchDogTimeout				#
	LI		$2, 0x000F0000					#
	SLT		$2, $2, $3						#
	BEQ		$2, $0, ExitGpu_CheckWatchDogTimer	#
	ADDU	$2, $0, $0						#
											#
WatchDogHasTimedOut:						#
	JAL		INT_SetMask						#     /* Do some reset stuff */
	ADDU	$4, $0, $0						#     TmpIntMaskStore2 = INT_SetMask(0);
	SW		$2, TmpIntMaskStore2			#
											#     /* Reset que */
	SW		$0, QueHead						#     QueHead = 0;
	SW		$0, QueTail						#     QueTail = 0;
											#
	LUI		$3, 0x1F80						#     *0x1F8010A8 = 0x00000401;
	LI		$2, 0x00000401					#
	SW		$2, 0x10A8($3)					#
											#
	LW		$2, 0x10F0($3)					#     *0x1F8010F0 |= 0x800;
	NOP										#
	ORI		$2, $2, 0x800					#
	SW		$2, 0x10F0($3)					#
											#
	LI		$2, 0x02000000					#     *0x1F801814 = 0x02000000;
	SW		$2, 0x1814($3)					#
											#
	LI		$2, 0x01000000					#     *0x1F801814 = 0x01000000;
	SW		$2, 0x1814($3)					#
											#
	LW		$4, TmpIntMaskStore2			#     INT_SetMask(TmpIntMaskStore2);
	JAL		INT_SetMask						#
	NOP										#
											#
	ADDIU	$2, $0, 0xFFFF					#     return (-1);
ExitGpu_CheckWatchDogTimer:					#
	LW		$31, 0x18($29)					#
	ADDIU	$29, $29, 0x20					#
	JR		$31								#
	NOP										#
	.end	Gpu_CheckWatchDogTimer			# }

###############################################################################

	.ent	Gpu_GetType						# PsxUInt32 Gpu_GetType(PsxUInt32 param)
Gpu_GetType:								# {
	LUI		$8, 0x1F80						#
											#
	LI		$3, 0x10000007					#     *0x1F801814 = 0x10000007;
	SW		$3, 0x1814($8)					#
											#
	LW		$2, 0x1810($8)					#
	LI		$3, 0xFFFFFF					#
	AND		$2, $2, $3						#
	ADDIU	$3, $0, 0x2						#     if ((*0x1F801810 & 0xFFFFFF) == 2)
	BNE		$2, $3, GPUTypeNot2				#     {
											#         if (!(param & 8))
	ANDI	$2, $4, 0x8						#         {
	BEQ		$2, $0, ExitGpu_GetType			#             return(3);
	ADDIU	$2, $0, 0x3						#         }
											#
	LI		$3, 0x9000001					#
	SW		$3, 0x1814($8)					#         *0x1F801814 = 0x09000001;
											#
	J		ExitGpu_GetType					#         return(4);
	ADDIU	$2, $0, 0x4						#     }
											#
GPUTypeNot2:								#
	LW		$2, 0x1814($8)					#
	LI		$3, 0xE1001000					#
	ANDI	$2, $2, 0x3FFF					#     *0x1F801810 = 0xE1001000 | (*0x1F801814 & 0x3FFF);
	OR		$2, $2, $3						#
	SW		$2, 0x1810($8)					#
											#
	LW		$2, 0x1810($8)					#     PsxUInt32 dummy = *0x1F801810;
	LW		$2, 0x1814($8)					#     if (*0x1F801814 & 0x1000)
	NOP										#     {
	ANDI	$2, $2, 0x1000					#         if (param & 8)
	BEQ		$2, $0, ExitGpu_GetType			#         {
	ADDU	$2, $0, $0						#             *0x1F801814 = 0x20000504;
											#             return (2);
	ANDI	$2, $4, 0x8						#         }
	BEQ		$2, $0, ExitGpu_GetType			#         return(1);
	ADDIU	$2, $0, 0x1						#     }
											#
	LI		$2, 0x20000504					#
	SW		$2, 0x1814($8)					#
											#
	ADDIU	$2, $0, 0x2						#
											#     return (0);
ExitGpu_GetType:							#
	JR		$31								#
	NOP										#
	.end	Gpu_GetType						# }

###############################################################################

	.globl	GPU_VSync						# PsxUInt32 GPU_VSync(void)
	.ent	GPU_VSync						# {
GPU_VSync:									#
	LA		$4, VSyncCount
	LW		$3, 0x0($4)						#
WaitForVSync:								#
	LW		$2, 0x0($4)						#
	NOP										#
	BEQ		$2, $3, WaitForVSync			#
	NOP										#
	JR		$31								#
	NOP										#
	.end	GPU_VSync						# }

###############################################################################

	.globl	GPU_SetPAL						# void GPU_SetPAL(PsxUInt32 newMode)
	.ent	GPU_SetPAL						# {
GPU_SetPAL:									#
	BEQ		$4, $0, SetNTSC
	NOP
	ADDIU	$4, $0, 0x1
SetNTSC:
	SB		$4, PalFlag						#
	JR		$31								#
	NOP										#     return(oldFlag);
	.end	GPU_SetPAL						# }

###############################################################################

	.globl	GPU_Init						# void GPU_Init(PsxInt32 xRes, PsxInt32 yRes,
	.ent	GPU_Init						#               PsxInt32 intl, PsxInt32 depth24)
GPU_Init:									# {
	ADDIU	$29, $29, 0xFFD8				#
	SW		$16, 0x18($29)					#
	SW		$17, 0x1C($29)					#
	SW		$31, 0x20($29)					#
											#
	ADDU	$16, $4, $0						#
	ADDU	$17, $5, $0						#
											#
	ANDI	$6, $6, 0xFFFF					#     Gpu_SetUpDispDrawEnv(xRes, yRes, intl,
	JAL		Gpu_SetUpDispDrawEnv			#                          depth24);
	ANDI	$7, $7, 0xFFFF					#
											#
	SH		$0, BufferIndex					#     BufferIndex = 0;
											#
	ADDU	$4, $16, $0						#     Gpu_SetUpForScreenSize(xRes, yRes);
	JAL		Gpu_SetUpForScreenSize			#
	ADDU	$5, $17, $0						#
											#
	JAL		Gpu_InitClipWinAndDrawOffset	#     Gpu_InitClipWinAndDrawOffset();
	NOP										#
											#
	LA		$4, DrawEnvClipX				#     Gpu_PutDrawEnv(&DrawEnvClipX);
	JAL		Gpu_PutDrawEnv					#
	NOP										#
											#
	LW		$31, 0x20($29)					#
	LW		$17, 0x1C($29)					#
	LW		$16, 0x18($29)					#
	JR		$31								#
	ADDIU	$29, $29, 0x28					#
	.end	GPU_Init						# }

###############################################################################

	.ent	Gpu_SetUpDispDrawEnv			# void Gpu_SetUpDispDrawEnv(PsxUInt32 xres,
Gpu_SetUpDispDrawEnv:						#				            PsxUInt32 yres,
	ADDIU	$29, $29, 0xFFEC				#				            PsxUInt32 intl,
	SW		$31, 0x10($29)					#                           PsxUInt32 depth24)
											# {
	LB		$2, PalFlag						#
											#
	SW		$0, TmpDispEnvDispX				#     TmpDispEnvDispX = TmpDispEnvDispY = 0;
	SLL		$5, $5, 0x10					#     TmpDispEnvDispW = xres;
	OR		$5, $5, $4						#     TmpDispEnvDispH = yres;
	SH		$5, TmpDispEnvDispW				#
	SW		$0, TmpDispEnvScrnX				#     TmpDispEnvScrnX = TmpDispEnvScrnY = 0;
	SW		$0, TmpDispEnvScrnW				#     TmpDispEnvScrnW = TmpDispEnvScrnH = 0;
											#
	SUB		$4, $0, $2						#     TmpDispEnvScrnY = PalFlag * 0x18;
	ANDI	$4, $4, 0x18					#
	SH		$4, TmpDispEnvScrnY				#
											#
	SLTI	$5, $6, 1						#     TmpDispEnvIsInter = intl & 1;
	XORI	$5, $5, 1						#
	SB		$5, TmpDispEnvIsInter			#
											#
	SLTI	$7, $7, 1						#     TmpDispEnvIsRGB24 = depth24 ? 1 : 0;
	XORI	$7, $7, 1						#
	SB		$7, TmpDispEnvIsRGB24			#
											#
	SW		$0, DrawEnvOffsetX				#     DrawEnvOffsetX = DrawEnvOffsetY = 0;
	SW		$0, DrawEnvTexWinX				#     DrawEnvTexWinX = DrawEnvTexWinY = 0;
	SW		$0, DrawEnvTexWinW				#     DrawEnvTexWinW = DrawEnvTexWinH = 0;
	SH		$0, DrawEnvTPage				#     DrawEnvTPage = 0;
	SB		$0, DrawEnvDither				#     DrawEnvDither = 0;
	SB		$0, DrawEnvDisplayDraw			#     DrawEnvDisplayDraw = 0;
											#
	SRL		$4, $6, 0x4						#     PsxUInt32 a = (((intl >> 4) & 3) ^ 3);
	ANDI	$4, $4, 0x3						#
	XORI	$4, $4, 0x3						#     GPU_Reset((a < 1) ? 3 : 0);
	SLTIU	$4, $4, 0x1						#
	SUBU	$4, $0, $4						#
	JAL		GPU_Reset						#
	ANDI	$4, $4, 0x3						#
											#
	LA		$4, DrawEnvClipX				#     Gpu_PutDrawEnv(&DrawEnvClipX);
	JAL		Gpu_PutDrawEnv					#
	NOP										#
											#
	LA		$4, TmpDispEnvDispX				#     Gpu_PutDispEnv(&TmpDispEnvDispX);
	JAL		Gpu_PutDispEnv					#
	NOP										#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x14					#
	JR		$31								#
	NOP										#
	.end	Gpu_SetUpDispDrawEnv			# }

###############################################################################

	.ent	Gpu_SetUpForScreenSize			# void Gpu_SetUpForScreenSize(PsxUInt16 width,
Gpu_SetUpForScreenSize:						#                             PsxUInt16 height)
	ANDI	$5, $5, 0xFFFF					# {
	ANDI	$4, $4, 0xFFFF					#     ScrWidth = width;
	SLL		$6, $5, 0x10;					#
	OR		$6, $6, $4						#     ScreenSize.x = width;
	LBU		$3, TmpDispEnvIsRGB24			#     ScreenSize.y = height;
	SW		$6, ScreenSize					#
											#     /* Scale by 1.5 for 24 bit screen */
	BEQ		$3, $0, NotA24BitClear			#	  if (TmpDispEnvIsRGB24)
	SRL		$3, $4, 0x1						#     {
	ADDU	$4, $4, $3						#         ScrWidth = ScrWidth + ScrWIdth >> 1;
NotA24BitClear:								#     }
	SLL		$5, $5, 0x10					#
	OR		$4, $4, $5						#
	SW		$4, ClearSize0					#     ClearSize0.x = ClearSize1,x = ScrWidth;
	SW		$4, ClearSize1					#     ClearSize0.y = ClearSize1.y = height;
											#
	ADDIU	$2, $0, 0x1						#     FrameCounter = 1;
	SW		$2, FrameCounter				#
											#
	JR		$31								#
	NOP										#
	.end	Gpu_SetUpForScreenSize			# }

###############################################################################

	.ent	Gpu_InsertOrderTableElement		# void Gpu_InsertOrderTableElement(GsOT_TAG *el1,
Gpu_InsertOrderTableElement:				#                                  GsOT_TAG *el2)
	LI		$6, 0x00FFFFFF					# {
	LI		$7, 0xFF000000					#     /* Inserts el2 immediately after el1 */
											#
	LW		$2, 0x0($4)						#     /* Point el2 to what el1 points to */
	LW		$3, 0x0($5)						#     el2->p &= 0xFF000000;
	AND		$8, $2, $6						#     el2->p |= el1->p & 0xFFFFFF;
	AND		$3, $3, $7						#
	OR		$3, $3, $8						#
	SW		$3, 0x0($5)						#
											#
	AND		$5, $5, $6						#     /* Point el1 at el2 */
	AND		$2, $2, $7						#     el1->p &= 0xFF000000;
	OR		$2, $2, $5						#     el1->p |= ((PsxUInt32)el2) & 0xFFFFFF;
	JR		$31								#
	SW		$2, 0x0($4)						#
	.end	Gpu_InsertOrderTableElement		# }

###############################################################################

	.globl	GPU_SetCmdWorkSpace				# void GPU_SetCmdWorkSpace(void *buffer)
	.ent	GPU_SetCmdWorkSpace				# {
GPU_SetCmdWorkSpace:						#
	SW		$4, CmdBufferAddress			#     CmdBufferAddress = buffer;
	JR		$31								#
	NOP										#
	.end	GPU_SetCmdWorkSpace				# }

###############################################################################

	.globl	GPU_SortBoxFill					# void GPU_SortBoxFill(GsOT *orderTable,
	.ent	GPU_SortBoxFill					#                      PsxUInt16 pos,
GPU_SortBoxFill:							#                      BOXFILL *boxFill)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#
	SLL		$5, $5, 0x2						#
	SUB		$4, $4, $5						#
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x10					#     /* Takes 16 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LH		$3, BufferIndex					#     /* Need to offset block by draw offset */
	LA		$2, DisplayOffset0				#
	SLL		$3, $3, 0x2						#     /* Offset into offset array */
	ADDU	$2, $2, $3						#
	LW		$2, 0x0($2)						#     /* Load X & Y offset */
											#
	LI		$3, 0x3000000					#     /* Set up the header */
	SW		$3, 0x0($5)						#
											#
	LW		$8, 0x0($6)						#     boxFill.color >--+
	LW		$9, 0x4($6)						#     boxFill.pos >----+-+
	LW		$10, 0x8($6)					#     boxFill.size >---+-+-+
											#                      | | |
	ADD		$9, $9, $2						#     Add offset >-----+-O |
											#                      | | |
	SW		$8, 0x4($5)						#     <----------------+ | |
	SW		$9, 0x8($5)						#     <------------------+ |
	SW		$10, 0xC($5)					#     <--------------------+
											#
	ADDI	$2, $0, 2						#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortBoxFill					# }

###############################################################################

	.globl	GPU_SortLine					# void GPU_SortLine(GsOT *orderTable, PsxUInt32 pos,
	.ent	GPU_SortLine					#                         LINE *line);
GPU_SortLine:								#
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#     /* Resolve $4 and $5 down to where */
	SLL		$5, $5, 0x2						#     /* we'll insert the ordertable elemnt, */
	SUB		$4, $4, $5						#     /* thereby freeing up more registers */
											#     /* for the data transfer */
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x10					#     /* Takes 16 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     tri.color >--+
	LW		$9, 0x4($6)						#     tri.vert0 >--+-+
	LW		$10, 0x8($6)					#     tri.vert1 >--+-+-+
											#                  | | |
	SW		$8, 0x4($5)						#     <------------+ | |
	SW		$9, 0x8($5)						#     <--------------+ |
	SW		$10, 0xC($5)					#     <----------------+
											#
	ADDI	$2, $0, 0x3						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x40					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortLine					# }

###############################################################################

	.globl	GPU_SortCiLine					# void        GPU_SortCiLine(GsOT *orderTable, PsxUInt32 pos,
	.ent	GPU_SortCiLine					#                           CILINE *ciLine);
GPU_SortCiLine:								#
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#     /* Resolve $4 and $5 down to where */
	SLL		$5, $5, 0x2						#     /* we'll insert the ordertable elemnt, */
	SUB		$4, $4, $5						#     /* thereby freeing up more registers */
											#     /* for the data transfer */
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x14					#     /* Takes 20 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     tri.color >--+
	LW		$9, 0x4($6)						#     tri.vert0 >--+-+
	LW		$10, 0x8($6)					#     tri.color >--+-+-+
	LW		$11, 0xC($6)					#     tri.vert1 >--+-+-+-+
											#                  | | | |
	SW		$8, 0x4($5)						#     <------------+ | | |
	SW		$9, 0x8($5)						#     <--------------+ | |
	SW		$10, 0xC($5)					#     <----------------+ |
	SW		$11, 0x10($5)					#     <------------------+
											#
	ADDI	$2, $0, 0x4						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x50					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortCiLine					# }

###############################################################################

	.globl	GPU_SortTriangle				# void GPU_SortTriangle(GsOT *ot,
	.ent	GPU_SortTriangle				#                       PsxUInt16 pos,
GPU_SortTriangle:							#                       TRI *tri)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#     /* Resolve $4 and $5 down to where */
	SLL		$5, $5, 0x2						#     /* we'll insert the ordertable elemnt, */
	SUB		$4, $4, $5						#     /* thereby freeing up more registers */
											#     /* for the data transfer */
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x14					#     /* Takes 20 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     tri.color >--+
	LW		$9, 0x4($6)						#     tri.vert0 >--+-+
	LW		$10, 0x8($6)					#     tri.vert1 >--+-+-+
	LW		$11, 0xC($6)					#     tri.vert2 >--+-+-+-+
											#                  | | | |
	SW		$8, 0x4($5)						#     <------------+ | | |
	SW		$9, 0x8($5)						#     <--------------+ | |
	SW		$10, 0xC($5)					#     <----------------+ |
	SW		$11, 0x10($5)					#     <------------------+
											#
	ADDI	$2, $0, 0x4						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x20					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortTriangle				# }

###############################################################################

	.globl	GPU_SortCiTriangle				# void GPU_SortCiTriangle(GsOT *orderTable,
	.ent	GPU_SortCiTriangle				#                         PsxUInt16 pos,
GPU_SortCiTriangle:							#                         CITRI *ciTri)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#
	SLL		$5, $5, 0x2						#
	SUB		$4, $4, $5						#
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x1C					#     /* Takes 28 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     ciTri.color0 >--+
	LW		$9, 0x4($6)						#     ciTri.vert0 >---+-+
	LW		$10, 0x8($6)					#     ciTri.color1 >--+-+-+
	LW		$11, 0xC($6)					#     ciTri.vert1 >---+-+-+-+
	LW		$12, 0x10($6)					#     ciTri.color2 >--+-+-+-+-+
	LW		$13, 0x14($6)					#     ciTri.vert2 >---+-+-+-+-+-+
											#                     | | | | | |
	SW		$8, 0x4($5)						#     <---------------+ | | | | |
	SW		$9, 0x8($5)						#     <-----------------+ | | | |
	SW		$10, 0xC($5)					#     <-------------------+ | | |
	SW		$11, 0x10($5)					#     <---------------------+ | |
	SW		$12, 0x14($5)					#     <-----------------------+ |
	SW		$13, 0x18($5)					#     <-------------------------+
											#
	ADDI	$2, $0, 0x6						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x30					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortCiTriangle				# }

###############################################################################

	.globl	GPU_SortTexTriangle				# void GPU_SortTexTriangle(GsOT *orderTable,
	.ent	GPU_SortTexTriangle				#                          PsxUInt16 pos,
GPU_SortTexTriangle:						#                          TEXTRI *texTri)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#
	SLL		$5, $5, 0x2						#
	SUB		$4, $4, $5						#
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x20					#     /* Takes 32 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     texTri.color >---+
	LW		$9, 0x4($6)						#     texTri.vert0 >---+-+
	LW		$10, 0x8($6)					#     texTri.tc0 >-----+-+-+
	LW		$11, 0xC($6)					#     texTri.vert1 >---+-+-+-+
	LW		$12, 0x10($6)					#     texTri.tc1 >-----+-+-+-+-+
	LW		$13, 0x14($6)					#     texTri.vert2 >---+-+-+-+-+-+
	LW		$14, 0x18($6)					#     texTri.tc2 >-----+-+-+-+-+-+-+
											#                      | | | | | | |
	SW		$8, 0x4($5)						#     <----------------+ | | | | | |
	SW		$9, 0x8($5)						#     <------------------+ | | | | |
	SW		$10, 0xC($5)					#     <--------------------+ | | | |
	SW		$11, 0x10($5)					#     <----------------------+ | | |
	SW		$12, 0x14($5)					#     <------------------------+ | |
	SW		$13, 0x18($5)					#     <--------------------------+ |
	SW		$14, 0x1C($5)					#     <----------------------------+
											#
	ADDI	$2, $0, 0x7						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x24					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
											#
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortTexTriangle				# }

###############################################################################

	.globl	GPU_SortCiTexTriangle			# void GPU_SortCiTexTriangle(GsOT *orderTable,
	.ent	GPU_SortCiTexTriangle			#                            PsxUInt16 pos,
GPU_SortCiTexTriangle:						#                            CITEXTRI *ciTexTri)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#
	SLL		$5, $5, 0x2						#
	SUB		$4, $4, $5						#
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x28					#     /* Takes 40 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     ciTexTri.color0 >--+
	LW		$9, 0x4($6)						#     ciTexTri.vert0 >---+-+
	LW		$10, 0x8($6)					#     ciTexTri.tc0 >-----+-+-+
	LW		$11, 0xC($6)					#     ciTexTri.color1 >--+-+-+-+
	LW		$12, 0x10($6)					#     ciTexTri.vert1 >---+-+-+-+-+
	LW		$13, 0x14($6)					#     ciTexTri.tc1 >-----+-+-+-+-+-+
	LW		$14, 0x18($6)					#     ciTexTri.color2 >--+-+-+-+-+-+-+
	LW		$15, 0x1C($6)					#     ciTexTri.vert2 >---+-+-+-+-+-+-+-+
	LW		$24, 0x20($6)					#     ciTexTri.tc2 >-----+-+-+-+-+-+-+-+-+
											#                        | | | | | | | | |
	SW		$8, 0x4($5)						#     <------------------+ | | | | | | | |
	SW		$9, 0x8($5)						#     <--------------------+ | | | | | | |
	SW		$10, 0xC($5)					#     <----------------------+ | | | | | |
	SW		$11, 0x10($5)					#     <------------------------+ | | | | |
	SW		$12, 0x14($5)					#     <--------------------------+ | | | |
	SW		$13, 0x18($5)					#     <----------------------------+ | | |
	SW		$14, 0x1C($5)					#     <------------------------------+ | |
	SW		$15, 0x20($5)                   #     <--------------------------------+ |
	SW		$24, 0x24($5)                   #     <----------------------------------+
											#
	ADDI	$2, $0, 0x9						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x34					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
											#
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortCiTexTriangle			# }

###############################################################################

	.globl	GPU_SortQuad					# void GPU_SortQuad(GsOT *orderTable,
	.ent	GPU_SortQuad					#                   PsxUInt16 pos,
GPU_SortQuad:								#                   QUAD *quad)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#     /* Resolve $4 and $5 down to where */
	SLL		$5, $5, 0x2						#     /* we'll insert the ordertable elemnt, */
	SUB		$4, $4, $5						#     /* thereby freeing up more registers */
											#     /* for the data transfer */
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x18					#     /* Takes 24 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     tri.color >--+
	LW		$9, 0x4($6)						#     tri.vert0 >--+-+
	LW		$10, 0x8($6)					#     tri.vert1 >--+-+-+
	LW		$11, 0xC($6)					#     tri.vert2 >--+-+-+-+
	LW		$12, 0x10($6)					#     tri.vert3 >--+-+-+-+-+
											#                  | | | | |
	SW		$8, 0x4($5)						#     <------------+ | | | |
	SW		$9, 0x8($5)						#     <--------------+ | | |
	SW		$10, 0xC($5)					#     <----------------+ | |
	SW		$11, 0x10($5)					#     <------------------+ |
	SW		$12, 0x14($5)					#     <--------------------+
											#
	ADDI	$2, $0, 0x5						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x28					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortQuad					# }

###############################################################################

	.globl	GPU_SortCiQuad					# void GPU_SortCiQuad(GsOT *orderTable,
	.ent	GPU_SortCiQuad					#                     PsxUInt16 pos,
GPU_SortCiQuad:								#                     CIQUAD *ciQuad)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#     /* Resolve $4 and $5 down to where */
	SLL		$5, $5, 0x2						#     /* we'll insert the ordertable elemnt, */
	SUB		$4, $4, $5						#     /* thereby freeing up more registers */
											#     /* for the data transfer */
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x24					#     /* Takes 36 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     tri.color0 >--+
	LW		$9, 0x4($6)						#     tri.vert0 >---+-+
	LW		$10, 0x8($6)					#     tri.color1 >--+-+-+
	LW		$11, 0xC($6)					#     tri.vert1 >---+-+-+-+
	LW		$12, 0x10($6)					#     tri.color2 >--+-+-+-+-+
	LW		$13, 0x14($6)					#     tri.vert2 >---+-+-+-+-+-+
	LW		$14, 0x18($6)					#     tri.color3 >--+-+-+-+-+-+-+
	LW		$15, 0x1C($7)					#     tri.vert3 >---+-+-+-+-+-+-+-+
											#                   | | | | | | | |
	SW		$8, 0x4($5)						#     <-------------+ | | | | | | |
	SW		$9, 0x8($5)						#     <---------------+ | | | | | |
	SW		$10, 0xC($5)					#     <-----------------+ | | | | |
	SW		$11, 0x10($5)					#     <-------------------+ | | | |
	SW		$12, 0x14($5)					#     <---------------------+ | | |
	SW		$13, 0x18($5)					#     <-----------------------+ | |
	SW		$14, 0x1C($5)					#     <-------------------------+ |
	SW		$15, 0x20($5)					#     <---------------------------+
											#
	ADDI	$2, $0, 0x8						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x38					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortCiQuad					# }

###############################################################################

	.globl	GPU_SortTexQuad					# void GPU_SortTexQuad(GsOT *orderTable,
	.ent	GPU_SortTexQuad					#                      PsxUInt32 pos,
GPU_SortTexQuad:							#                      TEXQUAD *texQuad)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#
	SLL		$5, $5, 0x2						#
	SUB		$4, $4, $5						#
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x28					#     /* Takes 40 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     texQuad.color >--+
	LW		$9, 0x4($6)						#     texQuad.vert0 >--+-+
	LW		$10, 0x8($6)					#     texQuad.tc0 >----+-+-+
	LW		$11, 0xC($6)					#     texQuad.vert1 >--+-+-+-+
	LW		$12, 0x10($6)					#     texQuad.tc1 >----+-+-+-+-+
	LW		$13, 0x14($6)					#     texQuad.vert2 >--+-+-+-+-+-+
	LW		$14, 0x18($6)					#     texQuad.tc2 >----+-+-+-+-+-+-+
	LW		$15, 0x1C($6)					#     texQuad.vert3 >--+-+-+-+-+-+-+-+
	LW		$24, 0x20($6)					#     texQuad.tc3 >----+-+-+-+-+-+-+-+-+
											#                      | | | | | | | | |
	SW		$8, 0x4($5)						#     <----------------+ | | | | | | | |
	SW		$9, 0x8($5)						#     <------------------+ | | | | | | |
	SW		$10, 0xC($5)					#     <--------------------+ | | | | | |
	SW		$11, 0x10($5)					#     <----------------------+ | | | | |
	SW		$12, 0x14($5)					#     <------------------------+ | | | |
	SW		$13, 0x18($5)					#     <--------------------------+ | | |
	SW		$14, 0x1C($5)					#     <----------------------------+ | |
	SW		$15, 0x20($5)                   #     <------------------------------+ |
	SW		$24, 0x24($5)                   #     <--------------------------------+
											#
	ADDI	$2, $0, 0x9						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x2C					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortTexQuad					# }

###############################################################################

	.globl	GPU_SortCiTexQuad				# void GPU_SortCiTexQuad(GsOT *orderTable,
	.ent	GPU_SortCiTexQuad				#                        PsxUInt32 pos,
GPU_SortCiTexQuad:							#                        CITEXQUAD *ciTexQuad)
	LW		$4, 0x10($4)					# {
	AND		$5, $5, 0xFFFF					#
	SLL		$5, $5, 0x2						#
	SUB		$4, $4, $5						#
											#
	LW		$5, CmdBufferAddress			#     /* Grab us a buffer for the primitive */
											#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	ADDU	$3, $5, 0x34					#     /* Takes 52 bytes */
	SW		$3, CmdBufferAddress			#     /* Get ready for next prim */
											#
	LW		$8, 0x0($6)						#     ciTexQuad.color0 >--+
	LW		$9, 0x4($6)						#     ciTexQuad.vert0 >---+-+
	LW		$10, 0x8($6)					#     ciTexQuad.tc0 >-----+-+-+
	LW		$11, 0xC($6)					#     ciTexQuad.color1 >--+-+-+-+
	LW		$12, 0x10($6)					#     ciTexQuad.vert1 >---+-+-+-+-+
	LW		$13, 0x14($6)					#     ciTexQuad.tc1 >-----+-+-+-+-+-+
	LW		$14, 0x18($6)					#     ciTexQuad.color2 >--+-+-+-+-+-+-+
	LW		$15, 0x1C($6)					#     ciTexQuad.vert2 >---+-+-+-+-+-+-+-+
	LW		$24, 0x20($6)					#     ciTexQuad.tc2 >-----+-+-+-+-+-+-+-+-+
	LW		$25, 0x24($6)					#     ciTexQuad.color3 >--+-+-+-+-+-+-+-+-+-+
	LW		$7, 0x28($6)					#     ciTexQuad.vert3 >---+-+-+-+-+-+-+-+-+-+-+
	LW		$6, 0x2C($6)					#     ciTexQuad.tc3 >-----+-+-+-+-+-+-+-+-+-+-+-+
											#                         | | | | | | | | | | | |
	SW		$8, 0x4($5)						#     <-------------------+ | | | | | | | | | | |
	SW		$9, 0x8($5)						#     <---------------------+ | | | | | | | | | |
	SW		$10, 0xC($5)					#     <-----------------------+ | | | | | | | | |
	SW		$11, 0x10($5)					#     <-------------------------+ | | | | | | | |
	SW		$12, 0x14($5)					#     <---------------------------+ | | | | | | |
	SW		$13, 0x18($5)					#     <-----------------------------+ | | | | | |
	SW		$14, 0x1C($5)					#     <-------------------------------+ | | | | |
	SW		$15, 0x20($5)                   #     <---------------------------------+ | | | |
	SW		$24, 0x24($5)                   #     <-----------------------------------+ | | |
	SW		$25, 0x28($5)					#     <-------------------------------------+ | |
	SW		$7, 0x2C($5)					#     <---------------------------------------+ |
	SW		$6, 0x30($5)					#     <-----------------------------------------+
											#
	ADDI	$2, $0, 0xC						#
	SB		$2, 0x3($5)						#     /* Length of the cmd */
											#
	ADDI	$2, $0, 0x3C					#     /* Fill in the primitive cmd */
											#
											#     /* Right, we've built it, just need */
											#     /* to link it in to the table */
											#
	JAL		Gpu_InsertOrderTableElement		#
	SB		$2, 0x7($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortCiTexQuad				# }

###############################################################################

	.globl	GPU_SortClear					# void GPU_SortClear(PsxUInt32 bufferIndex,
	.ent	GPU_SortClear					#                    GsOT *ot, COLOR *color)
GPU_SortClear:								# {
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	LA		$7, ClearOT0					#
	SLL		$4, $4, 0x4						#
	ADDU	$7, $7, $4						#     $6 points to the clear cmd buffer
											#
											#     COPY THE COLOR ACROSS
											#
	LH		$8, 0x0($6)						#     Load Red & Green >--+
	LB		$9, 0x2($6)						#     Load Blue >---------+-+
											#                         | |
	SH		$8, 0x4($7)						#     Store Red & Green <-+ |
	SB		$9, 0x6($7)						#     Store Blue <----------+
											#
	LW		$4, 0x10($5)					#     Insert at this pos
	JAL		Gpu_InsertOrderTableElement		#
	ADD		$5, $7, $0						#     Insert this
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_SortClear					# }

###############################################################################

	.globl	GPU_GetActiveBuff				# PsxInt32 GPU_GetActiveBuff(void)
	.ent	GPU_GetActiveBuff				# {
GPU_GetActiveBuff:							#
	LH		$2, BufferIndex					#
	JR		$31								#     return(BufferIndex);
	NOP										#
	.end	GPU_GetActiveBuff				# }

###############################################################################

	.ent	Gpu_InitClipWinAndDrawOffset	# void Gpu_InitClipWinAndDrawOffset(void)
Gpu_InitClipWinAndDrawOffset:				# {
	LH		$2, BufferIndex					#
	LA		$3, DisplayOffset0				#
	SLL		$2, $2, 0x2						#     Offset into offset array
	ADDU	$3, $3, $2						#
											#
	LW		$8, 0x0($3)						#     Load X & Y>--+
	LW		$10, ScreenSize					#     Load W & H>--+-+
											#                  | |
	SW		$8, DrawEnvClipX				#     Store X <----+ |
	SW		$8, DrawEnvOffsetX				#     Store X <----+ |
	SW		$10, DrawEnvClipW				#     Store W <------+
											#
	JR		$31								#
	NOP										#
	.end	Gpu_InitClipWinAndDrawOffset	# }

###############################################################################

	.globl	GPU_FlipDisplay					# void GPU_FlipDisplay(void)
	.ent	GPU_FlipDisplay					# {
GPU_FlipDisplay:							#     /* Copy X and Y of display offset */
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	LH		$2, BufferIndex					#     *(PsxUInt32 *)&TmpDispEnvDispX =
	LA		$3, DisplayOffset0				#         *(PsxUInt32 *)DisplayOffset0[BufferIndex];
	SLL		$2, $2, 0x2						#
	ADDU	$3, $3, $2						#
	LW		$3, 0x0($3)						#
											#
	LA		$4, TmpDispEnvDispX				#
	JAL		Gpu_PutDispEnv						#
	SW		$3, 0x0($4)						#
											#
	JAL		GPU_EnableDisplay				#     GPU_EnableDisplay(1);
	ADDIU	$4, $0, 0x1						#
											#
	LW		$3, FrameCounter				#
	LH		$2, BufferIndex					#
	ADDIU	$3, $3, 0x1						#
	SLTIU	$4, $3, 0x1						#
	ADD		$3, $3, $4						#     FrameCounter++;
	SW		$3, FrameCounter				#     FrameCounter += FrameCounter < 1 ? 1 : 0;
	SLTIU	$2, $2, 0x1						#
	SH		$2, BufferIndex					#     BufferIndex = !BufferIndex;
											#
	JAL		Gpu_InitClipWinAndDrawOffset	#     Gpu_InitClipWinAndDrawOffset();
	NOP										#
											#
	LA		$4, DrawEnvClipX				#     Gpu_PutDrawEnv(&DrawEnvClipX);
	JAL		Gpu_PutDrawEnv					#
	NOP										#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_FlipDisplay					# }

###############################################################################

	.globl	GPU_DefDispBuff					# void GPU_DefDispBuff(PsxInt32 x0, PsxInt32 y0,
	.ent	GPU_DefDispBuff					#                      PsxInt32 x1, PsxInt32 y1)
GPU_DefDispBuff:							# {
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	SLL		$5, $5, 0x10					#
	OR		$5, $5, $4						#
	SLL		$7, $7, 0x10					#
	OR		$7, $7, $6						#
											#
	SW		$5, DisplayOffset0				#     DisplayOffset0.x = x0;
	SW		$7, DisplayOffset1				#     DisplayOffset0.y = y0;
											#     DisplayOffset1.x = x1;
											#     DisplayOffset1.y = y1;
											#
	SW		$5, ClearPos0					#     ClearPos0.x = x0;
	SW		$7, ClearPos1					#     ClearPos0.y = y0
											#     ClearPos1.x = x1;
											#     ClearPos1.y = y1;
											#
	JAL		Gpu_InitClipWinAndDrawOffset	#     Gpu_InitClipWinAndDrawOffset();
	NOP										#
											#
	LA		$4, DrawEnvClipX				#     Gpu_PutDrawEnv(&DrawEnvClipX);
	JAL		Gpu_PutDrawEnv					#
	NOP										#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_DefDispBuff					# }

###############################################################################

	.globl	GPU_DrawOt						# void GPU_DrawOt(GsOT *ot)
	.ent	GPU_DrawOt						# {
GPU_DrawOt:									#
	ADDIU	$29, $29, 0xFFE8				#
	SW		$31, 0x10($29)					#
											#
	LW		$5, 0x10($4)					#     /* Ship it - it will follow the chain */
	ADDU	$6, $0, $0						#     Gpu_EnqueOp(Gpu_DoDMATransfer, otTag, 0, 0);
	LA		$4, Gpu_DoDMATransfer			#
	JAL		Gpu_EnqueOp						#
	ADDU	$7, $0, $0						#
											#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_DrawOt						# }

###############################################################################

	.globl	GPU_ClearOt						# void GPU_ClearOt(PsxUInt32 offset,
	.ent	GPU_ClearOt						#                  PsxUInt32 point,
GPU_ClearOt:								#                  GsOT *table)
	ADDIU	$29, $29, 0xFFE8				# {
	ANDI	$4, $4, 0xFFFF					#
	ANDI	$5, $5, 0xFFFF					#
	SW		$31, 0x10($29)					#
											#
	SW		$4, 0x8($6)						#     table->offset = offset;
	LW		$4, 0x0($6)						#     $4 = table.length;
	LW		$2, 0x4($6)						#
	ADDIU	$3, $0, 0x4						#
	SW		$5, 0xC($6)						#     table->point = point;
	LW		$5, 0x0($6)						#
	SLLV	$3, $3, $4						#
	ADDU	$2, $2, $3						#
	ADDIU	$2, $2, 0xFFFC					#
	SW		$2, 0x10($6)					#     table.tag = table.org + $3 - 4;
	ADDIU	$2, $0, 0x1						#
	LW		$4, 0x4($6)						#
	JAL		Gpu_ClearOTagR					#     Gpu_ClearOTagR(table.org, 1 << table.length);
	SLLV	$5, $2, $5						#
	LW		$31, 0x10($29)					#
	ADDIU	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	GPU_ClearOt						# }

###############################################################################

	.globl	GPU_TIMGetClut					# TIMCLUT *GPU_TIMGetClut(TIMHEADER *tim)
	.ent	GPU_TIMGetClut					# {
GPU_TIMGetClut:								#
	LW		$5, 0x0($4)						#     if (tim->id != 0x00000010)
	ADDIU	$3, $0, 0x0010					#     {
	BNE		$5, $3, ExitGPU_TIMGetClut		#         /* Not a valid TIM file */
	ADDU	$2, $0, $0						#         return(NULL);
											#     }
	LW		$5, 0x4($4)						#
	ADDIU	$4, $4, 0x8						#     if (!(tim->flags & TIMHDR_CLUTPRESENT))
	ANDI	$5, $5, 0x0008					#     {
	BEQ		$5, $0, ExitGPU_TIMGetClut		#         /* No clut in this file */
	ADDU	$2, $0, $0						#         return(NULL);
											#     }
	ADDU	$2, $4, $0						#
ExitGPU_TIMGetClut:							#     /* The clut immediately follows the header */
	JR		$31								#     return ((TIMCLUT *)(tim+1));
	NOP										#
	.end	GPU_TIMGetClut					# }

###############################################################################

	.globl	GPU_TIMGetImage					# TIMIMAGE *GPU_TIMGetImage(TIMHEADER *tim)
	.ent	GPU_TIMGetImage					# {
GPU_TIMGetImage:							#     PsxUInt32		*words;
	LW		$5, 0x0($4)						#     if (tim->id != 0x00000010)
	ADDIU	$3, $0, 0x0010					#     {
	BNE		$5, $3, ExitGPU_TIMGetImage		#         /* Not a valid TIM file */
	ADDU	$2, $0, $0						#         return(NULL);
											#     }
	LW		$5, 0x4($4)						#
	ADDIU	$2, $4, 0x8						#     if (!(tim->flags & TIMHDR_CLUTPRESENT))
	ANDI	$5, $5, 0x0008					#     {
	BEQ		$5, $0, ExitGPU_TIMGetImage		#         /* Image follows header, no clut */
	LW		$3, 0x0($2)						#         return((TIMIMAGE*)(tim+1));
	NOP										#     }
	ADDU	$2, $2, $3						#
ExitGPU_TIMGetImage:						#     words = (PsxUInt32 *)(tim+1);
	JR		$31								#     words += (words[0] / 4);
	NOP										#     return(words);
	.end	GPU_TIMGetImage					# }

###############################################################################

	.globl	GPU_LoadImageData				# void GPU_LoadImageData(RECT *area,
	.ent	GPU_LoadImageData				#                        PsxUInt16 *imageData)
GPU_LoadImageData:							# {
	ADDIU	$29, $29, 0xFFE0				#
	SW		$31, 0x18($29)					#     /* Copy rect into que, data is
											#      * passed directly.
	ADDU	$7, $5, $0						#      */
	ADDU	$5, $4, $0						#     return(Gpu_EnqueOp(Gpu_LoadImageSection,
	LA		$4, Gpu_LoadImageSection		#                        area, 8, data));
	JAL		Gpu_EnqueOp						#
	ADDIU	$6, $0, 0x8						#
											#
	LW		$31, 0x18($29)					#
	ADDIU	$29, $29, 0x20					#
	JR		$31								#
	NOP										#
	.end	GPU_LoadImageData				# }

###############################################################################

	.globl	GPU_CalcClutID					# PsxUInt16 GPU_CalcClutID(PsxUInt16 x,
	.ent	GPU_CalcClutID					#                          PsxUInt16 y)
GPU_CalcClutID:								# {
	SRL		$4, $4, 0x4						#     x >>= 4;
	SLL		$5, $5, 0x6						#     y <<= 6;
	JR		$31								#
	OR		$2, $4, $5						#     return (x | y);
	.end	GPU_CalcClutID					# }

###############################################################################

	.globl	GPU_CalcTexturePage				# PsxUInt16
	.ent	GPU_CalcTexturePage				# GPU_CalcTexturePage(PsxUInt16 x, PsxUInt16 y,
GPU_CalcTexturePage:						#                     PsxUInt32 clutMode)
	SRL		$4, $4, 0x6						# {
	SRL		$5, $5, 0x8						#     PsxUInt16 cmd;
	SLL		$5, $5, 0x4						#
	SLL		$6, $6, 0x7						#     cmd = (x >> 6) | ((y >> 8) << 4);
	OR		$2, $4, $5						#     cmd |= (clutMode << 7);
	JR		$31								#
	OR		$2, $2, $6						#     return (cmd);
	.end	GPU_CalcTexturePage				# }

###############################################################################
