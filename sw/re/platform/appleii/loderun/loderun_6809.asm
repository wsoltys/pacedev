;
;	LODE RUNNER
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
       	.area   idaseg (ABS)

.define			COCO3

.ifdef COCO3

; COCO registers
PIA0				.equ		0xFF00
PIA1				.equ		0xFF20

KEYCOL			.equ		PIA0+2
KEYROW			.equ		PIA0

; GIME registers  	
INIT0				.equ		0xFF90
INIT1				.equ		0xFF91
IRQENR			.equ		0xFF92
FIRQENR			.equ		0xFF93
TMRMSB			.equ		0xFF94
TMRLSB			.equ		0xFF95
VMODE				.equ		0xFF98
VRES				.equ		0xFF99
BRDR				.equ		0xFF9A
VSC					.equ		0xFF9C
VOFFMSB			.equ		0xFF9D
VOFFLSB			.equ		0xFF9E
HOFF				.equ		0xFF9F
MMUTSK1			.equ		0xFFA0
MMUTSK2			.equ		0xFFA8
PALETTE			.equ		0xFFB0
CPU089			.equ		0xFFD8
CPU179			.equ		0xFFD9
ROMMODE			.equ		0xFFDE
RAMMODE			.equ		0xFFDF

codebase		.equ		0x4000
.endif

						.org		codebase
stack				.equ		.-2

start:

.ifdef COCO3
; initialise Coco3 hardware
				ldu			stack
				orcc		#0x50										; disable interrupts
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
				lda			#0x60										; enable GIME MMU,IRQ
				sta			INIT0     							
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
;				lda			#0x08										; VBLANK IRQ
				lda			#0x00										; no VBLANK IRQ
				sta			IRQENR    							
				lda			#0x00										; no FIRQ enabled
				sta			FIRQENR   							
				lda			#0x80										; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
;				lda			#0x7A										; 225 scanlines, 128 bytes/row, 16 colours
				lda			#0x0C										; 192 scanlines, 40 bytes/row, 2 colours (320x192)
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
				lda			#0xE0										; screen at page $38
				sta			VOFFMSB
				lda			#0x00      							
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							
				lda			#0x00
				sta			PALETTE
				lda			#0x12
				sta			PALETTE+1
				sta			CPU179									; select fast CPU clock (1.79MHz)
.endif
			
				lda			#0x7F
				tfr			a,dp
					
; start lode runner
				jsr			read_paddles
;				lda			#1
;				jsr			sub_6359								; examine h/w and check disk sig			

display_title_screen: ; $6008
				jsr			gcls1
				ldy			#title_data
				ldx			#0x0000									; 2 centres the title screen
				lda			#35											; 35 bytes/line
				sta			*col
				lda			#192										; 192 lines/screen
				sta			*row
1$:			ldb			,y+											; count
				lda			,y+											; byte
2$:			sta			,x+
				dec			*col										; line byte count
				tst			*col										; done line?
				bne			3$											; no, skip
				pshs		b
				ldb			#35
				stb			*col										; reset line byte count
				ldb			#5
				abx															; adjust video ptr
				dec			*row										; dec line count
				puls		b
3$:			decb														; done count?
				bne			2$											; no, loop
				tst			*row										; done screen?
				bne			1$											; no, loop
; this is where the apple selects the hires screen				
				jmp			title_wait_for_key

loc_6056: ; $6056
				lda			#0
				sta			*score_1e1_1
				sta			*score_1e3_1e2
				sta			*score_1e5_1e4
				sta			*score_1e6
; store in zero page
				lda			#5											; number of lives
				sta			*no_lives
				lda			*byte_a7
				lsra
				beq			loc_6099
; do some crap
				jmp			display_title_screen

loc_6099:	; $6099
				jsr			cls_and_display_game_status
; stuff				
				ldb			#1
				jsr			init_read_unpack_display_level
loop:		bra			loop				
				; other crap				

title_wait_for_key: ; $618e
;				jsr			keybd_flush
				ldb			#4
1$:			pshs		b
				ldy			#0
2$:			lda			*paddles_detected
				cmpa		#0xcb										; detected?
				beq			3$											; no, skip
; check for joystick buttons here				
3$:			ldx			#PIA0
				ldb			#0											; all columns
				stb			2,x											; column strobe
				lda			,x
				coma														; any key pressed?
				bne			loc_61f6								; yes, exit
				leay		-1,y
				bne			2$
				puls		b
				decb														; done?
				;bne			1$											; no, loop *** FUDGE - shorten
				ldb			#1
				stb			*byte_a7
				stb			*level
; do some other crap
				jmp			loc_6056

loc_61f6:
; hack
				jsr			gcls1
break:	bra			break

