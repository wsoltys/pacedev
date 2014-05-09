;
;	LODE RUNNER
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
       	.area   idaseg (ABS)

.define			COCO3
.define			DEBUG

.ifdef COCO3

;.define			HAS_TITLE
						
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

HGR1_MSB		.equ		0x00
HGR2_MSB		.equ		0x20

						.macro HGR1
						lda			#0xE0								; screen at page $38
						sta			VOFFMSB
						.endm

						.macro HGR2
						lda			#0xE4								; screen at page $39
						sta			VOFFMSB
						.endm
						
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
				lda			#0
				sta			*row
				sta			*attract_mode
				lda			#HGR1_MSB
				sta			*hires_page_msb_1
				sta			*display_char_page
.ifdef HAS_TITLE
; coco code is different now				
				ldy			#title_data
				lda			*hires_page_msb_1
				ldb			#0											; 2 centres the title screen
				tfr			d,x
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
.endif				
				HGR1
				jmp			title_wait_for_key

zero_score_and_init_game: ; $6056
				lda			#0
				sta			*score_1e1_1
				sta			*score_1e3_1e2
				sta			*score_1e5_1e4
				sta			*score_1e6
; store in zero page
				lda			#5											; number of lives
				sta			*no_lives
				lda			*attract_mode
				lsra
				;beq			loc_6099
				bra			loc_6099
; do some crap
				jmp			display_title_screen

loc_6099:	; $6099
				jsr			cls_and_display_game_status
				HGR1
main_game_loop:
				ldb			#1
				jsr			init_read_unpack_display_level
				lda			#0
				lda			*attract_mode
				lsra
				beq			1$
				;jsr			keybd_flush
				lda			*current_col
				sta			*col
				lda			*current_row
				sta			*row
				lda			#9											; player
				jsr			blink_char_and_wait_for_key
1$:	; $60bf
				ldb			#0
; stuff
in_level_loop:
				jsr			sub_64bd
; stuff
				bra			in_level_loop

next_level:
				bra			main_game_loop				

title_wait_for_key: ; $618e
;				jsr			keybd_flush
				ldb			#4											; timeout
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
				bne			1$											; no, loop
				ldb			#1
				stb			*attract_mode
				stb			*level
; do some other crap
				bra			zero_score_and_init_game

loc_61f6:
; stuff
				ldb			#0
; stuff
				incb
				stb			*level
; stuff
				lda			#2
				sta			*attract_mode
				bra			zero_score_and_init_game														

init_read_unpack_display_level:	; $6238
				stb			*unk_a2
				ldb			#0xff
				stb			*current_col						; flag no player
				incb														; B=0
				stb			*unk_a3
				stb			*no_gold
				stb			*packed_byte_cnt
; stuff				
				stb			*nibble_cnt
				stb			*row
; heaps of stuff
				jsr			read_level_data
				ldb			*row
5$:			ldy			#lsb_row_addr						; table for row LSB entries
				lda			b,y											; get entry for row
				sta			*lsb_row_level_data_addr
				sta			*byte_8
				ldy			#msb_row_addr_1					; table for MSB entries
				lda			b,y											; get entry for row
				sta			*msb_row_level_data_addr
				ldy			#msb_row_addr_2					; table for MSB entries (#2)
				lda			b,y											; get entry for row
				sta			*byte_9
				ldx			#level_data_packed			; was in disk buffer
				ldb			*packed_byte_cnt
				abx															; ptr packed byte
				lda			#0
				sta			*col										; col=0
4$:			lda			*nibble_cnt
				lsra
				lda			,x											; source (packed) byte
				bcs			1$											; do high nibble
				anda		#0x0f										; low nibble
				bra			2$
1$:			lsra
				lsra
				lsra
				lsra
				inc			*packed_byte_cnt
				inx															; source (packed) addr
2$:			inc			*nibble_cnt
				ldb			*col
				cmpa		#10											; data byte 0-9?
				bcs			3$											; yes, valid (skip)
				lda			#0											; invalid, ignore
3$:			ldy			*msb_row_level_data_addr
				sta			b,y											; destination (unpacked) byte
				ldy			*byte_9
				sta			b,y											; destination (unpacked) byte 2
				inc			*col
				ldb			*col
				cmpb		#28											; last column?
				bcs			4$											; no, loop
				inc			*row
				ldb			*row
				cmpb		#16											; last row?
				bcs			5$											; no, loop
				jsr			init_and_draw_level
				rts

