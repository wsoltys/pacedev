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
				; since all deathstar routines reset SCAL
				; we need to set SCAL before every routine call
				SWSDK_CNTR
				SWSDK_SCAL 5,0
				SWSDK_JSRL SWSDK_DeathStarOutline
				SWSDK_SCAL 5,0
				SWSDK_JSRL SWSDK_DeathStarEquator
				SWSDK_SCAL 5,0
				SWSDK_JSRL SWSDK_DeathStarFocusLensOutline
				SWSDK_SCAL 5,0
				SWSDK_JSRL SWSDK_DeathStarFocusLensPanels
				SWSDK_SCAL 5,0
				SWSDK_JSRL SWSDK_DeathStarPanels

				; font in green
				SWSDK_CNTR
				SWSDK_SCAL 2,0
				SWSDK_VCTR -512,-104,0
				SWSDK_COLOR SWSDK_GREEN,128
				SWSDK_JSRL SWSDK_Font
				
				; font in blue
				SWSDK_CNTR
				SWSDK_SCAL 2,0
				SWSDK_VCTR -512,-168,0
				SWSDK_SCAL 2,64
				SWSDK_COLOR SWSDK_BLUE,128
				SWSDK_JSRL SWSDK_Font
				
				; font in red
				SWSDK_CNTR
				SWSDK_SCAL 2,0
				SWSDK_VCTR -512,-232,0
				SWSDK_SCAL 2,128
				SWSDK_COLOR SWSDK_RED,128
				SWSDK_JSRL SWSDK_Font

				; SDK message
				SWSDK_CNTR
				SWSDK_SCAL 2,0
				SWSDK_VCTR -256,-360,0
				SWSDK_COLOR SWSDK_GREEN,128
				ldx			#sdk_msg
				jsr			SWSDK_RenderString

				SWSDK_JMPL 0

				sta			SWSDK_AVGGo
9$:     		
      	SWSDK_KICK_WDOG
				bra			9$

sdk_msg:
				.ascii	"STAR WARS SDK V0.0."
				.byte		(1<<7)|'1

IRQ::
				rti
