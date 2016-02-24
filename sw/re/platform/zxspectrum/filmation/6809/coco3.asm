;
; *** COCO registers
;

PIA0				.equ		0xFF00
PIA1				.equ		0xFF20

KEYCOL			.equ		PIA0+2
KEYROW			.equ		PIA0

;
; *** GIME registers  	
;

INIT0				.equ		0xFF90
INIT1				.equ		0xFF91
IRQENR			.equ		0xFF92
FIRQENR			.equ		0xFF93
TMRMSB			.equ		0xFF94
TMRLSB			.equ		0xFF95
VMODE				.equ		0xFF98
VRES				.equ		0xFF99
BRDR				.equ		0xFF9A
VSC					.equ		0xFF9C
VOFFMSB			.equ		0xFF9D
VOFFLSB			.equ		0xFF9E
HOFF				.equ		0xFF9F
MMUTSK1			.equ		0xFFA0
MMUTSK2			.equ		0xFFA8
PALETTE			.equ		0xFFB0
CPU089			.equ		0xFFD8
CPU179			.equ		0xFFD9
ROMMODE			.equ		0xFFDE
RAMMODE			.equ		0xFFDF

;
; *** FILMATION-SPECIFIC CONFIGURATION HERE
;

;.define       CARTRIDGE
.define			GFX_1BPP
;.define     GFX_RGB

; *** derived - do no edit

.ifndef GFX_1BPP
	.define		GFX_4BPP
.endif
.ifndef GFX_RGB
  .define   GFX_COMPOSITE
.endif

.ifdef GFX_1BPP
	VIDEO_BPP			.equ	1
.else
	VIDEO_BPP			.equ	4
.endif

; *** end of derived

;
; Memory Map		Page
; ------------  ----
; $0000-$3BFF   $30-$31		HGR1
; $3F00-$3FFF   $31				Zero Page
; $4000-$7BFF   $32-$33		HGR2
; $7C00-$7FFF		$33				Level Data 1,2
; $8000-$9AXX   $34				Tile Graphics Data
; $A000-$BXXX		$35				Title Screen, Game Over Data
; $C000-$F965   $36-$37		Program Code & ROM Data
; $FA00-$FCFF   $37       RAM
;      -$FE00   $37				6809 System Stack
;

ZEROPAGE				.equ			0x5c00
codebase				.equ		  0x6010
stack						.equ		  0x7fff

;.define HAS_SOUND
.ifdef HAS_SOUND
  .define USE_1BIT_SOUND
  .ifdef USE_1BIT_SOUND
    SOUND_ADDR  .equ		PIA1+2
    SOUND_MASK  .equ    (1<<1)
  .else
    .define USE_DAC_SOUND
    SOUND_ADDR  .equ		PIA1
    SOUND_MASK  .equ    0xfc
  .endif
.endif
  
; MMU page mappings
VIDEOPAGE   .equ        0x30
;GFXPAGE			.equ				0x34
;CODEPAGE		.equ				0x36

; Spectrum Palette for Coco3
; - spectrum format : B=1, R=2, G=4
; -     coco format : RGBRGB

                .org      codebase-16

speccy_pal:
;       black, blue, red, magenta, green, cyan, yellow, grey/white
.ifdef GFX_RGB
        .db 0x00<<0, 0x01<<0, 0x04<<0, 0x05<<0, 0x02<<0, 0x03<<0, 0x06<<0, 0x07<<0
        .db 0x00*9, 0x01*9, 0x04*9, 0x05*9, 0x02*9, 0x03*9, 0x06*9, 0x07*9
.else
        .db 0, 12, 7, 9, 3, 29, 4, 32
        .db 0, 28, 23, 41, 17, 61, 51, 63
.endif
