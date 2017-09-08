;
;	Star Wars SDK
; - Example 1

				.list		(meb)										; macro expansion binary
       	.area   _CODE (ABS,OVR)
				.module ex1

.include "swsdk.inc"

; *** BUILD OPTIONS
;.define BUILD_OPT_PROFILE
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

        .org    0xE000

RESET::
       
       	lds			#SWSDK_CpuRAMEnd
     		jsr			SWSDK_Init

				ldy			#SWSDK_VectorRAMStart

				; death star
				ldx			#0x8040													; CNTR
				stx			,y++
				ldx			#0x7500													; SCAL BIN=5,LIN=0
				stx			,y++
				ldx			#0xA000|(SWSDK_DeathStarOutline>>1)
				stx			,y++
				ldx			#0x7500													; SCAL BIN=5,LIN=0
				stx			,y++
				ldx			#0xA000|(SWSDK_DeathStarEquator>>1)
				stx			,y++
				ldx			#0x7500													; SCAL BIN=5,LIN=0
				stx			,y++
				ldx			#0xA000|(SWSDK_DeathStarFocusLensOutline>>1)
				stx			,y++
				ldx			#0x7500													; SCAL BIN=5,LIN=0
				stx			,y++
				ldx			#0xA000|(SWSDK_DeathStarFocusLensPanels>>1)
				stx			,y++
				ldx			#0x7500													; SCAL BIN=5,LIN=0
				stx			,y++
				ldx			#0xA000|(SWSDK_DeathStarPanels>>1)
				stx			,y++

				; font
				ldx			#0x8040													; CNTR
				stx			,y++
				ldx			#0x7200													; SCAL BIN=2,LIN=0
				stx			,y++
				ldx			#0x1F98													; VCTR (word1)
				stx			,y++
				ldx			#0x1E00													; VCTR (word2)
				stx			,y++
				ldx			#0x7200													; SCAL BIN=2,LIN=0
				stx			,y++
				ldx			#0x6280													; COLOR C=2,Z=128
				stx			,y++
				ldx			#0xA000|(0x3002>>1)							; JSRL $3002
				stx			,y++
				
				; font
				ldx			#0x8040													; CNTR
				stx			,y++
				ldx			#0x7200													; SCAL BIN=2,LIN=0
				stx			,y++
				ldx			#0x1F58													; VCTR (word1)
				stx			,y++
				ldx			#0x1E00													; VCTR (word2)
				stx			,y++
				ldx			#0x7240													; SCAL BIN=2,LIN=40
				stx			,y++
				ldx			#0x6180													; COLOR C=2,Z=128
				stx			,y++
				ldx			#0xA000|(0x3002>>1)							; JSRL $3002
				stx			,y++
				
				; font
				ldx			#0x8040													; CNTR
				stx			,y++
				ldx			#0x7200													; SCAL BIN=2,LIN=0
				stx			,y++
				ldx			#0x1F18													; VCTR (word1)
				stx			,y++
				ldx			#0x1E00													; VCTR (word2)
				stx			,y++
				ldx			#0x7280													; SCAL BIN=2,LIN=80
				stx			,y++
				ldx			#0x6480													; COLOR C=4,Z=128
				stx			,y++
				ldx			#0xA000|(0x3002>>1)							; JSRL $3002
				stx			,y++

				; SDK
				ldx			#0x8040													; CNTR
				stx			,y++
				ldx			#0x7200													; SCAL BIN=2,LIN=0
				stx			,y++
				ldx			#0x1E98													; VCTR (word1)
				stx			,y++
				ldx			#0x1F00													; VCTR (word2)
				stx			,y++
				ldx			#0x7200													; SCAL BIN=2,LIN=0
				stx			,y++
				ldx			#0x6280													; COLOR C=2,Z=128
				stx			,y++
				ldx			#sdk_msg
				jsr			SWSDK_RenderString

				ldx			#0xE000|(0x0000>>1)							; JMPL $0
				stx			,y++
				sta			SWSDK_AVGGo

9$:     		
      	SWSDK_KICK_WDOG
				bra			9$

sdk_msg:
				.ascii	"STAR WARS SDK V0.0."
				.byte		(1<<7)|'1

IRQ::
				rti
