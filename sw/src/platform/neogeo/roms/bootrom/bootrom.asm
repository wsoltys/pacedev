	cpu 68000

ram_start equ $d00000
ram_end   equ $d0ffff
rom_start equ $f00000
rom_end   equ $f00fff

leds			equ $001000

	org $f00000

reset_ssp	dc.l	$d07fff
reset_pc  dc.l	start
	
	org $f00400
	
start:
	nop
	
; write to the leds
	move.w #$aa, d0
	move.l #leds, a0
	move.w d0,(a0)

; write/read burched sram
	move.l #$d00100,a0
	move.w #$1234,d0
	move.w d0,(a0)
	move.w (a0),d0

; write to the video ram
	move.l #$3c0000,a0
	move.w #$7020,(a0)		; vramad
	move.l #$3c0004,a0
	move.w #$0020,(a0)		; inc=32 (1 col)
	move.l #$3c0002,a0
	move.w #$4800,(a0)
	move.w #$4900,(a0)
	move.w #$2000,(a0)
	move.w #$4300,(a0)
	move.w #$4800,(a0)
	move.w #$5200,(a0)
	move.w #$4900,(a0)
	move.w #$5300,(a0)

done:
	bra done

	