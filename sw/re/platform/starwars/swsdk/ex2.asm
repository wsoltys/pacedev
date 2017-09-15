;
;	Star Wars SDK
; - Example 2 (test pattern routines & trigger)

				.list		(meb)										; macro expansion binary
				.module ex2

.include "swsdk.inc"

; *** BUILD OPTIONS
;.define BUILD_OPT_PROFILE
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

				.area		DATA (ABS,OVR)
				.org		SWSDK_CpuRAMStart

								.ds			256											; for DP (MAIN)
cnt			.equ		0x80
delay		.equ 		0x81
in0 		.equ    0x82
in1     .equ    0x83
								.ds			256											; for DP (IRQ)

				.bank   ROM (BASE=0xE000,SIZE=0x1FE0)
       	.area   ROM (REL,CON,BANK=ROM)

RESET::
        ; this MUST be the first instruction       
     		jmp			SWSDK_Init

				SWSDK_ACK_IRQ
				andcc		#~(1<<4)												; enable IRQ

				ldy			#SWSDK_VectorRAMStart
				SWSDK_JMPL 0x1802												; simulate other buffer
				SWSDK_HALT															; empty 1st half

        lda     #0
				sta     *cnt
				lda     #0
				sta     *in0
				sta     *in1
				
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
				SWSDK_CNTR
				SWSDK_VCTR -250,280,0
				SWSDK_COLOR SWSDK_YELLOW,128
				SWSDK_SCAL 2,96                         ; text a bit smaller
				ldx			#trigger_msg
				jsr			SWSDK_RenderString

        ; check for leading-edge button press
    
        lda     SWSDK_in0_shadow+2              ; debounced
        coma                                    ; active high
        ldb     *in0                            ; B=prev (active high)
        sta     *in0                            ; A=curr (prev=curr)
        eorb    *in0                            ; B=changed bits
        andb    *in0                            ; gone high
        bitb    #SWSDK_IN0_BUTTON1n             ; button 1 high?
        beq     0$                              ; no, skip
        inc     *cnt
0$:			lda			*cnt
			  cmpa		#1
				bne			1$
				SWSDK_JSRL SWSDK_IntensityTestPattern
				bra			3$
1$:			cmpa		#2
				bne			2$				
				SWSDK_JSRL SWSDK_CrossHatchAndFont
				bra			3$
2$:			clr			*cnt
				SWSDK_COLOR SWSDK_RED,128
				SWSDK_JSRL SWSDK_SquareHatch
3$:			

				SWSDK_HALT

				jmp			loop

sdk_msg:
				.ascii	"STAR WARS SDK "
				SWSDK_SZ_VERSION

title_msg:
				.ascii	"EX2: TEST PATTERN"
				.byte		(1<<7)|'S

trigger_msg:
				.ascii	"PRESS TRIGGER FOR NEXT PATTER"
				.byte		(1<<7)|'N
