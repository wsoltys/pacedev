				.list		(meb)										; macro expansion binary
       	.area   code (ABS, CON)
				.module coco3
				
.include "coco3.inc"

.globl	dp_base
.globl	asteroids
.globl	freq3kHz
.globl	halt
.globl	hyperspaceSwitch
.globl	FireSwitch
.globl	diagStep
.globl	slamSwitch
.globl	selfTest
.globl	leftCoinSwitch
.globl	centerCoinSwitch
.globl	rightCoinSwitch
.globl	p1StartSwitch
.globl	p2StartSwitch
.globl	thrustSwitch
.globl	rotateRightSwitch
.globl	rotateLeftSwitch

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
    .db CMP_DARK_BLACK, CMP_WHITE
    
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

; table of shifted values (2 bytes)
; - 1st run seeds low values
        ldb     #0
        clr     *0x03
2$:     lda     *0x03
        ldx     #shift_tbl+0x80
        sta     a,x
        leax    0x100,x
        clr     a,x
        inc     *0x03
        decb
        bne     2$
; next 7 runs shift the previous entries
        ldb     #7
        ldu     #shift_tbl+0x80
3$:     pshs    b
        ldb     #0
        clr     *0x03
4$:     pshs    b
        lda     *0x03
        tfr     u,x                     ; base for this shift
        ldb     a,x                     ; byte #1
        pshs    b
        leax    0x100,x
        ldb     a,x                     ; byte #2
        puls    a
        lsra
        rorb
        pshs    d                       ; b then a
        lda     *0x03
        leax    0x100,x
        puls    b
        stb     a,x                     ; byte #1 shifted
        leax    0x100,x
        puls    b
        stb     a,x                     ; byte #2 shifted
        inc     *0x03
        puls    b
        decb
        bne     4$
        leau    0x200,u                 ; base for next shift
        puls    b
        decb
        bne     3$

				lda			#0
				sta			leftCoinSwitch
				sta			centerCoinSwitch
				sta			rightCoinSwitch
				sta			p1StartSwitch
				sta			p2StartSwitch
				sta			thrustSwitch
				sta			rotateRightSwitch
				sta			rotateLeftSwitch

				lda			#0x02									; 1 coin, 1 credit
				sta			coinage								; dipswitch
				lda			#(1<<0)								; 3 lives
				sta			centerCoinMultiplierAndLives
				rts
				
osd_start::
				; clear the graphics screen
				lda			#0
				ldx			#coco_vram
1$:			sta			,x+
				cmpx		#VIDEO_SIZ
				bne			1$
				rts

dvg_cur:
				ldd			,y											; D = CUR Y (0-1023) (10 bits)
				lsra														
				rorb
				addd		,y++										; Y+Y/2 (11 bits)
				lsra
				rorb
				lsra
				rorb
				lsra
				rorb														; B = CUR Y (0-192) (8 bits)
				stb			*0x06
				ldb			#191
				subb		*0x06
				stb			*0x06										; store non-inverted Y
				; find address of line
				tfr			b,a
				clrb
				lsra
				rorb
				lsra
				rorb
				lsra
				rorb
				std			*0xC0
				; scale X
				ldd			,y++										; global scale, CUR X (0-1023) (10 bits)
				lsra
				rorb
				lsra
				rorb
				stb			*0x04										; CUR X (0-255)
				andb		#0x07
				stb			*0x05										; pixel offset (0-7)
				lsra
				lsra
				sta			*0x08										; global scale
				; find address of CUR (&line+x/8)
				ldx			*0xC0
				ldb			*0x04										; CUR X (0-255)
				lsrb
				lsrb
				lsrb
				abx
				stx			*0xC2
				sty			*0x0B										; update dvgram address
				CLC
				rts

char_SPACE:
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000

char_0:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000

char_1:
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000

char_2:
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%11111000
    .byte $%10000000
    .byte $%10000000
    .byte $%11111000

char_3:
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%11111000

char_4:
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000

char_5:
    .byte $%11111000
    .byte $%10000000
    .byte $%10000000
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%11111000

char_6:
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000

char_7:
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000

char_8:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000

char_9:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000

char_A:
    .byte $%00100000
    .byte $%01010000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000

char_B:
    .byte $%11110000
    .byte $%10001000
    .byte $%10001000
    .byte $%11110000
    .byte $%10001000
    .byte $%10001000
    .byte $%11110000

