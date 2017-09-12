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
i 			.equ 		1								
col			.equ		2

								.ds			256											; for DP (IRQ)
x:							.ds			2*4
y:							.ds			2*4

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
				SWSDK_VCTR -256,-360,0
				SWSDK_COLOR SWSDK_GREEN,128
				ldx			#sdk_msg
				jsr			SWSDK_RenderString

				; init a rectangle
				pshs		y
				ldx			#x
				ldy			#y
				ldd			#0
				std			0*2,x
				std			0*2,y
				std			1*2,x
				std			2*2,y
				ldd			#7
				std			1*2,y
				std			2*2,x
				std			2*2,y
				std			3*2,x
				puls		y

				ldu			#SWSDK_MathRAMStart
				
				; init rotation matrix
				; [cos -sin ..] [14 15 ..]
				; [sin  cos ..] [18 19 ..]
				ldd			#(255>>2)									; cos(5)
				std			0x14*2,u
				std			0x19*2,u
				ldd			#(22>>2)									; sin(5)
				std			0x18*2,u
				ldd			#-(22>>2)									; -sin(5)
				std			0x15*2,u

				lda			#1
				sta			*i
				clr			*col
				
inner_loop:

				ldx			#x
				
				; render it
				SWSDK_CNTR
				SWSDK_SCAL 0,0

				inc			*col
				lda			*col
				anda		#0x07
				ora			#>SWSDK_OP_COLOR
				ldb			#0xFF
				std			,y++
				
				lda			5*2+1,x
				suba		4*2+1,x
				anda		#0x1F
				ora			#>SWSDK_OP_SVEC
				ldb			1*2+1,x
				subb		0*2+1,x
				orb			#(7<<5)
				std			,y++

				lda			6*2+1,x
				suba		5*2+1,x
				anda		#0x1F
				ora			#>SWSDK_OP_SVEC
				ldb			2*2+1,x
				subb		1*2+1,x
				orb			#(7<<5)
				std			,y++

				lda			7*2+1,x
				suba		6*2+1,x
				anda		#0x1F
				ora			#>SWSDK_OP_SVEC
				ldb			3*2+1,x
				subb		2*2+1,x
				orb			#(7<<5)
				std			,y++

				lda			4*2+1,x
				suba		7*2+1,x
				anda		#0x1F
				ora			#>SWSDK_OP_SVEC
				ldb			0*2+1,x
				subb		3*2+1,x
				orb			#(7<<5)
				std			,y++

				ldu			#SWSDK_MathRAMStart

				; rotate a point
				
				ldb			#0
				lda			0*2+1,x
				std			0x24*2,u
				lda			4*2+1,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				stb			0*2+1,x
				ldd			4*2,u
				stb			4*2+1,x

				ldb			#0
				lda			1*2+1,x
				std			0x24*2,u
				lda			5*2+1,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				stb			1*2+1,x
				ldd			4*2,u
				stb			5*2+1,x

				ldb			#0
				lda			2*2+1,x
				std			0x24*2,u
				lda			6*2+1,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				stb			2*2+1,x
				ldd			4*2,u
				stb			6*2+1,x

				ldb			#0
				lda			3*2+1,x
				std			0x24*2,u
				lda			7*2+1,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				stb			3*2+1,x
				ldd			4*2,u
				stb			7*2+1,x

				dec			*i
				lbpl		inner_loop
								
				SWSDK_HALT

				jmp			loop

sdk_msg:
				.ascii	"STAR WARS SDK V0.0."
				.byte		(1<<7)|'2

IRQ::
				SWSDK_ACK_IRQ
				rti
