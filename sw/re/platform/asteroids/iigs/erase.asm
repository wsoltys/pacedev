.include "apple2.inc"

BUILD_OPT_ERASE_ASTEROID = 1
BUILD_OPT_ERASE_SHRAPNEL = 1

; iigs.asm
.import dvg_cur
.import dvg_scalebrightness
.import dvg_halt

.export handle_erase_opcode

erase_chr:
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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

erase_asteroid_0:
        HINT_IIGSMODE
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$460,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$964,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$0A0,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$8C0,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$140,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$506,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$820,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$962,x
        OP_EXIT

erase_asteroid_1:
        HINT_IIGSMODE
        sta     SHRMEM+$004,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$324,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$3C4,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$462,x
        OP_EXIT

erase_asteroid_2:
        HINT_IIGSMODE
        sta     SHRMEM+$144,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$142,x
        OP_EXIT

erase_asteroid_3:
        HINT_IIGSMODE
        sta     SHRMEM+$146,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$8C6,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$0A0,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$3C4,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$8C0,x
        sta     SHRMEM+$140,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$460,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$820,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$506,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$822,x
        sta     SHRMEM+$964,x
        OP_EXIT

erase_asteroid_4:
        HINT_IIGSMODE
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$324,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$3C4,x
        OP_EXIT

erase_asteroid_5:
        HINT_IIGSMODE
        sta     SHRMEM+$144,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$142,x
        OP_EXIT

erase_asteroid_6:
        HINT_IIGSMODE
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$822,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$5A4,x
        sta     SHRMEM+$644,x
        sta     SHRMEM+$6E4,x
        sta     SHRMEM+$784,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$8C6,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$506,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$642,x
        sta     SHRMEM+$8C0,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$6E2,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$782,x
        sta     SHRMEM+$820,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$964,x
        OP_EXIT

erase_asteroid_7:
        HINT_IIGSMODE
        sta     SHRMEM+$142,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$324,x
        sta     SHRMEM+$3C4,x
        sta     SHRMEM+$1E2,x
        OP_EXIT

erase_asteroid_8:
        HINT_IIGSMODE
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$142,x
        OP_EXIT

erase_asteroid_9:
        HINT_IIGSMODE
        sta     SHRMEM+$142,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$8C6,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$460,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$966,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$5A4,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$820,x
        sta     SHRMEM+$8C0,x
        sta     SHRMEM+$964,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$504,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$280,x
        OP_EXIT

erase_asteroid_10:
        HINT_IIGSMODE
        sta     SHRMEM+$284,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$3C4,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$324,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$1E4,x
        OP_EXIT

erase_asteroid_11:
        HINT_IIGSMODE
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$0A2,x
        OP_EXIT

erase_shifted_asteroid_0:
        HINT_IIGSMODE
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$460,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$006,x
        sta     SHRMEM+$288,x
        sta     SHRMEM+$648,x
        sta     SHRMEM+$6E8,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$140,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$506,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$820,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$964,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$962,x
        OP_EXIT

erase_shifted_asteroid_1:
        HINT_IIGSMODE
        sta     SHRMEM+$142,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$3C4,x
        OP_EXIT

erase_shifted_asteroid_2:
        HINT_IIGSMODE
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$0A4,x
        OP_EXIT

erase_shifted_asteroid_3:
        HINT_IIGSMODE
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$8C6,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$006,x
        sta     SHRMEM+$288,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$5A8,x
        sta     SHRMEM+$648,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$966,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$140,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$460,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$820,x
        sta     SHRMEM+$822,x
        sta     SHRMEM+$964,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$506,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$0A2,x
        OP_EXIT

erase_shifted_asteroid_4:
        HINT_IIGSMODE
        sta     SHRMEM+$142,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$3C4,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$1E4,x
        OP_EXIT

erase_shifted_asteroid_5:
        HINT_IIGSMODE
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$0A4,x
        OP_EXIT

erase_shifted_asteroid_6:
        HINT_IIGSMODE
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$5A4,x
        sta     SHRMEM+$6E4,x
        sta     SHRMEM+$784,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$8C6,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$006,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$3C8,x
        sta     SHRMEM+$468,x
        sta     SHRMEM+$502,x
        sta     SHRMEM+$508,x
        sta     SHRMEM+$5A8,x
        sta     SHRMEM+$966,x
        sta     SHRMEM+$644,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$326,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$6E2,x
        sta     SHRMEM+$6E6,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$782,x
        sta     SHRMEM+$820,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$786,x
        sta     SHRMEM+$822,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$964,x
        sta     SHRMEM+$004,x
        OP_EXIT

erase_shifted_asteroid_7:
        HINT_IIGSMODE
        sta     SHRMEM+$282,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$286,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$324,x
        sta     SHRMEM+$3C4,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E2,x
        OP_EXIT

erase_shifted_asteroid_8:
        HINT_IIGSMODE
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$0A4,x
        OP_EXIT

