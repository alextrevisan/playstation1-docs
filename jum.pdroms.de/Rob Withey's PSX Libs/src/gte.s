###############################################################################

	.rdata
	.align	4

###############################################################################

TmpRAStore1:
	.word	0
TmpRAStore2:
	.word	0

GTE_ScreenWidth:
	.word	0
GTE_ScreenHeight:
	.word	0

###############################################################################

# This is a sine lookup table
SineTab:
	.hword	0x0000							# 0x0000
	.hword	0x0065							# 0x0010
	.hword	0x00C9							# 0x0020
	.hword	0x012D							# 0x0030
	.hword	0x0191							# 0x0040
	.hword	0x01F5							# 0x0050
	.hword	0x0259							# 0x0060
	.hword	0x02BC							# 0x0070
	.hword	0x031F							# 0x0080
	.hword	0x0381							# 0x0090
	.hword	0x03E3							# 0x00A0
	.hword	0x0444							# 0x00B0
	.hword	0x04A5							# 0x00C0
	.hword	0x0505							# 0x00D0
	.hword	0x0564							# 0x00E0
	.hword	0x05C2							# 0x00F0
	.hword	0x061F							# 0x0100
	.hword	0x067C							# 0x0110
	.hword	0x06D7							# 0x0120
	.hword	0x0732							# 0x0130
	.hword	0x078B							# 0x0140
	.hword	0x07E3							# 0x0150
	.hword	0x083A							# 0x0160
	.hword	0x088F							# 0x0170
	.hword	0x08E4							# 0x0180
	.hword	0x0937							# 0x0190
	.hword	0x0988							# 0x01A0
	.hword	0x09D8							# 0x01B0
	.hword	0x0A26							# 0x01C0
	.hword	0x0A73							# 0x01D0
	.hword	0x0ABF							# 0x01E0
	.hword	0x0B08							# 0x01F0
	.hword	0x0B50							# 0x0200
	.hword	0x0B97							# 0x0210
	.hword	0x0BDB							# 0x0220
	.hword	0x0C1E							# 0x0230
	.hword	0x0C5E							# 0x0240
	.hword	0x0C9D							# 0x0250
	.hword	0x0CDA							# 0x0260
	.hword	0x0D15							# 0x0270
	.hword	0x0D4E							# 0x0280
	.hword	0x0D85							# 0x0290
	.hword	0x0DB9							# 0x02A0
	.hword	0x0DEC							# 0x02B0
	.hword	0x0E1C							# 0x02C0
	.hword	0x0E4B							# 0x02D0
	.hword	0x0E77							# 0x02E0
	.hword	0x0EA1							# 0x02F0
	.hword	0x0EC8							# 0x0300
	.hword	0x0EEE							# 0x0310
	.hword	0x0F11							# 0x0320
	.hword	0x0F31							# 0x0330
	.hword	0x0F50							# 0x0340
	.hword	0x0F6C							# 0x0350
	.hword	0x0F85							# 0x0360
	.hword	0x0F9C							# 0x0370
	.hword	0x0FB1							# 0x0380
	.hword	0x0FC4							# 0x0390
	.hword	0x0FD4							# 0x03A0
	.hword	0x0FE1							# 0x03B0
	.hword	0x0FEC							# 0x03C0
	.hword	0x0FF5							# 0x03D0
	.hword	0x0FFB							# 0x03E0
	.hword	0x0FFF							# 0x03F0
	.hword	0x1000							# 0x0400
	.hword	0x0FFF							# 0x0410
	.hword	0x0FFB							# 0x0420
	.hword	0x0FF5							# 0x0430
	.hword	0x0FEC							# 0x0440
	.hword	0x0FE1							# 0x0450
	.hword	0x0FD4							# 0x0460
	.hword	0x0FC4							# 0x0470
	.hword	0x0FB1							# 0x0480
	.hword	0x0F9C							# 0x0490
	.hword	0x0F85							# 0x04A0
	.hword	0x0F6C							# 0x04B0
	.hword	0x0F50							# 0x04C0
	.hword	0x0F31							# 0x04D0
	.hword	0x0F11							# 0x04E0
	.hword	0x0EEE							# 0x04F0
	.hword	0x0EC8							# 0x0500
	.hword	0x0EA1							# 0x0510
	.hword	0x0E77							# 0x0520
	.hword	0x0E4B							# 0x0530
	.hword	0x0E1C							# 0x0540
	.hword	0x0DEC							# 0x0550
	.hword	0x0DB9							# 0x0560
	.hword	0x0D85							# 0x0570
	.hword	0x0D4E							# 0x0580
	.hword	0x0D15							# 0x0590
	.hword	0x0CDA							# 0x05A0
	.hword	0x0C9D							# 0x05B0
	.hword	0x0C5E							# 0x05C0
	.hword	0x0C1E							# 0x05D0
	.hword	0x0BDB							# 0x05E0
	.hword	0x0B97							# 0x05F0
	.hword	0x0B50							# 0x0600
	.hword	0x0B08							# 0x0610
	.hword	0x0ABF							# 0x0620
	.hword	0x0A73							# 0x0630
	.hword	0x0A26							# 0x0640
	.hword	0x09D8							# 0x0650
	.hword	0x0988							# 0x0660
	.hword	0x0937							# 0x0670
	.hword	0x08E4							# 0x0680
	.hword	0x088F							# 0x0690
	.hword	0x083A							# 0x06A0
	.hword	0x07E3							# 0x06B0
	.hword	0x078B							# 0x06C0
	.hword	0x0732							# 0x06D0
	.hword	0x06D7							# 0x06E0
	.hword	0x067C							# 0x06F0
	.hword	0x061F							# 0x0700
	.hword	0x05C2							# 0x0710
	.hword	0x0564							# 0x0720
	.hword	0x0505							# 0x0730
	.hword	0x04A5							# 0x0740
	.hword	0x0444							# 0x0750
	.hword	0x03E3							# 0x0760
	.hword	0x0381							# 0x0770
	.hword	0x031F							# 0x0780
	.hword	0x02BC							# 0x0790
	.hword	0x0259							# 0x07A0
	.hword	0x01F5							# 0x07B0
	.hword	0x0191							# 0x07C0
	.hword	0x012D							# 0x07D0
	.hword	0x00C9							# 0x07E0
	.hword	0x0065							# 0x07F0
	.hword	0x0000							# 0x0800
	.hword	0xFF9C							# 0x0810
	.hword	0xFF38							# 0x0820
	.hword	0xFED4							# 0x0830
	.hword	0xFE70							# 0x0840
	.hword	0xFE0C							# 0x0850
	.hword	0xFDA8							# 0x0860
	.hword	0xFD45							# 0x0870
	.hword	0xFCE2							# 0x0880
	.hword	0xFC80							# 0x0890
	.hword	0xFC1E							# 0x08A0
	.hword	0xFBBD							# 0x08B0
	.hword	0xFB5C							# 0x08C0
	.hword	0xFAFC							# 0x08D0
	.hword	0xFA9D							# 0x08E0
	.hword	0xFA3F							# 0x08F0
	.hword	0xF9E2							# 0x0900
	.hword	0xF985							# 0x0910
	.hword	0xF92A							# 0x0920
	.hword	0xF8CF							# 0x0930
	.hword	0xF876							# 0x0940
	.hword	0xF81E							# 0x0950
	.hword	0xF7C7							# 0x0960
	.hword	0xF772							# 0x0970
	.hword	0xF71D							# 0x0980
	.hword	0xF6CA							# 0x0990
	.hword	0xF679							# 0x09A0
	.hword	0xF629							# 0x09B0
	.hword	0xF5DB							# 0x09C0
	.hword	0xF58E							# 0x09D0
	.hword	0xF542							# 0x09E0
	.hword	0xF4F9							# 0x09F0
	.hword	0xF4B1							# 0x0A00
	.hword	0xF46A							# 0x0A10
	.hword	0xF426							# 0x0A20
	.hword	0xF3E3							# 0x0A30
	.hword	0xF3A3							# 0x0A40
	.hword	0xF364							# 0x0A50
	.hword	0xF327							# 0x0A60
	.hword	0xF2EC							# 0x0A70
	.hword	0xF2B3							# 0x0A80
	.hword	0xF27C							# 0x0A90
	.hword	0xF248							# 0x0AA0
	.hword	0xF215							# 0x0AB0
	.hword	0xF1E5							# 0x0AC0
	.hword	0xF1B6							# 0x0AD0
	.hword	0xF18A							# 0x0AE0
	.hword	0xF160							# 0x0AF0
	.hword	0xF139							# 0x0B00
	.hword	0xF113							# 0x0B10
	.hword	0xF0F0							# 0x0B20
	.hword	0xF0D0							# 0x0B30
	.hword	0xF0B1							# 0x0B40
	.hword	0xF095							# 0x0B50
	.hword	0xF07C							# 0x0B60
	.hword	0xF065							# 0x0B70
	.hword	0xF050							# 0x0B80
	.hword	0xF03D							# 0x0B90
	.hword	0xF02D							# 0x0BA0
	.hword	0xF020							# 0x0BB0
	.hword	0xF015							# 0x0BC0
	.hword	0xF00C							# 0x0BD0
	.hword	0xF006							# 0x0BE0
	.hword	0xF002							# 0x0BF0
	.hword	0xF001							# 0x0C00
	.hword	0xF002							# 0x0C10
	.hword	0xF006							# 0x0C20
	.hword	0xF00C							# 0x0C30
	.hword	0xF015							# 0x0C40
	.hword	0xF020							# 0x0C50
	.hword	0xF02D							# 0x0C60
	.hword	0xF03D							# 0x0C70
	.hword	0xF050							# 0x0C80
	.hword	0xF065							# 0x0C90
	.hword	0xF07C							# 0x0CA0
	.hword	0xF095							# 0x0CB0
	.hword	0xF0B1							# 0x0CC0
	.hword	0xF0D0							# 0x0CD0
	.hword	0xF0F0							# 0x0CE0
	.hword	0xF113							# 0x0CF0
	.hword	0xF139							# 0x0D00
	.hword	0xF160							# 0x0D10
	.hword	0xF18A							# 0x0D20
	.hword	0xF1B6							# 0x0D30
	.hword	0xF1E5							# 0x0D40
	.hword	0xF215							# 0x0D50
	.hword	0xF248							# 0x0D60
	.hword	0xF27C							# 0x0D70
	.hword	0xF2B3							# 0x0D80
	.hword	0xF2EC							# 0x0D90
	.hword	0xF327							# 0x0DA0
	.hword	0xF364							# 0x0DB0
	.hword	0xF3A3							# 0x0DC0
	.hword	0xF3E3							# 0x0DD0
	.hword	0xF426							# 0x0DE0
	.hword	0xF46A							# 0x0DF0
	.hword	0xF4B1							# 0x0E00
	.hword	0xF4F9							# 0x0E10
	.hword	0xF542							# 0x0E20
	.hword	0xF58E							# 0x0E30
	.hword	0xF5DB							# 0x0E40
	.hword	0xF629							# 0x0E50
	.hword	0xF679							# 0x0E60
	.hword	0xF6CA							# 0x0E70
	.hword	0xF71D							# 0x0E80
	.hword	0xF772							# 0x0E90
	.hword	0xF7C7							# 0x0EA0
	.hword	0xF81E							# 0x0EB0
	.hword	0xF876							# 0x0EC0
	.hword	0xF8CF							# 0x0ED0
	.hword	0xF92A							# 0x0EE0
	.hword	0xF985							# 0x0EF0
	.hword	0xF9E2							# 0x0F00
	.hword	0xFA3F							# 0x0F10
	.hword	0xFA9D							# 0x0F20
	.hword	0xFAFC							# 0x0F30
	.hword	0xFB5C							# 0x0F40
	.hword	0xFBBD							# 0x0F50
	.hword	0xFC1E							# 0x0F60
	.hword	0xFC80							# 0x0F70
	.hword	0xFCE2							# 0x0F80
	.hword	0xFD45							# 0x0F90
	.hword	0xFDA8							# 0x0FA0
	.hword	0xFE0C							# 0x0FB0
	.hword	0xFE70							# 0x0FC0
	.hword	0xFED4							# 0x0FD0
	.hword	0xFF38							# 0x0FE0
	.hword	0xFF9C							# 0x0FF0

