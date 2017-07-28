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

; iigs.asm
.import upd_ptr
.import dvg_cur
.import dvg_scalebrightness
.import dvg_halt

.export handle_erase_opcode

; (almost) the whole file should be 65816 now
        HINT_IIGSMODE

erase_chr:
				IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$000,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A0,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$140,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$3C0,x
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				OP_EXIT

erase_life:
				IIGSMODE
				; offset Y (4=+$280) because it overwrites score
        ldx     $C2
        lda     #0
        sta     SHRMEM+$280+$322,x
        sta     SHRMEM+$280+$3C0,x
        sta     SHRMEM+$280+$3C2,x
        sta     SHRMEM+$280+$140,x
        sta     SHRMEM+$280+$1E0,x
        sta     SHRMEM+$280+$280,x
        sta     SHRMEM+$280+$000,x
        sta     SHRMEM+$280+$0A0,x
        sta     SHRMEM+$280+$320,x
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				OP_EXIT

erase_asteroid:
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
				OP_EXIT

erase_ship:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$000,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A0,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$140,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$3C0,x
        OP_EXIT

erase_large_saucer:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$504,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$502,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$324,x
        OP_EXIT

erase_shifted_large_saucer:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$502,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$324,x
        sta     SHRMEM+$504,x
        OP_EXIT

erase_small_saucer:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$1E2,x
        OP_EXIT

erase_shifted_small_saucer:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$004,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$1E4,x
        OP_EXIT
        
erase_saucer:
				IIGSMODE
				ldx			$C2										; SHR offset
				lda			$09										; X (0-255)
				bit			#1
				bne			:+
				jmp     erase_large_saucer
:				jmp     erase_shifted_large_saucer

erase_shot:
				IIGSMODE
				ldx			$C2										; SHR offset
				lda			#0
				sta			SHRMEM,x
				OP_EXIT

erase_shrapnel_0:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$282,x
        sta     SHRMEM+$504,x
        sta     SHRMEM+$5A2,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$000,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$460,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$5A4,x
        sta     SHRMEM+$0A2,x
				OP_EXIT

erase_shrapnel_1:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$326,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$6E4,x
        sta     SHRMEM+$782,x
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$000,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$5A0,x
				OP_EXIT

erase_shrapnel_2:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$000,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E4,x
        sta     SHRMEM+$006,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$822,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$326,x
				OP_EXIT

erase_shrapnel_3:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$006,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$966,x
        sta     SHRMEM+$000,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$142,x
				OP_EXIT

erase_shifted_shrapnel_0:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$006,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$504,x
        sta     SHRMEM+$5A2,x
				OP_EXIT

erase_shifted_shrapnel_1:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$000,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$6E4,x
        sta     SHRMEM+$782,x
				OP_EXIT

erase_shifted_shrapnel_2:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$006,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$822,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$000,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E4,x
				OP_EXIT

erase_shifted_shrapnel_3:
        IIGSMODE
				ldx			$C2										; SHR offset
        lda     #0
        sta     SHRMEM+$000,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$3C8,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$006,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$966,x
				OP_EXIT

shrapnel_jmp_tbl:
    		; 4 shrapnel patterns; large, medium, small
    		.word erase_shrapnel_0-1
    		.word erase_shrapnel_1-1
    		.word erase_shrapnel_2-1, erase_shrapnel_2-1
    		.word erase_shrapnel_3-1, erase_shrapnel_3-1

shifted_shrapnel_jmp_tbl:
    		; 4 shrapnel patterns; large, medium, small
    		.word erase_shifted_shrapnel_0-1
    		.word erase_shifted_shrapnel_1-1
    		.word erase_shifted_shrapnel_2-1, erase_shifted_shrapnel_2-1
    		.word erase_shifted_shrapnel_3-1, erase_shifted_shrapnel_3-1

erase_shrapnel:
				IIGSMODE
				lda			$08										; global scale
				and			#$00FF
				bne			:+
				lda			#$0010
:				sec
				sbc			#$0B									; -> 0-5
				asl														; word offset into table
				tax
				ldy			shrapnel_jmp_tbl,x
				lda     $09
				bit     #1
				beq     :+
				ldy     shifted_shrapnel_jmp_tbl,x
:       phy
				ldx     $C2
				rts

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
        HINT_IIMODE
				and			#$F0									; opcode in high nibble
				lsr
				lsr
				lsr														; offset in jump table
				IIGSMODE
				and     #$00FF
				tax
				ldy			erase_jmp_tbl,x
				phy
        rts                           ; erase
