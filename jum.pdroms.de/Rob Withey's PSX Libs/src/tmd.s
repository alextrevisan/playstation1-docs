	.rdata
	.align	2

###############################################################################

TmdPrimJumpTab:
	.word	Prim20							# 0x20 - Fl Untx Tri
	.word	UnHandledPrim					# 0x21 - Fl Untx Tri
	.word	Prim20							# 0x22 - Fl Untx Op Tri
	.word	UnHandledPrim					# 0x23 - Fl Untx Op Tri
	.word	Prim24							# 0x24 - Fl Tex Tri
	.word	UnHandledPrim					# 0x25 - Fl Tex Tri
	.word	Prim24							# 0x26 - Fl Tex Op Tri
	.word	UnHandledPrim					# 0x27 - Fl Tex Op Tri
	.word	Prim28							# 0x28 - Fl Untx Lit Tri
	.word	UnHandledPrim					# 0x29 - Fl Untx Lit Tri
	.word	Prim28							# 0x2A - Fl Untx Op Lit Tri
	.word	UnHandledPrim					# 0x2B - Fl Untx Op Lit Tri
	.word	Prim2C							# 0x2C - Fl Tex Lit Tri
	.word	UnHandledPrim					# 0x2D - Fl Tex Lit Tri
	.word	Prim2C							# 0x2E - Fl Tex Lit Op Tri
	.word	UnHandledPrim					# 0x2F - Fl Tex Lit Op Tri
	.word	Prim30							# 0x30 - Sm Untx Tri
	.word	UnHandledPrim					# 0x31 - Sm Untx Tri
	.word	Prim30							# 0x32 - Sm Untx Op Tri
	.word	UnHandledPrim					# 0x33 - Sm Untx Op Tri
	.word	Prim34							# 0x34 - Sm Tex Tri
	.word	UnHandledPrim					# 0x35 - Sm Tex Tri
	.word	Prim34							# 0x36 - Sm Tex Op Tri
	.word	UnHandledPrim					# 0x37 - Sm Tex Op Tri
	.word	Prim38							# 0x38 - Sm Untx Lit Tri
	.word	UnHandledPrim					# 0x39 - Sm Untx Lit Tri
	.word	Prim38							# 0x3A - Sm Untx Op Lit Tri
	.word	UnHandledPrim					# 0x3B - Sm Untx Op Lit Tri
	.word	Prim3C							# 0x3C - Sm Tex Lit Tri
	.word	UnHandledPrim					# 0x3D - Sm Tex Lit Tri
	.word	Prim3C							# 0x3E - Sm Tex Lit Op Tri
	.word	UnHandledPrim					# 0x3F - Sm Tex Lit Op Tri

	.word	Prim40							# 0x40 - Fl Untx Line
	.word	UnHandledPrim					# 0x41 - Invalid Prim
	.word	Prim40							# 0x42 - Fl Untx Op Line
	.word	UnHandledPrim					# 0x43 - Invalid Prim
	.word	UnHandledPrim					# 0x44 - Invalid Prim
	.word	UnHandledPrim					# 0x45 - Invalid Prim
	.word	UnHandledPrim					# 0x46 - Invalid Prim
	.word	UnHandledPrim					# 0x47 - Invalid Prim
	.word	UnHandledPrim					# 0x48 - Invalid Prim
	.word	UnHandledPrim					# 0x49 - Invalid Prim
	.word	UnHandledPrim					# 0x4A - Invalid Prim
	.word	UnHandledPrim					# 0x4B - Invalid Prim
	.word	UnHandledPrim					# 0x4C - Invalid Prim
	.word	UnHandledPrim					# 0x4D - Invalid Prim
	.word	UnHandledPrim					# 0x4E - Invalid Prim
	.word	UnHandledPrim					# 0x4F - Invalid Prim
	.word	Prim50							# 0x50 - Sm Untx Line
	.word	UnHandledPrim					# 0x51 - Invalid Prim
	.word	Prim50							# 0x52 - Sm Untx Op Line
	.word	UnHandledPrim					# 0x53 - Invalid Prim
	.word	UnHandledPrim					# 0x54 - Invalid Prim
	.word	UnHandledPrim					# 0x55 - Invalid Prim
	.word	UnHandledPrim					# 0x56 - Invalid Prim
	.word	UnHandledPrim					# 0x57 - Invalid Prim
	.word	UnHandledPrim					# 0x58 - Invalid Prim
	.word	UnHandledPrim					# 0x59 - Invalid Prim
	.word	UnHandledPrim					# 0x5A - Invalid Prim
	.word	UnHandledPrim					# 0x5B - Invalid Prim
	.word	UnHandledPrim					# 0x5C - Invalid Prim
	.word	UnHandledPrim					# 0x5D - Invalid Prim
	.word	UnHandledPrim					# 0x5E - Invalid Prim
	.word	UnHandledPrim					# 0x5F - Invalid Prim

	.word	UnHandledPrim					# 0x60 - Invalid Prim
	.word	UnHandledPrim					# 0x61 - Invalid Prim
	.word	UnHandledPrim					# 0x62 - Invalid Prim
	.word	UnHandledPrim					# 0x63 - Invalid Prim
	.word	UnHandledPrim					# 0x64 - Free Size Sprite
	.word	UnHandledPrim					# 0x65 - Invalid Prim
	.word	UnHandledPrim					# 0x66 - Free Size Op Sprite
	.word	UnHandledPrim					# 0x67 - Invalid Prim
	.word	UnHandledPrim					# 0x68 - Invalid Prim
	.word	UnHandledPrim					# 0x69 - Invalid Prim
	.word	UnHandledPrim					# 0x6A - Invalid Prim
	.word	UnHandledPrim					# 0x6B - Invalid Prim
	.word	UnHandledPrim					# 0x6C - 1x1 Sprite
	.word	UnHandledPrim					# 0x6D - Invalid Prim
	.word	UnHandledPrim					# 0x6E - 1x1 Op Sprite
	.word	UnHandledPrim					# 0x6F - Invalid Prim
	.word	UnHandledPrim					# 0x70 - Invalid Prim
	.word	UnHandledPrim					# 0x71 - Invalid Prim
	.word	UnHandledPrim					# 0x72 - Invalid Prim
	.word	UnHandledPrim					# 0x73 - Invalid Prim
	.word	UnHandledPrim					# 0x74 - 8x8 Sprite
	.word	UnHandledPrim					# 0x75 - Inavlid Prim
	.word	UnHandledPrim					# 0x76 - 8x8 Op Sprite
	.word	UnHandledPrim					# 0x77 - Inavlid Prim
	.word	UnHandledPrim					# 0x78 - Invalid Prim
	.word	UnHandledPrim					# 0x79 - Invalid Prim
	.word	UnHandledPrim					# 0x7A - Invalid Prim
	.word	UnHandledPrim					# 0x7B - Invalid Prim
	.word	UnHandledPrim					# 0x7C - 16x16 Sprite
	.word	UnHandledPrim					# 0x7D - Invalid Prim
	.word	UnHandledPrim					# 0x7E - 16x16 Op Sprite
	.word	UnHandledPrim					# 0x7F - Invalid Prim

