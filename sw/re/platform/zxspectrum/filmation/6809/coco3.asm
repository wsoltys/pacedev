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
.define     GFX_RGB

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
; $0000-$17FF   $38       Video
; $1800-$1FFF             (empty)
; $2000-$3FFF   $39				Code
; $4000-$5FFF   $3A       Code?
; $6000-$7FFF		$3B				Code?
; $8000-$9FFF   $30				Font and graphics data
; $A000-$BFFF   $31				Font and graphics data
; $C000-$DFFF   $32				Font and graphics data
; $E000-$FFFF   $37				???
;
; most alternate pages are used by Coco3 BASIC
; eg. page 34 is the HPUT/HGET buffer
; and is written whilst BASIC is running
; $30-$33 are the alternate HIRES page, so safe

coco_vram       .equ      0x0000
codebase				.equ		  0x2000
stack						.equ		  0x7fff
database        .equ      0x8000

; MMU page mappings
VRAM_PG         .equ      0x38
CODE_PG1        .equ      0x39
CODE_PG2        .equ      CODE_PG1+1
CODE_PG3        .equ      CODE_PG2+1
DATA_PG1        .equ      0x30
DATA_PG2        .equ      DATA_PG1+1
DATA_PG3        .equ      DATA_PG2+1

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

; Coco Keyboard
;    7  6  5  4  3  2  1  0
;	0: G  F  E  D  C  B  A  @
; 1: O  N  M  L  K  J  I  H
; 2: W  V  U  T  S  R  Q  P
; 3: SP RT LT DN UP Z  Y  X
; 4: '  &  %  $  #  "  !  0
; 4: 7  6  5  4  3  2  1  0
; 5: ?  >  =  <  +  *  )  (
; 5: /  .  _  ,  ;  :  9  8
; 6: SH F2 F1 CT AL BK CL CR

