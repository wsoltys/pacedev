
				.list		(meb)										; macro expansion binary
				.module swsdk
				
.include "swsdk.inc"

        .globl  RESET

; *** BUILD OPTIONS
.define BUILD_OPT_NO_SPLASH
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

				.area		DATA (ABS,OVR)
        .org    SWSDK_VariableStart
        
SWSDK_in0_shadow::
        .ds     3                               ; prev, curr, deb
SWSDK_in1_shadow::
        .ds     3
SWSDK_dsw0_shadow::
        .ds     3
SWSDK_dsw1_shadow::
        .ds     3

				.bank   ROM (BASE=0xE000,SIZE=0x1FE0)
       	.area   ROM (REL,CON,BANK=ROM)

SWSDK_Init::
				; this is exactly what the original ROM does
				orcc		#(1<<4)													; disable interrupts
				clr			SWSDK_BankSwitch
				lda			#0
				sta			SWSDK_LED1
				sta			SWSDK_LED2
				sta			SWSDK_LED3
				lda			#0
				SWSDK_RESET_PRNG
				lda			#0x80
				SWSDK_RESET_PRNG
				SWSDK_RESET_AVG
				; kick watchdog - a lot!
				ldu			#0
1$:			SWSDK_KICK_WDOG
				leau		-1,u
				cmpu		#0
				bne			1$
				lda			#>SWSDK_CpuRAMStart
				tfr			a,dp
				; clear RAM
				ldx			#SWSDK_CpuRAMStart
				ldd			#0
2$:			std			,x++
				cmpx		#SWSDK_CpuRAMEnd+1
				bcs			2$
				SWSDK_KICK_WDOG
				ldx			#SWSDK_MathRAMStart
				ldd			#0
3$:			std			,x++
				SWSDK_KICK_WDOG
				cmpx		#SWSDK_MathRAMEnd+1
				bcs			3$
				ldx			#SWSDK_VectorRAMStart
				ldd			#0
4$:			std			,x++
				SWSDK_KICK_WDOG
				cmpx		#SWSDK_VectorRAMEnd+1
				bcs			4$												
				lda			#0xFF
				sta			SWSDK_LED1
				sta			SWSDK_LED2
				sta			SWSDK_LED3
				SWSDK_ACK_IRQ
				lds     #SWSDK_Stack
				jmp     RESET+3

; copied verbatim from the ROM
; X=msg ptr, Y=display list
; uses DP:0,1
SWSDK_RenderString::
				ldb			,x+															; chr
				stx			*0															; save ptr
				aslb																		; word offset
				cmpb		#0x82														; pre-alpha?
				bcs			1$															; yes, go
				ldx			#SWSDK_Font+0x0014
				andb		#0x7F
				bra			render_chr
1$:			cmpb		#0x74														; colon?
				bne			2$															; no, skip
				ldx			#SWSDK_Font-0x0024
				bra			render_chr
2$:			cmpb		0x80														; '@'? ==(C)
				bne			3$															; no, skip
				ldx			#SWSDK_Font+0x56
				clrb
				bra			render_chr
3$:			cmpb		#0x60														; pre-digit?
				bcs			4$															; yes, skip
				ldx			#SWSDK_Font-0x005E
				bra			render_chr
4$:			cmpb		#0x40														; ' '?
				bne			5$															; no, skip
				ldx			#SWSDK_Font-0x0040
				bra			render_chr
5$:			cmpb		#0x4E														; quote?
				bne			6$															; no, skip
				ldx			#SWSDK_Font-0x0004
				bra			render_chr
6$:			cmpb		#0x58														; ','?
				bne			7$															; no, skip
				ldx			#SWSDK_Font-0x000C
				bra			render_chr
7$:			cmpb		#0x5A														; '-'?
				bne			8$															; no, skip
				ldx			#SWSDK_Font-2
				bra			render_chr
8$:			cmpb		#0x4A														; '%'? ==1/2
				bne			9$															; no, skip
				ldx			#SWSDK_Font+0x000A
				bra			render_chr
9$:			ldx			#SWSDK_Font-0x000E
render_chr:
				ldd			b,x															; get JSRL instruction
				std			,y++														; write to display list
				ldx			*0															; restore msg ptr
				tst			-1,x														; end of msg?
				bpl			SWSDK_RenderString							; no, loop
				rts				

; A = byte to render, Y = display list
SWSDK_RenderInt8Hex::
; quick 'n' dirty hack
        pshs    a
        anda    #0xF0
        lsra
        lsra
        lsra                                    ; word offset
        ldx     #0x3004
        ldx     a,x
        stx     ,y++
        puls    a
        anda    #0x0F
        asla                                    ; word offset
        ldx     #0x3004
        ldx     a,x
        stx     ,y++
        rts

; Returns (active high) state of buttons 1-4 in A
; - requires SDK ISR installed
SWSDK_ButtonState::
        lda     SWSDK_in0_shadow+2              ; debounced
        coma                                    ; active high
        anda    #SWSDK_IN0_BUTTON1n|SWSDK_IN0_BUTTON4n
        pshs    a
        lda     SWSDK_in1_shadow+2              ; debounced
        coma
        anda    #SWSDK_IN1_BUTTON2n|SWSDK_IN1_BUTTON3n
        ora     ,s+                             ; in0 + in1
        rts
        
; A = MW0 (PROM routine address)
SWSDK_GoMathAndWait::
				sta			SWSDK_MATHW_MW0
1$:			tst			SWSDK_IN1
				bmi			1$				
				rts				

debounce_in:
        ldb     ,x                              ; prev
        stb     1,x                             ; shift along
        sta     ,x                              ; curr
        anda    1,x                             ; prev AND curr
        ora     2,x                             ; (prev AND cur) OR deb
        sta     2,x                             ; (tmp) deb
        orb     ,x++                            ; prev OR curr
        andb    ,x                              ; (prev or curr) AND deb
        stb     ,x+                             ; store deb
        rts

; A = sound CPU command
SWSDK_WriteSoundCmd::
        ldb     #14                             ; 14 attempts
1$:     tst     SWSDK_MainReadyFlag             ; sound CPU ready?
        bpl     2$                              ; yes, go
        decb                                    ; exhausted all attempts?
        bne     1$                              ; no, loop
        lda     #0                              ; cmd=0x00
2$:     sta     SWSDK_MainRW                    ; write to sound CPU mailbox
        rts
               
SWSDK_IRQ::
				SWSDK_KICK_WDOG
				ldx     #SWSDK_in0_shadow
				lda			SWSDK_IN0
				jsr     debounce_in
				lda			SWSDK_IN1
        jsr     debounce_in				
				lda			SWSDK_DSW0
        jsr     debounce_in				
				lda			SWSDK_DSW1
        jsr     debounce_in				
				SWSDK_ACK_IRQ
				rti