string:
	.ascii	"Unhandled primitive %08x\n\000"

	.align	4

	.lcomm	PrimBuffer, 48					# 12 words
	.lcomm	cameraVert, 2000*8				# SVECTOR3D CameraVerts[2000];
	.lcomm	deviceVert, 2000*4				# SVECTOR2D DeviceVerts[2000];

###############################################################################

	.text
	.set	noreorder
	.align	4

###############################################################################

	.globl	TMD_FixUp						# TMDHEADER *TMD_FixUp(TMDHEADER *tmd)
	.ent	TMD_FixUp						# {
TMD_FixUp:									#     PsxUInt32 numObjs;
	LW		$2, 0x0($4)						#     if (tmd->id != 0x41)
	LI		$3, 0x41						#     {
	BNE		$2, $3, ExitTMD_FixUp			#         return(NULL);
	ADD		$2, $0, $0						#     }
											#
	LW		$3, 0x4($4)						#     if (tmd->flags & TMDHDR_FIXP)
	NOP										#     {
	ANDI	$2, $3, 0x1						#         return(tmd);
	BNE		$2, $0, ExitTMD_FixUp			#     }
	ADD		$2, $4, $0						#
											#
	ORI		$3, $3, 0x1						#     tmd->flags |= TMDHDR_FIXP;
	SW		$3, 0x4($4)						#
											#
	LW		$8, 0x8($4)						#     numObjs = tmd->numObjects;
	ADDI	$9, $4, 0xC						#     object = (TMDOBJECT *)(tmd + 1);
FixUpAnotherObject:							#
	BEQ		$8, $0, ExitTMD_FixUp			#     while (numObjs--)
	ADD		$2, $4, $0						#     {
											#         /* Fix it up */
	LW		$10, 0x0($9)					#
	LW		$11, 0x8($9)					#         /* object->vertexAddr += object; */
	LW		$12, 0x10($9)					#         /* object->normalAddr += object; */
	LW		$13, 0xC($9)					#         /* object->primitiveAddr += object; */
											#
	ADD		$10, $10, $9					#
	ADD		$11, $11, $9					#
	ADD		$12, $12, $9					#
	SLL		$13, $13, 0x2					#
	ADDI	$8, $8, 0xFFFF					#
											#
	SW		$10, 0x0($9)					#
	SW		$11, 0x8($9)					#
	SW		$12, 0x10($9)					#         object = (TMDOBJECT *)object->normalAddr +
											#                               object->numNormals;
	J		FixUpAnotherObject				#     }
	ADD		$9, $11, $13					#
ExitTMD_FixUp:								#
	JR		$31								#     return(tmd);
	NOP										#
	.end	TMD_FixUp						# }
	
###############################################################################

	.globl	TMD_Render						# TMDHEADER *
	.ent	TMD_Render						# TMD_Render(GsOT *orderTable, TMDHEADER *tmd,
