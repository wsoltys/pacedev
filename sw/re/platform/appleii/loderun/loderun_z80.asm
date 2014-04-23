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

				; zero-page
				.macro LD_ZP_r, addr,r
				ld			(ix+addr),r
				.endm
				.macro LD_r_ZP, r,addr
				ld			r,(ix+addr)
				.endm
				.macro INC_ZP,addr
				inc			(ix+addr)
				.endm
				.macro DEC_ZP,addr
				dec			(ix+addr)
				.endm
				.macro AND_ZP,addr
				and			(ix+addr)
				.endm
												
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
				ld					sp, stack
				ld					a,#0x00
				out					(0xe0),a						; no interrupts
				ld					a,#0x02
				out					(0x84),a						; memory map III
				ld					a,#0x40
				out					(0xec),a						; 4MHz
				ld					hl,#0xf800
				ld					de,#0xf801
				ld					bc,#0x07ff
				ld					(hl),#0x20
				ldir														; clear text screen
;				GFXMOD			0xB3								; 640x240, X-inc on write
				GFXMOD			0xB0								; text-only mode, X-inc on write
.endif

; for zero-page emulation
				ld					ix,#zero_page
				
; start lode runner				
				call				read_paddles
;				lda					#1
;				jsr					sub_6359						; examine h/w and check disk sig			

display_title_screen: ; $6008
				call				gcls1
; stuff         		
				ld					c,#0
				LD_ZP_r			row,c								
				LD_ZP_r			byte_a7,c
				ld					a,#0x20							; page 1
				LD_ZP_r			display_char_page,a
; stuff				  		
				ld					hl,#title_data
				xor					a
				ld					d,a									; x count
				ld					e,a									; y count
				GFXX    		
				GFXY    		
1$:			ld					b,(hl)							; get count
				inc					hl
2$:			ld					a,(hl)							; get byte
.ifdef PIXEL_DOUBLE
				NIBDBL
				push				af
				ld					a,c
				GFXDAT  		
				pop					af
				inc					d										; inc X count
				NIBDBL  		
				ld					a,c
.else           		
				inc					d										; dummy inc for 35*2
.endif				  		
				GFXDAT  		
				inc					d										; inc X count
				ld					a,d
				cp					#70									; end of line?
				jr					nz,3$								; no, skip
				xor					a
				ld					d,a
				GFXX    		
				inc					e										; inc Y count
				ld					a,e
				GFXY    		
3$:			djnz				2$
				inc					hl
				ld					a,e									; Y count
				cp					#192								; finished?
				jr					nz,1$
; this is where the apple selects the hires screen				
				GFXMOD			0xB3									; 640x240, X-inc on write
				jp					title_wait_for_key
				
loc_6056:	; $6056
				xor					a
				LD_ZP_r			score_1e1_1,a
				LD_ZP_r			score_1e3_1e2,a
				LD_ZP_r			score_1e5_1e4,a
				LD_ZP_r			score_1e6,a
; store in zero page
				ld					a,#5								; number of lives
				LD_ZP_r			no_lives,a
				LD_r_ZP			a,byte_a7
				srl					a
				jr					z,loc_6099
; do some crap  		
				jp					display_title_screen

loc_6099:	; $6099
				call				cls_and_display_game_status
; stuff				
				ld					b,#1
				call				init_read_unpack_display_level
loop:		jp					loop				
				; other crap				
				BREAK
				
title_wait_for_key: ; $618e
;				jsr					keybd_flush
				ld					b,#4
1$:			push				bc
				ld					bc,#0xF000
2$:			LD_r_ZP			a,paddles_detected
				cp					#0xcb								; detected?
				jr					z,3$								; no, skip
; check for joystick buttons here				
3$:			ld					a,(0xf4ff)					; check for any key
				or					a
				jr					nz,loc_61f6
				dec					bc
				ld					a,b
				or					c
				jr					nz,2$
				pop					bc
				;djnz				1$									; *** FUDGE - shorten
				LD_r_ZP			a,byte_a7
				;bne    		
				ld					b,#1
				LD_ZP_r			byte_a7,b
				LD_ZP_r			level,b
; do some other crap
				jp					loc_6056