init_read_unpack_display_level:	; $6238
				stb			*unk_a2
				ldb			#0xff
				stb			*byte_0
				incb														; B=0
				stb			*unk_a3
				stb			*no_gold
; stuff				
				stb			*unk_1a
				stb			*row
; heaps of stuff
				jsr			read_level_data
				ldb			*row
				ldx			#level_data_packed
				ldy			#level_data_unpacked
5$:			lda			#0
				sta			*col										; col=0
4$:			lda			*unk_1a									; nibble count
				lsra
				lda			,x											; source (packed) byte
				bcs			1$											; do high nibble
				anda		#0x0f										; low nibble
				bra			2$
1$:			lsra
				lsra
				lsra
				lsra
				inc			*unk_92
				inx															; source (packed) addr
2$:			inc			*unk_1a									; inc nibble count
				ldb			*col
				cmpa		#10											; data byte 0-9?
				bcs			3$											; yes, valid (skip)
				lda			#0											; invalid, ignore
3$:			sta			,y											; destination (unpacked) byte
; another copy
				leay		1,y											; destination (unpacked) addr
				inc			*col
				lda			*col
				cmpa		#28											; last column?
				bcs			4$											; no, loop
				inc			*row
				lda			*row
				cmpa		#16											; last row?
				bcs			5$											; no, loop
				jsr			init_and_display_level
				rts

read_level_data:	; $6264
; copies from disk buffer to low memory ($0D00)
				rts
				
init_and_display_level: ; $63B3
				ldx			#level_data_unpacked+28*16-1
				ldb			#15											; last row
				stb			*row
1$:			ldb			#27											; last column
				stb			*col
2$:			lda			,x
				dex
				cmpa		#6											; end-of-screen ladder?
				bne			8$											; no, skip
				lda			#0											; space
				bra			8$
8$:			pshs		x
				jsr			display_char_pg1
				puls		x
				dec			*col
				bpl			2$
				dec			*row
				bpl			1$
				rts
												
gcls1: ; $7A51
				ldx			#0x0000
				bra			gcls
gcls2:
				ldx			#0x0000								; fix me
gcls:		lda			#0x00
1$:			sta			,x+
				cmpx		#40*192
				bne			1$
				rts

cls_and_display_game_status:	; $79AD
				jsr			gcls1
				jsr			gcls2
				ldb			#34											; last column on screen
				lda			#0xaa										; pattern
				ldx			#176*40									; screen address
1$:			sta			0,x           					
				sta			40,x          					
				sta			80,x          					
				sta			120,x										; 4 scanlines of pixels
				inx															; next video address
				decb														; done line?
				bpl			1$											; no, loop
				lda			#16
				sta			*row
				lda			#0
				sta			*col
				jsr			display_message
				.asciz			"SCORE        MEN    LEVEL   "
				jsr			display_no_lives
				jsr			display_level
				ldd			#0x0000									; add 0
				bra			update_and_display_score				

display_no_lives:	; $7A70
				lda			*no_lives
				ldb			#16											; col=16
display_byte:
				stb			*col
				jsr			cnv_byte_to_3_digits
				lda			#16											; row=16
				sta			*row
				lda			*hundreds
				jsr			display_digit
				lda			*tens
				jsr			display_digit
				lda			*units
				jmp			display_digit

display_level: ; $7A8C
				lda			*level
				ldb			#25											; col=25
				bra			display_byte

update_and_display_score:	; $7A92
				pshs		a
				tfr			b,a
				adda		*score_1e1_1
				daa     		
				sta			*score_1e1_1
				puls		a
				adca		*score_1e3_1e2
				daa     		
				sta			*score_1e3_1e2
				lda			*score_1e5_1e4
				adca		#0
				sta			*score_1e3_1e2
				lda			*score_1e6
				adca		#0
				sta			*score_1e6
				lda			#5											; col=5
				sta			*col
				lda			#16											; row=16
				sta			*row
				lda			*score_1e6
				jsr			cnv_bcd_to_2_digits
				lda			*units
				jsr			display_digit
				lda			*score_1e5_1e4
				jsr			cnv_bcd_to_2_digits
				lda			*tens
				jsr			display_digit
				lda			*units
				jsr			display_digit
				lda			*score_1e3_1e2
				jsr			cnv_bcd_to_2_digits
				lda			*tens
				jsr			display_digit
				lda			*units
				jsr			display_digit
				lda			*score_1e1_1
				jsr			cnv_bcd_to_2_digits
				lda			*tens
				jsr			display_digit
				lda			*units
				bra			display_digit

cnv_bcd_to_2_digits: ; $7AE9
				sta			*tens
				anda		#0x0f
				sta			*units
				lda			*tens
				lsra
				lsra
				lsra
				lsra
				sta			*tens
				rts
				
cnv_byte_to_3_digits: ; $7AF8
				ldb			#0
				stb			*tens
				stb			*hundreds