TMD_Render:									#            MATRIX *ltm, PsxInt32 persp)
	ADDI	$29, $29, 0xFFE8				# {
	SW		$31, 0x0($29)					#
	SW		$16, 0x4($29)					#
	SW		$17, 0x8($29)					#
	SW		$18, 0xC($29)					#
	SW		$19, 0x10($29)					#
	SW		$20, 0x14($29)					#
											#
	ADD		$16, $4, $0						#     /* $16 = orderTable */
	ADD		$17, $5, $0						#     /* $17 = tmd */
	ADD		$18, $6, $0						#     /* $18 = ltm */
	ADD		$19, $7, $0						#     /* $19 = persp, numPrims */
	ADDI	$20, $17, 0xC					#     /* $20 = object, primheader */
											#
	LW		$2, 0x0($5)						#     if (tmd->id != 0x41)
	LW		$8, 0x4($5)						#     {
	LI		$3, 0x41						#         return(NULL);
	BNE		$2, $3, ExitTMD_Render			#     }
	ADD		$2, $0, $0						#
											#     if (!(tmd->flags & TMDHDR_FIXP))
	ANDI	$2, $8, 0x1						#     {
	BNE		$2, $0, TMDAlreadyFixedUp		#         TMD_FixUp(tmd);
	NOP										#     }
											#
	JAL		TMD_FixUp						#     
	ADD		$4, $5, $0						#
											#
TMDAlreadyFixedUp:							#
	LA		$4, cameraVert					#     GTE_SV3XForm(cameraVert,
	LW		$5, 0x0($20)					#                  (SVECTOR3D *)object->vertexAddr,
	LW		$7, 0x4($20)					#                  ltm, object->numVertices);
	JAL		GTE_SV3XForm					#
	ADD		$6, $18, $0						#
											#
	LA		$2, GTE_ParallelProject			#     /* Project them using correct method */
	BEQ		$19, $0, DoParallelProject		#     if (persp)
	NOP										#     {
	LA		$2, GTE_PerspectiveProject		#         GTE_PerspectiveProject(deviceVert, cameraVert,
											#                                object->numVertices);
DoParallelProject:							#     }
	LA		$4, deviceVert					#     else
	LA		$5, cameraVert					#     {
	LW		$6, 0x4($20)					#         GTE_ParallelProject(deviceVert, cameraVert,
	JALR	$31, $2							#                             object->numVertices);
	NOP										#     }
											#
	LW		$19, 0x14($20)					#     numPrims = object->numPrimitives;
	LW		$20, 0x10($20)					#     prim = object->primitiveAddr;
RenderAnotherPrim:							#
	BEQ		$19, $0, ExitTMD_Render			#     while (numPrims--)
	ADD		$2, $17, $0						#     {
											#
	LW		$2, 0x0($20)					#         PsxUInt32 primAddr = prim;
	ADDI	$19, $19, 0xFFFF				#         PsxUInt32 header = prim[0];
	ADD		$5, $20, $0						#
	ADDI	$20, $20, 0x4					#
	SRL		$3, $2, 0x6						#
	ANDI	$3, $3, 0x03FC					#         prim += (header >> 8) & 0xFF;
	BLTZ	$2, RenderAnotherPrim			#         if (header < 0x80000000)
	ADD		$20, $20, $3					#         {
											#             PsxUInt32 index = header >> 24;
	SRL		$2, $2, 0x16					#             index -= 0x20;
	ANDI	$3, $2, 0x03FC					#             if (index >= 0)
	SUB		$3, $3, 0x0080					#             {
	BLTZ	$2, RenderAnotherPrim			#                 FnPoint fn = TmdPrimJumpTab[index);
	NOP										#                 fn(primAddr);
	LA		$2, TmdPrimJumpTab				#             }
	ADD		$2, $2, $3						#         }
	LW		$2, 0x0($2)						#     }
	NOP										#
	JALR	$31, $2							#
	ADD		$4, $16, $0						#
	J		RenderAnotherPrim				#
	NOP										#
											#
ExitTMD_Render:								#
	ADD		$2, $17, $0						#     return (tmd);
	LW		$31, 0x0($29)					#
	LW		$16, 0x4($29)					#
	LW		$17, 0x8($29)					#
	LW		$18, 0xC($29)					#
	LW		$19, 0x10($29)					#
	LW		$20, 0x14($29)					#
	ADDI	$29, $29, 0x18					#
	JR		$31								#
	NOP										#
	.end	TMD_Render						# }

###############################################################################

	.ent	UnHandledPrim					# void UnHandledPrim(GsOT orderTable,
UnHandledPrim:								#                    PsxUInt32 *prim)
	ADDI	$29, $29, 0xFFEC				# {
	SW		$31, 0x10($29)					#
											#
	LA		$4, string						#     printf("Unhandled primitive %08x\n",
	JAL		printf							#            prim[0]);
	LW		$5, 0x0($5)						#
											#
	LW		$31, 0x10($29)					#
	ADDI	$29, $29, 0x14					#
											#
	JR		$31								#
	NOP										#
	.end	UnHandledPrim					# }

###############################################################################

	.ent	Prim20							# void Prim20(GsOT orderTable, PsxUInt32 *prim)
