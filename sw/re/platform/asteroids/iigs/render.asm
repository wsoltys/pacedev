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
.import dvg_cur
.import dvg_scalebrightness
.import dvg_halt
.import dvg_invalid

.export handle_dvg_opcode

; debug
.export dvg_chr
.export dvg_ship
.export render_ship_0

; still undecided if it's better with the BEQ
.macro  orw     offd, offv
        lda     offd,y
        beq     :+
        ora     SHRMEM+offv,x
        sta     SHRMEM+offv,x
:        
.endmacro

; $1
dvg_chr:
				HINT_IIGSMODE
        lda     (byte_B)            	; chr x2
				and			#$00FF
				tax
				ldy			chr_tbl,x
				ldx			$C2										; SHR offset
				orw     $00, 0*160+0
				orw     $02, 0*160+2
				orw     $04, 1*160+0
				orw     $06, 1*160+2
				orw     $08, 2*160+0
				orw     $0A, 2*160+2
				orw     $0C, 3*160+0
				orw     $0E, 3*160+2
				orw     $10, 4*160+0
				orw     $12, 4*160+2
				orw     $14, 5*160+0
				orw     $16, 5*160+2
				orw     $18, 6*160+0
				orw     $1A, 6*160+2
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				OP_EXIT

; $2
dvg_life:
				HINT_IIGSMODE
				; offset Y (+$280) because it overwrites score
				ldx			$C2										; SHR offset
        lda     #$00F0
        ora     SHRMEM+$280+$322,x
        sta     SHRMEM+$280+$322,x
        lda     #$00F0
        ora     SHRMEM+$280+$3C0,x
        sta     SHRMEM+$280+$3C0,x
        lda     #$00F0
        ora     SHRMEM+$280+$3C2,x
        sta     SHRMEM+$280+$3C2,x
        lda     #$0F0F
        ora     SHRMEM+$280+$140,x
        sta     SHRMEM+$280+$140,x
        lda     #$0F0F
        ora     SHRMEM+$280+$1E0,x
        sta     SHRMEM+$280+$1E0,x
        lda     #$0F0F
        ora     SHRMEM+$280+$280,x
        sta     SHRMEM+$280+$280,x
        lda     #$F000
        ora     SHRMEM+$280+$000,x
        sta     SHRMEM+$280+$000,x
        lda     #$F000
        ora     SHRMEM+$280+$0A0,x
        sta     SHRMEM+$280+$0A0,x
        lda     #$FFFF
        sta     SHRMEM+$280+$320,x
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				OP_EXIT

; $3
dvg_copyright:
				HINT_IIGSMODE
				; CUR SSS=0,(400,128)
				ldx			#$6F72
        ldy     #$000F
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$00C,x
        sta     SHRMEM+$00C,x
        tya
        ora     SHRMEM+$010,x
        sta     SHRMEM+$010,x
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$0AE,x
        sta     SHRMEM+$0AE,x
        tya
        ora     SHRMEM+$0B4,x
        sta     SHRMEM+$0B4,x
        tya
        ora     SHRMEM+$0B8,x
        sta     SHRMEM+$0B8,x
        tya
        ora     SHRMEM+$0BC,x
        sta     SHRMEM+$0BC,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$14E,x
        sta     SHRMEM+$14E,x
        tya
        ora     SHRMEM+$154,x
        sta     SHRMEM+$154,x
        tya
        ora     SHRMEM+$158,x
        sta     SHRMEM+$158,x
        tya
        ora     SHRMEM+$15C,x
        sta     SHRMEM+$15C,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$1EE,x
        sta     SHRMEM+$1EE,x
        tya
        ora     SHRMEM+$1F4,x
        sta     SHRMEM+$1F4,x
        tya
        ora     SHRMEM+$1F8,x
        sta     SHRMEM+$1F8,x
        tya
        ora     SHRMEM+$1FC,x
        sta     SHRMEM+$1FC,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$28E,x
        sta     SHRMEM+$28E,x
        lda     #$00F0
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$00FF
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$00FF
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$00FF
        ora     SHRMEM+$1F2,x
        sta     SHRMEM+$1F2,x
        lda     #$0FF0
        ora     SHRMEM+$01A,x
        sta     SHRMEM+$01A,x
        lda     #$0FF0
        ora     SHRMEM+$1FA,x
        sta     SHRMEM+$1FA,x
        lda     #$0FF0
        ora     SHRMEM+$29A,x
        sta     SHRMEM+$29A,x
        lda     #$0FFF
        ora     SHRMEM+$0BA,x
        sta     SHRMEM+$0BA,x
        ldy     #$F000
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$1E8,x
        sta     SHRMEM+$1E8,x
        tya
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$288,x
        sta     SHRMEM+$288,x
        ldy     #$F0F0
        tya
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        tya
        ora     SHRMEM+$0A8,x
        sta     SHRMEM+$0A8,x
        tya
        ora     SHRMEM+$0AC,x
        sta     SHRMEM+$0AC,x
        tya
        ora     SHRMEM+$0B0,x
        sta     SHRMEM+$0B0,x
        tya
        ora     SHRMEM+$0B2,x
        sta     SHRMEM+$0B2,x
        tya
        ora     SHRMEM+$1EC,x
        sta     SHRMEM+$1EC,x
        tya
        ora     SHRMEM+$1F0,x
        sta     SHRMEM+$1F0,x
        tya
        ora     SHRMEM+$28C,x
        sta     SHRMEM+$28C,x
        tya
        ora     SHRMEM+$290,x
        sta     SHRMEM+$290,x
        tya
        ora     SHRMEM+$292,x
        sta     SHRMEM+$292,x
        ldy     #$F0FF
        tya
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$008,x
        sta     SHRMEM+$008,x
        tya
        ora     SHRMEM+$00E,x
        sta     SHRMEM+$00E,x
        tya
        ora     SHRMEM+$012,x
        sta     SHRMEM+$012,x
        tya
        ora     SHRMEM+$014,x
        sta     SHRMEM+$014,x
        tya
        ora     SHRMEM+$018,x
        sta     SHRMEM+$018,x
        tya
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        tya
        ora     SHRMEM+$148,x
        sta     SHRMEM+$148,x
        tya
        ora     SHRMEM+$14C,x
        sta     SHRMEM+$14C,x
        tya
        ora     SHRMEM+$150,x
        sta     SHRMEM+$150,x
        tya
        ora     SHRMEM+$152,x
        sta     SHRMEM+$152,x
        tya
        ora     SHRMEM+$294,x
        sta     SHRMEM+$294,x
        tya
        ora     SHRMEM+$298,x
        sta     SHRMEM+$298,x
        lda     #$FF0F
        ora     SHRMEM+$01C,x
        sta     SHRMEM+$01C,x
        lda     #$FF0F
        ora     SHRMEM+$29C,x
        sta     SHRMEM+$29C,x
        lda     #$FFF0
        ora     SHRMEM+$15A,x
        sta     SHRMEM+$15A,x
				OP_EXIT

