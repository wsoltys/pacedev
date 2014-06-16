;
;	LODE RUNNER
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3
;.define			PLATFORM_WILLIAMS

;.define			DEBUG
;.define      DEBUG_DISABLE_DEMO_EXIT
;.define			DEBUG_GUARD_COPY
;.define			DEBUG_INVINCIBLE
;.define			DEBUG_NO_BITWISE_COLLISION_DETECT

.macro				KILL_PLAYER
	.ifndef DEBUG_INVINCIBLE
				lsr			*level_active
	.endif
.endm

START_LEVEL_0_BASED	.equ		0

;.define				CHAMPIONSHIP

.ifndef CHAMPIONSHIP
SCORE_GOLD				.equ	0x0250
SCORE_LEVEL				.equ	0x0100
SCORE_LEVEL_MULT	.equ	15
SCORE_TRAP				.equ	0x0075
SCORE_KILL				.equ	0x0075
;NUM_LEVELS				.equ	150
NUM_LEVELS				.equ	10
.else
SCORE_GOLD				.equ	0x0500
SCORE_LEVEL				.equ	0x0100
SCORE_LEVEL_MULT	.equ	20
SCORE_TRAP				.equ	0x0100
SCORE_KILL				.equ	0x0100
NUM_LEVELS				.equ	50
.endif

;
; 6809 stuff
;
  .macro	CLC
    andcc		#~(1<<0)
  .endm
  .macro	SEC
    orcc		#(1<<0)
  .endm

.iifdef PLATFORM_COCO3	.include "coco3.asm"

				.org		codebase
start:
				lds			#stack
				orcc		#0x50										; disable interrupts

.ifdef PLATFORM_COCO3

; initialise PLATFORM_COCO3 hardware
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
				lda			#0x00										; no VBLANK IRQ
				sta			IRQENR    							
				lda			#0x00										; no FIRQ enabled
				sta			FIRQENR   							
				lda			#0x80										; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
	.ifdef GFX_1BPP				
				lda			#0x0C										; 192 scanlines, 40 bytes/row, 2 colours (320x192)
	.else				
				lda			#0x15										; 192 scanlines, 80 bytes/row, 4 colours (320x192)
	.endif				
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
				lda			#0xDF										; screen at page $38
				sta			VOFFMSB
				lda			#0xFF
				sta			VOFFLSB   							
.ifdef GFX_1BPP				
				lda			#0x03										; normal display, horiz offset 3
.else
				lda			#0x02										; normal display, horiz offset 2
.endif				
				sta			HOFF      							
				ldx			#PALETTE
	.ifdef GFX_1BPP
				lda			#0x00										; black
				sta			,x+
	.else
				lda			#0x00										; black
				sta			,x+
				lda			#0x25										; orange (#0x35?)
				sta			,x+
				lda			#0x2d										; blue (#0x19?)
				sta			,x+
	.endif	; GFX_1BPP
	.ifdef GFX_MONO
				lda			#0x12										; green
	.else				
				lda			#0x3f										; white
	.endif				
				sta			,x+
				sta			CPU179									; select fast CPU clock (1.79MHz)
				
	.ifdef TILES_EXTERNAL
				lda			#GFXPAGE
				ldx			#(MMUTSK1+6)
				sta			,x+											; page 2 @$C000-$DFFF
				inca
				sta			,x+											; page 3 @$E000-$FFFF
	.endif	; TILES_EXTERNAL
				
.endif	; PLATFORM_COCO3
			
				lda			#>ZEROPAGE
				tfr			a,dp

; values set in Apple II loader
bootloader:
        lda     #6
        sta     *game_speed
        lda     #0xff
        ;sta     *byte_99
        lda     #0xca
        sta     *paddles_detected
        ;lda     #0x4c
        ;sta     *byte_23
; this needs to be done to synchronise
; the game state machine with the Apple        
        clra
        sta			*byte_64
        					
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
				lda			#APPLE_BPL
				sta			*col
				lda			#192										; 192 lines/screen
				sta			*row
1$:			ldb			,y+											; count
				lda			,y+											; byte
2$:			pshs		b
.if 1
				sta			,x+
.else
  ; code for colourizing 2BPP on-the-fly
				pshs		a
				GFX_BYTE
				pshs		b
				GFX_BYTE
				stb			,x+
				puls		b
				stb			,x+
				puls		a
.endif				
				dec			*col										; line byte count
				tst			*col										; done line?
				bne			3$											; no, skip
				ldb			#APPLE_BPL
				stb			*col										; reset line byte count
				ldb			#VIDEO_RM
				abx															; adjust video ptr
				dec			*row										; dec line count
3$:			puls		b
				decb														; done count?
				bne			2$											; no, loop
				tst			*row										; done screen?
				bne			1$											; no, loop
.else				
				lda			#8
				sta			*row
				lda			#2
				sta			*col
				jsr			display_message
				.asciz			"INSERT TITLE SCREEN HERE"
.endif	; HAS_TITLE
				HGR1
				jmp			title_wait_for_key

zero_score_and_init_game: ; $6056
				lda			#0
				sta			*score_1e1_1
				sta			*score_1e3_1e2
				sta			*score_1e5_1e4
				sta			*score_1e6
				sta			*unused_97
				sta			*wipe_next_time         ; draw next time
				sta			*guard_respawn_col
				sta			*demo_inp_cnt
				ldy			#attract_move_tbl
				sty			*msb_demo_inp_ptr
				lda			#5											; number of lives
				sta			*no_lives
				lda			*attract_mode
				lsra
				beq			loc_6099
; Apple version checks disk signature here
loc_6086:	; $6086
; more Apple-specific stuff here
; fall thru

loc_6099:	; $6099
				jsr			cls_and_display_game_status
				HGR1
main_game_loop:
				ldb			#1
				jsr			init_read_unpack_display_level
				lda			#0
				sta			*key_1
				sta			*key_2
				lda			*attract_mode
				lsra
				beq			1$
				jsr			keybd_flush
				lda			*current_col
				sta			*col
				lda			*current_row
				sta			*row
				lda			#9											; player
				jsr			blink_char_and_wait_for_key
1$:	; $60bf
				ldb			#0
				stb			*dig_dir
				stb			*playing_sound          ; no sound playing
				lda			*unused_97							; should be 0
				adda		*no_guards							; should =no_guards
				tfr			a,b
				ldy			#x3_tbl
				lda			b,y											; A=no_guards*3
				tfr			a,b											; B=no_guards*3
				ldy			#byte_6ca7
				lda			b,y
				sta			*byte_60
				leay		1,y
				lda			b,y
				sta			*byte_61
				leay		1,y
				lda			b,y
				sta			*byte_62
				ldb			*unused_97							; should be 0
				ldy			#guard_trap_cnt_init_tbl
				lda			b,y
				sta			*guard_trap_cnt_init		; should be 1st entry (0x26)
in_level_loop:
				jsr			handle_player						; digging, falling, keys
				lda			*level_active						; alive?
				beq			dec_lives								; no, exit
				jsr			throttle_and_update_sound
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
2$:			jsr			respawn_guards_and_update_holes
				lda			*level_active						; alive?
				beq			dec_lives								; no, exit
				jsr			throttle_and_update_sound
				jsr			handle_guards
				lda			*level_active						; alive?
				beq			dec_lives								; no, exit
				bra			in_level_loop

next_level:
				inc			*level									; next level
				inc			*level_0_based					; used for reading level data
				inc			*no_lives								; extra life
				bne			3$											; skip if no wrap
				dec			*no_lives								; =255
3$:			ldb			#SCORE_LEVEL_MULT
				stb			*farthest_updown_plyr_row
4$:			ldd			#SCORE_LEVEL						; add 100 pts
				jsr			update_and_display_score
				jsr     sub_622a
				jsr     sub_622a
				jsr     sub_622a
				dec			*farthest_updown_plyr_row
				bne			4$											; add 1500 pts
next_level_cont:				
				jmp			main_game_loop				

dec_lives:	; $613F
				dec			*no_lives
				jsr			display_no_lives
				;jsr			sub_78e1								; sound stuff
				jsr			throttle_and_update_sound
				; stuff
				lda			*attract_mode
				lsra														; demo mode?
				beq			loc_61d0								; yes, go
				lda			*no_lives								; any lives left?
				bne			next_level_cont					; yes, continue
				jsr			check_and_update_high_score_tbl
				jsr			game_over_animation
				bcs			check_start_new_game
				
title_wait_for_key: ; $618e
				jsr			keybd_flush
				ldb			#4											; timeout
1$:			stb			*zp_de									; 6809 only
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
				bne			check_start_new_game		; yes, exit
				leay		-1,y
				bne			2$
				ldb			*zp_de									; 6809 only
				decb														; done?
				bne			1$											; no, loop
				lda			*attract_mode						; in attract mode?
				bne			loc_61de								; yes, skip
				ldb			#1
				stb			*attract_mode						; set attract mode
				stb			*level
				stb			*byte_ac
				stb			*no_cheat
				ldb			*sound_enabled					; get sound setting
				stb			*zp_dd									; store - 6809 only
				sta			*sound_enabled					; mute sound
				jmp			zero_score_and_init_game

loc_61d0:	; $61D0
				lda			*zp_dd									; restore sound setting
				sta			*sound_enabled
; reads $C000 (keybd) but not used!?!				
				ldb			*byte_ac
				beq			check_start_new_game
				jmp			title_wait_for_key
				
loc_61de:	; $61DE
				cmpa		#1											; attract mode
				bne			loc_61f3
				beq			high_score_screen
				
read_and_display_scores:	; $61E4
				lda			#1
				;jsr			sub_6359								; disk access
high_score_screen: ; $61E9
				jsr			cls_and_display_high_scores
				lda			#2
				sta			*attract_mode
				jmp			title_wait_for_key				

loc_61f3:	; $61F3
				jmp			display_title_screen
				
check_start_new_game: ; $61F6
; check for 'e' key for editor (not supported)
				ldx			#PIA0
				ldb			#~(1<<0)								; col0
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<6)									; <ENTER>?
				beq			read_and_display_scores	; yes, go
start_new_game:	; $6201
				ldb			#START_LEVEL_0_BASED
				stb			*level_0_based
				incb
				stb			*level
				ldb			#1											; because we may start on another level
				stb			*no_cheat
				lda			#2
				sta			*attract_mode
				jmp			zero_score_and_init_game														

x3_tbl:	; $6214
       .db			0, 3, 6, 9, 12, 15, 18, 21, 24
guard_trap_cnt_init_tbl:	; $6214
				.db			0x26, 0x26, 0x2E, 0x44, 0x47, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F
				.db			0x50

sub_622a:
        lda     *farthest_updown_plyr_row
        asla
        asla
        asla
        asla
        ldb     #6
        ;jsr     sub_87d5                ; sound stuff?
        jmp     throttle_and_update_sound        
        
init_read_unpack_display_level:	; $6238
				stb			*editor_n
				ldb			#0xff
				stb			*current_col						; flag no player
				incb														; B=0
				stb			*no_eos_ladder_tiles
				stb			*no_gold
				stb			*no_guards
				stb			*curr_guard
				stb			*dig_sprite
				stb			*packed_byte_cnt
				stb			*nibble_cnt
				stb			*row
				tfr			b,a											; A=0
				ldb			#0x1e										; number of holes
				ldy			#hole_cnt
7$:			sta			b,y
				decb
				bpl			7$											; clear all hole counters
				ldb			#5											; number of guards
				ldy			#guard_cnt
8$:			sta			b,y				
				decb
				bpl			8$											; zero all guard counters
				lda			#1
				sta			*level_active
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
.if 0
; wipe enemies from the game
				cmpa		#8
				bne			0$
				lda			#0
0$:				
.endif				
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
				bcc			draw_ok
				lda			*level_0_based
				beq			jmp_display_title_screen
				ldb			#0
				;inc			*byte_97
				decb
				jmp			init_read_unpack_display_level
draw_ok:	; $62C3
				rts

jmp_display_title_screen:	; $62C4
				jmp			display_title_screen
				
read_level_data:	; $6264
; copies from disk buffer to low memory ($0D00)
				;sta			byte_b7f4								; disk area = *level_active???
				lda			*attract_mode
				lsra														; demo mode?
				beq			read_attract_mode_levels
				lda			*level_0_based
; nothing like original code from here-on in			

	; hack - 5 levels only atm
1$:			cmpa		#NUM_LEVELS
				bcs			2$
				suba		#NUM_LEVELS
				bra			1$
2$:
	; end of hack
					
				adda		#>game_level_data
				sta			*msb_line_addr_pg1
				lda			#<game_level_data
				sta			*lsb_line_addr_pg1
				ldx			*msb_line_addr_pg1
				ldy			#level_data_packed
				clrb
				bra			copy_level_data
				
read_attract_mode_levels:
				lda			*level
				deca
				adda		#>demo_level_data
				sta			*msb_line_addr_pg1
				lda			#<demo_level_data
				sta			*lsb_line_addr_pg1
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
5$:			cmpa		#8											; guard?
				bne			6$											; no, skip
				lda			*no_guards
				cmpa		#5											; max?
				bcc			3$											; yes, go
				inc			*no_guards							; add a guard
				inca
				ldy			#guard_col
				exg			a,b											; A=col,B=guard
				sta			b,y											; set guard column
				pshs		a
				lda			*row
				ldy			#guard_row
				sta			b,y											; set guard row
				lda			#0
				ldy			#guard_state
				sta			b,y
				ldy			#guard_sprite
				sta			b,y
				lda			#2
				ldy			#guard_x_offset
				sta			b,y
				ldy			#guard_y_offset
				sta			b,y
				lda			#0
				ldy			*byte_9
				puls		b												; B=col
				sta			b,y											; update tilemap (with space)
				lda			#8											; guard
				bra			8$
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
				lbpl		2$
				dec			*row
				ldb			*row
				lbpl		1$
				lda			*current_col
				bpl			draw_level
				SEC
				rts

draw_level:	; $648B
				jsr			wipe_and_draw_level
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
				sta			*enable_collision_detect
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
				sta			*not_falling
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
				jmp			draw_player_sprite

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
				jmp			draw_player_sprite

check_falling_sound:	; $6584
				lda			*not_falling
				bne			check_controls
				lda			#0x64
				ldb			#8
				jsr			play_falling_sound
check_controls:	; $658F				
				lda			#0x20
				;sta			*byte_a4
				sta			*not_falling
				jsr			read_controls
				lda			*key_1
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
				lda			*key_2
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
				jmp			draw_player_sprite				

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
				jmp			draw_player_sprite				

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
				sta			b,y
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
				jsr			draw_player_sprite
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
				
cant_dig_left:	; $67D8
				jmp			finish_dig_left
				rts
				
dig_left:	; $67db
				lda			#0xff
				sta			*dig_dir
				sta			*key_1
				sta			*key_2
				lda			#0
				sta			*dig_sprite
digging_left:
				ldb			*current_row
				cmpb		#15											; bottom row?
				bcc			cant_dig_left						; yes, exit
				incb														; row below
				jsr			set_row_addr_1_2
				ldb			*current_col
				beq			cant_dig_left						; left-most edge? yes, exit
				decb														; column to the left
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tilemap data (below, left)
				cmpa		#1											; brick?
				bne			cant_dig_left						; no, exit
				ldb			*current_row
				jsr			set_row_addr_1_2
				ldb			*current_col
				decb														; column to the left
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tilemap data (left)
				cmpa		#0											; space?
				lbne		abort_dig_left					; no, go
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
				jsr			draw_player_sprite
				ldb			*dig_sprite
				cmpb		#0x0c
				lbeq		loc_6898
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

