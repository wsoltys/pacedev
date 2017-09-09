;
;	Star Wars SDK
; - Example 1

				.list		(meb)										; macro expansion binary
				.module ex1

.include "swsdk.inc"

; *** BUILD OPTIONS
;.define BUILD_OPT_PROFILE
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

				.area		DATA (ABS,CON)
				.org		SWSDK_CpuRAMStart

								.ds			256											; for DP (MAIN)
								.ds			256											; for DP (IRQ)
msgy:						.ds			2

				.bank   ROM (BASE=0xE000,SIZE=0x1FE0)
       	.area   ROM (REL,CON,BANK=ROM)

RESET::
       
       	lds			#SWSDK_CpuRAMEnd
     		jsr			SWSDK_Init

				SWSDK_ACK_IRQ
				andcc		#~(1<<4)												; enable IRQ

				ldy			#SWSDK_VectorRAMStart
				SWSDK_JMPL 0x1802												; simulate other buffer
				SWSDK_HALT															; empty 1st half

				ldd			#(-360)&0x1FFF
				std			msgy
				
loop:

wait_AVG:
				SWSDK_KICK_WDOG
				SWSDK_AVG_HALTED												; Z=running
				beq			wait_AVG

				; ping-pong display list buffer				
				lda			SWSDK_VectorRAMStart						; MSB of JMPL
				tfr			a,b
				eorb		#0x0C														; $0000<->$1800
				stb			SWSDK_VectorRAMStart
				SWSDK_RESET_AVG
				SWSDK_GO_AVG

				; calculate new address
				anda		#0x1F
				asla																		; convert MSB to address
				ldb			#0x02
				tfr			d,y															; new display list

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
				;SWSDK_VCTR -256,-360,0
				ldd			msgy
				anda		#0x1F
				ora			#>SWSDK_OP_VCTR
				std			,y++
				ldd			#(-256)&0x1FFF
				std			,y++
				
				SWSDK_COLOR SWSDK_GREEN,128
				ldx			#sdk_msg
				jsr			SWSDK_RenderString

				ldx			msgy
				leax		1,x
				stx			msgy

				SWSDK_HALT

				jmp			loop

sdk_msg:
				.ascii	"STAR WARS SDK V0.0."
				.byte		(1<<7)|'1

IRQ::
				SWSDK_ACK_IRQ
				rti