Prim20:										# {
	ADDI	$29, $29, 0xFFF8				#
	SW		$31, 0x0($29)					#
	SW		$4, 0x4($29)					#     if (((prim[0] >> 16) & 0xFF) != 0)
	LW		$2, 0x0($5)						#     {
	LA		$8, PrimBuffer					#
	LA		$12, deviceVert					#
	SRL		$2, $2, 0x10					#
	AND		$2, $2, 0xFF					#
	BEQ		$2, $0, FlatColorPrim20			#
	NOP										#
	LW		$11, 0x14($5)					#
	LW		$9, 0x10($5)					#         /* ASSUMPTION - less than 16384 normals */
	ANDI	$10, $11, 0xFFFF				#         /* Hence we don't mask the vertex indices */
	SRL		$9, $9, 0xE						#
	SLL		$10, $10, 0x2					#
	SRL		$11, $11, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	ADD		$11, $11, $12					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x4($5)					#
	LW		$13, 0x8($5)					#
	LW		$14, 0xC($5)					#
											#
	SW		$12, 0x0($8)					#         param[0] = color0;
	SW		$9, 0x4($8)						#         param[1] = vert0;
	SW		$13, 0x8($8)					#         param[2] = color1;
	SW		$10, 0xC($8)					#         param[3] = vert1;
	SW		$14, 0x10($8)					#         param[4] = color2;
	SW		$11, 0x14($8)					#         param[5] = vert2;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                             &param[5]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim20					#
											#
	LW		$4, 0x4($29)					#             GPU_SortCiTriangle(orderTable, 3,
	LA		$6, PrimBuffer					#                                PrimBuffer);
	JAL		GPU_SortCiTriangle				#
	ADDI	$5, $0, 0x3						#
											#
	J		ExitPrim20						#
	NOP										#
											#
FlatColorPrim20:							#
	LW		$11, 0xC($5)					#
	LW		$9, 0x8($5)						#
	ANDI	$10, $11, 0xFFFF				#
	SRL		$9, $9, 0xE						#         /* ASSUMPTION - less than 16384 normals */
	SLL		$10, $10, 0x2					#         /* Hence we don't mask the vertex indices */
	SRL		$11, $11, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	ADD		$11, $11, $12					#
	LW		$12, 0x4($5)					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
											#
	SW		$12, 0x0($8)					#         buffer[0] = color;
	SW		$9, 0x4($8)						#         buffer[1] = vert0;
	SW		$10, 0x8($8)					#         buffer[2] = vert1;
	SW		$11, 0xC($8)					#         buffer[3] = vert2;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[2],
	ADDI	$5, $8, 0x8						#                             &param[3]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0xC						#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim20					#
											#
	LW		$4, 0x4($29)					#             GPU_SortTriangle(orderTable, 3,
	LA		$6, PrimBuffer					#                              PrimBuffer);
	JAL		GPU_SortTriangle				#
	ADDI	$5, $0, 0x3						#         }
											#
ExitPrim20:									#
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim20							# }

###############################################################################

	.ent	Prim24							# void Prim24(GsOT orderTable, PsxUInt32 *prim)
Prim24:										# {
	ADDI	$29, $29, 0xFFF8				#
	SW		$31, 0x0($29)					#
	SW		$4, 0x4($29)					#
	LA		$8, PrimBuffer					#
	LA		$12, deviceVert					#
	LW		$11, 0x14($5)					#
	LW		$9, 0x10($5)					#
	AND		$10, $11, 0xFFFF				#
	SRL		$9, $9, 0xE						#     /* ASSUMPTION - less than 16384 normals */
	SLL		$10, $10, 0x2					#     /* Hence we don't mask the vertex indices */
	SRL		$11, $11, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	ADD		$11, $11, $12					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x4($5)					#
	LW		$13, 0x8($5)					#
	LW		$14, 0xC($5)					#
											#
	ADDI	$2, $0, 0xFFFF					#     param[0] = 0xFFFFFFFF;
	SW		$2, 0x0($8)						#
	SW		$9, 0x4($8)						#     param[1] = deviceVert[vert0];
	SW		$12, 0x8($8)					#     param[2] = tex0 | (clutId << 16);
	SW		$10, 0xC($8)					#     param[3] = deviceVert[vert1];
	SW		$13, 0x10($8)					#     param[4] = tex1 | (tPage << 16);
	SW		$11, 0x14($8)					#     param[5] = deviceVert[vert2];
	SW		$14, 0x18($8)					#     param[6] = tex2;
											#
	ADDI	$4, $8, 0x4						#     if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                         &param[5]) > 0)
	JAL		GTE_IsPolyFront					#     {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim24					#
											#
	LW		$4, 0x4($29)					#         GPU_SortTexTriangle(orderTable, 3,
	LA		$6, PrimBuffer					#                             PrimBuffer);
	JAL		GPU_SortTexTriangle				#
	ADDI	$5, $0, 0x3						#
											#
ExitPrim24:									#     }
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim24							# }

###############################################################################

	.ent	Prim28							# void Prim28(GsOT orderTable, PsxUInt32 *prim)
