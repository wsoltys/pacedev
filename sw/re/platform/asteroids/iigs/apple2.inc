; apple2.inc

KBD 					= $C000				; b7=new key, b6..0=key scan code
KBDSTRB 			= $C010

; soft switch and status locations

_80STOREOFF 	= $C000
_80STOREON 		= $C001
_80COLOFF 		= $C00C
_80COLON 			= $C00D

_80STORE 			= $C018				; 1=PAGE2 switches main/aux, 0=switches video pages
TEXT 					= $C01A				; 1=text mode, 0=graphics mode
MIXED 				= $C01B				; 1=mixed, 0=full screen graphics
PAGE2 				= $C01C				; 1=video page 2 OR aux video
HIRES 				= $C01D				; 1=hires, 0=lores
_80COL 				= $C01F				; 1=80-column, 0=40-column

TEXTOFF 			= $C050
TEXTON 				= $C051
MIXEDOFF 			= $C052
MIXEDON 			= $C053
PAGE2OFF 			= $C054
PAGE2ON 			= $C055
HIRESSOFF 		= $C056
HIRESON 			= $C057

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