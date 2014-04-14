;
;	LODE RUNNER
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
       	.area   idaseg (ABS)
				.z80

.define			TRS80

.ifdef TRS80
codebase		.equ		0x5200

; un-comment to pixel-double the display
.define PIXEL_DOUBLE

				.macro GFXMOD, mode
				ld			a,#mode
				out			(131),a
				.endm

				.macro GFXX
				out			(128),a
				.endm
				
				.macro GFXY
				out			(129),a
				.endm
				
				.macro GFXDAT
				out			(130),a
				.endm

				.macro BITDBL
				rlca
				push		af
				rl			c
				pop			af
				rl			c
				.endm
				
				.macro NIBDBL
				BITDBL
				BITDBL
				BITDBL
				BITDBL
				.endm

.endif

				.org		codebase

.ifdef TRS80
; initialise TRS-80 hardware
				di
				ld			sp, stack
				ld			a,#0x00
				out			(0xe0),a								; no interrupts
				ld			a,#0x02
				out			(0x84),a								; memory map III
				ld			a,#0x40
				out			(0xec),a								; 4MHz
				ld			hl,#0xf800
				ld			de,#0xf801
				ld			bc,#0x07ff
				ld			(hl),#0x20
				ldir														; clear text screen
;				GFXMOD	0xB3										; 640x240, X-inc on write
				GFXMOD	0xB0										; text-only mode, X-inc on write
.endif

; start lode runner				
				call		read_paddles
;				lda			#1
;				jsr			sub_6359								; examine h/w and check disk sig			

display_title_screen: ; $6008
				call		gcls1
				ld			hl,#title_data
				xor			a
				ld			d,a											; x count
				ld			e,a											; y count
				GFXX
				GFXY
1$:			ld			b,(hl)									; get count
				inc			hl
2$:			ld			a,(hl)									; get byte
.ifdef PIXEL_DOUBLE
				NIBDBL
				push		af
				ld			a,c
				GFXDAT
				pop			af
				inc			d												; inc X count
				NIBDBL
				ld			a,c
.else
				inc			d				
.endif				
				GFXDAT
				inc			d												; inc X count
				ld			a,d
				cp			#70											; end of line?
				jr			nz,3$										; no, skip
				xor			a
				ld			d,a
				GFXX
				inc			e												; inc Y count
				ld			a,e
				GFXY
3$:			djnz		2$
				inc			hl
				ld			a,e											; Y count
				cp			#192										; finished?
				jr			nz,1$
; this is where the apple selects the hires screen				
				GFXMOD	0xB3										; 640x240, X-inc on write
				jp			title_wait_for_key
				
; $6056
				xor			a
; store in zero page
				ld			a,#5										; number of lives
				ld			(no_lives),a				
; do some crap
				jp			display_title_screen
				
title_wait_for_key: ; $618e
;				jsr			keybd_flush
				ld			b,#4
1$:			push		bc
				ld			bc,#0xF000
2$:			ld			a,(paddles_detected)
				cp			#0xcb										; detected?
				jr			z,3$										; no, skip
; check for joystick buttons here				
3$:			ld			a,(0xf4ff)							; check for any key
				or			a
				jr			nz,loc_61f6
				dec			bc
				ld			a,b
				or			c
				jr			nz,2$
				pop			bc
				djnz		1$
; do some other crap
; test $A7
				jp			loc_6056

loc_61f6:
; exit to debugger (trs80gp only)				
break:	ld			a,#4
				out			(0x47),a

gcls1: ; $7A51
				ld			c,#240
1$:			ld			a,c
				dec			a
				GFXY
				ld			b,#80
				xor			a
				GFXX
2$:			GFXDAT
				djnz		2$
				dec			c
				jr			nz,1$
				ret								

read_paddles: ; $8702
; check for joystick buttons here
				ld			a, #0xcb								; flag no paddles detected
				ld			(paddles_detected),a
				ret

; zero-page registers
.include "zeropage.asm"

.include "title.asm"

stack		.equ		.+0x400

				.end		codebase
						