render_asteroid_0:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        tya
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        tya
        ora     SHRMEM+$460,x
        sta     SHRMEM+$460,x
        tya
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        tya
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        lda     #$00FF
        ora     SHRMEM+$964,x
        sta     SHRMEM+$964,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        tya
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$8C0,x
        sta     SHRMEM+$8C0,x
        ldy     #$F000
        tya
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        tya
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        tya
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        tya
        ora     SHRMEM+$506,x
        sta     SHRMEM+$506,x
        tya
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        tya
        ora     SHRMEM+$820,x
        sta     SHRMEM+$820,x
        tya
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        lda     #$F00F
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        lda     #$FF0F
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        OP_EXIT
        
render_asteroid_1:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$000F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        tya
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$0F00
        ora     SHRMEM+$324,x
        sta     SHRMEM+$324,x
        lda     #$0F0F
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0FF0
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$F000
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$F000
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$F000
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        lda     #$F00F
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        lda     #$F0F0
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$FF00
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        OP_EXIT

render_asteroid_2:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$00F0
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00F0
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$00FF
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F000
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        OP_EXIT

render_asteroid_3:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        tya
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$8C6,x
        sta     SHRMEM+$8C6,x
        tya
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        lda     #$00FF
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        tya
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        tya
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        tya
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        tya
        ora     SHRMEM+$8C0,x
        sta     SHRMEM+$8C0,x
        ldy     #$F000
        tya
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$460,x
        sta     SHRMEM+$460,x
        tya
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        tya
        ora     SHRMEM+$820,x
        sta     SHRMEM+$820,x
        lda     #$F00F
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F00F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$F00F
        ora     SHRMEM+$506,x
        sta     SHRMEM+$506,x
        lda     #$F0FF
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        lda     #$FF00
        ora     SHRMEM+$822,x
        sta     SHRMEM+$822,x
        lda     #$FF00
        ora     SHRMEM+$964,x
        sta     SHRMEM+$964,x
        OP_EXIT

render_asteroid_4:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$0F00
        ora     SHRMEM+$324,x
        sta     SHRMEM+$324,x
        lda     #$0F0F
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F0F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$F000
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$F000
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        lda     #$F000
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$F00F
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$F0F0
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$F0F0
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        OP_EXIT

render_asteroid_5:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$00F0
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00F0
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$00FF
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F000
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        OP_EXIT