char_C:
    .byte $%11111000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%11111000

char_D:
    .byte $%11100000
    .byte $%10010000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10010000
    .byte $%11100000

char_E:
    .byte $%11111000
    .byte $%10000000
    .byte $%10000000
    .byte $%11110000
    .byte $%10000000
    .byte $%10000000
    .byte $%11111000

char_F:
    .byte $%11111000
    .byte $%10000000
    .byte $%10000000
    .byte $%11110000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000

char_G:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%10000000
    .byte $%10111000
    .byte $%10001000
    .byte $%11111000

char_H:
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000

char_I:
    .byte $%11111000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%11111000

char_J:
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000
    .byte $%00001000
    .byte $%10001000
    .byte $%01001000
    .byte $%00111000

char_K:
    .byte $%10010000
    .byte $%10100000
    .byte $%11000000
    .byte $%10000000
    .byte $%11000000
    .byte $%10100000
    .byte $%10010000

char_L:
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000
    .byte $%11111000

char_M:
    .byte $%10001000
    .byte $%11011000
    .byte $%10101000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000

char_N:
    .byte $%10001000
    .byte $%11001000
    .byte $%10101000
    .byte $%10101000
    .byte $%10011000
    .byte $%10011000
    .byte $%10001000

char_O:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000

char_P:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000
    .byte $%10000000
    .byte $%10000000
    .byte $%10000000

char_Q:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10101000
    .byte $%10010000
    .byte $%11101000

char_R:
    .byte $%11111000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000
    .byte $%10100000
    .byte $%10010000
    .byte $%10001000

char_S:
    .byte $%11111000
    .byte $%10000000
    .byte $%10000000
    .byte $%11111000
    .byte $%00001000
    .byte $%00001000
    .byte $%11111000

char_T:
    .byte $%11111000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000

char_U:
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%11111000

char_V:
    .byte $%10001000
    .byte $%10001000
    .byte $%01010000
    .byte $%01010000
    .byte $%01010000
    .byte $%00100000
    .byte $%00100000

char_W:
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10001000
    .byte $%10101000
    .byte $%11011000
    .byte $%10001000

char_X:
    .byte $%10001000
    .byte $%10001000
    .byte $%01010000
    .byte $%00100000
    .byte $%01010000
    .byte $%10001000
    .byte $%10001000

char_Y:
    .byte $%10001000
    .byte $%01010000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000
    .byte $%00100000

char_Z:
    .byte $%11111000
    .byte $%00001000
    .byte $%00010000
    .byte $%00100000
    .byte $%01000000
    .byte $%10000000
    .byte $%11111000

char_PERIOD:
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%01000000

char_UNDERSCORE:
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%00000000
    .byte $%11111000

chr_tbl:
		.word char_SPACE
		.word char_0, char_1, char_2, char_3
		.word char_4, char_5, char_6, char_7
		.word char_8, char_9
		.word char_A, char_B, char_C, char_D
		.word char_E, char_F, char_G, char_H
		.word char_I, char_J, char_K, char_L
		.word char_M, char_N, char_O, char_P
		.word char_Q, char_R, char_S, char_T
		.word char_U, char_V, char_W, char_X
		.word char_Y, char_Z
		.word char_PERIOD, char_UNDERSCORE

erase_chr:
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			#7
				sta			*0xD4										; lines
				ldy			*0xC2
				ldd			#0
1$:			std			,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				lda			*0x05										; pixel offset
				adda		#6
				bita		#0x08
				beq			2$
				anda		#0x07
				ldy			*0xC2
				leay		1,y
				sty			*0xC2										; update CUR
2$:			sta			*0x05
				CLC
				rts
				
dvg_chr:
				lda			1,y											; char code (x2)
				leay		2,y
				sty			*0x0B										; update dvgram address
				ldu			#chr_tbl
				ldu			a,u											; address of char data
				lda			*0x05										; pixel offset (0-7)
				lsla														; x2
				adda		#>shift_tbl
				ldb			#0x80
				std			*0xD0										; offset
				inca
				std			*0xD2										; offset2
				lda			#7
				sta			*0xD4										; lines
				ldy			*0xC2
1$:			ldb			,u+											; sprite data byte
				ldx			*0xD0
				lda			b,x											; shifted data bye
				ora			,y
				sta			,y
				ldx			*0xD2
				lda			b,x
				ora			1,y
				sta			1,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				lda			*0x05										; pixel offset
				adda		#6
				bita		#0x08
				beq			2$
				anda		#0x07
				ldy			*0xC2
				leay		1,y
				sty			*0xC2										; update CUR