###############################################################################

	.text
	.set	noreorder
	.align	4

###############################################################################

	.globl	GTE_Init
	.ent	GTE_Init
GTE_Init:
	ADDIU	$29, $29, 0xFFE8
	SW		$4, GTE_ScreenWidth
	SW		$5, GTE_ScreenHeight
	SW		$31, 0x10($29)
	JAL		GTE_Enable
	NOP
	ADDU	$4, $0, $0
	ADDU	$5, $0, $0
	JAL		GTE_SetFogColor
	ADDU	$6, $0, $0

	LW		$4, GTE_ScreenWidth				# Reset GTE offset
	LW		$5, GTE_ScreenHeight
	SRA		$4, $4, 0x1
	JAL		GTE_SetOffset
	SRA		$5, $5, 0x1

	LW		$31, 0x10($29)
	ADDIU	$29, $29, 0x18
	JR		$31
	NOP
	.end	GTE_Init

###############################################################################

	.globl	GTE_SetOffset
	.ent	GTE_SetOffset
GTE_SetOffset:
	SLL		$4, $4, 0x10					# Make 16.16 fixed point
	SLL		$5, $5, 0x10

	CTC2	$4, $24							# GTE.OFX = (param1 << 16) (x offset)
	CTC2	$5, $25							# GTE.OFY = (param2 << 16) (y offset)

	JR		$31
	NOP
	.end	GTE_SetOffset

