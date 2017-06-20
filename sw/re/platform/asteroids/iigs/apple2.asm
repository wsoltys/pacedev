.include "apple2.inc"

; export for debugging only
.export dvg_vec
.export dvg_cur
.export dvg_halt
.export dvg_jsr
.export dvg_rts
.export dvg_jmp
.export dvg_svec

; text lookup
text_row_addr:
				.word		$400,$480,$500,$580,$600,$680,$700,$780
				.word		$428,$4A8,$528,$5A8,$628,$6A8,$728,$7A8
				.word		$450,$4D0,$550,$5D0,$650,$6D0,$750,$7D0

apple_reset:
				lda			#$02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				rts

apple_start:
				; enable page1/page2 in 40 column mode
				sta			_80STOREOFF
				; set current text page to page 1
				lda			#<PAGE2OFF
				sta			$C0
				lda			#>PAGE2OFF
				sta			$C1
				lda			#0
				sta			$C2										; text address mask

				lda			#24
				sta			cls_row
				lda			#40
				sta			cls_col
				jsr			apple_render_frame		; cls page 1
				jsr			apple_render_frame		; cls page 2

				lda			#16
				sta			cls_row
				lda			#32
				sta			cls_col
				rts
								
; find text coordinates for current
; 10 bits -> 5 bits
cur_2_txt:
				lda			$05										; CUR X (msb)
				sta			$09
				lda			$04										; CUR X (lsb)
				asl
				rol			$09
				asl
				rol			$09
				asl
				rol			$09										; CUR X (0-31)
				lda			$07										; CUR Y (msb)
				sta			$0A
				lda			$06										; CUR Y (lsb)
				asl
				rol			$0A
				asl
				rol			$0A										; CUR Y (0-15)
				; lookup row addr
				lda			$0A
				eor			#$0F									; invert Y
				asl														; offset in row address table
				tay
				lda			text_row_addr,y
				sta			$80
				lda			text_row_addr+1,y
				eor			$C2										; page 1/2
				sta			$81
				rts

; print A=chr at CUR ($09,$0A)
print_chr:
				ldy			$09										; CUR X
				; this is a complete fudge
				inc			$09										; next char address
				sta			($80),Y
				rts
																
; dvg routines

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
				jsr			cur_2_txt
				lda			#$A8									; '('
				jsr			print_chr
				lda			#$83									; 'C'
				jsr			print_chr
				lda			#$A9									; ')'
				jsr			print_chr
				lda			#$B1									; '1'
				jsr			print_chr
				lda			#$B9									; '9'
				jsr			print_chr
				lda			#$B7									; '7'
				jsr			print_chr
				lda			#$B9									; '9'
				jsr			print_chr
				lda			#$A0									; space
				jsr			print_chr
				lda			#$81									; 'A'
				jsr			print_chr
				lda			#$94									; 'T'
				jsr			print_chr
				lda			#$81									; 'A'
				jsr			print_chr
				lda			#$92									; 'R'
				jsr			print_chr
				lda			#$89									; 'I'
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
				jsr			cur_2_txt							; map to text coordinates
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
				cmp			#11
				bcc			not_alpha
				sbc			#10
				ora			#$80
				bne			jsr_print							; (always)
not_alpha:
				cmp			#1
				bcc			not_digit
				sbc			#1
				ora			#$B0
				bne			jsr_print							; (always)
not_digit:
				lda			#$A0									; space
				bne			jsr_print							; (always)
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
				lda			#$9E
				bne			jsr_print
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

cls_row:	.byte 0
cls_col:	.byte 0

cls:
				lda			cls_row
				sec
				sbc			#1
				asl														; row*2
				tax
:				lda			text_row_addr,x
				sta			$80
				lda			text_row_addr+1,x
				eor			$C2
				sta			$81
				lda			cls_col
				sec
				sbc			#1
				tay
				lda			#$A0									; space
:				sta			($80),y
				dey
				bpl			:-
				dex
				dex
				bpl			:--
				rts
				
apple_render_frame:
				lda			#$0C
				eor			$C2										; flip text addr mask
				sta			$C2
				jsr			cls										; clear screen
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
				; flip page
				lda			#(1<<0)
				eor			$C0										; toggle softswitch address
				sta			$C0
				ldy			#0
				sta			($C0),y								; flip
				
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
			