read_level_data:	; $6264
; copies from disk buffer to low memory ($0D00)
				rts
				
init_and_draw_level: ; $63B3
				ldb			#15											; last row
				stb			*row
1$:			ldy			#lsb_row_addr
				lda			b,y											; get lsb of row
				sta			*lsb_row_level_data_addr
				sta			*byte_8
				ldy			#msb_row_addr_1
				lda			b,y											; get msb of row
				sta			*msb_row_level_data_addr
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9
				ldb			#27											; last column
				stb			*col
2$:			ldx			*msb_row_level_data_addr
				lda			b,x
				cmpa		#6											; end-of-screen ladder?
				bne			4$											; no, skip
; stuff				
3$:			lda			#0
				ldx			*msb_row_level_data_addr
				sta			b,x											; update tilemap
				ldx			*byte_9
				sta			b,x											; update tilemap
				bra			8$
4$:			cmpa		#7											; gold?
				bne			5$											; no, skip
				inc			*no_gold
				bra			8$
5$:			cmpa		#8											; enemy?
				bne			6$											; no, skip
				bra			8$											; fudge
6$:			cmpa		#9											; player?
				bne			7$											; no, skip
				tst			*current_col						; already got a player?
				bpl			3$											; yes, ignore
				stb			*current_col						; set player column
				lda			*row
				sta			*current_row						; set player row
				lda			#2
				sta			*x_offset_within_tile
				sta			*y_offset_within_tile
				lda			#8
				sta			*sprite_index
				lda			#0											; space
				ldx			*byte_9
				sta			b,x											; update tilemap
				lda			#9											; player
				bra			8$
7$:			cmpa		#5											; fall-thru?
				bne			8$											; no, skip
				lda			#1											; display diggable brick
8$:			jsr			display_char_pg2
				dec			*col
				ldb			*col
				bpl			2$
				dec			*row
				ldb			*row
				bpl			1$
				lda			*current_col
				bra			draw_level							; BPL!!!
				rts

draw_level:	; $648B
				jsr			wipe_or_draw_level
				rts

sub_64bd: ; $64bd
				bra			1$
1$:				
; stuff
				jsr			read_controls
				cmpa		#0xcc										; 'L'?
				bne			9$											; no, skip
				bra			move_right
9$:			rts

move_right: ; $6645
				ldb			*current_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				sta			*byte_8
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap & video addresses
				ldb			*x_offset_within_tile
				cmpb		#2
				bcc			can_move_right
				ldb			*current_col
				cmpb		#27											; right-most?
				beq			9$											; yes, exit
				incb														; next column
				ldy			#lsb_row_level_data_addr
				lda			b,y											; get tile data
				cmpa		#2											; solid?
				beq			9$											; yes, exit
				cmpa		#1											; brick?
				beq			9$											; yes, exit
				cmpa		#5											; fall-thru?
				bne			can_move_right					; no, continue				
9$:			rts

can_move_right: ; $6674
				jsr			calc_char_and_addr			; X(msb)=scanline
				jsr			wipe_char
				lda			#1
				sta			*dir										; set direction right
				;jsr			adjust_y_offset_within_tile
				inc			*x_offset_within_tile
				lda			*x_offset_within_tile
				cmpa		#5
				bcc			2$
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from filemap
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#1
1$:			ldy			#lsb_row_level_data_addr
				sta			b,y											; update tilemap
				inc			*current_col						; next tile
				incb
				lda			#9											; player
				sta			b,y											; update tilemap
				lda			#0
				sta			*x_offset_within_tile
				bra			3$
2$:			jsr			check_for_gold
3$:			ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#4											; rope?
				beq			4$											; yes, go
				lda			#8											; 1st sprite index (runner right)
				ldb			#0x0a										; last sprite index (runner right)								
				bra			5$
4$:			lda			#0x0b										; 1st sprite index (swinger right)
				ldb			#0x0d										; last sprite index (swinger right)
5$:			jsr			update_sprite_index
				jmp			draw_sprite				

sprite_to_char_tbl:	; $6968
				.db 		0xB, 0xC, 0xD, 0x18, 0x19, 0x1A, 0xF, 0x13, 9, 0x10, 0x11, 0x15, 0x16
				.db 		0x17, 0x25, 0x14, 0xE, 0x12, 0x1B, 0x1B, 0x1C, 0x1C, 0x1D, 0x1D, 0x1E
				.db 		0x1E, 0, 0, 0, 0, 0x26, 0x26, 0x27, 0x27, 0x1D, 0x1D, 0x1E, 0x1E, 0
				.db 		0, 0, 0, 0x1F, 0x1F, 0x20, 0x20, 0x21, 0x21, 0x22, 0x22, 0x23, 0x23
				.db 		0x24, 0x24, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x24, 0x24
				.db 		0x24, 0x24, 0x24, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 2, 2, 1
								
