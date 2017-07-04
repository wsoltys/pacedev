; apple2.inc

KBD 					= $C000				; b7=new key, b6..0=key scan code
KBDSTRB 			= $C010

; soft switch and status locations

_80STOREOFF 	= $C000
_80STOREON 		= $C001
MAINMEM				= $C003
AUXMEM				= $C005
_80COLOFF 		= $C00C
_80COLON 			= $C00D

_80STORE 			= $C018				; 1=PAGE2 switches main/aux, 0=switches video pages
TEXT 					= $C01A				; 1=text mode, 0=graphics mode
MIXED 				= $C01B				; 1=mixed, 0=full screen graphics
PAGE2 				= $C01C				; 1=video page 2 OR aux video
HIRES 				= $C01D				; 1=hires, 0=lores
_80COL 				= $C01F				; 1=80-column, 0=40-column

NEWVIDEO			= $C029				; b7=1 enable SHR, b6=1 linear, b5=1 mono DHR
SHADOW				= $C035				; b3=0 enable SHR
TEXTOFF 			= $C050
TEXTON 				= $C051
MIXEDOFF 			= $C052
MIXEDON 			= $C053
PAGE2OFF 			= $C054
PAGE2ON 			= $C055
HIRESSOFF 		= $C056
HIRESON 			= $C057

; extra IIGS stuff

RDMAINRAM			= $E0C002
RDCARDRAM			= $E0C003
WRMAINRAM			= $E0C004
WRCARDRAM			= $E0C005

;SHRMEM				= $012000
; adjust to centre 256x192 display
; - offset by (320-256)/2=32 pixels = 16 ($10) bytes
; - and by (200-192)/2=4 lines = 4*160=640 ($280) bytes
SHRMEM				= $012290

; asteroid2.asm

.global dvg_curr_addr_lsb 	: zeropage
.global dvg_curr_addr_msb 	: zeropage
.global byte_B 							: zeropage
.global byte_C 							: zeropage
.global CurrNumCredits			: zeropage
.global coinMultCredits			: zeropage

; IN0
.global hyperspaceSwitch
.global FireSwitch

; IN1
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

.macro HINT_IIGSMODE
	.A16
	.I16
.endmacro

.macro IIGSMODE
	clc
	xce
	rep #(1<<5)|(1<<4)
	HINT_IIGSMODE
.endmacro

.macro HINT_IIMODE
	.A8
	.I8
.endmacro

.macro IIMODE
	sec
	xce
	HINT_IIMODE
.endmacro