2$:			sta			*0x05
				CLC
				rts
				
bmp_life:
		.byte $%00100000
		.byte $%00100000
		.byte $%01010000
		.byte $%01010000
		.byte $%01010000
		.byte $%11111000
		.byte $%10001000

dvg_life:
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			*0x05										; pixel offset (0-7)
				lsla														; x2
				adda		#>shift_tbl
				ldb			#0x80
				std			*0xD0										; offset
				inca
				std			*0xD2										; offset2
				lda			#7
				sta			*0xD4										; lines
				ldu			#bmp_life
				ldd			*0xC2
				addd		#(4*32)									; because it overwrites score
				tfr			d,y
1$:			ldb			,u+											; sprite data byte
				ldx			*0xD0
				lda			b,x											; shifted data bye
				ora			,y
				sta			,y
				ldx			*0xD2
				lda			b,x
				ora			1,y
				sta			1,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				lda			*0x05										; pixel offset
				adda		#6
				bita		#0x08
				beq			2$
				anda		#0x07
				ldy			*0xC2
				leay		1,y
				sty			*0xC2										; update CUR
2$:			sta			*0x05
				CLC
				rts

copyright:
    .byte $%00000000, $%01001110, $%11101110, $%00000100, $%11100100, $%11101110, $%00001110, $%10010111
    .byte $%00001100, $%01001010, $%00101010, $%00001010, $%01001010, $%10100100, $%00000100, $%11010100
    .byte $%00001000, $%01001110, $%00101110, $%00001110, $%01001110, $%11100100, $%00000100, $%10110100
    .byte $%00001100, $%01000010, $%00100010, $%00001010, $%01001010, $%11000100, $%00000100, $%10010100
    .byte $%00000000, $%01000010, $%00100010, $%00001010, $%01001010, $%10101110, $%00001110, $%10010111

dvg_copyright:
				leay		2,y
				sty			*0x0B
				; CUR SSS=0,(400,128) = 100,24(168) = 12(shift=4)
				; - bitmap data is shifted already
				ldu			#copyright
				lda			#5
				sta			*0xD4
				ldy			#168*32+12
1$:			ldb			#8
2$:			lda			,u+
				ora			,y
				sta			,y+
				decb
				bne			2$
				leay		32-8,y
				dec			*0xD4
				bne			1$
				CLC
				rts
								
asteroid_0:
    .byte $%00001000, $%00010000
    .byte $%00010100, $%00101000
    .byte $%00100010, $%01000100
    .byte $%01000001, $%01000010
    .byte $%10000000, $%10000001
    .byte $%10000000, $%00000010
    .byte $%10000000, $%00000010
    .byte $%10000000, $%00000100
    .byte $%10000000, $%00000010
    .byte $%10000000, $%00000010
    .byte $%10000000, $%00000001
    .byte $%10000000, $%00000001
    .byte $%01000000, $%00000110
    .byte $%00100000, $%00011000
    .byte $%00011000, $%00100000
    .byte $%00000111, $%11000000

asteroid_1:
    .byte $%00000010, $%01000000
    .byte $%00000101, $%10100000
    .byte $%00001000, $%10010000
    .byte $%00001000, $%00100000
    .byte $%00001000, $%00100000
    .byte $%00001000, $%00010000
    .byte $%00000100, $%01100000
    .byte $%00000011, $%10000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_2:
    .byte $%00000001, $%10000000
    .byte $%00000010, $%11000000
    .byte $%00000010, $%01000000
    .byte $%00000001, $%10000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_3:
    .byte $%00001000, $%00010000
    .byte $%00010110, $%01101000
    .byte $%00100001, $%10000100
    .byte $%01000000, $%00000010
    .byte $%10000000, $%00000001
    .byte $%01000000, $%00001110
    .byte $%01000000, $%00010000
    .byte $%00100000, $%00001000
    .byte $%00100000, $%00000110
    .byte $%01000000, $%00000001
    .byte $%01000000, $%00000001
    .byte $%10000000, $%00000010
    .byte $%01000000, $%00000010
    .byte $%00100011, $%00000100
    .byte $%00010100, $%11001000
    .byte $%00001000, $%00110000