; Coco Keyboard
;    7  6  5  4  3  2  1  0
;	0: G  F  E  D  C  B  A  @
; 1: O  N  M  L  K  J  I  H
; 2: W  V  U  T  S  R  Q  P
; 3: SP RT LT DN UP Z  Y  X
; 4: '  &  %  $  #  "  !  0
; 4: 7  6  5  4  3  2  1  0
; 5: ?  >  =  <  +  *  )  (
; 5: /  .  _  ,  ;  :  9  8
; 6: SH F2 F1 CT AL BK CL CR

page:		.db			0

read_controls:	; $6a12
.ifdef DEBUG
				ldx			#PIA0
				ldb			#~(1<<0)								; col0
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<6)									; <ENTER>?
				bne			check_attract
				lda			page
				coma		
				sta			page
				bne			1$
				HGR1
				bra			2$
1$:			HGR2
2$:			lda			,x											; active low
				bita		#(1<<6)
				beq			2$											; wait for key release
.endif
check_attract:
				lda			*attract_mode
				cmpa		#1
				;beq			loc_68b8
1$:				
				ldx			#PIA0
				ldb			~(1<<4)									; col4
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#2											; 'L'?
				bne			2$											; no, skip
				lda			#0xcc										; 'L'
2$:				
				rts

calc_char_and_addr:	; $6b85
				ldb			*current_col
				lda			*x_offset_within_tile
				jsr			calc_x_in_2_pixel_incs
				stb			*msg_char								; store x_in_2_pixel_incs
				lda			*current_row
				ldb			*y_offset_within_tile
				jsr			calc_scanline						; A=scanline
				tfr			d,x											; X(msb)=scanline
				ldb			*sprite_index
				ldy			#sprite_to_char_tbl
				lda			b,y											; A=lookup char from sprite
				ldb			*msg_char								; restore x_in_2_pixel_incs
				rts

check_for_gold: ; $6b9d
				rts
								
update_sprite_index: ; $6bf4
				rts
				
draw_sprite: ; $6c02
				rts
																								
gcls1: ; $7A51
				lda			#HGR1_MSB
				ldb			#0
				tfr			d,x											; start addr
				adda		#0x20
				tfr			d,y											; end addr
				bra			gcls
gcls2:
				lda			#HGR2_MSB
				ldb			#0
				tfr			d,x											; start addr
				adda		#0x20
				tfr			d,y											; end addr
gcls:		sty			*byte_a
				lda			#0x00
1$:			sta			,x+
				cmpx		*byte_a
				bne			1$
				rts

cls_and_display_game_status:	; $79AD
				jsr			gcls1
				jsr			gcls2
				lda			*display_char_page			; 0x00/0x20
				ora			#0x1b
				ldb			#0x80										; 0x1b80 = offset
				tfr			d,x				
				lda			#0xaa										; pattern
				ldb			#34											; last column on screen
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

get_line_addr_pgs_1_2: ; $7A3E
				lda			#40
				mul
				stb			*lsb_line_addr_pg1
				stb			*lsb_line_addr_pg2
				ora			HGR1_MSB
				sta			*msb_line_addr_pg1
				eora		HGR1_MSB | HGR2_MSB
				sta			*msb_line_addr_pg2
				rts
				
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
				ldb			*display_char_page
				cmpb		#HGR2_MSB								; page 2?
				beq			1$											; yes, skip
				jsr			display_char_pg1
				inc			*col
				rts
1$:			jsr			display_char_pg2
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
				ldb			*display_char_page
				cmpb		#HGR2_MSB								; page 2?
				beq			1$											; yes, skip
				jsr			display_char_pg1
				inc			*col
				rts
1$:			jsr			display_char_pg2
				inc			*col
				rts

cr: ; 7B7D
				inc			*row										; next row
				lda			#0
				sta			*col										; col=0
				rts

display_char_pg1:	; $82AA
				sta			*msg_char
				lda			#HGR1_MSB
				bra			display_char
display_char_pg2: ; $82B0
				sta			*msg_char
				lda			#HGR2_MSB
