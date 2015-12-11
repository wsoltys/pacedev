	* ++====================================================================++
	* || common_crt0_cart.s - C Run Time Startup Code for Neo Geo Cartridge	||
	* ++--------------------------------------------------------------------++
	* || $Id: common_crt0_cart.s,v 1.5 2001/07/13 14:46:31 fma Exp $		||
	* ++--------------------------------------------------------------------++
	* || This is the startup code needed by programs compiled with GCC		||
	* ++--------------------------------------------------------------------||
	* || BGM: Guitar Vader - S.P.Y.											||
	* ++====================================================================++

********************** Exported Symbols **********************
	.globl	_start
	.globl	atexit

********************** Imported Symbols **********************
	.globl	__do_global_ctors
	.globl	__do_global_dtors
	.globl	main
	.globl	memset
	.globl	__bss_start	
	.globl	_end

********************** Program Start *************************

** NOTE: Cartridge systems have swapped IRQ1 and IRQ2

	.long	0x10F300, 0xC00402, 0xC00408, 0xC0040E
	.long	0xC00414, 0xC00426, 0xC00426, 0xC00426
	.long	0xC0041A, 0xC00420, 0xC00426, 0xC00426
	.long	0xC00426, 0xC00426, 0xC00426, 0xC0042C
	.long	0xC00522, 0xC00528, 0xC0052E, 0xC00534
	.long	0xC0053A, 0xC004F2, 0xC004EC, 0xC004E6
	.long	0xC004E0, IRQ2,     IRQ1,     IRQ3
	.long	DUMMY,	  DUMMY,    DUMMY,    DUMMY
	.long	TRAP00,	  TRAP01,	TRAP02,	  TRAP03
	.long	TRAP04,	  TRAP05,   TRAP06,   TRAP07
	.long   TRAP08,   TRAP09,   TRAP10,   TRAP11
	.long	TRAP12,   TRAP13,   TRAP14,   TRAP15
	.long	0xC00426, 0xC00426, 0xC00426, 0xC00426
	.long	0xC00426, 0xC00426, 0xC00426, 0xC00426
	.long	0xC00426, 0xC00426, 0xC00426, 0xC00426
	.long	0xC00426, 0xC00426, 0xC00426, 0xC00426
	
	.ascii	"NEO-GEO"
	.byte	CDDA_FLAG
	.word	GUID
	.long	0x0
	.long	DEBUG_DIPS
	.word	0x0
	.word	LOGO_START
	.long	_jp_config
	.long	_us_config
	.long	_sp_config

	jmp		ENTRY_POINT1
	jmp		ENTRY_POINT2
	jmp		ENTRY_POINT3
	jmp		ENTRY_POINT4
	
	.org	0x182

	.long	_security

_security:
	moveq	#0,d3
	tst.w	0xa14(a5)
	bne		l2a53a
	movea.l	0xa04(a5),a0
	move.w	0xa08(a5),d7

l2a508:
	move.b	d0,0x300001
	move.w	(a0),d1
	cmpi.b	#0xff,d1
	beq.s	l2a530
	move.w	2(a0),d0
	cmp.b	0xace(a5),d0
	bne.s	l2a530
	move.w	4(a0),d0
	cmp.b	0xacf(a5),d0
	bne.s	l2a530
	cmp.b	0xad0(a5),d1
	beq.s	l2a538

l2a530:
	addq.l	#8,a0
	dbf		d7,l2a508
	move.w	d7,d3
l2a538:
	rts

l2a53a:
	movea.l	0xa04(a5),a0
	move.w	0xa08(a5),d7
l2a542:
	move.w	(a0),d1
	lsr.w	#8,d1
	cmpi.b	#0xff,d1
	beq.s	l2a566
	move.w	(a0),d0
	cmp.b	0xace(a5),d0
	bne.s	l2a566
	move.w	2(a0),d0
	lsr.w	#8,d0
	cmp.b	0xacf(a5),d0
	bne.s	l2a566
	cmp.b	0xad0(a5),d1
	beq.s	l2a56e
l2a566:
	addq.l	#4,a0
	dbf		d7,l2a542
	move.w	d7,d3
l2a56e:
	rts

	.align	4

* Dummy exception routine
_dummy_exc_handler:
	rte

	.align	4

* Dummy sub-routine
_dummy_config_handler:
	rts

	.align	4

* Standard IRQ1 handler
_irq1_handler:
   addq.w #1, 0x401ffe
	move.w	#2, 0x3C000C
	rte

	.align	4

* Standard IRQ2 handler
_irq2_handler:
*  addq.w #1, 0x401ffe
	move.w	#1, _vbl_flag
	tst.b	0x10FD80
	bmi.s	0f
	jmp		0xC00438
	
0:
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	d0, 0x300001
	jsr		0xC0044A
	movem.l	(sp)+, d0-d7/a0-a6
	move.w	#4, 0x3C000C
	rte

	.align	4

* Standard IRQ3 handler
_irq3_handler:
	move.w	#1, 0x3C000C
	rte

	.align	4

* Dummy atexit (does nothing for now)
atexit:
	moveq	#0, d0
	rts

	.align	4

* Entry point of our program
_start:
	* Setup stack pointer and 'system' pointer
	lea		0x10F300,a7
	lea		0x108000,a5

	* Reset watchdog
	move.b	d0,0x300001
	
	* Flush interrupts
	move.b	#7,0x3C000C
	
	* Enable manual reset (A+B+C+START or SELECT)
	bclr	#7,0x10FD80
	
	* Enable interrupts
	move.w	#0x2000,sr

	* Initialize BSS section
	move.l	#_end, d0
	sub.l	#__bss_start, d0
	move.l	d0, -(a7)
	clr.l	-(a7)
	pea		__bss_start
	jbsr	memset	

	* Jump to main
	jbsr	main

	* Call global destructors
	jbsr	__do_global_dtors

	* For cart systems, infinite loop
9:
	jmp	9b(pc)

	.align	4

