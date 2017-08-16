				.list		(meb)										; macro expansion binary
       	.area   code (REL, CON)
				.module coco3
				
.include "coco3.inc"

.globl	dp_base
.globl	asteroids

; *** BUILD OPTIONS
.define BUILD_OPT_NO_SPLASH
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

osd_init::
				orcc		#0x50										; disable interrupts
				lds			#stack

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

; check for PAL/NTSC GIME
				lda			#0x3f										; ECB ROM $E000-
				ldx			#MMUTSK1
				sta			,x
				ldb			0x0033									; read BASIC video register mirror
				lda			#VRAM_PG
				sta			,x											; restore page
				stb			pal_detected

display_splash:
				lda			#0x01										; 32 CPL
				sta			VRES
        ldx     #0x400
        lda     #0x60                   ; green space
        eora		#0x40										; inverse (black space)
1$:     sta     ,x+
        cmpx    #0x600
        bne     1$
        ldx     #splash
        ldy     #0x420
				jsr			display_lines
				lda			pal_detected
				ldx			#ntsc_splash
				bita		#8											; pal?
				beq			2$											; no, skip
				ldx			#pal_splash
2$:			ldy			#0x540
   			jsr			display_lines
				ldx			#PIA0

splash_get_key:
				clr			cmp											; flag RGB
2$:			ldb			pal_detected
				lda			#~(1<<2)								; col=2
				bitb		#8											; PAL?
				beq			3$											; no, skip
				clra														; all columns
3$:			sta     2,x											; column strobe
				lda     ,x
				coma														; active high
				bitb		#8											; pal?
				beq			4$											; no, skip
				tsta														; any key hit?
.ifndef BUILD_OPT_NO_SPLASH				
				beq			2$											; no, loop
.endif				
				bra			setup_gime_for_game
4$:			bita    #(1<<2)                 ; 'R'?
				bne     5$											; yes, default, exit
        lda     #~(1<<3)								; col=3
				sta			2,x											; column strobe
				lda			,x											; active low
				bita    #(1<<0)                 ; 'C'?
				bne     2$                      ; try again
				ldb     #(1<<4)                 ; flag component
				stb     cmp
5$:     bra			setup_gime_for_game
        
display_lines:        
1$:     ldb     ,x+                     ; read 'attr'
        stb     attr
        lda     ,x                      ; leading null?
        beq     9$
				pshs    y
2$:     lda     ,x+
        beq     3$
        eora    attr
        eora		#0x40										; invert
        sta     ,y+
        bra     2$
3$:     puls    y
        leay    32,y
        bra     1$
9$:			rts
				
setup_gime_for_game:

; need DP for the FISR				
				lda			#>dp_base
				tfr			a,dp

; initialise PLATFORM_COCO3 hardware
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
				lda			FIRQENR									; ACK any pending GIME fast interrupt
		.ifdef BUILD_OPT_PROFILE
				lda			#MMUEN|#IEN|#FEN        ; enable GIME MMU, IRQ, FIRQ
		.else				
				;lda			#MMUEN|#FEN             ; enable GIME MMU, FIRQ
				lda			#MMUEN             			; enable GIME MMU
		.endif
				sta			INIT0     							
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
		.ifdef BUILD_OPT_PROFILE
				lda			#VBORD
		.else				
				lda			#0x00										; no VBLANK IRQ
		.endif
				sta			IRQENR    							
				lda			#TMR                    ; TMR FIRQ enabled
				;sta			FIRQENR   							
				lda			#BP										  ; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
				lda			#0x08										; 192 scanlines, 32 bytes/row, 2 colours (256x192)
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
  ; free-run, ~1/20s, used for RND (LFSR) atm
        lda     #<785
        sta     TMRLSB
        lda     #>785
        sta     TMRMSB

.ifdef BUILD_OPT_PROFILE
  ; install IRQ handler and enable CPU IRQ
				lda			IRQENR									; ACK any pending IRQ in the GIME
        lda     #0x7E                   ; jmp
        sta     0xFEF7
        ldx     #main_isr
        stx     0xFEF8
        clr			*vbl_cnt
        andcc   #~(1<<4)                ; enable IRQ in CPU    
.endif

; install FIRQ handler and enable TMR FIRQ
				;lda			#TMR|HBORD|VBORD        ; TMR FIRQ enabled
				;sta			FIRQENR   							
				lda			FIRQENR									; ACK any pending FIRQ in the GIME
        lda     #0x7E                   ; jmp
        sta     0xFEF4
				;ldx     #prng_fisr              ; address
				;stx     0xFEF5
        ;andcc   #~(1<<6)                ; enable FIRQ in CPU

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
		.ifdef USE_1BIT_SOUND
				anda		~#(1<<3)								; mute (other) sound
		.else
				ora			#(1<<3)									; enable (DAC) sound
		.endif
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

        jmp     asteroids
        
splash:
;       .asciz  "01234567890123456789012345678901"
        .db 0
        .asciz  "````ARCADE`ASTEROIDS`hREVri"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "``````FOR`THE`TRSmxp`COCOs"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```GRAPHICS`BY`NORBERT`KEHRER"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```hPREmRELEASE`VERSION`pnqi"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0x40
        .asciz  "|WWWnRETROPORTSnBLOGSPOTnCOMnAU~"
        .dw     0

ntsc_splash:
        .db 0
;        .asciz  "`````````NTSC`DETECTED"
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```````hRiGBohCiOMPOSITE"
        .dw     0

pal_splash:
        .db 0
;        .asciz  "``````PAL`MACHINE`DETECTED"
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```````m`PRESS`ANY`KEY`m"
        .dw     0

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

pal_detected:
				.ds			1
; rgb/composite video selected (bit 4)
cmp:    .ds 1
attr:   .ds     1

.globl	coinage
.globl	rightCoinMultiplier
.globl	centerCoinMultiplierAndLives
.globl	language

osd_reset::
				lda			#0x02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				rts
				
osd_start::
				rts
								
osd_render_frame::
				orcc		#0x50										; disable interrupts
				rts
