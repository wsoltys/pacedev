; apple2.inc

; asteroid2.asm

.global dvg_curr_addr_lsb 	: zeropage
.global dvg_curr_addr_msb 	: zeropage
.global byte_B 							: zeropage
.global byte_C 							: zeropage
.global coinMultCredits			: zeropage

.global coinage

; video.asm
.global apple_reset
.global apple_render_frame