asteroid_4:
    .byte $%00000010, $%01000000
    .byte $%00000101, $%10100000
    .byte $%00001000, $%00010000
    .byte $%00000100, $%01100000
    .byte $%00000100, $%00100000
    .byte $%00001000, $%00010000
    .byte $%00000101, $%10100000
    .byte $%00000010, $%01000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_5:
    .byte $%00000001, $%10000000
    .byte $%00000010, $%11000000
    .byte $%00000010, $%01000000
    .byte $%00000001, $%10000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_6:
    .byte $%00000011, $%11110000
    .byte $%00000100, $%00001000
    .byte $%00001000, $%00001000
    .byte $%00010000, $%00000100
    .byte $%00100000, $%00000010
    .byte $%01000000, $%00000010
    .byte $%11110000, $%00000001
    .byte $%00001000, $%00000001
    .byte $%01110000, $%00000001
    .byte $%10000000, $%10000001
    .byte $%01000001, $%10000010
    .byte $%01000010, $%10000010
    .byte $%00100010, $%10000100
    .byte $%00100100, $%10000100
    .byte $%00010100, $%10001000
    .byte $%00001000, $%11110000

asteroid_7:
    .byte $%00000001, $%11000000
    .byte $%00000010, $%00100000
    .byte $%00000100, $%00100000
    .byte $%00001110, $%00010000
    .byte $%00001000, $%00010000
    .byte $%00000100, $%10100000
    .byte $%00000101, $%10100000
    .byte $%00000010, $%11000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_8:
    .byte $%00000001, $%10000000
    .byte $%00000001, $%01000000
    .byte $%00000010, $%11000000
    .byte $%00000001, $%10000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_9:
    .byte $%00001111, $%11000000
    .byte $%00001000, $%00110000
    .byte $%00000100, $%00001000
    .byte $%00000010, $%00000110
    .byte $%11111110, $%00000001
    .byte $%10000000, $%00000001
    .byte $%10000000, $%00000111
    .byte $%10000000, $%01111000
    .byte $%10000000, $%00100000
    .byte $%10000000, $%00011000
    .byte $%01000000, $%00000110
    .byte $%01000000, $%00000001
    .byte $%00100000, $%00000001
    .byte $%00010000, $%01000010
    .byte $%00010011, $%10100100
    .byte $%00001100, $%00011000

asteroid_10:
    .byte $%00000011, $%10000000
    .byte $%00000010, $%01100000
    .byte $%00001110, $%00010000
    .byte $%00001000, $%01110000
    .byte $%00001000, $%01000000
    .byte $%00000100, $%00100000
    .byte $%00000100, $%10010000
    .byte $%00000011, $%01100000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_11:
    .byte $%00000001, $%10000000
    .byte $%00000011, $%01000000
    .byte $%00000010, $%01000000
    .byte $%00000001, $%10000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

asteroid_bmp_tbl:
    		; 4 asteroid patterns; large, medium, small
    		.word asteroid_2,  asteroid_1,  asteroid_0,  0
    		.word asteroid_5,  asteroid_4,  asteroid_3,  0
    		.word asteroid_8,  asteroid_7,  asteroid_6,  0
    		.word asteroid_11, asteroid_10, asteroid_9,  0

erase_asteroid:
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			#16
				sta			*0xD4										; lines
				ldy			*0xC2
				ldd			#0
1$:			std			,y
				sta			2,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				CLC
				rts
								
dvg_asteroid:
        lda     1,y											; status (4:3)=shape, (2:1)=size
				ldu			#asteroid_bmp_tbl
				anda		#0x1E
				ldu			a,u
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			*0x05										; pixel offset (0-7)
				lsla														; x2
				adda		#>shift_tbl
				ldb			#0x80
				std			*0xD0										; offset
				inca
				std			*0xD2										; offset2
				lda			#16
				sta			*0xD4										; lines
				ldy			*0xC2
1$:			ldb			,u+											; sprite data byte 1
				ldx			*0xD0										; offset
				lda			b,x											; 1st half of byte 1
				ora			,y
				sta			,y
				ldx			*0xD2										; offset2
				lda			b,x											; 2nd half of byte 1
				ldb			,u+											; sprite data byte 2
				ldx			*0xD0										; offset
				ora			b,x											; 2nd of byte 1, 1st of byte 2
				ora			1,y
				sta			1,y
				ldx			*0xD2										; offset 2
				lda			b,x											; 2nd of byte 2
				ora			2,y
				sta			2,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				lda			*0x05										; pixel offset
				adda		#6
				bita		#0x08
				beq			2$
				anda		#0x07
				ldy			*0xC2
				leay		1,y
				sty			*0xC2										; update CUR
