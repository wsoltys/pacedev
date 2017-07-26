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

.export dvg_chr
.export dvg_life
.export dvg_copyright
.export dvg_asteroid
.export dvg_ship
.export dvg_saucer
.export dvg_shot
.export dvg_shrapnel
.export dvg_explodingship

; $1
dvg_chr:
        lda     (byte_B),y            ; chr x2
				IIGSMODE
				and			#$00FF
				tax
				ldy			chr_tbl,x
render_7x2:				
				lda			#7										; 7 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda			0,y
        beq     :+
				ora			SHRMEM,x
				sta			SHRMEM,x							; 1st half of line
:				lda			2,y
        beq     :+
				ora			SHRMEM+2,x
				sta			SHRMEM+2,x						; 2nd half of line
:				iny
				iny
				iny
				iny
				clc
				txa
				adc			#160									; ptr next line
				tax
				dec			$C4										; line counter
				bne			:---
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				IIMODE
				OP_EXIT

; $2
dvg_life:
				IIGSMODE
				; offset Y because it overwrites score
				lda			$C2										; SHR offset
				cmp			#($1360+160)
				bcs			:+
				clc
				adc			#(160*4)
				sta			$C2										; new SHR offset
.ifndef BUILD_OPT_COMPILED_SPRITES				
:				ldy			#extra_ship
				jmp     render_7x2
.else
:				ldx			$C2										; SHR offset
        lda     #$00F0
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
        lda     #$00F0
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$00F0
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
        lda     #$0F0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
        lda     #$0F0F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
        lda     #$0F0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
        lda     #$F000
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
        lda     #$FFFF
        sta     SHRMEM+$320,x
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				IIMODE
				OP_EXIT
.endif				

; $3
dvg_copyright:
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
.ifndef BUILD_OPT_COMPILED_SPRITES				
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
.else				
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
.endif        
				IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
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
        IIMODE
        OP_EXIT

asteroid_jmp_tbl:
    		; 4 asteroid patterns; large, medium, small
    		.word render_asteroid_0-1,  render_asteroid_1-1,  render_asteroid_2-1
    		.word render_asteroid_3-1,  render_asteroid_4-1,  render_asteroid_5-1
    		.word render_asteroid_6-1,  render_asteroid_7-1,  render_asteroid_8-1
    		.word render_asteroid_9-1,  render_asteroid_10-1, render_asteroid_11-1

shifted_asteroid_jmp_tbl:
    		; 4 asteroid patterns; large, medium, small
    		.word render_shifted_asteroid_0-1,  render_shifted_asteroid_1-1,  render_shifted_asteroid_2-1
    		.word render_shifted_asteroid_3-1,  render_shifted_asteroid_4-1,  render_shifted_asteroid_5-1
    		.word render_shifted_asteroid_6-1,  render_shifted_asteroid_7-1,  render_shifted_asteroid_8-1
    		.word render_shifted_asteroid_9-1,  render_shifted_asteroid_10-1, render_shifted_asteroid_11-1

; $4
; $00(2:1)=shape(0-3)
dvg_asteroid:
        lda     (byte_B),y
				IIGSMODE
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
.ifndef BUILD_OPT_COMPILED_SPRITES
:				ldy			asteroid_tbl,x
				lda			$09										; X (0-255)
				bit			#1
				beq			render_16x4
				ldy			shifted_asteroid_tbl,x
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
				lda			8,y
				ora			SHRMEM+8,x
				sta			SHRMEM+8,x							; 5th qtr of line
				tya
				clc
				adc			#10
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
				OP_EXIT
.else
        HINT_IIGSMODE
:				ldy			asteroid_jmp_tbl,x
				lda     $09
				bit     #1
				beq     :+
				ldy     shifted_asteroid_jmp_tbl,x
:       phy
				ldx     $C2
				rts
.endif				
                        
; $5
; $00=dir(0-255)
dvg_ship:
				IIGSMODE
				lda			(byte_B),y            ; direction
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
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			shifted_ship_tbl,x
:				jmp			render_7x2
				HINT_IIMODE

; $6
; $00=
dvg_saucer:
				OP_EXIT
				IIGSMODE
				lda			(byte_B),y						; status
; fixme								
				ldy			#large_saucer
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			#shifted_large_saucer
:				;jmp			render_16x4
				HINT_IIMODE

; $7
dvg_shot:
				IIGSMODE
				ldx			$C2										; SHR offset
				lda			$09										; X (0-255)
				bit			#1
				bne			:+
				lda			#$F000
				bne			:++
:				lda			#$0F00
:				ora			SHRMEM,x
				sta			SHRMEM,x
				IIMODE
				OP_EXIT
        
; $8
dvg_shrapnel:
				OP_EXIT
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
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			shifted_shrapnel_tbl,x
:				;jmp			render_16x4
				HINT_IIMODE
        
; $9
dvg_explodingship:
				OP_EXIT

