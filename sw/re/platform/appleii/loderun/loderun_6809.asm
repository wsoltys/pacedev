;
;	LODE RUNNER
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			COCO3
.define			DEBUG

						.macro	CLC
						andcc		#~(1<<0)
						.endm
						.macro	SEC
						orcc		#(1<<0)
						.endm

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
				sta			*level_0_based
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
				HGR1
				jmp			title_wait_for_key
.else
				jmp			loc_61f6				
.endif				

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
				stb			*dig_dir
; stuff
in_level_loop:
				jsr			handle_player						; digging, falling, keys
; stuff
				lda			*no_gold
				bne			1$
				jsr			draw_end_of_screen_ladder
1$:			lda			*current_row
				bne			2$											; not top row
				lda			*y_offset_within_tile
				cmpa		#2
				bne			2$											; not top of tile
				lda			*no_gold								; any gold left?
				beq			next_level							; no, go
				cmpa		#0xff										; issue with eos ladder?
				beq			next_level							; yes, go
2$:				
				
.if 1
; delay for Coco
				ldx			#8000
9$:			dex
				bne			9$
.endif
.if 0
9$:			ldx			#PIA0
				ldb			#0											; all columns
				stb			2,x											; column strobe
				lda			,x
				coma														; any key pressed?
				bne			9$											; yes, loop
.endif				
				bra			in_level_loop

next_level:
				inc			*level									; next level
				inc			*level_0_based					; used for reading level data
				inc			*no_lives								; extra life
				bne			3$											; skip if no wrap
				dec			*no_lives								; =255
3$:			ldb			#15
				stb			*byte_5c
4$:			ldb			#1
				lda			#0											; add 100
				jsr			update_and_display_score
				dec			*byte_5c
				bne			4$											; add 1500
				jmp			main_game_loop				

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
				lbra		zero_score_and_init_game

loc_61e4:	; $61E4
				lda			#1
				;jsr			sub_6359								; disk access
loc_61e8: ; $61E9
				;jsr			cls_and_display_high_scores
				lda			#2
				sta			*attract_mode
				jmp			title_wait_for_key				

loc_61f3:	; $61F3
				jmp			display_title_screen
				
loc_61f6: ; $61F6
; check for 'e' key for editor (not supported)
				ldx			#PIA0
				ldb			#~(1<<0)								; col0
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		(1<<6)									; <ENTER>?
				beq			loc_61e4								; yes, go
				ldb			#0
				stb			*level_0_based
				incb
				stb			*level
				;stb			*byte_9d
				lda			#2
				sta			*attract_mode
				jmp			zero_score_and_init_game														

init_read_unpack_display_level:	; $6238
				stb			*unk_a2
				ldb			#0xff
				stb			*current_col						; flag no player
				incb														; B=0
				stb			*no_eos_ladder_tiles
				stb			*no_gold
				stb			*dig_sprite
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
; stuff
				ldb			#0
				stb			*level_0_based				
; stuff				
				rts

read_level_data:	; $6264
; copies from disk buffer to low memory ($0D00)
; stuff
				lda			*level
				deca
				adda		#>demo_level_data
				sta			*msb_line_addr_pg1
				lda			#<demo_level_data
				sta			*lsb_line_addr_pg1
; nothing like original code from here-on in				
				ldx			*msb_line_addr_pg1
				ldy			#level_data_packed
				clrb
copy_level_data:
				lda			,x+
				sta			,y+
				decb
				bne			copy_level_data
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
				ldb			*no_eos_ladder_tiles
				cmpb		#0x4d										; max?
				bcc			3$											; yes, skip
				inc			*no_eos_ladder_tiles
				incb
				lda			*row
				ldy			#eos_ladder_row
				sta			b,y											; store row
				lda			*col
				ldy			#eos_ladder_col
				sta			b,y											; store col
				tfr			a,b											; B=col
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
				lbpl		1$
				lda			*current_col
				bra			draw_level							; BPL!!!
				rts

draw_level:	; $648B
				jsr			wipe_or_draw_level
				ldb			#15											; last row
				stb			*row
1$:			ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr
				ldb			#27											; last column
				stb			*col			