2$:			sta			*0x05
				CLC
				rts

ship_0:
    .byte $%00000000
    .byte $%11000000
    .byte $%01111000
    .byte $%01000110
    .byte $%01111000
    .byte $%11000000
    .byte $%00000000

ship_1:
    .byte $%00000000
    .byte $%11110000
    .byte $%01001110
    .byte $%01001100
    .byte $%01110000
    .byte $%01000000
    .byte $%00000000

ship_2:
    .byte $%00000000
    .byte $%00011110
    .byte $%11100100
    .byte $%00101000
    .byte $%00010000
    .byte $%00100000
    .byte $%00000000

ship_3:
    .byte $%00000110
    .byte $%00011100
    .byte $%01100100
    .byte $%11101000
    .byte $%00011000
    .byte $%00010000
    .byte $%00010000

ship_4:
    .byte $%00000100
    .byte $%00001100
    .byte $%00010100
    .byte $%00111000
    .byte $%01001000
    .byte $%00001000
    .byte $%00001000

ship_5:
    .byte $%00001000
    .byte $%00011000
    .byte $%00011000
    .byte $%00101000
    .byte $%00100100
    .byte $%01111100
    .byte $%00000100

ship_6:
    .byte $%00010000
    .byte $%00010000
    .byte $%00101000
    .byte $%00101000
    .byte $%00101000
    .byte $%01111100
    .byte $%01000100

ship_7:
    .byte $%00100000
    .byte $%00110000
    .byte $%00110000
    .byte $%01001000
    .byte $%01001000
    .byte $%01111100
    .byte $%01000000

ship_8:
    .byte $%01000000
    .byte $%01100000
    .byte $%01010000
    .byte $%01001000
    .byte $%00110100
    .byte $%00100000
    .byte $%00100000

ship_9:
    .byte $%11000000
    .byte $%10110000
    .byte $%01001100
    .byte $%01001110
    .byte $%00110000
    .byte $%00110000
    .byte $%00010000

ship_10:
    .byte $%00000000
    .byte $%11110000
    .byte $%01001110
    .byte $%00110000
    .byte $%00010000
    .byte $%00001000
    .byte $%00000000

ship_11:
    .byte $%00000000
    .byte $%00011110
    .byte $%11100100
    .byte $%01100100
    .byte $%00011100
    .byte $%00000100
    .byte $%00000000

ship_12:
    .byte $%00000000
    .byte $%00000110
    .byte $%00111100
    .byte $%11000100
    .byte $%00111100
    .byte $%00000110
    .byte $%00000000

ship_13:
    .byte $%00000100
    .byte $%00011100
    .byte $%01100100
    .byte $%11110100
    .byte $%00001110
    .byte $%00000000
    .byte $%00000000

ship_14:
    .byte $%00001000
    .byte $%00010000
    .byte $%00110000
    .byte $%01011110
    .byte $%11100000
    .byte $%00000000
    .byte $%00000000

ship_15:
    .byte $%00010000
    .byte $%00110000
    .byte $%00110000
    .byte $%01001110
    .byte $%01011000
    .byte $%11100000
    .byte $%10000000

ship_16:
    .byte $%00100000
    .byte $%00100000
    .byte $%00110100
    .byte $%01001000
    .byte $%01010000
    .byte $%01100000
    .byte $%01000000

ship_17:
    .byte $%01000000
    .byte $%01111100
    .byte $%01001000
    .byte $%01001000
    .byte $%00110000
    .byte $%00110000
    .byte $%00100000

ship_18:
    .byte $%01000100
    .byte $%01111100
    .byte $%00101000
    .byte $%00101000
    .byte $%00101000
    .byte $%00010000
    .byte $%00010000

ship_19:
    .byte $%00000100
    .byte $%01111100
    .byte $%00100100
    .byte $%00101000
    .byte $%00011000
    .byte $%00011000
    .byte $%00001000

ship_20:
    .byte $%00001000
    .byte $%00001000
    .byte $%01011000
    .byte $%00101000
    .byte $%00010100
    .byte $%00001100
    .byte $%00000100

ship_21:
    .byte $%00010000
    .byte $%00010000
    .byte $%00011000
    .byte $%11101000
    .byte $%00110100
    .byte $%00001100
    .byte $%00000010