loc_61f6:
				BREAK

init_read_unpack_display_level:	; $6238
				LD_ZP_r			unk_a2,b
				ld					b,0xff
				LD_ZP_r			byte_0,b
				inc					b
				LD_ZP_r			unk_a3,b
				LD_ZP_r			no_gold,b
; stuff				
				LD_ZP_r			unk_1a,b
				LD_ZP_r			row,b
; heaps of stuff
				call				read_level_data
				LD_r_ZP			c,row
				ld					hl,#level_data_packed
				ld					de,#level_data_unpacked
5$:			xor					a
				LD_ZP_r			col,a								; col=0
4$:			LD_r_ZP			a,unk_1a						; nibble count
				srl					a
				ld					a,(hl)							; source (packed) byte
				jr					c,1$								; do high nibble
				and					#0x0f								; low nibble
				jr					2$
1$:			srl					a
				srl					a
				srl					a
				srl					a										; high->low nibble
				INC_ZP			unk_92
				inc					hl									; source (packed) addr
2$:			INC_ZP			unk_1a							; inc nibble count
				LD_r_ZP			b,col
				cp					#10									; data byte 0-9?
				jr					c,3$								; yes, valid (skip)
				xor					a										; invalid, ignore
3$:			ld					(de),a							; destination (unpacked) byte
; another copy
				inc					de									; destination (unpacked) addr
				INC_ZP			col
				LD_r_ZP			a,col
				cp					#28									; last column?
				jr					c,4$								; no, loop
				INC_ZP			row
				LD_r_ZP			a,row
				cp					#16									; last row?
				jr					c,5$								; no, loop
				call				init_and_display_level
				ret

read_level_data:	; $6264
; copies from disk buffer to low memory ($0D00)
				ret

init_and_display_level: ; $63B3
				ld					hl,#level_data_unpacked+28*16-1
				ld					c,#15								; last row
				LD_ZP_r			row,c
1$:			ld					c,#27								; last column
				LD_ZP_r			col,c
2$:			ld					a,(hl)
				dec					hl
				cp					#6									; end-of-screen ladder?
				jr					nz,8$								; no, skip
				ld					a,#0								; space
				jr					8$
8$:			push				hl
				call				display_char_pg1
				pop					hl
				DEC_ZP			col
				jp					p,2$
				DEC_ZP			row
				jp					p,1$
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
				call				gcls1
;				call				gcls2
				ld					b,#4								; 4 lines
				ld					c,#176							; starting row
1$:			push				bc				
				ld					a,c
				GFXY    		
				xor					a
				GFXX    		
				ld					b,#35								; bytes/line
.ifdef PIXEL_DOUBLE
				ld					a,#0xCC							; pattern
2$:			GFXDAT  		
				GFXDAT  		
.else           		
				ld					a,#0xAA							; pattern
2$:			GFXDAT  		
.endif				  		
				djnz				2$									; 1 line
				pop					bc
				inc					c
				djnz				1$
				ld					a,#16
				LD_ZP_r			row,a
				xor					a
				LD_ZP_r			col,a
				call				display_message
				.asciz			"SCORE        MEN    LEVEL   "
				call				display_no_lives
				call				display_level
				ld					bc,0x0000						; add 0
				jp					update_and_display_score				

display_no_lives:	; $7A70
				LD_r_ZP			a,no_lives
				ld					b,#16								; col=16
display_byte:
				LD_ZP_r			col,b
				call				cnv_byte_to_3_digits
				ld					a,#16								; row=16
				LD_ZP_r			row,a
				LD_r_ZP			a,hundreds
				call				display_digit
				LD_r_ZP			a,tens
				call				display_digit
				LD_r_ZP			a,units
				jp					display_digit

display_level: ; $7A8C
				LD_r_ZP			a,level
				ld					b,#25								; col=25
				jr					display_byte
				ret

