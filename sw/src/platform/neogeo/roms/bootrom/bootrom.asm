	cpu 68000

ram_start 					equ $100000
ram_end   					equ $10ffff
rom_start 					equ $f00000
rom_end   					equ $f00fff
          					
leds								equ $001000

; bios routines
clear_fixed_layer		equ $c1835e

	org $f00000

reset_ssp	dc.l	$107fff
reset_pc  dc.l	start
	
	org $f00400
	
start:
	nop
	
; set LED0
	move.w #$01, d0
	move.l #leds, a0
	move.w d0,(a0)

; copy system bios to sram
	lea.l $e20000,a0			; start of bios image in bootdata
	lea.l $c00000,a1			; start of bios (in sram)
cpybios:
	move.b (a0),d0				; 1st byte
	lsl.w #8,d0						; shift into next byte
	addq.l #1,a0
	move.b (a0),d0				; 2nd byte
	addq.l #1,a0
	rol.w #8,d0						; byte swap
	move.w d0,(a1)				; write to bios area
	addq.l #2,a1
	cmpi.l #$c20000,a1		; done?
	bne cpybios						; no, loop

; clear screen and display banner
	jsr clear_fixed_layer
	lea.l s_banner,a0
	move.w #$7020,d0
	jsr prints						; print banner

; swap out the bootdata and restore tile data
	lea.l $f00000,a0			; magic register
	move.l #$1,(a0)				; *bang*
done:
	bra done

; a0 = pointer to null-terminated string
; d0 = vram address
prints:
	lea.l $3c0002,a1			; vramrw
	move.w d0,-2(a1)			; vramad
	move.w #$0020,2(a1)		; vraminc=32 (1 col)
	clr.w d0
	move.b (a0)+,d0
prints_loop:
	move.w d0,(a1)				; display char
	move.b (a0)+,d0				; get next char
	cmpi.b #$00,d0				; done?
	bne prints_loop				; no, loop
	rts

; string table
s_banner	dc.b	"P.A.C.E. NEOGEO Boot ROM v0.1"
					dc.b	0

; write/read burched sram
	move.l #$d00100,a0
	move.w #$1234,d0
	move.w d0,(a0)
	move.w (a0),d0

	