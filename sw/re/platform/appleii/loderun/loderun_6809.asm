;
;	LODE RUNNER
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
       	.area   idaseg (ABS)

.define			COCO3

.ifdef COCO3

; COCO registers
PIA0				.equ		0xFF00
PIA1				.equ		0xFF20

KEYCOL			.equ		PIA0+2
KEYROW			.equ		PIA0

; GIME registers  	
INIT0				.equ		0xFF90
INIT1				.equ		0xFF91
IRQENR			.equ		0xFF92
FIRQENR			.equ		0xFF93
TMRMSB			.equ		0xFF94
TMRLSB			.equ		0xFF95
VMODE				.equ		0xFF98
VRES				.equ		0xFF99
BRDR				.equ		0xFF9A
VSC					.equ		0xFF9C
VOFFMSB			.equ		0xFF9D
VOFFLSB			.equ		0xFF9E
HOFF				.equ		0xFF9F
MMUTSK1			.equ		0xFFA0
MMUTSK2			.equ		0xFFA8
PALETTE			.equ		0xFFB0
CPU089			.equ		0xFFD8
CPU179			.equ		0xFFD9
ROMMODE			.equ		0xFFDE
RAMMODE			.equ		0xFFDF

codebase		.equ		0x4000
.endif

						.org		codebase
stack				.equ		.-2

.ifdef COCO3
; initialise Coco3 hardware
				ldu			stack
				orcc		#0x50										; disable interrupts
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
				lda			#0x60										; enable GIME MMU,IRQ
				sta			INIT0     							
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
;				lda			#0x08										; VBLANK IRQ
				lda			#0x00										; no VBLANK IRQ
				sta			IRQENR    							
				lda			#0x00										; no FIRQ enabled
				sta			FIRQENR   							
				lda			#0x80										; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
;				lda			#0x7A										; 225 scanlines, 128 bytes/row, 16 colours
				lda			#0x0C										; 192 scanlines, 40 bytes/row, 2 colours (320x192)
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
				lda			#0xE0										; screen at page $38
				sta			VOFFMSB
				lda			#0x00      							
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							
				lda			#0x00
				sta			PALETTE
				lda			#0x12
				sta			PALETTE+1
				sta			CPU179									; select fast CPU clock (1.79MHz)
.endif
				
; start lode runner
				jsr			read_paddles
;				lda			#1
;				jsr			sub_6359								; examine h/w and check disk sig			

display_title_screen: ; $6008
				jsr			gcls1
				ldy			#title_data
				ldx			#0x0000									; 2 centres the title screen
				lda			#35											; 35 bytes/line
				sta			(dtx)
				lda			#192										; 192 lines/screen
				sta			(dty)
1$:			ldb			,y+											; count
				lda			,y+											; byte
2$:			sta			,x+
				dec			(dtx)										; line byte count
				tst			(dtx)										; done line?
				bne			3$											; no, skip
				pshs		b
				ldb			#35
				stb			(dtx)										; reset line byte count
				ldb			#5
				abx															; adjust video ptr
				dec			(dty)										; dec line count
				puls		b
3$:			decb														; done count?
				bne			2$											; no, loop
				tst			(dty)										; done screen?
				bne			1$											; no, loop
; this is where the apple selects the hires screen				
				jmp			title_wait_for_key

loc_6056: ; $6056
				lda			#0
; store in zero page
				lda			#5											; number of lives
				sta			(no_lives)
; do some crap
				jmp			display_title_screen

title_wait_for_key: ; $618e
;				jsr			keybd_flush
; *** add 6s timeout here!!!
1$:			lda			(paddles_detected)
				cmpa		#0xcb										; detected?
				beq			3$											; no, skip
; check for joystick buttons here				
3$:			ldx			#PIA0
				ldb			#0											; all columns
				stb			2,x											; column strobe
				lda			,x
				coma														; any key pressed?
				bne			loc_61f6								; yes, exit
				bra			1$				
; do some other crap
; test $A7
				jmp			loc_6056

loc_61f6:
; hack
				jsr			gcls1
break:	bra			break

gcls1: ; $7A51
				ldx			#0x0000
				lda			#0x00
1$:			sta			,x+
				cmpx		#40*192
				bne			1$
				rts

read_paddles: ; $8702
				lda			#0xcb										; no paddles detected?
				sta			paddles_detected
				rts
								
; zero-page registers
.include "zeropage.asm"

; 6809 port-specific variables
dtx:		.db			1
dty:		.db			1

.include "title.asm"

				.end		codebase