###############################################################################

	.ent	GTE_Enable
GTE_Enable:
	SW		$31, TmpRAStore1
	JAL		PatchExceptionHandler
	NOP
	LW		$31, TmpRAStore1
	NOP
	MFC0	$2, $12							# Enable the GTE
	LI		$3, 0x40000000
	OR		$2, $2, $3
	MTC0	$2, $12
	NOP

	ADDIU	$8, $0, 0x155					# GTE.ZSF3 = 0x155
	CTC2	$8, $29							# This is for Z average 3
	NOP

	ADDIU	$8, $0, 0x100					# GTE.ZSF4 = 0x100
	CTC2	$8, $30							# This is for Z average 4
	NOP

	ADDIU	$8, $0, 0x2E8
	CTC2	$8, $26							# GTE.H = 0x600 (Viewplane distance)
	NOP

	ADDIU	$8, $0, 0xEF9E
	CTC2	$8, $27							# GTE.DQA = 0xEF9E (fogging plane)
	NOP

	LUI		$8, 0x140
	CTC2	$8, $28							# GTE.DQB = 0x140 (fogging plane)
	NOP

	CTC2	$0, $24							# GTE.OFX = 0 (x offset)
	CTC2	$0, $25							# GTE.OFY = 0 (y offset)
	NOP

	JR		$31
	NOP
	.end	GTE_Enable