2$:			ldy			*msb_row_level_data_addr
				lda			b,y											; get tilemap data
				cmpa		#9											; player?
				beq			3$											; yes, continue
				cmpa		#8											; enemy?
				bne			4$											; no, skip
3$:			lda			#0											; space
				jsr			display_char_pg2				; wipe player & enemies from bg
4$:			dec			*col
				ldb			*col										; done all columns?
				bpl			2$											; no, loop
				dec			*row
				ldb			*row										; done all rows?
				bpl			1$											; no, loop
				CLC
				rts

handle_player: ; $64bd
				lda			#1
				;sta			unk_94
				lda			*dig_dir
				beq			not_digging
				bpl			1$											; digging right
				jmp			digging_left
1$:			jmp			digging_right
not_digging:	; $64CD
				ldb			*current_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; update tilemap addr
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#3											; ladder?
				beq			cant_fall								; yes, exit
				cmpa		#4											; rope?
				bne			check_falling						; no, skip
				lda			*y_offset_within_tile
				cmpa		#2
				beq			cant_fall
check_falling:	; $64EB				
				lda			*y_offset_within_tile
				cmpa		#2
				bcs			handle_falling
				ldb			*current_row
				cmpb		#15											; bottom row?
				beq			cant_fall								; yes, skip
				ldy			#lsb_row_addr+1
				lda			b,y
				sta			*lsb_row_level_data_addr
				sta			*byte_8
				ldy			#msb_row_addr_1+1
				lda			b,y
				sta			*msb_row_level_data_addr
				ldy			#msb_row_addr_2+1
				lda			b,y
				sta			*byte_9									; setup tilemap address to row below
				ldb			*current_col
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#0											; space?
				beq			handle_falling					; yes, go
				cmpa		#8											; enemy?
				beq			cant_fall								; yes, go
				ldy			*byte_9									
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				beq			cant_fall								; yes, go
				cmpa		#2											; solid?
				beq			cant_fall								; yes, go
				cmpa		#3											; ladder?
				bne			handle_falling					; no, go
cant_fall:
				jmp			check_falling_sound				
				
handle_falling:	; $6525
				lda			#0
				sta			*unk_9b
				jsr			calc_char_and_addr
				jsr			wipe_char
				lda			#7											; char=0x13 (fall left)
				ldb			*dir										; left?
				bmi			1$											; yes, skip
				lda			#0x0f										; char=0x0f (fall right)
1$:			sta			*sprite_index
				jsr			adjust_x_offset_in_tile
				inc			*y_offset_within_tile
				lda			*y_offset_within_tile
				cmpa		#5											; >=5?
				bcc			fall_check_row_below		; yes, skip
				jsr			check_for_gold
				jmp			draw_sprite

fall_check_row_below:	; $654A
				lda			#0
				sta			*y_offset_within_tile
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
				sta			*byte_9									; setup tilemap address
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap				
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#0											; space
1$:			ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				inc			*current_row
				ldb			*current_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr	; setup tilemap address
				ldb			*current_col
				lda			#9											; player
				ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				jmp			draw_sprite

check_falling_sound:	; $6584
				lda			*unk_9b
				bne			check_controls
				lda			#0x64
				ldb			#8
				jsr			play_falling_sound
check_controls:	; $658F				
				lda			#0x20
				;sta			*byte_a4
				sta			*unk_9b
				jsr			read_controls
				;lda			*unk_9e
				cmpa		#0xc9										; 'I'?
				bne			check_down_key					; no, skip
				jsr			move_up
				bcs			check_left_key
				rts
check_down_key:
				cmpa		#0xcb										; 'K'?
				bne			check_dig_left_key			; no, skip
				jsr			move_down
				bcs			check_left_key
				rts
check_dig_left_key:
				cmpa		#0xd5										; U'?
				bne			check_dig_right_key			; no, skip
				jsr			dig_left
				bcs			check_left_key
				rts
check_dig_right_key:
				cmpa		#0xcf										; 'O'?
				bne			check_left_key					; no, skip
				jsr			dig_right
				bcs			check_left_key
				rts
check_left_key:
;				lda			unk_9f
				cmpa		#0xca										; 'J'?
				bne			check_right_key					; no, skip
				jmp			move_left