render_asteroid_6:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        tya
        ora     SHRMEM+$822,x
        sta     SHRMEM+$822,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        tya
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        tya
        ora     SHRMEM+$5A4,x
        sta     SHRMEM+$5A4,x
        tya
        ora     SHRMEM+$644,x
        sta     SHRMEM+$644,x
        tya
        ora     SHRMEM+$6E4,x
        sta     SHRMEM+$6E4,x
        tya
        ora     SHRMEM+$784,x
        sta     SHRMEM+$784,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        tya
        ora     SHRMEM+$8C6,x
        sta     SHRMEM+$8C6,x
        tya
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        tya
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        tya
        ora     SHRMEM+$506,x
        sta     SHRMEM+$506,x
        tya
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        tya
        ora     SHRMEM+$642,x
        sta     SHRMEM+$642,x
        tya
        ora     SHRMEM+$8C0,x
        sta     SHRMEM+$8C0,x
        ldy     #$F000
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        tya
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        tya
        ora     SHRMEM+$6E2,x
        sta     SHRMEM+$6E2,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        tya
        ora     SHRMEM+$782,x
        sta     SHRMEM+$782,x
        tya
        ora     SHRMEM+$820,x
        sta     SHRMEM+$820,x
        lda     #$FF00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$FF0F
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        lda     #$FFFF
        sta     SHRMEM+$004,x
        lda     #$FFFF
        sta     SHRMEM+$3C0,x
        lda     #$FFFF
        sta     SHRMEM+$964,x
        OP_EXIT

render_asteroid_7:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$0F00
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        lda     #$0F0F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        ldy     #$F000
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        tya
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$F0F0
        ora     SHRMEM+$324,x
        sta     SHRMEM+$324,x
        lda     #$F0F0
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        lda     #$F0FF
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        OP_EXIT

render_asteroid_8:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$00F0
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00F0
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$00FF
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        OP_EXIT

render_asteroid_9:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$8C6,x
        sta     SHRMEM+$8C6,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        tya
        ora     SHRMEM+$460,x
        sta     SHRMEM+$460,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        tya
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        tya
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        tya
        ora     SHRMEM+$966,x
        sta     SHRMEM+$966,x
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        tya
        ora     SHRMEM+$5A4,x
        sta     SHRMEM+$5A4,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        tya
        ora     SHRMEM+$820,x
        sta     SHRMEM+$820,x
        tya
        ora     SHRMEM+$8C0,x
        sta     SHRMEM+$8C0,x
        tya
        ora     SHRMEM+$964,x
        sta     SHRMEM+$964,x
        ldy     #$F000
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$504,x
        sta     SHRMEM+$504,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        lda     #$F00F
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        lda     #$F00F
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        lda     #$F0F0
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        lda     #$F0FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$FF00
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$FF00
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        lda     #$FF0F
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        lda     #$FF0F
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$FFFF
        sta     SHRMEM+$002,x
        lda     #$FFFF
        sta     SHRMEM+$280,x
        OP_EXIT

render_asteroid_10:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        lda     #$000F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$000F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$00F0
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$0F00
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$0FF0
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        lda     #$F000
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F000
        ora     SHRMEM+$324,x
        sta     SHRMEM+$324,x
        lda     #$F00F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$F00F
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$F0FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$FF00
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$FF0F
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        OP_EXIT

render_asteroid_11:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$000F
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$00F0
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00F0
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        OP_EXIT

render_shifted_asteroid_0:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        tya
        ora     SHRMEM+$460,x
        sta     SHRMEM+$460,x
        tya
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$288,x
        sta     SHRMEM+$288,x
        tya
        ora     SHRMEM+$648,x
        sta     SHRMEM+$648,x
        tya
        ora     SHRMEM+$6E8,x
        sta     SHRMEM+$6E8,x
        lda     #$00FF
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        lda     #$00FF
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        tya
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        tya
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        tya
        ora     SHRMEM+$506,x
        sta     SHRMEM+$506,x
        tya
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        tya
        ora     SHRMEM+$820,x
        sta     SHRMEM+$820,x
        tya
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        ldy     #$F000
        tya
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        lda     #$F0F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F0F0
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$F0FF
        ora     SHRMEM+$964,x
        sta     SHRMEM+$964,x
        lda     #$FF00
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        lda     #$FF00
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        OP_EXIT

render_shifted_asteroid_1:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00F0
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        lda     #$00F0
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        lda     #$00FF
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        tya
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$0FFF
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$F000
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$F000
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F000
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$FF00
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        OP_EXIT

render_shifted_asteroid_2:
        HINT_IIGSMODE
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$0F00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$F00F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        OP_EXIT

render_shifted_asteroid_3:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$8C6,x
        sta     SHRMEM+$8C6,x
        tya
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$288,x
        sta     SHRMEM+$288,x
        tya
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        tya
        ora     SHRMEM+$5A8,x
        sta     SHRMEM+$5A8,x
        tya
        ora     SHRMEM+$648,x
        sta     SHRMEM+$648,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$966,x
        sta     SHRMEM+$966,x
        lda     #$00FF
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$460,x
        sta     SHRMEM+$460,x
        tya
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        tya
        ora     SHRMEM+$820,x
        sta     SHRMEM+$820,x
        tya
        ora     SHRMEM+$822,x
        sta     SHRMEM+$822,x
        tya
        ora     SHRMEM+$964,x
        sta     SHRMEM+$964,x
        ldy     #$F000
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        lda     #$F00F
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        lda     #$F0F0
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        lda     #$FF00
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$FF00
        ora     SHRMEM+$506,x
        sta     SHRMEM+$506,x
        lda     #$FF0F
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        lda     #$FFF0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        OP_EXIT