abort_dig_left:	; $686E
				ldb			*current_row
				incb
				stb			*row
				ldb			*current_col
				decb
				stb			*col
				lda			#1											; brick
				jsr			display_char_pg1
				ldb			*dig_sprite
				beq			finish_dig_left
				decb
				ldy			#(sprite_to_char_tbl+0x12)
				lda			b,y
				pshs		a
				ldb			*current_row
				lda			*current_col
				deca
				jsr			calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				puls		a												; A=char
				jsr			wipe_char
				
finish_dig_left:	; $6892
				lda			#0
				sta			*dig_dir
				SEC
				rts

loc_6898: ; $6898
				ldb			*current_col
				decb
				jmp			add_hole_entry
												
cant_dig_right:	; $689E
				jmp			finish_dig_right
																				
dig_right: ; 68a1
				lda			#1
				sta			*dig_dir
				sta			*key_1
				sta			*key_2
				lda			#0x0c
				sta			*dig_sprite
digging_right:				
				ldb			*current_row
				cmpb		#15											; bottom row?
				bcc			cant_dig_right					; yes, exit
				incb														; row below
				jsr			set_row_addr_1_2
				ldb			*current_col
				cmpb		#27											; right-most edge?
				bcc			cant_dig_right					; yes, exit
				incb														; column to the right
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tilemap data (below, right)
				cmpa		#1											; brick?
				bne			cant_dig_right					; no, exit
				ldb			*current_row
				jsr			set_row_addr_1_2
				ldb			*current_col
				incb														; column to the right
				ldy			*msb_row_level_data_addr
				lda			b,y											; get tilemap data (right)
				cmpa		#0											; space?
				lbne		abort_dig_right					; no, go
				jsr			calc_char_and_addr
				jsr			wipe_char
				jsr			adjust_x_offset_in_tile
				jsr			adjust_y_offset_within_tile
				ldb			*dig_sprite
				ldy			#sprite_to_char_tbl+0x2A
				lda			b,y
				pshs		a
				ldy			#sprite_to_char_tbl+0x37
				lda			b,y
				puls		b
				;jsr			sub_87d5
				ldb			*dig_sprite
				lda			#8											; sprite=8, tile=9 (running right)
				cmpb		#0x12
				bcc			1$
				lda			#0x0e
1$:			sta			*sprite_index
				jsr			draw_player_sprite
				ldb			*dig_sprite
				cmpb		#0x18
				lbeq		loc_6962
				cmpb		#0x0c
				beq			2$
				ldy			#sprite_to_char_tbl+0x11
				lda			b,y
				pshs		a
				lda			*current_col
				inca
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
				inca
				sta			*col
				ldb			*current_row
				stb			*row
				jsr			calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				puls		a												; A=char
				jsr			display_transparent_char
				inc			*row
				ldb			*dig_sprite
				ldy			#sprite_to_char_tbl+0x1e
				lda			b,y
				jsr			display_char_pg1
				inc			*dig_sprite
				CLC															; flag
				rts

abort_dig_right:	; $6936
				ldb			*current_row
				incb
				stb			*row
				ldb			*current_col
				incb
				stb			*col
				lda			#1											; brick
				jsr			display_char_pg1
				ldb			*dig_sprite
				cmpb		#0x0c
				beq			finish_dig_right
				decb
				ldy			#sprite_to_char_tbl+0x12
				lda			b,y
				pshs		a
				lda			*current_col
				inca
				ldb			*current_row
				jsr			calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				puls		a												; A=char
				jsr			wipe_char

finish_dig_right:	; $695C
				lda			#0
				sta			*dig_dir
				SEC
				rts

loc_6962: ; $6962
				ldb			*current_col
				incb
				jmp			add_hole_entry
								
sprite_to_char_tbl:	; $6968
				.db 		0xB, 0xC, 0xD, 0x18, 0x19, 0x1A, 0xF, 0x13, 9, 0x10, 0x11, 0x15, 0x16
				.db 		0x17, 0x25, 0x14, 0xE, 0x12, 0x1B, 0x1B, 0x1C, 0x1C, 0x1D, 0x1D, 0x1E
				.db 		0x1E, 0, 0, 0, 0, 0x26, 0x26, 0x27, 0x27, 0x1D, 0x1D, 0x1E, 0x1E, 0
				.db 		0, 0, 0, 0x1F, 0x1F, 0x20, 0x20, 0x21, 0x21, 0x22, 0x22, 0x23, 0x23
				.db 		0x24, 0x24, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x24, 0x24
				.db 		0x24, 0x24, 0x24, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 2, 2, 1

handle_attract_mode:	; $69B8
				ldx			#PIA0
				ldb			#0										; all columns
				stb			2,x										; column strobe
				lda			,x										; active low
				coma													; active high
.ifndef DEBUG_DISABLE_DEMO_EXIT				
				bne			exit_demo							; key pressed, go
.endif				
				bra			next_demo_inp
exit_demo:				
				lsr			*byte_ac
				lsr			*level_active					; kill player
				lda			#1
				sta			*no_lives
				rts

next_demo_inp:	; $69D6
				lda			*demo_inp_cnt					; counter=0?
				bne			1$										; no, skip
				ldy			*msb_demo_inp_ptr
				lda			0,y										; get 1st byte
				sta			*demo_inp_key_1_2
				lda			1,y										; get 2nd byte
				sta			*demo_inp_cnt
				leay		2,y										; next entry
				sty			*msb_demo_inp_ptr			; update ptr
1$:			ldb			*demo_inp_key_1_2
				andb		#0x0f									; low nibble
				ldy			#demo_inp_remap_tbl
				lda			b,y										; get equivalent keycode
				sta			*key_1
				ldb			*demo_inp_key_1_2
				lsrb
				lsrb
				lsrb
				lsrb
				lda			b,y										; get equivalent keycode
				sta			*key_2
				dec			*demo_inp_cnt
				rts

demo_inp_remap_tbl:	; $6A0B
;								I, J, K, L, O, U, <SPACE>
				.db			0xC9, 0xCA, 0xCB, 0xCC, 0xCF, 0xD5, 0xA0
								
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
				bne			93$
				lda			page
				coma		
				sta			page
				bne			91$
				HGR1
				bra			92$
91$:		HGR2
92$:		lda			,x											; active low
				bita		#(1<<6)
				beq			92$											; wait for key release
93$:				
.endif
				lda			*attract_mode
				cmpa		#1
				beq			handle_attract_mode
				ldy			#got_key
				pshs		y												; set return address
.ifdef PLATFORM_COCO3				
1$:     ldx			#PIA0
				ldb			#~(1<<4)								; col4
				stb			2,x											; columns strobe
				lda			,x											; active low
				coma
				anda		#(1<<6)									; bit6=CTRL
				sta			*zp_de
				ldb			#~(1<<0)								; col0
				stb			2,x											; columns strobe
				lda			,x											; active low
				bita    #(1<<3)                 ; <X>?
				bne     96$                     ; no, skip
				lda     #0xcf                   ; 'O'
				rts
96$:		bita		#(1<<6)									; <ENTER>?
				bne			10$
				tst			*zp_de									; CTRL?
				bne			10$											; no, skip
				lda			#0x8d										; CTRL-M
				rts
10$:		ldb			#~(1<<1)								; col1
				stb			2,x											; columns strobe
				lda			,x											; active low
				bita		#(1<<0)									; 'A'?
				bne			11$											; no, skip
				tst			*zp_de									; CTRL?
				beq			11$											; no, skip
				lda			#0x81										; CTRL-A
				rts
11$:		bita		#(1<<1)									; 'I'?
				bne			2$											; no, skip
				lda			#0xc9										; 'I'
				rts
2$:			ldb			#~(1<<2)								; col2
				stb			2,x											; columns strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'J'?
				bne			21$											; no, skip
				lda			#0xca										; 'J'
				rts
21$:		bita    #(1<<3)                 ; <Z>
        bne     26$                     ; no, skip
        lda     #0xd5                   ; 'U'
        rts								
26$:    bita    #(1<<6)                 ; <BREAK>
        bne     22$                     ; no, skip
        lda     #0x9b                   ; <ESC>
        rts								
22$:    bita		#(1<<2)									; 'R'?
				bne			3$											; no, skip
			  tst			*zp_de									; CTRL?
				beq			3$											; no, skip
				lda			#0x92										; CTRL-R
				rts
3$:			ldb			#~(1<<3)								; col3
				stb			2,x											; columns strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'K'?
				bne			33$											; no, skip
				lda			#0xcb										; 'K'
				rts
33$:    bita    #(1<<3)                 ; <UP>?
        bne     4$                      ; no, skip
        lda     #0xc9                   ; 'I'
        rts
4$:			ldb			#~(1<<4)								; col4
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'L'?
				bne			43$											; no, skip
				lda			#0xcc										; 'L'
				rts
43$:    bita    #(1<<3)                 ; <DOWN>?
        bne     5$                      ; no, skip
        lda     #0xcb                   ; 'K'
        rts
5$:			ldb			#~(1<<5)								; col5
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<2)									; 'U'?
				bne			53$											; no, skip
				lda			#0xd5										; 'U'
				rts
53$:    bita    #(1<<3)                 ; <LEFT>?
        bne     6$                      ; no, skip
        lda     #0xca                   ; 'J'
        rts				
6$:			ldb			#~(1<<6)								; col6
				stb			2,x											; column_strobe
				lda			,x											; active low
        bita    #(1<<3)                 ; <RIGHT>?
        bne     60$                     ; no, skip
        lda     #0xcc                   ; 'L'
        rts				
60$:    tst			*zp_de									; CTRL?
				beq			7$                      ; no, skip
				bita		#(1<<0)									; 'F'?
				bne			61$											; no, skip
				lda			#0x80										; CTRL-@
				rts
61$:		bita		#(1<<1)									; 'N'?
				bne			7$											; no, skip
				lda			#0x9e										; CTRL-^			
				rts
7$:			ldb			#~(1<<7)								; col7
				stb			2,x											; column strobe
				lda			,x											; active low
				bita		#(1<<1)									; 'O'?
				bne			8$											; no, skip
				lda			#0xcf										; 'O'
				rts
8$:			clra
.endif
				rts
got_key:
				tfr			a,b											; B=(apple)key
				stb			*msg_char
				bne			key_pressed
; fixme - see source
key_pressed:	; $6A2B
				cmpb		#0xa0										; normal character?
				bcc			2$											; yes, go
				stb			*msg_char
				ldb			#0xff
1$:			incb
				ldy			#ctl_keys
				lda			b,y											; get key entry
				beq			2$											; done? yes, exit				
				cmpa		*msg_char								; match?
				bne			1$											; no, loop
				ldx			#ctl_key_vector_fn
				aslb														; entry offset
				abx
				ldy			,x
				pshs		y												; set as return address
				rts
2$:			; paddle stuff
				ldb			*msg_char				
				stb			*key_1
				stb			*key_2
				rts

goto_next_level:	; $6A56
				inc			*no_lives
				inc			*level
				inc			*level_0_based
				lsr			*level_active						; 'kill' player
				lsr			*no_cheat
        jsr     keybd_flush             ; wait for no keys (6809 only)
				rts
				
extra_life:	; $6A61
				inc			*no_lives
				bne			1$
				dec			*no_lives
1$:			jsr			display_no_lives
				lsr			*no_cheat
        jsr     keybd_flush             ; wait for no keys (6809 only)
				jmp			read_controls

freeze:	; $6A76
        jsr     keybd_flush             ; wait for no keys
				jsr			wait_for_key
				cmpa		#0x9b
				bne			freeze
        jsr     keybd_flush             ; wait for no keys (6809 only)
				jmp			read_controls
																				
terminate_game:	; $6A81
				lda			#1
				sta			*no_lives
abort_life:	; $6A84
				lsr			*level_active
        jsr     keybd_flush             ; wait for no keys (6809 only)
				rts

speed_up:	; $6ABC
				lda			*game_speed
; the original source jumps to $6ACD
; which equates to 1$ in the slow_down routine
; but it's obviously a cut-n-paste error
; and makes no difference to the execution
				beq			1$
				dec			*game_speed
1$:			jsr     keybd_flush             ; wait for no keys (6809 only)
        jmp			read_controls

slow_down:	; $6AC5
				lda			*game_speed
				cmpa		#0x0f
				beq			1$
				inc			*game_speed
1$:			jsr     keybd_flush             ; wait for no keys (6809 only)
        jmp			read_controls
												
ctl_keys:	; $6B59
				.db			0x9e										; CTRL-^ (next level)
				.db			0x80										; CTRL-@ (extra life)
				.db			0x9b										; ESC (freeze toggle)
				.db			0x92										; CTRL-R (terminate game)
				.db			0x81										; CTRL-A (abort life)
				.db			0x88										; CTRL-H (speed up)
				.db			0x95										; CTRL-U (slow down)
				.db			0x8d										; CTRL-M (display high scores)
				.db			0

ctl_key_vector_fn:
				.dw			#goto_next_level
				.dw			#extra_life
				.dw			#freeze
				.dw			#terminate_game
				.dw			#abort_life
				.dw			#speed_up
				.dw			#slow_down
				.dw			#ctrl_m
												
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
				lsr		  *enable_collision_detect  ; disable
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
				ldd			#SCORE_GOLD							; add 250/500 pts
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
				
draw_player_sprite: ; $6c02
				jsr			calc_char_and_addr
				jsr			display_transparent_char
				lda     *collision_detect       ; collision?
				beq     1$                      ; no, skip
.ifndef DEBUG_NO_BITWISE_COLLISION_DETECT
				lda     *enable_collision_detect  ; enabled?
				beq     1$                      ; no, skip
				KILL_PLAYER
.endif				
1$:			rts

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

add_hole_entry:	; $6C39
				lda			#0
				sta			*dig_dir
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
				sta			b,y											; update tilemap
				jsr			display_char_pg1
				lda			#0											; space
				jsr			display_char_pg2
				dec			*row										; row above
				lda			#0											; space
				jsr			display_char_pg1
				inc			*row										; row below
				ldb			#0xff
1$:			incb														; next hole
				cmpb		#0x1e										; max?
				beq			2$											; yes, exit
				ldy			#hole_cnt
				lda			b,y											; empty entry?
				bne			1$											; yes, loop
				lda			*row
				ldy			#hole_row								; store row of hole
				sta			b,y
				lda			*col
				ldy			#hole_col								; store col of hole
				sta			b,y
				lda			#180										; init counter
				ldy			#hole_cnt								; store hole counter
				sta			b,y
				SEC
2$:			rts

handle_guards:	; $6C82
				ldb			*no_guards							; any guards?
				beq			4$											; no, exit
				inc			*byte_64
				ldb			*byte_64
				cmpb		#3
				bcs			1$
				ldb			#0
				stb			*byte_64
1$:			pshs		b
				tfr			dp,a
				ldb			#0x60										; D=&($60)
				tfr			d,y
				puls		b
				lda			b,y											; get entry
				sta			*byte_63
2$:			lsr			*byte_63
				bcc			3$
				jsr			update_guards
				lda			*level_active						; player killed?
				beq			4$											; yes, skip
3$:			lda			*byte_63
				bne			2$
4$:			rts

