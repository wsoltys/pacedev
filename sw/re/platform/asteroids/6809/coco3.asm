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

handle_erase_opcode:
				SEC
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
				
dvg_jmp_tbl:
				.word		dvg_cur
				.word		dvg_chr
				.word		dvg_life
				.word		dvg_copyright
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
				.word		dvg_nop
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

				rts