check_right_key:				
				cmpa		#0xcc										; 'L'?
				bne			no_keys									; no, skip
				jmp			move_right
no_keys:				
				rts

move_left: ; 65D3
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
				cmpb		#3
				bcc			can_move_left
				ldb			*current_col
				beq			9$											; left-most? yes, exit
				decb														; previous column
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tile data
				cmpa		#2											; solid?
				beq			9$											; yes, exit
				cmpa		#1											; brick?
				beq			9$											; yes, exit
				cmpa		#5											; fall-thru?
				bne			can_move_left						; no, continue				
9$:			rts
				
can_move_left: ; $6600
				jsr			calc_char_and_addr			; X(lsb)=scanline
				jsr			wipe_char
				lda			#-1
				sta			*dir										; set direction right
				jsr			adjust_y_offset_within_tile
				dec			*x_offset_within_tile
				bpl			2$
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from filemap
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#0
1$:			ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				dec			*current_col						; previous tile
				decb
				lda			#9											; player
				sta			b,y											; update tilemap
				lda			#4
				sta			*x_offset_within_tile
				bra			3$
2$:			jsr			check_for_gold
3$:			ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#4											; rope?
				beq			4$											; yes, go
				lda			#0											; 1st sprite index (runner left)
				ldb			#2											; last sprite index (runner left)								
				bra			5$
4$:			lda			#3											; 1st sprite index (swinger left)
				ldb			#5											; last sprite index (swinger left)
5$:			jsr			update_sprite_index
				jmp			draw_sprite				

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
				bcs			can_move_right
				ldb			*current_col
				cmpb		#27											; right-most?
				beq			9$											; yes, exit
				incb														; next column
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tile data
				cmpa		#2											; solid?
				beq			9$											; yes, exit
				cmpa		#1											; brick?
				beq			9$											; yes, exit
				cmpa		#5											; fall-thru?
				bne			can_move_right					; no, continue				
9$:			rts

can_move_right: ; $6674
				jsr			calc_char_and_addr			; X(lsb)=scanline
				jsr			wipe_char
				lda			#1
				sta			*dir										; set direction right
				jsr			adjust_y_offset_within_tile
				inc			*x_offset_within_tile
				lda			*x_offset_within_tile
				cmpa		#5
				bcs			2$
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from filemap
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#0
1$:			ldy			*msb_row_level_data_addr
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

move_up: ; $66BD
				ldb			*current_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#3											; ladder?
				beq			check_move_up						; yes, go
				ldb			*y_offset_within_tile
				cmpb		#3											; <3?
				bcs			cant_move_up						; yes, exit
				ldb			*current_row
				ldy			#lsb_row_addr+1					; row below???
				lda			b,y											; get object from tilemap
				sta			*byte_8
				ldy			#msb_row_addr_2+1				; row below?
				lda			b,y											; get object from tilemap
				sta			*byte_9
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#3											; ladder?
				beq			can_move_up
cant_move_up:	; $66EB
				SEC
				rts
				
check_move_up:	; $66ED				
				ldb			*y_offset_within_tile
				cmpb		#3											; >=3?
				bcc			can_move_up							; yes, go
				ldb			*current_row
				beq			cant_move_up						; top row? yes, exit
				ldy			#lsb_row_addr-1
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1-1
				lda			b,y
				sta			*msb_row_level_data_addr	; adjust tilemap address to row above
				ldb			*current_col
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				beq			cant_move_up						; yes, exit
				cmpa		#2											; solid?
				beq			cant_move_up						; yes, exit
				cmpa		#5											; fall-thru?
				beq			cant_move_up						; yes, exit
				
can_move_up:
				jsr			calc_char_and_addr
				jsr			wipe_char
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
				sta			*byte_9									; setup tilemap and video address
				jsr			adjust_x_offset_in_tile
				dec			*y_offset_within_tile
				bpl			climber_check_for_gold	; change tiles? no, skip
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#0											; space
1$:			ldy			*msb_row_level_data_addr
				lda			b,y
				dec			*current_row
				ldb			*current_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr
				ldb			*current_col
				lda			#9											; player
				ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				lda			#4
				sta			*y_offset_within_tile
				bra			update_climber_sprite
climber_check_for_gold:
				jsr			check_for_gold
