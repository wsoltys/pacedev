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
;	.byte	$00, $F0, $00, $00
        lda     #$F000
        ora     SHRMEM+$000,x
        sta     SHRMEM+$000,x
;	.byte $00, $F0, $00, $00
        lda     #$F000
        ora     SHRMEM+$0A0,x
        sta     SHRMEM+$0A0,x
;	.byte $0F, $0F, $00, $00		
        lda     #$0F0F
        ora     SHRMEM+$140,x
        sta     SHRMEM+$140,x
;	.byte $0F, $0F, $00, $00		
        lda     #$0F0F
        ora     SHRMEM+$1E0,x
        sta     SHRMEM+$1E0,x
;	.byte $0F, $0F, $00, $00		
        lda     #$0F0F
        ora     SHRMEM+$280,x
        sta     SHRMEM+$280,x
;	.byte $FF, $FF, $F0, $00
        lda     #$FFFF
        ora     SHRMEM+$320,x
        sta     SHRMEM+$320,x
        lda     #$00F0
        ora     SHRMEM+$322,x
        sta     SHRMEM+$322,x
;	.byte $F0, $00, $F0, $00
        lda     #$00F0
        ora     SHRMEM+$3C0,x
        sta     SHRMEM+$3C0,x
        lda     #$00F0
        ora     SHRMEM+$3C2,x
        sta     SHRMEM+$3C2,x
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
				IIMODE
				OP_EXIT

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
				IIGSMODE
				lda			(byte_B),y						; status
; fixme								
				ldy			#large_saucer
				lda			$09										; X (0-255)
				bit			#1
				beq			:+
				ldy			#shifted_large_saucer
:				jmp			render_16x4
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
:				jmp			render_16x4
				HINT_IIMODE
        
; $9
dvg_explodingship:
				OP_EXIT

