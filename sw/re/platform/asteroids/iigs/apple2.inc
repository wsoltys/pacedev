; apple2.inc

KBD = $C000
KBDSTRB = $C010
PAGE2OFF = $C054
PAGE2ON = $C055

; asteroid2.asm

.global dvg_curr_addr_lsb 	: zeropage
.global dvg_curr_addr_msb 	: zeropage
.global byte_B 							: zeropage
.global byte_C 							: zeropage
.global CurrNumCredits			: zeropage
.global coinMultCredits			: zeropage

.global leftCoinSwitch
.global centerCoinSwitch
.global rightCoinSwitch
.global p1StartSwitch
.global p2StartSwitch
.global thrustSwitch
.global rotateRightSwitch
.global rotateLeftSwitch

.global coinage
.global centerCoinMultiplierAndLives

; apple2.asm
.global apple_reset
.global apple_start
.global apple_render_frame