update_and_display_score:	; $7A92
				LD_r_ZP			a,score_1e1_1
				add					b
				daa     		
				LD_ZP_r			score_1e1_1,a
				LD_r_ZP			a,score_1e3_1e2
				adc					c
				daa     		
				LD_ZP_r			score_1e3_1e2,a
				LD_r_ZP			a,score_1e5_1e4
				adc					#0
				LD_ZP_r			score_1e3_1e2,a
				LD_r_ZP			a,score_1e6
				adc					#0
				LD_ZP_r			score_1e6,a
				ld					a,#5								; col=5
				LD_ZP_r			col,a
				ld					a,#16								; row=16
				LD_ZP_r			row,a
				LD_r_ZP			a,score_1e6
				call				cnv_bcd_to_2_digits
				LD_r_ZP			a,units
				call				display_digit
				LD_r_ZP			a,score_1e5_1e4
				call				cnv_bcd_to_2_digits
				LD_r_ZP			a,tens
				call				display_digit
				LD_r_ZP			a,units
				call				display_digit
				LD_r_ZP			a,score_1e3_1e2
				call				cnv_bcd_to_2_digits
				LD_r_ZP			a,tens
				call				display_digit
				LD_r_ZP			a,units
				call				display_digit
				LD_r_ZP			a,score_1e1_1
				call				cnv_bcd_to_2_digits
				LD_r_ZP			a,tens
				call				display_digit
				LD_r_ZP			a,units
				jp					display_digit

cnv_bcd_to_2_digits: ; $7AE9
				LD_ZP_r			tens,a
				and					#0x0f
				LD_ZP_r			units,a
				LD_r_ZP			a,tens
				srl					a
				srl					a
				srl					a
				srl					a
				LD_ZP_r			tens,a
				ret
				
cnv_byte_to_3_digits: ; $7AF8
				ld					b,#0
				LD_ZP_r			tens,b
				LD_ZP_r			hundreds,b
1$:			cp					#100
				jr					c,2$
				INC_ZP			hundreds
				sub					#100
				jr					nz,1$								; loop counting hundreds
2$:			cp					#10
				jr					c,3$
				INC_ZP			tens
				sub					#10
				jr					2$									; loop counting tens
3$:			LD_ZP_r			units,a							; store units
				ret

display_digit: ; $7B15
				add					#0x3b								; convert to 'ASCII'
				call				display_char_pg1
				INC_ZP			col
				ret
																
remap_character: ; $7B2A
				cp					#0xc1								; <'A'
				jr					c,1$								; yes, go
				cp					#0xdB								; <= 'Z'?
				jr					c,3$								; yes, go
1$:			ld					b,#0x7c
				cp					#0xa0								; space?
				jr					z,2$								; yes, go
				ld					b,#0xdb
				cp					#0xbe								; >
				jr					z,2$
				inc					b
				cp					#0xae								; .
				jr					z,2$
				inc					b
				cp					#0xa8								; (
				jr					z,2$
				inc					b
				cp					#0xa9								; )
				jr					z,2$
				inc					b
				cp					#0xaf								; /
				jr					z,2$
				inc					b
				cp					#0xad								; -
				jr					z,2$
				inc					b
				cp					#0xbc								; <
				jr					z,2$
				ld					a,#0x10
				ret     		
2$:			ld					a,b
3$:			sub					#0x7c								; zero-based
				ret
			
display_character: ; $7B64
				cp					#0x8d								; cr?
				jr					z,cr								; yes, handle
				call				remap_character			; returned in A
				call				display_char_pg1
				INC_ZP			col
				ret

cr: ; 7B7D
				INC_ZP			row									; next row
				xor					a
				LD_ZP_r			col,a								; col=0
				ret
				
display_char_pg1:	; $82AA
				LD_ZP_r			msg_char,a					; store character
				LD_r_ZP			c,row
				call				sub_885d						; get scanline in A
				LD_ZP_r			scanline,c
				LD_r_ZP			b,col
				call				calc_col_addr_shift
				LD_ZP_r			col_addr_offset,a
				LD_ZP_r			col_pixel_shift,b
				ld					hl,#left_char_masks
				ld					d,0
				ld					e,b
				srl					e
				add					hl,de
				ld					a,(hl)							; lchar_mask
				LD_ZP_r			lchar_mask,a
				ld					e,#4
				add					hl,de
				ld					a,(hl)							; rchar_mask
				LD_ZP_r			rchar_mask,a
				call				render_char_in_buffer
				ld					hl,#char_render_buf
				ld					b,#11								; scanlines per char
				LD_ZP_r			scanline_cnt,a