display_char:				
				sta			*hires_page_msb_1
				ldb			*row
				jsr			calc_colx5_scanline			; B=scanline
				stb			*scanline
				ldb			*col
				jsr			calc_col_addr_shift
				sta			*col_addr_offset
				stb			*col_pixel_shift
				lsrb
				ldx			#left_char_masks
				lda			b,x
				sta			*lchar_mask
				ldx			#right_char_masks
				lda			b,x
				sta			*rchar_mask
				jsr			render_char_in_buffer
				ldx			#char_render_buf
				lda			*scanline
				ldb			#40
				mul
				ora			*hires_page_msb_1				; OR-in page address
				tfr			d,y
				ldb			*col_addr_offset
				leay		b,y
				ldb			#11
2$:			lda			0,y
				anda		*lchar_mask
				ora			,x+
				sta			0,y
				lda			1,y
				anda		*rchar_mask
				ora			,x+
				sta			1,y
				leay		40,y
				decb
				bne			2$
				rts

left_char_masks:	; $8328
				.db			0x00, 0xc0, 0xf0, 0xfc
right_char_masks:	; $832F
				.db			0x3f, 0x0f, 0x03, 0x00

wipe_char:	; $8336
				exg			d,x				
				sta			*scanline
				exg			d,x
				sta			*msg_char
				jsr			calc_addr_shift_for_x
				sta			*col_addr_offset
				stb			*col_pixel_shift
				jsr			render_char_in_buffer
				ldb			#11
				stb			*scanline_cnt
				ldb			#0
				lda			*col_pixel_shift
wipe_2_byte_char_from_video:
				ldb			*scanline
				jsr			get_line_addr_pgs_1_2
				ldb			*col_addr_offset
				ldy			#char_render_buf
				lda			b,y
				coma
				ldy			#lsb_line_addr_pg1
				anda		b,y
				ldx			#lsb_line_addr_pg2
				ora			b,x
				sta			b,y
				leay		1,y
				incb
				ldy			#char_render_buf
				lda			b,y
				coma
				ldy			#lsb_line_addr_pg1
				anda		b,y
				ldx			#lsb_line_addr_pg2
				ora			b,x
				sta			b,y
				leay		1,y
				inc			*scanline
				dec			*scanline_cnt
				bne			wipe_2_byte_char_from_video			
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

blink_char_and_wait_for_key:	; $8700
				sta			blink_char
1$:			lda			#0x68
				sta			*timer
				lda			#0											; space
				ldb			blink_char
				bne			2$											; not a space, skip
				lda			#0x0a										; solid square
2$:			jsr			display_char_pg1
3$:			ldx			#PIA0
				ldb			#0											; all columns
				stb			2,x											; column strobe
				lda			,x
				coma														; any key pressed?
				bne			blink_got_key						; yes, exit
; read keyboard
				dec			*timer									; timeout?
				bne			3$											; no, loop
				lda			blink_char
				jsr			display_char_pg1
				lda			#0x68
				sta			*timer
; read keyboard
4$:
				dec			*timer								; timeout?
				bne			4$										; no, loop
				bra			1$										; loop waiting for key

blink_got_key:
				pshs		a
				lda			blink_char
				jsr			display_char_pg1
				puls		a
				rts
				
blink_char:
				.db			6
								
read_paddles: ; $87A2
				lda			#0xcb										; no paddles detected?
				sta			*paddles_detected
				rts

calc_colx5_scanline:	; $885d
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

calc_addr_shift_for_x:	; $8872
				ldy			#movement_offset_to_addr_tbl
				lda			b,y
				pshs		a
				ldy			#movement_offset_to_shift_tbl
				lda			b,y
				tfr			b,a
				puls		a
				rts
				
calc_scanline: ; $887C
				pshs		b												; save y_offset_within_tile
				jsr			calc_colx5_scanline
				puls		b												; restore y_offset_within_tile
				ldy			#byte_888a
				adda		b,y											; A=scanline
				rts

byte_888a:
				.db			-5, -3, 0, 2, 4
								
calc_x_in_2_pixel_incs: ; $888F
				pshs		a												; save x_offset_within_tile
				jsr			calc_colx5_scanline			; B=colx5
				puls		a												; restore x_offset_within_tile
				ldy			#byte_889d
				addb		a,y											; B=x as count of 2-pixel increments
				rts

byte_889d:
				.db			-1, -2, 0, 1, 2
								
wipe_or_draw_level:	; $88A2
; nothing like the 6502 code!
				lda			#HGR2_MSB
				clrb
				tfr			d,x
				adda		#0x1b
				orb			#0x80										; end addr (line 176)
				tfr			d,y
				sty			*byte_a
				lda			#HGR1_MSB
				clrb
				tfr			d,y
