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
	;rol.w #8,d0						; byte swap
	move.w d0,(a1)				; write to bios area
	addq.l #2,a1
	cmpi.l #$c20000,a1		; done?
	bne cpybios						; no, loop

; swap out the bootdata and restore tile data
	lea.l $f00000,a0			; magic register
	move.b #$2,(a0)				; *bang*

; clear screen and display banner
	jsr clear_fixed_layer
	lea.l s_banner,a0
	move.w #$7020,d0
	jsr prints

	lea.l s_bios,a0
	move.w #$7022,d0
	jsr prints

  ; patches to get it to run atm
  move.l #$4e714e71,d0    ; nop,nop
  move.l d0,($c11b28).l   ; test palbank0
  move.l d0,($c11b3a).l   ; test palbank1
  move.l d0,($c11b58).l   ; test vram (1st part)
  move.l d0,($c11b66).l   ; test vram (2nd part)
  ;move.l d0,($c11be0).l   ; wait for time pulse
  ;move.l d0,($c11bf6).l   ; wait for time pulse
  ;move.l d0,($c11c14).l   ; calendar test
  ;move.l d0,($c11c1c).l   ; calendar test
  move.l d0,($c11c62).l   ; system rom error
  ;move.w d0,($c1871a).l   ; wait for vblank
  move.w #$600c,d0        ; bra...
  move.w d0,($c12030).l   ; z80 error

	lea.l s_patch,a0
	move.w #$7023,d0
	jsr prints

	lea.l s_abcd,a0
	move.w #$7025,d0
	jsr prints

wait_abcd:
  move.w ($300000).l,d0
  not d0
  and.w #$f000,d0
  beq wait_abcd;

	lea.l s_boot,a0
	move.w #$7026,d0
	jsr prints

; boot the neogeo
	lea.l $f00000,a0			; magic register
	move.b #$1,(a0)				; *bang*

hang:
	bra hang

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
s_bios	  dc.b	"System BIOS copied"
					dc.b	0
s_patch	  dc.b	"System BIOS patched"
					dc.b	0
s_abcd    dc.b	"Press A/B/C/D to boot NEOGEO"
					dc.b	0
s_boot    dc.b  "Booting NEOGEO..."
          dc.b  0

; write/read burched sram
	move.l #$d00100,a0
	move.w #$1234,d0
	move.w d0,(a0)
	move.w (a0),d0

	