
				.list		(meb)										; macro expansion binary
       	.area   _CODE (ABS, OVR)
				.module swsdk
				
.include "swsdk.inc"

; *** BUILD OPTIONS
.define BUILD_OPT_NO_SPLASH
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

        .org    0xF000

SWSDK_Init::
				; this is exactly what the original ROM does
				orcc		#0x10
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