update_climber_sprite:
				lda			#0x10										; 1st sprite index (climber)
				ldb			#0x11										; last sprite index (climber)
				jsr			update_sprite_index
				jsr			draw_sprite
				CLC															; flag able to move
				rts

move_down:	; $6766
				ldb			*y_offset_within_tile
				cmpb		#2
				bcs			can_move_down
				ldb			*current_row
				cmpb		#15											; bottom row?
				bcc			cant_move_down					; yes, exit
				ldy			#lsb_row_addr+1					; row below
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1+1
				lda			b,y
				sta			*msb_row_level_data_addr	; adjust tilemap address for row below
				ldb			*current_col
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#2											; solid?
				beq			cant_move_down					; yes, exit
				cmpa		#1											; brick?
				bne			can_move_down						; no, go
cant_move_down:	; $6788
				SEC															; flag unable to move
				rts				

can_move_down:	; $678A
				jsr			calc_char_and_addr
				jsr			wipe_char
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
				sta			*byte_9
				jsr			adjust_x_offset_in_tile
				inc			*y_offset_within_tile
				lda			*y_offset_within_tile
				cmpa		#5											; <5?
				bcs			2$											; yes, skip
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#0
1$:			ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				inc			*current_row						; row below
				ldb			*current_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr	; update tilemap address
				ldb			*current_col
				lda			#9											; player
				ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				lda			#0
				sta			*y_offset_within_tile
				jmp			update_climber_sprite
2$:			jmp			climber_check_for_gold				
				
sprite_to_char_tbl:	; $6968
				.db 		0xB, 0xC, 0xD, 0x18, 0x19, 0x1A, 0xF, 0x13, 9, 0x10, 0x11, 0x15, 0x16
				.db 		0x17, 0x25, 0x14, 0xE, 0x12, 0x1B, 0x1B, 0x1C, 0x1C, 0x1D, 0x1D, 0x1E
				.db 		0x1E, 0, 0, 0, 0, 0x26, 0x26, 0x27, 0x27, 0x1D, 0x1D, 0x1E, 0x1E, 0
				.db 		0, 0, 0, 0x1F, 0x1F, 0x20, 0x20, 0x21, 0x21, 0x22, 0x22, 0x23, 0x23
				.db 		0x24, 0x24, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x24, 0x24
				.db 		0x24, 0x24, 0x24, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 2, 2, 1

loc_67d8:	; $67D8
				;jmp			loc_6892
				rts
				
dig_left:	; $67db
				lda			#0xff
				sta			*dig_dir
				;sta			*unk_9e
				;sta			*unk_9f
				lda			#0
				sta			*dig_sprite
digging_left:
				ldb			*current_row
				cmpb		#15											; bottom row?
				bcc			loc_67d8								; yes, exit
				incb														; row below
				jsr			set_row_addr_1_2
				ldb			*current_col
				beq			loc_67d8								; left-most edge? yes, exit
				decb														; column to the left
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tilemap data (below, left)
				cmpa		#1											; brick?
				bne			loc_67d8								; no, exit
				ldb			*current_row
				jsr			set_row_addr_1_2
				ldb			*current_col
				decb														; column to the left
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tilemap data (left)
				cmpa		#0											; space?
				lbne		loc_686e								; no, go
				jsr			calc_char_and_addr
				jsr			wipe_char
				jsr			adjust_x_offset_in_tile
				jsr			adjust_y_offset_within_tile
				ldb			*dig_sprite
				ldy			#sprite_to_char_tbl+0x36
				lda			b,y
				pshs		a
				ldy			#sprite_to_char_tbl+0x43
				lda			b,y
				puls		b
				;jsr			sub_87d5
				ldb			*dig_sprite
				lda			#0											; sprite=0, tile=$B (running left)
				cmpb		#6
				bcc			1$
				lda			#6
1$:			sta			*sprite_index
				jsr			draw_sprite
				ldb			*dig_sprite
				cmpb		#0x0c
				beq			loc_6898
				cmpb		#0
				beq			2$
				ldy			#sprite_to_char_tbl+0x11
				lda			b,y
				pshs		a
				lda			*current_col
				deca
				ldb			*current_row
				jsr			calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				puls		a												; A=char
				jsr			wipe_char
				ldb			*dig_sprite