1$:			lda			,x+
				sta			,y+
				cmpx		*byte_a
				bne			1$
				rts
					
; zero-page registers
.include "zeropage.asm"

lsb_row_addr:	; $1C05
					.db		<(ldu1+0*28), <(ldu1+1*28), <(ldu1+2*28), <(ldu1+3*28)
					.db		<(ldu1+4*28), <(ldu1+5*28), <(ldu1+6*28), <(ldu1+7*28)
					.db		<(ldu1+8*28), <(ldu1+9*28), <(ldu1+10*28), <(ldu1+11*28)
					.db		<(ldu1+12*28), <(ldu1+13*28), <(ldu1+14*28), <(ldu1+15*28)
msb_row_addr_1: ; $1C15
					.db		>(ldu1+0*28), >(ldu1+1*28), >(ldu1+2*28), >(ldu1+3*28)
					.db		>(ldu1+4*28), >(ldu1+5*28), >(ldu1+6*28), >(ldu1+7*28)
					.db		>(ldu1+8*28), >(ldu1+9*28), >(ldu1+10*28), >(ldu1+11*28)
					.db		>(ldu1+12*28), >(ldu1+13*28), >(ldu1+14*28), >(ldu1+15*28)
msb_row_addr_2:	; $1C25
					.db		>(ldu2+0*28), >(ldu2+1*28), >(ldu2+2*28), >(ldu2+3*28)
					.db		>(ldu2+4*28), >(ldu2+5*28), >(ldu2+6*28), >(ldu2+7*28)
					.db		>(ldu2+8*28), >(ldu2+9*28), >(ldu2+10*28), >(ldu2+11*28)
					.db		>(ldu2+12*28), >(ldu2+13*28), >(ldu2+14*28), >(ldu2+15*28)

row_to_scanline_tbl:	; $1c51
				.db			0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121
				.db			132, 143, 154, 165, 181

col_to_addr_tbl:	; $1c62
				.db			0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16
				.db			17, 18, 20, 21, 22, 23, 25, 26, 27, 28, 30, 31, 32, 33

movement_offset_to_addr_tbl:	; $1C9A
				.db 		0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5
				.db 		5, 6, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 0xA, 0xA, 0xA, 0xA
				.db 		0xB, 0xB, 0xB, 0xC, 0xC, 0xC, 0xC, 0xD, 0xD, 0xD, 0xE, 0xE, 0xE, 0xE, 0xF
				.db 		0xF, 0xF, 0x10, 0x10, 0x10, 0x10, 0x11, 0x11, 0x11, 0x12, 0x12, 0x12, 0x12
				.db 		0x13, 0x13, 0x13, 0x14, 0x14, 0x14, 0x14, 0x15, 0x15, 0x15, 0x16, 0x16
				.db 		0x16, 0x16, 0x17, 0x17, 0x17, 0x18, 0x18, 0x18, 0x18, 0x19, 0x19, 0x19
				.db 		0x1A, 0x1A, 0x1A, 0x1A, 0x1B, 0x1B, 0x1B, 0x1C, 0x1C, 0x1C, 0x1C, 0x1D
				.db 		0x1D, 0x1D, 0x1E, 0x1E, 0x1E, 0x1E, 0x1F, 0x1F, 0x1F, 0x20, 0x20, 0x20
				.db 		0x20, 0x21, 0x21, 0x21, 0x22, 0x22, 0x22, 0x22, 0x23, 0x23, 0x23, 0x24
				.db 		0x24, 0x24, 0x24, 0x25, 0x25, 0x25, 0x26, 0x26, 0x26, 0x26, 0x27, 0x27
				.db 		0x27
movement_offset_to_shift_tbl:	; $1D26
				.db 		0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3
				.db 		5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1
				.db 		3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6
				.db 		1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4
				.db 		6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2
				.db 		4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0
				.db 		2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5, 0, 2, 4, 6, 1, 3, 5

; 			.nlist
; .include "tiles.asm"
; .include "title.asm"
; .include "levels.asm"

				.nlist
				
.include "tiles.asm"
.ifdef HAS_TITLE
	.include "title.asm"
.endif
.include "levels.asm"

				.list

; this was in low memory on the apple
				.bndry	512
level_data_unpacked_1:
ldu1:
				.ds			512
level_data_unpacked_2:
ldu2:
				.ds			512
				
				.end		start
			