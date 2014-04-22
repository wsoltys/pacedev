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
				ld			(score_10_1),a
				ld			(score_1000_100),a
				ld			(score_100000_10000),a
				ld			(score_1000000),a
; store in zero page
				ld			a,#5										; number of lives
				ld			(no_lives),a				
				ld			a,(byte_A7)
				srl			a
				jr			z,loc_6099
; do some crap
				jp			display_title_screen

loc_6099:	; $6099
				call		cls_and_display_game_status
				ld			b,#1
				call		init_read_unpack_display_level
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

init_read_unpack_display_level:	; $6238
; heaps of stuff
				call		read_level_data
				ld			a,(row)
				ld			c,a
				ret

read_level_data:	; $6264
; copies from disk buffer to low memory ($0D00)
				ret
								
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

cls_and_display_game_status:	; $79AD
				call		gcls1
;				call		gcls2
				ld			b,#4										; 4 lines
				ld			c,#176									; starting row
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
				call		display_no_lives
				call		display_level
				ld			bc,0x0000								; add 0
				jp			update_and_display_score				

display_no_lives:	; $7A70
				ld			a,(no_lives)
				ld			b,#16										; col=16
display_byte:
				push		af
				ld			a,b
				ld			(col),a
				pop			af
				call		cnv_byte_to_3_digits
				ld			a,#16										; row=16
				ld			(row),a
				ld			a,(hundreds)
				call		display_digit
				ld			a,(tens)
				call		display_digit
				ld			a,(units)
				jp			display_digit

display_level: ; $7A8C
				ld			a,(level)
				ld			b,#25										; col=25
				jr			display_byte
				ret

update_and_display_score:	; $7A92
				ld			a,(score_10_1)
				add			b
				daa
				ld			(score_10_1),a
				ld			a,(score_1000_100)
				adc			c
				daa
				ld			(score_1000_100),a
				ld			a,(score_100000_10000)
				adc			#0
				ld			(score_100000_10000),a
				ld			a,(score_1000000)
				adc			#0
				ld			(score_1000000),a
				ld			a,#5										; col=5
				ld			(col),a
				ld			a,#16										; row=16
				ld			(row),a
				ld			a,(score_1000000)
				call		cnv_bcd_to_2_digits
				ld			a,(units)
				call		display_digit
				ld			a,(score_100000_10000)
				call		cnv_bcd_to_2_digits
				ld			a,(tens)				
				call		display_digit
				ld			a,(units)
				call		display_digit
				ld			a,(score_1000_100)
				call		cnv_bcd_to_2_digits
				ld			a,(tens)				
				call		display_digit
				ld			a,(units)
				call		display_digit
				ld			a,(score_10_1)				
				call		cnv_bcd_to_2_digits
				ld			a,(tens)				
				call		display_digit
				ld			a,(units)
				jp			display_digit

cnv_bcd_to_2_digits: ; $7AE9
				ld			(tens),a
				and			#0x0f
				ld			(units),a
				ld			a,(tens)
				srl			a
				srl			a
				srl			a
				srl			a
				ld			(tens),a
				ret
				
cnv_byte_to_3_digits: ; $7AF8
				ld			ix,#hundreds
				ld			(ix+00),0								; hundreds
				ld			(ix+01),0								; tens
1$:			cp			#100
				jr			c,2$
				inc			(ix+00)									; inc hundreds
				sub			#100
				jr			nz,1$										; loop counting hundreds
2$:			cp			#10
				jr			c,3$
				inc			(ix+01)									; inc tens
				sub			#10
				jr			2$											; loop counting tens
3$:			ld			(ix+02),a								; store units
				ret

display_digit: ; $7B15
				add			#0x3b										; convert to 'ASCII'
				call		display_char_pg1
				ld			hl,#col
				inc			(hl)
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
2$:			ld			a,b
3$:			sub			#0x7c										; zero-based
				ret
			
display_character: ; $7B64
				cp			#0x8d										; cr?
				jr			z,cr										; yes, handle
				call		remap_character					; returned in A
				call		display_char_pg1
				ld			hl,#col
				inc			(hl)										; next column
				ret

cr: ; 7B7D
				ld			hl,#row
				inc			(hl)										; next row
				xor			a
				ld			(col),a									; col=0
				ret
				
display_char_pg1:	; $82AA
				ld			(msg_char),a						; store character
				ld			a,(row)
				call		sub_885d								; get scanline in A
				ld			(scanline),a
				ld			a,(col)
				call		calc_col_addr_shift
				ld			(col_pixel_shift),a
				ld			hl,#left_char_masks
				ld			d,0
				ld			e,a
				srl			e
				add			hl,de
				ld			a,(hl)									; lchar_mask
				ld			(lchar_mask),a
				ld			e,#4
				add			hl,de
				ld			a,(hl)									; rchar_mask
				ld			(rchar_mask),a
				ld			a,b
				ld			(col_addr_offset),a
				call		render_char_in_buffer
				ld			ix,#char_render_buf
				ld			iy,#lchar_mask
				ld			hl,#scanline
				ld			b,#11										; scanlines per char
1$:			ld			a,(hl)									; scanline
				GFXY
				ld			a,(col_addr_offset)
				GFXX
.ifndef PIXEL_DOUBLE				
				in			a,(130)									; video byte
				and			(iy+00)									; lchar_mask
				or			(ix+00)									; data byte 1
