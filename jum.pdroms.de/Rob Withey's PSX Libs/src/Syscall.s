#
#	PSX SYSTEM CALL
#
	.macro	BIOSCALL	type,no,name
	.text
	.align	2
	.globl	\name
	.text
	.ent	\name
\name:
	li	$8,\type
	.set	noreorder
	jr	$8
	li	$9,\no
	.set	reorder
	.end	\name
	.endm

	.macro	SYSTEMCALL	no,name
	.text
	.align	2
	.globl	\name
	.text
	.ent	\name
\name:
	li	$4,\no
	syscall
	jr	$31
	.end	\name
	.endm

# a0 call

	BIOSCALL	0xa0,0x00,open
	BIOSCALL	0xa0,0x01,lseek
	BIOSCALL	0xa0,0x02,read
	BIOSCALL	0xa0,0x03,write
	BIOSCALL	0xa0,0x04,close
	BIOSCALL	0xa0,0x05,ioctl
	BIOSCALL	0xa0,0x06,exit
	BIOSCALL	0xa0,0x07,sys_a0_07
	BIOSCALL	0xa0,0x08,getc
	BIOSCALL	0xa0,0x09,putc
	BIOSCALL	0xa0,0x0a,todigit
	BIOSCALL	0xa0,0x0b,atof
	BIOSCALL	0xa0,0x0c,strtoul
	BIOSCALL	0xa0,0x0d,strtol
	BIOSCALL	0xa0,0x0e,abs
	BIOSCALL	0xa0,0x0f,labs
	BIOSCALL	0xa0,0x10,atoi
	BIOSCALL	0xa0,0x11,atol
	BIOSCALL	0xa0,0x12,atob
	BIOSCALL	0xa0,0x13,setjmp
	BIOSCALL	0xa0,0x14,longjmp
	BIOSCALL	0xa0,0x15,strcat
	BIOSCALL	0xa0,0x16,strncat
	BIOSCALL	0xa0,0x17,strcmp
	BIOSCALL	0xa0,0x18,strncmp
	BIOSCALL	0xa0,0x19,strcpy
	BIOSCALL	0xa0,0x1a,strnpy
	BIOSCALL	0xa0,0x1b,strlen
	BIOSCALL	0xa0,0x1c,index
	BIOSCALL	0xa0,0x1d,rindex
	BIOSCALL	0xa0,0x1e,strchr
	BIOSCALL	0xa0,0x1f,strrchr
	BIOSCALL	0xa0,0x20,strpbrk
	BIOSCALL	0xa0,0x21,strspn
	BIOSCALL	0xa0,0x22,strcspn
	BIOSCALL	0xa0,0x23,strtok
	BIOSCALL	0xa0,0x24,strstr
	BIOSCALL	0xa0,0x25,toupper
	BIOSCALL	0xa0,0x26,tolower
	BIOSCALL	0xa0,0x27,bcopy
	BIOSCALL	0xa0,0x28,bzero
	BIOSCALL	0xa0,0x29,bcmp
	BIOSCALL	0xa0,0x2a,memcpy
	BIOSCALL	0xa0,0x2b,memset
	BIOSCALL	0xa0,0x2c,memmove
	BIOSCALL	0xa0,0x2d,memcmp
	BIOSCALL	0xa0,0x2e,memchr
	BIOSCALL	0xa0,0x2f,rand
	BIOSCALL	0xa0,0x30,srand
	BIOSCALL	0xa0,0x31,qsort
	BIOSCALL	0xa0,0x32,strtod
	BIOSCALL	0xa0,0x33,malloc
	BIOSCALL	0xa0,0x34,free
	BIOSCALL	0xa0,0x35,lsearch
	BIOSCALL	0xa0,0x36,bsearch
	BIOSCALL	0xa0,0x37,calloc
	BIOSCALL	0xa0,0x38,realloc
	BIOSCALL	0xa0,0x39,InitHeap
	BIOSCALL	0xa0,0x3a,_exit
	BIOSCALL	0xa0,0x3b,getchar
	BIOSCALL	0xa0,0x3c,putchar
	BIOSCALL	0xa0,0x3d,gets
	BIOSCALL	0xa0,0x3e,puts
	BIOSCALL	0xa0,0x3f,printf
	BIOSCALL	0xa0,0x40,sys_a0_40
	BIOSCALL	0xa0,0x41,LoadTest
	BIOSCALL	0xa0,0x42,Load
	BIOSCALL	0xa0,0x43,Exec
	BIOSCALL	0xa0,0x44,FlushCache
	BIOSCALL	0xa0,0x45,InstallInterruptHandler
	BIOSCALL	0xa0,0x46,GPU_dw
	BIOSCALL	0xa0,0x47,mem2vram
	BIOSCALL	0xa0,0x48,SendGPU
	BIOSCALL	0xa0,0x49,GPU_cw
	BIOSCALL	0xa0,0x4a,GPU_cwb
	BIOSCALL	0xa0,0x4b,SendPackets
	BIOSCALL	0xa0,0x4c,sys_a0_4c
	BIOSCALL	0xa0,0x4d,GetGPUStatus
	BIOSCALL	0xa0,0x4e,GPU_sync
	BIOSCALL	0xa0,0x4f,sys_a0_4f
	BIOSCALL	0xa0,0x50,sys_a0_50
	BIOSCALL	0xa0,0x51,LoadExec
	BIOSCALL	0xa0,0x52,GetSysSp
	BIOSCALL	0xa0,0x53,sys_a0_53
	BIOSCALL	0xa0,0x54,_96_init
	BIOSCALL	0xa0,0x55,_bu_init
	BIOSCALL	0xa0,0x56,_96_remove
	BIOSCALL	0xa0,0x57,sys_a0_57
	BIOSCALL	0xa0,0x58,sys_a0_58
	BIOSCALL	0xa0,0x59,sys_a0_59
	BIOSCALL	0xa0,0x5a,sys_a0_5a
	BIOSCALL	0xa0,0x5b,dev_tty_init
	BIOSCALL	0xa0,0x5c,dev_tty_open
	BIOSCALL	0xa0,0x5d,dev_tty_5d
	BIOSCALL	0xa0,0x5e,dev_tty_ioctl
	BIOSCALL	0xa0,0x5f,dev_cd_open
	BIOSCALL	0xa0,0x60,dev_cd_read
	BIOSCALL	0xa0,0x61,dev_cd_close
	BIOSCALL	0xa0,0x62,dev_cd_firstfile
	BIOSCALL	0xa0,0x63,dev_cd_nextfile
	BIOSCALL	0xa0,0x64,dev_cd_chdir
	BIOSCALL	0xa0,0x65,dev_card_open
	BIOSCALL	0xa0,0x66,dev_card_read
	BIOSCALL	0xa0,0x67,dev_card_write
	BIOSCALL	0xa0,0x68,dev_card_close
	BIOSCALL	0xa0,0x69,dev_card_firstfile
	BIOSCALL	0xa0,0x6a,dev_card_nextfile
	BIOSCALL	0xa0,0x6b,dev_card_erase
	BIOSCALL	0xa0,0x6c,dev_card_undelete
	BIOSCALL	0xa0,0x6d,dev_card_format
	BIOSCALL	0xa0,0x6e,dev_card_rename
	BIOSCALL	0xa0,0x6f,dev_card_6f
