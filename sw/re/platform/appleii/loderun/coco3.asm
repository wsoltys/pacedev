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

HGR1_MSB		.equ		0x00
HGR2_MSB		.equ		0x40

						.macro HGR1
						lda			#0xDF								; screen at page $38
						sta			VOFFMSB
						.endm

						.macro HGR2
						lda			#0xE7								; screen at page $40
						sta			VOFFMSB
						.endm

;
; *** LODE RUNNER SPECIFIC CONFIGURATION HERE
;

;.define			GFX_1BPP
;.define			GFX_MONO

.ifndef GFX_1BPP
	.define		GFX_2BPP
.endif
.ifndef GFX_MONO
	.define		GFX_COLOUR
.endif

; *** These macros are only used for the experimental mode
; *** where the title screen was colourised on-the-fly
; *** from the original monochrome tile data
; *** - no longer used
;
.ifdef GFX_MONO
					.macro GFX_BYTE
						lsra												; b0->C
						rorb												; C->b7
						asrb												; b7->b7..b6
						lsra												; b1->C
						rorb												; C->b7
						asrb												; b7->b7..b6
						lsra												; b2->C
						rorb												; C->b7
						asrb												; b7->b7..b6
						lsra												; b3->C
						rorb												; C->b7
						asrb												; b7->b7..b6
					.endm
.else
					.macro GFX_NIBBLE
						pshs		a
						lsra												; b0->C
						rorb												; C->b7
						lsra												; b1->C
						rorb												; C->b7, b7->b6
						puls		a
						lsra												; b0->C
						rorb												; C->b7, b7..6->b6..5
						lsra												; b1->C
						rorb												; C->b7, b7..5->b6..4
					.endm
					.macro GFX_BYTE
						GFX_NIBBLE
						GFX_NIBBLE
					.endm
.endif						

.ifdef GFX_1BPP
	VIDEO_BPP			.equ	1
.else
	VIDEO_BPP			.equ	2
.endif

VIDEO_BPL     	.equ  VIDEO_BPP*40
VIDEO_RM				.equ	VIDEO_BPP*5
APPLE_BPL				.equ	VIDEO_BPL-VIDEO_RM
						
;
; Memory Map		Page
; ------------  ----
; $0000-$3BFF   $38				HGR1
; $4000-$7BFF   $39				HGR2
; $7F00-$7FFF   $39				Zero Page
; $8000-        $34-$35		Program Code & Data
;      -$BFFF   $35				6809 System Stack
; $C000-$EXXX   $36-$37		Tile Graphics Data
; $EX00-$       $37				Title Screen Data
;

ZEROPAGE		.equ				0x7f00
codebase		.equ		  	0x8000
stack				.equ		  	0xC000

.define	TILES_EXTERNAL
.ifdef TILES_EXTERNAL
  tile_data	  .equ	  	0xC000
.endif

.define	HAS_TITLE
.define	TITLE_EXTERNAL
.ifdef TITLE_EXTERNAL
	.ifdef GFX_1BPP
  	title_data	.equ	  0xE3C0
 .else
  	title_data	.equ	  0xE000
 .endif
.endif

.define HAS_SOUND
.ifdef HAS_SOUND
  ;.define USE_1BIT_SOUND
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
CODEPAGE		.equ				0x34
GFXPAGE			.equ				0x36

;.define			LEVELS_EXTERNAL
