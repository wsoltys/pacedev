.include "apple2.inc"

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

; render.asm
.import handle_dvg_opcode

; erase/render.asm
.import handle_erase_opcode
.export upd_ptr
.export dvg_cur
.export dvg_scalebrightness
.export dvg_halt
.export dvg_invalid

; for debugging
.export cur_2_shr
.export apple_render_frame
.export read_joystick
.export read_btns

; build options
; comment-out to disable (not =0)
;BUILD_OPT_RENDER_CLS = 1

apple_reset:
				HINT_IIMODE
				lda     SPEED
				ora     #(1<<7)               ; turbo
				sta     SPEED
				lda			#$02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				rts

apple_start:
				HINT_IIMODE
				; switch into superhires mode (from 8-bit mode)
				lda			NEWVIDEO
				ora			#(1<<7)|(1<<6)				; SHR, linear
				and			#~(1<<5)+256					; colour
				sta			NEWVIDEO
				; enable shadowing
				lda			SHADOW
				and			#~(1<<3)+256					; enable for SHR (only)
				sta			SHADOW
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
				sta			DVGRAM+$0400
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

; $0
dvg_cur:
        IIMODE
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

; $A-$D
dvg_invalid:
        OP_EXIT

; $E
dvg_scalebrightness:
				OP_EXIT
        
; $F
dvg_halt:
        IIMODE
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				sec														; flag halt
				rts

apple_render_frame:
        HINT_IIMODE
.ifdef BUILD_OPT_RENDER_CLS
;				cls
	.if 0
				IIGSMODE
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
				IIMODE
.endif ; BUILD_OPT_RENDER_CLS			
;
				IIGSMODE
				lda			dvg_curr_addr_lsb
				and			#DVGRAM|$0400
				eor			#$0400
				ora			#$0002
				sta			byte_B
				IIMODE
erase_loop:				
				ldy			#1										; 2nd byte has the opcode
				lda			(byte_B),y						; opcode (high nibble)
				dey														; reset to 1st byte
				jsr			handle_erase_opcode		; handle it
				bcc			erase_loop
;
				IIGSMODE
				lda			dvg_curr_addr_lsb
				and			#DVGRAM|$0400
				ora			#$0002
				sta			byte_B
				IIMODE
render_loop:
				ldy			#1										; 2nd byte has the opcode
				lda			(byte_B),y						; opcode (high nibble)
				dey														; reset to 1st byte
				jsr			handle_dvg_opcode			; handle it
				bcc			render_loop

				; fudge some inputs now
	
	inputs:			
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
:				lda			PB1
				bpl			:+											; no, skip
				sta			hyperspaceSwitch
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
	