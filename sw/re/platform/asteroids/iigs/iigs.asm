.include "apple2.inc"

; for debugging
.export dvg_cur
.export dvg_chr
.export dvg_copyright
.export dvg_asteroid
.export dvg_halt
.export cur_2_shr
.export apple_render_frame
.export read_joystick
.export read_btns

; bitmaps.asm
.import chr_tbl
.import copyright
.import extra_ship
.import ship_tbl
.import shifted_ship_tbl
.import asteroid_tbl
.import shifted_asteroid_tbl
.import large_saucer
.import shifted_large_saucer
.import small_saucer
.import shifted_small_saucer
.import shrapnel_tbl
.import shifted_shrapnel_tbl

; build options
; comment-out to disable (not =0)
;BUILD_OPT_RENDER_CLS = 1

apple_reset:
				.A8
				.I8
				lda     SPEED
				ora     #(1<<7)               ; turbo
				sta     SPEED
				lda			#$02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				rts

apple_start:
				.A8
				.I8
				; switch into superhires mode (from 8-bit mode)
				lda			NEWVIDEO
				ora			#(1<<7)|(1<<6)				; SHR, linear
				and			#~(1<<5)+256					; colour
				sta			NEWVIDEO
				; enable shadowing
				lda			SHADOW
				ora			#~(1<<3)+256					; enable for SHR (only)
;				sta			SHADOW
				; init the palette
				IIGSMODE
				ldx     #0
				lda			#$000									; R=G=B=0 (black)
:				sta			$019e00,x							; palette=0
        clc
        adc     #$111
				inx
				inx
				cpx     #(16*2)
				bne     :-
				; init SCBs
				ldx			#200-1								; 200 lines
				lda			#$0000                ; palette=0
:				sta			$019D00,x
				dex
				dex
				bpl			:-				
				; init other display list
				lda			#(OP_HALT<<8)|OP_HALT
				sta			$4400
				IIMODE
				rts

; scale current (10 bits X,Y) for SHR (256x192)
; and calc SHR address
; entry: $04/$05=X, $06/$07=Y
; exit: $09/$0A=X,Y   $C0,$C1=Y*160   $C2,$C3=y*160+X/2
cur_2_shr:
				; scale X
				IIGSMODE
				lda			$04										; CUR X (0-1023)
				lsr
				lsr
				IIMODE
				sta			$09										; CUR X (0-255)
				; scale Y
				IIGSMODE
				lda			$06										; CUR Y (0-1023) (10 bits)
				lsr
				clc
				adc			$06										; Y+Y/2 (11 bits)
				lsr
				lsr
				lsr														; CUR Y (0-191) (8 bits)
				IIMODE
				sta			$0A
				lda			#191
				clc
				sbc			$0A
				sta			$0A										; store non-inverted Y
				; find address (y*160+x/2) 160=128+32
				lsr
				sta			$C1										; msb (x128)
				sta			$C3										; msb (x128)
				ror
				and			#(1<<7)
				sta			$C0										; lsb (x128)
				sta			$C2										; lsb (x128)
				lda			$C3
				lsr
				ror			$C2
				lsr
				ror			$C2										; lsb (x32)
				sta			$C3										; msb (x32)
				clc
				lda			$C0
				adc			$C2
				sta			$C0										; lsb (x160)
				lda			$C1
				adc			$C3
				sta			$C1										; msb (x160)
				lda			$09
				lsr														; X/2
				clc
				adc			$C0
				sta			$C2										; lsb (address)
				lda			$C1
				adc			#$00
				sta			$C3										; msb (address)
				rts

upd_ptr:
				clc
				adc			byte_B
				sta			byte_B
				bcc			:+
				inc			byte_C
:				rts				

.macro OP_EXIT
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts
.endmacro

; $0
dvg_cur:
				lda			(byte_B),y						; Y (lsb)
				sta			$06
				iny
				lda			(byte_B),y						; Y (msb)
				and			#$03									; 2 bits only
				sta			$07
				iny
				lda			(byte_B),y						; X (lsb)
				sta			$04
				iny
				lda			(byte_B),y						; X (msb)
				and			#$03									; 2 bits only
				sta			$05
				lda			(byte_B),y						; global scale
				lsr
				lsr
				lsr
				lsr														; to low nibble
				sta			$08
				jsr			cur_2_shr							; map to pixel coordinates
				lda			#4										; 4 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts

; $1
dvg_chr:
        lda     (byte_B),y            ; chr x2
				IIGSMODE
				and			#$00FF
				tax
				ldy			chr_tbl,x
render_7x2:				
				lda			#7										; 7 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda			0,y
        beq     :+
				ora			SHRMEM,x
				sta			SHRMEM,x							; 1st half of line
:				lda			2,y
        beq     :+
				ora			SHRMEM+2,x
				sta			SHRMEM+2,x						; 2nd half of line
:				iny
				iny
				iny
				iny
				clc
				txa
				adc			#160									; ptr next line
				tax
				dec			$C4										; line counter
				bne			:---
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				IIMODE
				OP_EXIT

; $2
dvg_life:
				IIGSMODE
				; offset Y because it overwrites score
				lda			$C2										; SHR offset
				cmp			#($1360+160)
				bcs			:+
				clc
				adc			#(160*4)
				sta			$C2										; new SHR offset
:				ldy			#extra_ship
				jmp     render_7x2
				HINT_IIMODE

; $3
dvg_copyright:
				; CUR SSS=0,(400,128)
.if 0				
				lda			#<128
				sta			$06
				lda			#>128
				sta			$07
				lda			#<400
				sta			$04
				lda			#>400
				sta			$05
				lda			#00
				sta			$08		
				jsr			cur_2_shr
.endif				
				IIGSMODE
				ldy			#copyright
;				ldx			$C2										; SHR offset ($6F72)
				ldx			#$6F72
				lda			#5										; 5 lines
				sta			$C4
:				lda			#15										; 15 words/line
				sta			$C6
:				lda			0,y
				ora			SHRMEM,x
				sta			SHRMEM,x
				iny
				iny														; pixel data
				inx
				inx														; screen ptr
				dec			$C6										; done line?
				bne			:-										; no, loop
				txa
				clc
				adc			#(160-30)							; ptr next line
				tax
				dec			$C4										; done all lines?
				bne			:--										; no, loop
				IIMODE
				OP_EXIT

; $4
; $00(2:1)=shape(0-3)
dvg_asteroid:
        lda     (byte_B),y
				IIGSMODE
				sta			$C6
				asl														; pattern x4
				clc
				adc			$C6										; =pattern x6
				and			#$00FF
				tax
				lda			$08										; global scale
				and			#$00FF
				beq			:+										; large? yes, go
				inx
				inx
				cmp			#$0F									; medium?
				beq			:+										; yes, go
				inx
				inx														; small
:				ldy			asteroid_tbl,x
				lda			$09										; X (0-255)
				bit			#1
				beq			render_16x4
				ldy			shifted_asteroid_tbl,x
render_16x4:
				lda			#16										; 16 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda			0,y
        ;beq     :+
				ora			SHRMEM,x
				sta			SHRMEM,x							; 1st qtr of line
:				lda			2,y
        ;beq     :+
				ora			SHRMEM+2,x
				sta			SHRMEM+2,x							; 2nd qtr of line
:				lda			4,y
        ;beq     :+
				ora			SHRMEM+4,x
				sta			SHRMEM+4,x							; 3rd qtr of line
:				lda			6,y
        ;beq     :+
				ora			SHRMEM+6,x
				sta			SHRMEM+6,x							; 4th qtr of line
:				lda			8,y
        ;beq     :+
				ora			SHRMEM+8,x
				sta			SHRMEM+8,x							; 5th qtr of line
:				tya
				clc
				adc			#10
				tay
				clc
				txa
				adc			#160									; ptr next line
				tax
				dec			$C4										; line counter
				bne			:------
				; update CUR
				lda			$C2
				clc
				adc			#8
				sta			$C2
				IIMODE
				OP_EXIT
                        
; $5
; $00=dir(0-255)
dvg_ship:
				IIGSMODE
				lda			(byte_B),y            ; direction
				xba														; high byte for more resolution
				and			#$ff00
				lsr
				lsr
				lsr
				lsr														; dir/16
				sta			$D0
				lsr														; dir/8
				clc
				adc			$D0										; dir/16+dir/8 = dir/24
				xba														; back to low byte
				and			#$00ff								; mask off high-res bits
				asl														; word offset
				tax
				ldy			ship_tbl,x
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			shifted_ship_tbl,x
:				jmp			render_7x2
				HINT_IIMODE

