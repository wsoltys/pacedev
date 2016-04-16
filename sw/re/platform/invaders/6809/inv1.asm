;
;	SPACE INVADERS
; - ported from the original arcade game
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

; *** BUILD OPTIONS
; *** end of BUILD OPTIONS

; *** derived - do not edit

.ifndef BUILD_OPT_INVALID
  .define GFX_1BPP
.else
  .define GFX_2BPP
.endif

; *** end of derived

; *** INVADERS stuff here
        .org    var_base
        
        .bndry  0x100
dp_base:            .ds     256        
z80_b               .equ    0x00
z80_c               .equ    0x01
z80_d               .equ    0x02
z80_e               .equ    0x03
z80_h               .equ    0x04
z80_l               .equ    0x05
z80_a_              .equ    0x06
z80_f_              .equ    0x07
z80_r               .equ    0x08

; rgb/composite video selected (bit 4)
cmp:                            .ds 1

				.org		0xc000

start_coco:
				orcc		#0x50										; disable interrupts
				lds			#stack

.ifdef PLATFORM_COCO3

; switch in 32KB cartridge
        lda     #COCO|MMUEN|MC3|MC1|MC0 ; 32KB internal ROM
        sta     INIT0
; setup MMU to copy ROM
        lda     #CODE_PG1
        ldx     #MMUTSK1                ; $0000-$7FFF
        ldb     #4
1$:     sta     ,x+
        inca
        decb
        bne     1$                      ; map pages $30-$33
; copy ROM into RAM        
        ldx     #0x8000                 ; start of 32KB ROM
        ldy     #0x0000                 ; destination
2$:     lda     ,x+
        sta     ,y+
        cmpx    #0xff00                 ; done?
        bne     2$                      ; no, loop
; setup MMU mapping for game
        lda     #CODE_PG1
        ldx     #MMUTSK1+4              ; $8000-$FFFF
        ldb     #4
4$:     sta     ,x+
        inca
        decb
        bne     4$                      ; map pages $30-33
        lda     #VRAM_PG
        ldx     #MMUTSK1                ; $0000-
        ldb     #4
5$:     sta     ,x+
        inca
        decb
        bne     5$                      ; map pages $38-$3B        
; switch to all-RAM mode
        sta     RAMMODE        

display_splash:

        ldx     #0x400
        lda     #96                     ; green space
1$:     sta     ,x+
        cmpx    #0x600
        bne     1$
        ldx     #splash
        ldy     #0x420
2$:     pshs    y
        ldb     ,x+                     ; read 'attr'
        stb     attr
        lda     ,x                      ; leading null?
        beq     5$
3$:     lda     ,x+
        beq     4$
        eora    attr
        sta     ,y+
        bra     3$
4$:     puls    y
        leay    32,y
        bra     2$
5$:     ldx			#PIA0
        ldb     #0                      ; flag rgb
6$:     lda     #~(1<<2)
				sta     2,x
				lda     ,x
				bita    #(1<<2)                 ; 'R'?
				beq     7$
        lda     #~(1<<3)
				sta			2,x											; column strobe
				lda			,x											; active low
				bita    #(1<<0)                 ; 'C'?
				bne     6$                      ; try again
				ldb     #(1<<4)                 ; flag component
7$:     stb     cmp

setup_gime_for_game:

; initialise PLATFORM_COCO3 hardware
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
				lda			#MMUEN|#FEN             ; enable GIME MMU, FIRQ
				sta			INIT0     							
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
				lda			#0x00										; no VBLANK IRQ
				sta			IRQENR    							
				lda			#TMR                    ; TMR FIRQ enabled
				sta			FIRQENR   							
				lda			#BP										  ; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
	  .ifdef GFX_1BPP				
				lda			#0x08										; 192 scanlines, 32 bytes/row, 2 colours (256x192)
	  .else				
				lda			#0x11										; 192 scanlines, 64 bytes/row, 4 colours (256x192)
	  .endif				
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
				lda			#(VRAM_PG<<2)           ; screen at page $38
				sta			VOFFMSB
				lda			#0x00
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							

				ldx			#PALETTE
				ldy     #rgb_pal
				ldb     #16
