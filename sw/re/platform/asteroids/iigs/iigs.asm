.include "apple2.inc"

; for debugging
.export cur_2_shr
.export print_chr
.export apple_render_frame

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
; entry: $09/$0A=X,Y
; exit: $C0,$C1=Y*160   $C2,$C3=y*160+X/2
cur_2_shr:
				; scale X
				lda			$04										; CUR X (lsb)
				sta			$09
				lda			$05										; CUR X (msb)
				lsr
				ror			$09
				lsr
				ror			$09										; CUR X (0-255)
				; scale Y
				lda			$06										; CUR Y (lsb)
				sta			$0A
				lda			$07										; CUR Y (msb)
				lsr
				ror			$0A
				lsr
				ror			$0A
				lsr
				ror			$0A										; 7 bits (0-127)
				lda			$0A
				lsr														; (0-64)
				clc
				adc			$0A										; (0-128)+(0-64)=(0-192)
				sta			$0A
				; find address (y*160+x/2) 160=128+32
				lda			#191
				clc
				sbc			$0A										; Y (inverted)
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
				asl														; word offset
				and			#$00FF
				tax
				ldy			chr_tbl,x
render_7x2:				
				lda			#7										; 7 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda			0,y
				sta			$012000,x							; 1st half of line
				lda			2,y
				sta			$012002,x							; 2nd half of line
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
				inc			$C2
				IIMODE
				rts
																
upd_ptr:
				clc
				adc			byte_B
				sta			byte_B
				bcc			:+
				inc			byte_C
:				rts				

copyright:
				; CUR SSS=0,(400,128)
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
				lda			#$0D									; 'C'
				jsr			print_chr
				lda			#$02									; '1'
				jsr			print_chr
				lda			#$0A									; '9'
				jsr			print_chr
				lda			#$08									; '7'
				jsr			print_chr
				lda			#$0A									; '9'
				jsr			print_chr
				lda			#$00									; space
				jsr			print_chr
				lda			#$0B									; 'A'
				jsr			print_chr
				lda			#$1E									; 'T'
				jsr			print_chr
				lda			#$0B									; 'A'
				jsr			print_chr
				lda			#$1C									; 'R'
				jsr			print_chr
				lda			#$13									; 'I'
				jsr			print_chr
				lda			#0										; so we can BNE
				rts

; $0-$9
dvg_vec:
				lda			#4										; 4 bytes in instruction
				jsr 		upd_ptr
				clc														; no halt
				rts
				
; $A				
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

; $B
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
				lda			#$A3									; '#'
				ldx			$08										; global scale
				beq			jsr_print							; large
				lda			#$AA									; '*'
				cpx			#$0f
				beq			jsr_print							; medium
				lda			#$AB									; '+'
				bne			jsr_print							; (always)
:				dey
:				inx
				inx
				cpx			#(4*2)
				bne			al
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
				lda			#$80									; '@'
				bne			jsr_print							; (always)
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
				jsr			copyright
				bne			jsr_exit
:				dey
:
chk_extra_ship:
				; check for extra ships display
				lda			#$6D
				cmp			(byte_B),y
				bne			:++
				iny
				lda			#$CA
				cmp			(byte_B),y
				bne			:+
				; found extra ship
				IIGSMODE
				ldy			#extra_ship
				jsr			render_7x2
				IIMODE
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
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_vec-1
				.word		dvg_cur-1
				.word		dvg_halt-1
				.word		dvg_jsr-1
				.word		dvg_rts-1
				.word		dvg_jmp-1
				.word		dvg_svec-1

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
:				sta			$012000,x							; 5 cycles
				dex														; 2 cycles
				dex														; 2 cycles
				bpl			:-										; 2 cycles = 11 cycles/word (faster)
