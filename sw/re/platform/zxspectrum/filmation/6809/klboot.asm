;
; LODE RUNNER - LOADER
; - ported from the original Apple II version
; - by tcdev 2014 msmcdoug@gmail.com
;
        .list   (meb)                   ; macro expansion binary
        
        .area   idaseg (ABS)

.include "coco3.asm"

.define	ENABLE_SPLASH

        ; $4000
        .org    0x4000

start:
; get parameter from BASIC loader
;        jsr     0xb3ed                  ; D=parameter
;        std     param
        
				orcc		#0x50										; disable interrupts
        lda     #0x4c
        sta     INIT0
        lda     #0x03                   ; text mode
        sta     VMODE
        lda     #0x15
        sta     VRES
        lda     #0x12
        sta     BRDR
				lda			#(VRAM_PG<<2)           ; screen at page $38
        sta     VOFFMSB
        lda     #0x00
        sta     VOFFLSB
        lda     #VRAM_PG
        sta     MMUTSK1
        inca
        sta     MMUTSK1+1
        lda     #0x00                   ; black text
        sta     PALETTE+1

.ifdef ENABLE_SPLASH
; display splash screen       
        ldx     #splash
        ldy     #0
        ldb     #0
1$:     lda     ,x+
        bita    #(1<<7)
        beq     2$
        anda    #0x7f
        tfr     a,b                     ; attribute
        bra     1$        
2$:     sta     ,y+
        stb     ,y+
        cmpx    #eos
        bne     1$        

        ldx     #PIA0
        ldb     #0                      ; all columns
flush:  stb     2,x                     ; column strobe
        lda     ,x
        coma                            ; active high
        bne     flush                   ; wait for no key
wait:   stb     2,x                     ; column strobe
        lda     ,x        
        coma                            ; active high
        beq     wait                    ; wait for key
.endif

        lda     #CODE_PG1               ; code bank
        ldx     #MMUTSK1+4              ; $8000
        ldb     #4
1$:     sta     ,x+                     ; switch in code,data banks
        inca
        decb
        bne     1$
        
2$:     jmp     0xc000                  ; jump to Lode Runner

;param:  .dw     0

GREEN_BG          .equ    0
BLACK_BG          .equ    1
BLACK_TEXT        .equ    (0<<3)
WHITE_TEXT        .equ    (3<<3)

BLACK_ON_GREEN    .equ    (1<<7)|BLACK_TEXT|GREEN_BG
WHITE_ON_GREEN    .equ    (1<<7)|WHITE_TEXT|GREEN_BG
WHITE_ON_BLACK    .equ    (1<<7)|WHITE_TEXT|BLACK_BG

splash:
;       .ascii  "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
        .db     WHITE_ON_BLACK
        .ascii  "            ZX Spectrum Knight Lore for the TRS-80 Color Computer 3      (Demo) "
        .db     BLACK_ON_GREEN
        .ascii  "                                                                                "
        .ascii  "Released in 1984 by Ultimate Play the game, Knight Lore was a seminal title for "
        .ascii  "the ZX Spectrum and would popularise isometric graphics in computer games in the"
        .ascii  "years that followed. A smash hit upon release, it was followed up with two      "
        .ascii  "spiritual sequels, Alien 8 and Pentagram, with only minor updates to the        "
        .ascii  "filmation engine at the core of the game.                                       "
        .ascii  "                                                                                "
        .ascii  "This project began with a complete reverse-engineering of the original Z80 code."
        .ascii  "I then re-coded the game in C, to facilitate porting of the game to more capable"
        .ascii  "platforms such as the Amiga and the Neo Geo. Finally, I translated the original "
        .ascii  "Z80 listing to 6809 in order to replicate the exact behaviour - every nuance and"
        .ascii  "even every bug (except one) - of the ZX Spectrum game. The graphics data has    "
        .ascii  "been lifted directly from the Z80 code; it's a pixel-perfect port, they simply  "
        .ascii  "don't get any more faithful than this.                                          "
        .ascii  "                                                                                "
        .ascii  "Due to the nature of the hardware, this port is a little less colourful than the"
        .ascii  "Z80 spectrum original, but this has no affect at all on the game play.          "
        .ascii  "                                                                                "
        .ascii  "Comments, suggestions or bug reports may be submitted via comments on the       "
        .ascii  "greater project website: "
        .db     WHITE_ON_GREEN
        .ascii  "<www.retroports.blogspot.com.au>"
        .db     BLACK_ON_GREEN
        .ascii  " where you can find    "
        .ascii  "commentary on this and other retro porting projects.                            "
        .ascii  "                                                                                "
        .db     WHITE_ON_BLACK
        .ascii  "                             Press any key to play                              "
eos:

        .end    start
        