###############################################################################

	.globl	GTE_SetFogColor
	.ent	GTE_SetFogColor
GTE_SetFogColor:
	SLL		$4, $4, 0x4
	SLL		$5, $5, 0x4
	SLL		$6, $6, 0x4
	CTC2	$4, $21							# GTE.RFC = (param1 << 4); (fog color)
	CTC2	$5, $22							# GTE.GFC = (param2 << 4); (fog color)
	CTC2	$6, $23							# GTE.BFC = (param3 << 4); (fog color)
	JR		$31
	NOP
	.end	GTE_SetFogColor

###############################################################################

	.ent	PatchExceptionHandler
PatchExceptionHandler:
	SW		$31, TmpRAStore2
	JAL		EnterCriticalSection			# Don't want people running our code
	NOP										# whilst we patch it

	ADDIU	$10, $0, 0xB0
	JALR	$31, $10						# Get C0 Table
	ADDIU	$9, $0, 0x56
	LW		$2, 0x18($2)					# Get Exception handler vector

	LA		$10, ExceptionHandlerStart		# Then patch it
	LA		$9, ExceptionHandlerEnd
PatchItLopp:
	LW		$3, 0x0($10)					# Copy code over exception handler
	ADDIU	$10, $10, 0x4
	ADDIU	$2, $2, 0x4
	BNE		$10, $9, PatchItLopp
	SW		$3, -0x4($2)

	JAL		FlushCache						# Since we've changed some code, we must
	NOP										# flush the I-cache

	JAL		ExitCriticalSection				# OK to run it now
	NOP
	LW		$31, TmpRAStore2
	NOP
	JR		$31
	NOP
	.end	PatchExceptionHandler

###############################################################################

# This is an event handler patch - we don't care about at register ($1) usage here
	.set	noat
ExceptionHandlerStart:
	NOP
	NOP
	ADDIU	$26, $0, 0x100
	LW		$26, 0x8($26)
	NOP
	LW		$26, 0x0($26)
	NOP
	ADDI	$26, $26, 0x8
	SW		$1, 0x4($26)
	SW		$2, 0x8($26)
	SW		$3, 0xC($26)
	SW		$31, 0x7C($26)
	MFC0	$2, $13
	NOP
ExceptionHandlerEnd:
# Back to the real world
# Actually, we won't reset the noat thing, cos we're accessing $1 on COP2

###############################################################################

	.globl	GTE_MatrixSetIdentity			# GTE_MatrixSetIdentity(MATRIX *matrix);
	.ent	GTE_MatrixSetIdentity
GTE_MatrixSetIdentity:
	LI		$2, 0x1000						# 4.12 elements - this is 1.0

	SW		$2, ($4)						# Fill it all in with the right numbers
	SW		$0, 0x4($4)
	SW		$2, 0x8($4)
	SW		$0, 0xC($4)
	SW		$2, 0x10($4)
	SW		$0, 0x14($4)
	SW		$0, 0x18($4)
	SW		$0, 0x1C($4)

	J		$31
	NOP
	.end	GTE_MatrixSetIdentity

###############################################################################

	.globl	GTE_SV3Scale					# GTE_SV3Scale(SVECTOR3D *vectorOut,
	.ent	GTE_SV3Scale					#              SVECTOR3D *vectorIn,
GTE_SV3Scale:								#              PsxUInt16 scale,
											#              PsxUInt32 quantity);
	MTC2	$6, $8							# GTE.IR0 = scale

