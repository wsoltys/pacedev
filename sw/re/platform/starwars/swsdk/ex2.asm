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
i 			.equ 		0x80								
col			.equ		0x81

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

				; init a rectangle
				POINT_SHIFT = 2
				ldx			#x
				ldy			#y
				ldd			#0<<POINT_SHIFT
				std			0*2,x
				std			0*2,y
				std			1*2,x
				std			3*2,y
				ldd			#255<<POINT_SHIFT
				std			1*2,y
				std			2*2,x
				std			2*2,y
				std			3*2,x
				
				; cos(45)<<14=11585, sin(45)<<14=11585
				; cos(5)<<14=16322, sin(5)<<14=1428
				; cos(1)<<14=16382, sin(1)<<14=286
				; cos(0.25)<<14=16384, sin(0.25)<<14=71
				; cos(0.05)<<14=16384, sin(0.05)<<14=14
				COS_THETA = 16322
				SIN_THETA = 1428
				TRIG_SHIFT = 0
				; init rotation matrix
				; [cos -sin ..] [$14 $15 ..]
				; [sin  cos ..] [$18 $19 ..]
				ldu			#SWSDK_MathRAMStart
				ldd			#(COS_THETA>>TRIG_SHIFT)
				std			0x14*2,u
				std			0x19*2,u
				ldd			#-(SIN_THETA>>TRIG_SHIFT)
				std			0x15*2,u
				ldd			#(SIN_THETA>>TRIG_SHIFT)
				std			0x18*2,u

				clr			*col
speed		.equ		60
				lda			#speed
				sta			*i
				
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
				SWSDK_COLOR SWSDK_GREEN,255
				ldx			#sdk_msg
				jsr			SWSDK_RenderString
				SWSDK_CNTR
				SWSDK_VCTR -400,-440,0
				SWSDK_COLOR SWSDK_WHITE,128
				ldx			#title_msg
				jsr			SWSDK_RenderString

				; render it
				SWSDK_CNTR
				SWSDK_SCAL 2+POINT_SHIFT,0

				inc			*col
				lda			*col
				lda			SWSDK_BLUE
				anda		#0x07
				ora			#>SWSDK_OP_COLOR
				ldb			#0xFF
				std			,y++

				ldx			#x
								
				ldd			5*2,x
				subd		4*2,x
				anda		#0x1F
				ora			#>SWSDK_OP_VCTR
				std			,y++
				ldd			1*2,x
				subd		0*2,x
				anda		#0x1F
				ora			#(7<<5)
				std			,y++

				ldd			6*2,x
				subd		5*2,x
				anda		#0x1F
				ora			#>SWSDK_OP_VCTR
				std			,y++
				ldd			2*2,x
				subd		1*2,x
				anda		#0x1F
				ora			#(7<<5)
				std			,y++

				ldd			7*2,x
				subd		6*2,x
				anda		#0x1F
				ora			#>SWSDK_OP_VCTR
				std			,y++
				ldd			3*2,x
				subd		2*2,x
				anda		#0x1F
				ora			#(7<<5)
				std			,y++

				ldd			4*2,x
				subd		7*2,x
				anda		#0x1F
				ora			#>SWSDK_OP_VCTR
				std			,y++
				ldd			0*2,x
				subd		3*2,x
				anda		#0x1F
				ora			#(7<<5)
				std			,y++

				dec			*i
				bne			skip_rot
				lda			#speed
				sta			*i
				
				ldu			#SWSDK_MathRAMStart

				; rotate a point
				; [x y ..] = [$24 $28 ..]
				ldd			0*2,x
				std			0x24*2,u
				ldd			4*2,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				std			0*2,x
				ldd			4*2,u
				std			4*2,x

				ldd			1*2,x
				std			0x24*2,u
				ldd			5*2,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				std			1*2,x
				ldd			4*2,u
				std			5*2,x

				ldd			2*2,x
				std			0x24*2,u
				ldd			6*2,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				std			2*2,x
				ldd			4*2,u
				std			6*2,x

				ldd			3*2,x
				std			0x24*2,u
				ldd			7*2,x
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_40
				jsr			SWSDK_GoMathAndWait
				
				ldd			3*2,u
				std			3*2,x
				ldd			4*2,u
				std			7*2,x

skip_rot:

				SWSDK_HALT

				jmp			loop

sdk_msg:
				.ascii	"STAR WARS SDK V0.0."
				.byte		(1<<7)|'2

title_msg:
				.ascii	"MATH BOX OP 40: 3X3 MATRIX MULTIPL"
				.byte		(1<<7)|'Y
				
IRQ::
				SWSDK_ACK_IRQ
				rti