byte_6ca7:	; $6CA7
				.db 		0, 0, 0
        .db 		0, 1, 1
        .db 		1, 1, 1
        .db 		1, 3, 1
        .db 		1, 3, 3
        .db 		3, 3, 3
        .db 		3, 3, 7
        .db 		3, 7, 7
        .db 		7, 7, 7
        .db 		7, 7, 0xF
        .db 		7, 0xF, 0xF
        .db 		0xF, 0xF, 0xF

guard_sprite_to_char_tbl:	; $6CCB 
				.db			8, 0x2B, 0x2C, 0x30, 0x31, 0x32, 0x36, 0x28, 0x29, 0x2A, 0x2D, 0x2E, 0x2F
				.db			0x35, 0x33, 0x34

update_guards:	; $6CDB
				inc			*curr_guard
				ldb			*no_guards
				cmpb		*curr_guard							; max?
				bcc			1$											; no, skip
				ldb			#1
				stb			*curr_guard
1$:			jsr			copy_guard_to_curr
				lda			*curr_guard_state
				bmi			check_guard_falling
				beq			check_guard_falling
				dec			*curr_guard_state
				lda			*curr_guard_state
				cmpa		#13											; started wriggling?
				bcc			save_guard_and_ret			; no, skip
				jmp			check_wriggle				

save_guard_and_ret:	; $6CFB
				ldb			*curr_guard
				ldy			#guard_cnt
				lda			b,y
				beq			2$
				jmp			copy_curr_to_guard
2$:			jmp			render_guard_and_ret
				rts

check_guard_falling:	; $6D08
				ldb			*curr_guard_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#3											; ladder?
				beq			2$											; yes, go
				cmpa		#4											; rope?
				bne			1$											; no, skip
				lda			*curr_guard_y_offset
				cmpa		#2
				beq			2$											; yes, go
1$:			lda			*curr_guard_y_offset
				cmpa		#2
				bcs			handle_guard_falling
				ldb			*curr_guard_row
				cmpb		#15											; bottom row?
				beq			2$											; yes, go
				ldy			#(lsb_row_addr+1)
				lda			b,y											; row below
				sta			*lsb_row_level_data_addr
				sta			*byte_8
				ldy			#(msb_row_addr_2+1)
				lda			b,y
				sta			*byte_9
				ldy			#(msb_row_addr_1+1)
				lda			b,y
				sta			*msb_row_level_data_addr	; setup tilemap address
				ldb			*curr_guard_col
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#0											; space?
				beq			handle_guard_falling		; yes, go
				cmpa		#9											; player?
				beq			handle_guard_falling		; yes, go
				cmpa		#8											; guard?
				beq			2$											; yes, go
				ldy			*byte_9									
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				beq			2$											; yes, go
				cmpa		#2											; solid?
				beq			2$											; yes, go
				cmpa		#3											; ladder?
				bne			handle_guard_falling		; no, go
2$: ; $6D61
				jmp			calc_guard_movement

handle_guard_falling:	; $ 6D64
				jsr			calc_guard_xychar
				jsr			wipe_char
				jsr			adjust_guard_x_offset
				lda			#6											; =char $36 = fall left
				ldb			*curr_guard_dir					; left?
				bmi			1$											; yes, skip
				lda			#0x0d										; =char $35 = fall right
1$:			sta			*curr_guard_sprite
				inc			*curr_guard_y_offset
				lda			*curr_guard_y_offset
				cmpa		#5
				bcc			guard_fall_into_next_row
				lda			*curr_guard_y_offset
				cmpa		#2
				bne			render_guard_and_ret
				jsr			check_guard_pickup_gold
				ldb			*curr_guard_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y											; get tilemap object
				cmpa		#1											; brick?
				bne			render_guard_and_ret		; no, go
; guard has hit bottom of hole				
				lda			*curr_guard_state
				bpl			2$
				dec			*no_gold
2$:			lda			*guard_trap_cnt_init
				sta			*curr_guard_state
				ldd			#SCORE_TRAP							; add 75/100 pts
				jsr			update_and_display_score
				;jsr			sub_87e1								; sound stuff				

render_guard_and_ret:	; $6DB7				
				jsr			calc_guard_xychar
				jsr			display_transparent_char
				jmp			copy_curr_to_guard

guard_fall_into_next_row:	; $6DC0
				lda			#0
				sta			*curr_guard_y_offset		; y_offset=0
				ldb			*curr_guard_row
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
				ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#0											; space
1$:			ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap				
				inc			*curr_guard_row					; row below
				ldb			*curr_guard_row
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
				ldb			*curr_guard_col
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#9											; player?
				bne			2$											; no, skip
				KILL_PLAYER
2$:			ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				bne			loc_6e58								; no, go
				lda			*curr_guard_state
				bpl			loc_6e58
; just fallen into a hole				
				ldb			*curr_guard_row
				decb														; row above
				stb			*row
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
				ldb			*curr_guard_col
				stb			*col
				ldy			*byte_9
				lda			b,y											; get object from tilemap (row above)
				cmpa		#0											; space?
				beq			guard_drop_gold					; yes, go
				dec			*no_gold								; gold gone forever!
				jmp			loc_6e46
				
guard_drop_gold:	; $6E31
; B=col
				lda			#7											; gold
				ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				ldy			*byte_9
				sta			b,y											; update tilemap
				jsr			display_char_pg2				; render on bg
				lda			*col
				ldb			*row
				jsr			calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				lda			#7											; A=char (gold)
				jsr			display_transparent_char
				
loc_6e46:	; $6E46
				ldb			*curr_guard_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr	; setup tilemap address
				lda			#0
				sta			*curr_guard_state
				ldb			*curr_guard_col
loc_6e58:	; $6E58
				lda			#8											; guard
				ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				jsr			calc_guard_xychar
				jsr			display_transparent_char	; render on screen
				jmp			copy_curr_to_guard

check_wriggle:	; $6E65
				cmpa		#7											; still wriggling?
				bcs			calc_guard_movement			; no, skip
				jsr			calc_guard_xychar
				jsr			wipe_char
				ldb			*curr_guard_state
				ldy			#(wriggle_tbl-7)
				lda			b,y											; get wriggle x_offset
				sta			*curr_guard_x_offset
				jsr			calc_guard_xychar
				jsr			display_transparent_char	; render on screen
				jmp			copy_curr_to_guard

wriggle_tbl:	; $6E7F 
				.db			2, 1, 2, 3, 2, 1

calc_guard_movement:	; $6E85
				lda			*curr_guard_col
				ldb			*curr_guard_row
				jsr			guard_ai
				aslb
				ldy			#guard_move_vector_tbl
				ldx			b,y
				pshs		x
				rts															; go
				
guard_move_vector_tbl:	; $6E97
				.dw			#copy_guard_to_curr
				.dw			#guard_move_left
				.dw			#guard_move_right
				.dw			#guard_move_up
				.dw			#guard_move_down

guard_cant_climb:                                       ; CODE XREF: ROM:6EB4j
        lda     *curr_guard_state
        beq     1$
        bmi     1$
        inc     *curr_guard_state
1$:     jmp     copy_curr_to_guard
								
guard_move_up:	; $6EAC
        lda     *curr_guard_y_offset
        cmpa    #3											; already moving up?
        bcc     guard_can_move_up				; yes, go
        ldb     *curr_guard_row         ; top row?
        beq     guard_cant_climb        ; yes, exit
        decb                            ; row above
        ldy			#lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr	; setup tilemap address
        ldb     *curr_guard_col
        ldy     *msb_row_level_data_addr
        lda			b,y											; get object from tilemap (below)
        cmpa    #1											; brick?
        beq     guard_cant_climb				; yes, exit
        cmpa    #2											; solid?
        beq     guard_cant_climb				; yes, exit
        cmpa    #5											; fall-thru?
        beq     guard_cant_climb				; yes, exit
        cmpa    #8											; guard?
        beq     guard_cant_climb				; yes, exit

guard_can_move_up:	; $6ED5
				jsr     calc_guard_xychar
        jsr     wipe_char
        jsr     adjust_guard_x_offset
        ldb     *curr_guard_row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        sta     *byte_8
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9									; setup tilemap address
        dec     *curr_guard_y_offset		; move down
        bpl     guard_climber_check_for_gold	; same tile? yes, go
        jsr     check_guard_drop_gold
        ldb     *curr_guard_col
        ldy			*byte_9
        lda     b,y											; get object from tilemap
        cmpa    #1                      ; brick?
        bne     1$											; no, skip
        lda     #0                      ; space
1$:     ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
        dec     *curr_guard_row					; next row down
        ldb     *curr_guard_row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr	; setup tilemap address
        ldb     *curr_guard_col
        ldy     *msb_row_level_data_addr
        lda			b,y											; get object from tilemap
        cmpa    #9                      ; player?
        bne     2$											; no, skip
        KILL_PLAYER
2$:     lda     #8                      ; enemy
        sta     b,y											; update tilemap
        lda     #4
        sta     *curr_guard_y_offset
        bra			update_guard_climber_sprite
        
guard_climber_check_for_gold:        
				jsr     check_guard_pickup_gold

update_guard_climber_sprite:
				lda     #0x0e										; 1st climber sprite
        ldb     #0x0f										; last cliber sprite
        jsr     update_guard_sprite_index
        jsr     calc_guard_xychar
        jsr     display_transparent_char
        jmp     copy_curr_to_guard
				
guard_move_down:	; $6F39
        lda     *curr_guard_y_offset
        cmpa		#2
        bcs     guard_can_move_down
        ldb     *curr_guard_row
        cmpb		#0x0f										; bottom row?
        bcc     guard_cant_move_down		; yes, exit
        incb
        ldy     #lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr	; setup tilemap address
        ldb     *curr_guard_col
        ldy     *msb_row_level_data_addr
        lda			b,y											; get object from tilemap
        cmpa    #2                      ; solid?
        beq     guard_cant_move_down    ; yes, skip
        cmpa    #8                      ; enemy?
        beq     guard_cant_move_down    ; yes, skip
        cmpa    #1                      ; brick?
        bne     guard_can_move_down     ; no, go

guard_cant_move_down:	; $6F60
        jmp     copy_curr_to_guard

guard_can_move_down:	; $6F63
        jsr     calc_guard_xychar
        jsr     wipe_char
        jsr     adjust_guard_x_offset
        ldb     *curr_guard_row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        sta     *byte_8
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9									; setup tilemap address
        inc     *curr_guard_y_offset
        lda     *curr_guard_y_offset
        cmpa    #5
        bcs     3$
        jsr     check_guard_drop_gold
        ldb     *curr_guard_col
        ldy     *byte_9
        lda			b,y											; get object from tilemap
        cmpa    #1											; brick?
        bne     1$											; no, skip
        lda     #0											; space
1$:     ldy     *msb_row_level_data_addr
				sta			b,y											; update tilemap
        inc     *curr_guard_row
        ldb     *curr_guard_row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr	; setup tilemap address
        ldb     *curr_guard_col
        ldy     *msb_row_level_data_addr
        lda			b,y											; get object from tilemap
        cmpa    #9                      ; player?
        bne     2$											; no, skip
        KILL_PLAYER
2$:     lda     #8											; guard
        sta     b,y											; update tilemap
        lda     #0
        sta     *curr_guard_y_offset
        jmp     update_guard_climber_sprite
3$:     jmp     guard_climber_check_for_gold
				
guard_move_left:	; $6FBC
				ldb			*curr_guard_row
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
				ldb			*curr_guard_x_offset
				cmpb		#3
				bcc			guard_can_move_left
				ldb			*curr_guard_col
				beq			guard_cant_move_left		; left-most column, exit
				decb														; column to left
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#8											; another guard?
				beq			guard_cant_move_left		; yes, exit
				cmpa		#2											; solid?
				beq			guard_cant_move_left		; yes, exit
				cmpa		#1											; brick?
				beq			guard_cant_move_left		; yes, exit
				ldy			*byte_9									
				lda			b,y											; get object from tilemap
				cmpa		#5											; fall-thru?
				bne			guard_can_move_left
guard_cant_move_left:	; $6FEE
				jmp			copy_curr_to_guard
				
guard_can_move_left:	; $6FF1
				jsr			calc_guard_xychar
				jsr			wipe_char
				jsr			adjust_guard_y_offset
				lda			#-1
				sta			*curr_guard_dir					; left
				dec			*curr_guard_x_offset
				bpl			3$
				jsr			check_guard_drop_gold
				ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick?
				bne			1$											; no, skip
				lda			#0											; space
1$:			ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				dec			*curr_guard_col
				decb
				lda			b,y											; get object from tilemap (left)
				cmpa		#9											; player?
				bne			2$											; no, skip
				KILL_PLAYER
2$:			lda			#8											; guard
				sta			b,y											; update tilemap
				lda			#4
				sta			*curr_guard_x_offset
				bra			4$
3$:			jsr			check_guard_pickup_gold
4$:			ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#4											; rope?
				beq			5$											; yes, skip
				lda			#0											; =$08 1st guard sprite (running left)
				ldb			#2											; =$2C last guard sprite (running left)
				bra			6$
5$:			lda			#3											; =$30 1st guard sprite (swinging left)
				ldb			#5											; =$32 last guard sprite (swining left)												
6$:			jsr     update_guard_sprite_index
				jsr     calc_guard_xychar
				jsr     display_transparent_char
				jmp     copy_curr_to_guard
				
guard_move_right: ; $7047
				ldb			*curr_guard_row
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
				lda			*curr_guard_x_offset
				cmpa		#2
				bcs			guard_can_move_right
				ldb			*curr_guard_col
				cmpb		#27											; right-most?
				beq			guard_cant_move_right		; yes, exit
				incb														; next column
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#8											; guard?
				beq			guard_cant_move_right		; yes, exit
				cmpa		#2											; solid?
				beq			guard_cant_move_right		; yes, exit
				cmpa		#1											; brick?
				beq			guard_cant_move_right		; yes, exit
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#5											; fall-thru?
				bne			guard_can_move_right		; no, continue
guard_cant_move_right:	; $707B
				jmp			copy_curr_to_guard
				
guard_can_move_right:	; $707E				
				jsr			calc_guard_xychar
				jsr			wipe_char
				jsr			adjust_guard_y_offset
				lda			#1
				sta			*curr_guard_dir					; right
				inc			*curr_guard_x_offset
				lda			*curr_guard_x_offset
				cmpa		#5
				bcs			5$
				jsr			check_guard_drop_gold
				ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y
				cmpa		#1											; brick?
				bne			3$
				lda			#0											; space
3$:			ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				inc			*curr_guard_col					; next column
				incb
				lda			b,y											; get object from tilemap (right)
				cmpa		#9											; player?
				bne			4$											; no, skip
				KILL_PLAYER
4$:			lda			#8											; guard
				sta			b,y											; update tilemap
				lda			#0
				sta			*curr_guard_x_offset
				bra			6$
5$:			jsr			check_guard_pickup_gold
6$:			ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#4											; rope?
				beq			7$											; yes, skip
				lda			#7											; 1st sprite (running right)
				ldb			#9											; last sprite (running right)
				bra			8$
7$:			lda			#0x0a										; 1st sprite (swinging right)
				ldb			#0x0c										; last sprite (swinging right)
8$:			jsr     update_guard_sprite_index
				jsr     calc_guard_xychar
				jsr     display_transparent_char
				jmp     copy_curr_to_guard

guard_ai:	; $70D8
; A=col, B=row
; ret: B=0..4 (direction)
				sta			*guard_ai_col
				stb			*guard_ai_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*guard_ai_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#1											; brick (ie. trapped)?
				bne			1$											; no, skip
				lda			*curr_guard_state
				beq			1$
				bmi			1$
				ldb			#3											; UP
				rts
