
				.list		(meb)										; macro expansion binary
				.bank   ROM (BASE=0xE000,SIZE=0x1FE0)
       	.area   ROM (REL,CON,BANK=ROM)
				.module swsdk
				
.include "swsdk.inc"

; *** BUILD OPTIONS
.define BUILD_OPT_NO_SPLASH
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

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
				puls		y																; save return address
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
				pshs		y																; restore return address
				lda			#0xFF
				sta			SWSDK_LED1
				sta			SWSDK_LED2
				sta			SWSDK_LED3
				SWSDK_ACK_IRQ
				rts

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

SWSDK_GoMathAndWait::
				sta			SWSDK_MATHW_MW0
1$:			tst			SWSDK_IN1
				bmi			1$				
				rts				