Prim28:										# {
	ADDI	$29, $29, 0xFFF8				#     PsxUInt32 *buffer = PrimBuffer
	SW		$31, 0x0($29)					#
	SW		$4, 0x4($29)					#     if (((prim[0] >> 16) & 0xFF) != 0)
	LW		$2, 0x0($5)						#     {
	LA		$8, PrimBuffer					#
	LA		$13, deviceVert					#
	SRL		$2, $2, 0x10					#
	AND		$2, $2, 0xFF					#
	BEQ		$2, $0, FlatColorPrim28			#
	NOP										#
	LW		$11, 0x18($5)					#
	LW		$9, 0x14($5)					#         /* ASSUMPTION - less than 16384 normals */
	ANDI	$10, $11, 0xFFFF				#         /* Hence we don't mask the vertex indices */
	LW		$12, 0x1C($5)					#
	SRL		$9, $9, 0xE						#
	SLL		$10, $10, 0x2					#
	SRL		$11, $11, 0xE					#
	AND		$12, $12, 0xFFFF				#
	SLL		$12, $12, 0x2					#
	ADD		$9, $9, $13						#
	ADD		$10, $10, $13					#
	ADD		$11, $11, $13					#
	ADD		$12, $12, $13					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x0($12)					#
											#
	LW		$13, 0x4($5)					#
	LW		$14, 0x8($5)					#
	LW		$15, 0xC($5)					#
	LW		$24, 0x10($5)					#
											#
	SW		$13, 0x0($8)					#         param[0] = color0;
	SW		$9, 0x4($8)						#         param[1] = vert0;
	SW		$14, 0x8($8)					#         param[2] = color1;
	SW		$10, 0xC($8)					#         param[3] = vert1;
	SW		$15, 0x10($8)					#         param[4] = color2;
	SW		$11, 0x14($8)					#         param[5] = vert2;
	SW		$24, 0x18($5)					#         param[6] = color3;
	SW		$12, 0x1C($5)					#         param[7] = vert3;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                             &param[5]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim28					#
											#
	LW		$4, 0x4($29)					#             GPU_SortCiQuad(orderTable, 3,
	LA		$6, PrimBuffer					#                            PrimBuffer);
	JAL		GPU_SortCiQuad					#
	ADDI	$5, $0, 0x3						#
											#
	J		ExitPrim28						#
	NOP										#
											#
FlatColorPrim28:							#
	LW		$11, 0xC($5)					#
	LW		$9, 0x8($5)						#
	ANDI	$10, $11, 0xFFFF				#
	LW		$12, 0x10($5)					#
	SRL		$9, $9, 0xE						#         /* ASSUMPTION - less than 16384 normals */
	SLL		$10, $10, 0x2					#         /* Hence we don't mask the vertex indices */
	SRL		$11, $11, 0xE					#
	AND		$12, $12, 0xFFFF				#
	SLL		$12, $12, 0x2					#
	ADD		$9, $9, $13						#
	ADD		$10, $10, $13					#
	ADD		$11, $11, $13					#
	ADD		$12, $12, $13					#
	LW		$13, 0x4($5)					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x0($12)					#
											#
	SW		$13, 0x0($8)					#         buffer[0] = color;
	SW		$9, 0x4($8)						#         buffer[1] = vert0;
	SW		$10, 0x8($8)					#         buffer[2] = vert1;
	SW		$11, 0xC($8)					#         buffer[3] = vert2;
	SW		$12, 0x10($8)					#         buffer[4] = vert3;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[2],
	ADDI	$5, $8, 0x8						#                             &param[3]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0xC						#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim28					#
											#
	LW		$4, 0x4($29)					#             GPU_SortQuad(orderTable, 3,
	LA		$6, PrimBuffer					#                          PrimBuffer);
	JAL		GPU_SortQuad					#
	ADDI	$5, $0, 0x3						#         }
											#
ExitPrim28:									#
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim28							# }

###############################################################################

	.ent	Prim2C							# void Prim2C(GsOT orderTable, PsxUInt32 *prim)
Prim2C:										# {
	ADDI	$29, $29, 0xFFF8				#     PsxUInt32 *buffer = PrimBuffer
	SW		$31, 0x0($29)					#
	SW		$4, 0x4($29)					#
	LA		$8, PrimBuffer					#
	LA		$13, deviceVert					#
	LW		$11, 0x18($5)					#
	LW		$9, 0x14($5)					#
	LW		$12, 0x1C($5)					#
	AND		$10, $11, 0xFFFF				#
	AND		$12, $12, 0xFFFF				#
	SRL		$9, $9, 0xE						#     /* $9 = vert0 */
	SLL		$10, $10, 0x2					#     /* $10 = vert1 */
	SRL		$11, $11, 0xE					#     /* $11 = vert2 */
	SLL		$12, $12, 0x2					#     /* $12 = vert3 */
	ADD		$9, $9, $13						#
	ADD		$10, $10, $13					#
	ADD		$11, $11, $13					#
	ADD		$12, $12, $13					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x0($12)					#
											#
	LW		$13, 0x4($5)					#
	LW		$14, 0x8($5)					#
	LW		$15, 0xC($5)					#
	LW		$24, 0x10($5)					#
											#
	ADDI	$2, $0, 0xFFFF					#     param[0] = 0xFFFFFFFF;
	SW		$2, 0x0($8)						#
	SW		$9, 0x4($8)						#     param[1] = deviceVert[vert0];
	SW		$13, 0x8($8)					#     param[2] = tex0 | (clutId << 16);
	SW		$10, 0xC($8)					#     param[3] = deviceVert[vert1];
	SW		$14, 0x10($8)					#     param[4] = tex1 | (tPage << 16);
	SW		$11, 0x14($8)					#     param[5] = deviceVert[vert2];
	SW		$15, 0x18($8)					#     param[6] = tex2;
	SW		$12, 0x1C($8)					#     param[7] = deviceVert[vert3];
	SW		$24, 0x20($8)					#     param[8] = tex3;
											#
	ADDI	$4, $8, 0x4						#     if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                         &param[5]) > 0)
	JAL		GTE_IsPolyFront					#     {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim2C					#
											#
	LW		$4, 0x4($29)					#         GPU_SortTexQuad(orderTable, 3,
	LA		$6, PrimBuffer					#                         PrimBuffer);
	JAL		GPU_SortTexQuad					#
	ADDI	$5, $0, 0x3						#
											#
