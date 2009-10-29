        .title  Carte Blanche ROM Loader Firmware

        ; constants
        start = 0x0100
        ram = 0x800
        nmi = 0x0066
        vram = 0x3c00
        guest_rom = 0x4000
        sram = 0x8000
        
        .area   main (ABS)

        ;*
        ;*      main routine
        ;*

        .org    0x0000

        di
        jp      start

        .org    nmi

        retn

        .org    start-#0x08
loop:   jr      loop

        .org    start
        
        ld      sp,#ram+0x7FE
        
        call	  cls
                
        ld      hl,#title
        ld      de,#vram
        call    print_string    

        ;* show the rom name
        ld      hl,#0x1008
        ld      de,#vram+0x80
        ld      c,#8
l1:     ld      a,(hl)
        ld      (de),a
        inc     hl
        inc     de
        dec     c
        jr      NZ,l1
                        
        ld      hl,#cpymsg
        ld      de,#vram+0x100
        call    print_string

        ;* copy ROM to SRAM
        ld      hl,#guest_rom
        ld      de,#sram
        ld      bc,#0x4000
        ldir

        ld      hl,#vfymsg
        ld      de,#vram+0x140
        call    print_string

        ;* verify ROM data
        ld      hl,#guest_rom
        ld      de,#sram
        ld      bc,#0x4000
vfyloop:
        ld      a,(de)
        cp      (hl)
        jr      NZ,vfyfail
        inc     hl
        inc     de
        dec     bc
        ld      a,b
        or      c
        jr      NZ,vfyloop
        jr      vfyok

vfyfail:
        ld      hl,#vfmsg
        ld      de,#vram+0x180
        call    print_string
        jp      loop

vfyok:  ld      hl,#vokmsg
        ld      de,#vram+0x180
        call    print_string

        ld      hl,#bitmsg
        ld      de,#vram+0x200
        call    print_string
        
        jp      loop

        ;*
        ;*      routines
        ;*

		; print a null-terminated ascii string
		; hl = source
		; de = dest
print_string:
		ld		a,(hl)			; get char
		inc		hl
		or		a				    ; done?
		ret		Z				    ; yes, return
		ld		(de),a
		inc   de
		jr		print_string
		
        ; display a byte in hex
        ; C  = byte
        ; DE = destination
show_hex:
        push    bc
        ld      a,c
        ld      b,#4
        srl     a               
        srl     a               
        srl     a               
        srl     a               ; shift hi nibble down
        call    sh_1            ; get hi nibble digit
        ld      a,c
        and     #0x0f           ; mask lo nibble
        call    sh_1            ; get lo nibble digit
        pop     bc
        ret
sh_1:   exx
        ld      hl,#hex_dig     ; ptr digits
        ld      b,#0
        ld      c,a             
        add     hl,bc           ; add nibble offset
        ld      a,(hl)          ; get ascii digit
        exx
        ld      (de),a          ; store in ram
        ld		a,e
        sub		#0x20
        ld		e,a
        ret		NC
        dec		d
        ret
hex_dig:
		.db		#0x00, #0x01, #0x02, #0x03, #0x04, #0x05, #0x06, #0x07
		.db		#0x08, #0x09, #0x11, #0x12, #0x13, #0x14, #0x15, #0x16

cls:
        ld      hl,#vram
        ld      de,#vram+1
        ld      bc,#0x0400
        ld      (hl),#0x20
        ldir
        ret
title:
        .ascii  /Carte Blanche ROM Loader v0.1/
		    .db		#0
cpymsg:
        .ascii  /Copying ROM to SRAM/
		    .db		#0
vfymsg:
        .ascii  /Verifying ROM data/
		    .db		#0
vfmsg:
        .ascii  /ROM data verify failed!/
		    .db		#0
vokmsg:
        .ascii  /ROM data verified!/
		    .db		#0
bitmsg:
        .ascii  /Now program the FPGA with the game bitstream.../
		    .db		#0