; $6
; $00=
dvg_saucer:
				IIGSMODE
				lda			(byte_B),y						; status
; fixme								
				ldy			#large_saucer
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			#shifted_large_saucer
:				jmp			render_16x4
				HINT_IIMODE

; $7
dvg_shot:
				IIGSMODE
				ldx			$C2										; SHR offset
				lda			$09										; X (0-255)
				bit			#1
				bne			:+
				lda			#$F000
				bne			:++
:				lda			#$0F00
:				ora			SHRMEM,x
				sta			SHRMEM,x
				IIMODE
				OP_EXIT
        
; $8
dvg_shrapnel:
				; the original uses 6 global scale factors from $B-$0
				; and 4 patterns in this sequence
				; $B:2,6 $C:0,4,6 $D,$E,$F,$0:0,2,4,6
				; instead we'll just use global scale factor
				; $B=0, $C=1, $D,$E=2, $F,$0=3
				IIGSMODE
				lda			$08										; global scale
				and			#$00FF
				bne			:+
				lda			#$0010
:				clc
				sbc			#$0B									; -> 0-5
				asl														; word offset into table
				tax
				ldy			shrapnel_tbl,x
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			shifted_shrapnel_tbl,x
:				jmp			render_16x4
				HINT_IIMODE
        
; $9
dvg_explodingship:
				OP_EXIT

; $A-$D
dvg_invalid:
        OP_EXIT

; $E
dvg_scalebrightness:
				OP_EXIT
        
; $F
dvg_halt:
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				sec														; flag halt
				rts

dvg_jmp_tbl:
				.word		dvg_cur-1
				.word		dvg_chr-1
				.word		dvg_life-1
				.word		dvg_copyright-1
				.word		dvg_asteroid-1
				.word		dvg_ship-1
				.word		dvg_saucer-1
				.word		dvg_shot-1
				.word		dvg_shrapnel-1
				.word		dvg_explodingship-1
				.word		dvg_invalid-1
				.word		dvg_invalid-1
				.word		dvg_invalid-1
				.word		dvg_invalid-1
				.word		dvg_scalebrightness-1
				.word		dvg_halt-1

handle_dvg_opcode:
				and			#$F0									; opcode in high nibble
				lsr
				lsr
				lsr														; offset in jump table
				tax
				lda			dvg_jmp_tbl+1,x
				pha
				lda			dvg_jmp_tbl,x
				pha
				rts

erase_chr:
erase_7x2:				
				IIGSMODE
				lda			#7										; 7 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda     #0
				sta			SHRMEM,x							; 1st half of line
				sta			SHRMEM+2,x						; 2nd half of line
				clc
				txa
				adc			#160									; ptr next line
				tax
				dec			$C4										; line counter
				bne			:-
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				IIMODE
				OP_EXIT

erase_life:
				IIGSMODE
				; offset Y because it overwrites score
				lda			$C2										; SHR offset
				cmp			#($1360+160)
				bcs			:+
				clc
				adc			#(160*4)
				sta			$C2										; new SHR offset
				ldy			#extra_ship
:				jmp     erase_7x2
				HINT_IIMODE

erase_asteroid:
erase_16x4:
				IIGSMODE
				lda			#16										; 16 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda			#0
				sta			SHRMEM,x							; 1st qtr of line
				sta			SHRMEM+2,x							; 2nd qtr of line
				sta			SHRMEM+4,x							; 3rd qtr of line
				sta			SHRMEM+6,x							; 4th qtr of line
				sta			SHRMEM+8,x							; 5th qtr of line
				clc
				txa
				adc			#160									; ptr next line
				tax
				dec			$C4										; line counter
				bne			:-
				; update CUR
				lda			$C2
				clc
				adc			#8
				sta			$C2
				IIMODE
				OP_EXIT

erase_ship:
        jmp     erase_7x2

erase_saucer:
        jmp     erase_16x4

erase_shot:
				IIGSMODE
				ldx			$C2										; SHR offset
				lda			#0
				sta			SHRMEM,x
				IIMODE
				OP_EXIT

erase_shrapnel:
				jmp     erase_16x4

erase_explodingship:
        OP_EXIT
                        
erase_invalid:
        OP_EXIT
        