ship_22:
    .byte $%00000000
    .byte $%00100000
    .byte $%00010000
    .byte $%00101000
    .byte $%11110100
    .byte $%00001110
    .byte $%00000000

ship_23:
    .byte $%00000000
    .byte $%01000000
    .byte $%01110000
    .byte $%01001100
    .byte $%01011110
    .byte $%11100000
    .byte $%00000000

ship_tbl:
		.word ship_0,  ship_1,  ship_2,  ship_3
		.word ship_4,  ship_5,  ship_6,  ship_7
		.word ship_8,  ship_9,  ship_10, ship_11
		.word ship_12, ship_13, ship_14, ship_15
		.word ship_16, ship_17, ship_18, ship_19
		.word ship_20, ship_21, ship_22, ship_23

thrust_x_off_tbl:
    .byte 0, 0, 1, 1, 2, 3, 3, 3, 4, 5, 5, 6, 6, 6, 5, 5
    .byte 4, 3, 3, 3, 2, 1, 1, 0
	
thrust_y_off_tbl:
    .byte 3, 3, 4, 5, 5, 6, 6, 6, 5, 5, 4, 3, 3, 2, 1, 1
    .byte 1, 0, 0, 0, 1, 1, 2, 3
		
erase_ship:
				jsr			erase_chr
				rts
				
dvg_ship:
        lda     ,y                      ; opcode incl. thrust
        sta     *0xC8
				lda			1,y											; direction
				clrb														; D = direction
				lsra
				rorb
				lsra
				rorb
				lsra
				rorb														; D = (0..31)
				std			*0xD8
				lsra
				rorb														; D = (0..15)
				addd		*0xD8										; A = dir (0..47) = (0..23)*2
				anda		#0x3E
				sta     *0xD8                   ; A=(0..23)*2 for thrust
				ldu			#ship_tbl
				ldu			a,u											; address of BMP				
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			*0x05										; pixel offset (0-7)
				lsla														; x2
				adda		#>shift_tbl
				ldb			#0x80
				std			*0xD0										; offset
				inca
				std			*0xD2										; offset2
				lda			#7
				sta			*0xD4										; lines
				ldy			*0xC2
1$:			ldb			,u+											; sprite data byte
				ldx			*0xD0
				lda			b,x											; shifted data bye
				ora			,y
				sta			,y
				ldx			*0xD2
				lda			b,x
				ora			1,y
				sta			1,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				lda     *0xC8                   ; opcode
				bita    #(1<<3)                 ; thrust?
				beq     9$                      ; no, skip
        ldb     *0xD8
        lsrb                            ; B=dir=(0..23)
        ldx     #thrust_x_off_tbl
        abx
        lda     ,x                      ; x offset for pixel
        ldb     24,x                    ; y offset for pixel
        ldx     *0xC2                   ; video address
        adda    *0x05                   ; add pixel x offset
        bita    #8
        beq     2$
        leax    1,x                     ; bump video address
        anda    #7
2$:     ldu     #shot_bmp
        lda     a,u                     ; get thrust data
        aslb
        aslb
        aslb
        aslb
        aslb                            ; y offset x32
        abx
        sta     ,x                      ; display thrust
9$:		  CLC
				rts
				
large_saucer_bmp:
    .byte $%00000011, $%11000000
    .byte $%00000010, $%01000000
    .byte $%00000111, $%11100000
    .byte $%00001000, $%00010000
    .byte $%00010000, $%00001000
    .byte $%00111111, $%11111100
    .byte $%00010000, $%00001000
    .byte $%00001000, $%00010000
    .byte $%00000111, $%11100000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

small_saucer_bmp:
    .byte $%00000001, $%10000000
    .byte $%00000010, $%01000000
    .byte $%00000101, $%10100000
    .byte $%00000011, $%11000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

saucer_bmp_tbl:
				.word 0x0000
    		.word small_saucer_bmp
    		.word large_saucer_bmp

erase_saucer:
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			#16
				sta			*0xD4										; lines
				ldy			*0xC2
				ldd			#0
1$:			std			,y
				sta			2,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				CLC
				rts
				
