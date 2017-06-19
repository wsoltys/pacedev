; apple2.inc

PAGE2OFF = $C054
PAGE2ON = $C055

; asteroid2.asm

.global dvg_curr_addr_lsb 	: zeropage
.global dvg_curr_addr_msb 	: zeropage
.global byte_B 							: zeropage
.global byte_C 							: zeropage
.global coinMultCredits			: zeropage

.global coinage
.global centerCoinMultiplierAndLives

; apple2.asm
.global apple_reset
.global apple_start
.global apple_render_frame