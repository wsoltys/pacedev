	cpu 68000

ram_start 					equ $100000
ram_end   					equ ram_start+$ffff
bootrom_start 			equ $ff0000
bootrom_end   			equ bootrom_start+$fff

leds								equ $001000

; NEOGEO/68K memory space
rom1_start          equ $000000
rom1_end            equ rom1_start+$fffff
buttons             equ $300000
reg_swpbios         equ $3a0003
reg_swprom          equ $3a0013
vramrw              equ $3c0002
bios_start          equ $c00000
bios_end            equ bios_start+$1ffff
magic               equ bootrom_start

; boot data (flash) memory space
boot_data           equ $e00000
bfix_image          equ boot_data           ; bios fixed layer (tile) data 128KiB
cfix_image          equ boot_data+$20000    ; cart fixed layer (tile) data 128KiB
bios_image          equ boot_data+$40000    ; bios program code 128KiB
rom1_image          equ boot_data+$60000    ; cart program code up to 1MiB

; bios routines
clear_fixed_layer		equ $c1835e

	org bootrom_start

reset_ssp	dc.l	$107fff
reset_pc  dc.l	start

	org bootrom_start+$400
	
start:
	nop

  move.b #1,d2              ; flag an error
  	
; set LED0
	move.w #$01, d0
	move.l #leds, a0
	move.w d0,(a0)

; ensure we're writing to BIOS vectors for the copy
  lea.l reg_swpbios,a0
  move.b d0,(a0)            ; any write

; copy system bios to s(d)ram
	lea.l bios_image,a0		    ; start of bios image in bootdata
	lea.l bios_start,a1		    ; start of bios (in s(d)ram)
cpybios:                    
	move.b (a0),d0				    ; 1st byte
	lsl.w #8,d0						    ; shift into next byte
	addq.l #1,a0              
	move.b (a0),d0				    ; 2nd byte
	addq.l #1,a0              
	move.w d0,(a1)				    ; write to bios area
	addq.l #2,a1              
	cmpi.l #bios_end+1,a1     ; done?
	bne cpybios						    ; no, loop

  ;bra skip_rom_cpy
                            
; ensure we're writing to ROM vectors for the copy
  lea.l reg_swprom,a0
  move.b d0,(a0)            ; any write

; copy rom1 to s(d)ram
	lea.l rom1_image,a0		    ; start of rom1 image in bootdata
	lea.l rom1_start,a1		    ; start of rom1 (in sdram)
cpyrom1:                    
	move.b (a0),d0				    ; 1st byte
	lsl.w #8,d0						    ; shift into next byte
	addq.l #1,a0              
	move.b (a0),d0				    ; 2nd byte
	addq.l #1,a0              
	move.w d0,(a1)				    ; write to rom1 area
	addq.l #2,a1              
	cmpi.l #rom1_end+1,a1	    ; done? *** change me
	bne cpyrom1						    ; no, loop

skip_rom_cpy:

; verify contents of s(d)ram
	lea.l bios_image,a0		    ; start of bios image in bootdata
	lea.l bios_start,a1		    ; start of bios (in s(d)ram)
vfybios:                    
	move.b (a0),d0				    ; 1st byte
	lsl.w #8,d0						    ; shift into next byte
	addq.l #1,a0              
	move.b (a0),d0				    ; 2nd byte
	addq.l #1,a0              
  move.w (a1),d1            ; get from s(d)ram
  cmp.w d0,d1               
  bne vfydone               ; no good
	addq.l #2,a1              
	cmpi.l #bios_end+1,a1	    ; done?
	bne vfybios						    ; no, loop

  ;bra skip_rom_vfy

	lea.l rom1_image+$80,a0		; start of rom1 image in bootdata (skip vectors)
	lea.l rom1_start+$80,a1		; start of rom1 (in s(d)ram)
vfyrom1:                    
	move.b (a0),d0				    ; 1st byte
	lsl.w #8,d0						    ; shift into next byte
	addq.l #1,a0              
	move.b (a0),d0				    ; 2nd byte
	addq.l #1,a0              
  move.w (a1),d1            ; get from s(d)ram
  cmp.w d0,d1               
  bne vfydone               ; no good
	addq.l #2,a1              
	cmpi.l #rom1_end+1,a1	    ; done?
	bne vfyrom1						    ; no, loop

skip_rom_vfy:
                            
  move.b #0,d2              ; flag OK
  
vfydone:  
; swap out the bootdata and restore tile data
	lea.l magic,a0		        ; magic register
	move.b #$2,(a0)				    ; *bang*
                            
  cmpi.b #0,d2	
  bne skipclr;
    
; clear screen and display banner
	jsr clear_fixed_layer

skipclr:
	lea.l s_banner,a0
	move.w #$7020,d0
	jsr prints

	lea.l s_bios,a0
	move.w #$7022,d0
	jsr prints

  cmpi.b #0, d2         ; check error flag
  bne vfyerr;

	lea.l s_vfybios,a0
	move.w #$7023,d0
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
	move.w #$7024,d0
	jsr prints

	lea.l s_rom1,a0
	move.w #$7025,d0
	jsr prints

	lea.l s_vfyrom1,a0
	move.w #$7026,d0
	jsr prints

	lea.l s_abcd,a0
	move.w #$7028,d0
	jsr prints

wait_abcd:
  move.w (buttons).l,d0
  not d0
  and.w #$f000,d0
  beq wait_abcd;

	lea.l s_boot,a0
	move.w #$7029,d0
	jsr prints

; ensure we're writing to BIOS vectors for the copy
  lea.l reg_swpbios,a0
  move.b d0,(a0)            ; any write

; boot the neogeo
	lea.l magic,a0		    ; magic register
	move.b #$1,(a0)				; *bang*

hang:
	bra hang

vfyerr:
	lea.l s_vfyerr,a0
	move.w #$7023,d0
	jsr prints
  bra hang
  
; a0 = pointer to null-terminated string
; d0 = vram address
prints:
	lea.l vramrw,a1			  ; vramrw
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
s_banner	dc.b	"P.A.C.E. NEOGEO Boot ROM v0.4"
					dc.b	0
s_bios	  dc.b	"System BIOS copied"
					dc.b	0
s_vfybios	dc.b	"System BIOS verified"
					dc.b	0
s_vfyerr	dc.b	"BIOS/ROM1 verify error!"
					dc.b	0
s_patch	  dc.b	"System BIOS patched"
					dc.b	0
s_rom1	  dc.b	"Cart ROM1 copied"
					dc.b	0
s_vfyrom1	dc.b	"Cart ROM1 verified"
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
	