#	BIOSCALL	0xa0,0x70,_bu_init
#	BIOSCALL	0xa0,0x71,_96_init
#	BIOSCALL	0xa0,0x72,_96_remove
	BIOSCALL	0xa0,0x73,sys_a0_73
	BIOSCALL	0xa0,0x74,sys_a0_74
	BIOSCALL	0xa0,0x75,sys_a0_75
	BIOSCALL	0xa0,0x76,sys_a0_76
	BIOSCALL	0xa0,0x77,sys_a0_77
	BIOSCALL	0xa0,0x78,_96_CdSeekL
	BIOSCALL	0xa0,0x79,sys_a0_79
	BIOSCALL	0xa0,0x7a,sys_a0_7a
	BIOSCALL	0xa0,0x7b,sys_a0_7b
	BIOSCALL	0xa0,0x7c,_96_CdGetStatus
	BIOSCALL	0xa0,0x7d,sys_a0_7d
	BIOSCALL	0xa0,0x7e,_96_CdRead
	BIOSCALL	0xa0,0x7f,sys_a0_7f
	BIOSCALL	0xa0,0x80,sys_a0_80
	BIOSCALL	0xa0,0x81,sys_a0_81
	BIOSCALL	0xa0,0x82,sys_a0_82
	BIOSCALL	0xa0,0x83,sys_a0_83
	BIOSCALL	0xa0,0x84,sys_a0_84
	BIOSCALL	0xa0,0x85,_96_CdStop
	BIOSCALL	0xa0,0x86,sys_a0_86
	BIOSCALL	0xa0,0x87,sys_a0_87
	BIOSCALL	0xa0,0x88,sys_a0_88
	BIOSCALL	0xa0,0x89,sys_a0_89
	BIOSCALL	0xa0,0x8a,sys_a0_8a
	BIOSCALL	0xa0,0x8b,sys_a0_8b
	BIOSCALL	0xa0,0x8c,sys_a0_8c
	BIOSCALL	0xa0,0x8d,sys_a0_8d
	BIOSCALL	0xa0,0x8e,sys_a0_8e
	BIOSCALL	0xa0,0x8f,sys_a0_8f
	BIOSCALL	0xa0,0x90,sys_a0_90
	BIOSCALL	0xa0,0x91,sys_a0_91
	BIOSCALL	0xa0,0x92,sys_a0_92
	BIOSCALL	0xa0,0x93,sys_a0_93
	BIOSCALL	0xa0,0x94,sys_a0_94
	BIOSCALL	0xa0,0x95,sys_a0_95
	BIOSCALL	0xa0,0x96,AddCDROMDevice
	BIOSCALL	0xa0,0x97,AddMemCardDevice
	BIOSCALL	0xa0,0x98,DisableKernelIORedirection
	BIOSCALL	0xa0,0x99,EnableKernelIORedirection
	BIOSCALL	0xa0,0x9a,sys_a0_9a
	BIOSCALL	0xa0,0x9b,sys_a0_9b
	BIOSCALL	0xa0,0x9c,SetConf # may be
	BIOSCALL	0xa0,0x9d,GetConf # 
	BIOSCALL	0xa0,0x9e,sys_a0_9e
	BIOSCALL	0xa0,0x9f,SetMem
	BIOSCALL	0xa0,0xa0,_boot
	BIOSCALL	0xa0,0xa1,SystemError
	BIOSCALL	0xa0,0xa2,EnqueueCdIntr
	BIOSCALL	0xa0,0xa3,DequeueCdIntr
	BIOSCALL	0xa0,0xa4,sys_a0_a4
	BIOSCALL	0xa0,0xa5,ReadSector
	BIOSCALL	0xa0,0xa6,get_cd_status
	BIOSCALL	0xa0,0xa7,bufs_cb_0
	BIOSCALL	0xa0,0xa8,bufs_cb_1
	BIOSCALL	0xa0,0xa9,bufs_cb_2
	BIOSCALL	0xa0,0xaa,bufs_cb_3
	BIOSCALL	0xa0,0xab,_card_info
	BIOSCALL	0xa0,0xac,_card_load
	BIOSCALL	0xa0,0xad,_card_auto
	BIOSCALL	0xa0,0xae,bufs_cb_4
	BIOSCALL	0xa0,0xaf,sys_a0_af
	BIOSCALL	0xa0,0xb0,sys_a0_b0
	BIOSCALL	0xa0,0xb1,sys_a0_b1
	BIOSCALL	0xa0,0xb2,do_a_long_jmp
	BIOSCALL	0xa0,0xb3,sys_a0_b3
	BIOSCALL	0xa0,0xb4,sys_a0_b4