1$:			
.ifdef DEBUG_GUARD_COPY		
				lda			*key_1
				ldb			#1											; left
				cmpa		#0xca										; 'J'
				beq			9$											; yes, return
				ldb			#2											; right
				cmpa		#0xcc										; 'L'
				beq			9$											; yes, return
				ldb			#3											; up
				cmpa		#0xc9										; 'I'
				beq			9$											; yes, return
				ldb			#4											; down
				cmpa		#0xcb										; 'K'
				beq			9$											; yes, return
				ldb			#0											; nowhere
9$:			rts
.else
				lda			*guard_ai_row
				cmpa		*current_row
				beq			same_row
				jmp			different_row

same_row:	; $7100
				lda			*guard_ai_col
				sta			*target_col
				cmpa		*current_col
				bcc			guard_right_of_player
				
guard_left_of_player:	; $7108
				inc			*target_col							; target to the right
				ldb			*guard_ai_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*target_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap (right)
				cmpa		#3											; ladder?
				beq			try_next_col_right			; yes, go
				cmpa		#4											; rope?
				beq			try_next_col_right			; yes, go
				ldb			*guard_ai_row         	
				cmpb		#15											; bottom row?
				beq			try_next_col_right			; yes, go
				ldy			#(lsb_row_addr+1)     	
				lda			b,y                   	
				sta			*byte_8               	
				ldy			#(msb_row_addr_2+1)   	
				lda			b,y                   	
				sta			*byte_9									; setup tilemap address (row below)
				ldb			*target_col           	
				ldy			*byte_9               	
				lda			b,y											; get object from tilemap (below right)
				cmpa		#0											; space?
				beq			different_row						; yes, go
				cmpa		#5											; fall-thru?
				beq			different_row						; yes, go
try_next_col_right:	; $713E           	
				lda			*target_col           	
				cmpa		*current_col          	
				bne			guard_left_of_player		; no, try next column
				ldb			#2											; RIGHT
				rts                           	
				                              	
guard_right_of_player:	; $7147					
				dec			*target_col							; column to left
				ldb			*guard_ai_row         	
				ldy			#lsb_row_addr         	
				lda			b,y                   	
				sta			*byte_8               	
				ldy			#msb_row_addr_2       	
				lda			b,y                   	
				sta			*byte_9									; setup tilemap address (left)
				ldb			*target_col           	
				ldy			*byte_9               	
				lda			b,y											; get object from tilemap (left)
				cmpa		#3											; ladder?
				beq			try_next_col_left				; yes, go
				cmpa		#4											; rope?
				beq			try_next_col_left				; yes, go
				ldb			*guard_ai_row         	
				cmpb		#15											; bottom row?
				beq			try_next_col_left				; yes, go
				ldy			#(lsb_row_addr+1)     	
				lda			b,y                   	
				sta			*byte_8               	
				ldy			#(msb_row_addr_2+1)   	
				lda			b,y                   	
				sta			*byte_9									; setup tilemap address (row below)
				ldb			*target_col           	
				ldy			*byte_9               	
				lda			b,y											; get object from tilemap (row below)
				cmpa		#0											; space?
				beq			different_row						; yes, go
				cmpa		#5											; fall-thru?
				beq			different_row						; yes, go
try_next_col_left:	; $717D           	
				lda			*target_col           	
				cmpa		*current_col						; same as player?
				bne			guard_right_of_player		; no, try next column
				ldb			#1											; LEFT
				rts
				
different_row:	; $7186
        lda     #0
        sta     *guard_ai_dir         	; no direction
        lda     #0xff
        sta     *guard_ai_best_delta
        lda     *guard_ai_col
        ldb     *guard_ai_row
        jsr     find_farthest_left_right ; how far on this row?
        jsr     guard_ai_up_down
        jsr     guard_ai_left
        jsr     guard_ai_right
        ldb     *guard_ai_dir
				rts				
.endif				

locret_71A1:	; $71A1
				rts

guard_ai_left:	; $71A2
        lda     *farthest_left          ; left-most column guard can get to on this row
        cmpa    *guard_ai_col           ; there now?
        beq     locret_71A1             ; yes, exit
        ldb     *guard_ai_row
        cmpb    #15                     ; bottom row?
        beq     1$											; yes, go (no good)
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row below)
        ldb     *farthest_left
        ldy     *byte_9
        lda			b,y											; get object from tilemap (below farthest left)
        cmpa    #1                      ; brick?
        beq     1$											; yes, go
        cmpa    #2                      ; solid?
        beq     1$											; yes, go
        lda     *farthest_left
        ldb     *guard_ai_row
        jsr     find_farthest_down
        ldb     *farthest_left
        jsr     calc_row_col_delta
        cmpa    *guard_ai_best_delta
        bcc     1$
        sta     *guard_ai_best_delta
        lda     #1                      ; LEFT
        sta     *guard_ai_dir
1$:     ldb     *guard_ai_row           ; top row?
        beq     2$											; yes, go
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9                 ; setup tilemap address
        ldb     *farthest_left
        ldy     *byte_9
        lda			b,y											; get object from tilemap
        cmpa    #3                      ; ladder?
        bne     2$											; no, go
        ldb     *guard_ai_row
        lda     *farthest_left
        jsr     find_farthest_up
        ldb     *farthest_left
        jsr     calc_row_col_delta
        cmpa    *guard_ai_best_delta
        bcc     2$
        sta     *guard_ai_best_delta
        lda     #1                      ; LEFT
        sta     *guard_ai_dir
2$:     inc     *farthest_left
        jmp     guard_ai_left

locret_720B:	; $720B
				rts
				
guard_ai_right:	; $720C
        lda     *farthest_right
        cmpa    *guard_ai_col           ; left-most column?
        beq     locret_720B             ; yes, exit
        ldb     *guard_ai_row
        cmpb    #15                     ; bottom row?
        beq     1$											; yes, go
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row below)
        ldb     *farthest_right
        ldy     *byte_9
        lda			b,y											; get object from tilemap (below)
        cmpa    #1                      ; brick?
        beq     1$											; yes, go
        cmpa    #2                      ; solid?
        beq     1$											; yes, go
        lda     *farthest_right
        ldb     *guard_ai_row
        jsr     find_farthest_down
        ldb     *farthest_right
        jsr     calc_row_col_delta
        cmpa    *guard_ai_best_delta
        bcc     1$
        sta     *guard_ai_best_delta
        lda     #2                      ; RIGHT
        sta     *guard_ai_dir
1$:     ldb     *guard_ai_row           ; top row?
        beq     2$											; yes, go
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9                 ; setup tilemap address
        ldb     *farthest_right
        ldy     *byte_9
        lda			b,y											; get object from tilemap address
        cmpa    #3                      ; ladder?
        bne     2$											; no, go
        ldb     *guard_ai_row
        lda     *farthest_right
        jsr     find_farthest_up
        ldb     *farthest_right
        jsr     calc_row_col_delta
        cmpa    *guard_ai_best_delta
        bcc     2$
        sta     *guard_ai_best_delta
        lda     #2                      ; RIGHT
        sta     *guard_ai_dir
2$:     dec     *farthest_right
        jmp     guard_ai_right

guard_ai_up_down:	; $7275
        ldb     *guard_ai_row
        cmpb    #15                     ; bottom row?
        beq     guard_ai_cant_go_down   ; yes, go
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row below)
        ldb     *guard_ai_col
        ldy     *byte_9
        lda			b,y											; get object from tilemap (below)
        cmpa    #1                      ; brick?
        beq     guard_ai_cant_go_down   ; yes, go
        cmpa    #2                      ; solid?
        beq     guard_ai_cant_go_down   ; yes, go
        lda     *guard_ai_col
        ldb     *guard_ai_row
        jsr     find_farthest_down      ; A=farthest row (down)
        ldb     *guard_ai_col
        jsr     calc_row_col_delta
        cmpa    *guard_ai_best_delta
        bcc     guard_ai_cant_go_down
        sta     *guard_ai_best_delta
        lda     #4                      ; DOWN
        sta     *guard_ai_dir

guard_ai_cant_go_down:	; $72A7
        ldb     *guard_ai_row           ; top row?
        beq     1$											; yes, exit
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9                 ; setup tilemap address
        ldb     *guard_ai_col
        ldy     *byte_9
        lda			b,y											; get object from tilemap
        cmpa    #3                      ; ladder?
        bne     1$											; no, exit
        lda     *guard_ai_col
        ldb     *guard_ai_row
        jsr     find_farthest_up        ; A=farthest row (up)
        ldb     *guard_ai_col
        jsr     calc_row_col_delta
        cmpa    *guard_ai_best_delta
        bcc     1$
        sta     *guard_ai_best_delta
        lda     #3                      ; UP
        sta     *guard_ai_dir
1$:			rts

calc_row_col_delta:	; $72D4
; A=farthest, B=col
        sta     *nibble_cnt             ; A=farthest down, B=col
        cmpa    *current_row            ; same as player?
        bne     calc_row_delta          ; no, skip
        cmpb    *curr_guard_col         ; compare column
        bcs     1$											; to the left
        tfr			b,a											; A=col
        suba   	*curr_guard_col         ; delta col
        rts
1$:     stb     *nibble_cnt             ; guard_ai_col
        lda     *curr_guard_col
        suba		*nibble_cnt             ; delta col
        rts

calc_row_delta:	; $72EB
        bcs     1$
        suba		*current_row            ; delta row
        adda    #200                    ; weighting
        rts
1$:     lda     *current_row
        suba		*nibble_cnt             ; delta row
        adda    #100                    ; weighting
        rts

loc_72FD:	; $72FD
				lda     *byte_5e								; row
        rts

find_farthest_up:	; $7300
        stb     *byte_5e                ; row
        sta     *byte_5d                ; col
loc_7304:	; $7304
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9                 ; setup tilemap address
        ldb     *byte_5d                ; col
        ldy     *byte_9
        lda			b,y											; get object from tilemap
        cmpa    #3                      ; ladder?
        bne     loc_72FD                ; no, exit
        dec     *byte_5e                ; can get to row above
        ldb     *byte_5d                ; col
        beq     up_try_right            ; left-most column? yes, go
        decb                            ; column to left
        ldy     *byte_9
        lda			b,y											; get object from tilemap (left)
        cmpa    #1                      ; brick?
        beq     1$											; yes, go
        cmpa    #2                      ; solid?
        beq     1$											; yes, go
        cmpa    #3                      ; ladder?
        beq     1$											; yes, go
        ldb     *byte_5e                ; row (above)
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (above)
        ldb     *byte_5d                ; col
        decb                            ; column to left
        ldy     *byte_9
        lda			b,y											; get object from tilemap (above, left)
        cmpa    #4                      ; rope?
        bne     up_try_right            ; no, go
1$:     lda     *byte_5e                ; row
        sta     *farthest_updown_plyr_row
        cmpa    *current_row            ; compare with player
        bcs     farthest_up_is_player_row	; above player - exit
        beq     farthest_up_is_player_row	; same row as player - exit

up_try_right:	; $734A
        ldb     *byte_5d                ; col
        cmpb    #27                     ; right-most?
        beq     try_next_row_up					; yes, go
        ldb     *byte_5e                ; row (above)
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address
        ldb     *byte_5d                ; col
        incb                            ; column to right
        ldy     *byte_9
        lda			b,y											; get object from tilemap (right)
        cmpa    #1                      ; brick?
        beq     1$											; yes, go
        cmpa    #2                      ; solid?
        beq     1$											; yes, go
        cmpa    #3                      ; ladder?
        beq     1$											; yes, go
        ldb     *byte_5e                ; row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row above)
        ldb     *byte_5d                ; col
        incb                            ; column to right
        ldy     *byte_9
        lda			b,y											; get object from tilemap (right, above)
        cmpa    #4                      ; rope?
        bne     try_next_row_up					; no, go
1$:     lda     *byte_5e                ; row
        sta     *farthest_updown_plyr_row
        cmpa    *current_row            ; compare with player
        bcs     farthest_up_is_player_row	; above player - exit
        beq     farthest_up_is_player_row	; same row as player - exit

try_next_row_up:	; $738C
        ldb     *byte_5e                ; row
        cmpb    #1                      ; top row?
        bcs     1$											; yes, exit
        jmp     loc_7304                ; loop
1$:     rts

farthest_up_is_player_row:	; $7397
        lda     *farthest_updown_plyr_row
        rts

loc_739A:	; $739A
				lda			*byte_5e
				rts
				
find_farthest_down:	; $739D
        stb     *byte_5e                ; store row
        sta     *byte_5d                ; store col
loc_73A1:	; $73A1
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row below)
        ldb     *byte_5d                ; col
        ldy     *byte_9
        lda			b,y											; get object from tilemap
        cmpa    #1                      ; brick?
        beq     loc_739A                ; yes, exit
        cmpa    #2                      ; solid?
        beq     loc_739A                ; yes, exit
        ldb     *byte_5e                ; row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9                 ; setup tilemap address
        ldb     *byte_5d                ; col
        ldy     *byte_9
        lda			b,y											; get object from tilemap
        cmpa    #0                      ; space (falling)?
        beq     try_next_row_down       ; yes, go
        cmpb    #0                      ; (ladder or rope - can move left/right)
                                        ; left-most col?
        beq     down_try_right          ; yes, go
        decb                            ; column to left
        ldy     *byte_9
        lda			b,y											; get object from tilemap (left)
        cmpa    #4                      ; rope?
        beq     1$			                ; yes, go
        ldb     *byte_5e                ; row
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row below)
        ldb     *byte_5d                ; col
        decb                            ; column to left
        ldy     *byte_9
        lda			b,y											; get object from tilemap (below, left)
        cmpa    #1                      ; brick?
        beq     1$											; yes, go
        cmpa    #2                      ; solid?
        beq     1$											; yes, go
        cmpa    #3                      ; ladder?
        bne     down_try_right          ; no, go
1$:     lda     *byte_5e                ; row
        sta     *farthest_updown_plyr_row
        cmpa		*current_row            ; compare with player
        bcc     farthest_down_is_player_row ; guard same row or below player, exit

down_try_right:	; $73FB
        ldb     *byte_5d                ; col
        cmpb    #27                     ; right-most column?
        bcc     try_next_row_down       ; yes, go
        incb                            ; column to right
        ldy     *byte_9
        lda			b,y											; get object from tilemap (row/below, right)
        cmpa    #4                      ; rope?
        beq     1$											; yes, go
        ldb     *byte_5e                ; row
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row below)
        ldb     *byte_5d                ; col
        incb                            ; column to right
        ldy     *byte_9
        lda			b,y											; get object from tilemap (below, right)
        cmpa    #1                      ; brick?
        beq     1$											; yes, go
        cmpa    #3                      ; ladder?
        beq     1$											; yes, go
        cmpa    #2                      ; solid?
        bne     try_next_row_down       ; no, go
1$:     lda     *byte_5e                ; row
        sta     *farthest_updown_plyr_row
        cmpa   	*current_row            ; compare with player
        bcc     farthest_down_is_player_row ; guard same row or below player, exit

try_next_row_down:	; $742D
        inc     *byte_5e                ; next row down
        ldb     *byte_5e                ; row
        cmpb    #16                     ; past bottom of screen?
        bcc     1$											; yes, exit
        jmp     loc_73A1                ; loop
1$:     lda     #15
        rts