.else
				ld			a,(ix+00)								; data byte 1
				NIBDBL
				push		af
				in			a,(130)									; video byte
				and			(iy+00)									; lchar_mask
				or			c
				GFXDAT
				pop			af
				NIBDBL
				ld			a,c
.endif				
				GFXDAT
				inc			ix
.ifndef PIXEL_DOUBLE				
				in			a,(130)									; video byte
				and			(iy+01)									; rchar_mask
				or			(ix+00)									; data byte 2
.else
				ld			a,(ix+00)
				NIBDBL
				push		af
				ld			a,c
				GFXDAT
				pop			af
				NIBDBL
				in			a,(130)									; video_byte
				and			(iy+01)									; rchar_mask
				or			c
.endif				
				GFXDAT
				inc			ix
				inc			(hl)										; inc scanline
				dec			b
				jp			nz,1$
;				djnz		1$
				ret

left_char_masks:	; $8328
.ifndef PIXEL_DOUBLE
				.db			0x00, 0xc0, 0xf0, 0xfc
.else
				.db			0x00, 0xf0
.endif				
right_char_masks:	; $832F
.ifndef PIXEL_DOUBLE
				.db			0x3f, 0x0f, 0x03, 0x00
.else
				.db			0x0f, 0x00
.endif				
				
render_char_in_buffer:	; $8438
				ld			hl,#char_bank_tbl
				ld			a,(col_pixel_shift)			; 0,2,4,6 (same as word offset)
				ld			d,0
				ld			e,a
				add			hl,de
				ld			e,(hl)
				inc			hl
				ld			d,(hl)
				ex			de,hl										; HL = ptr char bank
				push		hl
				ld			hl,#char_offset_tbl
				ld			a,(msg_char)
				sla			a												; word offset
				ld			d,0
				ld			e,a
				add			hl,de										; ptr char offset entry
				ld			e,(hl)
				inc			hl
				ld			d,(hl)									; DE = offset
				pop			hl											; ptr char bank
				add			hl,de
				ld			de,#char_render_buf
				ld			bc,#(11*2)							; bytes to copy
				ldir
				ret

char_bank_tbl:
				.dw			#tile_data+0*22*104
				.dw			#tile_data+1*22*104
				.dw			#tile_data+2*22*104
				.dw			#tile_data+3*22*104

char_offset_tbl:
				.dw			 0*22,  1*22,  2*22,  3*22,  4*22,    5*22,   6*22,   7*22
				.dw			 8*22,  9*22, 10*22, 11*22, 12*22,   13*22,  14*22,  15*22
				.dw			16*22, 17*22, 18*22, 19*22, 20*22,   21*22,  22*22,  23*22
				.dw			24*22, 25*22, 26*22, 27*22, 28*22,   29*22,  30*22,  31*22
				.dw			32*22, 33*22, 34*22, 35*22, 36*22,   37*22,  38*22,  39*22
				.dw			40*22, 41*22, 42*22, 43*22, 44*22,   45*22,  46*22,  47*22
				.dw			48*22, 49*22, 50*22, 51*22, 52*22,   53*22,  54*22,  55*22
				.dw			56*22, 57*22, 58*22, 59*22, 60*22,   61*22,  62*22,  63*22
				.dw			64*22, 65*22, 66*22, 67*22, 68*22,   69*22,  70*22,  71*22
				.dw			72*22, 73*22, 74*22, 75*22, 76*22,   77*22,  78*22,  79*22
				.dw			80*22, 81*22, 82*22, 83*22, 84*22,   85*22,  86*22,  87*22
				.dw			88*22, 89*22, 90*22, 91*22, 92*22,   93*22,  94*22,  95*22
				.dw			96*22, 97*22, 98*22, 99*22, 100*22, 101*22, 102*22, 103*22
				
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

sub_885d:	; $885d
				ld			hl,#row_to_scanline_tbl
				ld			d,0
				ld			e,a											; row
				add			hl,de										; ptr entry for row
				ld			a,(hl)									; scanline
				; other stuff
				ret

calc_col_addr_shift:	; $8868
				ld			hl,#col_to_addr_tbl
				ld			d,0
				ld			e,a											; col
.ifdef PIXEL_DOUBLE
				sla			e
.endif
				add			hl,de										; ptr entry for col
				ld			b,(hl)									; addr
				sla			a												; shift (same for pixel-double)
.ifndef PIXEL_DOUBLE				
				and			#0x06
.else
				and 		#0x02
.endif
				ret
								
.include "zeropage.asm"									; zero-page registers

.include "tiles.asm"										; tile graphic data

row_to_scanline_tbl:	; $1c51
				.db			0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121
				.db			132, 143, 154, 165, 181

col_to_addr_tbl:	; $1c62
				.db			0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16
				.db			17, 18, 20, 21, 22, 23, 25, 26, 27, 28, 30, 31, 32, 33
; following lines used only for pixel-doubling on TRS-80				
				.db			35, 36, 37, 38, 40, 41, 42, 43, 45, 46, 47, 48, 50, 51
				.db			52, 53, 55, 56, 57, 58, 60, 61, 62, 63, 65, 66, 67, 68

.include "title.asm"										; title screen RLE data

stack		.equ		.+0x400

				.end		codebase
						