#b0 call

	BIOSCALL	0xb0,0x00,SysMalloc
	BIOSCALL	0xb0,0x01,sys_b0_01
	BIOSCALL	0xb0,0x02,sys_b0_02
	BIOSCALL	0xb0,0x03,sys_b0_03
	BIOSCALL	0xb0,0x04,sys_b0_04
	BIOSCALL	0xb0,0x05,sys_b0_05
	BIOSCALL	0xb0,0x06,sys_b0_06
	BIOSCALL	0xb0,0x07,DeliverEvent
	BIOSCALL	0xb0,0x08,OpenEvent
	BIOSCALL	0xb0,0x09,CloseEvent
	BIOSCALL	0xb0,0x0a,WaitEvent
	BIOSCALL	0xb0,0x0b,EnableEvent
	BIOSCALL	0xb0,0x0c,sys_b0_0c
	BIOSCALL	0xb0,0x0d,DisableEvent
	BIOSCALL	0xb0,0x0e,OpenTh
	BIOSCALL	0xb0,0x0f,CloseTh
	BIOSCALL	0xb0,0x10,ChangeTh
	BIOSCALL	0xb0,0x11,sys_b0_11
	BIOSCALL	0xb0,0x12,InitPAD
	BIOSCALL	0xb0,0x13,StartPAD
	BIOSCALL	0xb0,0x14,StopPAD
	BIOSCALL	0xb0,0x15,PAD_init
	BIOSCALL	0xb0,0x16,PAD_dr
	BIOSCALL	0xb0,0x17,ReturnFromException
	BIOSCALL	0xb0,0x18,ResetEntryInt
	BIOSCALL	0xb0,0x19,HookEntryInt
	BIOSCALL	0xb0,0x1a,sys_b0_1a
	BIOSCALL	0xb0,0x1b,sys_b0_1b
	BIOSCALL	0xb0,0x1c,sys_b0_1c
	BIOSCALL	0xb0,0x1d,sys_b0_1d
	BIOSCALL	0xb0,0x1e,sys_b0_1e
	BIOSCALL	0xb0,0x1f,sys_b0_1f
	BIOSCALL	0xb0,0x20,UnDeliverEvent
	BIOSCALL	0xb0,0x21,sys_b0_21
	BIOSCALL	0xb0,0x22,sys_b0_22
	BIOSCALL	0xb0,0x23,sys_b0_23
	BIOSCALL	0xb0,0x24,sys_b0_24
	BIOSCALL	0xb0,0x25,sys_b0_25
	BIOSCALL	0xb0,0x26,sys_b0_26
	BIOSCALL	0xb0,0x27,sys_b0_27
	BIOSCALL	0xb0,0x28,sys_b0_28
	BIOSCALL	0xb0,0x29,sys_b0_29
	BIOSCALL	0xb0,0x2a,sys_b0_2a
	BIOSCALL	0xb0,0x2b,sys_b0_2b
	BIOSCALL	0xb0,0x2c,sys_b0_2c
	BIOSCALL	0xb0,0x2d,sys_b0_2d
	BIOSCALL	0xb0,0x2e,sys_b0_2e
	BIOSCALL	0xb0,0x2f,sys_b0_2f
	BIOSCALL	0xb0,0x30,sys_b0_30
	BIOSCALL	0xb0,0x31,sys_b0_31
