; Star Wars SDK
;
; 6809 CPU vectors

				.list		(meb)										; macro expansion binary
       	.area   CPUVECS (ABS,OVR)
				.module cpuvecs

				.globl 	RESET
				.globl	SWSDK_IRQ
				
				.org		0xFFE0

NMI:
				bra			NMI

				.org		0xFFF0
				
				.dw			0x0C85					; reserved
				.dw			NMI							; SWI3
				.dw			NMI							; SWI2
				.dw			NMI							; FIRQ
				.dw			SWSDK_IRQ				; IRQ
				.dw			NMI							; SWI1
				.dw			NMI							; NMI
				.dw			RESET						; RESET