farthest_down_is_player_row:	; $743B
        lda     *farthest_updown_plyr_row
        rts
				
find_farthest_left_right:	; $743E
; A=col, B=row
        sta     *farthest_left        	; save col
        sta     *farthest_right       	; save col (again)
        stb     *scanline               ; save row

find_farthest_left:	; $7444
        lda     *farthest_left        	; guard col
        beq     find_farthest_right   	; left-most col? yes, go
        ldb     *scanline               ; guard row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr ; setup tilemap address
        ldb     *farthest_left        	; guard col
        decb                            ; column to left
        ldy     *msb_row_level_data_addr
        lda			b,y											; get object from tilemap (left)
        cmpa    #1                      ; brick?
        beq     find_farthest_right   	; yes, go
        cmpa    #2                      ; solid?
        beq     find_farthest_right   	; yes, go
        cmpa    #3                      ; ladder?
        beq     1$											; yes, go
        cmpa    #4                      ; rope?
        beq     1$											; yes, go
        ldb     *scanline               ; guard row
        cmpb    #15                     ; bottom row?
        beq     1$											; yes, go
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap (row below)
        ldb     *farthest_left
        decb                            ; below left
        ldy     *byte_9
        lda			b,y											; get object from tilemap (below, left)
        cmpa    #1                      ; brick?
        beq     1$											; yes, we can walk on it, go
        cmpa    #2                      ; solid?
        beq     1$											; yes, we can walk on it, go
        cmpa    #3                      ; ladder?
        bne     2$											; no, we can't walk on it, go
1$:     dec     *farthest_left
        bpl     find_farthest_left    	; try again
2$:     dec     *farthest_left

find_farthest_right: ; $7490
        lda     *farthest_right
        cmpa    #27                     ; right-most column?
        beq     3$											; yes, go
        ldb     *scanline               ; guard row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *lsb_row_level_data_addr
        ldy     #msb_row_addr_1
        lda			b,y
        sta     *msb_row_level_data_addr ; setup tilemap address
        ldb     *farthest_right
        incb                            ; column to right
        ldy     *msb_row_level_data_addr
        lda			b,y											; get object from tilemap (right)
        cmpa    #1                      ; brick?
        beq     3$											; yes, exit
        cmpa    #2                      ; solid?
        beq     3$											; yes, exit
        cmpa    #3                      ; ladder?
        beq     1$											; yes, go
        cmpa    #4                      ; rope?
        beq     1$											; yes, go
        ldb     *scanline               ; guard row
        cmpb    #15                     ; bottom row?
        beq     1$											; yes, go
        ldy     #(lsb_row_addr+1)
        lda			b,y
        sta     *byte_8
        ldy     #(msb_row_addr_2+1)
        lda			b,y
        sta     *byte_9                 ; setup tilemap address (row below)
        ldb     *farthest_right
        incb                            ; column to right
        ldy     *byte_9
        lda			b,y											; get object from tilemap (below, right)
        cmpa    #1                      ; brick?
        beq     1$											; yes, go
        cmpa    #2                      ; solid?
        beq     1$											; yes, go
        cmpa    #3                      ; ladder?
        bne     2$											; no, go
1$:     inc     *farthest_right
        bpl     find_farthest_right   	; try again
2$:     inc     *farthest_right
3$:			rts
								
calc_guard_xychar:	; $74DF
				lda			*curr_guard_col
				ldb			*curr_guard_x_offset
				jsr			calc_x_in_2_pixel_incs	; B=x
				stb			*msg_char
				ldb			*curr_guard_row
				lda			*curr_guard_y_offset
				jsr			calc_scanline						; B=scanline
				tfr			d,x											; X(lsb)=scanline
				ldb			*curr_guard_sprite
				ldy			#guard_sprite_to_char_tbl
				lda			b,y											; A=char
				ldb			*msg_char								; B=x_in_2_pixel_incs		
				rts

check_guard_pickup_gold:	; $74F7
				lda			*curr_guard_x_offset
				cmpa		#2
				bne			1$
				lda			*curr_guard_y_offset
				cmpa		#2
				bne			1$
				ldb			*curr_guard_row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*curr_guard_col
				ldy			*byte_9
				lda			b,y											; get object from tilemap
				cmpa		#7											; gold?
				bne			1$											; no, exit
				lda			*curr_guard_state
				bmi			1$
				lda			#-1
				suba		*guard_respawn_col
				sta			*curr_guard_state
				lda			#0											; space
				sta			b,y											; remove gold from tilemap
				ldb			*curr_guard_row
				stb			*row
				ldb			*curr_guard_col
				stb			*col
				jsr			display_char_pg2				; render space on bg
				ldb			*row
				lda			*col
				jsr			calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				lda			#7											; A=char (gold)
				jmp			wipe_char
1$:			rts

check_guard_drop_gold:	; $753E
				lda			*curr_guard_state
				bpl			2$
				inc			*curr_guard_state
				bne			2$
        ldb     *curr_guard_row
        stb     *row
        ldy     #lsb_row_addr
        lda			b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda			b,y
        sta     *byte_9									; setup tilemap address
        ldb     *curr_guard_col
        stb     *col                    ; col
        ldy     *byte_9
        lda			b,y											; get object from tilemap
        cmpa    #0                      ; space?
        bne     1$											; no, skip
        lda     #7                      ; gold
        sta     b,y											; update tilemap
        jsr     display_char_pg2        ; render onto background
        ldb     *row
        lda     *col
        jsr     calc_colx5_scanline
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
        lda     #7                      ; gold
        jmp     display_transparent_char ; render onto fg
1$:     dec     *curr_guard_state
2$:			rts

update_guard_sprite_index:	; $7574
				inc			*curr_guard_sprite
				cmpa		*curr_guard_sprite
				bcs			2$
1$:			sta			*curr_guard_sprite
				rts
2$:			cmpb		*curr_guard_sprite
				bcs			1$								
				rts
												
adjust_guard_x_offset:	; $7582
				lda			*curr_guard_x_offset
				cmpa		#2
				bcs			1$
				beq			2$
				dec			*curr_guard_x_offset
				jmp			check_guard_pickup_gold
1$:			inc			*curr_guard_x_offset
				jmp			check_guard_pickup_gold
2$:			rts

adjust_guard_y_offset:	; $7595
				lda			*curr_guard_y_offset
				cmpa		#2
				bcs			1$
				beq			2$
				dec			*curr_guard_y_offset
				jmp			check_guard_pickup_gold
1$:			inc			*curr_guard_y_offset
				jmp			check_guard_pickup_gold
2$:			rts
																				
copy_curr_to_guard:	; $75A8
				ldb			*curr_guard
				lda			*curr_guard_col
				ldy			#guard_col
				sta			b,y
				lda			*curr_guard_row
				ldy			#guard_row
				sta			b,y
				lda			*curr_guard_x_offset
				ldy			#guard_x_offset
				sta			b,y
				lda			*curr_guard_y_offset
				ldy			#guard_y_offset
				sta			b,y
				lda			*curr_guard_state
				ldy			#guard_state
				sta			b,y
				lda			*curr_guard_dir
				ldy			#guard_dir
				sta			b,y
				lda			*curr_guard_sprite
				ldy			#guard_sprite
				sta			b,y
				rts
								
copy_guard_to_curr:	; $75CE
				ldb			*curr_guard
				ldy			#guard_col
				lda			b,y
				sta			*curr_guard_col
				ldy			#guard_row
				lda			b,y
				sta			*curr_guard_row
				ldy			#guard_x_offset
				lda			b,y
				sta			*curr_guard_x_offset
				ldy			#guard_y_offset
				lda			b,y
				sta			*curr_guard_y_offset
				ldy			#guard_sprite
				lda			b,y
				sta			*curr_guard_sprite
				ldy			#guard_dir
				lda			b,y
				sta			*curr_guard_dir
				ldy			#guard_state
				lda			b,y
				sta			*curr_guard_state
				rts
				
respawn_guards_and_update_holes: ; $75F4
				jsr			check_and_handle_respawn
				inc			*guard_respawn_col
				lda			*guard_respawn_col
				cmpa		#28											; right-most_column?
				bcs			1$											; no, skip
				lda			#0
				sta			*guard_respawn_col			; reset
1$:			ldb			#0x1e										; max number of holes
check_hole:
				ldy			#hole_cnt
				lda			b,y											; get hole counter
				stb			*byte_88								; save hole#
				tsta														; 6809 only!
				bne			update_hole							; active, go
				jmp			next_hole

update_hole:	; $760f
				dec			b,y											; dec hole counter
				beq			restore_brick
				ldy			#hole_col
				lda			b,y
				sta			*col
				ldy			#hole_row
				lda			b,y
				sta			*row
				ldy			#hole_cnt
				lda			b,y
				cmpa		#20											; counter=20?
				bne			chk_hole_cnt_10					; no, skip
				lda			#0x37										; brick re-fill 0
update_hole_tile:	; $7627
				jsr			display_char_pg2
				lda			*col
				ldb			*row
				jsr			calc_colx5_scanline		
				tfr			d,x											; X(lsb)=scanline
				tfr			a,b											; B=x_in_2_pixel_incs
				lda			#0											; space
				jsr			wipe_char
goto_next_hole: ; $7636				
				jmp			next_hole
chk_hole_cnt_10:	; $7636
				cmpa		#10											; counter=10?
				bne			goto_next_hole					; no, skip
				lda			#0x38										; brick refill 1
				bra			update_hole_tile

restore_brick:	; $7641
				ldb			*byte_88								; hole#
				ldy			#hole_row
				lda			b,y
				sta			*row
				tfr			a,b											; B=row
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
				ldb			*byte_88								; hole#
				ldy			#hole_col
				lda			b,y
				sta			*col
				tfr			a,b											; B=col
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				cmpa		#0											; space?
				bne			1$											; no, skip
				jmp			redisplay_brick
1$:			cmpa		#9											; player?
				bne			2$											; no, skip
				KILL_PLAYER
2$:			cmpa		#8											; guard?
				beq			4$											; yes, go
				cmpa		#7											; gold?	
				bne			3$											; no, skip
				dec			*no_gold								; gold lost forever
3$:			jmp			redisplay_brick
4$:			lda			#1											; brick
				sta			b,y											; update tilemap
				ldy			*byte_9
				sta			b,y											; update tilemap
				jsr			display_char_pg1				; render on screen
				lda			#1											; brick
				jsr			display_char_pg2				; render on bg
				ldb			*no_guards

check_trapped_guards:	; $768A
				ldy			#guard_col
				lda			b,y
				cmpa		*col										; same column?
				lbne		check_next_trapped			; no, skip
				ldy			#guard_row
				lda			b,y
				cmpa		*row										; same row?
				lbne		check_next_trapped			; no, skip
				ldy			#guard_state
				lda			b,y											; carrying gold?
				bpl			1$											; no, skip
				dec			*no_gold								; gold gone
1$:			lda			#0x7f
				sta			b,y											; update guard state				
				stb			*curr_guard							; make current
				jsr			copy_guard_to_curr
				jsr			calc_guard_xychar
				jsr			wipe_char
				ldb			*curr_guard
				lda			#1
				sta			*row										; guard row=1
2$:			ldb			*row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*byte_8
				ldy			#msb_row_addr_2
				lda			b,y
				sta			*byte_9									; setup tilemap address
				ldb			*guard_respawn_col
3$:			ldy			*byte_9
				lda			b,y											; get object from tilemap				
				cmpa		#0											; space?
				beq			4$											; yes, skip
				inc			*guard_respawn_col
				ldb			*guard_respawn_col
				cmpb		#28											; right-most column?
				bcs			3$											; no, try again
				inc			*row										; next row down
				lda			#0
				sta			*guard_respawn_col			; reset
				bra			2$											; try again
4$:			tfr			b,a											; A=column
				ldb			*curr_guard
				ldy			#guard_col
				sta			b,y											; set column
				lda			*row
				ldy			#guard_row
				sta			b,y											; set row
				lda			#20
				ldy			#guard_cnt
				sta			b,y											; init count
				lda			#2
				ldy			#guard_y_offset
				sta			b,y
				ldy			#guard_x_offset
				sta			b,y
				lda			#0
				ldy			#guard_sprite
				sta			b,y
				ldd			#SCORE_KILL							; add 75/100 pts
				jsr			update_and_display_score
				jmp			next_hole

check_next_trapped:	; $76FE
				decb
				lbne		check_trapped_guards

redisplay_brick:	; $7701				
				lda			#1											; brick
				ldy			*msb_row_level_data_addr
				sta			b,y											; update tilemap
				jsr			display_char_pg1
				lda			#1											; brick
				jsr			display_char_pg2
				
next_hole:	; $770D
				ldb			*byte_88								; hole#
				decb														; next hole
				bmi			1$											; done? yes, exit
				jmp			check_hole							; loop
1$:			
loc_7715:
				rts				

check_and_handle_respawn:	; $7716
				ldb			*no_guards
				beq			loc_7715
				lda			*curr_guard
				pshs		a
loc_771d: ; $771D				
				ldy			#guard_cnt
				lda			b,y
				beq			next_guard
				stb			*curr_guard
				jsr			copy_guard_to_curr
				lda			#0x7f
				ldy			#guard_state
				sta			b,y
				ldy			#guard_col
				lda			b,y
				sta			*col
				ldy			#guard_row
				lda			b,y
				sta			*row
				ldy			#guard_cnt
				dec			b,y
				beq			finish_respawn
				lda			b,y
				cmpa		#19
				bne			2$
				lda			#0x39										; guard respawn 0
				jsr			display_char_pg2				; render on bg
				jsr			calc_guard_xychar
				lda			#0x39										; guard respawn 0
				jsr			display_transparent_char	; render on screen
				jmp			3$
2$:			cmpa		#10
				bne			next_guard
				lda			#0x3a										; guard respawn 1				
				jsr			display_char_pg2				; render on bg
				jsr			calc_guard_xychar
				lda			#0x3a										; guard respawn 1
				jsr			display_transparent_char	; render on screen
3$:			ldb			*curr_guard
next_guard: ; $7765
				decb
				bne			loc_771d
				puls		a
				sta			*curr_guard
				rts

finish_respawn:	; $776C
				ldb			*row
				ldy			#lsb_row_addr
				lda			b,y
				sta			*lsb_row_level_data_addr
				ldy			#msb_row_addr_1
				lda			b,y
				sta			*msb_row_level_data_addr	; setup tilemap address
				ldb			*curr_guard
				ldy			#guard_cnt
				inc			b,y
				ldb			*col
				ldy			*msb_row_level_data_addr
				lda			b,y											; get object from tilemap
				bne			next_guard							; not a space, exit
				lda			#8											; guard
				sta			b,y											; update tilemap
				lda			#0											; space
				jsr			display_char_pg2				; render on bg
				lda			#0
				ldb			*curr_guard
				ldy			#guard_state
				sta			b,y											; init state
				ldy			#guard_cnt
				sta			b,y											; init count
				lda			#8											; guard
				jsr			display_char_pg1
				;jsr			sub_87e1								; sound?
				ldb			*curr_guard
				jmp			next_guard
				
												
ctrl_m:	; $77AC
				jsr			cls_and_display_high_scores
				ldb			#5
0$:			ldy			#0
1$:			ldx			#PIA0
				lda			#0											; all columns
				sta			2,x											; column strobe
				lda			,x											; active low
				coma														; active high
				bne			2$											; key, exit
				leay		-1,y
				bne			1$
				decb
				bne			0$