ExitPrim2C:									#     }
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim2C							# }

###############################################################################

	.ent	Prim30							# void Prim30(GsOT orderTable, PsxUInt32 *prim)
Prim30:										# {
	ADDI	$29, $29, 0xFFF8				#     PsxUInt32 *buffer = PrimBuffer;
	SW		$31, 0x0($29)					#
	SW		$4, 0x4($29)					#     if (((prim[0] >> 16) & 0xFF) != 0)
	LW		$2, 0x0($5)						#     {
	LA		$8, PrimBuffer					#
	LA		$12, deviceVert					#
	SRL		$2, $2, 0x10					#
	AND		$2, $2, 0xFF					#
	BEQ		$2, $0, FlatColorPrim30			#
	NOP										#
	LW		$9, 0x10($5)					#
	LW		$10, 0x14($5)					#
	LW		$11, 0x18($5)					#
	SRL		$9, $9, 0xE						#         /* ASSUMPTION - less than 16384 normals */
	SRL		$10, $10, 0xE					#         /* Hence we don't mask the vertex indices */
	SRL		$11, $11, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	ADD		$11, $11, $12					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x4($5)					#
	LW		$13, 0x8($5)					#
	LW		$14, 0xC($5)					#
											#
	SW		$12, 0x0($8)					#         param[0] = color0;
	SW		$9, 0x4($8)						#         param[1] = vert0;
	SW		$13, 0x8($8)					#         param[2] = color1;
	SW		$10, 0xC($8)					#         param[3] = vert1;
	SW		$14, 0x10($8)					#         param[4] = color2;
	SW		$11, 0x14($8)					#         param[5] = vert2;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                             &param[5]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim30					#
											#
	LW		$4, 0x4($29)					#             GPU_SortCiTriangle(orderTable, 3,
	LA		$6, PrimBuffer					#                                PrimBuffer);
	JAL		GPU_SortCiTriangle				#
	ADDI	$5, $0, 0x3						#
											#
	J		ExitPrim30						#         }
	NOP										#     }
											#     else
FlatColorPrim30:							#     {
	LW		$9, 0x8($5)						#
	LW		$10, 0xC($5)					#
	LW		$11, 0x10($5)					#
	SRL		$9, $9, 0xE						#         /* ASSUMPTION - less than 16384 normals */
	SRL		$10, $10, 0xE					#         /* Hence we don't mask the vertex indices */
	SRL		$11, $11, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	ADD		$11, $11, $12					#
	LW		$12, 0x4($5)					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
											#
	SW		$12, 0x0($8)					#         buffer[0] = color;
	SW		$9, 0x4($8)						#         buffer[1] = vert0;
	SW		$10, 0x8($8)					#         buffer[2] = vert1;
	SW		$11, 0xC($8)					#         buffer[3] = vert2;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[2],
	ADDI	$5, $8, 0x8						#                             &param[3]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0xC						#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim30					#
											#
	LW		$4, 0x4($29)					#             GPU_SortTriangle(orderTable, 3,
	LA		$6, PrimBuffer					#                              PrimBuffer);
	JAL		GPU_SortTriangle				#
	ADDI	$5, $0, 0x3						#         }
ExitPrim30:									#
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim30							# }

###############################################################################

	.ent	Prim34							# void Prim34(GsOT orderTable, PsxUInt32 *prim)
Prim34:										# {
	ADDI	$29, $29, 0xFFF8				#     PsxUInt32 *buffer = PrimBuffer;
	SW		$31, 0x0($29)					#     PsxUInt16 vert0 = prim[4] >> 16;
	SW		$4, 0x4($29)					#     PsxUInt16 vert1 = prim[5] >> 16;
	LA		$8, PrimBuffer					#     PsxUInt16 vert2 = prim[6] >> 16;
	LA		$12, deviceVert					#
	LW		$9, 0x10($5)					#
	LW		$10, 0x14($5)					#
	LW		$11, 0x18($5)					#
	SRL		$9, $9, 0xE						#     /* ASSUMPTION - less than 16384 normals */
	SRL		$10, $10, 0xE					#     /* Hence we don't mask the vertex indices */
	SRL		$11, $11, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	ADD		$11, $11, $12					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x4($5)					#
	LW		$13, 0x8($5)					#
	LW		$14, 0xC($5)					#
											#
	ADDI	$2, $0, 0xFFFF					#     param[0] = 0xFFFFFFFF;
	SW		$2, 0x0($8)						#
	SW		$9, 0x4($8)						#     param[1] = deviceVert[vert0];
	SW		$12, 0x8($8)					#     param[2] = tex0 | (clutId << 16);
	SW		$10, 0xC($8)					#     param[3] = deviceVert[vert1];
	SW		$13, 0x10($8)					#     param[4] = tex1 | (tPage << 16);
	SW		$11, 0x14($8)					#     param[5] = deviceVert[vert2];
	SW		$14, 0x18($8)					#     param[6] = tex2;
											#
	ADDI	$4, $8, 0x4						#     if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                         &param[5]) > 0)
	JAL		GTE_IsPolyFront					#     {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim34					#
											#
	LW		$4, 0x4($29)					#         GPU_SortTexTriangle(orderTable, 3,
	LA		$6, PrimBuffer					#                             PrimBuffer);
	JAL		GPU_SortTexTriangle				#
	ADDI	$5, $0, 0x3						#
											#