erase_shifted_asteroid_9:
        HINT_IIGSMODE
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$320,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$460,x
        sta     SHRMEM+$500,x
        sta     SHRMEM+$5A0,x
        sta     SHRMEM+$0A6,x
        sta     SHRMEM+$288,x
        sta     SHRMEM+$328,x
        sta     SHRMEM+$3C8,x
        sta     SHRMEM+$6E8,x
        sta     SHRMEM+$788,x
        sta     SHRMEM+$822,x
        sta     SHRMEM+$466,x
        sta     SHRMEM+$5A6,x
        sta     SHRMEM+$966,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$504,x
        sta     SHRMEM+$780,x
        sta     SHRMEM+$826,x
        sta     SHRMEM+$8C2,x
        sta     SHRMEM+$8C4,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$640,x
        sta     SHRMEM+$6E0,x
        sta     SHRMEM+$824,x
        sta     SHRMEM+$8C6,x
        sta     SHRMEM+$962,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$464,x
        sta     SHRMEM+$646,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$282,x
        OP_EXIT

erase_shifted_asteroid_10:
        HINT_IIGSMODE
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$282,x
        sta     SHRMEM+$3C4,x
        sta     SHRMEM+$146,x
        sta     SHRMEM+$1E6,x
        sta     SHRMEM+$3C6,x
        sta     SHRMEM+$004,x
        sta     SHRMEM+$002,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$324,x
        sta     SHRMEM+$462,x
        sta     SHRMEM+$284,x
        sta     SHRMEM+$322,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$464,x
        OP_EXIT

erase_shifted_asteroid_11:
        HINT_IIGSMODE
        sta     SHRMEM+$004,x
        sta     SHRMEM+$1E4,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$0A4,x
				OP_EXIT

asteroid_jmp_tbl:
    		; 4 asteroid patterns; large, medium, small
    		.word erase_asteroid_2-1,  erase_asteroid_1-1,  erase_asteroid_0-1,  0
    		.word erase_asteroid_5-1,  erase_asteroid_4-1,  erase_asteroid_3-1,  0
    		.word erase_asteroid_8-1,  erase_asteroid_7-1,  erase_asteroid_6-1,  0
    		.word erase_asteroid_11-1, erase_asteroid_10-1, erase_asteroid_9-1,  0

shifted_asteroid_jmp_tbl:
    		; 4 asteroid patterns; large, medium, small
    		.word erase_shifted_asteroid_2-1,  erase_shifted_asteroid_1-1,  erase_shifted_asteroid_0-1,  0
    		.word erase_shifted_asteroid_5-1,  erase_shifted_asteroid_4-1,  erase_shifted_asteroid_3-1,  0
    		.word erase_shifted_asteroid_8-1,  erase_shifted_asteroid_7-1,  erase_shifted_asteroid_6-1,  0
    		.word erase_shifted_asteroid_11-1, erase_shifted_asteroid_10-1, erase_shifted_asteroid_9-1,  0

erase_asteroid:
				HINT_IIGSMODE
        lda     (byte_B)							; status (4:3)=shape, (2:1)=size
       	and 		#$001E
       	tax
				ldy			asteroid_jmp_tbl,x
				lda     $09
				bit     #1
				beq     :+
				ldy     shifted_asteroid_jmp_tbl,x
:       phy
				ldx     $C2
				lda			#0
				rts

erase_ship:
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
        lda     #0
        sta     SHRMEM+$004,x
        sta     SHRMEM+$0A2,x
        sta     SHRMEM+$1E2,x
        sta     SHRMEM+$144,x
        sta     SHRMEM+$0A4,x
        sta     SHRMEM+$142,x
        sta     SHRMEM+$1E4,x
        OP_EXIT
        
saucer_jmp_tbl:
				.word $0000
    		.word erase_small_saucer-1
    		.word erase_large_saucer-1

shifted_saucer_jmp_tbl:
				.word $0000
    		.word erase_shifted_small_saucer-1
    		.word erase_shifted_large_saucer-1

erase_saucer:
				HINT_IIGSMODE
				lda			(byte_B)							; status
				and			#$0003
				asl
				tax
				ldy			saucer_jmp_tbl,x
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			shifted_saucer_jmp_tbl,x
:				phy
				ldx			$C2										; SHR offset
				rts
				
erase_shot:
        HINT_IIGSMODE
				ldx			$C2										; SHR offset
				lda			#0
				sta			SHRMEM,x
				OP_EXIT

.ifdef BUILD_OPT_ERASE_SHRAPNEL

erase_shrapnel_0:
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
        HINT_IIGSMODE
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
				ldx     $C2										; SHR offset
				lda			#0
				rts
.endif

erase_explodingship:
        OP_EXIT
                        
erase_invalid:
        OP_EXIT

erase_jmp_tbl:
				.word		dvg_cur-1
				.word		erase_chr-1
				.word		erase_life-1
				.word		erase_invalid-1
.ifdef BUILD_OPT_ERASE_ASTEROID
				.word		erase_asteroid-1
.else
				.word		erase_invalid-1
.endif				
				.word		erase_ship-1
				.word		erase_saucer-1
				.word		erase_shot-1
.ifdef BUILD_OPT_ERASE_SHRAPNEL
				.word		erase_shrapnel-1
.else
				.word		erase_invalid-1
.endif				
				.word		erase_explodingship-1
				.word		erase_invalid-1
				.word		erase_invalid-1
				.word		erase_invalid-1
				.word		erase_invalid-1
				.word		dvg_scalebrightness-1
				.word		dvg_halt-1
				rts

handle_erase_opcode:
				HINT_IIGSMODE
				xba														; opcode to low byte
				lsr
				lsr
				lsr														; offset in jump table
				and     #$001E
				tax
				lda			erase_jmp_tbl,x
				pha
        rts                           ; erase