2$:			ldy			#sprite_to_char_tbl+0x12
				lda			b,y
				pshs		a
				lda			*current_col				
				deca
				sta			*col
				ldb			*current_row
				stb			*row
				jsr			calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				puls		a												; A=char
				jsr			display_transparent_char
				ldb			*dig_sprite
				ldy			#sprite_to_char_tbl+0x2a
				lda			b,y
				inc			*row
				jsr			display_char_pg1
				inc			*dig_sprite
				CLC															; flag
				rts

loc_686e:	; $686E
				SEC
				rts

loc_6898: ; $6898
				ldb			*current_col
				decb
				jmp			loc_6c39
												
dig_right: ; 68a1
				lda			#1
				sta			*dig_dir
digging_right:				
;stuff				
				CLC															; flag
				rts
																
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
				ldb			#~(1<<1)								; col1
				stb			2,x											; columns strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'JI?
				bne			2$											; no, skip
				lda			#0xc9										; 'I'
				rts
2$:			ldb			#~(1<<2)								; col2
				stb			2,x											; columns strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'J'?
				bne			3$											; no, skip
				lda			#0xca										; 'J'
				rts
3$:			ldb			#~(1<<3)								; col3
				stb			2,x											; columns strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'K'?
				bne			4$											; no, skip
				lda			#0xcb										; 'K'
				rts
4$:			ldb			#~(1<<4)								; col4
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'L'?
				bne			5$											; no, skip
				lda			#0xcc										; 'L'
				rts
5$:			ldb			#~(1<<5)								; col5
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<2)									; 'U'?
				bne			6$											; no, skip
				lda			#0xd5										; 'U'
				rts
6$:			ldb			#~(1<<7)								; col7
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'O'?
				bne			7$											; no, skip
				lda			#0xcf										; 'O'
				rts
7$:				
				rts

calc_char_and_addr:	; $6b85
				lda			*current_col
				ldb			*x_offset_within_tile
				jsr			calc_x_in_2_pixel_incs
				stb			*msg_char								; store x_in_2_pixel_incs
				ldb			*current_row
				lda			*y_offset_within_tile
				jsr			calc_scanline						; B=scanline
				tfr			d,x											; X(lsb)=scanline
				ldb			*sprite_index
				ldy			#sprite_to_char_tbl
				lda			b,y											; A=lookup char from sprite
				ldb			*msg_char								; restore x_in_2_pixel_incs
				rts

check_for_gold: ; $6b9d
				lda			*x_offset_within_tile
				cmpa		#2											; offset=2?
				bne			9$											; no, return
				lda			*y_offset_within_tile
				cmpa		#2											; offset=2?
				bne			9$											; no, return
				ldb			*current_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*current_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#7											; gold?
				bne			9$											; no, exit
				;lsr		unk_94
				dec			*no_gold
				ldb			*current_row
				stb			*row
				ldb			*current_col
				stb			*col
				lda			#0											; space
				ldy			*byte_9
				sta			b,y											; wipe gold from tilemap
				jsr			display_char_pg2				; wipe gold from bg page
				ldb			*row
				lda			*col
				jsr			calc_colx5_scanline			; A=col*5, B=scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				lda			#7											; gold
				jsr			wipe_char								; from video display
				ldb			#2
				lda			#0x50										; add 250
				jsr			update_and_display_score
				;jsr		sub_87e1								; sound
9$:			rts
								
update_sprite_index: ; $6bf4
; A=1st, B=last
				inc			*sprite_index
				cmpa		*sprite_index
				bcs			2$
1$:			sta			*sprite_index				
				rts
2$:			cmpb		*sprite_index
				bcs			1$
				rts				
				
draw_sprite: ; $6c02
				jsr			calc_char_and_addr
				jsr			display_transparent_char
				rts

adjust_x_offset_in_tile:	; $6C13
				lda			*x_offset_within_tile
				cmpa		#2
				bcs			1$
				beq			2$
				dec			*x_offset_within_tile
				jmp			check_for_gold
1$:			inc			*x_offset_within_tile
				jmp			check_for_gold
2$:			rts