render_shifted_asteroid_4:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00F0
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        lda     #$00F0
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        lda     #$0F00
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$0FFF
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$0FFF
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        ldy     #$F000
        tya
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        tya
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$FF00
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        OP_EXIT

render_shifted_asteroid_5:
        HINT_IIGSMODE
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$0F00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$F00F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        OP_EXIT

render_shifted_asteroid_6:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        tya
        ora     SHRMEM+$5A4,x
        sta     SHRMEM+$5A4,x
        tya
        ora     SHRMEM+$6E4,x
        sta     SHRMEM+$6E4,x
        tya
        ora     SHRMEM+$784,x
        sta     SHRMEM+$784,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        tya
        ora     SHRMEM+$8C6,x
        sta     SHRMEM+$8C6,x
        tya
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        tya
        ora     SHRMEM+$3C8,x
        sta     SHRMEM+$3C8,x
        tya
        ora     SHRMEM+$468,x
        sta     SHRMEM+$468,x
        tya
        ora     SHRMEM+$502,x
        sta     SHRMEM+$502,x
        tya
        ora     SHRMEM+$508,x
        sta     SHRMEM+$508,x
        tya
        ora     SHRMEM+$5A8,x
        sta     SHRMEM+$5A8,x
        tya
        ora     SHRMEM+$966,x
        sta     SHRMEM+$966,x
        lda     #$00FF
        ora     SHRMEM+$644,x
        sta     SHRMEM+$644,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        tya
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        tya
        ora     SHRMEM+$6E2,x
        sta     SHRMEM+$6E2,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        tya
        ora     SHRMEM+$782,x
        sta     SHRMEM+$782,x
        tya
        ora     SHRMEM+$820,x
        sta     SHRMEM+$820,x
        ldy     #$F000
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        tya
        ora     SHRMEM+$822,x
        sta     SHRMEM+$822,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        lda     #$F0F0
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        lda     #$FF00
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        lda     #$FF0F
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$FF0F
        ora     SHRMEM+$964,x
        sta     SHRMEM+$964,x
        lda     #$FFFF
        sta     SHRMEM+$004,x
        OP_EXIT

render_shifted_asteroid_7:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        lda     #$00F0
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        tya
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$0F0F
        ora     SHRMEM+$324,x
        sta     SHRMEM+$324,x
        lda     #$0FFF
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$F000
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$F00F
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$F0FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$FF0F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        OP_EXIT

render_shifted_asteroid_8:
        HINT_IIGSMODE
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$0F00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F00F
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$F0F0
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        OP_EXIT

render_shifted_asteroid_9:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        tya
        ora     SHRMEM+$460,x
        sta     SHRMEM+$460,x
        tya
        ora     SHRMEM+$500,x
        sta     SHRMEM+$500,x
        tya
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        tya
        ora     SHRMEM+$288,x
        sta     SHRMEM+$288,x
        tya
        ora     SHRMEM+$328,x
        sta     SHRMEM+$328,x
        tya
        ora     SHRMEM+$3C8,x
        sta     SHRMEM+$3C8,x
        tya
        ora     SHRMEM+$6E8,x
        sta     SHRMEM+$6E8,x
        tya
        ora     SHRMEM+$788,x
        sta     SHRMEM+$788,x
        tya
        ora     SHRMEM+$822,x
        sta     SHRMEM+$822,x
        lda     #$00FF
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        lda     #$00FF
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        lda     #$00FF
        ora     SHRMEM+$966,x
        sta     SHRMEM+$966,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$504,x
        sta     SHRMEM+$504,x
        tya
        ora     SHRMEM+$780,x
        sta     SHRMEM+$780,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        lda     #$0FF0
        ora     SHRMEM+$8C2,x
        sta     SHRMEM+$8C2,x
        lda     #$0FFF
        ora     SHRMEM+$8C4,x
        sta     SHRMEM+$8C4,x
        ldy     #$F000
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$8C6,x
        sta     SHRMEM+$8C6,x
        lda     #$F00F
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        lda     #$F0FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        ldy     #$FF00
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        tya
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        tya
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        lda     #$FF0F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$FF0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FFFF
        sta     SHRMEM+$282,x
        OP_EXIT

render_shifted_asteroid_10:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$000F
        ora     SHRMEM+$3C4,x
        sta     SHRMEM+$3C4,x
        lda     #$00F0
        ora     SHRMEM+$146,x
        sta     SHRMEM+$146,x
        lda     #$00F0
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        lda     #$00F0
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$324,x
        sta     SHRMEM+$324,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$F000
        ora     SHRMEM+$284,x
        sta     SHRMEM+$284,x
        lda     #$F000
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$F000
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$FF00
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$FF00
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$FF0F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FFF0
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        OP_EXIT

render_shifted_asteroid_11:
        HINT_IIGSMODE
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$0F00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$F0F0
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        OP_EXIT

asteroid_jmp_tbl:
    		; 4 asteroid patterns; large, medium, small
    		.word render_asteroid_2-1,  render_asteroid_1-1,  render_asteroid_0-1,  0
    		.word render_asteroid_5-1,  render_asteroid_4-1,  render_asteroid_3-1,  0
    		.word render_asteroid_8-1,  render_asteroid_7-1,  render_asteroid_6-1,  0
    		.word render_asteroid_11-1, render_asteroid_10-1, render_asteroid_9-1,  0