ExitPrim34:									#     }
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim34							# }

###############################################################################

	.ent	Prim38							# void Prim38(GsOT orderTable, PsxUInt32 *prim)
Prim38:										# {
	ADDI	$29, $29, 0xFFF8				#     PsxUInt32 *buffer = PrimBuffer
	SW		$31, 0x0($29)					#
	SW		$4, 0x4($29)					#     if (((prim[0] >> 16) & 0xFF) != 0)
	LW		$2, 0x0($5)						#     {
	LA		$8, PrimBuffer					#
	LA		$13, deviceVert					#
	SRL		$2, $2, 0x10					#
	AND		$2, $2, 0xFF					#
	BEQ		$2, $0, FlatColorPrim38			#
	NOP										#
	LW		$9, 0x14($5)					#         /* ASSUMPTION - less than 16384 normals */
	LW		$10, 0x18($5)					#         /* Hence we don't mask the vertex indices */
	LW		$11, 0x1C($5)					#
	LW		$12, 0x20($5)					#
	SRL		$9, $9, 0xE						#
	SRL		$10, $10, 0xE					#
	SRL		$11, $11, 0xE					#
	SRL		$12, $12, 0xE					#
	ADD		$9, $9, $13						#
	ADD		$10, $10, $13					#
	ADD		$11, $11, $13					#
	ADD		$12, $12, $13					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x0($12)					#
											#
	LW		$13, 0x4($5)					#
	LW		$14, 0x8($5)					#
	LW		$15, 0xC($5)					#
	LW		$24, 0x10($5)					#
											#
	SW		$13, 0x0($8)					#         param[0] = color0;
	SW		$9, 0x4($8)						#         param[1] = vert0;
	SW		$14, 0x8($8)					#         param[2] = color1;
	SW		$10, 0xC($8)					#         param[3] = vert1;
	SW		$15, 0x10($8)					#         param[4] = color2;
	SW		$11, 0x14($8)					#         param[5] = vert2;
	SW		$24, 0x18($5)					#         param[6] = color3;
	SW		$12, 0x1C($5)					#         param[7] = vert3;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                             &param[5]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim38					#
											#
	LW		$4, 0x4($29)					#             GPU_SortCiQuad(orderTable, 3,
	LA		$6, PrimBuffer					#                            PrimBuffer);
	JAL		GPU_SortCiQuad					#
	ADDI	$5, $0, 0x3						#
											#
	J		ExitPrim38						#
	NOP										#
											#
FlatColorPrim38:							#
	LW		$9, 0x8($5)						#
	LW		$10, 0xC($5)					#
	LW		$11, 0x10($5)					#
	LW		$12, 0x14($5)					#
	SRL		$9, $9, 0xE						#         /* ASSUMPTION - less than 16384 normals */
	SRL		$10, $10, 0xE					#         /* Hence we don't mask the vertex indices */
	SRL		$11, $11, 0xE					#
	SRL		$12, $12, 0xE					#
	ADD		$9, $9, $13						#
	ADD		$10, $10, $13					#
	ADD		$11, $11, $13					#
	ADD		$12, $12, $13					#
	LW		$13, 0x4($5)					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x0($12)					#
											#
	SW		$13, 0x0($8)					#         buffer[0] = color;
	SW		$9, 0x4($8)						#         buffer[1] = vert0;
	SW		$10, 0x8($8)					#         buffer[2] = vert1;
	SW		$11, 0xC($8)					#         buffer[3] = vert2;
	SW		$12, 0x10($8)					#         buffer[4] = vert3;
											#
	ADDI	$4, $8, 0x4						#         if (GTE_IsPolyFront(&param[1], &param[2],
	ADDI	$5, $8, 0x8						#                             &param[3]) > 0)
	JAL		GTE_IsPolyFront					#         {
	ADDI	$6, $8, 0xC						#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim38					#
											#
	LW		$4, 0x4($29)					#             GPU_SortQuad(orderTable, 3,
	LA		$6, PrimBuffer					#                          PrimBuffer);
	JAL		GPU_SortQuad					#
	ADDI	$5, $0, 0x3						#         }
											#
ExitPrim38:									#
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim38							# }

###############################################################################

	.ent	Prim3C							# void Prim3C(GsOT orderTable, PsxUInt32 *prim)
