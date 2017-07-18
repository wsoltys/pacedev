.include "apple2.inc"

; for debugging
.export dvg_vec
.export chk_shrapnel
.export chk_extra_ship
.export print_copyright
.export cur_2_shr
.export print_chr
.export apple_render_frame

.import chr_tbl
.import ship_tbl
.import extra_ship
.import large_ufo
.import small_ufo
.import shrapnel_tbl
.import asteroid_tbl
.import copyright

; build options
; comment-out to disable (not =0)
BUILD_OPT_RENDER_CLS = 1

apple_reset:
				.A8
				.I8
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
				ora			#!(1<<3)+256					; enable for SHR (only)
				sta			SHADOW
				; init the palette
				IIGSMODE
				lda			#$000									; black
				sta			$019e00								; palette=0, colour=0
				lda			#$fff									; white
				sta			$019e02								; palette=0, colour=1
				; init SCBs
				ldx			#200-1								; 200 lines
				lda			#$0000
:				sta			$019D00,x
				dex
				dex
				bpl			:-				
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

; print A=chr at CUR (offset $C3$C2)
print_chr:
				IIGSMODE
;				asl														; word offset
				and			#$00FF
				tax
				ldy			chr_tbl,x
render_7x2:				
				lda			#7										; 7 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda			0,y
				ora			SHRMEM,x
				sta			SHRMEM,x							; 1st half of line
				lda			2,y
				ora			SHRMEM+2,x
				sta			SHRMEM+2,x						; 2nd half of line
				iny
				iny
				iny
				iny
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
;				inc			$C2										; not what Norbert does!?!
				IIMODE
				rts

; X=pattern word offset
print_asteroid:
				IIGSMODE
				txa														; pattern x2
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
render_16x4:
				lda			#16										; 16 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda			0,y
				ora			SHRMEM,x
				sta			SHRMEM,x							; 1st qtr of line
				lda			2,y
				ora			SHRMEM+2,x
				sta			SHRMEM+2,x							; 2nd qtr of line
				lda			4,y
				ora			SHRMEM+4,x
				sta			SHRMEM+4,x							; 3rd qtr of line
				lda			6,y
				ora			SHRMEM+6,x
				sta			SHRMEM+6,x							; 4th qtr of line
				tya
				clc
				adc			#8
				tay
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
				rts
																				
upd_ptr:
				clc
				adc			byte_B
				sta			byte_B
				bcc			:+
				inc			byte_C
:				rts				

print_copyright:
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
				lda			#0										; so we can BNE
				rts

; $0-$9
dvg_vec:
				iny
				lda			(byte_B),y
				cmp			#$70
				bne			:+
				iny
				iny
				lda			(byte_B),y
				cmp			#$F0
				bne			:+
				; shot!?!
				IIGSMODE
				ldx			$C2										; SHR offset
				lda			SHRMEM,x
				ora			#$0100								; arbitrary pixel
				sta			SHRMEM,x
				IIMODE
:				lda			#4										; 4 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts
				
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
        lda     (byte_B),y
				jmp			jsr_print
        rts
        
; $F
dvg_halt:
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				sec														; flag halt
				rts

; $C
dvg_jsr:
chk_char:
				; try matching against character routine
				ldx			#$00									; char index (x2)
cl:			lda			$56D4,x								; $5000-$800+$ED4
				cmp			(byte_B),y
				bne			no_lo
				iny
				lda			$56D5,x
				cmp			(byte_B),y
				bne			no_hi
				; found a character
				txa
				lsr														; char index
				jmp			jsr_print
no_hi:	dey
no_lo:	inx
				inx
				cpx			#(37*2)
				bne			cl
chk_asteroid:				
				; check for asteroid
				ldx			#$00
al:			lda			$51DE,x								; $5000-$800+$9DE
				cmp			(byte_B),y
				bne			:++
				iny
				lda			$51DF,x
				cmp			(byte_B),y
				bne			:+
				; found an asteroid
				jsr			print_asteroid
				jmp			jsr_exit
:				dey
:				inx
				inx
				cpx			#(4*2)
				bne			al
chk_shrapnel:
				; check for shrapnel
				ldx			#$00
sl:			lda			$50F8,x								; $5000-$800+$8F8
				cmp			(byte_B),y
				bne			:+++
				iny
				lda			$50F9,x
				cmp			(byte_B),y
				bne			:++
				; found shrapnel
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
				jsr			render_16x4
				HINT_IIMODE
				jmp			jsr_exit
:				dey
:				inx
				inx
				cpx			#(4*2)
				bne			sl
chk_ufo:
				; check for UFO
				lda			#$29
				cmp			(byte_B),y
				bne			:++
				iny
				lda			#$C9
				cmp			(byte_B),y
				bne			:+
				; found a UFO
				IIGSMODE
				ldy			#large_ufo
				jsr			render_16x4
				HINT_IIMODE
				jmp			jsr_exit
:				dey
:
chk_copyright:
				; check for copyright message
				lda			#$52
				cmp			(byte_B),y
				bne			:++
				iny
				lda			#$C8
				cmp			(byte_B),y
				bne			:+
				; found copyright
				jsr			print_copyright
				bne			jsr_exit
:				dey
:
chk_extra_ship:
				; check for extra ships display
				lda			#$6D
				cmp			(byte_B),y
				bne			:+++
				iny
				lda			#$CA
				cmp			(byte_B),y
				bne			:++
				; found extra ship
				IIGSMODE
				; offset Y because it overwrites score
				lda			$C2										; SHR offset
				cmp			#($1360+160)
				bcs			:+
				clc
				adc			#(160*4)
				sta			$C2										; new SHR offset
:				ldy			#extra_ship
				jsr			render_7x2
				HINT_IIMODE
				jmp			jsr_exit
:				dey
:
chk_null:
				lda			#0
				beq			jsr_exit							; (always)
jsr_print:
				jsr			print_chr
jsr_exit:				
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts

; $D
dvg_rts:
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts

; $E
dvg_jmp:
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts

; $F
dvg_svec:
				lda			#2										; 2 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts

dvg_jmp_tbl:
				.word		dvg_cur-1
				.word		dvg_chr-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
				.word		dvg_rts-1
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
				IIMODE
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

				; now we (always) render the ship
				IIGSMODE
				lda			direction							; 0-256
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
				jsr			render_7x2
				HINT_IIMODE			

				; fudge some inputs now
				
				lda			#0
				sta			hyperspaceSwitch
				sta			FireSwitch
				sta			p1StartSwitch
				sta			rotateRightSwitch
				sta			rotateLeftSwitch
												
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
:				cmp			#$20									; <space>?
				bne			:+
				lda			#(1<<7)								; fire bit
				sta			FireSwitch
				bne			kbd_exit
:				cmp			#$2E									; '.'				
				bne			:+
				lda			#(1<<7)
				sta			rotateRightSwitch
				bne			kbd_exit
:				cmp			#$2C									; ','
				bne			:+
				lda			#(1<<7)
				sta			rotateLeftSwitch
				bne			kbd_exit
:				cmp			#$46									; 'F'?
				bne			:++
:				lda			KBD
				bpl			:-										; no key, loop
				sta			KBDSTRB
:				
kbd_exit:				
				rts
	