#	BIOSCALL	0xb0,0x32,open
#	BIOSCALL	0xb0,0x33,lseek
#	BIOSCALL	0xb0,0x34,read
#	BIOSCALL	0xb0,0x35,write
#	BIOSCALL	0xb0,0x36,close
#	BIOSCALL	0xb0,0x37,ioctl
#	BIOSCALL	0xb0,0x38,exit
#	BIOSCALL	0xb0,0x39,sys_b0_39
#	BIOSCALL	0xb0,0x3a,getc
#	BIOSCALL	0xb0,0x3b,putc
#	BIOSCALL	0xb0,0x3c,getchar
#	BIOSCALL	0xb0,0x3d,putchar
#	BIOSCALL	0xb0,0x3e,gets
#	BIOSCALL	0xb0,0x3f,puts
	BIOSCALL	0xb0,0x40,cd
	BIOSCALL	0xb0,0x41,format
	BIOSCALL	0xb0,0x42,firstfile
	BIOSCALL	0xb0,0x43,nextfile
	BIOSCALL	0xb0,0x44,rename
	BIOSCALL	0xb0,0x45,delete
	BIOSCALL	0xb0,0x46,undelete
	BIOSCALL	0xb0,0x47,AddDevice
	BIOSCALL	0xb0,0x48,RemoteDevice
	BIOSCALL	0xb0,0x49,PrintInstalledDevices
	BIOSCALL	0xb0,0x4a,InitCARD
	BIOSCALL	0xb0,0x4b,StartCARD
	BIOSCALL	0xb0,0x4c,StopCARD
	BIOSCALL	0xb0,0x4d,sys_b0_4d
	BIOSCALL	0xb0,0x4e,_card_write
	BIOSCALL	0xb0,0x4f,_card_read
	BIOSCALL	0xb0,0x50,_new_card
	BIOSCALL	0xb0,0x51,Krom2RawAdd
	BIOSCALL	0xb0,0x52,sys_b0_52
	BIOSCALL	0xb0,0x53,sys_b0_53
	BIOSCALL	0xb0,0x54,_get_errno
	BIOSCALL	0xb0,0x55,_get_error
	BIOSCALL	0xb0,0x56,GetC0Table
	BIOSCALL	0xb0,0x57,GetB0Table
	BIOSCALL	0xb0,0x58,_card_chan
	BIOSCALL	0xb0,0x59,sys_b0_59
	BIOSCALL	0xb0,0x5a,sys_b0_5a
	BIOSCALL	0xb0,0x5b,ChangeClearPAD
	BIOSCALL	0xb0,0x5c,_card_status
	BIOSCALL	0xb0,0x5d,_card_wait