dvg_saucer:
        lda     1,y											; status 
        anda		#0x03										; size (1..2)
        asla
				ldu			#saucer_bmp_tbl
				ldu			a,u
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			*0x05										; pixel offset (0-7)
				lsla														; x2
				adda		#>shift_tbl
				ldb			#0x80
				std			*0xD0										; offset
				inca
				std			*0xD2										; offset2
				lda			#16
				sta			*0xD4										; lines
				ldy			*0xC2
1$:			ldb			,u+											; sprite data byte 1
				ldx			*0xD0										; offset
				lda			b,x											; 1st half of byte 1
				ora			,y
				sta			,y
				ldx			*0xD2										; offset2
				lda			b,x											; 2nd half of byte 1
				ldb			,u+											; sprite data byte 2
				ldx			*0xD0										; offset
				ora			b,x											; 2nd of byte 1, 1st of byte 2
				ora			1,y
				sta			1,y
				ldx			*0xD2										; offset 2
				lda			b,x											; 2nd of byte 2
				ora			2,y
				sta			2,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				lda			*0x05										; pixel offset
				adda		#6
				bita		#0x08
				beq			2$
				anda		#0x07
				ldy			*0xC2
				leay		1,y
				sty			*0xC2										; update CUR
2$:			sta			*0x05
				CLC
				rts

shot_bmp:
				.byte		0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01
				
erase_shot:
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			*0x05										; pixel offset (0-7)
				ldy     *0xC2
        clr     ,y
				CLC
				rts
				
dvg_shot:
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			*0x05										; pixel offset (0-7)
				ldu			#shot_bmp
				lda			a,u
				ldy     *0xC2
        ora     ,y
        sta     ,y				              ; hack
        CLC
        rts

shrapnel_0:
    .byte $%00010000, $%00010000
    .byte $%00000010, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00001000
    .byte $%00000100, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00010000, $%00010000
    .byte $%00000000, $%01000000
    .byte $%00000100, $%00010000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

shrapnel_1:
    .byte $%00100000, $%00000000
    .byte $%00000000, $%00001000
    .byte $%00000010, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000100
    .byte $%00000100, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00100000, $%00001000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%01000000
    .byte $%00000100, $%00001000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

shrapnel_2:
    .byte $%01000000, $%00001000
    .byte $%00000000, $%00000000
    .byte $%00000010, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000010
    .byte $%00001000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%01000000, $%00001000
    .byte $%00000000, $%01000000
    .byte $%00000000, $%00000000
    .byte $%00001000, $%00001000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000

shrapnel_3:
    .byte $%10000000, $%00000100
    .byte $%00000000, $%00000000
    .byte $%00000010, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000001
    .byte $%00001000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%00000000, $%00000000
    .byte $%10000000, $%00000100
    .byte $%00000000, $%00000000
    .byte $%00000000, $%01000000
    .byte $%00000000, $%00000000
    .byte $%00001000, $%00000100

shrapnel_bmp_tbl:
     		; 4 shrapnel patterns, some re-used
    		.word shrapnel_0
    		.word shrapnel_1
    		.word shrapnel_2, shrapnel_2
    		.word shrapnel_3, shrapnel_3

erase_shrapnel:
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			#16
				sta			*0xD4										; lines
				ldy			*0xC2
				ldd			#0
1$:			std			,y
				sta			2,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
        CLC
        rts
    
dvg_shrapnel:
				; the original uses 6 global scale factors from $B-$0
				; and 4 patterns in this sequence
				; $B:2,6 $C:0,4,6 $D,$E,$F,$0:0,2,4,6
				; instead we'll just use global scale factor
				; $B=0, $C=1, $D,$E=2, $F,$0=3
        lda     *0x08                   ; global scale
				ldu			#shrapnel_bmp_tbl
				suba    #0x0B                   ; (0-5)
				lsla                            ; word offset
				ldu			a,u
				leay		2,y
				sty			*0x0B										; update dvgram address
				lda			*0x05										; pixel offset (0-7)
				lsla														; x2
				adda		#>shift_tbl
				ldb			#0x80
				std			*0xD0										; offset
				inca
				std			*0xD2										; offset2
				lda			#16
				sta			*0xD4										; lines
				ldy			*0xC2