2$:			HGR1
        jsr     gcls2
        ldb     #15                     ; 15 rows to draw
        stb     *row
3$:     ldy     #lsb_row_addr
        lda     b,y
        sta     *byte_8
        ldy     #msb_row_addr_2
        lda     b,y
        sta     *byte_9                 ; setup tilemap address
        ldb     #27                     ; 28 columns to draw
        stb     *col
4$:     ldy     *byte_9
        lda     b,y                     ; get object from tilemap
        cmpa    #5                      ; fall-thru?
        bne     5$                      ; no, skip
        lda     #1                      ; display brick
5$:     jsr     display_char_pg2
        dec     *col
        ldb     *col
        bpl     4$                      ; draw row
        dec     *row
        ldb     *row
        bpl     3$                      ; draw all rows
        ldb     #0x1e                   ; max holes
6$:     stb     *byte_88
        ldy     #hole_cnt
        lda     b,y                     ; hole active?
        beq     9$                      ; no, skip
        pshs    a                       ; A=hole_cnt
        ldy     #hole_row
        lda     b,y                     ; get row
        sta     *row
        ldy     #hole_col
        lda     b,y                     ; get column
        sta     *col
        puls    a                       ; A=hole_cnt
        cmpa    #0x15
        bcs     7$                      ; skip
        lda     #0                      ; space
        jsr     display_char_pg2        ; render onto background
        bra     9$
7$:     cmpa    #0x0b
        bcs     8$                      ; skip
        lda     #0x37                   ; brick refill 0
        jsr     display_char_pg2        ; render onto background
        bra     9$
8$:     lda     #0x38                   ; brick refill 1
        jsr     display_char_pg2        ; render onto background
9$:     ldb     *byte_88
        decb
        bpl     6$                      ; loop all holes
        ldb     *no_guards              ; any guards?
        beq     14$                     ; no, exit
10$:    ldy     #guard_cnt
        lda     b,y                     ; get guard_cnt
        stb     *byte_88                ; zero?
        tsta                            ; 6809 only
        beq     13$                     ; yes, skip
        pshs    a                       ; A=guard_cnt
        ldy     #guard_col
        lda     b,y
        sta     *col
        ldy     #guard_row
        lda     b,y
        sta     *row
        puls    a                       ; A=guard_cnt
        cmpa    #0x14
        bcc     13$                     ; skip
        cmpa    #0x0b
        bcs     11$                     ; skip
        lda     #0x39
        bne     12$                     ; skip
11$:    lda     #0x3a
12$:    jsr     display_char_pg2
13$:    ldb     *byte_88
        decb
        bne     10$                     ; loop all guards
14$:    jmp     read_controls        
				
cls_and_display_high_scores:	; $786B
				jsr			gcls2
				lda			#HGR2_MSB
				sta			*display_char_page
				lda			#0
				sta			*col
				sta			*row
				jsr			display_message
				.ascii	"    LODE RUNNER HIGH SCORES\r\r\r"
				.ascii	"    INITIALS LEVEL  SCORE\r"
				.ascii	"    -------- ----- --------\r"
				.db			0
				lda			#1
				sta			*guard_ai_col						; counter
display_hs:	; $78D4		
				cmpa		#10											; 10th score?
				bne			2$											; no, skip
				lda			#1
				jsr			display_digit
				lda			#0
				jsr			display_digit						; "10"
				bra			3$
2$:			lda			#(0x80|0x20)						; space
				jsr			display_character
				lda			*guard_ai_col
				jsr			display_digit
3$:			jsr			display_message
				.asciz	".    "
        ldb     *guard_ai_col           ; score counter
        ldy     #high_score_offset_tbl
        lda     b,y
        sta     *guard_ai_row           ; offset into hs table
        ldy     #(hs_tbl+3)             ; level offset
        tfr     a,b
        lda     b,y                     ; level, zero?
        bne     4$                      ; no, skip
        lbra    next_hs
4$:     ldb     *guard_ai_row           ; offset into hs table
				ldy			#(hs_tbl+0)
				lda			b,y											; initial #1
				ora			#(1<<7)
				jsr			display_character
        ldb			*guard_ai_row
        ldy			#(hs_tbl+1)
        lda			b,y											; initial #2
        ora			#(1<<7)
				jsr			display_character
        ldb			*guard_ai_row
        ldy			#(hs_tbl+2)
        lda			b,y											; initial #3
        ora			#(1<<7)
				jsr			display_character
				jsr			display_message
				.asciz	"    "		
				ldb			*guard_ai_row
        ldy			#(hs_tbl+3)
				lda			b,y											; level
				jsr			cnv_byte_to_3_digits
				lda			*hundreds
				jsr			display_digit
				lda			*tens
				jsr			display_digit
				lda			*units
				jsr			display_digit
				jsr			display_message
				.asciz	"  "
				ldb			*guard_ai_row
				ldy			#(hs_tbl+4)
				lda			b,y											; millions
				jsr			cnv_bcd_to_2_digits
				lda			*tens
				jsr			display_digit
				lda			*units
				jsr			display_digit
				ldb			*guard_ai_row
				ldy			#(hs_tbl+5)
				lda			b,y											; hundreds, tens of thousands
				jsr			cnv_bcd_to_2_digits
				lda			*tens
				jsr			display_digit
				lda			*units
				jsr			display_digit
				ldb			*guard_ai_row
				ldy			#(hs_tbl+6)
				lda			b,y											; thousands, hundreds
				jsr			cnv_bcd_to_2_digits
				lda			*tens
				jsr			display_digit
				lda			*units
				jsr			display_digit
				ldb			*guard_ai_row
				ldy			#(hs_tbl+7)
				lda			b,y											; tens, units
				jsr			cnv_bcd_to_2_digits
				lda			*tens
				jsr			display_digit
				lda			*units
				jsr			display_digit
next_hs:	; $788C
				jsr			cr
				inc			*guard_ai_col						; next score
				lda			*guard_ai_col
				cmpa		#11											; done all scores?
				bcc			done_hs
				lbra		display_hs
done_hs:	; $799A				
				HGR2
				lda			#HGR1_MSB
				sta			*display_char_page				
				rts

high_score_offset_tbl:	; $79A2
				.db			0, 0, 8, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48
																																				
cls_and_display_game_status:	; $79AD
				jsr			gcls1
				jsr			gcls2
				lda			*display_char_page			; 0x00/0x20
				ora			#>(176*VIDEO_BPL)
				ldb			#<(176*VIDEO_BPL)				; offset
				tfr			d,x				
.ifdef GFX_1BPP
				lda			#0xaa
.else
	.ifdef GFX_MONO	
				lda			#0xcc										; pattern
	.else
				lda			#0xaa
	.endif
.endif
				ldb			#(APPLE_BPL-1)					; last column on screen
1$:			sta			0*VIDEO_BPL,x           					
				sta			1*VIDEO_BPL,x          					
				sta			2*VIDEO_BPL,x          					
				sta			3*VIDEO_BPL,x						; 4 scanlines of pixels
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
				ldd			#0x0000									; add 0 pts
				bra			update_and_display_score				

get_line_addr_curr_page:	; $7A31
; B=scanline
				lda			#VIDEO_BPL
				mul
				ora			*hires_page_msb_1
				stb			*lsb_line_addr_pg1
				sta			*msb_line_addr_pg1
				rts				

get_line_addr_pgs_1_2: ; $7A3E
; B=scanline
				lda			#VIDEO_BPL
				mul
				stb			*lsb_line_addr_pg1
				stb			*lsb_line_addr_pg2
				ora			#HGR1_MSB
				sta			*msb_line_addr_pg1
				eora		#(HGR1_MSB | HGR2_MSB)
				sta			*msb_line_addr_pg2
				rts
				
gcls1: ; $7A51
				lda			#HGR1_MSB
				ldb			#0
				tfr			d,x											; start addr
; not sure why this doesn't work				
;				leax		-4,x										; video offset in GIME
				adda		#>(VIDEO_BPL*192)
				tfr			d,y											; end addr
				bra			gcls
gcls2:
				lda			#HGR2_MSB
				ldb			#0
				tfr			d,x											; start addr
				leax		-4,x										; video offset in GIME
				adda		#>(VIDEO_BPL*192)
				tfr			d,y											; end addr
gcls:		sty			*word_a
				lda			#0x00
1$:			sta			,x+
				cmpx		*word_a
				bne			1$
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

initial_cnt:  ; $824D
        .ds     1
        
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
				ldb			#VIDEO_BPL
				mul
				ora			*hires_page_msb_1				; OR-in page address
				tfr			d,y
				ldb			*col_addr_offset
				leay		b,y											; video address
				ldb			#11											; 11 lines
2$:			lda			0,y											; get 1st byte from video
				anda		*lchar_mask							; preserve adjacent tile data
				ora			,x+											; OR-in render byte
				sta			0,y											; update video
.ifdef GFX_1BPP				
				lda			1,y											; get 2nd byte from video
				anda		*rchar_mask							; preserve adjacent tile data
				ora			,x+											; OR-in render byte
.else
				lda			,x+											; get render byte				
.endif				
				sta			1,y											; update video
.ifdef GFX_2BPP
				lda			2,y
				anda		*rchar_mask
				ora			,x+
				sta			2,y
.endif				
				leay		VIDEO_BPL,y
				decb
				bne			2$
				rts

.ifdef GFX_1BPP
left_char_masks:	; $8328
				.db			0x00, 0xc0, 0xf0, 0xfc
right_char_masks:	; $832F
				.db			0x3f, 0x0f, 0x03, 0x00
.else
left_char_masks:	; $8328
				.db			0x00, 0xf0
right_char_masks:	; $832F
				.db			0x0f, 0x00
.endif

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
.ifdef GFX_2BPP
				incb
				lda			,y+											; get data from render buffer
				coma														; invert character data
				ldx			*msb_line_addr_pg1
				pshs		x
				anda		b,x											; mask off character
				ldx			*msb_line_addr_pg2
				ora			b,x											; OR-in background
				puls		x
				sta			b,x											; update video byte
.endif				
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
				sta			*collision_detect       ; initialise
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
				ora			*collision_detect
				sta			*collision_detect
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
				ora			*collision_detect
				sta			*collision_detect
				lda			,x											; get byte to be rendered
				ldy			*msb_line_addr_pg1
				ora			b,y
				sta			b,y											; update video byte
				inx															; next render buffer address
.ifdef GFX_2BPP
				incb														; next video address
				lda			b,y
				ldy			*msb_line_addr_pg2
				eora		b,y
				anda		,x
				ora			*collision_detect
				sta			*collision_detect
				lda			,x											; get byte to be rendered
				ldy			*msb_line_addr_pg1
				ora			b,y
				sta			b,y											; update video byte
				inx
.endif				
				inc			*scanline
				dec			*scanline_cnt
				bne			OR_2_byte_char_to_video
				rts

.ifdef GFX_1BPP
BPC			.equ		2*11
.else
BPC			.equ		3*11
.endif
								
render_char_in_buffer:	; $8438
				ldx			#char_bank_tbl
				lda			*col_pixel_shift				; 0,2,4,6 (same as word offset)
				ldy			a,x											; ptr entry
				leax		,y											; entry (X=bank address)
				lda			*msg_char
				ldb			#BPC
				mul															; offset into bank
				leax		d,x											; X=ptr char data
				ldb			#BPC										; no. bytes to copy
				ldy			#char_render_buf				; destination
1$:			lda			,x+
				sta			,y+
				decb														; done all bytes?
				bne			1$											; no, loop
				rts

char_bank_tbl:
				.dw			#tile_data+0*BPC*104
				.dw			#tile_data+1*BPC*104
.ifdef GFX_1BPP
				.dw			#tile_data+2*BPC*104
				.dw			#tile_data+3*BPC*104
.endif				

check_and_update_high_score_tbl:	; $84C8
				lda			*no_cheat								; cheating?
				beq			3$											; yes, skip high score update
				lda			*score_1e1_1
				ora			*score_1e3_1e2
				ora			*score_1e5_1e4
				ora			*score_1e6							; score = 0?
				beq			3$											; yes, exit
; the Apple version checks the disk here				
				ldb			#1											; 1st high score
1$:			ldy			#high_score_offset_tbl
				lda			b,y
				stb			*guard_ai_row						; 6809 only
				tfr			a,b											; B=offset
				lda			*level
				ldy			#(hs_tbl+3)							; high score level
				cmpa		b,y											; compare
				bcs			2$											; lower, skip
				bne			add_hs_entry
				lda			*score_1e6
				ldy			#(hs_tbl+4)							; millions
				cmpa		b,y											; compare
				bcs			2$											; lower, skip
				bne			add_hs_entry
				lda			*score_1e5_1e4
				ldy			#(hs_tbl+5)							; hundreds, tens of thousands
				cmpa		b,y											; compare
				bcs			2$											; lower, skip
				bne			add_hs_entry
				lda			*score_1e3_1e2
				ldy			#(hs_tbl+6)							; thousands, hundreds
				cmpa		b,y											; compare
				bcs			2$											; lower, skip
				bne			add_hs_entry
				lda			*score_1e1_1
				ldy			#(hs_tbl+7)							; tens, units
				cmpa		b,y											; compare
				bcs			2$											; lower, skip
				bne			add_hs_entry
2$:			ldb			*guard_ai_row						; B=entry index (6809 only)
				incb														; next high score				
				cmpb		#11											; done?
				bcs			1$											; no, loop
3$:			rts

add_hs_entry:
				ldb			*guard_ai_row						; 6809 only
				cmpb		#10											; last entry?
				beq			3$											; yes, skip
				stb			*guard_ai_row
				ldb			#9
1$:			ldy			#high_score_offset_tbl
				lda			b,y
				pshs		b												; B=score index
				tfr			a,b
				lda			#8											; 8 bytes to copy
				sta			*scanline_cnt
2$:			ldy			#hs_tbl
				lda			b,y
				ldy			#(hs_tbl+8)
				sta			b,y
				incb
				dec			*scanline_cnt
				bne			2$											; copy hs entry
				puls		b												; B=score index
				cmpb		*guard_ai_row						; done?
				beq			3$											; yes, skip
				decb
				bne			1$											; loop all entries
3$:			ldy			#high_score_offset_tbl
				lda			b,y
				stb     *byte_69                ; 6809 only
				tfr			a,b											; B=entry
				lda			#0xa0										; space
				ldy			#hs_tbl
				sta			b,y
				leay		1,y
				sta			b,y
				leay		1,y
				sta			b,y											; zap initials
				lda			*level
				leay		1,y
				sta			b,y											; set level
				lda			*score_1e6
				leay		1,y
				sta			b,y											; set millions
				lda			*score_1e5_1e4
				leay		1,y
				sta			b,y											; set hundreds, tens of thousands
				lda			*score_1e3_1e2
				leay		1,y
				sta			b,y											; set thousands, hundreds
				lda			*score_1e1_1
				leay		1,y
				sta			b,y											; set units
				ldb     *byte_69                ; 6809 only
				ldy			#high_score_offset_tbl
				lda			b,y                     ; offset into the table
				sta     *zp_de                  ; 6809 only (was self-modifying code)
				jsr			cls_and_display_high_scores
				lda			#HGR2_MSB
				sta			*display_char_page
				lda     *byte_69
        adda    #4
        sta     *row                    ; set row for initials entry
        lda     #7
        sta     *col                    ; set col for initials entry
        ldb     #0
        stb     initial_cnt
        