AnotherSV3Scale:
	BEQ		$7, $0, DoneSV3Scale
	NOP
	LH		$8, ($5)						# vectorIn.x >------------+
	LH		$9, 0x2($5)						# vectorIn.y >------------+-+
	LH		$10, 0x4($5)					# vectorIn.z >------------+-+-+
											#                         | | |
	MTC2	$8, $9							# GTE.IR3 = vectorIn.x <--+ | |
	MTC2	$9, $10							# GTE.IR2 = vectorIn.y <----+ |
	MTC2	$10, $11						# GTE.IR1 = vectorIn.z <------+

	NOP										# Wait for it to settle in the GTE
	NOP										#

	C2		0x198003D						# Clock the result in the GTE

	MFC2	$8, $9							# GTE.IR1 >----------------+
	MFC2	$9, $10							# GTE.IR2 >----------------+-+	
	MFC2	$10, $11						# GTE.IR3 >----------------+-+-+
											#                          | | |
	SH		$8, ($4)						# vectorOut.x = GTE.IR1 <--+ | |
	SH		$9, 0x2($4)						# vectorOut.y = GTE.IR2 <----+ |
	SH		$10, 0x4($4)					# vectorOut.z = GTE.IR3 <------+

	ADDIU	$4, $4, 0x8						# Next destination vector
	ADDIU	$5, $5, 0x8						# Next source vector

	J		AnotherSV3Scale					# Another one
	ADDIU	$7, $7, 0xFFFF

DoneSV3Scale:
	JR		$31								# Back to the caller
	NOP										#
	.end	GTE_SV3Scale

###############################################################################

	.globl	GTE_SV3XForm					# GTE_SV3XForm(SVECTOR3D *vectOut,
	.ent	GTE_SV3XForm					#              SVECTOR3D *vectIn,
GTE_SV3XForm:								#              MATRIX *mat,
											#              PsxUInt32 quantity);
	LW		$8, ($6)						# m[0][1] m[0][0] >---------------+
	LW		$9, 0x4($6)						# m[1][0] m[0][2] >---------------+-+
	LW		$10, 0x8($6)					# m[1][2] m[1][1] >---------------+-+-+
	LW		$11, 0xC($6)					# m[2][1] m[2][0] >---------------+-+-+-+
	LW		$12, 0x10($6)					# m[2][2] >-----------------------+-+-+-+-+
											#                                 | | | | |
	CTC2	$8, $0							# GTE.R11R12 = m[0][1] m[0][0] <--+ | | | |
	CTC2	$9, $1							# GTE.R13R21 = m[1][0] m[0][2] <----+ | | |
	CTC2	$10, $2							# GTE.R22R23 = m[1][2] m[1][1] <------+ | |
	CTC2	$11, $3							# GTE.R31R32 = m[2][1] m[2][0] <--------+ |
	CTC2	$12, $4							# GTE.R33 = m[2][2] <---------------------+

	LW		$15, 0x14($6)					# Get offset X
	LW		$24, 0x18($6)					# Get offset Y
	LW		$25, 0x1C($6)					# Get offset Z

AnotherSV3XForm:
	BEQ		$7, $0, DoneSV3XForm
	NOP

	LWC2	$0, ($5)						# Load short vector
	LWC2	$1, 0x4($5)

	NOP										# Wait for it to settle in the GTE
	NOP

	C2		0x486012						# Clock the result in the GTE

	MFC2	$8, $9							# GTE.IR1 >--------------+
	MFC2	$9, $10							# GTE.IR2 >--------------+-+
	MFC2	$10, $11						# GTE.IR3 >--------------+-+-+
											#                        | | |
	ADDU	$8, $8, $15						# translate.x >----------O | |
	ADDU	$9, $9, $24						# translate.y >----------+-O |
	ADDU	$10, $10, $25					# translate.z >----------+-+-O
											#                        | | |
	SH		$8, ($4)						# vectOut.x = GTE.IR1 <--+ | |
	SH		$9, 0x2($4)						# vectOut.y = GTE.IR2 <----+ |
	SH		$10, 0x4($4)					# vectOut.z = GTE.IR3 <------+

	ADDIU	$4, $4, 0x8						# Next destination vector
	ADDIU	$5, $5, 0x8						# Next source vector

	J		AnotherSV3XForm					# Another one
	ADDIU	$7, $7, 0xFFFF

DoneSV3XForm:
	JR		$31
	NOP
	.end	GTE_SV3XForm

###############################################################################

	.globl	GTE_V3XForm						# GTE_V3XForm(VECTOR3D *vectOut,
	.ent	GTE_V3XForm						#             VECTOR3D *vectIn,
GTE_V3XForm:								#             MATRIX *mat);
	LW		$8, ($6)						# m[0][1] m[0][0] >---------------+
	LW		$9, 0x4($6)						# m[1][0] m[0][2] >---------------+-+
	LW		$10, 0x8($6)					# m[1][2] m[1][1] >---------------+-+-+
	LW		$11, 0xC($6)					# m[2][1] m[2][0] >---------------+-+-+-+
	LW		$12, 0x10($6)					# m[2][2] >-----------------------+-+-+-+-+
											#                                 | | | | |
	CTC2	$8, $0							# GTE.R11R12 = m[0][1] m[0][0] <--+ | | | |
	CTC2	$9, $1							# GTE.R13R21 = m[1][0] m[0][2] <----+ | | |
	CTC2	$10, $2							# GTE.R22R23 = m[1][2] m[1][1] <------+ | |
	CTC2	$11, $3							# GTE.R31R32 = m[2][1] m[2][0] <--------+ |
	CTC2	$12, $4							# GTE.R33 = m[2][2] <---------------------+

	LW		$15, 0x14($6)					# Get offset X
	LW		$24, 0x18($6)					# Get offset Y
	LW		$25, 0x1C($6)					# Get offset Z