1$:			LD_r_ZP			a,scanline
; stuff
				GFXY    		
				LD_r_ZP			a,col_addr_offset
				GFXX
.ifndef PIXEL_DOUBLE				
				in					a,(130)							; video byte
				AND_ZP			lchar_mask
				or					(hl)								; data byte 1
.else
				ld					a,(hl)							; data byte 1
				NIBDBL  		
				push				af
				in					a,(130)							; video byte
				AND_ZP			lchar_mask
				or					c
				GFXDAT  		
				pop					af
				NIBDBL  		
				in					a,(130)
				or					c
.endif				
				GFXDAT
				inc					hl
.ifndef PIXEL_DOUBLE				
				in					a,(130)							; video byte
				AND_ZP			rchar_mask
				or					(hl)								; data byte 2
.else           		
				ld					a,(hl)
				NIBDBL  		
				in					a,(130)
				AND_ZP			rchar_mask
				or					c
.endif				  		
				GFXDAT  		
				inc					hl
				INC_ZP			scanline
				dec					b										; scanline_cnt
				jp					nz,1$
				ret

left_char_masks:	; $8328
.ifndef PIXEL_DOUBLE
				.db			0x00, 0xc0, 0xf0, 0xfc
.else
				.db			0x00, 0xf0, 0x00, 0x00
.endif				
right_char_masks:	; $832F
.ifndef PIXEL_DOUBLE
				.db			0x3f, 0x0f, 0x03, 0x00
.else
				.db			0x0f, 0x00, 0x00, 0x00
.endif				
				
render_char_in_buffer:	; $8438
				ld					hl,#char_bank_tbl
				LD_r_ZP			a,col_pixel_shift		; 0,2,4,6 (same as word offset)
				ld					d,0
				ld					e,a
				add					hl,de
				ld					e,(hl)
				inc					hl
				ld					d,(hl)
				ex					de,hl								; HL = ptr char bank
				push				hl
				ld					hl,#char_offset_tbl
				LD_r_ZP			a,msg_char
				sla					a										; word offset
				ld					d,0
				ld					e,a
				add					hl,de								; ptr char offset entry
				ld					e,(hl)
				inc					hl
				ld					d,(hl)							; DE = offset
				pop					hl									; ptr char bank
				add					hl,de
				ld					de,#char_render_buf
				ld					bc,#(11*2)					; bytes to copy
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
				pop					hl
1$:			ld					(msg_addr),hl				; store msg ptr
				ld					a,(hl)							; msg char
				or					a										; end of msg?
				jr					z,9$								; yes, exit
				or					#0x80								; *** FUDGE
				call				display_character
				ld					hl,(msg_addr)				; msg ptr
				inc					hl									; inc
				jr					1$									; loop
9$:			inc					hl									; skip NULL
				push				hl
				ret
								
read_paddles: ; $8702
; check for joystick buttons here
				ld					a, #0xcb						; flag no paddles detected
				LD_ZP_r			paddles_detected,a
				ret

sub_885d:	; $885d
				ld					hl,#row_to_scanline_tbl
				ld					d,0
				ld					e,c									; row
				add					hl,de								; ptr entry for row
				ld					a,(hl)							; scanline
				; other stuff
				ld					c,a
				ret

calc_col_addr_shift:	; $8868
				ld					hl,#col_to_addr_tbl
				ld					d,0
				ld					e,b									; col
.ifdef PIXEL_DOUBLE
				sla					e										; effectively doubling the column
.endif
				add					hl,de								; ptr entry for col
				ld					a,(hl)							; addr
				push				af
				ld					a,b									; col   = 0,1,2,3,4...
				sla					a										; shift = 0,2,4,6,0...
.ifndef PIXEL_DOUBLE				
				and					#0x06								; shift = 0,2,4,6,0...
.else
				and 				#0x02								; shift = 0,2,0,2,0...
.endif
				ld					b,a
				pop					af
				ret

; this was in low memory on the apple
level_data_unpacked:
				.ds					28*16
												
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
.include "levels.asm"

stack		.equ				.+0x400

				.end				codebase