erase_jmp_tbl:
				.word		dvg_cur-1
				.word		erase_chr-1
				.word		erase_life-1
				.word		erase_invalid-1
				.word		erase_asteroid-1
				.word		erase_ship-1
				.word		erase_saucer-1
				.word		erase_shot-1
				.word		erase_shrapnel-1
				.word		erase_explodingship-1
				.word		erase_invalid-1
				.word		erase_invalid-1
				.word		erase_invalid-1
				.word		erase_invalid-1
				.word		dvg_scalebrightness-1
				.word		dvg_halt-1
				rts

handle_erase_opcode:
				and			#$F0									; opcode in high nibble
				lsr
				lsr
				lsr														; offset in jump table
				tax
				lda			erase_jmp_tbl+1,x
				pha
				lda			erase_jmp_tbl,x
				pha
        rts
        
apple_render_frame:
;				cls
				IIGSMODE
.ifdef BUILD_OPT_RENDER_CLS
	.if 0
				phb
				lda			#$0000
				ldx			#$2000
				sta			$010000,x
				ldy			#$2001
				lda			#$77FF
				mvn			$01,$01								; 7 cycles/byte
				plb
	.else				
				ldx			#$7800
				lda			#$0
:				sta			SHRMEM,x							; 5 cycles
				dex														; 2 cycles
				dex														; 2 cycles
				bpl			:-										; 2 cycles = 11 cycles/word (faster)
	.endif	
.endif ; BUILD_OPT_RENDER_CLS			
;
				IIMODE
				lda			#2
				sta			byte_B
				lda			dvg_curr_addr_msb
				eor     #$04
				sta			byte_C
erase_loop:				
				ldy			#1										; 2nd byte has the opcode
				lda			(byte_B),y						; opcode (high nibble)
				dey														; reset to 1st byte
				jsr			handle_erase_opcode		; handle it
				bcc			erase_loop
;
				lda			#2
				sta			byte_B
				lda			dvg_curr_addr_msb
				sta			byte_C
render_loop:
				ldy			#1										; 2nd byte has the opcode
				lda			(byte_B),y						; opcode (high nibble)
				dey														; reset to 1st byte
				jsr			handle_dvg_opcode			; handle it
				bcc			render_loop

				; fudge some inputs now
				
				lda			#0
				sta			hyperspaceSwitch
				sta			FireSwitch
				sta			p1StartSwitch
				sta     thrustSwitch
				sta			rotateRightSwitch
				sta			rotateLeftSwitch
	
				lda     SPEED
				and     #~(1<<7)+256            ; slow
				sta     SPEED

read_joystick:	
	      lda     #0
	      sta     $e0
	      sta     $e1
	      lda     PTRIG
:       ldx     #1
:       lda     PADDL0,x
        bpl     :++
        inc     $e0,x
:       dex
        bpl     :--
        lda     PADDL0
        ora     PADDL1
        bpl     :++
        lda     $e0
        ora     $e1
        bpl     :---
:       nop
        bpl     :--
:       
        lda     #(1<<7)
        ldy     $e0                     ; X
chk_left:
        cpy     #$12                    ; left?
        bcs     chk_right               ; no, skip
        sta     rotateLeftSwitch
        bne     chk_up
chk_right:
        cpy     #$30                    ; right?
	      bcc     chk_up                  ; no, skip
	      sta     rotateRightSwitch
chk_up:
        ldy     $e1                     ; Y
        cpy     #$12                    ; up?
        bcs     read_btns               ; no, skip
        sta     thrustSwitch
read_btns:        
        lda     PB0
        bpl     :+                      ; no, skip
        sta     FireSwitch
:

				lda     SPEED
				ora     #(1<<7)               ; fast
				sta     SPEED
	      					
				lda			KBD
				bpl			kbd_exit							; no key, exit
				; got a key
				sta			KBDSTRB
				and			#$7F									; scan code
				cmp			#$31									; '1'?
				bne			:+
				lda			#(1<<7)
				sta			p1StartSwitch
				bne			kbd_exit
:				cmp			#$35									; '5'?
				bne			:+
				inc			CurrNumCredits
				bne			kbd_exit
:       cmp     #$20                  ; <SPACE>
        bne     :+
        lda     #(1<<7)
        sta     hyperspaceSwitch
        bne     kbd_exit				
:				cmp			#$46									; 'F'?
				bne			:++
:				lda			KBD
				bpl			:-										; no key, loop
				sta			KBDSTRB
:				
kbd_exit:				
				rts
	