inipal:
				lda     ,y+
				sta     ,x+
				decb
				bne     inipal
				
				sta			CPU179									; select fast CPU clock (1.79MHz)

  ; configure timer
  ; free-run, max range, used for RND atm
        lda     #<4095
        sta     TMRLSB
        lda     #>4095
        sta     TMRMSB

  ; install FIRQ handler and enable TMR FIRQ
				;lda			#TMR|HBORD|VBORD        ; TMR FIRQ enabled
				;sta			FIRQENR   							
        lda     #0x7E                   ; jmp
        sta     0xFEF4
				ldx     #main_fisr              ; address
				stx     0xFEF5
        andcc   #~0x40                  ; enable FIRQ in CPU

  ; setup the PIAS for joystick sampling
  
  ; configure joystick axis selection as outputs
  ; and also select left/right joystick
        lda     PIA0+CRA
        ldb     PIA0+CRB
        ora     #(1<<5)|(1<<4)          ; CA2 as output
        orb     #(1<<5)|(1<<4)          ; CB2 as output
.ifdef LEFT_JOYSTICK
        orb     #(1<<3)                 ; CB2=1 left joystick
.else
        andb    #~(1<<3)                ; CB2=0 right joystick
.endif
        sta     PIA0+CRA
        stb     PIA0+CRB
  ; configure comparator as input
        lda     PIA0+CRA
        anda    #~(1<<2)                ; select DDRA
        sta     PIA0+CRA
        lda     PIA0+DDRA
        anda    #~(1<<7)                ; PA7 as input
        sta     PIA0+DDRA
        lda     PIA0+CRA
        ora     #(1<<2)                 ; select DATAA
        sta     PIA0+CRA
  ; configure sound register as outputs
        lda     PIA1+CRA
        anda    #~(1<<2)                ; select DDRA
        sta     PIA1+CRA
        lda     PIA1+DDRA
        ora     #0xfc                   ; PA[7..2] as output
        sta     PIA1+DDRA
        lda     PIA1+CRA
        ora     #(1<<2)                 ; select DATAA
        sta     PIA1+CRA
          
  .ifdef HAS_SOUND				
				lda			PIA1+CRB
				ora			#(1<<5)|(1<<4)					; set CB2 as output
				ora			#(1<<3)									; enable sound
				sta			PIA1+CRB
				; bit2 sets control/data register
				lda     PIA1+CRB
				anda    #~(1<<2)                ; select DDRB
				sta     PIA1+CRB
				lda     PIA1+DDRB
				ora     #(1<<1)                 ; PB1 output
				sta     PIA1+DDRB
        ; setup for data register				
				lda     PIA1+CRB
				ora     #(1<<2)                 ; select DATAB
				sta     PIA1+CRB
  .endif  ; HAS_SOUND

.endif	; PLATFORM_COCO3
			
				lda			#>dp_base
				tfr			a,dp
        jmp     start                   ; knight lore
        
rgb_pal:
    .db RGB_DARK_BLACK, RGB_DARK_BLUE, RGB_DARK_RED, RGB_DARK_MAGENTA
    .db RGB_DARK_GREEN, RGB_DARK_CYAN, RGB_DARK_YELLOW, RGB_GREY
    .db RGB_BLACK, RGB_BLUE, RGB_RED, RGB_MAGENTA
    .db RGB_GREEN, RGB_CYAN, RGB_YELLOW, RGB_WHITE
cmp_pal:    
    .db CMP_DARK_BLACK, CMP_DARK_BLUE, CMP_DARK_RED, CMP_DARK_MAGENTA
    .db CMP_DARK_GREEN, CMP_DARK_CYAN, CMP_DARK_YELLOW, CMP_GREY
    .db CMP_BLACK, CMP_BLUE, CMP_RED, CMP_MAGENTA
    .db CMP_GREEN, CMP_CYAN, CMP_YELLOW, CMP_WHITE


splash:
;       .asciz  "01234567890123456789012345678901"
        .db 0
        .asciz  "````ZX`SPECTRUM`KNIGHT`LORE"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "``````FOR`THE`TRSmxp`COCOs"
        .db 0
        .asciz  "`"
        .db 0
.ifdef BUILD_OPT_CPC_GRAPHICS
        .asciz  "````j`AMSTRAD`CPC`GRAPHICS`j"
.else        
  .ifdef BUILD_OPT_MICK_FARROW_GRAPHICS
        .asciz  "````j`MICK`FARROW`GRAPHICS`j"
  .else
        .asciz  "`````j`ORIGINAL`GRAPHICS`j"
  .endif
.endif
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "``hCOCOFEST`DEMO`VERSION`qnqi"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```````hRiGBohCiOMPOSITE"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0x40
        .asciz  "|WWWnRETROPORTSnBLOGSPOTnCOMnAU~"
        .dw     0


attr:   .ds     1
                
start:
        jmp     start

main_fisr:
; temp hack - should do LFSR or something
; and also tune frequency
        tst     FIRQENR                 ; ACK FIRQ
        inc     *z80_r
        rti

        .include "vram_dat.asm"

				.end		start_coco
