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
.export dvg_cur
.export dvg_scalebrightness
.export dvg_halt
.export dvg_invalid

; for debugging
.export apple_render_frame
.export erase_loop
.export read_joystick
.export read_btns

; build options
; comment-out to disable (not =0)

apple_reset:
				HINT_IIMODE
				
; stay on the splash screen until key hit
				sta			KBDSTRB
				ldy			#0
:				lda			msg,y									; get msg char
				beq			waitkey								; zero - done
				ora			#$80									; convert to Apple code
				;sta			$6D0,y								; display
				sta			$7D0,y								; display
				iny														; next char
				bne			:-										; always
waitkey:		
				lda			KBD
				bpl			waitkey								; no key, loop
				sta			KBDSTRB
				and			#$7F									; scan code
;
				lda     SPEED
				ora     #(1<<7)               ; turbo
				sta     SPEED
				lda			#$02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				sei
				rts

msg:		.asciiz "       - PRESS ANY KEY TO PLAY -        "

apple_start:
				HINT_IIMODE
				; switch into superhires mode (from 8-bit mode)
				lda			NEWVIDEO
				ora			#(1<<7)|(1<<6)				; SHR, linear
				and			#~(1<<5)+256					; colour
				sta			NEWVIDEO
				; black border
				lda			TXTBDR
				and			#$F0
				sta			TXTBDR
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
				;lda			#(OP_HALT<<8)|OP_HALT
				;sta			DVGRAM+$0400

; clear the SHR screen				
				ldx			#$7D00
				lda			#$0
:				sta			$012000,x							; 5 cycles
				dex														; 2 cycles
				dex														; 2 cycles
				bpl			:-										; 2 cycles = 11 cycles/word (faster)
				
				sei														; disable interrupts

				; disable shadowing
				sep			#$20
				.A8
				lda			SHADOW
;				ora			#(1<<3)
				ora			#$1E
				sta			SHADOW
				rep			#$20				
				.A16

				IIMODE
				rts

shr_y_offs_tbl:
.repeat	192, I
				.word		160*I 
.endrepeat

; scale current (10 bits X,Y) for SHR (256x192)
; and calc SHR address
; exit: $04/$05=X, $06/$07=Y, $08/$09=global scale, $C0,$C1=Y*160, $C2,$C3=y*160+X/2
; $0
dvg_cur:
				HINT_IIGSMODE
				; fortunately bits 11,10 are 00!
				; scale Y
				lda			(byte_B)							; CUR Y (0-1023) (10 bits)
				lsr
				clc
				adc			(byte_B)							; Y+Y/2 (11 bits)
				inc			byte_B
				inc			byte_B
				lsr
				lsr
				lsr														
				and			#$00FF								; mask off opcode bits
				sta			byte_6								; CUR Y (0-191) (8 bits)
				lda			#191
				sec														; no carry on subtract
				sbc			byte_6
				sta			byte_6								; store non-inverted Y
				; find address of line
				asl														; y*2 (offset)
				tax
				ldy			shr_y_offs_tbl,x
				sty			$C0
				; scale X
				lda			(byte_B)							; global scale
				xba
				lsr
				lsr
				lsr
				lsr
				and			#$000F								; mask off X bits
				sta			byte_8
				lda			(byte_B)							; CUR X (0-1023)
				inc			byte_B
				inc			byte_B
				lsr
				lsr
				and			#$00FF								; mask off global scale
				sta			byte_4								; CUR X (0-255)
				; find address of CUR (y*160+x/2)
				lsr
				clc
				adc			$C0
				sta			$C2										; should never generate carry!
				rts

; $A-$D
dvg_invalid:
        OP_EXIT

; $E
dvg_scalebrightness:
				OP_EXIT
        
; $F
dvg_halt:
				inc			byte_B
				inc			byte_B
				sec														; flag halt
				rts

old_dp:	.word		0
old_sp:	.word		0

apple_render_frame:
				IIGSMODE
				
				; disable shadowing
				sep			#$20
				.A8
				lda			SHADOW
				;ora			#(1<<3)
				ora			#$1E
				sta			SHADOW
				rep			#$20				
				.A16
				
				lda			dvg_curr_addr_lsb
				and			#DVGRAM|$0400
				eor			#$0400
				ora			#$0002
				sta			byte_B
erase_loop:				
				lda			(byte_B)
				jsr			handle_erase_opcode		; handle it
				bcc			erase_loop
;
				lda			dvg_curr_addr_lsb
				and			#DVGRAM|$0400
				ora			#$0002
				sta			byte_B
render_loop:
				lda			(byte_B)
				jsr			handle_dvg_opcode			; handle it
				bcc			render_loop

				; enable shadowing
				sep			#$20
				.A8
				lda			SHADOW
				and			#~(1<<3)+256					; enable for SHR (only)
				sta			SHADOW
				rep			#$20				
				.A16

				; save sp, dp				
				tdc
				sta			old_dp
				tsc
				sta			old_sp

				; and restore sp, dp				
				lda			old_sp
				tcs
				lda			old_dp
				tcd
				
; rewrite the SHR screen				
				ldx			#$7D00
:				lda			$012000,x
				sta			$012000,x							; 5 cycles
				dex														; 2 cycles
				dex														; 2 cycles
				bpl			:-										; 2 cycles = 11 cycles/word (faster)

				IIMODE
				
				; read some inputs now
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
	