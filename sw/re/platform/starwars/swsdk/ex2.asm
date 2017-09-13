;
;	Star Wars SDK
; - Example 2 (test pattern routines)

				.list		(meb)										; macro expansion binary
				.module ex2

.include "swsdk.inc"

; *** BUILD OPTIONS
;.define BUILD_OPT_PROFILE
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

				.area		DATA (ABS,CON)
				.org		SWSDK_CpuRAMStart

								.ds			256											; for DP (MAIN)
cnt			.equ		0x80
delay		.equ 		0x81								

								.ds			256											; for DP (IRQ)
object:					.ds			4*4

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

				clr			*cnt
FRAME_DELAY			.equ		120
				lda			#FRAME_DELAY
				sta			*delay
				
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

				; SDK message
				SWSDK_CNTR
				SWSDK_SCAL 2,0
				SWSDK_VCTR -256,440,0
				SWSDK_COLOR SWSDK_GREEN,255
				ldx			#sdk_msg
				jsr			SWSDK_RenderString
				SWSDK_CNTR
				SWSDK_VCTR -240,360,0
				SWSDK_COLOR SWSDK_WHITE,128
				ldx			#title_msg
				jsr			SWSDK_RenderString

				dec			*delay
				bne			skip_inc
				lda			#FRAME_DELAY
				sta			*delay
				inc			*cnt
skip_inc:
				lda			*cnt
				cmpa		#1
				bne			1$
				SWSDK_JSRL SWSDK_IntesnsityTestPattern
				bra			3$
1$:			cmpa		#2
				bne			2$				
				SWSDK_JSRL SWSDK_CrossHatchAndFont
				bra			3$
2$:			clr			*cnt
				SWSDK_COLOR SWSDK_RED,128
				SWSDK_JSRL SWSDK_SquareHatch
3$:			
skip_rot:

				SWSDK_HALT

				jmp			loop

sdk_msg:
				.ascii	"STAR WARS SDK "
				SWSDK_SZ_VERSION

title_msg:
				.ascii	"EX2: TEST PATTERN"
				.byte		(1<<7)|'S
				
IRQ::
				SWSDK_ACK_IRQ
				rti
