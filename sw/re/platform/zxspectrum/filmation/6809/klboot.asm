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
        .ascii  "The game Lode Runner itself should need no introduction, having received        "
        .ascii  "numerous ports, clones and sequels on dozens of platforms over 3 decades from   "
        .ascii  "8-bit machines to current-generation consoles, and spawning no less than 5      "
        .ascii  "arcade games.                                                                   "
        .ascii  "                                                                                "
        .ascii  "However for me, there is no substitute for the original 1983 Apple II version.  "
        .ascii  "                                                                                "
        .ascii  "This is the culmination of an effort to recreate the original Apple II Lode     "
        .ascii  "Runner experience on another platform; in this case the Coco3. After reverse-   "
        .ascii  "engineering the Apple II machine code, I wrote a line-by-line hand-translation  "
        .ascii  "of the original 6502 instructions to their 6809 counterparts. Every pixel, every"
        .ascii  "nuance of game-play logic has been painstakingly reproduced. Ports simply don't "
        .ascii  "get any more faithful than this.                                                "
        .ascii  "                                                                                "
        .ascii  "The port is avaiable in both monochrome and colour versions. The colour version "
        .ascii  "emulates the Apple II colour artifacting as closely as possible, as per MESS.   "
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
        