next_initial: ; $857F
        ldb     initial_cnt
1$:     ldy     #hs_tbl
        addb    *zp_de                  ; get offset for initial
        lda     b,y                     ; get initial
        jsr     remap_character
        jsr     blink_char_cursor_wait_key
        cmpa    #0x8d                   ; <ENTER>?
        beq     done_initials_entry     ; yes, go
        cmpa    #0x88                   ; <BS>?
        bne     add_initial             ; no, go
        lda     initial_cnt             ; 1st initial?
        beq     beep_and_loop           ; yes, exit
        dec     initial_cnt
        dec     *col
        bra     next_initial            ; loop
        
add_initial:  ; $85A3
        cmpa    #0x95                   ; right arrow?
        bne     1$                      ; no, skip
        ldb     initial_cnt
        cmpb    #2                      ; last initial?
        beq     beep_and_loop           ; yes, exit
        inc     *col
        inc     initial_cnt
        bra     next_initial
1$:     cmpa    #0xae                   ; '.'?
        beq     save_initial            ; yes, go
        cmpa    #0xa0                   ; space?
        beq     save_initial            ; yes, go
        cmpa    #0xc1                   ; alpha?
        bcs     beep_and_loop           ; no, exit
        cmpa    #0xdb                   ; alpha?
        bcc     beep_and_loop           ; no, exit

save_initial: ; $85C6
        ldy     #hs_tbl
        ldb     initial_cnt
        addb    *zp_de                  ; get offset for initial
        sta     b,y                     ; save initial
        jsr     display_character
        inc     initial_cnt
        lda     initial_cnt
        cmpa    #3                      ; done 3 initials?
        bcs     next_initial            ; no, loop
        dec     initial_cnt
        dec     *col                    ; stay on 3rd initial
        jmp     next_initial            ; loop

beep_and_loop:  ; $85E1
        ;jsr     sound        
        jmp     next_initial            ; loop
                				
done_initials_entry:  ; $85E7
				lda			#HGR1_MSB
				sta			*display_char_page
				; apple version checks disk signature here
				; * bug in Apple II version, stack grows down
				; * fix it by popping return address
				puls		x
				jmp			title_wait_for_key

blink_char_cursor_wait_key:
        sta     blink_char
1$:     lda     #104                    ; blink ON timer
        sta     *timer
        lda     blink_char
        bne     2$
        lda     #0x0a                   ; cursor character
2$:     jsr     display_char_pg2
3$:     jsr     read_ascii_key          ; 6809 only
        bne     5$                      ; key_pressed, go
        dec     *timer
        bne     3$
        lda     #0
        jsr     display_char_pg2
        lda     #104                    ; blink OFF timer
        sta     *timer
4$:     jsr     read_ascii_key          ; 6809 only
        bne     5$                      ; key_pressed, go
        dec     *timer
        bne     4$
        bra     1$        
5$:     pshs    a                       ; save key
        lda     blink_char
        jsr     display_char_pg2        ; restore screen character
        puls    a                       ; restore key
        rts

read_ascii_key: ; 6809 only
; A=key, Z=pressed/not
        ldb     #~(1<<7)
        ldx     #PIA0
1$:     stb     2,x                     ; column strobe
        lda     ,x                      ; read row
        coma                            ; active high
        anda		#0x7f										; no 8th row
        bne     2$                      ; got key, exit
        SEC
        rorb                            ; next column
        cmpb    #-1
        bne     1$                      ; loop 5 columns
        clra                            ; flag no key pressed
        rts
2$:     comb
        pshs    b                       ; save column
        ldb     #-1
3$:     incb
        lsra
        bne     3$                      ; get row count
        aslb
        aslb
        aslb                            ; B=row*8
        ldx     #ascii_key_mapping
        abx                             ; key ptr row
        puls    a                       ; restore column
        ldb     #-1
4$:     incb
        lsra
        bne     4$                      ; get row count
        lda     b,x                     ; get ascii code
        pshs    a
        jsr     keybd_flush
        puls    a
        ora     #(1<<7)                 ; convert to 'Apple' key (and set flag)
        rts        

ascii_key_mapping:
        .db     '@, 'A, 'B, 'C, 'D, 'E, 'F, 'G
        .db     'H, 'I, 'J, 'K, 'L, 'M, 'N, 'O
        .db     'P, 'Q, 'R, 'S, 'T, 'U, 'V, 'W
        .db     'X, 'Y, 'Z, 0x00, 0x00, 0x08, 0x15, ' 
        .db     '0, '1, '2, '3, '4, '5, '6, '7
        .db     '8, '9, ':, ';, ',, '_, '., '/
        .db     0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                
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

keybd_flush:	; $869F
; no such concept on the COCO3
; - so wait until no keys pressed
				ldx			#PIA0
				ldb			#0											; all columns
1$:			stb			2,x											; column strobe
				lda			,x											; active low
				coma														; active high
				bne			1$											; keys pressed, loop
				rts

wait_for_key: ; 86A8
; fudged for FREEZE fn, which only needs <ESC>
				ldx			#PIA0
				ldb			#~(1<<2)							  ; column 2
1$:			stb			2,x											; column strobe
				lda			,x											; active low
				coma														; active high
				bita    #(1<<6)                 ; <BREAK>?
				beq			1$											; no, loop
				lda     #0x9b                   ; <ESC>
				rts
        
delay_180X_scaled:  ; $86B1
; B=scale entry
        ldy     #speed_scale_tbl
        lda     b,y
        tfr     b,a                     ; B=speed entry
delay_180X: ; $86B5
.ifdef GFX_1BPP
        ldx     #650                    ; original code=#180
.else
        ldx     #575                    ; original code=#180
.endif        
1$:     dex
        bne     1$
        decb
        bne     delay_180X        
        rts

speed_scale_tbl:  ; $86BE
        .db     2, 4, 6, 8, 0xA, 0xC, 0xE, 0x10, 0x12, 0x14, 0x16, 0x18, 0x1A, 0x1C
        .db     0x1E, 0x20
												
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

throttle_and_update_sound: ; $8811
        lda     *playing_sound          ; sound playing?
        beq     loc_8832                ; no, go
; stuff        
        SEC
        rts

loc_8832: ; $8832
        lda     *not_falling            ; falling?
        bne     throttle_game_speed     ; no, go
; stuff
; - hack: remove me!!!
        bra     throttle_game_speed        
        rts

throttle_game_speed:  ; $8844                				
        ldb     *game_speed
        jsr     delay_180X_scaled
        CLC
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
; B=col
				ldx			#col_to_addr_tbl
				lda			b,x											; A=col address
				aslb
.ifdef GFX_1BPP				
				andb		#0x06										; B=shift
.else
				andb		#0x02										; B=shift
.endif				
				rts

calc_addr_shift_for_x:	; $8872
; B=x_in_2_pixel_incs
				tfr			b,a
.ifdef GFX_1BPP
				lsra
.endif				
				lsra														; A=addr
				lslb
.ifdef GFX_1BPP				
				andb		#0x06										; B=shift
.else
				andb		#0x02										; B=shift
.endif				
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
								
wipe_and_draw_level:	; $88A2
0$:     ldd     #176/2
        std     *y0
        ldd     #280/2
        std     *x0
        lda     *wipe_next_time         ; wiping or drawing?
        beq     2$                      ; drawing, skip
        ldd     #170
        std     *r
        ldb     #0
        stb     *drawing
1$:     jsr     render_wipe_circle
        dec     *(r+1)
        bne     1$                      ; do wipe
2$:     ldd     #1
        std     *r
        stb     *wipe_next_time         ; flag wipe next time
        stb     *drawing
				jsr			display_no_lives
				jsr			display_level
3$:     jsr     render_wipe_circle
        inc     *(r+1)
        lda     *(r+1)
        cmpa    #170
        bne     3$                      ; do draw
        rts        

render_wipe_circle:
        ldd     #0
        std     *y                      ; y=0
        ldd     *r
        std     *x                      ; x=radius
        negb
        coma                            ; D=-x
        addd    #1                      ; D=1-x
        std     *re                     ; radiusError = 1-x
0$:     ldd     *x
        cmpd    *y
        lblo    9$                      ; while (x >= y)

.macro	PSET		x,y
				ldd			x
				ldx			y
				jsr			pset
.endm

; plot 8 points here
				ldd			#0
				subd		*x
				std			*minus_x
				ldd			#0
				subd		*y
				std			*minus_y

				PSET		*x,*y				
				PSET		*y,*x
				PSET		*minus_x,*y
				PSET		*minus_y,*x
				PSET		*minus_x,*minus_y
				PSET		*minus_y,*minus_x
        PSET		*x,*minus_y
        PSET		*y,*minus_x
; end of plot

        inc     *(y+1)                  ; y++
        ldd     *re
        bpl     1$                      ; if (radiusError < 0)
        ldd     *y                      ; D=y
        aslb
        rola                            ; D=2*y
        addd    #1                      ; D=2*y+1
        bra     2$
1$:     ldd     *x
        subd    #1
        std     *x                      ; x--
        ldd     *y                      ; D=y
        subd    *x                      ; D=y-x
        addd    #1                      ; D=y-x+1
        aslb
        rola                            ; D=2*(y-x+1)
2$:     addd    *re                     ; radiusError += D
        std     *re
        lbra    0$
9$:     rts

pset:
; D=x, X=y
        addd    *x0											; D=x0+x
        cmpd    #280                    ; x limit?
        bcc     9$                      ; yes, exit
        exg			d,x											; D=y, X=x0+x
        addd    *y0											; D=y0+y
        cmpd    #176                    ; y limit?
        bcc     9$                      ; yes, exit
        lda     #VIDEO_BPL
        mul                             ; D=line_addr
        exg			d,x											; D=x0+x, X=line_addr
        lsra
        rorb
        lsra
        rorb                            ; B=(x0+x)/4
.ifdef GFX_1BPP
				stb			*circle_mask
        lsra
        rorb                            ; B=(x0+x)/8
.endif        
        abx															; X=pixel_addr
        lda     *drawing
        bne     2$                      ; yes, skip
.ifdef GFX_1BPP
; optimisation - assumes x0 is even
				lda			#0xf0
				ldb			*circle_mask
				bitb		#(1<<0)
				bne			1$
				lda			#0x0f
1$:			anda		,x
.else
        clra
.endif        
        bra     4$
2$:     tfr     x,d											; D=X=pg1
				eora		#(HGR1_MSB | HGR2_MSB)	; D=pg2
				tfr			d,y											; Y=pg2
.ifdef GFX_1BPP				
; optimisation - assumes x0 is even
				lda			#0xf0
				ldb			*circle_mask
				bitb		#(1<<0)
				beq			3$
				lda			#0x0f
3$:			anda		,y				
				ora			,x
.else
				lda			,y
.endif
4$:     sta     ,x                      ; plot all 4 pixels
9$:     rts

game_over_animation:	; $8B1A
        lda     #1
        sta     game_over_loop_cnt
        sta     *timer                  ; 6809 only
        lda     #HGR1_MSB
        sta     *hires_page_msb_1
1$:     jsr     game_over_frame_1_11
        jsr     game_over_frame_2_10
        jsr     game_over_frame_3_9
        jsr     game_over_frame_4_8
        jsr     game_over_frame_5_7
        jsr     game_over_frame_6
        jsr     game_over_frame_5_7
        jsr     game_over_frame_4_8
        jsr     game_over_frame_3_9
        jsr     game_over_frame_2_10
        jsr     game_over_frame_1_11
        jsr     game_over_frame_12_20
        jsr     game_over_frame_13_19
        jsr     game_over_frame_14_18
        jsr     game_over_frame_15_17
        jsr     game_over_frame_16
        jsr     game_over_frame_15_17
        jsr     game_over_frame_14_18
        jsr     game_over_frame_13_19
        jsr     game_over_frame_12_20
        lda     game_over_loop_cnt
        cmpa    #100
        bcs     1$
        jsr     game_over_frame_1_11
        jsr     game_over_frame_2_10
        jsr     game_over_frame_3_9
        jsr     game_over_frame_4_8
        jsr     game_over_frame_5_7
        jsr     game_over_frame_6
        CLC
				rts

game_over_frame_6:	; $8B7A
        jsr     render_game_over
        .db 		0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 2, 1, 0

game_over_frame_5_7:	; $8B8B
        jsr     render_game_over
        .db 		0, 0, 1, 2, 3, 4, 5, 7, 9, 0xA, 2, 1, 0, 0

game_over_frame_4_8:	; $8B9C
        jsr     render_game_over
        .db 		0, 0, 0, 1, 2, 3, 4, 9, 0xA, 2, 1, 0, 0, 0

game_over_frame_3_9:	; $8BAD
        jsr     render_game_over
        .db 		0, 0, 0, 0, 1, 2, 3, 0xA, 2, 1, 0, 0, 0, 0

game_over_frame_2_10:	; $8BBE
        jsr     render_game_over
        .db 		0, 0, 0, 0, 0, 1, 3, 0xA, 1, 0, 0, 0, 0, 0

game_over_frame_1_11:	; $8BCF
        jsr     render_game_over
        .db 		0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0

game_over_frame_16:	; $8BE0
        jsr     render_game_over
        .db 		0, 1, 2, 0xA, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

game_over_frame_15_17:	; $8BF1
        jsr     render_game_over
        .db 		0, 0, 1, 2, 0xA, 9, 7, 5, 4, 3, 2, 1, 0, 0

game_over_frame_14_18:	; $8C02
        jsr     render_game_over
        .db 		0, 0, 0, 1, 2, 0xA, 9, 4, 3, 2, 1, 0, 0, 0

game_over_frame_13_19:	; $8C13
        jsr     render_game_over
        .db 		0, 0, 0, 0, 1, 2, 0xA, 3, 2, 1, 0, 0, 0, 0

game_over_frame_12_20:	; $8C24
        jsr     render_game_over
				.db 		0, 0, 0, 0, 0, 1, 0xA, 3, 1, 0, 0, 0, 0, 0

game_over_line_data:	; 8C35
.ifdef GFX_1BPP
gol1:   .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
gol2:   .db     0x00, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55  
        .db     0x55, 0x55, 0x55, 0x55, 0x54, 0x00  
gol3:   .db     0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x01, 0x00  
gol4:   .db     0x01, 0x15, 0x45, 0x45, 0x54, 0x55, 0x01  
        .db     0x54, 0x51, 0x15, 0x45, 0x51, 0x00  
gol5:   .db     0x01, 0x10, 0x44, 0x45, 0x44, 0x50, 0x01  
        .db     0x14, 0x51, 0x14, 0x04, 0x11, 0x00  
gol6:   .db     0x01, 0x10, 0x04, 0x44, 0x44, 0x50, 0x01  
        .db     0x14, 0x51, 0x14, 0x04, 0x11, 0x00  
gol7:   .db     0x01, 0x10, 0x04, 0x44, 0x44, 0x54, 0x01  
        .db     0x04, 0x51, 0x15, 0x05, 0x51, 0x00  
gol8:   .db     0x01, 0x11, 0x45, 0x44, 0x44, 0x40, 0x01  
        .db     0x04, 0x51, 0x10, 0x05, 0x41, 0x00  
gol9:   .db     0x01, 0x10, 0x44, 0x44, 0x44, 0x40, 0x01  
        .db     0x04, 0x55, 0x10, 0x05, 0x41, 0x00  
gol10:  .db     0x01, 0x10, 0x44, 0x44, 0x44, 0x40, 0x01  
        .db     0x04, 0x54, 0x10, 0x05, 0x11, 0x00  