shifted_asteroid_jmp_tbl:
    		; 4 asteroid patterns; large, medium, small
    		.word render_shifted_asteroid_2-1,  render_shifted_asteroid_1-1,  render_shifted_asteroid_0-1,  0
    		.word render_shifted_asteroid_5-1,  render_shifted_asteroid_4-1,  render_shifted_asteroid_3-1,  0
    		.word render_shifted_asteroid_8-1,  render_shifted_asteroid_7-1,  render_shifted_asteroid_6-1,  0
    		.word render_shifted_asteroid_11-1, render_shifted_asteroid_10-1, render_shifted_asteroid_9-1,  0

; $4
dvg_asteroid:
				HINT_IIGSMODE
        lda     (byte_B)							; status (4:3)=shape, (2:1)=size
       	and 		#$001E
       	tax
				ldy			asteroid_jmp_tbl,x
				lda     byte_4								; X (0-255)
				bit     #(1<<0)
				beq     :+
				ldy     shifted_asteroid_jmp_tbl,x
:       phy
				ldx     $C2
				rts

.macro thrust offs, data
        lda			$c8										; thrust
        bit			#(1<<11)
        beq			:+
        lda     #data
        ora     SHRMEM+offs,x
        sta     SHRMEM+offs,x
:
.endmacro

render_ship_0:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00FF
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$00FF
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$F00F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$FF0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        thrust  $1E0, $00F0
       	OP_EXIT

render_ship_1:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$000F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$00FF
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F0FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FFFF
        sta     SHRMEM+$0A0,x
        thrust  $1E0, $00F0
        OP_EXIT

render_ship_2:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$F0FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F0FF
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        thrust  $280, $000F
        OP_EXIT

render_ship_3:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F00F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$F00F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F0FF
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        thrust  $320, $000F
        OP_EXIT

render_ship_4:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$00FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        thrust  $321, $00F0
        OP_EXIT

render_ship_5:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$000F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF0F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $3C1, $000F
        OP_EXIT

render_ship_6:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$000F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF0F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $3C1, $000F
        OP_EXIT

render_ship_7:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$000F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$000F
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$FF00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF0F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $3C1, $000F
        OP_EXIT

render_ship_8:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$0F0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$F000
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F00F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$FF00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        thrust  $322, $00F0
        OP_EXIT

render_ship_9:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$00FF
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$00FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F0FF
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$FF00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FFF0
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $322, $000F
        OP_EXIT

render_ship_10:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$00F0
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F0FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$FFFF
        sta     SHRMEM+$0A0,x
        thrust  $282, $000F
        OP_EXIT

render_ship_11:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$000F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F00F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F0FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F0FF
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        thrust  $1E3, $00F0
        OP_EXIT

render_ship_12:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00FF
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$00FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$F00F
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F00F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        thrust  $1E3, $00F0
        OP_EXIT

render_ship_13:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$F00F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F0FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$FFFF
        sta     SHRMEM+$1E0,x
        thrust  $143, $00F0
        OP_EXIT

render_ship_14:
        HINT_IIGSMODE
        lda     #$00F0
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F0F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F0FF
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F0FF
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        thrust  $0A2, $000F
        OP_EXIT

render_ship_15:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$0F00
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$0F0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F0FF
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F0FF
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FF00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        thrust  $0A2, $000F
        OP_EXIT

render_ship_16:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$000F
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$0F0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F000
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$F00F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        thrust  $0A2, $00F0
        OP_EXIT

render_ship_17:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$000F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F000
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$FF00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FF0F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $001, $000F
        OP_EXIT

render_ship_18:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$000F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$0F00
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF0F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $001, $000F
        OP_EXIT

render_ship_19:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$00FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$0F00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$FF0F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $001, $000F
        OP_EXIT

render_ship_20:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$000F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$0F0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        thrust  $0A1, $00F0
        OP_EXIT

render_ship_21:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$F0FF
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$FF00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        thrust  $0A0, $000F
        OP_EXIT

render_ship_22:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F0FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$FFFF
        sta     SHRMEM+$280,x
        thrust  $140, $000F
        OP_EXIT

render_ship_23:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$000F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$00FF
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$0F0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F0FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$F0FF
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FF0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        thrust  $1E0, $00F0
        OP_EXIT

render_shifted_ship_0:
        HINT_IIGSMODE
        lda     #$00FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F00F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$F00F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF00
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$FF00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        thrust  $1E0, $000F
 	      OP_EXIT

render_shifted_ship_1:
        HINT_IIGSMODE
        lda     #$00F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$F00F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$FF00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF0F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$FF0F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        thrust  $1E0, $000F
        OP_EXIT

render_shifted_ship_2:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$0F00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FFFF
        sta     SHRMEM+$0A2,x
        thrust  $281, $00F0
        OP_EXIT

render_shifted_ship_3:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00F0
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$00FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F0FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$FF00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF0F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        thrust  $321, $00F0
        OP_EXIT