1$:			cmpa		#100
				bcs			2$
				inc			*hundreds
				suba		#100
				bne			1$											; loop counting hundreds
2$:			cmpa		#10
				bcs			3$
				inc			*tens
				suba		#10
				bne			2$											; loop counting tens
3$:			sta			*units									; store units
				rts

display_digit: ; $7B15
				adda		#0x3b										; convert to 'ASCII'
				jsr			display_char_pg1
				inc			*col
				rts

remap_character: ; $7B2A
				cmpa		#0xc1										; <'A'
				bcs			1$											; yes, go
				cmpa		#0xdB										; <= 'Z'?
				bcs			3$											; yes, go
1$:			ldb			#0x7c
				cmpa		#0xa0										; space?
				beq			2$											; yes, go
				ldb			#0xdb
				cmpa		#0xbe										; >
				beq			2$                  		
				incb                        		
				cmpa		#0xae										; .
				beq			2$                  		
				incb                        		
				cmpa		#0xa8										; (
				beq			2$                  		
				incb                        		
				cmpa		#0xa9										; )
				beq			2$                  		
				incb                        		
				cmpa		#0xaf										; /
				beq			2$                  		
				incb                        		
				cmpa		#0xad										; -
				beq			2$                  		
				incb                        		
				cmpa		#0xbc										; <
				beq			2$                  		
				lda			#0x10               		
				rts                         		
2$:			tfr			b,a                 		
3$:			suba		#0x7c										; zero-based
				rts
			
display_character: ; $7B64
				cmpa		#0x8d										; cr?
				beq			cr											; yes, handle
				jsr			remap_character					; returned in A
				jsr			display_char_pg1
				inc			*col
				rts

cr: ; 7B7D
				inc			*row										; next row
				lda			#0
				sta			*col										; col=0
				rts

display_char_pg1:	; $82AA
				sta			*msg_char
				ldb			*row
				jsr			sub_885d								; get scanline in B
				stb			*scanline
				ldb			*col
				jsr			calc_col_addr_shift
				sta			*col_addr_offset
				stb			*col_pixel_shift
; ignore masks for now
				jsr			render_char_in_buffer
				ldx			#char_render_buf
				lda			*scanline
				ldb			#40
				mul
				tfr			d,y
				ldb			*col_addr_offset
				leay		b,y
				ldb			#11
1$:			lda			0,y
; lmask here
				ora			,x+
				sta			0,y
				lda			1,y
; rmask here				
				ora			,x+
				sta			1,y
				leay		40,y
				decb
				bne			1$								
				rts

render_char_in_buffer:	; $8438
				ldx			#char_bank_tbl
				lda			*col_pixel_shift				; 0,2,4,6 (same as word offset)
				ldy			a,x											; ptr entry
				leax		,y											; entry (X=bank address)
				lda			*msg_char
				ldb			#22
				mul															; offset into bank
				leax		d,x											; X=ptr char data
				ldb			#(11*2)
				ldy			#char_render_buf				; destination
1$:			lda			,x+
				sta			,y+
				decb														; done all bytes?
				bne			1$											; no, loop
				rts

char_render_buf:
				.ds			22
				
char_bank_tbl:
				.dw			#tile_data+0*22*104
				.dw			#tile_data+1*22*104
				.dw			#tile_data+2*22*104
				.dw			#tile_data+3*22*104

display_message:	; $86E0
				puls		x
1$:			stx			*msg_addr								; store msg ptr
				lda			,x											; msg char
				beq			9$											; yes, exit
				ora			#0x80										; *** FUDGE
				jsr			display_character   		
				ldx			*msg_addr								; msg ptr
				inx															; inc
				bra			1$											; loop
9$:			inx															; skip NULL
				pshs		x
				rts

read_paddles: ; $8702
				lda			#0xcb										; no paddles detected?
				sta			*paddles_detected
				rts

sub_885d:	; $885d
				ldx			#row_to_scanline_tbl
				lda			b,x
				; other stuff
				tfr			a,b											; B=scanline
				rts

calc_col_addr_shift:	; $8868
				ldx			#col_to_addr_tbl
				lda			b,x											; A=col address
				aslb
				andb		#0x06										; B=shift
				rts
								
; this was in low memory on the apple
level_data_unpacked:
				.ds					28*16
												
; zero-page registers
.include "zeropage.asm"

.include "tiles.asm"

row_to_scanline_tbl:	; $1c51
				.db			0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121
				.db			132, 143, 154, 165, 181

col_to_addr_tbl:	; $1c62
				.db			0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16
				.db			17, 18, 20, 21, 22, 23, 25, 26, 27, 28, 30, 31, 32, 33

.include "title.asm"
.include "levels.asm"

				.end		start
			