; Star Wars SDK
;
; 6809 CPU vectors

				.list		(meb)										; macro expansion binary
       	.area   _CODE (ABS,OVR)
				.module cpuvecs

				.globl 	IRQ
				.globl 	RESET

				.org		0xFFE0

NMI:
				bra			NMI

				.org		0xFFF0
				
				.dw			0x0C85					; reserved
				.dw			NMI							; SWI3
				.dw			NMI							; SWI2
				.dw			NMI							; FIRQ
				.dw			IRQ							; IRQ
				.dw			NMI							; SWI1
				.dw			NMI							; NMI
				.dw			RESET						; RESET