render_shifted_ship_4:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$000F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$000F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$00FF
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F00F
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F0F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        thrust  $321, $000F
        OP_EXIT

render_shifted_ship_5:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$00FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$F000
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$F0FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$FF00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $3C2, $00F0
        OP_EXIT

render_shifted_ship_6:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$00F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F000
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$F0FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$FF00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $3C2, $00F0
        OP_EXIT

render_shifted_ship_7:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F0FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$FF00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $3C2, $00F0
        OP_EXIT

render_shifted_ship_8:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$0F00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$0F00
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F0F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$FF00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $322, $000F
        OP_EXIT

render_shifted_ship_9:
        HINT_IIGSMODE
        ldy     #$00F0
        tya
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$0F00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$0F0F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F00F
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F00F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF0F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        thrust  $323, $00F0
        OP_EXIT

render_shifted_ship_10:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$00F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF0F
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$FF0F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        thrust  $283, $00F0
        OP_EXIT

render_shifted_ship_11:
        HINT_IIGSMODE
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F000
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$F0FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$FF00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$FF0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FFFF
        sta     SHRMEM+$0A2,x
        thrust  $1E3, $000F
        OP_EXIT

render_shifted_ship_12:
        HINT_IIGSMODE
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F00F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F0FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F0FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$FF00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$FF00
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        thrust  $1E3, $000F
        OP_EXIT

render_shifted_ship_13:
        HINT_IIGSMODE
        lda     #$F000
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F0F0
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$F0FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF0F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$FF0F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        thrust  $143, $000F
        OP_EXIT

render_shifted_ship_14:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$00F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$FF0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FFFF
        sta     SHRMEM+$1E2,x
        thrust  $0A3, $00F0
        OP_EXIT

render_shifted_ship_15:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$00F0
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$00F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$00FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF0F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$FF0F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $0A3, $00F0
        OP_EXIT

render_shifted_ship_16:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$0F00
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F0F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        thrust  $0A2, $000F
        OP_EXIT

render_shifted_ship_17:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$0F00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$0F00
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F0FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$FF00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $002, $00F0
        OP_EXIT

render_shifted_ship_18:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00F0
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00F0
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F000
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$F0FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$FF00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $002, $00F0
        OP_EXIT

render_shifted_ship_19:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$000F
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$00FF
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$00FF
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$0F00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F0FF
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$FF00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        thrust  $002, $00F0
        OP_EXIT

render_shifted_ship_20:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$000F
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$F000
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$F00F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$F0F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        thrust  $0A1, $000F
        OP_EXIT

render_shifted_ship_21:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$00F0
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$00FF
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$0F00
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$F00F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$F0F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$FF0F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        thrust  $0A1, $00F0
        OP_EXIT

render_shifted_ship_22:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$0F00
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F0F0
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$FF0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$FF0F
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        thrust  $141, $00F0
        OP_EXIT

render_shifted_ship_23:
        HINT_IIGSMODE
        lda     #$00F0
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$F000
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$F000
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F00F
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$FF00
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$FF0F
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FFFF
        sta     SHRMEM+$282,x
        thrust  $1E0, $000F
        OP_EXIT
                        
ship_jmp_tbl:
    		.word render_ship_0-1,  render_ship_1-1,  render_ship_2-1,  render_ship_3-1
    		.word render_ship_4-1,  render_ship_5-1,  render_ship_6-1,  render_ship_7-1
    		.word render_ship_8-1,  render_ship_9-1,  render_ship_10-1, render_ship_11-1
    		.word render_ship_12-1, render_ship_13-1, render_ship_14-1, render_ship_15-1
    		.word render_ship_16-1, render_ship_17-1, render_ship_18-1, render_ship_19-1
    		.word render_ship_20-1, render_ship_21-1, render_ship_22-1, render_ship_23-1

shifted_ship_jmp_tbl:
    		.word render_shifted_ship_0-1,  render_shifted_ship_1-1,  render_shifted_ship_2-1,  render_shifted_ship_3-1
    		.word render_shifted_ship_4-1,  render_shifted_ship_5-1,  render_shifted_ship_6-1,  render_shifted_ship_7-1
    		.word render_shifted_ship_8-1,  render_shifted_ship_9-1,  render_shifted_ship_10-1, render_shifted_ship_11-1
    		.word render_shifted_ship_12-1, render_shifted_ship_13-1, render_shifted_ship_14-1, render_shifted_ship_15-1
    		.word render_shifted_ship_16-1, render_shifted_ship_17-1, render_shifted_ship_18-1, render_shifted_ship_19-1
    		.word render_shifted_ship_20-1, render_shifted_ship_21-1, render_shifted_ship_22-1, render_shifted_ship_23-1

; $5
; $00=dir(0-255)
dvg_ship:
				HINT_IIGSMODE
				lda			(byte_B)            	; direction
				sta			$c8										; opcode inc. thrust
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
				ldy			ship_jmp_tbl,x
				lda     byte_4								; X (0-255)
				bit     #(1<<0)
				beq			:+
				ldy			shifted_ship_jmp_tbl,x