1$:			ldb			,u+											; sprite data byte 1
				ldx			*0xD0										; offset
				lda			b,x											; 1st half of byte 1
				ora			,y
				sta			,y
				ldx			*0xD2										; offset2
				lda			b,x											; 2nd half of byte 1
				ldb			,u+											; sprite data byte 2
				ldx			*0xD0										; offset
				ora			b,x											; 2nd of byte 1, 1st of byte 2
				ora			1,y
				sta			1,y
				ldx			*0xD2										; offset 2
				lda			b,x											; 2nd of byte 2
				ora			2,y
				sta			2,y
				leay		32,y
				dec			*0xD4										; done all lines?
				bne			1$											; no, loop
				lda			*0x05										; pixel offset
				adda		#6
				bita		#0x08
				beq			2$
				anda		#0x07
				ldy			*0xC2
				leay		1,y
				sty			*0xC2										; update CUR
2$:			sta			*0x05
        CLC
        rts
            
dvg_nop:
				leay		2,y
				sty			*0x0B
				CLC
				rts

dvg_halt:
				leay		2,y
				sty			*0x0B
				SEC
				rts
				
erase_jmp_tbl:
				.word		dvg_cur
				.word		erase_chr
				.word		erase_chr
				.word		dvg_nop
				.word		erase_asteroid
				.word		erase_chr
				.word		erase_saucer
				.word		erase_shot
				.word		erase_shrapnel
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_halt
								
handle_erase_opcode:
				lsra
				lsra
				lsra
				anda		#0x1E
				ldx			#erase_jmp_tbl
				jmp			[a,x]
				rts

dvg_jmp_tbl:
				.word		dvg_cur
				.word		dvg_chr
				.word		dvg_life
				.word		dvg_copyright
				.word		dvg_asteroid
				.word		dvg_ship
				.word		dvg_saucer
				.word		dvg_shot
				.word		dvg_shrapnel
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_halt
								
handle_dvg_opcode:
				lsra
				lsra
				lsra
				anda		#0x1E
				ldx			#dvg_jmp_tbl
				jmp			[a,x]
				
osd_render_frame::
;
				ldd			*0x02									; dvg_curr_addr
				anda		#(>dvgram|0x04)
				eora		#0x04									; previous frame
				ldb			#0x02									; start at $0002
				std			*0x0B
erase_loop:				
				ldy			*0x0B
				ldd			,y
				jsr			handle_erase_opcode		; handle it
				bcc			erase_loop
;
				ldd			*0x02									; dvg_curr_addr
				anda		#(>dvgram|0x04)
				ldb			#0x02									; start at $0002
				std			*0x0B
render_loop:
				ldy			*0x0B
				ldd			,y
				jsr			handle_dvg_opcode			; handle it
				bcc			render_loop
;
; now for some inputs...
        clr     hyperspaceSwitch
				clr			FireSwitch
				clr			rotateLeftSwitch
				clr			rotateRightSwitch
				clr     p1StartSwitch
				clr			thrustSwitch
				ldx			#KEYROW
				ldb			#(1<<7)
				lda			#~(1<<0)								; "ROW = 0
				sta			2,x
				lda			,x
				bita		#(1<<3)									; <X>?
				bne			1$
				stb			hyperspaceSwitch
1$:			lda			#~(1<<1)								; "ROW = 1
				sta			2,x
				lda			,x
				bita		#(1<<4)									; <1>?
				bne			2$
				stb			p1StartSwitch
2$:			lda			#~(1<<2)								; "ROW = 2
				sta			2,x
				lda			,x
				bita		#(1<<3)									; <Z>?
				bne			3$
				stb			FireSwitch
3$:     lda     #~(1<<3)								; "ROW" = 3
				sta			2,x
				lda			,x
				bita		#(1<<3)									; <UP>?
				bne			5$
				stb			thrustSwitch				
5$:     lda     #~(1<<5)								; "ROW" = 5
				sta			2,x
				lda			,x
				bita		#(1<<3)									; <LEFT>?
				bne			51$
				stb			rotateLeftSwitch				
51$:    bita    #(1<<4)                 ; <5>?
				bne			6$
52$:		lda     #~(1<<5)								; "ROW" = 5
        sta			2,x
				lda			,x
				bita		#(1<<4)
				beq			52$											; wait for release
				inc			*0x70										; CurrNumCredits
6$:     lda     #~(1<<6)								; "ROW" = 6
				sta			2,x
				lda			,x
				bita		#(1<<3)									; <RIGHT>?
				bne			61$
				stb			rotateRightSwitch
				; freeze (for snapshot)
61$:    bita    #(1<<0)                	; <F>?
				bne			9$
62$:		sta			2,x
				lda			,x
				bita		#(1<<0)
				beq			62$											; wait for release
9$:			rts
