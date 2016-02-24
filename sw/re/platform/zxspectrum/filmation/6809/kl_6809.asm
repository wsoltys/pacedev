;
;	KNIGHT LORE
; - ported from the original ZX Spectrum version
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

				.org		codebase
start:
				orcc		#0x50										; disable interrupts
				lds			#stack

.ifdef PLATFORM_COCO3

; initialise PLATFORM_COCO3 hardware
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			IRQENR									; ACK any pending GIME interrupt
.ifndef CARTRIDGE				
				lda			#0x60										; enable GIME MMU,IRQ
				sta			INIT0     							
.endif				
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
				lda			#0x00										; no VBLANK IRQ
				sta			IRQENR    							
				lda			#0x00										; no FIRQ enabled
				sta			FIRQENR   							
				lda			#0x80										; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
	  .ifdef GFX_1BPP				
				lda			#0x08										; 192 scanlines, 32 bytes/row, 2 colours (256x192)
	  .else				
				lda			#0x1A										; 192 scanlines, 128 bytes/row, 4 colours (256x192)
	  .endif				
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
				lda			#(VIDEOPAGE<<2)         ; screen at page $30
				sta			VOFFMSB
				lda			#0x00
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							
				
				ldx			#PALETTE
				ldy     #speccy_pal
				ldb     #16
inipal:
				lda     ,y+
				sta     ,x+
				decb
				bne     inipal
				
				sta			CPU179									; select fast CPU clock (1.79MHz)
        ;sta     RAMMODE
        
  ; configure video MMU

        lda     #VIDEOPAGE
        ldx     #(MMUTSK1)              ; $0000-
        ldb     #3
  mmumap: 
        sta     ,x+
        inca
        decb
        bne     mmumap                  ; map pages $30-$31

  .ifdef HAS_SOUND				

				lda			0xff23
				ora			#(1<<5)|(1<<4)					; set CB2 as output
				ora			#(1<<3)									; enable sound
				sta			0xff23

    .ifdef USE_1BIT_SOUND				
				; bit2 sets control/data register
				lda     0xff23                  ; CRB
				anda    #~(1<<2)                ; control register
				sta     0xff23                  ; CRB
				lda     0xff22                  ; DDRB
				ora     #(1<<1)                 ; PB1 output
				sta     0xff22                  ; DDRB
        ; setup for data register				
				lda     0xff23                  ; CRB
				ora     #(1<<2)                 ; data register
				sta     0xff23                  ; CRB
    .endif  ; USE_1BIT_SOUND

    .ifdef USE_DAC_SOUND
				; bit2 sets control/data register
				lda     0xff21                  ; CRA
				anda    #~(1<<2)                ; control register
				sta     0xff21                  ; CRA
				lda     0xff20                  ; DDRA
				ora     #0xfc                   ; PA2-7 outputs
				sta     0xff20                  ; DDRA
        ; setup for data register				
				lda     0xff21                  ; CRA
				ora     #(1<<2)                 ; data register
				sta     0xff21                  ; CRA
    .endif  ; USE_DAC_SOUND

  .endif  ; HAS_SOUND
												
.endif	; PLATFORM_COCO3
			
				lda			#>ZEROPAGE
				tfr			a,dp
        
loop:
        bra     loop

				.end		start