:       phy
				ldx     $C2
				rts

render_large_saucer:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        tya
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        tya
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        tya
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        lda     #$F000
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F0FF
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$F0FF
        ora     SHRMEM+$504,x
        sta     SHRMEM+$504,x
        lda     #$FF00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$FF00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$FF0F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF0F
        ora     SHRMEM+$502,x
        sta     SHRMEM+$502,x
        lda     #$FFFF
        sta     SHRMEM+$322,x
        lda     #$FFFF
        sta     SHRMEM+$324,x
        OP_EXIT

render_shifted_large_saucer:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        tya
        ora     SHRMEM+$286,x
        sta     SHRMEM+$286,x
        tya
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        tya
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$F000
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$F0FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$F0FF
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        lda     #$FF00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$FF00
        ora     SHRMEM+$502,x
        sta     SHRMEM+$502,x
        ldy     #$FFFF
        tya
        sta     SHRMEM+$144,x
        tya
        sta     SHRMEM+$322,x
        tya
        sta     SHRMEM+$324,x
        tya
        sta     SHRMEM+$504,x
        OP_EXIT

render_small_saucer:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$00F0
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$00FF
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        lda     #$0F00
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        lda     #$0F0F
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F0F0
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$FF00
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        OP_EXIT

render_shifted_small_saucer:
        HINT_IIGSMODE
        lda     #$00FF
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        lda     #$0F00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$0F00
        ora     SHRMEM+$1E2,x
        sta     SHRMEM+$1E2,x
        lda     #$0FFF
        ora     SHRMEM+$144,x
        sta     SHRMEM+$144,x
        lda     #$F000
        ora     SHRMEM+$0A4,x
        sta     SHRMEM+$0A4,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F0FF
        ora     SHRMEM+$1E4,x
        sta     SHRMEM+$1E4,x
        OP_EXIT

saucer_jmp_tbl:
				.word $0000
    		.word render_small_saucer-1
    		.word render_large_saucer-1

shifted_saucer_jmp_tbl:
				.word $0000
    		.word render_shifted_small_saucer-1
    		.word render_shifted_large_saucer-1

; $6
; $00=
dvg_saucer:
				HINT_IIGSMODE
				lda			(byte_B)							; status
				and			#$0003
				asl
				tax
				ldy			saucer_jmp_tbl,x
				lda     byte_4								; X (0-255)
				bit     #(1<<0)
				beq			:+
				ldy			shifted_saucer_jmp_tbl,x
:				phy
				ldx			$C2										; SHR offset
				rts

; $7
dvg_shot:
				HINT_IIGSMODE
				ldx			$C2										; SHR offset
				lda     byte_4								; X (0-255)
				bit     #(1<<0)
				bne			:+
				lda			#$F000
				bne			:++
:				lda			#$0F00
:				ora			SHRMEM,x
				sta			SHRMEM,x
				OP_EXIT

render_shrapnel_0:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$000F
        ora     SHRMEM+$504,x
        sta     SHRMEM+$504,x
        lda     #$000F
        ora     SHRMEM+$5A2,x
        sta     SHRMEM+$5A2,x
        lda     #$00F0
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        ldy     #$0F00
        tya
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        tya
        ora     SHRMEM+$004,x
        sta     SHRMEM+$004,x
        tya
        ora     SHRMEM+$460,x
        sta     SHRMEM+$460,x
        tya
        ora     SHRMEM+$464,x
        sta     SHRMEM+$464,x
        tya
        ora     SHRMEM+$5A4,x
        sta     SHRMEM+$5A4,x
        lda     #$F000
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
				OP_EXIT

render_shrapnel_1:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        tya
        ora     SHRMEM+$6E4,x
        sta     SHRMEM+$6E4,x
        tya
        ora     SHRMEM+$782,x
        sta     SHRMEM+$782,x
        lda     #$00F0
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        lda     #$00F0
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        lda     #$00F0
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
				OP_EXIT

render_shrapnel_2:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$000F
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        lda     #$000F
        ora     SHRMEM+$6E4,x
        sta     SHRMEM+$6E4,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        tya
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        tya
        ora     SHRMEM+$822,x
        sta     SHRMEM+$822,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$F000
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
				OP_EXIT

render_shrapnel_3:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$966,x
        sta     SHRMEM+$966,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        lda     #$0F00
        ora     SHRMEM+$3C6,x
        sta     SHRMEM+$3C6,x
        lda     #$F000
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
				OP_EXIT

render_shifted_shrapnel_0:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$1E6,x
        sta     SHRMEM+$1E6,x
        ldy     #$00F0
        tya
        ora     SHRMEM+$002,x
        sta     SHRMEM+$002,x
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        tya
        ora     SHRMEM+$466,x
        sta     SHRMEM+$466,x
        tya
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        lda     #$0F00
        ora     SHRMEM+$0A2,x
        sta     SHRMEM+$0A2,x
        lda     #$F000
        ora     SHRMEM+$282,x
        sta     SHRMEM+$282,x
        lda     #$F000
        ora     SHRMEM+$504,x
        sta     SHRMEM+$504,x
        lda     #$F000
        ora     SHRMEM+$5A2,x
        sta     SHRMEM+$5A2,x
				OP_EXIT