gol11:  .db     0x01, 0x15, 0x44, 0x44, 0x44, 0x55, 0x01  
        .db     0x54, 0x10, 0x15, 0x45, 0x11, 0x00  
.else
gol1:   .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00  
gol2:   .db     0x00, 0x00, 0x15, 0x55, 0x55, 0x55, 0x55, 0x55  
        .db     0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55  
        .db     0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x50  
        .db     0x00, 0x00  
gol3:   .db     0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
        .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01  
        .db     0x00, 0x00  
gol4:   .db     0x00, 0x01, 0x01, 0x55, 0x50, 0x15, 0x50, 0x15  
        .db     0x55, 0x50, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50  
        .db     0x15, 0x01, 0x01, 0x55, 0x50, 0x15, 0x55, 0x01  
        .db     0x00, 0x00  
gol5:   .db     0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x15  
        .db     0x50, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50  
        .db     0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01  
        .db     0x00, 0x00  
gol6:   .db     0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x15, 0x00, 0x00, 0x01, 0x01, 0x50  
        .db     0x15, 0x01, 0x01, 0x50, 0x00, 0x10, 0x01, 0x01  
        .db     0x00, 0x00  
gol7:   .db     0x00, 0x01, 0x01, 0x00, 0x00, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x15, 0x50, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x01, 0x01, 0x55, 0x00, 0x15, 0x55, 0x01  
        .db     0x00, 0x00  
gol8:   .db     0x00, 0x01, 0x01, 0x01, 0x50, 0x15, 0x50, 0x10  
        .db     0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x01, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01  
        .db     0x00, 0x00  
gol9:   .db     0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x55, 0x01, 0x00, 0x00, 0x15, 0x50, 0x01  
        .db     0x00, 0x00  
gol10:  .db     0x00, 0x01, 0x01, 0x00, 0x10, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x10, 0x00, 0x00, 0x01, 0x00, 0x10  
        .db     0x15, 0x50, 0x01, 0x00, 0x00, 0x15, 0x01, 0x01  
        .db     0x00, 0x00  
gol11:  .db     0x00, 0x01, 0x01, 0x55, 0x50, 0x10, 0x10, 0x10  
        .db     0x10, 0x10, 0x15, 0x55, 0x00, 0x01, 0x55, 0x50  
        .db     0x01, 0x00, 0x01, 0x55, 0x50, 0x15, 0x01, 0x01  
        .db     0x00, 0x00  
.endif

game_over_data_addr_tbl:	; $8CCF
				.dw			#(gol1-13*VIDEO_BPP)
				.dw			#(gol2-13*VIDEO_BPP)
				.dw			#(gol3-13*VIDEO_BPP)
				.dw			#(gol4-13*VIDEO_BPP)
				.dw			#(gol5-13*VIDEO_BPP)
				.dw			#(gol6-13*VIDEO_BPP)
				.dw			#(gol7-13*VIDEO_BPP)
				.dw			#(gol8-13*VIDEO_BPP)
				.dw			#(gol9-13*VIDEO_BPP)
				.dw			#(gol10-13*VIDEO_BPP)
				.dw			#(gol11-13*VIDEO_BPP)

render_game_over:	; $8CE5
				puls		x                       ; data address
				stx			*word_a
				ldb			#80											; scanline
				stb			*row
				bra			loc_8d12
game_over_do_scanline:
				jsr			get_line_addr_curr_page	; B=scanline
				ldy			*word_a
				lda			,y											; get graphics line #
				asla														; word offset in table for line data
				tfr			a,b											; B=offset
				ldy			#game_over_data_addr_tbl
				ldx			b,y											; X=address of line data
				ldb			#13*VIDEO_BPP						; starting byte offset
				ldy			*msb_line_addr_pg1
				leay    -2*VIDEO_BPP,y          ; fix for 8-bit video data (x=88 vs 91)
1$:			lda			b,x											; data byte
				sta			b,y											; update screen
				incb
				cmpb		#26*VIDEO_BPP						; (was 27) last column?
				bcs			1$											; no, loop
; this was after the jump on 6502 due to return address differences				
				jsr			game_over_anim_tbl_next_byte
loc_8d12:	; $8D12
				inc			*row
				ldb			*row
				cmpb		#95											; last row?
				bcs			game_over_do_scanline		; no, loop
				ldb			game_over_loop_cnt
2$:			lda			#0xff
3$:     deca
				bne			3$											; delay
				lda     #0x80
4$:			deca
				bne     4$
				decb														; done?
				bne			2$											; no, loop
				inc     game_over_loop_cnt
.ifdef PLATFORM_COCO3				
				ldx			#PIA0
				ldb			#0											; all columns
				stb			2,x											; column strobe
				lda			,x
				coma														; any key pressed?
				beq     5$                      ; no, skip
				tst     *timer                  ; seen key-up?
				bne     5$                      ; no, skip
				jsr     keybd_flush
				bra			exit_game_over_animation
5$:			sta     *timer
.endif				
				rts

exit_game_over_animation:
				puls		x												; discard return address
				SEC
				rts
				
game_over_loop_cnt: ; $8D4B
        .ds     1

game_over_anim_tbl_next_byte:	; $8D4C
				ldy			*word_a
				leay		1,y
				sty			*word_a
				rts
       
attract_move_tbl:	; $9B00
				.db 		0x16, 0x4C, 0x66, 2, 0x55, 1, 0x66, 2, 0x36, 0x18, 0x55, 1, 0x44, 1
				.db 		0x66, 0x14, 0x36, 0xD, 0x30, 0x17, 0x60, 8, 0x66, 3, 0x16, 0x16, 0x66
				.db 		4, 0x36, 0x23, 0x32, 1, 0x62, 1, 0x55, 1, 0x66, 0x20, 0x16, 7, 0x66
				.db 		2, 0x36, 0x25, 0x30, 0x14, 0x60, 0xE, 0x10, 0x11, 0x16, 0x25, 0x10, 8
				.db 		0x16, 0x23, 0x10, 6, 0x60, 2, 0x30, 0xF, 0x36, 0x17, 0x66, 2, 0x16, 7
				.db 		0x55, 1, 0x66, 0x1E, 0x16, 0x38, 0x44, 1, 0x16, 5, 0x44, 1, 0x16, 7
				.db 		0x44, 1, 0x36, 7, 0x55, 1, 0x36, 4, 0x55, 1, 0x16, 3, 0x55, 1, 0x16
				.db 		3, 0x36, 0xB, 0x55, 1, 0x16, 3, 0x36, 0xE, 0x44, 1, 0x66, 1, 0x60, 0xC
				.db 		0x30, 0x29, 0x60, 2, 0x44, 1, 0x16, 0x2B, 0x10, 4, 0x60, 5, 0x30, 1
				.db 		0x36, 0x67, 0x32, 1, 0x44, 1, 0x66, 0x2B, 0x36, 0xC, 0x30, 0x15, 0x36
				.db 		0x12, 0x55, 1, 0x16, 3, 0x55, 1, 0x36, 5, 0x55, 1, 0x16, 3, 0x36, 8
				.db 		0x66, 2, 0x16, 0x4A, 0x10, 4, 0x60, 7, 0x30, 9, 0x36, 0x15, 0x66, 0xA
				.db 		0x16, 0xD, 0x44, 1, 0x66, 2, 0x16, 4, 0x44, 1, 0x16, 2, 0x44, 6, 0x16
				.db 		4, 0x44, 1, 0x16, 2, 0x62, 0x15, 0x36, 0x31, 0x66, 1, 0x62, 4, 0x12
				.db 		6, 0x44, 1, 0x66, 0x37, 0x36, 1, 0x30, 0x1D, 0x60, 0x33, 0x36, 0x32
				.db 		0x66, 3, 0x16, 1, 0x10, 0x1B, 0x60, 5, 0x36, 0x28, 0x44, 1, 0x66, 0x1F
				.db 		0x36, 0x14, 0x44, 1, 0x55, 1, 0x66, 0x2D, 0x36, 1, 0x30, 0x12, 0x60
				.db 		0x25, 0x66, 1, 0x55, 1, 0x16, 0xD, 0x66, 2, 0x36, 9, 0x30, 0xA, 0x36
				.db 		4, 0x44, 1, 0x36, 3, 0x44, 1, 0x36, 3, 0x16, 0x22, 0x44, 1, 0x16, 7
				.db 		0x44, 4, 0x16, 3, 0x44, 1, 0x16, 0x27, 0x12, 0xE, 0x16, 0x1E, 0x55, 1
				.db 		0x66, 0x19, 0x36, 1, 0x30, 3, 0x60, 7, 0x10, 0x1F, 0x60, 7, 0x30, 9
				.db 		0x36, 0x33, 0x66, 4, 0x10, 9, 0x16, 8, 0x12, 1, 0x62, 0xC, 0x32, 1
				.db 		0x36, 0x32, 0x44, 1, 0x16, 0xB, 0x44, 1, 0x16, 9, 0x44, 1, 0x10, 0x2C
				.db 		0x60, 4, 0x30, 3, 0x36, 0xA, 0x44, 1, 0x16, 5, 0x44, 1, 0x36, 3, 0x44
				.db 		1, 0x36, 3, 0x44, 1, 0x66, 3, 0x36, 3, 0x55, 1, 0x36, 8, 0x55, 1
				.db 		0x66, 0x4C, 0x16, 9, 0x10, 0x15, 0x44, 1, 0x10, 0x2F, 0x16, 9, 0x12
				.db 		3, 0x16, 0x12, 0x66, 2, 0x36, 6, 0x66, 0x2D, 0x55, 1, 0x16, 3, 0x10
				.db 		0x1C, 0x55, 1, 0x16, 3, 0x44, 1, 0x36, 3, 0x32, 0x15, 0x36, 0xB, 0x30
				.db 		0xB, 0x60, 0xC, 0x44, 1, 0x62, 0xD, 0x12, 2, 0x16, 0xD, 0x44, 1, 0x66
				.db 		0x20, 0x36, 4, 0x30, 0x17, 0x36, 0x1E, 0x44, 1, 0x36, 0x2F, 0x30, 8
				.db 		0x60, 3, 0x10, 0x22, 0x16, 0x1B, 0x66, 0x26, 0x55, 7, 0x16, 3, 0x55
				.db 		1, 0x66, 0x1D, 0x16, 2, 0x10, 0x85, 0x60, 2, 0x30, 3, 0x36, 3, 0x32
				.db 		0xF, 0x36, 3, 0x30, 0xC, 0x36, 0x20, 0x66, 1, 0x16, 0xA, 0x60, 6, 0x66
				.db 		2, 0x36, 8, 0x30, 5, 0x60, 2, 0x66, 2, 0x16, 8, 0x10, 1, 0x60, 6
				.db 		0x66, 1, 0x36, 8, 0x30, 4, 0x60, 3, 0x66, 1, 0x16, 8, 0x10, 2, 0x60
				.db 		3, 0x30, 1, 0x36, 8, 0x30, 3, 0x60, 3, 0x16, 9, 0x10, 2, 0x60, 3
				.db 		0x30, 3, 0x36, 7, 0x30, 3, 0x60, 2, 0x10, 2, 0x16, 8, 0x10, 1, 0x60
				.db 		2, 0x30, 2, 0x36, 0xA, 0x30, 2, 0x60, 2, 0x10, 3, 0x16, 4, 0x10, 3
				.db 		0x60, 5, 0x30, 2, 0x36, 7, 0x66, 0x16, 0x36, 2, 0x66, 0x33, 0x55, 1
				.db 		0x36, 5, 0x55, 1, 0x36, 4, 0x55, 1, 0x36, 3, 0x55, 1, 0x36, 3, 0x55
				.db 		1, 0x66, 0xA9, 0x62, 0xC, 0x66, 7, 0x60, 0xF, 0x55, 1, 0x66, 0x18, 0x16
				.db 		0x2A, 0x55, 1, 0x16, 3, 0x66, 1, 0x60, 7, 0x66, 3, 0x36, 3, 0x30, 0x1B
				.db 		0x36, 8, 0x44, 1, 0x66, 0x18, 0x36, 0xF, 0x66, 8, 0x44, 1, 0x66, 0x38
				.db 		0x30, 0xE, 0x66, 0x11, 0x60, 4, 0x66, 0x49, 0x37, 3, 0, 0, 0, 0, 0
				.db 		0x30, 3, 0, 0, 0, 0, 0, 0x33, 7, 0, 0, 0, 0, 0, 0x30, 3, 0, 0
				.db 		0, 0, 0, 0x37, 3, 0, 0, 0, 0, 0, 0x30, 3, 0, 0, 0, 0, 0, 0x33
				.db 		7, 0, 0, 0, 0, 0, 0x30, 3, 0, 0, 0, 0, 0, 0x37, 3, 0, 0, 0, 0
				.db 		0, 0x30, 3, 0, 0, 0, 0, 0, 0x33, 7, 0, 0, 0, 0, 0, 0x30, 3, 0
				.db 		0, 0, 0, 0, 0x37, 3, 0, 0, 0, 0, 0, 0x30, 3, 0, 0, 0, 9, 0, 0x33
				.db 		7, 0, 0, 0, 0, 0, 0x30, 3, 0, 0x30, 0x11, 0x11, 0x11, 0x11, 0x11
				.db 		0x11, 0x11, 0x11, 3, 0, 0x30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				.db 		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				.db 		0
									
; zero-page registers
.include "zeropage.asm"

eos_ladder_col:	; $C00
				.ds		0x30
eos_ladder_row:	; $C30
				.ds		0x30
guard_col:	; $C60
				.ds		8					
guard_row:	; $C68
				.ds		8					
guard_state:	; $C70
				.ds		8					
guard_x_offset:	; $C78
				.ds		8					
guard_y_offset:	; $C80
				.ds		8					
guard_sprite:	; $C88
				.ds		8					
guard_dir:	; $C90
				.ds		8					
guard_cnt:	; $C98
				.ds		8					
hole_col:	; $CA0
				.ds		0x20
hole_row:	; $CC0
				.ds		0x20
hole_cnt:	; $CE0
				.ds		0x20

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
.ifdef GFX_1BPP
				.db			0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16
				.db			17, 18, 20, 21, 22, 23, 25, 26, 27, 28, 30, 31, 32, 33
.else
				.db			0, 2, 5, 7, 10, 12, 15, 17, 20, 22, 25, 27, 30, 32
				.db			35, 37, 40, 42, 45, 47, 50, 52, 55, 57, 60, 62, 65, 67
.endif

hs_tbl:	; $1F00
; 0-2 = initials, 3 = level, 4-7 = score (BCD)
				.db			0x4d, 0x4d, 0x43, 42, 0x00, 0x04, 0x20, 0x00
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				
				.db			0, 0, 0, 0, 0, 0, 0, 0				

; 			.nlist
; .include "tiles.asm"
; .include "title.asm"
; .include "levels.asm"

				.nlist

.ifndef TILES_EXTERNAL				
	.include "tiles.asm"
.endif

.ifdef HAS_TITLE
	.ifndef TITLE_EXTERNAL
		.include "title.asm"
	.endif
.endif

.include "levels.asm"

				.list

end_of_data	.equ		.

; this was in low memory on the apple

level_data_packed:
				.ds		256
				
				.bndry	512
level_data_unpacked_1:
ldu1:
				.ds			512
level_data_unpacked_2:
ldu2:
				.ds			512
				
				.end		start
			