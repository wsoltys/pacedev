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

				; for 'trs80gp -ee' only
				.macro BREAK
				ld			a,#4
				out			(0x47),a
				.endm
				
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
				xor			a
				ld			(byte_A7),a
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
				
loc_6056:	; $6056
				xor			a
; store in zero page
				ld			a,#5										; number of lives
				ld			(no_lives),a				
				ld			a,(byte_A7)
				srl			a
				jr			z,loc_6099
; do some crap
				jp			display_title_screen

loc_6099:	; $6099
				call		loc_79AD
loop:		jp			loop				
				; other crap				
				BREAK
				
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
				;djnz		1$											; *** FUDGE - shorten
				ld			a,(byte_A7)
				;bne
				ld			a,#1
				ld			(byte_A7),a
; do some other crap
				jp			loc_6056

loc_61f6:
				BREAK

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

loc_79AD:	; $79AD
				call		gcls1
;				call		gcls2
				ld			b,#4										; 4 lines
				ld			c,#220									; starting row
1$:			push		bc				
				ld			a,c
				GFXY
				xor			a
				GFXX
				ld			b,#35										; bytes/line
.ifdef PIXEL_DOUBLE
				ld			a,#0xCC									; pattern
2$:			GFXDAT
				GFXDAT
.else
				ld			a,#0xAA									; pattern
2$:			GFXDAT
.endif				
				djnz		2$											; 1 line
				pop			bc
				inc			c
				djnz		1$
				ld			a,#0x10
				ld			(row),a
				ld			a,#0x00
				ld			(col),a
				call		display_message
				
				.asciz	"SCORE        MEN    LEVEL   "
				
				ret

remap_character: ; $7B2A
				cp			#0xc1										; <'A'
				jr			c,1$										; yes, go
				cp			#0xdB										; <= 'Z'?
				jr			c,3$										; yes, go
1$:			ld			b,#0x7c
				cp			#0xa0										; space?
				jr			z,2$										; yes, go
				ld			b,#0xdb
				cp			#0xbe										; >
				jr			z,2$
				inc			b
				cp			#0xae										; .
				jr			z,2$
				inc			b
				cp			#0xa8										; (
				jr			z,2$
				inc			b
				cp			#0xa9										; )
				jr			z,2$
				inc			b
				cp			#0xaf										; /
				jr			z,2$
				inc			b
				cp			#0xad										; -
				jr			z,2$
				inc			b
				cp			#0xbc										; <
				jr			z,2$
				ld			a,#0x10
				ret
2$:			ld			a,c
3$:			sub			#0x7c										; zero-based
				ret
			
display_character: ; $7B64
				cp			#0x8d										; cr?
				jr			z,cr										; yes, handle
				call		remap_character
				call		display_char_pg1
				ld			hl,col
				inc			(hl)
				ret

cr: ; 7B7D
				ld			hl,row
				inc			(hl)
				xor			a
				ld			(col),a
				ret
				
display_char_pg1:	; $82AA
				ld			(msg_char),a						; store character
				ld			a,(row)
; stuff
				ld			a,(col)
; stuff
				call		copy_character_to_video
				ret

copy_character_to_video:
				ld			a,#11
;				ld			(scanline_cnt),a
				
				ret
								
display_message:	; $86E0
				pop			hl
1$:			ld			(msg_addr),hl						; store msg ptr
				ld			a,(hl)									; msg char
				or			a												; end of msg?
				jr			z,9$										; yes, exit
				or			#0x80										; *** FUDGE
				call		display_character
				ld			hl,(msg_addr)						; msg ptr
				inc			hl											; inc
				jr			1$											; loop
9$:			inc			hl											; skip NULL
				push		hl
				ret
								
read_paddles: ; $8702
; check for joystick buttons here
				ld			a, #0xcb								; flag no paddles detected
				ld			(paddles_detected),a
				ret

.include "zeropage.asm"									; zero-page registers

.include "tiles.asm"										; tile graphic data

.include "title.asm"										; title screen RLE data

stack		.equ		.+0x400

				.end		codebase
						