render_shifted_shrapnel_1:
        HINT_IIGSMODE
        lda     #$000F
        ora     SHRMEM+$0A6,x
        sta     SHRMEM+$0A6,x
        lda     #$000F
        ora     SHRMEM+$5A6,x
        sta     SHRMEM+$5A6,x
        lda     #$000F
        ora     SHRMEM+$786,x
        sta     SHRMEM+$786,x
        lda     #$0F00
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$0F00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$5A0,x
        sta     SHRMEM+$5A0,x
        ldy     #$F000
        tya
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        tya
        ora     SHRMEM+$6E4,x
        sta     SHRMEM+$6E4,x
        tya
        ora     SHRMEM+$782,x
        sta     SHRMEM+$782,x
				OP_EXIT

render_shifted_shrapnel_2:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        tya
        ora     SHRMEM+$646,x
        sta     SHRMEM+$646,x
        tya
        ora     SHRMEM+$822,x
        sta     SHRMEM+$822,x
        tya
        ora     SHRMEM+$826,x
        sta     SHRMEM+$826,x
        lda     #$0F00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        lda     #$0F00
        ora     SHRMEM+$326,x
        sta     SHRMEM+$326,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F000
        ora     SHRMEM+$640,x
        sta     SHRMEM+$640,x
        lda     #$F000
        ora     SHRMEM+$6E4,x
        sta     SHRMEM+$6E4,x
				OP_EXIT

render_shifted_shrapnel_3:
        HINT_IIGSMODE
        ldy     #$000F
        tya
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        tya
        ora     SHRMEM+$462,x
        sta     SHRMEM+$462,x
        tya
        ora     SHRMEM+$6E0,x
        sta     SHRMEM+$6E0,x
        tya
        ora     SHRMEM+$962,x
        sta     SHRMEM+$962,x
        lda     #$00F0
        ora     SHRMEM+$3C8,x
        sta     SHRMEM+$3C8,x
        lda     #$0F00
        ora     SHRMEM+$142,x
        sta     SHRMEM+$142,x
        ldy     #$F000
        tya
        ora     SHRMEM+$006,x
        sta     SHRMEM+$006,x
        tya
        ora     SHRMEM+$6E6,x
        sta     SHRMEM+$6E6,x
        tya
        ora     SHRMEM+$824,x
        sta     SHRMEM+$824,x
        tya
        ora     SHRMEM+$966,x
        sta     SHRMEM+$966,x
				OP_EXIT

shrapnel_jmp_tbl:
    		; 4 shrapnel patterns; large, medium, small
    		.word render_shrapnel_0-1
    		.word render_shrapnel_1-1
    		.word render_shrapnel_2-1, render_shrapnel_2-1
    		.word render_shrapnel_3-1, render_shrapnel_3-1

shifted_shrapnel_jmp_tbl:
    		; 4 shrapnel patterns; large, medium, small
    		.word render_shifted_shrapnel_0-1
    		.word render_shifted_shrapnel_1-1
    		.word render_shifted_shrapnel_2-1, render_shifted_shrapnel_2-1
    		.word render_shifted_shrapnel_3-1, render_shifted_shrapnel_3-1
        
; $8
dvg_shrapnel:
				; the original uses 6 global scale factors from $B-$0
				; and 4 patterns in this sequence
				; $B:2,6 $C:0,4,6 $D,$E,$F,$0:0,2,4,6
				; instead we'll just use global scale factor
				; $B=0, $C=1, $D,$E=2, $F,$0=3
				HINT_IIGSMODE
				lda			byte_8								; global scale
				bne			:+
				lda			#$0010
:				sec
				sbc			#$0B									; -> 0-5
				asl														; word offset into table
				tax
				ldy			shrapnel_jmp_tbl,x
				lda     byte_4								; X (0-255)
				bit     #(1<<0)
				beq     :+
				ldy     shifted_shrapnel_jmp_tbl,x
:       phy
				ldx     $C2                   ; current SHR offset
				rts                           ; render
        
; $9
dvg_explodingship:
				OP_EXIT

dvg_jmp_tbl:
				.word		dvg_cur-1
				.word		dvg_chr-1
				.word		dvg_life-1
				.word		dvg_copyright-1
				.word		dvg_asteroid-1
				.word		dvg_ship-1
				.word		dvg_saucer-1
				.word		dvg_shot-1
				.word		dvg_shrapnel-1
				.word		dvg_explodingship-1
				.word		dvg_invalid-1
				.word		dvg_invalid-1
				.word		dvg_invalid-1
				.word		dvg_invalid-1
				.word		dvg_scalebrightness-1
				.word		dvg_halt-1

handle_dvg_opcode:
				HINT_IIGSMODE
        xba
				lsr
				lsr
				lsr														; offset in jump table
				and     #$001E
				tax
				lda			dvg_jmp_tbl,x
				pha
				rts														; render
