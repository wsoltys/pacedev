;
; *** 6809 stuff
;

  .macro	CCF
    andcc		#~(1<<0)
  .endm
  .macro	SCF
    orcc		#(1<<0)
  .endm
  .macro  EI
    andcc   #~(1<<4)                    ; enable IRQ in CPU    
  .endm
  .macro  DI
    orcc    #(1<<4)                     ; disable IRQ in CPU    
  .endm

;
; *** COCO registers
;

PIA0				.equ		0xFF00
PIA1				.equ		0xFF20
DATAA       .equ    0x00
DDRA        .equ    DATAA
CRA         .equ    0x01
DATAB       .equ    0x02
DDRB        .equ    DATAB
CRB         .equ    0x03

KEYCOL			.equ		PIA0+2
KEYROW			.equ		PIA0

;
; *** GIME registers  	
;

INIT0				.equ		0xFF90
COCO        .equ    1<<7
MMUEN       .equ    1<<6
IEN         .equ    1<<5
FEN         .equ    1<<4
MC3         .equ    1<<3
MC2         .equ    1<<2
MC1         .equ    1<<1
MC0         .equ    1<<0
INIT1				.equ		0xFF91
TINS        .equ    1<<5
TR          .equ    1<<0
IRQENR			.equ		0xFF92
FIRQENR			.equ		0xFF93
TMR         .equ    1<<5
HBORD       .equ    1<<4
VBORD       .equ    1<<3
EI2         .equ    1<<2
EI1         .equ    1<<1
EI0         .equ    1<<0
TMRMSB			.equ		0xFF94
TMRLSB			.equ		0xFF95
VMODE				.equ		0xFF98
BP          .equ    1<<7
BPI         .equ    1<<5
MOCH        .equ    1<<4
H50         .equ    1<<3
VRES				.equ		0xFF99
BRDR				.equ		0xFF9A
VSC					.equ		0xFF9C
VOFFMSB			.equ		0xFF9D
VOFFLSB			.equ		0xFF9E
HOFF				.equ		0xFF9F
HVEN        .equ    1<<7
MMUTSK1			.equ		0xFFA0
MMUTSK2			.equ		0xFFA8
PALETTE			.equ		0xFFB0
CPU089			.equ		0xFFD8
CPU179			.equ		0xFFD9
ROMMODE			.equ		0xFFDE
RAMMODE			.equ		0xFFDF

; some graphics/memory calculations

.define GFX_1BPP
.ifdef GFX_1BPP
  VIDEO_BPL     .equ    32
.else
  VIDEO_BPL     .equ    64
.endif
  VIDEO_SIZ     .equ    VIDEO_BPL*192


; most alternate pages are used by Coco3 BASIC
; eg. page 34 is the HPUT/HGET buffer
; and is written whilst BASIC is running
; $30-$33 are the alternate HIRES page, so safe

; Memory Map		Page
; ------------  ----
; $0000-$2FFF   $38/$39   vram
; $3000-$5FFF   $39/$3A   vid_buf
; $6000-$6FFF   $3B       shift_tbl
; $7000-$73FF    "        wram
; $7400-$7FFF    "        stack
; $8000-$BFXX   $30-$31   (unused)
; $C000-$FFXX   $32-$33   Code+Data

CODE_PG1    .equ    0x30
VRAM_PG     .equ    0x38
; these are Coco VRAM, not SI VRAM
VRAM_MSB    .equ    (0x39<<2)
;VRAM_LSB    .equ    0x00
VRAM_LSB    .equ    32*(32/8)

vram        .equ    0x0000
cocovram    .equ    0x2000
vidbuf      .equ    VIDEO_SIZ
shift_tbl   .equ    0x6000
WRAM        .equ    0x7000
stack       .equ    0x7fff
code_base		.equ		0xC000

; values for 63.5us tick
; 60Hz/2 / 63.695us = ~130.8
TMR_8ms     .equ    131
TMR_9ms     .equ    141
TMR_9m5s    .equ    149
TMR_10ms    .equ    157
TMR_260ms   .equ    0x0fff

; equates to keyboard rows
; - phantom keys appear accordingly
RJOY_BTN1   .equ    (1<<0)
LJOY_BTN1   .equ    (1<<1)
RJOY_BTN2   .equ    (1<<2)
LJOY_BTN2   .equ    (1<<3)

;.define LEFT_JOYSTICK
.ifdef LEFT_JOYSTICK
  JOY_BTN1  .equ    LJOY_BTN1
  JOY_BTN2  .equ    LJOY_BTN2
.else
  .define RIGHT_JOYSTICK
  JOY_BTN1  .equ    RJOY_BTN1
  JOY_BTN2  .equ    RJOY_BTN2
.endif
; high and low thresholds 
; for 'digital' operation
JOY_LO_TH   .equ    0x64                ; ~40%
JOY_HI_TH   .equ    0x98                ; ~60%

.define HAS_SOUND
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

; Spectrum Palette for Coco3
; - spectrum format : B=1, R=2, G=4
; -     coco format : RGBRGB

ATTR_BLACK      .equ  0
ATTR_BLUE       .equ  1
ATTR_RED        .equ  2
ATTR_MAGENTA    .equ  3
ATTR_GREEN      .equ  4
ATTR_CYAN       .equ  5
ATTR_YELLOW     .equ  6
ATTR_WHITE      .equ  7

RGB_DARK_BLACK    .equ  0x00
RGB_DARK_BLUE     .equ  0x01
RGB_DARK_RED      .equ  0x04
RGB_DARK_MAGENTA  .equ  0x05
RGB_DARK_GREEN    .equ  0x02
RGB_DARK_CYAN     .equ  0x03
RGB_DARK_YELLOW   .equ  0x06
RGB_GREY          .equ  0x07

RGB_BLACK         .equ  RGB_DARK_BLACK*9
RGB_BLUE          .equ  RGB_DARK_BLUE*9
RGB_RED           .equ  RGB_DARK_RED*9
RGB_MAGENTA       .equ  RGB_DARK_MAGENTA*9
RGB_GREEN         .equ  RGB_DARK_GREEN*9
RGB_CYAN          .equ  RGB_DARK_CYAN*9
RGB_YELLOW        .equ  RGB_DARK_YELLOW*9
RGB_WHITE         .equ  RGB_GREY*9
                  
CMP_BLACK         .equ  0
CMP_BLUE          .equ  28
CMP_RED           .equ  23
CMP_MAGENTA       .equ  41
CMP_GREEN         .equ  17
CMP_CYAN          .equ  61
CMP_YELLOW        .equ  51
CMP_WHITE         .equ  63

CMP_DARK_BLACK    .equ  0
CMP_DARK_BLUE     .equ  12
CMP_DARK_RED      .equ  7
CMP_DARK_MAGENTA  .equ  9
CMP_DARK_GREEN    .equ  3
CMP_DARK_CYAN     .equ  29
CMP_DARK_YELLOW   .equ  4
CMP_GREY          .equ  32
