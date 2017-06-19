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
				sta			$81
				rts

; print A=chr at CUR ($09,$0A)
print_chr:
				ldy			$09										; CUR X
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
				; try matching against character routine
				ldx			#$00									; char index (x2)
lk1:		lda			$56D4,x
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
				bne			lk1
				beq			jsr_exit							; (always)
jsr_print:
				jsr			print_chr
				; this is a complete fudge
				inc			$09										; next char address
jsr_exit:				
:				lda			#2										; 2 bytes in instruction
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
								
render_frame:
				; clear screen
				ldx			#(16-1)*2
:				lda			text_row_addr,x
				sta			$80
				lda			text_row_addr+1,x
				sta			$81
				ldy			#31
				lda			#$A0									; space
:				sta			($80),y
				dey
				bpl			:-
				dex
				dex
				bpl			:--
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
				rts


			