adjust_y_offset_within_tile: ; $6C26
				lda			*y_offset_within_tile
				cmpa		#2
				bcs			1$
				beq			2$
				dec			*y_offset_within_tile
				jmp			check_for_gold
1$:			inc			*y_offset_within_tile
				jmp			check_for_gold				
2$:			rts

loc_6c39:	; $6C39
				lda			#0
				sta			*byte_9c
				lda			*current_row
				inca														; row below
				stb			*col
				sta			*row
				exg			a,b											; A=col, B=row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr
				lda			#0											; space
				ldb			*col
				ldy			*msb_row_level_data_addr
				sta			b,y
				jsr			display_char_pg1
				lda			#0											; space
				jsr			display_char_pg2
				dec			*row										; row above
				lda			#0											; space
				jsr			display_char_pg1
				inc			*row										; row below
				ldb			#0xff
1$:			incb
				cmpb		#0x1e
				beq			2$
;stuff
				SEC									
2$:			rts
																																
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
				ora			#HGR1_MSB
				sta			*msb_line_addr_pg1
				eora		#(HGR1_MSB | HGR2_MSB)
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
				pshs		b
				adda		*score_1e1_1
				daa     		
				sta			*score_1e1_1
				puls		a
				adca		*score_1e3_1e2
				daa     		
				sta			*score_1e3_1e2
				lda			*score_1e5_1e4
				adca		#0
				daa
				sta			*score_1e5_1e4
				lda			*score_1e6
				adca		#0
				daa
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
; A=char
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
; A=char, B=x_in_2_pixel_incs, X(lsb)=scanline
				exg			d,x				
				stb			*scanline
				exg			d,x
				sta			*msg_char
				jsr			calc_addr_shift_for_x		; A=addr, B=shift
				sta			*col_addr_offset
				stb			*col_pixel_shift
				jsr			render_char_in_buffer
				ldb			#11
				stb			*scanline_cnt
;				ldb			#0
				ldy			#char_render_buf
				lda			*col_pixel_shift
wipe_2_byte_char_from_video:
				ldb			*scanline
				jsr			get_line_addr_pgs_1_2
				lda			,y+											; get data from render buffer
				coma														; invert character data
				ldb			*col_addr_offset
				ldx			*msb_line_addr_pg1
				pshs		x
				anda		b,x											; mask off character
				ldx			*msb_line_addr_pg2
				ora			b,x											; OR-in background
				puls		x
				sta			b,x											; update video byte
				incb														; next byte
				lda			,y+											; get data from render buffer
				coma														; invert character data
				ldx			*msb_line_addr_pg1
				pshs		x
				anda		b,x											; mask off character
				ldx			*msb_line_addr_pg2
				ora			b,x											; OR-in background
				puls		x
				sta			b,x											; update video byte
				inc			*scanline
				dec			*scanline_cnt
				bne			wipe_2_byte_char_from_video			
				rts

display_transparent_char:	; $83A7
; A=char, B=x_in_2_pixel_incs, X(lsb)=scanline
				exg			d,x											; X(lsb)=scanline
				stb			*scanline
				exg			d,x
				sta			*msg_char								
				jsr			calc_addr_shift_for_x
				sta			*col_addr_offset
				stb			*col_pixel_shift
				jsr			render_char_in_buffer
				lda			#11
				sta			*scanline_cnt
				lda			#0
				sta			*byte_52
				ldx			#char_render_buf
OR_2_byte_char_to_video:	; $83C3
				ldb			*scanline
				jsr			get_line_addr_pgs_1_2				
				ldb			*col_addr_offset
				ldy			*msb_line_addr_pg1
				lda			b,y											; get video byte
				ldy			*msb_line_addr_pg2
				eora		b,y											; background
				anda		,x											; char render buf
				ora			*byte_52
				sta			*byte_52
				lda			,x											; get byte to be rendered
				ldy			*msb_line_addr_pg1
				ora			b,y
				sta			b,y											; update video byte
				inx															; next render buffer address
				incb														; next video address
				lda			b,y
				ldy			*msb_line_addr_pg2
				eora		b,y
				anda		,x
				ora			*byte_52
				sta			*byte_52
				lda			,x											; get byte to be rendered
				ldy			*msb_line_addr_pg1
				ora			b,y
				sta			b,y											; update video byte
				inx															; next render buffer address
				inc			*scanline
				dec			*scanline_cnt
				bne			OR_2_byte_char_to_video
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