AnotherV3XForm:
	BEQ		$7, $0, DoneV3XForm
	NOP

	LW		$8, ($5)						# vectorIn.x >--+
	LW		$9, 0x4($5)						# vectorIn.y >--+-+
	LW		$10, 0x8($5)					# vectorIn.z >--+-+-+
											#               | | |
	SRA		$11, $8, 0xF					# Int part <----+ | | >--------+
	ANDI	$8, $8, 0x7FFF					# Frac part <---+ | | >--------+-----+
											#                 | |          |     |
	SRA		$12, $9, 0xF					# Int part <------+ | >--------+-+   |
	ANDI	$9, $9, 0x7FFF					# Frac part <-----+ | >--------+-+---+-+
											#                   |          | |   | |
	SRA		$13, $10, 0xF					# Int part <--------+ >--------+-+---+-+-+
	ANDI	$10, $10, 0x7FFF				# Frac part <-------+ >--------+-+-+ | | |
											#                              | | | | | |
	MTC2	$11, $9							# GTE.IR1 = int(vectorIn.x) <--+ | | | | |
	MTC2	$12, $10						# GTE.IR2 = int(vectorIn.y) <----+ | | | |
	MTC2	$13, $11						# GTE.IR3 = int(vectorIn.z) <------+ | | |
											#                                    | | |
	NOP										# Wait for it to settle in the GTE   | | |
	NOP										#                                    | | |
											#                                    | | |
	C2		0x41E012						# Clock the result (integer part)    | | |
											#                                    | | |
	MFC2	$11, $25						# Int result.x = GTE.MAC1            | | |
	MFC2	$12, $26						# Int result.y = GTE.MAC2            | | |
	MFC2	$13, $27						# Int result.z = GTE.MAC3            | | |
											#                                    | | |
	MTC2	$8, $9							# GTE.IR1 = frac(vectorIn.x) <-------+ | |
	MTC2	$9, $10							# GTE.IR2 = frac(vectorIn.y) <---------+ |
	MTC2	$10, $11						# GTE.IR3 = frac(vectorIn.z) <-----------+

	NOP										# Wait for it to settle in the GTE
	NOP

	C2		0x49E012						# Clock the result (fractional part)

	SLL		$11, $11, 0x3					# Shift integer part into place (shift 3
	SLL		$12, $12, 0x3					# because 15-12 = 3).  15 is shift into place.
	SLL		$13, $13, 0x3					# 12 is 20.12 bit, 3 is what's left to do.

	MFC2	$8, $25							# Frac result.x = GTE.MAC1
	MFC2	$9, $26							# Frac result.y = GTE.MAC2
	MFC2	$10, $27						# Frac result.z = GTE.MAC3

	ADDU	$8, $8, $11						# Re-assemble!!!
	ADDU	$9, $9, $12
	ADDU	$10, $10, $13

	ADDU	$8, $8, $15						# Add offset
	ADDU	$9, $9, $24
	ADDU	$10, $10, $25

	SW		$8, ($4)						# Store result
	SW		$9, 0x4($4)
	SW		$10, 0x8($4)

	ADDIU	$4, $4, 0x10					# Next destination vector
	ADDIU	$5, $5, 0x10					# Next source vector

	J		AnotherV3XForm					# Another one
	ADDIU	$7, $7, 0xFFFF

DoneV3XForm:
	JR		$31
	NOP
	.end	GTE_V3XForm

###############################################################################

	.globl	GTE_MatMul						# GTE_MatMul(MATRIX *matOut,
	.ent	GTE_MatMul						#            MATRIX *matIn1,
