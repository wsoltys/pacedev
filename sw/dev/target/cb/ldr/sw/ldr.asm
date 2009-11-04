        .title  Carte Blanche ROM Loader Firmware

        ; constants
        start = 0x0100
        ram = 0x800
        nmi = 0x0066
        vram = 0x3c00
        guest_rom = 0x4000
        sram = 0x8000

        ; variables
        r_rty = #ram
        w_rty = #ram+1
        rback = #ram+2
                        
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

        ld      a,#3
        ld      (w_rty),a
cpystart:
        ld      a,#9
        ld      (r_rty),a

        ;* copy ROM to SRAM
        ld      hl,#guest_rom
        ld      de,#sram
        ld      bc,#0x4000
        ldir

vfystart:
        ld      hl,#vfymsg
        ld      de,#vram+0x140
        call    print_string

        ;* show the read,write retry count
        ld      a,(r_rty)
        ld      b,a
        ld      a,#0x0A
        sub     a,b
        add     a,#0x30
        ld      (#vram+0x140+20),a
        ld      a,(w_rty)
        ld      b,a
        ld      a,#0x04
        sub     a,b
        add     a,#0x30
        ld      (#vram+0x140+22),a

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

vfyok:  ld      hl,#vokmsg
        ld      de,#vram+0x180
        call    print_string

        ld      hl,#bitmsg
        ld      de,#vram+0x200
        call    print_string
        
        jp      loop

vfyfail:
        ld      (rback),a         ; save read-back value
        ld      a,(r_rty)
        dec     a
        ld      (r_rty),a
        jr      NZ,vfystart
        ld      a,(w_rty)
        dec     a
        ld      (w_rty),a
        jr      NZ,cpystart

        exx
        ld      hl,#vfmsg
        ld      de,#vram+0x180
        call    print_string
        exx        

        push    hl                ; rom address        
        push    de                ; sram address
        ld      c,d
        ld      de,#vram+0x180+25
        call    show_hex          ; address high byte
        pop     bc
        call    show_hex          ; address low byte
        pop     hl                ; rom address
        ld      c,(hl)
        inc     de
        inc     de
        call    show_hex          ; rom value
        ld      a,(rback)
        ld      c,a
        inc     de                
        inc     de                
        inc     de                
        call    show_hex          ; sram read-back value
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
        inc     de              ; next character position
        ret
hex_dig:
		.db		#0x30, #0x31, #0x32, #0x33, #0x34, #0x35, #0x36, #0x37
		.db		#0x38, #0x39, #0x41, #0x42, #0x43, #0x44, #0x45, #0x46

cls:
        ld      hl,#vram
        ld      de,#vram+1
        ld      bc,#0x0400
        ld      (hl),#0x20
        ldir
        ret

title:
        .ascii  /Carte Blanche ROM Loader v0.2/
		    .db		#0
cpymsg:
        .ascii  /Copying ROM to SRAM/
		    .db		#0
vfymsg:
        .ascii  /Verifying ROM data (0/
        .db   #0x2F
        .ascii  /0).../
		    .db		#0
		    .db		#0
vfmsg:
        .ascii  /ROM data verify failed @$0000,$00!=$00/
		    .db		#0
vokmsg:
        .ascii  /ROM data verified OK!/
		    .db		#0
bitmsg:
        .ascii  /Now program the FPGA with the game bitstream.../
		    .db		#0
