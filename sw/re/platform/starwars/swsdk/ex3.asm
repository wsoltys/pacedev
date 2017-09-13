;
;	Star Wars SDK
; - Example 3 (mathbox)

				.list		(meb)										; macro expansion binary
				.module ex3

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

				; cos(45)<<14=11585, sin(45)<<14=11585
				; cos(5)<<14=16322, sin(5)<<14=1428
				; cos(1)<<14=16382, sin(1)<<14=286
				; cos(0.25)<<14=16384, sin(0.25)<<14=71
				; cos(0.05)<<14=16384, sin(0.05)<<14=14
				COS_THETA = 16322
				SIN_THETA = 1428
				TRIG_SHIFT = 0
rotation_matrix:
								.word		COS_THETA>>TRIG_SHIFT, 	-(SIN_THETA>>TRIG_SHIFT), 	0,	0
								.word		SIN_THETA>>TRIG_SHIFT, 	COS_THETA>>TRIG_SHIFT, 			0,	0
								.word		0, 											0,													0,	0

				POINT_SHIFT = 2
rectangle_vertices:
								.word		0<<POINT_SHIFT,			0<<POINT_SHIFT
								.word		0<<POINT_SHIFT,			255<<POINT_SHIFT
								.word		255<<POINT_SHIFT,		255<<POINT_SHIFT
								.word		255<<POINT_SHIFT,		0<<POINT_SHIFT
RESET::
       
       	lds			#SWSDK_CpuRAMEnd
     		jsr			SWSDK_Init

				SWSDK_ACK_IRQ
				andcc		#~(1<<4)												; enable IRQ

				ldy			#SWSDK_VectorRAMStart
				SWSDK_JMPL 0x1802												; simulate other buffer
				SWSDK_HALT															; empty 1st half

				; init an object (rectangle)
				ldx			#rectangle_vertices
				ldu			#object
				ldb			#4*2														; 4 coordinate pairs
1$:			ldy			,x++														; from ROM
				sty			,u++														; to RAM
				decb
				bne			1$
				
				; init rotation matrix
				ldu			#SWSDK_MathRAMStart
				leau		0x14*2,u												; start of 'C' in OP$40 routine
				ldx			#rotation_matrix
				ldb			#3*3
2$:			ldy			,x++														; from ROM
				sty			,u++														; to MATH RAM
				decb
				bne			2$

FRAME_DELAY			.equ		60
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
				SWSDK_VCTR -256,-360,0
				SWSDK_COLOR SWSDK_GREEN,255
				ldx			#sdk_msg
				jsr			SWSDK_RenderString
				SWSDK_CNTR
				SWSDK_VCTR -470,-440,0
				SWSDK_COLOR SWSDK_WHITE,128
				ldx			#title_msg
				jsr			SWSDK_RenderString

				; *** RENDER THE OBJECT

				SWSDK_CNTR
				SWSDK_SCAL 2+POINT_SHIFT,0
				lda			SWSDK_BLUE
				ora			#>SWSDK_OP_COLOR
				ldb			#0xFF
				std			,y++

				ldx			#object
				lda			#4															; 4 vectors
				sta			*cnt

				; hack - this only works because
				; V0=(0,0) and V(3+1)=(0,0)
render:										
				ldd			3*2,x														; x2
				subd		1*2,x														; -x1
				anda		#0x1F
				ora			#>SWSDK_OP_VCTR
				std			,y++
				ldd			2*2,x														; y2
				subd		0*2,x														; -y1
				anda		#0x1F
				ora			#(7<<5)
				std			,y++
				leax		4,x															; next vertice
				dec			*cnt
				bne			render

				dec			*delay
				bne			skip_rot
				lda			#FRAME_DELAY
				sta			*delay

				; *** 2D ROTATION AROUND THE ORIGIN				

				ldu			#SWSDK_MathRAMStart
				lda			#4
				sta			*cnt
				ldx			#object
rotate:
				ldd			,x															; x
				std			0x24*2,u
				ldd			2,x															; y
				std			0x28*2,u
				lda			#SWSDK_MATH_OP_3x3MatrixMultiply
				jsr			SWSDK_GoMathAndWait
				ldd			0x03*2,u												; rotated x
				std			,x++
				ldd			0x04*2,u												; rotated y
				std			,x++
				dec			*cnt
				bne			rotate

skip_rot:

				SWSDK_HALT

				jmp			loop

sdk_msg:
				.ascii	"STAR WARS SDK "
				SWSDK_SZ_VERSION

title_msg:
				.ascii	"EX3: MATHBOX OP40 - 3X3 MATRIX MULTIPL"
				.byte		(1<<7)|'Y
				
IRQ::
				SWSDK_ACK_IRQ
				rti