GTE_MatMul:									#            MATRIX *matIn2);
	LI		$3, 0xFFFF0000

	LW		$8, ($6)						# m[0][1] m[0][0] >---------------+
	LW		$9, 0x4($6)						# m[1][0] m[0][2] >---------------+-+
	LW		$10, 0x8($6)					# m[1][2] m[1][1] >---------------+-+-+
	LW		$11, 0xC($6)					# m[2][1] m[2][0] >---------------+-+-+-+
	LW		$12, 0x10($6)					# m[2][2] >-----------------------+-+-+-+-+
											#                                 | | | | |
	CTC2	$8, $0							# GTE.R11R12 = m[0][1] m[0][0] <--+ | | | |
	CTC2	$9, $1							# GTE.R13R21 = m[1][0] m[0][2] <----+ | | |
	CTC2	$10, $2							# GTE.R22R23 = m[1][2] m[1][1] <------+ | |
	CTC2	$11, $3							# GTE.R31R32 = m[2][1] m[2][0] <--------+ |
	CTC2	$12, $4							# GTE.R33 = m[2][2] <---------------------+

	LHU		$8, ($5)						# Load first vector of matrix matIn1
	LW		$9, 0x4($5)
	LW		$10, 0xC($5)
	AND		$9, $9, $3
	OR		$8, $8, $9

	MTC2	$8, $0							# Plug first vector into the GTE
	MTC2	$10, $1

	NOP										# Wait for it to settle
	NOP

	C2		0x486012						# And multiply the first column of the matrix

	LHU		$8, 0x2($5)						# Load second vector of matrix matIn1
	LW		$9, 0x8($5)
	LH		$10, 0xE($5)
	SLL		$9, $9, 0x10
	OR		$8, $8, $9

	MFC2	$11, $9							# Get first result
	MFC2	$12, $10
	MFC2	$13, $11

	MTC2	$8, $0							# Plug second vector into the GTE
	MTC2	$10, $1

	NOP										# Wait for it to settle
	NOP

	C2		0x486012						# Multiply the second column of the matrix

	LHU		$8, 0x4($5)						# Load third vector of matrix matIn1
	LW		$9, 0x8($5)
	LW		$10, 0x10($5)
	AND		$9, $9, $3
	OR		$8, $8, $9

	MFC2	$14, $9							# Get second result
	MFC2	$15, $10
	MFC2	$24, $11

	MTC2	$8, $0							# Plug third vector into the GTE
	MTC2	$10, $1

	NOP										# Wait for it to settle
	NOP

	C2		0x486012

	ANDI	$11, $11, 0xFFFF				# Assemble and write back the result
	SLL		$14, $14, 0x10
	OR		$14, $14, $11
	SW		$14, ($4)

	ANDI	$13, $13, 0xFFFF
	SLL		$24, $24, 0x10
	OR		$24, $24, $13
	SW		$24, 0xC($4)

	MFC2	$8, $9							# Get third result
	MFC2	$9, $10

	ANDI	$8, $8, 0xFFFF					# Assemble and write back the result
	SLL		$12, $12, 0x10
	OR		$8, $8, $12
	SW		$8, 0x4($4)

	ANDI	$15, $15, 0xFFFF
	SLL		$9, $9, 0x10
	OR		$9, $9, $15
	SW		$9, 0x8($4)

	SWC2	$11, 0x10($4)					# This one comes straight from the GTE

	JR		$31
	NOP
	.end	GTE_MatMul

###############################################################################

	.globl	GTE_IsPolyFront					# GTE_IsPolyFront(SVECTOR2D *vert0,
	.ent	GTE_IsPolyFront					#                 SVECTOR2D *vert1,
GTE_IsPolyFront:							#                 SVECTOR2D *vert2);
	LWC2	$12, ($4)						# Load X and Y of vert 0
	LWC2	$13, ($5)						# Load X and Y of vert 1
	LWC2	$14, ($6)						# Load X and Y of vert 2

	NOP										# Time to settle
	NOP

	C2		0x1400006						# Clock the result

	MFC2	$2, $24							# Get the result to return

	JR		$31
	NOP
	.end	GTE_IsPolyFront

###############################################################################

	.globl	GTE_ParallelProject				# GTE_ParallelProject(SVECTOR2D *vertOut,
	.ent	GTE_ParallelProject				#                     SVECTOR3D *vertIn,
GTE_ParallelProject:						#                     PsxUInt32 quantity);
	LW		$10, GTE_ScreenWidth			# This is the screen size
	LW		$11, GTE_ScreenHeight

	SRA		$8, $10, 0x1					# And these are the offset
	SRA		$9, $11, 0x1

ParProjAnotherVertex:
	BEQ		$6, $0, DoneParProj
	NOP
	LH		$2, ($5)
	LH		$3, 0x2($5)

	MULT	$2, $10							# vertIn.x * scrWidth >------------------+
	NOP										#                                        |
	MFLO	$2								# vertIn.x * scrWidth <------------------O
											#                                        |
	MULT	$3, $11							# vertIn.y * scrHeight >-----------------+-+
											#                                        | |
	SRA		$2, $2, 0xC						# (vertIn.x * scrWidth) >> 12 <----------O |
	ADDU	$2, $2, $8						# This is the parallel projected value <-O |
	SH		$2, ($4)						# Store the projected X <----------------+ |
											#                                          |
	MFLO	$3								# vertIn.y * scrHeight <-------------------O
											#                                          |
	ADDU	$5, $5, 0x8						# Next source vertex                       |
											#                                          |
	SRA		$3, $3, 0xC						# (vertIn.y * scrHeight) >> 12 <-----------O
	ADDU	$3, $3, $9						# This is the parallel projected value <---O
	SH		$3, 0x2($4)						# Store the projected Y <------------------+

	ADDU	$4, $4, 0x4						# Next destination vertex

	J		ParProjAnotherVertex			# Another one
	ADDIU	$6, $6, 0xFFFF
	