Prim3C:										# {
	ADDI	$29, $29, 0xFFF8				#     PsxUInt32 *buffer = PrimBuffer
	SW		$31, 0x0($29)					#
	SW		$4, 0x4($29)					#
	LA		$8, PrimBuffer					#
	LA		$13, deviceVert					#
	LW		$11, 0x18($5)					#
	LW		$9, 0x14($5)					#
	LW		$10, 0x18($5)					#
	LW		$11, 0x1C($5)					#
	LW		$12, 0x20($5)					#
	SRL		$9, $9, 0xE						#     /* $9 = vert0 */
	SRL		$10, $10, 0xE					#     /* $10 = vert1 */
	SRL		$11, $11, 0xE					#     /* $11 = vert2 */
	SRL		$12, $12, 0xE					#     /* $12 = vert3 */
	ADD		$9, $9, $13						#
	ADD		$10, $10, $13					#
	ADD		$11, $11, $13					#
	ADD		$12, $12, $13					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
	LW		$11, 0x0($11)					#
	LW		$12, 0x0($12)					#
											#
	LW		$13, 0x4($5)					#
	LW		$14, 0x8($5)					#
	LW		$15, 0xC($5)					#
	LW		$24, 0x10($5)					#
											#
	ADDI	$2, $0, 0xFFFF					#     param[0] = 0xFFFFFFFF;
	SW		$2, 0x0($8)						#
	SW		$9, 0x4($8)						#     param[1] = deviceVert[vert0];
	SW		$13, 0x8($8)					#     param[2] = tex0 | (clutId << 16);
	SW		$10, 0xC($8)					#     param[3] = deviceVert[vert1];
	SW		$14, 0x10($8)					#     param[4] = tex1 | (tPage << 16);
	SW		$11, 0x14($8)					#     param[5] = deviceVert[vert2];
	SW		$15, 0x18($8)					#     param[6] = tex2;
	SW		$12, 0x1C($8)					#     param[7] = deviceVert[vert3];
	SW		$24, 0x20($8)					#     param[8] = tex3;
											#
	ADDI	$4, $8, 0x4						#     if (GTE_IsPolyFront(&param[1], &param[3],
	ADDI	$5, $8, 0xC						#                         &param[5]) > 0)
	JAL		GTE_IsPolyFront					#     {
	ADDI	$6, $8, 0x14					#
											#
	ADDI	$2, $2, 0xFFFF					#
	BLTZ	$2, ExitPrim3C					#
											#
	LW		$4, 0x4($29)					#         GPU_SortTexQuad(orderTable, 3,
	LA		$6, PrimBuffer					#                         PrimBuffer);
	JAL		GPU_SortTexQuad					#
	ADDI	$5, $0, 0x3						#
											#
ExitPrim3C:									#     }
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x8					#
	JR		$31								#
	NOP										#
	.end	Prim3C							# }

###############################################################################

	.ent	Prim40							# void Prim40(GsOT orderTable, PsxUInt32 *prim)
Prim40:										# {
	ADDI	$29, $29, 0xFFFC				#     PsxUInt32 *buffer = PrimBuffer;
	SW		$31, 0x0($29)					#
											#
	LA		$6, PrimBuffer					#
	LA		$12, deviceVert					#
											#
	LW		$10, 0x8($5)					#     /* Sort out the vertices */
	LW		$11, 0x4($5)					#
	AND		$9, $10, 0xFFFF					#
	SLL		$9, $9, 0x2						#
	SRL		$10, $10, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
											#
	SW		$11, 0x0($6)					#     buffer[0] = color;
	SW		$9, 0x4($6)						#     buffer[1] = deviceVert[vert0];
	SW		$10, 0x8($6)					#     buffer[2] = deviceVert[vert1];
											#
	JAL		GPU_SortLine					#     GPU_SortLine(orderTable, 3, PrimBuffer);
	ADD		$5, $0, 0x3						#
											#
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x4					#
	JR		$31								#
	NOP										#
	.end	Prim40							# }

###############################################################################

	.ent	Prim50							# void Prim50(GsOT orderTable, PsxUInt32 *prim)
Prim50:										# {
	ADDI	$29, $29, 0xFFFC				#     PsxUInt32 *buffer = PrimBuffer;
	SW		$31, 0x0($29)					#
											#
	LA		$6, PrimBuffer					#
	LA		$12, deviceVert					#
											#
	LW		$10, 0xC($5)					#     /* Sort out the vertices */
	LW		$11, 0x4($5)					#
	LW		$12, 0x8($5)					#
	AND		$9, $10, 0xFFFF					#
	SLL		$9, $9, 0x2						#
	SRL		$10, $10, 0xE					#
	ADD		$9, $9, $12						#
	ADD		$10, $10, $12					#
	LW		$9, 0x0($9)						#
	LW		$10, 0x0($10)					#
											#
	SW		$11, 0x0($6)					#     buffer[0] = color0;
	SW		$9, 0x4($6)						#     buffer[1] = deviceVert[vert0];
	SW		$12, 0x8($6)					#     buffer[2] = color1;
	SW		$10, 0xC($6)					#     buffer[3] = deviceVert[vert1];
											#
	JAL		GPU_SortCiLine					#     GPU_SortCiLine(orderTable, 3, PrimBuffer);
	ADD		$5, $0, 0x3						#
											#
	LW		$31, 0x0($29)					#
	ADDI	$29, $29, 0x4					#
	JR		$31								#
	NOP										#
	.end	Prim50							# }

###############################################################################