draw_end_of_screen_ladder:	; $8631
				lda			#0
				sta			eos_ladder_col					; flag ladder OK
				ldb			*no_eos_ladder_tiles
				stb			no_eos_ladder_entries
1$:			ldb			no_eos_ladder_entries		; done last ladder?
				beq			9$											; yes, exit
				ldy			#eos_ladder_col
				lda			b,y											; get col
				bmi			8$											; -1?, yes, ignore
				sta			*col
				ldy			#eos_ladder_row
				lda			b,y
				sta			*row
				tfr			a,b											; B=row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				bne			7$											; not a space, skip
				lda			#3											; ladder
				;ldy			*byte_9
				sta			b,y											; update tilemap
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				bne			4$											; not a space, skip
				lda			#3											; ladder
				sta			b,y											; update tilemap
4$:			lda			#3											; ladder
				jsr			display_char_pg2
				lda			*col
				ldb			*row
				jsr			calc_colx5_scanline			; B=scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=col*5=x_in_2_pixel_incs
				lda			#3											; ladder
				jsr			display_transparent_char	; update video
				ldb			no_eos_ladder_entries
				lda			#0xff
				ldy			#eos_ladder_col
				sta			b,y											; flag ladder (tile) drawn
				bra			8$
7$:			lda			#1											; flag ladder error
				sta			eos_ladder_col
8$:			dec			no_eos_ladder_entries
				jmp			1$
9$:			lda			eos_ladder_col					; ladder drawn OK?
				bne			91$											; no, skip
				dec			*no_gold								; ???
91$:		rts

no_eos_ladder_entries:
				.ds			1
								
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

play_falling_sound:	; $87BA
; *** TBD
				rts
				
set_row_addr_1_2:	; $884B
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				sta			*byte_8
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9
				rts
				
calc_colx5_scanline:	; $885d
; A=col, B=row
				pshs		a												; save col
				ldy			#row_to_scanline_tbl
				lda			b,y											; A=scanline
				puls		b												; B=col
				pshs		a												; save scanline
				ldy			#col_x_5_tbl
				lda			b,y											; A=col*5
				puls		b												; B=scanline
				rts

calc_col_addr_shift:	; $8868
				ldx			#col_to_addr_tbl
				lda			b,x											; A=col address
				aslb
				andb		#0x06										; B=shift
				rts

calc_addr_shift_for_x:	; $8872
; B=x_in_2_pixel_incs
				tfr			b,a
				lsra
				lsra														; A=addr
				lslb
				andb		#7											; B=shift
				rts
				
calc_scanline: ; $887C
; A=y_offset_within_tile, B=row
				pshs		a												; save y_offset_within_tile
				jsr			calc_colx5_scanline			; B=scanline
				puls		a												; restore y_offset_within_tile
				ldy			#byte_888a
				addb		a,y											; B=scanline
				rts

byte_888a:
				.db			-5, -3, 0, 2, 4
								
calc_x_in_2_pixel_incs: ; $888F
; A=col, B=x_offset_within_tile
				pshs		b												; save x_offset_within_tile
				jsr			calc_colx5_scanline			; A=colx5
				tfr			a,b											; B=colx5
				puls		a												; restore x_offset_within_tile
				ldy			#byte_889d
				addb		a,y											; B=x as count of 2-pixel increments
				rts

byte_889d:
				.db			-2, -1, 0, 1, 2
								
wipe_or_draw_level:	; $88A2
				jsr			display_no_lives
				jsr			display_level
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

eos_ladder_col:	; $C00
					.ds		0x30
eos_ladder_row:	; $C30
					.ds		0x30

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

col_x_5_tbl:	; $1C35
					.db 	0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75
					.db 	80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135

row_to_scanline_tbl:	; $1c51
				.db			0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121
				.db			132, 143, 154, 165, 181

col_to_addr_tbl:	; $1c62
				.db			0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16
				.db			17, 18, 20, 21, 22, 23, 25, 26, 27, 28, 30, 31, 32, 33

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
			