DoneParProj:
	JR		$31
	NOP
	.end	GTE_ParallelProject

###############################################################################

	.globl	GTE_PerspectiveProject			# GTE_PerspectiveProject(SVECTOR2D *vertOut,
	.ent	GTE_PerspectiveProject			#                        SVECTOR3D *vertIn,
GTE_PerspectiveProject:						#                        PsxUInt32 quantity);
	LI		$2, 0x1000						# 4.12 elements - this is 1.0

	CTC2	$2, $0							# Upload identity matrix
	CTC2	$0, $1
	CTC2	$2, $2
	CTC2	$0, $3
	CTC2	$2, $4

	CTC2	$0, $5							# No translation component
	CTC2	$0, $6
	CTC2	$0, $7

	LW		$10, GTE_ScreenWidth			# This is the screen size
	LW		$11, GTE_ScreenHeight

	SRA		$8, $10, 0x1					# And these are the offset
	SRA		$9, $11, 0x1

PerspProjAnotherVertex:
	BEQ		$6, $0, DonePerspProj
	NOP
	LW		$2, ($5)
	LW		$3, 0x4($5)
	MTC2	$2, $0
	MTC2	$3, $1

	C2		0x180001						# Project it

	MFC2	$2, $14							# Get XY from GTE
	NOP										# This NOP is vital

# It all gets a bit hacky here (touchy feely bit). What about screen size?

	SRA		$3, $2, 0x10					# $3 is Y
	SLL		$2, $2, 0x10
	SRA		$2, $2, 0x10					# $2 is X

	SH		$2, ($4)						# Store the projected X
	SH		$3, 0x2($4)						# Store the projected Y

	ADDU	$4, $4, 0x4						# Next destination vertex
	ADDU	$5, $5, 0x8						# Next source vertex

	J		PerspProjAnotherVertex			# Another one
	ADDIU	$6, $6, 0xFFFF
	
DonePerspProj:
	JR		$31
	NOP
	.end	GTE_PerspectiveProject

###############################################################################

	.globl	GTE_AverageZ3					# PsxUInt32
	.ent	GTE_AverageZ3					# GTE_AverageZ3(PsxInt32 z1, PsxInt32 z2,
GTE_AverageZ3:								#               PsxInt32 z3)
	MTC2	$4, $17							# {
	MTC2	$5, $18							#     /* Upload the three Z values */
	MTC2	$6, $19							#
	NOP										#
	NOP										#
	C2		0x158002D						#     /* Do the operation */
											#
	MFC2	$2, $7							#     /* Get the result */
	JR		$31								#
	NOP										#
	.end	GTE_AverageZ3					# }

###############################################################################

	.globl	GTE_AverageZ4					# PsxUInt32
	.ent	GTE_AverageZ4					# GTE_AverageZ4(PsxInt32 z1, PsxInt32 z2,
GTE_AverageZ4:								#               PsxInt32 z3, PsxInt32 z4)
	MTC2	$4, $16							# {
	MTC2	$5, $17							#     /* Upload the four Z values */
	MTC2	$6, $18							#
	MTC2	$7, $19							#
	NOP										#
	NOP										#
	C2		0x168002E						#     /* Do the operation */
											#
	MFC2	$2, $7							#     /* Get the result */
	JR		$31								#
	NOP										#
	.end	GTE_AverageZ4					# }

###############################################################################

	.globl	GTE_Sin							# PsxInt16 GTE_Sin(PsxInt16 angle);
	.ent	GTE_Sin
GTE_Sin:
	ADD		$4, $4, 0x8						# Round input
	SRL		$4, $4, 0x3						# Create table index
	ANDI	$4, $4, 0x1FE					# This is the table index (multiple of two)

	LA		$2, SineTab
	ADD		$2, $2, $4						# We can pull the result from here

	LH		$2, ($2)

	JR		$31
	NOP
	.end	GTE_Sin



###############################################################################

	.globl	GTE_Cos							# PsxInt16 GTE_Cos(PsxInt16 angle);
	.ent	GTE_Cos
GTE_Cos:
	ADD		$4, $4, 0x408					# Convert phase and round input
	SRL		$4, $4, 0x3						# Create table index
	ANDI	$4, $4, 0x1FE					# This is the table index (multiple of two)

	LA		$2, SineTab
	ADD		$2, $2, $4						# We can pull the result from here

	LH		$2, ($2)

	JR		$31
	NOP
	.end	GTE_Cos

###############################################################################
