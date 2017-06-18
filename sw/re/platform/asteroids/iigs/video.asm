.include "apple2.inc"

render_frame:
				lda		#2
				sta		byte_B
				lda		dvg_curr_addr_msb
				sta		byte_C
				ldy		#0
render_loop:
				lda		(byte_B),y
				iny
				cmp		#$b0
				bne		render_loop
				rts
			