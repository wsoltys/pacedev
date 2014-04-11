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

; cartridge memory
codebase		.equ		0x8000
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
				lda			#0xE1										; screen based at page $38 ($70000) + 16 lines (16*128=2KB)
				sta			VOFFMSB									; /8 = $E100
				lda			#0x00      							
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							
				sta			RAMMODE									; select RAM mode
				ldx			#MMUTSK1								; start of bank registers for TASK 1
				lda			#12											; bank 12 ($18000) RAM and graphics ROM
				sta			4,x     								
				lda			#13											; bank 13 ($1A000) program ROM
				sta			5,x     								
				lda			#14											; bank 14 ($1C000) program ROM (continued)
				sta			6,x     								
				inca														; bank 15 ($1E000) program ROM (continued)
				sta			7,x     								
				sta			CPU179									; select fast CPU clock (1.79MHz)
.endif
				
; start lode runner
				jsr			display_title
1$:			jsr			1$

display_title:
				rts
								
.include "title.asm"

				.end		codebase