.endif				
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

				; fudge some inputs now
				
				lda			#0
				sta			p1StartSwitch
				
				lda			KBD
				BPL			kbd_exit
				; got a key
				sta			KBDSTRB
				and			#$7F									; scan code
				cmp			#$31									; '1'?
				bne			:+
				lda			#(1<<7)
				sta			p1StartSwitch
:				cmp			#$35									; '5'?
				bne			:+
				inc			CurrNumCredits
:								
kbd_exit:				
				rts

char_SPACE:
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
    .BYTE  $00, $00, $00, $00
char_0:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_1:
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
char_2:
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00
char_3:
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_4:
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
char_5:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_6:
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_7:
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
char_8:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_9:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
char_A:
    .BYTE  $00, $10, $00, $00
    .BYTE  $01, $01, $00, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
char_B:
    .BYTE  $11, $11, $00, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $00, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $00, $00
char_C:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00
char_D:
    .BYTE  $11, $10, $00, $00
    .BYTE  $10, $01, $00, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $01, $00, $00
    .BYTE  $11, $10, $00, $00
char_E:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00
char_F:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
char_G:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_H:
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
char_I:
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $11, $11, $10, $00
char_J:
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $01, $00, $10, $00
    .BYTE  $00, $11, $10, $00
char_K:
    .BYTE  $10, $01, $00, $00
    .BYTE  $10, $10, $00, $00
    .BYTE  $11, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $00, $00, $00
    .BYTE  $10, $10, $00, $00
    .BYTE  $10, $01, $00, $00
char_L:
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00
char_M:
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $01, $10, $00
    .BYTE  $10, $10, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
char_N:
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $00, $10, $00
    .BYTE  $10, $10, $10, $00
    .BYTE  $10, $10, $10, $00
    .BYTE  $10, $01, $10, $00
    .BYTE  $10, $01, $10, $00
    .BYTE  $10, $00, $10, $00
char_O:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_P:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
char_Q:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $10, $10, $00
    .BYTE  $10, $01, $00, $00
    .BYTE  $11, $10, $10, $00
char_R:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $10, $00, $00
    .BYTE  $10, $01, $00, $00
    .BYTE  $10, $00, $10, $00
char_S:
    .BYTE  $11, $11, $10, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_T:
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
char_U:
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $11, $11, $10, $00
char_V:
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $01, $01, $00, $00
    .BYTE  $01, $01, $00, $00
    .BYTE  $01, $01, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
char_W:
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $10, $10, $00
    .BYTE  $11, $01, $10, $00
    .BYTE  $10, $00, $10, $00
char_X:
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $01, $01, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $01, $01, $00, $00
    .BYTE  $10, $00, $10, $00
    .BYTE  $10, $00, $10, $00
char_Y:
    .BYTE  $10, $00, $10, $00
    .BYTE  $01, $01, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $00, $10, $00, $00
char_Z:
    .BYTE  $11, $11, $10, $00
    .BYTE  $00, $00, $10, $00
    .BYTE  $00, $01, $00, $00
    .BYTE  $00, $10, $00, $00
    .BYTE  $01, $00, $00, $00
    .BYTE  $10, $00, $00, $00
    .BYTE  $11, $11, $10, $00

chr_tbl:
		.word char_SPACE
		.word char_0, char_1, char_2, char_3
		.word char_4, char_5, char_6, char_7
		.word char_8, char_9
		.word char_A, char_B, char_C, char_D
		.word char_E, char_F, char_G, char_H
		.word char_I, char_J, char_K, char_L
		.word char_M, char_N, char_O, char_P
		.word char_Q, char_R, char_S, char_T
		.word char_U, char_V, char_W, char_X
		.word char_Y, char_Z

extra_ship:
		.byte	$00, $10, $00, $00
		.byte $00, $10, $00, $00
		.byte $01, $01, $00, $00		
		.byte $01, $01, $00, $00		
		.byte $01, $01, $00, $00		
		.byte $11, $11, $10, $00
		.byte $10, $00, $10, $00
				