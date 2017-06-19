.include "apple2.inc"

; export for debugging only
.export dvg_vec
.export dvg_cur
.export dvg_halt
.export dvg_jsr
.export dvg_rts
.export dvg_jmp
.export dvg_svec

; dvg routines

upd_ptr:
				sec
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
								
render_frame:
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


			