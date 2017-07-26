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

.export erase_chr
.export erase_life
.export erase_asteroid
.export erase_ship
.export erase_saucer
.export erase_shot
.export erase_shrapnel
.export erase_explodingship
.export erase_invalid

erase_chr:
erase_7x2:				
				IIGSMODE
.ifndef BUILD_OPT_COMPILED_SPRITES
				lda			#7										; 7 lines
				sta			$C4
				ldx			$C2										; SHR offset
:				lda     #0
				sta			SHRMEM,x							; 1st half of line
				sta			SHRMEM+2,x						; 2nd half of line
				clc
				txa
				adc			#160									; ptr next line
				tax
				dec			$C4										; line counter
				bne			:-
.else
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
.endif
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
				IIMODE
				OP_EXIT

erase_life:
				IIGSMODE
				; offset Y because it overwrites score
				lda			$C2										; SHR offset
				cmp			#($1360+160)
				bcs			:+
				clc
				adc			#(160*4)
				sta			$C2										; new SHR offset
.ifndef BUILD_OPT_COMPILED_SPRITES				
				ldy			#extra_ship
:				jmp     erase_7x2
.else
:       ldx     $C2                   ; SHR offset
        lda     #0
        sta     SHRMEM+$322,x
        sta     SHRMEM+$3C0,x
        sta     SHRMEM+$3C2,x
        sta     SHRMEM+$140,x
        sta     SHRMEM+$1E0,x
        sta     SHRMEM+$280,x
        sta     SHRMEM+$000,x
        sta     SHRMEM+$0A0,x
        sta     SHRMEM+$320,x
				; update CUR
				inc			$C2
				inc			$C2
				inc			$C2
.endif
				IIMODE
				OP_EXIT

erase_asteroid:
erase_16x4:
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
				IIMODE
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
        IIMODE
        OP_EXIT
        
erase_saucer:
        jmp     erase_16x4

erase_shot:
				IIGSMODE
				ldx			$C2										; SHR offset
				lda			#0
				sta			SHRMEM,x
				IIMODE
				OP_EXIT

erase_shrapnel:
				jmp     erase_16x4

erase_explodingship:
        OP_EXIT
                        
erase_invalid:
        OP_EXIT