# c0 call

	BIOSCALL	0xc0,0x00,InitRCnt
	BIOSCALL	0xc0,0x01,InitException
	BIOSCALL	0xc0,0x02,SysEnqIntRP
	BIOSCALL	0xc0,0x03,SysDeqIntRP
	BIOSCALL	0xc0,0x04,get_free_EvCB_slot
	BIOSCALL	0xc0,0x05,get_free_TCB_slot
	BIOSCALL	0xc0,0x06,ExceptionHandler
	BIOSCALL	0xc0,0x07,InstallExceptionHandler
	BIOSCALL	0xc0,0x08,SysInitMemory
	BIOSCALL	0xc0,0x09,SysInitKMem
	BIOSCALL	0xc0,0x0a,ChangeClearRCnt
#	BIOSCALL	0xc0,0x0b,SystemError
	BIOSCALL	0xc0,0x0c,InitDefInt
	BIOSCALL	0xc0,0x0d,sys_c0_0d
	BIOSCALL	0xc0,0x0e,sys_c0_0e
	BIOSCALL	0xc0,0x0f,sys_c0_0f
	BIOSCALL	0xc0,0x10,sys_c0_10
	BIOSCALL	0xc0,0x11,sys_c0_11
	BIOSCALL	0xc0,0x12,InstallDevices
	BIOSCALL	0xc0,0x13,FlushStdInOutPut
	BIOSCALL	0xc0,0x14,sys_c0_14
	BIOSCALL	0xc0,0x15,_cdevinput
	BIOSCALL	0xc0,0x16,_cdevscan
	BIOSCALL	0xc0,0x17,_circgetc
	BIOSCALL	0xc0,0x18,_circputc
	BIOSCALL	0xc0,0x19,ioabort
	BIOSCALL	0xc0,0x1a,sys_c0_1a
	BIOSCALL	0xc0,0x1b,KernelRedirect
	BIOSCALL	0xc0,0x1c,PatchAOTable

# syscall

	SYSTEMCALL	0,Exception
	SYSTEMCALL	1,EnterCriticalSection
	SYSTEMCALL	2,ExitCriticalSection
