      ORG 4096

BITMAP EQU $8000                      Location of bitmap screen
CHRBUF EQU $f87c                      Character screen compare RAM
CHRSIZ EQU 1024
SPRBUF EQU $fc7e+8                    Sprite data compare RAM
SPRSIZ EQU 384-8
LASTSPR EQU $6A34                     $6A80 address of last sprite (skip some unused sprites..)

NEWSPR EQU 1

      SETDP 16

; z80 registers
;
REGF  RMB 1
REGA  RMB 1
REGB  RMB 1
REGC  RMB 1
REGBC EQU REGB
REGD  RMB 1
REGE  RMB 1
REGDE EQU REGD
REGH  RMB 1
REGL  RMB 1
REGHL EQU REGH
REGXH RMB 1
REGXL RMB 1
REGIX EQU REGXH
REGYH RMB 1
REGYL RMB 1
REGIY EQU REGYH

BAKX  RMB 1                           Register toggle flag (BAK/BAX)
BAKBC RMB 2
BAKDE RMB 2
BAKHL RMB 2
BAXBC RMB 2
BAXDE RMB 2
BAXHL RMB 2

; donkey kong variables
;
REFRES FDB SPRBUF
OLDJOY FCB $00
IN0    FCB $00                        7c00 Inputs 0 $10=jump, $08=down, $04=up, $02=left, $01=right
IN1    FCB $00                        7c80 Inputs 1
IN2    FCB $00                        7d00 Inputs 2 $80=coin, $04=start1, $08=start2
DSW1   FCB $80                        7d80 Dip Switches
TICK   FCB $00                        IRQ counter
TICK2  FCB $00                        FRAME counter
TICK3  FCB $00
TOGGLE FCB $30                        Frame buffer toggle

; sound decompressor variables
;
DOWN  FCB 0
UP    FCB 0
STEP  FCB 1
OUTBK FCB $0
INBK  FCB $1e
FOUR  FCB 4

; sound variables
;
MUSIC FCB 0
EFFEC FCB $ff
ETIME FCB 0
V1BNK FCB 4
V2BNK FCB 0

L0008 LDB $6007       LD A,($6007)    13ce 06b9 051d 031c Attract mode flag
      LSRB            RRCA
      BCC L000f       RET NC
LSKIP LEAS 2,S        INC SP
;                     INC SP
L000f RTS             RET

L0010 LDB $6200       LD A,($6200)    2ed7 2e07 2dde 2c92 2c06 03a5 Flag - Is Mario alive?
      LSRB            RRCA            Yes, return
      BCC LSKIP       RET C           No, skip call then return
;     LEAS 2,S        INC SP
;                     INC SP
L0017 RTS             RET

L0018 LDX #$6009      LD HL,$6009     3069 186f 178e 168a 1670 1421 13a1 138f 12de 12ac 128b 123c 0c91 0bdd 0bd1 0abf 0a63 0024
      DEC ,X          DEC (HL)
      BNE LSKIP       RET Z
;     LEAS 2,S        INC SP
;                     INC SP
L001f RTS             RET

L0028 ASLB            ADD A,A
      PULS X          POP HL
;                     LD E,A
;                     LD D,$00
;                     JP $0032
      ABX             ADD HL,DE       002d
      LDX ,X+         LD E,(HL)       endian fix
;                     INC HL
;                     LD D,(HL)
;     EXG Y,X         EX DE,HL
      JMP ,X          JP (HL)

L0038 LDY #$0004      LD DE,$0004     0d90 0d89 307c 2dd9 1885 1864 1857 180e 16df 16b5 1688 166e 0b84 0b7e 0b37 0b31 0b1c 0ad1 0acb 082b 0825 0485 0460 040a
      LDA #$0a        LD B,$0A
      STA REGB 
L003d LDB REGC        LD A,C          0da3 0d9a 18b4 0041
      ADDB ,X         ADD A,(HL)
      STB ,X          LD (HL),A
      LEAX 4,X        ADD HL,DE       DE is always 4
      DEC REGB        DJNZ $003D
      BNE L003d
LRTS  RTS             RET

;                     JR $0044        29b1 3fa8 33a3 2fcd 2ed6 2e06 2ddd 2c91 2c05 2956 26fc 25f4 24ec 2209 1e43 1a35 1682 1668 03a4
L0030 LDX #$6227      LD HL,$6227     0030 Level Type
      LDA ,X          LD B,(HL)
L0048 LSRB            RRCA            0049
      BCC L0049
      ORB #128      
L0049 DECA            DJNZ $0048
      BNE L0048
      STA REGB 
      BCS LRTS        RET C
      PULS X,PC       POP HL

L004e LDY #$6908      LD DE,$6908     0d6f 2dd1 2d3b 1873 185c 184f 1806 16f1 16ae 168e 1674 165a 0b21 0ac3 081d 0472 0448
      LDA #20         LD BC,$0028
      STU REGIX 
L0054 LDU ,X++        LDIR
      STU ,Y++
      DECA
      BNE L0054
      LDU REGIX 
      RTS             RET

; FIRQ sound routine
;
FIRQ   STA <FPAT+1    ;4              store A
       LDA 65427      ;5              FIRQ ACK
       LDA #33        ;2
       STA 65425      ;5              enable second mmu task
V1ADDR LDA $658b      ;5              load 1st voice (music)
V2ADDR ADDA $89ff     ;5  bb xx xx    add 2nd voice (effect)
       STA 65312      ;5  b7 ff 20    output to DAC

;V2ADDR ADDA #68      ;2  8b 44       alternate code - when v2 is stopped
;       STA 65312     ;5  b7 ff 20
;       JMP V2OK      ;3  0e xx

       DEC V2ADDR+2   ;6  0a xx       decrement voice 2 LSB
       BHI V2OK       ;3              *** DANGIT!! THIS NEEDS TO BRANCH WHEN V2ADDR+2 == $FF ***
       dec V2ADDR+2                   *** cheapo patch to skip xx00 address ***
       DEC V2ADDR+1                   decrement voice 2 MSB
       BMI V2OK
       LDA #$9f                       reset MSB to next bank
       STA V2ADDR+1
       LDA V2BNK
       DECA                           decrement MMU bank
V2EBNK CMPA #$00                      reached end of sample?
       BGE V2OKB
       lda #$8b                       modify thyself to stop voice channel
       sta V2ADDR
       lda #$44
       sta V2ADDR+1
       lda #$b7
       sta V2ADDR+2
       lda #$ff
       sta V2ADDR+3
       lda #$20
       sta V2ADDR+4
       lda #$0e
       sta V2ADDR+5
       lda #V2OK&$FF
       sta V2ADDR+6
;V2LLSB LDA #$ff                       reload voice 2 loop LSB
;       STA V2ADDR+2
;V2LMSB LDA #$89                       reload voice 2 loop MSB
;       STA V2ADDR+1
;V2LBNK LDA #$00                       reload voice 2 loop bank
V2OKB  STA 65452
       STA V2BNK

V2OK   INC V1ADDR+2   ;6              increment voice 1 LSB
       BNE V1OK       ;3
       INC V1ADDR+1                   increment voice 1 MSB
       BPL V1OK
       LDA #$60                       reset MSB to next bank
       STA V1ADDR+1
       LDA V1BNK
       INCA                           increment MMU bank
V1EBNK CMPA #$05                      reached end of sample?
       BLS V1OKB
V1LLSB LDA #$00                       reload voice 1 loop LSB
       STA V1ADDR+2
V1LMSB LDA #$7e                       reload voice 1 loop MSB
       STA V1ADDR+1
V1LBNK LDA #$05                       reload voice 1 loop bank
V1OKB  STA 65451
       STA V1BNK

V1OK   LDA #32        ;2
       STA 65425      ;5              re-enable primary mmu task
FPAT   LDA #00        ;2              restore A
       RTI            ;6

;                                     GET RANDOM NUMBER
L0057 LDB $6018       LD A,($6018)    308b 2eba 2c41 256e 2545 00b9
;                     LD HL,$601A
      ADDB $601a      ADD A,(HL)      ADD FIRST TIMER
;                     LD HL,$6019
      ADDB $6019      ADD A,(HL)      ADD SECOND TIMER
RANDP ADDB #0                         57 coco hack extra randomizer
      STB $6018       LD ($6018),A    STORE AGAIN
      RTS             RET

L0020 DEC $6008       LD HL,$6008     084b 0763
;                     DEC (HL)
      BNE L002x
      JMP L0018       JR Z,$0018
L002x PULS X,PC       POP HL          1787 0603
;     RTS             RET

L0000 ORCC #$50                       Disable 6809 interrupts for now...
;     CLRB            LD A,$00        00b2
;     STB $7d84       LD ($7D84),A    Disable Interrupts
      LDB #16
      TFR B,DP
      SETDP 16
      JMP L0266       JP $0266

;L0066                PUSH AF         60Hz interrupt routine
L0066 LDD REGBC       PUSH BC
;                     PUSH DE
;                     PUSH HL
;                     PUSH IX
      LDX REGIY       PUSH IY
      PSHS D,X
;     CLRB            XOR A
;     STB $7d84       LD ($7D84),A    Disable Interrupts
;                     LD A,($7D00)    Inputs 2
;                     AND $01
;                     JP NZ,$4000
;     JSR L0141       CALL $0141
      LDB $6007       LD A,($6007)    Attract mode flag
;                     AND A
      BNE L00b5       JP NZ,$00B5
      LDB $6026       LD A,($6026)
;                     AND A
      BNE L0098       JP NZ,$0098
      LDA IN1         LD A,($7C80)    Inputs 1
      LDB $600e       LD x,($600E)
;                     AND x
      BNE L009b       JP NZ,$009B
L0098 LDA IN0         LD A,($7C00)    008b Inputs 0
L009b STA REGB        LD B,A          0095
      ANDA #$0f       AND $0F
      STA REGC        LD C,A
      LDA $6011       LD A,($6011)
      COMA            CPL
      ANDA REGB       AND B
      ANDA #$10       AND $10         Z80-AND makes carry=0
      LSLA            RLA
      ROLA            RLA
      ROLA            RLA
      ORA REGC        OR C
      LDB REGB        LD H,B
;     TFR D,X         LD L,A
      STD $6010       LD ($6010),HL   <- endian swapped Joystick inputs
;                     LD A,B
;                     BIT 6,A
;                     JP NZ,$0000     system reset!
;L00b5 LDX #$601a      LD HL,$601A     0084
L00b5 DEC $601a       DEC (HL)
      BSR L0057       CALL $0057
      JSR L017b       CALL $017B
      BSR L00e0       CALL $00E0
      LDX #L00d2      LD HL,$00D2     push resume of IRQ address onto stack
      PSHS X          PUSH HL
      LDB $6005       LD A,($6005)
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L01c3
      FDB L073c
      FDB L08b2
      FDB L06fe

L00d2 PULS D,X        POP IY          finish IRQ
      STX REGIY 
;                     POP IX
;                     POP HL
;                     POP DE
      STD REGBC       POP BC
;     LDB #$01        LD A,$01
;     STB $7d84       LD ($7D84),A    Enable Interrupts
;     PULS Y,U,PC     POP AF
      RTS             RET

L00e0 LDX #$6080      LD HL,$6080     00bf
      LDY #$7d00      LD DE,$7D00     Digital Sound Triggers
      LDB $6007       LD A,($6007)    Attract mode flag
;                     AND A
      BNE L011b       RET NZ
      LDA #$08        LD B,$08
L00ed LDB ,X          LD A,(HL)       00f8
;                     AND A
      BEQ L00f5       JP Z,$00F5
      DEC ,X          DEC (HL)
      LDB #$01        LD A,$01
L00f5 STB ,Y+         LD (DE),A       00ef
;                     INC E
      LEAX 1,X        INC L
      DECA            DJNZ $00ED
      BNE L00ed
      STA REGB 
      LDX #$608b      LD HL,$608B
      LDB ,X          LD A,(HL)
;                     AND A
      BNE L0108       JP NZ,$0108
;                     DEC L
;                     DEC L
      LDB ,--X        LD A,(HL)
      BRA L010b       JP $010B
L0108 DEC ,X          DEC (HL)        00ff
;                     DEC L
      LDB ,-X         LD A,(HL)
L010b STB $7c00       LD ($7C00),A    0105 Background Sound/Music select
      LDX #$6088      LD HL,$6088
      CLRB            XOR A
      CMPB ,X         CP (HL)
      BEQ L0118       JP Z,$0118
      DEC ,X          DEC (HL)
      INCB            INC A
L0118 STB $7d80       LD ($7D80),A    0113 Sound Trigger - dead
L011b RTS             RET

L011c LDA #$08        LD B,$08        19ca 17b7 1708 1344 12f2 0bda 0989 02b5 0195
      CLRB            XOR A
      LDX #$7d00      LD HL,$7D00     Digital Sound Triggers
      LDY #$6080      LD DE,$6080
L0125 STB ,X+         LD (HL),A       0129
      STB ,Y+         LD (DE),A
;                     INC L
;                     INC E
      DECA            DJNZ $0125
      BNE L0125
      LDA #$04        LD B,$04
L012d STB ,Y+         LD (DE),A       012f
;                     INC E
      DECA            DJNZ $012D
      BNE L012d
      STA REGB 
      STB $7d80       LD ($7D80),A    Stop Sound - dead
      STB $7c00       LD ($7C00),A    Background Sound/Music select
      RTS             RET

;                                     Unknown???
;L0138 FCB $53,$00,$69,$80,$41,$00,$70,$80,$81
;
;L0141 LDX #L0138      LD HL,$0138     007d
;      CLRB            XOR A           what do these addresses do???
;      STB $7d85       LD ($7D85),A    0/1 Toggle
;      LDB ,X+         LD A,(HL)
;      STB $7808       LD ($7808),A
;;                     INC HL
;      LDB ,X+         LD A,(HL)
;      STB $7800       LD ($7800),A
;;                     INC HL
;      LDB ,X+         LD A,(HL)
;      STB $7800       LD ($7800),A
;;                     INC HL
;      LDB ,X+         LD A,(HL)
;      STB $7801       LD ($7801),A
;;                     INC HL
;      LDB ,X+         LD A,(HL)
;      STB $7801       LD ($7801),A
;;                     INC HL
;      LDB ,X+         LD A,(HL)
;      STB $7802       LD ($7802),A
;;                     INC HL
;      LDB ,X+         LD A,(HL)
;      STB $7802       LD ($7802),A
;;                     INC HL
;      LDB ,X+         LD A,(HL)
;      STB $7803       LD ($7803),A
;;                     INC HL
;      LDB ,X          LD A,(HL)
;      STB $7803       LD ($7803),A
;      LDB #$01        LD A,$01
;      STB $7d85       LD ($7D85),A    0/1 Toggle
;      CLRB            XOR A
;      STB $7d85       LD ($7D85),A    0/1 Toggle
;      RTS             RET

L017b LDB IN2         LD A,($7D00)    00bc Inputs 2
      LDX #$6003      LD HL,$6003
      TSTB            BIT 7,A
      BMI L0189       JP NZ,$0189
      LDA #$01        LD (HL),$01
      STA ,X
      RTS             RET
L0189 lda PAL+3                       fiddle with GIME palette registers directly
      ldb PAL+5
      sta $ffb3                       restore normal palette
      stb $ffb5
      LDB ,X          LD A,(HL)       0183
;                     AND A
      BEQ L01b9       RET Z
      PSHS X          PUSH HL
      LDB $6005       LD A,($6005)
      CMPB #$03       CP $03
      BEQ L019d       JP Z,$019D
      JSR L011c       CALL $011C
      LDB #$03        LD A,$03
      STB $6083       LD ($6083),A
L019d PULS X          POP HL          0192
      CLR ,X          LD (HL),$00
;                     DEC HL
      INC ,-X         INC (HL)
      LDY #$6024      LD DE,$6024
      LDB ,Y          LD A,(DE)
      SUBB ,X         SUB (HL)
      BNE L01b9       RET NZ
      STB ,X          LD (HL),A
      LEAY 1,Y        INC DE
;                     DEC HL
      EXG Y,X         EX DE,HL
      LDA ,-Y         LD A,(DE)
      CMPA #$90       CP $90
      BCC L01b9       RET NC
      ADDA ,X         ADD A,(HL)
      DAA             DAA
      STA ,Y          LD (DE),A
      LDY #$0400      LD DE,$0400
      JSR L309f       CALL $309F
L01b9 RTS             RET

;                                     Initial Score & High Score on bootup
L01ba FCB $00,$37,$00,$aa,$aa
L01bf FCB $aa,$50,$76,$00

L01c3 JSR L0874       CALL $0874
      LDX #L01ba      LD HL,$01BA
      LDY #$60b2      LD DE,$60B2
      LDB #$09        LD BC,$0009
L01cf LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L01cf
      LDB #$01        LD A,$01
      STB $6007       LD ($6007),A    Set Attract mode flag
      STB $6229       LD ($6229),A
      STB $6228       LD ($6228),A
      JSR L06b8       CALL $06B8
      BSR L0207       CALL $0207
      LDB #$01        LD A,$01
      STB $7d82       LD ($7D82),A    Flip Screen
      STB $6005       LD ($6005),A
      STB $6227       LD ($6227),A    Level Type
      CLRB            XOR A
      STB $600a       LD ($600A),A    Game Screen Sequencer
      JSR L0a53       CALL $0A53
      LDY #$0304      LD DE,$0304
      JSR L309f       CALL $309F
      LDY #$0202      LD DE,$0202
      JSR L309f       CALL $309F
      LDY #$0200      LD DE,$0200
      JSR L309f       CALL $309F
      RTS             RET

L0207 LDB DSW1        LD A,($7D80)    01df DIP Switches
      STB REGC        LD C,A
      LDX #$6020      LD HL,$6020
      ANDB #$03       AND $03
      ADDB #$03       ADD A,$03
      STB ,X+         LD (HL),A
;                     INC HL
      LDB REGC        LD A,C
      RORB            RRCA
      RORB            RRCA
      LDA #$07        LD A,$07        line moved
      ANDB #$03       AND $03
;                     LD B,A
      BEQ L0226       JP Z,$0226
      LDA #$05        LD A,$05
L0221 ADDA #$05       ADD A,$05       0224
      DAA             DAA
      DECB            DJNZ $0221
      BNE L0221
L0226 STA ,X+         LD (HL),A       021c
;                     INC HL
      LDB REGC        LD A,C
      STU REGIX 
      LDU #$0101      LD BC,$0101
      STU REGBC 
      LDU #$0102      LD DE,$0102
      STU REGDE 
      ANDB #$70       AND $70
      LSLB            RLA
      ROLB            RLA
      ROLB            RLA
      ROLB            RLA
      BEQ L0247       JP Z,$0247
      BCS L0241       JP C,$0241
      INCB            INC A
      STB REGC        LD C,A
      LDA REGD        LD E,D
      STA REGE 
      BRA L0247       JP $0247
L0241 ADDB #$02       ADD A,$02       0238
      STB REGB        LD B,A
      STB REGD        LD D,A
      ASLB            ADD A,A
      STB REGE        LD E,A
L0247 LDU REGDE       LD (HL),D       023e 0235
      STU ,X++        INC HL
;                     LD (HL),E
;                     INC HL
      LDU REGBC       LD (HL),B
      STU ,X++        INC HL
;                     LD (HL),C
;                     INC HL
      LDB DSW1        LD A,($7D80)    DIP Switches
      ROLB            RLCA
      LDB #$01        LD A,$01
      BCS L0259       JP C,$0259
      DECB            DEC A
L0259 STB ,X          LD (HL),A       0255
      LDX #L3565      LD HL,$3565     High Score table
      LDY #$6100      LD DE,$6100
      LDA #85         LD BC,$00AA
L0263 LDU ,X++        LDIR
      STU ,Y++
      DECA
      BNE L0263
      LDU REGIX 
      RTS             RET

L0266 LDS #$6c00                      initialise stack pointer
      JSR GSET                        copy character set to $0000 RAM
      LDA #$10        LD B,$10        0005 boot up initialisation
      STA REGB                        clear 16 pages of RAM at $6000
      LDX #$6000      LD HL,$6000
      CLRB            XOR A
L026c CLRA            LD C,A          0272
L026d STB ,X+         LD (HL),A       0270
;                     INC HL
      DECA            DEC C
      BNE L026d       JR NZ,$026D
      DEC REGB        DJNZ $026C
      BNE L026c
      LDA #$04        LD B,$04        clear 4 pages of RAM at $7000
      STA REGB 
      LDX #$7000      LD HL,$7000
L0279 CLRA            LD C,A          027f
L027a STB ,X+         LD (HL),A       027d
;                     INC HL
      DECA            DEC C
      BNE L027a       JR NZ,$027A
      DEC REGB        DJNZ $0279
      BNE L0279
      LDA #$04        LD B,$04        fill 4 pages of RAM at $7400 with $10
      STA REGB 
      LDB #$10        LD A,$10
      LDX #$7400      LD HL,$7400
L0288 CLRA            LD C,$00        028f
L028a STB ,X+         LD (HL),A       028d
;                     INC HL
      DECA            DEC C
      BNE L028a       JR NZ,$028A
      DEC REGB        DJNZ $0288
      BNE L0288
      LDX #$60c0      LD HL,$60C0     fill $40 bytes at $60c0 with $ff
      LDA #$40        LD B,$40
      LDB #$ff        LD A,$FF
L0298 STB ,X+         LD (HL),A       029a
;                     INC HL
      DECA            DJNZ $0298
      BNE L0298
      LDB #$c0        LD A,$C0
      STB $60b0       LD ($60B0),A
      STB $60b1       LD ($60B1),A
      CLRB            XOR A
      STB $7d83       LD ($7D83),A    Unknown???
      STB $7d86       LD ($7D86),A    BG Palette select
      STB $7d87       LD ($7D87),A    BG Palette select
      JSR SETPAL
      INCB            INC A
      STB $7d82       LD ($7D82),A    Flip Screen
;     LDS #$6c00      LD SP,$6C00     initialise stack pointer
      JSR L011c       CALL $011C
;     LDB #$01        LD A,$01
;     STB $7d84       LD ($7D84),A    Enable Interrupts

      LDX #$FEF7                      6809 IRQ address
      LDD #$b6ff                      "LDA $FFxx
      STD ,X++
      LDD #$020c                            xx02 INC xx
;     LDD #$920c                            xx92 INC xx
      STD ,X++
      LDD #(TICK&$ff)*$100+$3b                    xx TICK RTI
      STD ,X

      LDB #$35
      STB $ff03                       Turn on PIA 60hz IRQ

      ANDCC #$AF                      Enable 6809 IRQ & FIRQ
      LDA #1
      STA TICK

L02bd INC TICK3                       02e1 02d8 XXXX (INSERT INTERRUPT TRAP HERE!!!)
      LDA TICK3
      ANDA #$7
      BEQ WAITT
      LDA TICK
      BEQ WAITT
      DEC TICK2
      BEQ DOGRF
      CMPA #2
      BHI SKIPG

;DOGRF PSHS Y,U
;      lda #18
;      sta 65434                       testing - set border color
DOGRF JSR ERASS
;      lda #36
;      sta 65434                       testing - set border color
      JSR DRAWC
;      lda #9
;      sta 65434                       testing - set border color
      JSR DRAWS
      jsr TOGGS
;      PULS Y,U
      LDA #7
      STA TICK2
;SKIPG lda #7
;      sta 65434                       testing - set border color
SKIPG JSR JOYIN                       (also DECs TICK)
      JSR DOSND
;      lda #54
;      sta 65434                       testing - set border color
      JSR L0066
;      lda #0
;      sta 65434                       testing - set border color
      
WAITT LDA #$60        LD H,$60
      LDB $60b1       LD A,($60B1)
      TFR D,X         LD L,A
      LDB ,X          LD A,(HL)
      ASLB            ADD A,A
      BCC L02e3       JR NC,$02E3
      BSR L0315       CALL $0315
      JSR L0350       CALL $0350
;                     LD HL,$6019
      INC $6019       INC (HL)
      LDX #$6383      LD HL,$6383
      LDB $601a       LD A,($601A)
      CMPB ,X         CP (HL)
      BEQ L02bd       JR Z,$02BD
      STB ,X          LD (HL),A
      JSR L037f       CALL $037F
      JSR L03a2       CALL $03A2
      BRA L02bd       JR $02BD
L02e3 ANDB #$1f       AND $1F         02c5
      CLRA            LD D,$00
      TFR D,Y         LD E,A
      LDA #$ff        LD (HL),$FF
      STA ,X+         INC L
      LDB ,X          LD C,(HL)
      STB REGC 
      STA ,X+         LD (HL),$FF
;                     INC L
      TFR X,D         LD A,L
      CMPB #$c0       CP $C0
      BCC L02f6       JR NC,$02F6
      LDB #$c0        LD A,$C0
L02f6 STB $60b1       LD ($60B1),A    02f2
      LDB REGC        LD A,C
      LDX #L02bd      LD HL,$02BD     this is a return address!
      PSHS X          PUSH HL
;                     LD HL,$0307
      LEAY L0307,Y    ADD HL,DE
      LDX ,Y          LD E,(HL)       endian fix
;                     INC HL
;                     LD D,(HL)
;     EXG Y,X         EX DE,HL
      JMP ,X          JP (HL)
;                                     JUMP TABLE
L0307 FDB L051c
      FDB L059b
      FDB L05c6
      FDB L05e9
      FDB L0611
      FDB L062a
      FDB L06b8

L0315 LDB $601a       LD A,($601A)    02c7
      STB REGB        LD B,A
      ANDB #$0f       AND $0F
      BNE L0346       RET NZ
      JSR L0008       RST $08
      LDB $600d       LD A,($600D)
      BSR L0347       CALL $0347
;                     LD DE,$FFE0
      LDA REGB        BIT 4,B
      ANDA #16
      BEQ L033e       JR Z,$033E
      LDB #$10        LD A,$10
      STB ,X          LD (HL),A
      LEAX -32,X      ADD HL,DE
      STB ,X          LD (HL),A
      LEAX -32,X      ADD HL,DE
      STB ,X          LD (HL),A
      LDB $600f       LD A,($600F)
;                     AND A
      BEQ L0346       RET Z
      LDB $600d       LD A,($600D)
      EORB #$01       XOR $01
      BSR L0347       CALL $0347
L033e INCB            INC A           0328
      STB ,X          LD (HL),A
      LEAX -32,X      ADD HL,DE
      LDA #$25        LD (HL),$25
      STA ,X
      LEAX -32,X      ADD HL,DE
      LDA #$20        LD (HL),$20
      STA ,X
L0346 RTS             RET

L0347 LDX #$7740      LD HL,$7740     033b 0320
      TSTB            AND A
      BEQ L0346       RET Z
      LDX #$74e0      LD HL,$74E0
      RTS             RET

L0350 LDB $622d       LD A,($622D)    02ca loops often while waiting for IRQ?
;                     AND A
      BNE L0346       RET NZ
      LDX #$60b3      LD HL,$60B3
      LDB $600d       LD A,($600D)
;                     AND A
      BEQ L0361       JR Z,$0361
      LDX #$60b6      LD HL,$60B6
L0361 LDB ,X+         LD A,(HL)       035c
;                     AND $F0
;                     LD B,A
;                     INC HL
      LDA ,X          LD A,(HL)
;                     AND $0F
;                     OR B
      LSRA            RRCA
      RORB
      LSRA            RRCA
      RORB
      LSRA            RRCA
      RORB
      LSRA            RRCA
      RORB
      LDX #$6021      LD HL,$6021
      CMPB ,X         CP (HL)
      BCS L0346       RET C
      LDB #$01        LD A,$01
      STB $622d       LD ($622D),A
      LDX #$6228      LD HL,$6228     current level data 8-bytes
      INC ,X          INC (HL)
      JMP L06b8       JP $06B8

L037f LDX #$6384      LD HL,$6384     02db
      LDB ,X          LD A,(HL)
      INC ,X          INC (HL)
      TSTB            AND A
      BNE L03a1       RET NZ
      LDX #$6381      LD HL,$6381
      LDA ,X          LD A,(HL)
      STA REGB        LD B,A
      INC ,X          INC (HL)
      ANDA #$07       AND $07
      BNE L03a1       RET NZ
      LDB REGB        LD A,B
      LDA REGB
      LSRB            RRCA
      RORA
      LSRB            RRCA
      RORA
      LSRB            RRCA
      RORA
      STA REGB        LD B,A
      LDB $6229       LD A,($6229)
      ADDB REGB       ADD A,B
      CMPB #$05       CP $05
      BCS L039e       JR C,$039E
      LDB #$05        LD A,$05
L039e STB $6380       LD ($6380),A    039a
L03a1 RTS             RET

L03a2 LDB #$03        LD A,$03        02de
      JSR L0030       RST $30
      JSR L0010       RST $10
      LDB $6350       LD A,($6350)
      RORB            RRCA
      BCS L03a1       RET C
      LDX #$62b8      LD HL,$62B8
      DEC ,X          DEC (HL)
      BNE L03a1       RET NZ
      LDA #$04        LD (HL),$04
      STA ,X
      LDB $62b9       LD A,($62B9)
      RORB            RRCA
      BCC L03a1       RET NC
      LDX #$6a29      LD HL,$6A29
      LDA #$40        LD B,$40
      LDU #$66a0      LD IX,$66A0
      RORB            RRCA
      BCC L03e4       JP NC,$03E4
      LDB #$02        LD (IX+$09),$02
      STB $9,U 
      STB $a,U        LD (IX+$0A),$02
      ADDA #2         INC B
;                     INC B
      BSR L03f2       CALL $03F2
      LDX #$62ba      LD HL,$62BA
      DEC ,X          DEC (HL)
      BNE L03a1       RET NZ
      LDB #$01        LD A,$01
      STB $62b9       LD ($62B9),A
      STB $63a0       LD ($63A0),A
L03de LDB #$10        LD A,$10        03ef
      STB $62ba       LD ($62BA),A
      RTS             RET
L03e4 LDB #$02        LD (IX+$09),$02 03c1
      STB $9,U 
      CLR $a,U        LD (IX+$0A),$00
      BSR L03f2       CALL $03F2
      BRA L03de       JP $03DE

L03f2 STA ,X          LD (HL),B       03ec 03ce
      LDB $6019       LD A,($6019)
      RORB            RRCA
      BCS L03fa       RET C
      INCA            INC B
      STA ,X          LD (HL),B
L03fa RTS             RET

;                                     animate kong & pauline
L03fb LDB $6227       LD A,($6227)    19b0 get level type
      CMPB #$02       CP $02          is it conveyor belt level?
      BNE L0413       JP NZ,$0413     no, skip side-to-side movement
      LDX #$6908      LD HL,$6908     HL = Start of Kong sprite make-up
      LDB $63a3       LD A,($63A3)    Get Top Conveyor Speed/Direction
      STB REGC        LD C,A          C = Kong location adjustment
      JSR L0038       RST $38         Adjust Kong location with Conveyor
      LDB $6910       LD A,($6910)    Get Kong Sprite3 X position
      SUBB #$3b       SUB $3B         Subtract 59 (for cement)
      STB $63b7       LD ($63B7),A    Save Cement Kong moving X position
L0413 LDB $6391       LD A,($6391)    0400 Get Kong Thrash status
;                     AND A           Is Kong's trashing arms?
      BNE L0426       JP NZ,$0426     Yes, so handle Thrash Animation
      LDB $601a       LD A,($601A)    Get General Purpose Timer
;                     AND A           Is it time to start thrashing?
      BNE L0486       JP NZ,$0486     No, so go animate Lady
      LDB #$01        LD A,$01        Start Thrashing
      STB $6391       LD ($6391),A    Set Kong Thrash status = 1
L0426 LDX #$6390      LD HL,$6390     0417 HL = Kong Animation Timer
      INC ,X          INC (HL)        Increment Timer
      LDB ,X          LD A,(HL)       Get Kong Animation Timer
      CMPB #$80       CP $80          Is Thrashing finished?
      BEQ L0464       JP Z,$0464      Yes, so draw Kong with mouth closed
      LDB $6393       LD A,($6393)    Check Barrel Deployment Indicator
;                     AND A           Is a deployment in progress?
      BNE L0486       JP NZ,$0486     Yes, so don't thrash arms
      LDB ,X          LD A,(HL)       Get Kong Animation Timer
      STB REGB        LD B,A          Save Get Kong Animation Timer (B)
      ANDB #$1f       AND $1F         Is it time to thrash arms?
      BNE L0486       JP NZ,$0486     Not yet, so animate Lady
      LDX #L39cf      LD HL,$39CF     Thrash arms-->
      LDA REGB        BIT 5,B
      ANDA #32
      BNE L0448       JR NZ,$0448
      LDX #L39f7      LD HL,$39F7
L0448 JSR L004e       CALL $004E      0443
      LDB #$03        LD A,$03
      STB $6082       LD ($6082),A
L0450 LDB $6227       LD A,($6227)    0475 Level Type
      RORB            RRCA
      BCC L0478       JP NC,$0478
      RORB            RRCA
      BCS L0486       JP C,$0486
      LDX #$690b      LD HL,$690B
      LDA #$fc        LD C,$FC
      STA REGC 
      JSR L0038       RST $38
      BRA L0486       JP $0486
L0464 CLRB            XOR A           042d Draw Kong with mouth closed
      STB ,X+         LD (HL),A
;                     INC HL
      STB ,X          LD (HL),A
      LDB $6393       LD A,($6393)
;                     AND A
      BNE L0486       JP NZ,$0486
      LDX #L385c      LD HL,$385C
      JSR L004e       CALL $004E
      BRA L0450       JP $0450
L0478 LDX #$6908      LD HL,$6908     0454
      LDA #$44        LD C,$44
      STA REGC 
      RORB            RRCA
      BCC L0485       JP NC,$0485
      LDB $63b7       LD A,($63B7)
      STB REGC        LD C,A
L0485 JSR L0038       RST $38         047e
L0486 LDB $6390       LD A,($6390)    046c 0461 0458 043b 0434 041e Animate pauline
      STB REGC        LD C,A
      LDY #$0020      LD DE,$0020
      LDB $6227       LD A,($6227)    Level Type
      CMPB #$04       CP $04
      BEQ L04be       JP Z,$04BE
      LDB REGC        LD A,C
;                     AND A
      BEQ L04a1       JP Z,$04A1
      LDB #$ef        LD A,$EF
      LDA REGC        BIT 6,C
      ANDA #64
      BNE L04a3       JP NZ,$04A3
L04a1 LDB #$10        LD A,$10        0497
L04a3 LDX #$75c4      LD HL,$75C4     049e
      BSR L0514       CALL $0514
      LDB $6905       LD A,($6905)
L04ac STB $6905       LD ($6905),A    0506 04ee
      LDA REGC        BIT 6,C
      ANDA #64
      BEQ L04bd       RET Z
      STB REGB        LD B,A
      LDB REGC        LD A,C
      ANDB #$07       AND $07
      BNE L04bd       RET NZ
      LDB REGB        LD A,B
      EORB #$03       XOR $03
      STB $6905       LD ($6905),A
L04bd RTS             RET
L04be LDB #$10        LD A,$10        0492
      LDX #$7623      LD HL,$7623
      BSR L0514       CALL $0514
      LDX #$7583      LD HL,$7583
      BSR L0514       CALL $0514
      LDA REGC        BIT 6,C
      ANDA #64
      BEQ L0509       JP Z,$0509
      LDB $6203       LD A,($6203)    mario X position
      CMPB #$80       CP $80
      BCC L04f1       JP NC,$04F1
      LDB #$df        LD A,$DF
      LDX #$7623      LD HL,$7623
      BSR L0514       CALL $0514
L04e1 LDB $6901       LD A,($6901)    0511
      ORB #$80        OR $80
      STB $6901       LD ($6901),A
      LDB $6905       LD A,($6905)
      ORB #$80        OR $80
      BRA L04ac       JP $04AC
L04f1 LDB #$ef        LD A,$EF        04d6
      LDX #$7583      LD HL,$7583
      BSR L0514       CALL $0514
L04f9 LDB $6901       LD A,($6901)    050e
      ANDB #$7f       AND $7F
      STB $6901       LD ($6901),A
      LDB $6905       LD A,($6905)
      ANDB #$7f       AND $7F
      BRA L04ac       JP $04AC
L0509 LDB $6203       LD A,($6203)    04ce mario X position
      CMPB #$80       CP $80
      BCC L04f9       JP NC,$04F9
      BRA L04e1       JP $04E1

L0514 LDA #$03        LD B,$03        17d0 17ca 1726 04f6 04de 04c9 04c3 04a6
      STA REGB 
L0516 STB ,X          LD (HL),A       0519
      STB REGA        ADD HL,DE
      TFR Y,D
      LEAX D,X
      LDB REGA 
      DECB            DEC A
      DEC REGB        DJNZ $0516
      BNE L0516
      RTS             RET

L051c STB REGC        LD C,A          06a5 0698
      JSR L0008       RST $08
      BSR L055f       CALL $055F
      LDB REGC        LD A,C
      ADDB REGC       ADD A,C
      ADDB REGC       ADD A,C
;                     LD C,A
      LDX #L3529      LD HL,$3529     Bonus Points Table
;                     LD B,$00
      ABX             ADD HL,BC
      CLRA            AND A           clear carry
      LDB #$03        LD B,$03
L052e LDA ,Y          LD A,(DE)       0534
      ADCA ,X+        ADC A,(HL)
      DAA             DAA
      STA ,Y+         LD (DE),A
;                     INC DE
;                     INC HL
      DECB            DJNZ $052E
      BNE L052e
      PSHS Y          PUSH DE
      LEAY -1,Y       DEC DE
      LDB $600d       LD A,($600D)
      BSR L056b       CALL $056B
      PULS Y          POP DE
      LEAY -1,Y       DEC DE
      LDX #$60ba      LD HL,$60BA
      LDA #$03        LD B,$03
L0545 LDB ,Y          LD A,(DE)       054d
      CMPB ,X         CP (HL)
      BCS L054f       RET C
      BNE L0550       JP NZ,$0550
      LEAY -1,Y       DEC DE
      LEAX -1,X       DEC HL
      DECA            DJNZ $0545
      BNE L0545
L054f RTS             RET
L0550 BSR L055f       CALL $055F      0548
      LDX #$60b8      LD HL,$60B8
L0556 LDB ,Y+         LD A,(DE)       055a
      STB ,X+         LD (HL),A
;                     INC DE
;                     INC HL
      DECA            DJNZ $0556
      BNE L0556
      JMP L05da       JP $05DA

L055f LDY #$60b2      LD DE,$60B2     0550 051e
      LDB $600d       LD A,($600D)
;                     AND A
      BEQ L056a       RET Z
      LDY #$60b5      LD DE,$60B5
L056a RTS             RET

L056b LDU #$7781      LD IX,$7781     05d7 053b
      TSTB            AND A
      BEQ L057c       JR Z,$057C      Print score
      LDU #$7521      LD IX,$7521
      BRA L057c       JR $057C        Print score
L0578 LDU #$7641      LD IX,$7641     05dd

L057c TFR Y,X         EX DE,HL        15ad 0576 0570 Print score
;     LDY #$ffe0      LD DE,$FFE0     unnecessary?
      LDD #$0304      LD BC,$0304
      STD REGBC 

L0583 LDB ,X          LD A,(HL)       0627 0590
      RORB            RRCA
      RORB            RRCA
      RORB            RRCA
      RORB            RRCA
      BSR L0593       CALL $0593      Print score digit
      LDB ,X          LD A,(HL)
      BSR L0593       CALL $0593      Print score digit
      LEAX -1,X       DEC HL
      DEC REGB        DJNZ $0583
      BNE L0583
      RTS             RET

L0593 ANDB #$0f       AND $0F         058c 0588
      STB ,U          LD (IX+$00),A
      LEAU -32,U      ADD IX,DE
      RTS             RET

L059b CMPB #$03       CP $03          05bf
      BCC L05bd       JP NC,$05BD
      PSHS B          PUSH AF
      LDX #$60b2      LD HL,$60B2
      TSTB            AND A
      BEQ L05ab       JP Z,$05AB
      LDX #$60b5      LD HL,$60B5
L05ab CMPB #$02       CP $02          05a5
      BNE L05b3       JP NZ,$05B3
      LDX #$60b8      LD HL,$60B8
L05b3 CLRB            XOR A           05ad
      STB ,X+         LD (HL),A
;                     INC HL
      STB ,X+         LD (HL),A
;                     INC HL
      STB ,X          LD (HL),A
      PULS B          POP AF
      BRA L05c6       JP $05C6
L05bd DECB            DEC A           05c4 059d
      PSHS B,CC       PUSH AF
      BSR L059b       CALL $059B
      PULS B,CC       POP AF
      BNE L05bd       RET Z
      RTS             JR $05BD

L05c6 CMPB #$03       CP $03          05e2 05ba
      BEQ L05e0       JP Z,$05E0
      LDY #$60b4      LD DE,$60B4
      TSTB            AND A
      BEQ L05d5       JP Z,$05D5
      LDY #$60b7      LD DE,$60B7
L05d5 CMPB #$02       CP $02          05cf
      BNE L056b       JP NZ,$056B

L05da LDY #$60ba      LD DE,$60BA     055c
      JMP L0578       JP $0578
L05e0 DECB            DEC A           05e7 05c8
      PSHS B,CC       PUSH AF
      BSR L05c6       CALL $05C6
      PULS B,CC       POP AF
      BNE L05e0       RET Z
      RTS             JR $05E0

L05e9 LDX #L364b      LD HL,$364B     08ed 0618 Print text on screen
      ASLB            ADD A,A
      PSHS B,CC       PUSH AF
      ANDB #$7f       AND $7F
;                     LD E,A
;                     LD D,$00
      ABX             ADD HL,DE
      LDY ,X          LD E,(HL)
;                     INC HL
;                     LD D,(HL)
;                     EX DE,HL
      LDX ,Y++        LD E,(HL)
;                     INC HL
;                     LD D,(HL)
;                     INC HL
;     LDD #$ffe0      LD BC,$FFE0     unnecessary?
      STD REGBC 
;                     EX DE,HL
L0600 LDB ,Y          LD A,(DE)       060f
      CMPB #$3f       CP $3F
      BNE L0606       JP Z,$0026
      PULS X,PC
L0606 STB ,X          LD (HL),A
      PULS B,CC       POP AF
      BCC L060c       JR NC,$060C
      LDA #$10        LD (HL),$10
      STA ,X
L060c PSHS B,CC       PUSH AF         0608
      LEAY 1,Y        INC DE
      LEAX -32,X      ADD HL,BC
      BRA L0600       JR $0600

L0611 LDB $6007       LD A,($6007)    Attract mode flag
      RORB            RRCA
      BCS L0616       RET NC
L0615 RTS

L0616 ldx #OVERLAY                    set colors to be correct in advance
      stx PATCH4+2
      LDB #$05        LD A,$05        1486 141e 08f0
      BSR L05e9       CALL $05E9
      LDX #$6001      LD HL,$6001     # of credits
;     LDY #$ffe0      LD DE,$FFE0     unnecessary?
      LDU #$74bf      LD IX,$74BF
      LDA #$01        LD B,$01
      STA REGB 
      JMP L0583       JP $0583

L062a TSTB            AND A
      BEQ L0691       JP Z,$0691
      LDA $638c       LD A,($638C)    bonus timer
;                     AND A
      LBNE L06a8      JP NZ,$06A8     decrement if not already zero
      LDB $63b8       LD A,($63B8)    zero - make mario die?
;                     AND A
      BNE L0615       RET NZ
      LDD #$000a      LD BC,$000A
      STD REGBC 
      LDB $62b0       LD A,($62B0)
L0640 INC REGB        INC B           0642
      SUBB REGC       SUB C
      BNE L0640       JP NZ,$0640
      LDB REGB        LD A,B
      LDA REGB        RLCA
      ASLA
      ROLB
      ASLA            RLCA
      ROLB
      ASLA            RLCA
      ROLB
      ASLA            RLCA
      ROLB
      STB $638c       LD ($638C),A    bonus timer (set initial value)
      LDX #L384a      LD HL,$384A
      LDY #$7465      LD DE,$7465
      LDB #$06        LD A,$06
      STB REGA 
L0655 LDU #$001d      LD IX,$001D     0664
      LDB #$03        LD BC,$0003
L065c LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L065c
      TFR Y,D         ADD IX,DE
      LEAU D,U
      TFR U,Y         PUSH IX
;                     POP DE
      DEC REGA        DEC A
      BNE L0655       JP NZ,$0655
      LDA $638c       LD A,($638C)    bonus timer
L066a STA REGC        LD C,A          06b5
      ANDA #$0f       AND $0F
      STA REGB        LD B,A
      LDB REGC        LD A,C
      LSRB            RRCA
      LSRB            RRCA
      LSRB            RRCA
      LSRB            RRCA
;     ANDB #$0f       AND $0F
      BNE L0689       JP NZ,$0689     more than 900 time left?
      LDB #$03        LD A,$03
      STB $6089       LD ($6089),A
      LDB #$70        LD A,$70
      STB $7486       LD ($7486),A    time is running out! make bonus timer RED
      STB $74a6       LD ($74A6),A
      ADDB REGB       ADD A,B
      STB REGB        LD B,A
      LDB #$10        LD A,$10
L0689 STB $74e6       LD ($74E6),A    0675 print 1st digit of bonus timer
      LDB REGB        LD A,B
      STB $74c6       LD ($74C6),A    print 2nd digit of bonus timer
      RTS             RET
L0691 LDB $638c       LD A,($638C)    062b bonus timer (add to score?)
      STB REGB        LD B,A
      PSHS B          PUSH BC
      ANDB #$0f       AND $0F
      JSR L051c       CALL $051C
      PULS B          POP BC
      STB REGB        LD A,B
      LSRB            RRCA
      LSRB            RRCA
      LSRB            RRCA
      LSRB            RRCA
;     ANDB #$0f       AND $0F
      ADDB #$0a       ADD A,$0A
      JMP L051c       JP $051C

L06a8 SUBA #$01       SUB 01          0632 decrement bonus timer (fixed DAA bug!)
      BNE L06b1       JR NZ,$06B1
      LDX #$63b8      LD HL,$63B8
      LDB #$01        LD (HL),$01
      STB ,X
L06b1 TFR A,B         DAA             06aa
      ANDB #$0f
      CMPB #$0f
      BNE DAA1
      SUBA #6
DAA1  STA $638c       LD ($638C),A    bonus timer (update value)
      BRA L066a       JP $066A

L06b8 STB REGC        LD C,A          037c 01dc
      JSR L0008       RST $08
      LDA #$06        LD B,$06
;     LDY #$ffe0      LD DE,$FFE0     unnecessary?
      LDX #$7783      LD HL,$7783
      LDB #$10        LD (HL),$10     06c5
L06c2 STB ,X
      LEAX -32,X      ADD HL,DE
      DECA            DJNZ $06C2
      BNE L06c2
      LDB $6228       LD A,($6228)    Number of lives?
      SUBB REGC       SUB C
      BEQ L06d7       JP Z,$06D7
      STB REGB        LD B,A
      LDX #$7783      LD HL,$7783
L06d2 LDA #$ff        LD (HL),$FF     06d5 Print number of lives
      STA ,X
      LEAX -32,X      ADD HL,DE
      DEC REGB        DJNZ $06D2
      BNE L06d2
L06d7 LDX #$7503      LD HL,$7503     06cb Print "L=00"
      LDA #$1c        LD (HL),$1C
      STA ,X
      LDX #$74e3      LD HL,$74E3
      LDA #$34        LD (HL),$34
      STA ,X
      LDA $6229       LD A,($6229)
      CMPA #$64       CP $64
      BCS L06ed       JR C,$06ED
      LDA #$63        LD A,$63
      STA $6229       LD ($6229),A
L06ed LDB #$ff        LD BC,$FF0A     06e6
L06f0 INCB            INC B           06f2
      SUBA #$0a       SUB C
      BCC L06f0       JP NC,$06F0
      ADDA #$0a       ADD A,C
      STA $74a3       LD ($74A3),A
;                     LD A,B
      STB $74c3       LD ($74C3),A
      RTS             RET

L06fe LDB $600a       LD A,($600A)    Game Screen Sequencer (During Gameplay)
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L0986                       0 ?
      FDB L09ab                       1
      FDB L09d6                       2
      FDB L09fe                       3 ?
      FDB L0a1b                       4 print "Player II" screen?
      FDB L0a37                       5 print "Player I" screen
      FDB L0a63                       6 wait...
      FDB L0a76                       7 Process the intro sequence
      FDB L0bda                       8 draw "How High Can You Get"?
      FDB L0000
      FDB L0c91                       A How High Can You Get screen
      FDB L123c                       B Start of gameplay
      FDB L197a                       C Gameplay
      FDB L127c                       D Died in gameplay
      FDB L12f2
      FDB L1344
      FDB L138f                       10 Game Over screen
      FDB L13a1                       11 Player II Game Over screen
      FDB L13aa                       12 ?
      FDB L13bb
      FDB L141e                       14 Your name has been registered screen
      FDB L1486                       15 Enter initials screen
      FDB L1615                       16 Mario-Pauline reunion sequence?
      FDB L196b                       17 Clear screen?

L073c LDX #$600a      LD HL,$600A     Game Screen Sequencer (In Attract Mode)
      LDB $6001       LD A,($6001)    # of credits
;                     AND A
      BNE L075c       JP NZ,$075C
      LDB ,X          LD A,(HL)
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L0779                       0 Reset/Initialise game?
      FDB L0763                       1 Insert Coin Screen
      FDB L123c                       2 start of attract mode gameplay?
      FDB L1977                       3 Attract mode gameplay
      FDB L127c                       4 died in attract gameplay
      FDB L07c3                       5 switch to Donkey Kong title screen
      FDB L07cb                       6 Donkey Kong Title Screen flashing
      FDB L084b                       7 Donkey Kong Title Screen not flashing

L075c CLR ,X          LD (HL),$00     0743
      LDX #$6005      LD HL,$6005
      INC ,X          INC (HL)
      RTS             RET

L0763 JSR L0020       RST $20         Insert coin screen
      CLRB            XOR A
      STB $6392       LD ($6392),A
      STB $63a0       LD ($63A0),A
      LDB #$01        LD A,$01
      STB $6227       LD ($6227),A    Set Level Type 1
      STB $6229       LD ($6229),A
      STB $6228       LD ($6228),A
      JMP L0c92       JP $0C92

L0779 LDX #$7d86      LD HL,$7D86     BG Palette select
      CLR ,X+         LD (HL),$00
;                     INC HL
      CLR ,X          LD (HL),$00
      JSR SETPAL
      LDY #$031b      LD DE,$031B
      JSR L309f       CALL $309F
      LEAY 1,Y        INC E
      JSR L309f       CALL $309F
      JSR L0965       CALL $0965
      LDX #$6009      LD HL,$6009
      LDA #$02        LD (HL),$02
      STA ,X+         INC HL
      INC ,X          INC (HL)        $600a Game Screen Sequencer
      JSR L0874       CALL $0874
      JSR L0a53       CALL $0A53
      LDB $600f       LD A,($600F)
      CMPB #$01       CP $01
      BNE L07a3       CALL Z,$09EE
      JSR L09ee
L07a3 LDY $6022       LD DE,($6022)
      LDX #$756c      LD HL,$756C
      BSR L07ad       CALL $07AD

L07ad TFR Y,D         LD (HL),E       07aa
      STB ,X++        INC HL
;                     INC HL
      STA ,X          LD (HL),D
;                     LD A,D
      SUBA #$0a       SUB 0A
      BNE L07bc       JP NZ,$07BC
      STA ,X          LD (HL),A
      INCA            INC A
      STA $758e       LD ($758E),A
L07bc LDY #$0201      LD DE,$0201     07b4
      LDX #$768c      LD HL,$768C
      RTS             RET

L07c3 JSR L0874       CALL $0874
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      INC ,X          INC (HL)
      RTS             RET

L082d LDB $638b       LD A,($638B)    07d0
      STB REGC        LD C,A
      LDB $638a       LD A,($638A)
      DECB            DEC A
      STB $638a       LD ($638A),A
      JMP L07da       JP $07DA
L07cb LDB $638a       LD A,($638A)
;                     CP $00
      BNE L082d       JP NZ,$082D
      LDB #$60        LD A,$60
      STB $638a       LD ($638A),A
      LDA #$5f        LD C,$5F
      STA REGC 
L07da CMPB #$00       CP $00          0838 flash palette during donkey kong title screen
      BEQ L083b       JP Z,$083B
;     LDX #$7d86      LD HL,$7D86     BG Palette select
;     CLR ,X          LD (HL),$00     set BG Palette
      LDB REGC        LD A,C
      LDA REGC        RLC A
      ASLA
      ROLB
;      BCC L07eb       JR NC,$07EB
;      LDA #$01        LD (HL),$01    set BG Palette
;      STA ,X
;L07eb LEAX 1,X        INC HL         07e7
;      CLR ,X          LD (HL),$00    set BG Palette
      TFR B,A         RLC A
      ASLA
      ROLB
;      BCC L07f4       JR NC,$07F4
;      LDA #$01        LD (HL),$01
;      STA ,X
L07f4 STB $638b       LD ($638B),A    07f0
       cmpb #$d7
       bne ALTPAL
       lda TICK
IDLE   cmpa TICK
       BEQ IDLE
       lda PAL+3                      fiddle with GIME palette registers directly
       ldb PAL+5
       bra YESPAL
ALTPAL cmpb #$7d
       bne NOPAL
       lda TICK
IDLE2  cmpa TICK
       BEQ IDLE2
       lda PAL+6
       ldb PAL+10
YESPAL sta $ffb3
       stb $ffb5
       ldx #OVERLAY+192               set colors to be correct in advance
       stx PATCH4+2
NOPAL LDX #L3d08      LD HL,$3D08     draw big donkey kong logo on title screen
L07fa LDB #$b0        LD A,$B0        0809
      LDA ,X+         LD B,(HL)
      STA REGB 
;                     INC HL
      LDY ,X++        LD E,(HL)
;                     INC HL
;                     LD D,(HL)
L0801 STB ,Y+         LD (DE),A       0803
;                     INC DE
      DEC REGB        DJNZ $0801
      BNE L0801
;                     INC HL
      LDB ,X          LD A,(HL)
;                     CP $00
      BNE L07fa       JP NZ,$07FA
      LDY #$031e      LD DE,$031E
      JSR L309f       CALL $309F
      LEAY 1,Y        INC DE
      JSR L309f       CALL $309F
      LDX #L39cf      LD HL,$39CF
;                     NOP
      JSR L004e       CALL $004E
; if alternate release version...
;      LDX #$74af      ld hl,$74af    add TM symbol to screen
;      LDA #$9f        ld de,$Ffe0
;      STA ,X          ld (hl),$9f
;      LDA #$9e        add hl,de
;      STA -32,X       ld (hl),$9e

      LDX #$6908      LD HL,$6908
      LDA #$44        LD C,$44
      STA REGC 
      JSR L0038       RST $38
      LDX #$690b      LD HL,$690B
      LDA #$78        LD C,$78
      STA REGC 
      JSR L0038       RST $38
      RTS             RET
L083b LDX #$6009      LD HL,$6009     07dc
      LDA #$02        LD (HL),$02
      STA ,X+         INC HL
      INC ,X          INC (HL)        $600a Game Screen Sequencer
      LDX #$638a      LD HL,$638A
      CLR ,X+         LD (HL),$00
;                     INC HL
      CLR ,X          LD (HL),$00
      RTS             RET

L084b JSR L0020       RST $20
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      CLR ,X          LD (HL),$00
      RTS             RET

L0852 LDX #$7400      LD HL,$7400     196b 0986
      LDA #$04        LD C,$04
      STA REGC 
L0857 CLRA            LD B,$00        0860
      LDB #$10        LD A,$10
L085b STB ,X+         LD (HL),A       085d
;                     INC HL
      DECA            DJNZ $085B
      BNE L085b
      DEC REGC        DEC C
      BNE L0857       JP NZ,$0857
      LDX #$6900      LD HL,$6900
      LDA #$02        LD C,$02
      STA REGC 
L0868 LDA #$c0        LD B,$C0        0870
      CLRB            XOR A
L086b STB ,X+         LD (HL),A       086d
;                     INC HL
      DECA            DJNZ $086B
      BNE L086b
      DEC REGC        DEC C
      BNE L0868       JP NZ,$0868
      RTS             RET

; Clear the screen and sprites
;
L0874 LDX #$7404      LD HL,$7404     1422 0c92 0bde 0a64 093b 08ba 07c3 0795 01c3
      LDA #$20        LD C,$20
      STA REGC 
L0879 LDA #$1c        LD B,$1C        0886
      LDB #$10        LD A,$10        clear character
;                     LD DE,$0004
L0880 STB ,X+         LD (HL),A       0882
;                     INC HL
      DECA            DJNZ $0880
      BNE L0880
      LEAX 4,X        ADD HL,DE       skip score area
      DEC REGC        DEC C
      BNE L0879       JP NZ,$0879
      LDX #$7522      LD HL,$7522
;     LDY #$0020      LD DE,$0020     unnecessary?
      LDA #$02        LD C,$02
      STA REGC 
      LDB #$10        LD A,$10
L0893 LDA #$0e        LD B,$0E        089d
L0895 STB ,X          LD (HL),A       0897
      LEAX $20,X      ADD HL,DE
      DECA            DJNZ $0895
      BNE L0895
      LDX #$7523      LD HL,$7523
      DEC REGC        DEC C
      BNE L0893       JP NZ,$0893
      LDX #$6900      LD HL,$6900     clear all sprites
      CLRA            LD B,$00
      CLRB            LD A,$00
L08a7 STB ,X+         LD (HL),A       08a9
;                     INC HL
      DECA            DJNZ $08A7
      BNE L08a7
      LDA #$80        LD B,$80
L08ad STB ,X+         LD (HL),A       08af
;                     INC HL
      DECA            DJNZ $08AD
      BNE L08ad
      RTS             RET

L08b2 LDB $600a       LD A,($600A)    Game Screen Sequencer
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L08ba
      FDB L08f8

L08ba BSR L0874       CALL $0874
      CLRB            XOR A
      STB $6007       LD ($6007),A    Reset Attract mode flag
      LDY #$030c      LD DE,$030C
      JSR L309f       CALL $309F
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      INC ,X          INC (HL)
      JSR L0965       CALL $0965
      CLRB            XOR A
      LDX #$7d86      LD HL,$7D86     BG Palette select
      STB ,X+         LD (HL),A
;                     INC L
      STB ,X          LD (HL),A
      JSR SETPAL

L08d5 LDD #$0409      LD B,$04        08f8
      STA REGB 
      STB REGE        LD E,$09
      LDB $6001       LD A,($6001)    # of credits
      CMPB #$01       CP $01
      BEQ L08e4       JP Z,$08E4
      LDA #$0c        LD B,$0C
      STA REGB 
      INC REGE        INC E
L08e4 LDB $601a       LD A,($601A)    08de
      ANDB #$07       AND $07
      BNE L08f3       JP NZ,$08F3
      LDB REGE        LD A,E
      JSR L05e9       CALL $05E9
      JSR L0616       CALL $0616      Print CREDITS xx
L08f3 LDB IN2         LD A,($7D00)    08e9 Inputs 2
      ANDB REGB       AND B
      RTS             RET

L08f8 BSR L08d5       CALL $08D5
      CMPB #$04       CP $04
      BEQ L0906       JP Z,$0906
      CMPB #$08       CP $08
      BEQ L0919       JP Z,$0919
      RTS             RET
L0906 JSR L0977       CALL $0977      08fd
      LDX #$6048      LD HL,$6048     P2 level data 8-bytes
      LDA #$08        LD B,$08
      CLRB            XOR A
L090f STB ,X+         LD (HL),A       0911
;                     INC L
      DECA            DJNZ $090F
      BNE L090f
      LDX #$0000      LD HL,$0000
      BRA L0938       JP $0938
L0919 BSR L0977       CALL $0977      0902
      BSR L0977       CALL $0977
      LDY #$6048      LD DE,$6048     P2 level data 8-bytes
      LDB $6020       LD A,($6020)
      STB ,Y+         LD (DE),A
;                     INC E
      LDX #L095e      LD HL,$095E     Initialise level data
      LDB #$07        LD BC,$0007
L092d LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L092d
      LDY #$0101      LD DE,$0101
      JSR L309f       CALL $309F
      LDX #$0001      LD HL,$0100     endian fixed!!!
L0938 STX $600e       LD ($600E),HL   0916
      JSR L0874       CALL $0874
      LDY #$6040      LD DE,$6040     P1 level data 8-bytes
      LDB $6020       LD A,($6020)
      STB ,Y+         LD (DE),A
;                     INC E
      LDX #L095e      LD HL,$095E     Initialise level data
      LDB #$07        LD BC,$0007
L094c LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L094c
      LDY #$0100      LD DE,$0100
      JSR L309f       CALL $309F
      CLRB            XOR A
      STB $600a       LD ($600A),A    Game Screen Sequencer
      LDB #$03        LD A,$03
      STB $6005       LD ($6005),A
      RTS             RET

;                                     Start of game level init data
L095e FCB $01
      FDB L3a65
      FCB $01,$00,$00,$00

L0965 LDY #$0400      LD DE,$0400     08cb 078b
      JSR L309f       CALL $309F
      LDY #$0314      LD DE,$0314
      LDA #$06        LD B,$06
      STA REGB 
L0970 JSR L309f       CALL $309F      0974
      LEAY 1,Y        INC E
      DEC REGB        DJNZ $0970
      BNE L0970
      RTS             RET

L0977 LDX #$6001      LD HL,$6001     091c 0919 0906 # of credits
      LDA #$99        LD A,$99
      ADDA ,X         ADD A,(HL)
      DAA             DAA
      STA ,X          LD (HL),A
      LDY #$0400      LD DE,$0400
      JSR L309f       CALL $309F
      RTS             RET

L0986 JSR L0852       CALL $0852
      JSR L011c       CALL $011C
      LDY #$7d82      LD DE,$7D82     Flip Screen
      LDB #$01        LD A,$01
      STB ,Y          LD (DE),A
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      LDB $600e       LD A,($600E)
;                     AND A
      BNE L099f       JP NZ,$099F
      LDA #$01        LD (HL),$01
      STA ,X
      RTS             RET
L099f LDB $6026       LD A,($6026)    0999
      DECB            DEC A
      BEQ L09a8       JP Z,$09A8
      CLRB            XOR A
      STB ,Y          LD (DE),A
L09a8 LDA #$03        LD (HL),$03     09a3
      STA ,X
      RTS             RET

L09ab LDX #$6040      LD HL,$6040     copy P1 level data/index to current 
      LDY #$6228      LD DE,$6228     current level data 8-bytes
      LDB #$08        LD BC,$0008
L09b4 LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L09b4
      LDX $622a       LD HL,($622A)   Pointer to level order table
      LDB ,X          LD A,(HL)
      STB $6227       LD ($6227),A    Set Level Type
      LDX #$6009      LD HL,$6009
      LDY #$600a      LD DE,$600A     Game Screen Sequencer
      LDB $600f       LD A,($600F)
;                     AND A
      BEQ L09d0       JP Z,$09D0
      LDA #$78        LD (HL),$78
      STA ,X
      EXG Y,X         EX DE,HL
      LDA #$02        LD (HL),$02
      STA ,X
      RTS             RET
L09d0 LDA #$01        LD (HL),$01     09c7
      STA ,X
      EXG Y,X         EX DE,HL
      LDA #$05        LD (HL),$05
      STA ,X
      RTS             RET

L09d6 CLRB            XOR A
      STB $7d86       LD ($7D86),A    BG Palette select
      STB $7d87       LD ($7D87),A    BG Palette select
      JSR SETPAL
      LDY #$0302      LD DE,$0302
      JSR L309f       CALL $309F
      LDY #$0201      LD DE,$0201
      JSR L309f       CALL $309F
      LDB #$05        LD A,$05
      STB $600a       LD ($600A),A    Game Screen Sequencer

L09ee LDB #$02        LD A,$02        0a2e 07a0
      STB $74e0       LD ($74E0),A
      LDB #$25        LD A,$25
      STB $74c0       LD ($74C0),A
      LDB #$20        LD A,$20
      STB $74a0       LD ($74A0),A
      RTS             RET

L09fe LDX #$6048      LD HL,$6048     copy P2 level data/index to current
      LDY #$6228      LD DE,$6228     current level data 8-bytes
      LDB #$08        LD BC,$0008
L0a07 LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L0a07
      LDX $622a       LD HL,($622A)   Pointer to level order table
      LDB ,X          LD A,(HL)
      STB $6227       LD ($6227),A    Set Level Type
      LDB #$78        LD A,$78
      STB $6009       LD ($6009),A
      LDB #$04        LD A,$04
      STB $600a       LD ($600A),A    Game Screen Sequencer
      RTS             RET

L0a1b CLRB            XOR A
      STB $7d86       LD ($7D86),A    BG Palette select
      STB $7d87       LD ($7D87),A    BG Palette select
      JSR SETPAL
      LDY #$0303      LD DE,$0303
      JSR L309f       CALL $309F
      LDY #$0201      LD DE,$0201
      JSR L309f       CALL $309F
      BSR L09ee       CALL $09EE
      LDB #$05        LD A,$05
      STB $600a       LD ($600A),A    Game Screen Sequencer
      RTS             RET

L0a37 LDY #$0304      LD DE,$0304
      JSR L309f       CALL $309F
      LDY #$0202      LD DE,$0202
      JSR L309f       CALL $309F
      LDY #$0200      LD DE,$0200
      JSR L309f       CALL $309F
      LDY #$0600      LD DE,$0600
      JSR L309f       CALL $309F
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      INC ,X          INC (HL)

L0a53 LDB #$01        LD A,$01        0798 01f1
      STB $7740       LD ($7740),A
      LDB #$25        LD A,$25
      STB $7720       LD ($7720),A
      LDB #$20        LD A,$20
      STB $7700       LD ($7700),A
      RTS             RET

L0a63 JSR L0018       RST $18
      JSR L0874       CALL $0874
      LDX #$6009      LD HL,$6009
      LDA #$01        LD (HL),$01
      STA ,X+         INC L
      INC ,X          INC (HL)        $600a Game Screen Sequencer
      LDY #$622c      LD DE,$622C
      LDB ,Y          LD A,(DE)
;                     AND A
      BNE L0a75       RET NZ          Already seen intro sequence?
      INC ,X          INC (HL)        Skip intro sequence
L0a75 RTS             RET

L0a76 LDB $6385       LD A,($6385)    Process the intro sequence
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L0a8a                       Draw climb screen
      FDB L0abf
      FDB L0ae8
      FDB L3069
      FDB L0b06                       Draw first girder deformation
      FDB L3069
      FDB L0b68                       Draw the rest of the deformations
      FDB L0bb3                       Growl

L0a8a CLRB            XOR A
      STB $7d86       LD ($7D86),A    BG Palette select
      INCB            INC A
      STB $7d87       LD ($7D87),A    BG Palette select
      JSR SETPAL
      LDY #L380d      LD DE,$380D     Draw data for climb intro screen
      JSR L0da7       CALL $0DA7
      LDB #$10        LD A,$10
      STB $76a3       LD ($76A3),A
      STB $7663       LD ($7663),A
      LDB #$d4        LD A,$D4
      STB $75aa       LD ($75AA),A
      CLRB            XOR A
      STB $62af       LD ($62AF),A
      LDX #L38b4      LD HL,$38B4
      STX $63c2       LD ($63C2),HL
      LDX #L38cb      LD HL,$38CB
      STX $63c4       LD ($63C4),HL
      LDB #$40        LD A,$40
      STB $6009       LD ($6009),A
      LDX #$6385      LD HL,$6385
      INC ,X          INC (HL)
      RTS             RET

L0abf JSR L0018       RST $18
      LDX #L388c      LD HL,$388C
      JSR L004e       CALL $004E
      LDX #$6908      LD HL,$6908
      LDA #$30        LD C,$30
      STA REGC 
      JSR L0038       RST $38
      LDX #$690b      LD HL,$690B
      LDA #$99        LD C,$99
      STA REGC 
      JSR L0038       RST $38
      LDB #$1f        LD A,$1F
      STB $638e       LD ($638E),A
      CLRB            XOR A
      STB $690c       LD ($690C),A
      LDX #$608a      LD HL,$608A
      LDA #$01        LD (HL),$01
      STA ,X+         INC HL
      LDA #$03        LD (HL),$03
      STA ,X
      LDX #$6385      LD HL,$6385
      INC ,X          INC (HL)
      RTS             RET

L0ae8 JSR L306f       CALL $306F
      LDB $62af       LD A,($62AF)
      ANDB #$0f       AND $0F
      BNE L0af3       CALL Z,$304A
      JSR L304a
L0af3 LDB $690b       LD A,($690B)
      CMPB #$5d       CP $5D
      BCC L0b05       RET NC
      LDB #$20        LD A,$20
      STB $6009       LD ($6009),A
      LDX #$6385      LD HL,$6385
      INC ,X          INC (HL)
      STX $63c0       LD ($63C0),HL
L0b05 RTS             RET

L0b06 LDB $601a       LD A,($601A)    Draw first girder deformation
      RORB            RRCA
      BCS L0b05       RET C
      LDX $63c2       LD HL,($63C2)
      LDB ,X          LD A,(HL)
      CMPB #$7f       CP $7F
      BEQ L0b1e       JP Z,$0B1E
      LEAX 1,X        INC HL
      STX $63c2       LD ($63C2),HL
      STB REGC        LD C,A
      LDX #$690b      LD HL,$690B
      JSR L0038       RST $38
      RTS             RET
L0b1e LDX #L385c      LD HL,$385C     0b11
      JSR L004e       CALL $004E
      LDY #$6900      LD DE,$6900
      LDB #$08        LD BC,$0008
L0b2a LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L0b2a
      LDX #$6908      LD HL,$6908
      LDA #$50        LD C,$50
      STA REGC 
      JSR L0038       RST $38
      LDX #$690b      LD HL,$690B
      LDA #$fc        LD C,$FC
      STA REGC 
      JSR L0038       RST $38
L0b38 JSR L304a       CALL $304A      0b40
      LDB $638e       LD A,($638E)
      CMPB #$0a       CP $0A
      BNE L0b38       JP NZ,$0B38
      LDB #$03        LD A,$03
      STB $6082       LD ($6082),A
      LDY #L392c      LD DE,$392C     Draw data for bending girders (first bounce)
      JSR L0da7       CALL $0DA7
      LDB #$10        LD A,$10
      STB $74aa       LD ($74AA),A
      STB $748a       LD ($748A),A
      LDB #$05        LD A,$05
      STB $638d       LD ($638D),A
      LDB #$20        LD A,$20
      STB $6009       LD ($6009),A
      LDX #$6385      LD HL,$6385
      INC ,X          INC (HL)
      STX $63c0       LD ($63C0),HL
      RTS             RET

L0b68 LDB $601a       LD A,($601A)    Draw the rest of the deformations
      RORB            RRCA
      BCS L0b85       RET C
      LDX $63c4       LD HL,($63C4)
      LDB ,X          LD A,(HL)
      CMPB #$7f       CP $7F
      BEQ L0b86       JP Z,$0B86
      LEAX 1,X        INC HL
      STX $63c4       LD ($63C4),HL
      LDX #$690b      LD HL,$690B
      STB REGC        LD C,A
      JSR L0038       RST $38
      LDX #$6908      LD HL,$6908
      LDA #$ff        LD C,$FF
      STA REGC 
      JSR L0038       RST $38
L0b85 RTS             RET
L0b86 LDX #L38cb      LD HL,$38CB     0b73
      STX $63c4       LD ($63C4),HL
      LDB #$03        LD A,$03
      STB $6082       LD ($6082),A
      LDX #L38dc      LD HL,$38DC     Draw data for bending girders
      LDB $638d       LD A,($638D)
      DECB            DEC A
      LSLB            RLCA
      LSLB            RLCA
      LSLB            RLCA
      LSLB            RLCA
;                     LD E,A
;                     LD D,$00
      ABX             ADD HL,DE
      TFR X,Y         EX DE,HL
      JSR L0da7       CALL $0DA7
      LDX #$638d      LD HL,$638D
      DEC ,X          DEC (HL)
      BNE L0bb2       RET NZ
      LDB #$b0        LD A,$B0
      STB $6009       LD ($6009),A
      LDX #$6385      LD HL,$6385
      INC ,X          INC (HL)
L0bb2 RTS             RET

L0bb3 LDX #$608a      LD HL,$608A     DK growl in intro sequence
      LDB $6009       LD A,($6009)
      CMPB #$90       CP $90
      BNE L0bc8       JR NZ,$0BC8
      LDA #$0f        LD (HL),$0F
      STA ,X+         INC HL
      LDA #$03        LD (HL),$03
      STA ,X
      LDX #$6919      LD HL,$6919
      INC ,X          INC (HL)
      BRA L0bd1       JR $0BD1
L0bc8 CMPB #$18       CP $18          0bbb
      BNE L0bd1       JR NZ,$0BD1
      LDX #$6919      LD HL,$6919
      DEC ,X          DEC (HL)
;                     NOP
L0bd1 JSR L0018       RST $18         0bca 0bc6
      CLRB            XOR A
      STB $6385       LD ($6385),A
      INC ,X+         INC (HL)
;                     INC HL
      INC ,X          INC (HL)
      RTS             RET


L0bda JSR L011c       CALL $011C
      JSR L0018       RST $18
      JSR L0874       CALL $0874
      LDA #$06        LD D,$06
      LDB $6200       LD A,($6200)    Flag - Mario alive
      TFR D,Y         LD E,A
      JSR L309f       CALL $309F
      LDX #$7d86      LD HL,$7D86     BG Palette select
      LDA #$01        LD (HL),$01
      STA ,X+         INC HL
      CLR ,X          LD (HL),$00
      JSR SETPAL
      LDX #$608a      LD HL,$608A
      LDA #$02        LD (HL),$02
      STA ,X+         INC HL
      LDA #$03        LD (HL),$03
      STA ,X
      LDX #$63a7      LD HL,$63A7
      CLR ,X          LD (HL),$00
      LDX #$76dc      LD HL,$76DC
      STX $63a8       LD ($63A8),HL
      LDB $622e       LD A,($622E)
      CMPB #$06       CP $06
      BCS L0c11       JR C,$0C11
      LDB #$05        LD A,$05
      STB $622e       LD ($622E),A
L0c11 LDB $622f       LD A,($622F)    0c0a
      STB REGB        LD B,A
      LDB $622b       LD A,($622A)    Pointer to level order table (endian fixed!!!)
      CMPB REGB       CP B
      BEQ L0c1f       JR Z,$0C1F
      LDX #$622e      LD HL,$622E
      INC ,X          INC (HL)
L0c1f STB $622f       LD ($622F),A    0c19
      LDB $622e       LD A,($622E)
      STB REGB        LD B,A
      LDX #$75bc      LD HL,$75BC
L0c29 LDA #$50        LD C,$50        0c7f
L0c2b STA ,X          LD (HL),C       0c40
      INCA            INC C
;                     DEC HL
      STA ,-X         LD (HL),C
      INCA            INC C
;                     DEC HL
      STA ,-X         LD (HL),C
      INCA            INC C
;                     DEC HL
      STA ,-X         LD (HL),C
;                     LD A,C
      CMPA #$67       CP $67
      BEQ L0c43       JP Z,$0C43
      INCA            INC C
;                     LD DE,$0023
      LEAX $23,X      ADD HL,DE
      BRA L0c2b       JP $0C2B
L0c43 LDB $63a7       LD A,($63A7)    0c38
      INCB            INC A
      STB $63a7       LD ($63A7),A
      DECB            DEC A
      ASLB            SLA A
      ASLB            SLA A
      PSHS X          PUSH HL
      LDX #L3cf0      LD HL,$3CF0
;                     PUSH BC
      LDU $63a8       LD IX,($63A8)
;                     LD C,A
;                     LD B,$00
      ABX             ADD HL,BC
      LDB ,X+         LD A,(HL)
      STB $60,U       LD (IX+$60),A
;                     INC HL
      LDB ,X+         LD A,(HL)
      STB $40,U       LD (IX+$40),A
;                     INC HL
      LDB ,X          LD A,(HL)
      STB $20,U       LD (IX+$20),A
      LDA #$8b        LD (IX-$20),$8B
      STA -$20,U
;                     POP BC
      TFR U,X         PUSH IX
;                     POP HL
;                     LD DE,$FFFC
      LEAX -4,X       ADD HL,DE
      STX $63a8       LD ($63A8),HL
      PULS X          POP HL
;                     LD DE,$FF5F
      LEAX -161,X     ADD HL,DE
      DEC REGB        DEC B
      BNE L0c29       JP NZ,$0C29
      LDY #$0307      LD DE,$0307
      JSR L309f       CALL $309F
      LDX #$6009      LD HL,$6009
      LDA #$a0        LD (HL),$A0
      STA ,X+         INC HL
      INC ,X          INC (HL)        $600a Game Screen Sequencer
      INC ,X          INC (HL)        $600a Game Screen Sequencer
      RTS             RET

L0c91 JSR L0018       RST $18

L0c92 JSR L0874       CALL $0874      0776
      CLRB            XOR A
      STB $638c       LD ($638C),A    bonus timer
      LDY #$0501      LD DE,$0501
      JSR L309f       CALL $309F
      LDX #$7d86      LD HL,$7D86     BG Palette select
      CLR ,X+         LD (HL),$00
;                     INC HL
      LDA #$01        LD (HL),$01
      STA ,X
      LDB $6227       LD A,($6227)    Level Type
      DECB            DEC A
      BEQ L0cd4       JP Z,$0CD4
      DECB            DEC A
      BEQ L0cdf       JP Z,$0CDF
      DECB            DEC A
      BEQ L0cf2       JP Z,$0CF2
;     JSR SETPAL
      JSR L0d43       CALL $0D43
      LDX #$7d86      LD HL,$7D86     BG Palette select
      LDA #$01        LD (HL),$01
      STA ,X
      JSR SETPAL
      LDB #$0b        LD A,$0B
      STB $6089       LD ($6089),A
      LDY #L3c8b      LD DE,$3C8B     LEVEL 4 (rivets screen) data
L0cc6 JSR L0da7       CALL $0DA7      0cfd 0cef 0cdc
      LDB $6227       LD A,($6227)    Level Type
      CMPB #$04       CP $04
      BNE L0cd1       CALL Z,$0D00
      BSR L0d00
L0cd1 JMP L3fa0       JP $3FA0
L0cd4 JSR SETPAL
      LDY #L3ae4      LD DE,$3AE4     0cab LEVEL 1 (girder screen) data
      LDB #$08        LD A,$08
      STB $6089       LD ($6089),A
      BRA L0cc6       JP $0CC6
L0cdf LDY #L3b5d      LD DE,$3B5D     0caf LEVEL 2 (cement screen) data
      LDX #$7d86      LD HL,$7D86     BG Palette select
      LDA #$01        LD (HL),$01
      STA ,X+         INC HL
      CLR ,X          LD (HL),$00
      JSR SETPAL
      LDB #$09        LD A,$09
      STB $6089       LD ($6089),A
      BRA L0cc6       JP $0CC6
L0cf2 JSR SETPAL
      BSR L0d27       CALL $0D27      0cb3
      LDB #$0a        LD A,$0A
      STB $6089       LD ($6089),A
      LDY #L3be5      LD DE,$3BE5     LEVEL 3 (elevator screen) data
      BRA L0cc6       JP $0CC6

L0d00 LDA #$08        LD B,$08        0cce
      STA REGB 
      LDX #L0d17      LD HL,$0D17
L0d05 LDB #$b8        LD A,$B8        0d14
      LDA #$02        LD C,$02
      LDY ,X++        LD E,(HL)
;                     INC HL
;                     LD D,(HL)
;                     INC HL
L0d0d STB ,Y+         LD (DE),A       0d11
      DECB            DEC A
;                     INC DE
      DECA            DEC C
      BNE L0d0d       JP NZ,$0D0D
      DEC REGB        DJNZ $0D05
      BNE L0d05
      RTS             RET

;                                     Rivets level - location of rivets
L0d17 FDB $76ca,$76cf,$76d4,$76d9,$752a,$752f,$7534,$7539

L0d27 LDX #$770d      LD HL,$770D     0cf2
      BSR L0d30       CALL $0D30
      LDX #$760d      LD HL,$760D

L0d30 LDA #$11        LD B,$11        0d2a
      LDB #$fd
L0d32 STB ,X+         LD (HL),$FD     0d35
;                     INC HL
      DECA            DJNZ $0D32
      BNE L0d32
;                     LD DE,$000F     unnecessary
      LEAX $f,X       ADD HL,DE
      LDA #$11        LD B,$11
      LDB #$fc
L0d3d STB ,X+         LD (HL),$FC     0d40
;                     INC HL
      DECA            DJNZ $0D3D
      BNE L0d3d
      RTS             RET

L0d43 LDX #$7687      LD HL,$7687     0cb6
      BSR L0d4c       CALL $0D4C
      LDX #$7547      LD HL,$7547

L0d4c LDA #$04        LD B,$04        0d46
      LDB #$fd
L0d4e STB ,X+         LD (HL),$FD     0d51
;                     INC HL
      DECA            DJNZ $0D4E
      BNE L0d4e
;                     LD DE,$001C     unnecessary
      LEAX $1c,X      ADD HL,DE
      LDA #$04        LD B,$04
      LDB #$fc
L0d59 STB ,X+         LD (HL),$FC     0d5c
;                     INC HL
      DECA            DJNZ $0D59
      BNE L0d59
      RTS             RET
L0d5f JSR L0f56       CALL $0F56      3fa3
      JSR L2441       CALL $2441
      LDX #$6009      LD HL,$6009
      LDA #$40        LD (HL),$40
      STA ,X+         INC HL
      INC ,X          INC (HL)        $600a Game Screen Sequencer
      LDX #L385c      LD HL,$385C
      JSR L004e       CALL $004E
      LDY #$6900      LD DE,$6900
      LDB #$08        LD BC,$0008
L0d78 LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L0d78
      LDB $6227       LD A,($6227)    Level Type
      CMPB #$04       CP $04
      BEQ L0d8b       JR Z,$0D8B
      LSRB            RRCA
      LSRB            RRCA
      BCS L0da6       RET C
      LDX #$690b      LD HL,$690B
      LDA #$fc        LD C,$FC
      STA REGC 
      JSR L0038       RST $38
      RTS             RET
L0d8b LDX #$6908      LD HL,$6908     0d7f
      LDA #$44        LD C,$44
      STA REGC 
      JSR L0038       RST $38
      LDY #$0004      LD DE,$0004
      LDX #$0210      LD BC,$0210
      STX REGBC 
      LDX #$6900      LD HL,$6900
      JSR L003d       CALL $003D
      LDX #$02f8      LD BC,$02F8
      STX REGBC 
      LDX #$6903      LD HL,$6903
      JSR L003d       CALL $003D
L0da6 RTS             RET

L0da7 LDB ,Y          LD A,(DE)       18a8 1800 17f4 17e8 17dc 0f49 0f18 0ed0 0e4c 0cc6 0ba1 0b4b 0a95
      STB $63b3       LD ($63B3),A
      CMPB #$aa       CP $AA
      BEQ L0da6       RET Z
      LEAY 1,Y        INC DE
      LDD ,Y+         LD A,(DE)
;                     LD H,A
;                     LD B,H
;                     INC DE
;                     LD A,(DE)
      TFR D,X         LD L,A
      STD REGBC       LD C,L
      PSHS Y          PUSH DE
      JSR L2ff0       CALL $2FF0
      PULS Y          POP DE
      STX $63ab       LD ($63AB),HL
      LDB REGB        LD A,B
      ANDB #$07       AND $07
      STB $63b4       LD ($63B4),A
      LDB REGC        LD A,C
      ANDB #$07       AND $07
      STB $63af       LD ($63AF),A
      LEAY 1,Y        INC DE
      LDB ,Y+         LD A,(DE)
      TFR B,A         LD H,A
      SUBB REGB       SUB B
      BCC L0dd3       JP NC,$0DD3
      NEGB            NEG
L0dd3 STB $63b1       LD ($63B1),A    0dce
;                     INC DE
      LDB ,Y          LD A,(DE)
      TFR D,X         LD L,A
      SUBB REGC       SUB C
      STB $63b2       LD ($63B2),A
      LDB ,Y          LD A,(DE)
      ANDB #$07       AND $07
      STB $63b0       LD ($63B0),A
      PSHS Y          PUSH DE
      JSR L2ff0       CALL $2FF0
      PULS Y          POP DE
      STX $63ad       LD ($63AD),HL
      LDB $63b3       LD A,($63B3)
      CMPB #$02       CP $02
      BPL L0e4f       JP P,$0E4F
      LDB $63b2       LD A,($63B2)
      SUBB #$10       SUB 10
      STB REGB        LD B,A
      LDB $63af       LD A,($63AF)
      ADDB REGB       ADD A,B
      STB $63b2       LD ($63B2),A
      LDB $63af       LD A,($63AF)
      ADDB #$f0       ADD A,$F0
      LDX $63ab       LD HL,($63AB)
      STB ,X+         LD (HL),A
;                     INC L
      SUBB #$30       SUB 30
      STB ,X          LD (HL),A
      LDB $63b3       LD A,($63B3)
      CMPB #$01       CP $01
      BNE L0e19       JP NZ,$0E19
      CLRB            XOR A
      STB $63b2       LD ($63B2),A
L0e19 LDB $63b2       LD A,($63B2)    0e27 0e12
      SUBB #$08       SUB 08
      STB $63b2       LD ($63B2),A
      BCS L0e2a       JP C,$0E2A
      LEAX 1,X        INC L
      LDA #$c0        LD (HL),$C0
      STA ,X
      BRA L0e19       JP $0E19
L0e2a LDB $63b0       LD A,($63B0)    0e21
      ADDB #$d0       ADD A,$D0
      LDX $63ad       LD HL,($63AD)
      STB ,X          LD (HL),A
      LDB $63b3       LD A,($63B3)
      CMPB #$01       CP $01
      BNE L0e3f       JP NZ,$0E3F
;                     DEC L
      LDA #$c0        LD (HL),$C0
      STA -1,X
;                     INC L
L0e3f LDB $63b0       LD A,($63B0)    0e38
;                     CP $00
      BEQ L0e4b       JP Z,$0E4B
      ADDB #$e0       ADD A,$E0       convert bottom of ladder to girder tile 
      LEAX 1,X        INC L
      STB ,X          LD (HL),A
L0e4b LEAY 1,Y        INC DE          0e44
      JMP L0da7       JP $0DA7
L0e4f LDB $63b3       LD A,($63B3)    0df0
      CMPB #$02       CP $02
      LBNE L0ee8      JP NZ,$0EE8
      LDB $63af       LD A,($63AF)
      ADDB #$f0       ADD A,$F0
      STB $63b5       LD ($63B5),A
      LDX $63ab       LD HL,($63AB)
L0e62 LDB $63b5       LD A,($63B5)    0ee5 0ecc 0e8c
      STB ,X+         LD (HL),A
;                     INC HL
      TFR X,D         LD A,L
      ANDB #$1f       AND $1F
      BEQ L0e78       JP Z,$0E78
      LDB $63b5       LD A,($63B5)
      CMPB #$f0       CP $F0
      BEQ L0e78       JP Z,$0E78
      SUBB #$10       SUB 10
      STB ,X          LD (HL),A
;0e78                 LD BC,$001F     unnecessary? 0e72 0e6a
L0e78 LEAX $1f,X      ADD HL,BC
      LDB $63b1       LD A,($63B1)
      SUBB #$08       SUB 08
      BCS L0ecf       JP C,$0ECF
      STB $63b1       LD ($63B1),A
      LDB $63b2       LD A,($63B2)
;                     CP $00
      BEQ L0e62       JP Z,$0E62
      LDB $63b5       LD A,($63B5)
      STB ,X+         LD (HL),A
;                     INC HL
      TFR X,D         LD A,L
      ANDB #$1f       AND $1F
      BEQ L0ea0       JP Z,$0EA0
      LDB $63b5       LD A,($63B5)
      SUBB #$10       SUB 10
      STB ,X          LD (HL),A
;0ea0                 LD BC,$001F     unnecessary? 0e97
L0ea0 LEAX $1f,X      ADD HL,BC
      LDB $63b1       LD A,($63B1)
      SUBB #$08       SUB 08
      BCS L0ecf       JP C,$0ECF
      STB $63b1       LD ($63B1),A
      LDB $63b2       LD A,($63B2)
;                     BIT 7,A
      BMI L0ed3       JP NZ,$0ED3
      LDB $63b5       LD A,($63B5)
      INCB            INC A
      STB $63b5       LD ($63B5),A
      CMPB #$f8       CP $F8
      BNE L0ec9       JP NZ,$0EC9
      LEAX 1,X        INC HL
      LDB #$f0        LD A,$F0
      STB $63b5       LD ($63B5),A
L0ec9 TFR X,D         LD A,L          0ec0
      ANDB #$1f       AND $1F
      BNE L0e62       JP NZ,$0E62
L0ecf LEAY 1,Y        INC DE          0f20 0ea9 0e81
      JMP L0da7       JP $0DA7
L0ed3 LDB $63b5       LD A,($63B5)    0eb4
      DECB            DEC A
      STB $63b5       LD ($63B5),A
      CMPB #$f0       CP $F0
      BPL L0ee5       JP P,$0EE5
      LEAX -1,X       DEC HL
      LDB #$f7        LD A,$F7
      STB $63b5       LD ($63B5),A
L0ee5 JMP L0e62       JP $0E62        0edc
L0ee8 LDB $63b3       LD A,($63B3)    0e54
      CMPB #$03       CP $03
      BNE L0f1b       JP NZ,$0F1B
      LDX $63ab       LD HL,($63AB)
      LDB #$b3        LD A,$B3
      STB ,X          LD (HL),A
;                     LD BC,$0020     unnecessary?
      LEAX $20,X      ADD HL,BC
      LDB $63b1       LD A,($63B1)
      SUBB #$10       SUB 10
L0eff BCS L0f14       JP C,$0F14      0f11
      STB $63b1       LD ($63B1),A
      LDB #$b1        LD A,$B1
      STB ,X          LD (HL),A
;                     LD BC,$0020     unnecessary?
      LEAX $20,X      ADD HL,BC
      LDB $63b1       LD A,($63B1)
      SUBB #$08       SUB 08
      BRA L0eff       JP $0EFF
L0f14 LDB #$b2        LD A,$B2        0eff
      STB ,X          LD (HL),A
      LEAY 1,Y        INC DE
      JMP L0da7       JP $0DA7
L0f1b LDB $63b3       LD A,($63B3)    0eed
      CMPB #$07       CP $07
      BPL L0ecf       JP P,$0ECF
      CMPB #$04       CP $04
      BEQ L0f4c       JP Z,$0F4C
      CMPB #$05       CP $05
      BEQ L0f51       JP Z,$0F51
      LDB #$fe        LD A,$FE
L0f2f STB $63b5       LD ($63B5),A    0f53 0f4e
      LDX $63ab       LD HL,($63AB)
L0f35 LDB $63b5       LD A,($63B5)    0f45
      STB ,X          LD (HL),A
;                     LD BC,$0020     unnecessary?
      LEAX $20,X      ADD HL,BC
      LDB $63b1       LD A,($63B1)
      SUBB #$08       SUB 08
      STB $63b1       LD ($63B1),A
      BCC L0f35       JP NC,$0F35
      LEAY 1,Y        INC DE
      JMP L0da7       JP $0DA7
L0f4c LDB #$10        LD A,$E0        0f25 erase straight girder tiles during stomping sequence
      BRA L0f2f       JP $0F2F
L0f51 LDB #$b0        LD A,$B0        0f2a
      BRA L0f2f       JP $0F2F

L0f56 LDA #$27        LD B,$27        0d5f
      LDX #$6200      LD HL,$6200     Flag - Mario alive
      CLRB            XOR A           clear all flags
L0f5c STB ,X+         LD (HL),A       0f5e
;                     INC L
      DECA            DJNZ $0F5C
      BNE L0f5c
      LDA #$11        LD C,$11
      STA REGC 
;                     LD D,$80
      LDX #$6280      LD HL,$6280
L0f67 LDA #$80        LD B,D          0f6d
L0f68 STB ,X+         LD (HL),A       0f6a
;                     INC HL
      DECA            DJNZ $0F68
      BNE L0f68
      DEC REGC        DEC C
      BNE L0f67       JR NZ,$0F67
      LDX #L3d9c      LD HL,$3D9C
      LDY #$6280      LD DE,$6280
      LDA #32         LD BC,$0040
      STU REGIX 
L0f78 LDU ,X++        LDIR
      STU ,Y++
      DECA
      BNE L0f78
      LDU REGIX 
      LDB $6229       LD A,($6229)
      LDA #10         LD B,A
      MUL             AND A
;                     RLA
;                     AND A
;                     RLA
;                     AND A
;                     RLA
;                     ADD A,B
;                     ADD A,B
      ADDB #$28       ADD A,$28
      CMPB #$51       CP $51
      BCS L0f8e       JR C,$0F8E
      LDB #$50        LD A,$50
L0f8e LDX #$62b0      LD HL,$62B0     0f8a
      LDA #$03        LD B,$03
L0f93 STB ,X+         LD (HL),A       0f95
;                     INC L
      DECA            DJNZ $0F93
      BNE L0f93
      ASLB            ADD A,A
      STB REGB        LD B,A
      LDB #$dc        LD A,$DC
      SUBB REGB       SUB B
      CMPB #$28       CP $28
      BCC L0fa2       JR NC,$0FA2
      LDB #$28        LD A,$28
L0fa2 STB ,X+         LD (HL),A       0f9e
;                     INC L
      STB ,X          LD (HL),A
      LDX #$6209      LD HL,$6209
      LDA #$04        LD (HL),$04
      STA ,X+         INC L
      LDA #$08        LD (HL),$08
      STA ,X
      LDB $6227       LD A,($6227)    Level Type
      STB REGC        LD C,A
      ANDB #4         BIT 2,A
      BNE L0fcb       JR NZ,$0FCB
      LDX #$6a00      LD HL,$6A00
      LDB #$4f        LD A,$4F
      LDA #$03        LD B,$03
      STA REGB 
L0fbc STB ,X+         LD (HL),A       0fc9
;                     INC L
      LDA #$3a        LD (HL),$3A
      STA ,X+         INC L
      LDA #$0f        LD (HL),$0F
      STA ,X+         INC L
      LDA #$18        LD (HL),$18
      STA ,X+         INC L
      ADDB #$10       ADD A,$10
      DEC REGB        DJNZ $0FBC
      BNE L0fbc
L0fcb LDB REGC        LD A,C          0fb3
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L0000
      FDB L0fd7                       Initialize level 1 - girder
      FDB L101f                       Initialize level 2 - elevator
      FDB L1087                       Initialize level 3 - cement
      FDB L1131                       Initialize level 4 - rivets

L0fd7 LDX #L3ddc      LD HL,$3DDC     Initialize level 1 - girder
      LDY #$69a8      LD DE,$69A8
      LDB #$10        LD BC,$0010
L0fe0 LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L0fe0
      LDX #L3dec      LD HL,$3DEC     Fireball sprite data
      LDY #$6407      LD DE,$6407
      LDD #$051c      LD C,$1C
      STD REGBC       LD B,$05
      JSR L122a       CALL $122A
      LDX #L3df4      LD HL,$3DF4
      JSR L11fa       CALL $11FA
      LDX #L3e00      LD HL,$3E00
      LDY #$69fc      LD DE,$69FC
      LDB #$04        LD BC,$0004
L0ffe LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L0ffe
      LDX #L3e0c      LD HL,$3E0C
      JSR L11a6       CALL $11A6
      LDX #L101b      LD HL,$101B
      LDY #$6707      LD DE,$6707
      LDD #$081c      LD BC,$081C
      STD REGBC 
      JSR L122a       CALL $122A
      LDY #$6807      LD DE,$6807
      LDA #$02        LD B,$02
      STA REGB 
      JSR L122a       CALL $122A
      RTS             RET

;                                     Cement level - unknown sprites?
L101b FCB $00,$00,$02,$02

;                                     Initialize level 2 - elevator
;
L101f LDX #L3dec      LD HL,$3DEC     Fireball sprite data
      LDY #$6407      LD DE,$6407
      LDD #$051c      LD BC,$051C
      STD REGBC 
      JSR L122a       CALL $122A
      JSR L1186       CALL $1186
      LDX #L3e18      LD HL,$3E18
      LDY #$65a7      LD DE,$65A7
      LDD #$060c      LD BC,$060C
      STD REGBC 
      JSR L122a       CALL $122A
      LDU #$65a0      LD IX,$65A0
      LDX #$69b8      LD HL,$69B8
      LDY #$0010      LD DE,$0010
      LDA #$06        LD B,$06
      STA REGB 
      JSR L11d3       CALL $11D3
      LDX #L3dfa      LD HL,$3DFA
      JSR L11fa       CALL $11FA
      LDX #L3e04      LD HL,$3E04
      LDY #$69fc      LD DE,$69FC
      LDB #$04        LD BC,$0004
L1058 LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L1058
      LDX #L3e1c      LD HL,$3E1C
      LDY #$6944      LD DE,$6944
      LDB #$08        LD BC,$0008
L1063 LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L1063
      LDX #L3e24      LD HL,$3E24
      LDY #$69e4      LD DE,$69E4
      LDB #$18        LD BC,$0018
L106e LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L106e
      LDX #L3e10      LD HL,$3E10
      JSR L11a6       CALL $11A6
      LDX #L3e3c      LD HL,$3E3C
      LDY #$6a0c      LD DE,$6A0C
      LDB #$0c        LD BC,$000C
L107f LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L107f
      LDB #$01        LD A,$01
      STB $62b9       LD ($62B9),A
      RTS             RET

;                                     Initialize level 3 - cement
;
L1087 LDX #L3dec      LD HL,$3DEC     Fireball sprite data
      LDY #$6407      LD DE,$6407
      LDD #$051c      LD BC,$051C
      STD REGBC 
      JSR L122a       CALL $122A
      JSR L1186       CALL $1186
      LDX #$6600      LD HL,$6600
;                     LD DE,$0010
      LDB #$01        LD A,$01
      LDA #$06        LD B,$06
L10a0 STB ,X          LD (HL),A       10a2
      LEAX $10,X      ADD HL,DE
      DECA            DJNZ $10A0
      BNE L10a0
      LDA #$02        LD C,$02
      STA REGC 
      LDB #$08        LD A,$08
L10a8 LDA #$03        LD B,$03        10b4
      LDX #$660d      LD HL,$660D
L10ad STB ,X          LD (HL),A       10af
      LEAX $10,X      ADD HL,DE
      DECA            DJNZ $10AD
      BNE L10ad
;                     LD A,$08
      DEC REGC        DEC C
      BNE L10a8       JP NZ,$10A8
      LDX #L3e64      LD HL,$3E64
      LDY #$6603      LD DE,$6603
      LDD #$060e      LD BC,$060E
      STA REGB 
      JSR L11ec       CALL $11EC
      LDX #L3e60      LD HL,$3E60
      LDY #$6607      LD DE,$6607
      LDD #$060c      LD BC,$060C
      STD REGBC 
      JSR L122a       CALL $122A
      LDU #$6600      LD IX,$6600
      LDX #$6958      LD HL,$6958
      LDA #$06        LD B,$06
      STA REGB 
      LDY #$0010      LD DE,$0010
      JSR L11d3       CALL $11D3
      LDX #L3e48      LD HL,$3E48
      LDY #$6a0c      LD DE,$6A0C
      LDB #6          LD BC,$000C
L10e7 LDU ,X++        LDIR
      STU ,Y++
      DECB
      BNE L10e7
      LDU #$6400      LD IX,$6400     fireball character data
      LDD #$0158      LD (IX+$00),$01
      STA ,U
      STB $3,U        LD (IX+$03),$58
      STB $e,U        LD (IX+$0E),$58
      LDB #$80        LD (IX+$05),$80
      STB $5,U
      STB $f,U        LD (IX+$0F),$80
      STA $20,U       LD (IX+$20),$01
      LDD #$eb60      LD (IX+$23),$EB
      STA $23,U
      STA $2e,U       LD (IX+$2E),$EB
      STB $25,U       LD (IX+$25),$60
      STB $2f,U       LD (IX+$2F),$60
      LDY #$6970      LD DE,$6970
      LDX #L1121      LD HL,$1121
      LDB #$10        LD BC,$0010
L111e LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L111e
      RTS             RET

;                                     Elevator Level - Elevator cap sprites
;L1121 FCB $37,$45,$0f,$60,$37,$45,$8f,$f7,$77,$45,$0f,$60,$77,$45,$8f,$f7
L1121 FCB $37,$45,$0f,$60,$37,$c5,$0f,$f7,$77,$45,$0f,$60,$77,$c5,$0f,$f7

;                                     Initialize level 4 - rivets
;
L1131 LDX #L3df0      LD HL,$3DF0     Fireball (type 2) sprite data
      LDY #$6407      LD DE,$6407
      LDD #$051c      LD BC,$051C
      STD REGBC 
      JSR L122a       CALL $122A
      LDX #L3e14      LD HL,$3E14
      BSR L11a6       CALL $11A6
      LDX #L3e54      LD HL,$3E54
      LDY #$6a0c      LD DE,$6A0C
      LDB #$0c        LD BC,$000C
L114c LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L114c
      LDX #L1182      LD HL,$1182
      LDY #$64a3      LD DE,$64A3
      LDD #$021e      LD BC,$021E
      STA REGB 
      JSR L11ec       CALL $11EC
      LDX #L117e      LD HL,$117E
      LDY #$64a7      LD DE,$64A7
      LDD #$021c      LD BC,$021C
      STD REGBC 
      JSR L122a       CALL $122A
      LDU #$64a0      LD IX,$64A0
      LDA #$01        LD (IX+$00),$01
      STA ,U
      STA $20,U       LD (IX+$20),$01
      LDX #$6950      LD HL,$6950
      LDA #$02        LD B,$02
      STA REGB 
      LDY #$0020      LD DE,$0020
      BSR L11d3       CALL $11D3
      RTS             RET

;                                     Rivets level? Unknown sprites?
L117e FCB $3f,$0c,$08,$08
L1182 FCB $73,$50,$8d,$50

L1186 LDX #L11a2      LD HL,$11A2     1093 102b
      LDY #$6507      LD DE,$6507
      LDD #$0a0c      LD BC,$0A0C
      STD REGBC 
      JSR L122a       CALL $122A
      LDU #$6500      LD IX,$6500
      LDX #$6980      LD HL,$6980     initialize 10 spring objects?
      LDA #$0a        LD B,$0A
      STA REGB 
      LDY #$0010      LD DE,$0010
      BSR L11d3       CALL $11D3
      RTS             RET

;                                     Elevator level - bouncing spring sprite
L11a2 FCB $3b,$00,$02,$02

L11a6 LDY #$6683      LD DE,$6683     1140 1073 1003
      LDD #$020e      LD BC,$020E
      STA REGB 
      BSR L11ec       CALL $11EC
      LDX #L3e08      LD HL,$3E08
      LDY #$6687      LD DE,$6687
      LDD #$020c      LD BC,$020C
      STD REGBC 
      JSR L122a       CALL $122A
      LDU #$6680      LD IX,$6680     hammer character data
      LDA #$01        LD (IX+$00),$01
      STA ,U
      STA $10,U       LD (IX+$10),$01
      LDX #$6a18      LD HL,$6A18     location of hammers in sprite ram
      LDA #$02        LD B,$02        2 hammers
      STA REGB 
      LDY #$0010      LD DE,$0010
      BSR L11d3       CALL $11D3
      RTS             RET

;                                     copy sprite data to sprite display RAM
;
L11d3 LDB $3,U        LD A,(IX+$03)   11e9 11cf 119e 117a 10db 1046
      andb #$fe                       coco hack to speed up sprites
      STB ,X          LD (HL),A       set sprite X
;                     INC L
      LDB $7,U        LD A,(IX+$07)   set sprite character #
      STB 1,X         LD (HL),A
;                     INC L
;     LDB $8,U        LD A,(IX+$08)   set sprite vflip/palette
;     STB 2,X         LD (HL),A
;                     INC L
      LDB $5,U        LD A,(IX+$05)   set sprite Y
      STB 3,X         LD (HL),A
      LEAX 4,X        INC L
      STB REGA        ADD IX,DE
      TFR Y,D
      LEAU D,U
      LDB REGA 
      DEC REGB        DJNZ $11D3
      BNE L11d3
      RTS             RET

L11ec LDA ,X+         LD A,(HL)       11f7 11ac 1157 10c0
      STA ,Y++        LD (DE),A
;                     INC HL
;                     INC E
;                     INC E
      LDA ,X+         LD A,(HL)
      STA ,Y          LD (DE),A
;                     INC HL
;                     LD A,E
      LEAY B,Y        ADD A,C
;                     LD E,A
      DEC REGB        DJNZ $11EC
      BNE L11ec
      RTS             RET

L11fa LDU #$66a0      LD IX,$66A0     104c 0ff2
      LDY #$6a28      LD DE,$6A28
      LDA #$01        LD (IX+$00),$01
      STA ,U
      LDB ,X+         LD A,(HL)
      STB $3,U        LD (IX+$03),A   set sprite X
      andb #$fe                       coco hack to speed up sprites
      STB ,Y          LD (DE),A
;                     INC E
;                     INC HL
      LDB ,X+         LD A,(HL)
      STB $7,U        LD (IX+$07),A   set sprite character #
      STB 1,Y         LD (DE),A
;                     INC E
;                     INC HL
      LDB ,X+         LD A,(HL)
      STB $8,U        LD (IX+$08),A   set sprite h-flip & palette
;     STB 2,Y         LD (DE),A
;                     INC E
;                     INC HL
      LDB ,X+         LD A,(HL)
      STB $5,U        LD (IX+$05),A   set sprite Y
      STB 3,Y         LD (DE),A
;                     INC HL
      LDB ,X+         LD A,(HL)
      STB $9,U        LD (IX+$09),A
;                     INC HL
      LDB ,X          LD A,(HL)
      STB $a,U        LD (IX+$0A),A
      RTS             RET

L122a PSHS X          PUSH HL         1239 11b8 118f 1163 113a 10cc 1090 1037 1028 1017 100f 0fec
;                     PUSH BC
      LDA #$04        LD B,$04
L122e LDB ,X+         LD A,(HL)       1232
      STB ,Y+         LD (DE),A
;                     INC HL
;                     INC E
      DECA            DJNZ $122E
      BNE L122e
;                     POP BC
      PULS X          POP HL
;                     LD A,E
      LDA REGC        ADD A,C
      LEAY A,Y        LD E,A
      DEC REGB        DJNZ $122A
      BNE L122a
      RTS             RET

L123c JSR L0018       RST $18
      LDD #$e016      LD BC,$E016
      STD REGBC 
      LDA $6227       LD A,($6227)    Level Type
      CMPA #$03       CP $03
      BEQ L124b       JP Z,$124B
      LDD #$f03f      LD BC,$F03F
      STD REGBC 
L124b LDU #$6200      LD IX,$6200     1245 Mario Flags
      LDX #$694c      LD HL,$694C
      LDA #$01        LD (IX+$00),$01 Flag - Set Mario alive
      STA ,U
      STB $3,U        LD (IX+$03),C   sprite X
      andb #$fe                       coco hack to speed up sprites
      STB ,X          LD (HL),C
;                     INC L
      LDA #$80        LD (IX+$07),$80 sprite character #
      STA $7,U 
      STA 1,X         LD (HL),$80
;                     INC L
      LDA #$02        LD (IX+$08),$02 sprite h-flip & palette
      STA $8,U 
;      STA 2,X         LD (HL),$02
;                     INC L
      LDA REGB        LD (IX+$05),B   sprite Y
      STA $5,U 
      STA 3,X         LD (HL),B
      LDA #$01        LD (IX+$0F),$01
      STA $f,U 
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      INC ,X          INC (HL)
      LDY #$0601      LD DE,$0601
      JSR L309f       CALL $309F
      RTS             RET

L127c JSR L1dbd       CALL $1DBD      process mario death animation?
      LDB $639d       LD A,($639D)
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L128b                       delay before spinning
      FDB L12ac                       spin mario in death
      FDB L12de                       dead mario lying down
;     FDB L0000

L128b JSR L0018       RST $18
      LDX #$694d      LD HL,$694D
      LDB #$f0        LD A,$F0        Mario dead sprite character # <<1
      ROL ,X          RL (HL)
      RORB            RRA
      STB ,X          LD (HL),A
      LDX #$639d      LD HL,$639D
      INC ,X          INC (HL)
      LDB #$0d        LD A,$0D
      STB $639e       LD ($639E),A
      LDB #$08        LD A,$08
      STB $6009       LD ($6009),A
      JSR L30bd       CALL $30BD
      LDB #$03        LD A,$03
      STB $6088       LD ($6088),A
      RTS             RET

L12ac JSR L0018       RST $18
      LDB #$08        LD A,$08
      STB $6009       LD ($6009),A
      LDX #$639e      LD HL,$639E
      DEC ,X          DEC (HL)
      BEQ L12cb       JP Z,$12CB
      LDX #$694d      LD HL,$694D
      LDB ,X          LD A,(HL)
      RORB            RRA
      LDB #$02        LD A,$02
      RORB            RRA
      STB REGB        LD B,A
      EORB ,X         XOR (HL)
      STB ,X+         LD (HL),A
;                     INC L
      LDB REGB        LD A,B
      ANDB #$80       AND $80         flip mario upside down when dying?
      lda -1,X                        coco hack to use modified sprite tiles
      ora #$40
      EORB ,X         XOR (HL)
      bpl hack2
      cmpa #$79
      beq hack2
      cmpa #$f9
      beq hack2
      anda #$bf
hack2 std -1,x
;     STB ,X          LD (HL),A      
      RTS             RET
L12cb LDX #$694d      LD HL,$694D      12b6
      LDB #$f4        LD A,$F4
      ROL ,X          RL (HL)
      RORB            RRA
      STB ,X          LD (HL),A
      LDX #$639d      LD HL,$639D
      INC ,X          INC (HL)
      LDB #$80        LD A,$80
      STB $6009       LD ($6009),A
      RTS             RET

L12de JSR L0018       RST $18
      JSR L30db       CALL $30DB
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      LDB $600e       LD A,($600E)
;                     AND A
      BEQ L12ed       JP Z,$12ED
      INC ,X          INC (HL)
L12ed INC ,X          INC (HL)        12e9
;                     DEC HL
      LDA #$01        LD (HL),$01
      STA ,-X
      RTS             RET

L12f2 JSR L011c       CALL $011C      save current level data to P1
      CLRB            XOR A
      STB $622c       LD ($622C),A
      LDX #$6228      LD HL,$6228     current level data 8-bytes
      DEC ,X          DEC (HL)        Decrement Number of lives?
      LDB ,X          LD A,(HL)       Number of lives?
      LDY #$6040      LD DE,$6040     P1 level data 8-bytes
      LDA #4          LD BC,$0008
      STU REGIX 
L1304 LDU ,X++        LDIR
      STU ,Y++
      DECA
      BNE L1304
      LDU REGIX 
      TSTB            AND A
      BNE L1334       JP NZ,$1334
      LDB #$01        LD A,$01
      LDX #$60b2      LD HL,$60B2
      JSR L13ca       CALL $13CA
      LDX #$76d4      LD HL,$76D4
      LDB $600f       LD A,($600F)
;                     AND A
      BEQ L1322       JR Z,$1322
      LDY #$0302      LD DE,$0302
      JSR L309f       CALL $309F
      LEAX -1,X       DEC HL
L1322 JSR L1826       CALL $1826      1319
      LDY #$0300      LD DE,$0300
      JSR L309f       CALL $309F
      LDX #$6009      LD HL,$6009
      LDA #$c0        LD (HL),$C0
      STA ,X+         INC HL
      LDA #$10        LD (HL),$10     $600a Game Screen Sequencer
      STA ,X
      RTS             RET
L1334 LDB #$08        LD C,$08        1307 Set How High Can You Get screen?
      LDA $600f       LD A,($600F)
;                     AND A
      BEQ L133f       JP Z,$133F
      LDB #$17        LD C,$17        Set to switch players???
L133f STB REGC        LD A,C          133a
      STB $600a       LD ($600A),A    Game Screen Sequencer
      RTS             RET

L1344 JSR L011c       CALL $011C      copy current level data to P2
      CLRB            XOR A
      STB $622c       LD ($622C),A
      LDX #$6228      LD HL,$6228     current level data 8-bytes
      DEC ,X          DEC (HL)        Decrement Number of lives?
      LDB ,X          LD A,(HL)       Number of lives?
      LDY #$6048      LD DE,$6048     P2 level data 8-bytes
      LDA #4          LD BC,$0008
      STU REGIX 
L1356 LDU ,X++        LDIR
      STU ,Y++
      DECA
      BNE L1356
      LDU REGIX 
      TSTB            AND A
      BNE L137f       JP NZ,$137F
      LDB #$03        LD A,$03
      LDX #$60b5      LD HL,$60B5
      BSR L13ca       CALL $13CA
      LDY #$0303      LD DE,$0303
      JSR L309f       CALL $309F
      LDY #$0300      LD DE,$0300
      JSR L309f       CALL $309F
      LDX #$76d3      LD HL,$76D3
      JSR L1826       CALL $1826
      LDX #$6009      LD HL,$6009
      LDA #$c0        LD (HL),$C0
      STA ,X+         INC HL
      LDA #$11        LD (HL),$11     $600a Game Screen Sequencer
      STA ,X
      RTS             RET
L137f LDB #$17        LD C,$17        1359 Set to switch players???
      LDA $6040       LD A,($6040)
;                     AND A
      BNE L138a       JP NZ,$138A
      LDB #$08        LD C,$08        Set How High Can You Get screen?
L138a STB REGC        LD A,C          1385
      STB $600a       LD ($600A),A    Game Screen Sequencer
      RTS             RET

L138f JSR L0018       RST $18
      LDB #$17        LD C,$17        ??? screen
      LDA $6048       LD A,($6048)
L1395 INC ,X          INC (HL)        13a7
      TSTA            AND A
      BNE L139c       JP NZ,$139C
      LDB #$14        LD C,$14        ??? screen
L139c STB REGC        LD A,C          1397
      STB $600a       LD ($600A),A    Game Screen Sequencer
      RTS             RET

L13a1 JSR L0018       RST $18
      LDB #$17        LD C,$17        ??? screen
      LDA $6040       LD A,($6040)
      BRA L1395       JP $1395

L13aa LDB $6026       LD A,($6026)
      STB $7d82       LD ($7D82),A    Flip Screen
      CLRB            XOR A
      STB $600a       LD ($600A),A    Game Screen Sequencer
      LDX #$0101      LD HL,$0101
      STX $600d       LD ($600D),HL
      RTS             RET

L13bb CLRB            XOR A
      STB $600d       LD ($600D),A
      STB $600e       LD ($600E),A
      STB $600a       LD ($600A),A    Game Screen Sequencer
      INCB            INC A
      STB $7d82       LD ($7D82),A    Flip Screen
      RTS             RET

L13ca LDY #$61c6      LD DE,$61C6     1361 130f
      STB ,Y          LD (DE),A
      JSR L0008       RST $08
      LEAY 1,Y        INC DE
      LDB #$03        LD BC,$0003
L13d3 LDA ,X+         LDIR
      STA ,Y+
      DECB
      BNE L13d3
      LDA #$03        LD B,$03
      LDX #$61b1      LD HL,$61B1
;13da                 DEC DE          13e9
L13da LDB ,-Y         LD A,(DE)
      LSRB            RRCA
      LSRB            RRCA
      LSRB            RRCA
      LSRB            RRCA
;     ANDB #$0f       AND $0F
      STB ,X+         LD (HL),A
;                     INC HL
      LDB ,Y          LD A,(DE)
      ANDB #$0f       AND $0F
      STB ,X+         LD (HL),A
;                     INC HL
      DECA            DJNZ $13DA
      BNE L13da
      LDA #$0e        LD B,$0E
      LDB #$10
L13ed STB ,X+         LD (HL),$10     13f0
;                     INC HL
      DECA            DJNZ $13ED
      BNE L13ed
      LDB #$3f        LD (HL),$3F
      STB ,X
      LDA #$05        LD B,$05
      STA REGB 
      LDX #$61a5      LD HL,$61A5
      LDY #$61c7      LD DE,$61C7
L13fc LDB ,Y+         LD A,(DE)       141b
      SUBB ,X+        SUB (HL)
;                     INC HL
;                     INC DE
      LDB ,Y+         LD A,(DE)
      SBCB ,X+        SBC A,(HL)
;                     INC HL
;                     INC DE
      LDB ,Y          LD A,(DE)
      SBCB ,X         SBC A,(HL)
      BCS L141d       RET C
;                     PUSH BC
      LDA #$19        LD B,$19
      STA REGA 
L140a LDA ,X          LD C,(HL)       1411
      LDB ,Y          LD A,(DE)
      STB ,X          LD (HL),A
;                     LD A,C
      STA ,Y          LD (DE),A
      LEAX -1,X       DEC HL
      LEAY -1,Y       DEC DE
      DEC REGA        DJNZ $140A
      BNE L140a
;                     LD BC,$FFF5
      LEAX -11,X      ADD HL,BC
;                     EX DE,HL
      LEAY -11,Y      ADD HL,BC
;                     EX DE,HL
;                     POP BC
      DEC REGB        DJNZ $13FC
      BNE L13fc
L141d RTS             RET

L141e JSR L0616       CALL $0616      Print CREDITS xx
      JSR L0018       RST $18
      JSR L0874       CALL $0874
      CLRB            LD A,$00
      STB $600e       LD ($600E),A
      STB $600d       LD ($600D),A
      LDX #$611c      LD HL,$611C
      LDY #$0022      LD DE,$0022     unnecessary?
      LDA #$05        LD B,$05
      LDB #$01        LD A,$01
L1437 CMPB ,X         CP (HL)         143c
      BEQ L1459       JP Z,$1459
      LEAX $22,X      ADD HL,DE
      DECA            DJNZ $1437
      BNE L1437
      LDX #$611c      LD HL,$611C
      LDD #$0503      LD B,$05
;     LDB #$03        LD A,$03
L1445 CMPB ,X         CP (HL)         144a
      BEQ L144f       JP Z,$144F
      LEAX $22,X      ADD HL,DE
      DECA            DJNZ $1445
      BNE L1445
      BRA L1475       JP $1475
L144f LDB #$01        LD A,$01        1446
      STB $600e       LD ($600E),A
      STB $600d       LD ($600D),A
      CLRB            LD A,$00
L1459 LDX #$6026      LD HL,$6026     1438
      ORB ,X          OR (HL)
      STB $7d82       LD ($7D82),A    Flip Screen
;     CLRB            LD A,$00
      CLR $6009       LD ($6009),A
      LDX #$600a      LD HL,$600A     Game Screen Sequencer
      INC ,X          INC (HL)
      LDY #$030d      LD DE,$030D
      LDA #$0c        LD B,$0C
      STA REGB
L146e JSR L309f       CALL $309F      1472
      LEAY 1,Y        INC DE
      DEC REGB        DJNZ $146E
      BNE L146e
      RTS             RET
L1475 LDB #$01        LD A,$01        144c
      STB $7d82       LD ($7D82),A    Flip Screen
      STB $6005       LD ($6005),A
      STB $6007       LD ($6007),A    Set Attract mode flag
;     CLRB            LD A,$00
      CLR $600a       LD ($600A),A    Game Screen Sequencer
      RTS             RET

; High score initials entry screen
;
L1486 JSR L0616       CALL $0616      Print CREDITS xx
      LDX #$6009      LD HL,$6009
      LDB ,X          LD A,(HL)
;                     AND A
      BNE L14dc       JP NZ,$14DC
      STB $7d86       LD ($7D86),A    BG Palette select
      STB $7d87       LD ($7D87),A    BG Palette select
      JSR SETPAL                      this sets palette too late!
      LDA #$01        LD (HL),$01
      STA ,X
      LDX #$6030      LD HL,$6030
      LDA #$0a        LD (HL),$0A
      STA ,X+         INC HL
      CLR ,X+         LD (HL),$00
;                     INC HL
      LDA #$10        LD (HL),$10
      STA ,X+         INC HL
      LDA #$1e        LD (HL),$1E
      STA ,X+         INC HL
      LDA #$3e        LD (HL),$3E
      STA ,X+         INC HL
      CLR ,X          LD (HL),$00
      LDX #$75e8      LD HL,$75E8
      STX $6036       LD ($6036),HL
      LDX #$611c      LD HL,$611C
      LDB $600e       LD A,($600E)
      LSLB            RLCA
      INCB            INC A
      STB REGC        LD C,A
;                     LD DE,$0022
      LDA #$04        LD B,$04
L14c1 LDB ,X          LD A,(HL)       14c7
      CMPB REGC       CP C
      BEQ L14c9       JP Z,$14C9
      LEAX $22,X      ADD HL,DE
      DECA            DJNZ $14C1
      BNE L14c1
L14c9 STX $6038       LD ($6038),HL   14c3 point to high score
      LDY #$fff3      LD DE,$FFF3     unnecessary?
      LEAX -13,X      ADD HL,DE
      STX $603a       LD ($603A),HL
;                     LD B,$00
      LDB $6035       LD A,($6035)
      STB REGC        LD C,A
      JSR L15fa       CALL $15FA      Set high score initial select sprite
L14dc LDX #$6034      LD HL,$6034     148e
      DEC ,X          DEC (HL)
      BNE L14fc       JP NZ,$14FC
      LDA #$3e        LD (HL),$3E
      STA ,X
;                     DEC HL
      DEC ,-X         DEC (HL)
      LBEQ L15c6      JP Z,$15C6
      LDB ,X          LD A,(HL)
      LDA #$ff        LD B,$FF
L14ed INCA            INC B           14f0
      SUBB #$0a       SUB 0A
      BCC L14ed       JP NC,$14ED
      ADDB #$0a       ADD A,$0A
      STB $7552       LD ($7552),A
;                     LD A,B
      STA $7572       LD ($7572),A
L14fc LDX #$6030      LD HL,$6030     14e0
      LDA ,X          LD B,(HL)
      STA REGB 
      LDA #$0a        LD (HL),$0A
      STA ,X
      LDB $6010       LD A,($6010)    Joystick inputs
;                     BIT 7,A
      BMI L1546       JP NZ,$1546
      ANDB #$03       AND $03
      BNE L1514       JP NZ,$1514
      INCB            INC A
      STB ,X          LD (HL),A
      JMP L158a       JP $158A
L1514 DEC REGB        DEC B           150c
      BEQ L151d       JP Z,$151D
      LDB REGB        LD A,B
      STB ,X          LD (HL),A
      BRA L158a       JP $158A
L151d ANDB #2         BIT 1,A         1515
      BNE L1539       JP NZ,$1539
      LDB $6035       LD A,($6035)
      INCB            INC A
      CMPB #$1e       CP $1E
      BNE L152d       JP NZ,$152D
      CLRB            LD A,$00
L152d STB $6035       LD ($6035),A    1543 153e 1528
      STB REGC        LD C,A
;                     LD B,$00
      JSR L15fa       CALL $15FA
      BRA L158a       JP $158A
L1539 LDB $6035       LD A,($6035)    151f
      SUBB #$01       SUB 01
      BPL L152d       JP P,$152D
      LDB #$1d        LD A,$1D
      BRA L152d       JP $152D
L1546 LDB $6035       LD A,($6035)    1507
      CMPB #$1c       CP $1C
      BEQ L156d       JP Z,$156D
      CMPB #$1d       CP $1D
      BEQ L15c6       JP Z,$15C6
      LDX $6036       LD HL,($6036)
;                     LD BC,$7588     unnecessary
      TSTB            AND A
      CMPX #$7588     SBC HL,BC
      BEQ L158a       JP Z,$158A
;                     ADD HL,BC
      ADDB #$11       ADD A,$11
      STB ,X          LD (HL),A
;                     LD BC,$FFE0     unnecessary?
      LEAX -32,X      ADD HL,BC
L1567 STX $6036       LD ($6036),HL   1583
      BRA L158a       JP $158A
L156d LDX $6036       LD HL,($6036)   154b
;                     LD BC,$0020     unnecessary
      LEAX $20,X      ADD HL,BC
;                     AND A           clear carry?
;                     LD BC,$7608     unnecessary
      CMPX #$7608     SBC HL,BC
      BNE L1580       JP NZ,$1586
      LDX #$75e8      LD HL,$75E8
L1580 LDB #$10        LD A,$10        1587
      STB ,X          LD (HL),A
      BRA L1567       JP $1567
;                     ADD HL,BC       157a
;                     JP $1580
L158a LDX #$6032      LD HL,$6032     156a 155c 1536 151a 1511
      DEC ,X          DEC (HL)
      BNE L15f9       JP NZ,$15F9
      LDB $6031       LD A,($6031)
;                     AND A
      BNE L15b8       JP NZ,$15B8
      LDB #$01        LD A,$01
      STB $6031       LD ($6031),A
      LDY #L01bf      LD DE,$01BF     point to "empty/dummy score"
L15a0 LDX $6038       LD IY,($6038)   15c3 point to high score
      STX REGIY 
      LDX 4,X         LD L,(IY+$04)   conv to big endian
;                     LD H,(IY+$05)
      TFR X,U         PUSH HL
;                     POP IX
      JSR L057c       CALL $057C      Print score (or erase score...)
      LDB #$10        LD A,$10
      STB $6032       LD ($6032),A
      BRA L15f9       JP $15F9
L15b8 CLRB            XOR A           1595
      STB $6031       LD ($6031),A
      LDY $6038       LD DE,($6038)   point to high score
      LEAY 3,Y        INC DE
;                     INC DE
;                     INC DE
      BRA L15a0       JP $15A0
L15c6 LDY $6038       LD DE,($6038)   1550 14e7 point to high score
      CLRB            XOR A
      STB ,Y          LD (DE),A
      LDX #$6009      LD HL,$6009
      LDA #$80        LD (HL),$80
      STA ,X+         INC HL
      DEC ,X          DEC (HL)
      LDA #$0c        LD B,$0C
      LDX #$75e8      LD HL,$75E8
      LDY $603a       LD IY,($603A)
;                     LD DE,$FFE0
L15df LDB ,X          LD A,(HL)       15e6
      STB ,Y+         LD (IY+$00),A
;                     INC IY
      LEAX -32,X      ADD HL,DE
      DECA            DJNZ $15DF
      BNE L15df
      STY REGIY 
      LDA #$05        LD B,$05
      STA REGB 
      LDY #$0314      LD DE,$0314
L15ed JSR L309f       CALL $309F      15f1
      LEAY 1,Y        INC DE
      DEC REGB        DJNZ $15ED
      BNE L15ed
      LDY #$031a      LD DE,$031A
      JSR L309f       CALL $309F
L15f9 RTS             RET             15b5 158e ;

L15fa PSHS Y,X        PUSH DE         1533 14d9
;                     PUSH HL
      ASL REGC        SLA C
      LDX #L360f      LD HL,$360F
      LDB REGC        ADD HL,BC       REGB is always zero
      ABX
      TFR X,Y         EX DE,HL
      LDX #$6974      LD HL,$6974     Set sprite for initials entry
      LDB ,Y+         LD A,(DE)
;                     INC DE
;     andb #$fe                       coco hack to speed up sprites
      STB ,X          LD (HL),A       X Coordinate
;                     INC HL
      LDA #$72        LD (HL),$72     Character #
      STA 1,X         INC HL
;     LDA #$0c        LD (HL),$0C     Palette
;     STA 2,X         INC HL
      LDB ,Y          LD A,(DE)
      STB 3,X         LD (HL),A       Y Coordinate
      PULS X,Y,PC     POP HL
;                     POP DE
;                     RET

L1615 JSR L30bd       CALL $30BD
      LDB $6227       LD A,($6227)    Level Type
      LSRB            RRCA
      BCC L162f       JP NC,$162F
      LDB $6388       LD A,($6388)
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L1654
      FDB L1670
      FDB L168a
      FDB L1732
      FDB L1757
      FDB L178e

L162f LSRB            RRCA            161c
      BCC L1641       JP NC,$1641
      LDB $6388       LD A,($6388)
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L16a3
      FDB L16bb
      FDB L1732
      FDB L1757
      FDB L178e

L1641 JSR L1dbd       CALL $1DBD      1630
      LDB $6388       LD A,($6388)
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L17b6
      FDB L3069
      FDB L1839
      FDB L186f
      FDB L1880
      FDB L18c6

L1654 JSR L1708       CALL $1708
      LDX #L385c      LD HL,$385C
      JSR L004e       CALL $004E
      LDB #$20        LD A,$20
      STB $6009       LD ($6009),A

L1662 LDX #$6388      LD HL,$6388     16a0
      INC ,X          INC (HL)
      LDB #$01        LD A,$01
      JSR L0030       RST $30
      LDX #$690b      LD HL,$690B
      LDA #$fc        LD C,$FC
      STA REGC 
      JSR L0038       RST $38
      RTS             RET

L1670 JSR L0018       RST $18
      LDX #L3932      LD HL,$3932
      JSR L004e       CALL $004E
      LDB #$20        LD A,$20
      STB $6009       LD ($6009),A
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
      LDB #$04        LD A,$04
      JSR L0030       RST $30
      LDX #$690b      LD HL,$690B
      LDA #$04        LD C,$04
      STA REGC 
      JSR L0038       RST $38
      RTS             RET

L168a JSR L0018       RST $18
      LDX #L388c      LD HL,$388C
      JSR L004e       CALL $004E
      LDB #$66        LD A,$66
      STB $690c       LD ($690C),A
      CLRB            XOR A
      STB $6924       LD ($6924),A
      STB $692c       LD ($692C),A
      STB $62af       LD ($62AF),A
      BRA L1662       JP $1662

L16a3 BSR L1708       CALL $1708
      LDB $6910       LD A,($6910)
      SUBB #$3b       SUB 3B
      LDX #L385c      LD HL,$385C
      JSR L004e       CALL $004E
      LDX #$6908      LD HL,$6908
      STB REGC        LD C,A
      JSR L0038       RST $38
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
      RTS             RET

L16bb CLRB            XOR A
      STB $62a0       LD ($62A0),A
      LDB $63a3       LD A,($63A3)
      STB REGC        LD C,A
      LDB $6910       LD A,($6910)
      CMPB #$5a       CP $5A
      BCC L16e1       JP NC,$16E1
      LDA REGC        BIT 7,C
      BPL L16d5       JP Z,$16D5
L16d0 LDB #$01        LD A,$01        16e8
      STB $62a0       LD ($62A0),A
L16d5 JSR L2602       CALL $2602      16eb 16cd
      LDB $63a3       LD A,($63A3)
      STB REGC        LD C,A
      LDX #$6908      LD HL,$6908
      JSR L0038       RST $38
      RTS             RET
L16e1 CMPB #$5d       CP $5D          16c8
      BCS L16ee       JP C,$16EE
      LDA REGC        BIT 7,C
      BPL L16d0       JP Z,$16D0
      BRA L16d5       JP $16D5
L16ee LDX #L388c      LD HL,$388C     16e3
      JSR L004e       CALL $004E
      LDB #$66        LD A,$66
      STB $690c       LD ($690C),A
      CLRB            XOR A
      STB $6924       LD ($6924),A
      STB $692c       LD ($692C),A
      STB $62af       LD ($62AF),A
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
      RTS             RET

L1708 JSR L011c       CALL $011C      16a3 1654
      LDX #$6a20      LD HL,$6A20
      LDA #$80        LD (HL),$80
      STA ,X+         INC HL
      LDA #$76        LD (HL),$76
      STA ,X+         INC HL
      LDA #$09        LD (HL),$09
      STA ,X+         INC HL
      LDA #$20        LD (HL),$20
      STA ,X
;                     LD HL,$6905
      LDA #$13        LD (HL),$13
      STA $6905
      LDX #$75c4      LD HL,$75C4
      LDY #$0020      LD DE,$0020
      LDB #$10        LD A,$10
      JSR L0514       CALL $0514
      LDX #$608a      LD HL,$608A
      LDA #$07        LD (HL),$07
      STA ,X+         INC HL
      LDA #$03        LD (HL),$03
      STA ,X
      RTS             RET

L1732 JSR L306f       CALL $306F
      LDB $6913       LD A,($6913)
      CMPB #$2c       CP $2C
      BCC L1756       RET NC
      CLRB            XOR A
      STB $6900       LD ($6900),A
      STB $6904       LD ($6904),A
      STB $690c       LD ($690C),A
      LDB #$6b        LD A,$6B
      STB $6924       LD ($6924),A
      DECB            DEC A
      STB $692c       LD ($692C),A
      LDX #$6a21      LD HL,$6A21
      INC ,X          INC (HL)
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
L1756 RTS             RET

L1757 JSR L306f       CALL $306F
      BSR L176c       CALL $176C
      LEAX 1,X        INC HL
      LEAY 1,Y        INC DE
      BSR L1783       CALL $1783
      LDB #$40        LD A,$40
      STB $6009       LD ($6009),A
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
      RTS             RET

L176c LDY #$0003      LD DE,$0003     unnecessary? 175a
      LDX #$692f      LD HL,$692F
      LDA #$0a        LD B,$0A
;1774                 AND A           clear carry 1780
L1774 LDB ,X          LD A,(HL)
      LEAX -3,X       SBC HL,DE
      CMPB #$19       CP $19
      BCC L177f       JP NC,$177F
      CLR ,X          LD (HL),$00
L177f LEAX -1,X       DEC HL          177a
      DECA            DJNZ $1774
      BNE L1774
      RTS             RET

L1783 LDA #$0a        LD B,$0A        175f
      STA REGB 
L1785 LDB ,X          LD A,(HL)       178b
;                     AND A
      BEQ L178a       JP NZ,$0026
      PULS X,PC
;      RTS
L178a STB REGA        ADD HL,DE
      TFR Y,D
      LEAX D,X
      LDB REGA 
      DEC REGB        DJNZ $1785
      BNE L1785
      RTS             RET

L178e JSR L0018       RST $18
      LDX $622a       LD HL,($622A)   Pointer to level order table
      LEAX 1,X        INC HL
      LDB ,X          LD A,(HL)
      CMPB #$7f       CP $7F          check to restart repeating levels
      BNE L179d       JP NZ,$179D
      LDX #L3a73      LD HL,$3A73
      LDB ,X          LD A,(HL)
L179d STX $622a       LD ($622A),HL   1796 Pointer to level order table
      STB $6227       LD ($6227),A    Set Level Type
      LDY #$0500      LD DE,$0500
      JSR L309f       CALL $309F
      CLRB            XOR A
      STB $6388       LD ($6388),A
      LDX #$6009      LD HL,$6009
      LDA #$30        LD (HL),$30
      STA ,X+         INC HL
      LDA #$08        LD (HL),$08     $600a Game Screen Sequencer (set How High screen)
      STA ,X
      RTS             RET

L17b6 JSR L011c       CALL $011C
      LDX #$608a      LD HL,$608A
      LDA #$0e        LD (HL),$0E
      STA ,X+         INC HL
      LDA #$03        LD (HL),$03
      STA ,X
      LDB #$10        LD A,$10
      LDY #$0020      LD DE,$0020
      LDX #$7623      LD HL,$7623
      JSR L0514       CALL $0514
      LDX #$7583      LD HL,$7583
      JSR L0514       CALL $0514
      LDX #$76da      LD HL,$76DA
      BSR L1826       CALL $1826
      LDY #L3a47      LD DE,$3A47     Draw data for end of rivets level
      JSR L0da7       CALL $0DA7
      LDX #$76d5      LD HL,$76D5
      BSR L1826       CALL $1826
      LDY #L3a4d      LD DE,$3A4D     Draw data for end of rivets level
      JSR L0da7       CALL $0DA7
      LDX #$76d0      LD HL,$76D0
      BSR L1826       CALL $1826
      LDY #L3a53      LD DE,$3A53     Draw data for end of rivets level
      JSR L0da7       CALL $0DA7
      LDX #$76cb      LD HL,$76CB
      BSR L1826       CALL $1826
      LDY #L3a59      LD DE,$3A59     Draw data for end of rivets level
      JSR L0da7       CALL $0DA7
      LDX #L385c      LD HL,$385C
      JSR L004e       CALL $004E
      LDX #$6908      LD HL,$6908
      LDA #$44        LD C,$44
      STA REGC 
      JSR L0038       RST $38
;                     LD HL,$6905
      LDA #$13        LD (HL),$13
      STA $6905
      LDB #$20        LD A,$20
      STB $6009       LD ($6009),A
      LDB #$80        LD A,$80
      STB $6390       LD ($6390),A
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
      STX $63c0       LD ($63C0),HL
      RTS             RET

L1826 LDY #$ffdb      LD DE,$FFDB     18a2 17fa 17ee 17e2 17d6 1373 1322
      LDA #$0e        LD C,$0E
      STA REGC 
      LDB #$10        LD A,$10
L182d LDA #$05        LD B,$05        1835
L182f STB ,X+         LD (HL),A       1831
;                     INC HL
      DECA            DJNZ $182F
      BNE L182f
      STB REGA        ADD HL,DE
      TFR Y,D
      LEAX D,X
      LDB REGA 
      DEC REGC        DEC C
      BNE L182d       JP NZ,$182D
      RTS             RET

L1839 LDX #$6390      LD HL,$6390
      INC ,X          INC (HL)
      BEQ L1859       JP Z,$1859
      LDB ,X          LD A,(HL)
      ANDB #$07       AND $07
      BNE L1858       RET NZ
      LDY #L39cf      LD DE,$39CF
      LDA ,X          BIT 3,(HL)
      ANDA #8
      BNE L184e       JR NZ,$184E
      LDY #L39f7      LD DE,$39F7
L184e EXG Y,X         EX DE,HL        1849
      JSR L004e       CALL $004E
      LDX #$6908      LD HL,$6908
      LDA #$44        LD C,$44
      STA REGC 
      JSR L0038       RST $38
L1858 RTS             RET
L1859 LDX #L385c      LD HL,$385C     183d
      JSR L004e       CALL $004E
      LDX #$6908      LD HL,$6908
      LDA #$44        LD C,$44
      STA REGC 
      JSR L0038       RST $38
      LDB #$20        LD A,$20
      STB $6009       LD ($6009),A
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
      RTS             RET

L186f JSR L0018       RST $18
      LDX #L3a1f      LD HL,$3A1F
      JSR L004e       CALL $004E
      LDB #$03        LD A,$03
      STB $6084       LD ($6084),A
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
      RTS             RET

L1880 LDX #$690b      LD HL,$690B
      LDA #$01        LD C,$01
      STA REGC 
      JSR L0038       RST $38
      LDB $691b       LD A,($691B)
      CMPB #$d0       CP $D0
      BNE L18c5       RET NZ
      LDB #$20        LD A,$20
      STB $6919       LD ($6919),A
      LDX #$6a24      LD HL,$6A24
      LDA #$7f        LD (HL),$7F
      STA ,X+         INC L
      LDA #$39        LD (HL),$39
      STA ,X+         INC L
      LDA #$01        LD (HL),$01
      STA ,X+         INC L
      LDA #$d8        LD (HL),$D8
      STA ,X
      LDX #$76c6      LD HL,$76C6
      JSR L1826       CALL $1826
      LDY #L3a5f      LD DE,$3A5F     Draw data for end of rivets level
      JSR L0da7       CALL $0DA7
      LDY #$0004      LD DE,$0004
      LDD #$0228      LD BC,$0228
      STD REGBC 
      LDX #$6903      LD HL,$6903
      JSR L003d       CALL $003D
      CLRB            LD A,$00
      STB $62af       LD ($62AF),A
      LDB #$03        LD A,$03
      STB $6082       LD ($6082),A
      LDX #$6388      LD HL,$6388
      INC ,X          INC (HL)
L18c5 RTS             RET

L18c6 LDX #$62af      LD HL,$62AF
      DEC ,X          DEC (HL)
      LBEQ L193d      JP Z,$193D
      LDB ,X          LD A,(HL)
      ANDB #$07       AND $07
      BNE L18c5       RET NZ
      LDX #$6a25      LD HL,$6A25
      LDB ,X          LD A,(HL)
      EORB #$80       XOR 80
      STB ,X          LD (HL),A
      LDX #$6919      LD HL,$6919
      LDA ,X          LD B,(HL)
      ANDA #223       RES 5,B
      STA REGB 
      CLRB            XOR A
      JSR L3009       CALL $3009
      ORB #$20        OR 20
      STB ,X          LD (HL),A
      LDX #$62af      LD HL,$62AF
      LDB ,X          LD A,(HL)
      CMPB #$e0       CP $E0
      BNE L1910       JP NZ,$1910
      LDB #$50        LD A,$50
      STB $694f       LD ($694F),A
      CLRB            LD A,$00
      STB $694d       LD ($694D),A
      LDB #$9f        LD A,$9F
      STB $694c       LD ($694C),A
      LDB $6203       LD A,($6203)    mario X position
      CMPB #$80       CP $80
      BCC L190f       JP NC,$190F
      LDB #$80        LD A,$80
      STB $694d       LD ($694D),A
      LDB #$5f        LD A,$5F
      STB $694c       LD ($694C),A
L190f LDB ,X          LD A,(HL)       1902
L1910 CMPB #$c0       CP $C0          18eb
      BNE L193c       RET NZ
      LDX #$608a      LD HL,$608A
      LDA #$0c        LD (HL),$0C
      STA ,X
      LDB $6229       LD A,($6229)
      RORB            RRCA
      BCS L1920       JR C,$1920
      LDA #$05        LD (HL),$05
      STA ,X
L1920 LEAX 1,X        INC HL          191c
      LDA #$03        LD (HL),$03
      STA ,X
      LDX #$6a23      LD HL,$6A23
      LDA #$40        LD (HL),$40
      STA ,X
;                     DEC HL
      LDA #$09        LD (HL),$09
      STA ,-X
;                     DEC HL
      LDA #$76        LD (HL),$76
      STA ,-X
;                     DEC HL
      LDA #$8f        LD (HL),$8F
      STA ,-X
      LDB $6203       LD A,($6203)    mario X position
      CMPB #$80       CP $80
      BCC L193c       RET NC
      LDB #$6f        LD A,$6F
      STB $6a20       LD ($6A20),A
L193c RTS             RET
L193d LDX $622a       LD HL,($622A)   18ca Pointer to level order table
      LEAX 1,X        INC HL
      LDB ,X          LD A,(HL)
      CMPB #$7f       CP $7F          check to restart repeating levels
      BNE L194b       JP NZ,$194B
      LDX #L3a73      LD HL,$3A73
      LDB ,X          LD A,(HL)
L194b STX $622a       LD ($622A),HL   1944 Pointer to level order table
      STB $6227       LD ($6227),A    Set Level Type
      LDX #$6229      LD HL,$6229
      INC ,X          INC (HL)
      LDY #$0500      LD DE,$0500
      JSR L309f       CALL $309F
      CLRB            XOR A
      STB $622e       LD ($622E),A
      STB $6388       LD ($6388),A
      LDX #$6009      LD HL,$6009
      LDA #$e0        LD (HL),$E0
      STA ,X+         INC HL
      LDA #$08        LD (HL),$08     $600a Game Screen Sequencer (set How High screen)
      STA ,X
      RTS             RET

L196b JSR L0852       CALL $0852
      LDB $600e       LD A,($600E)
      ADDB #$12       ADD A,$12
      STB $600a       LD ($600A),A    Game Screen Sequencer
      RTS             RET

L1977 JSR L21ee       CALL $21EE

L197a JSR L1dbd       CALL $1DBD
      JSR L1e8c       CALL $1E8C
      JSR L1ac3       CALL $1AC3
      JSR L1f72       CALL $1F72
      JSR L2c8f       CALL $2C8F
      JSR L2c03       CALL $2C03
      JSR L30ed       CALL $30ED      process fireballs?
      JSR L2e04       CALL $2E04      process springs
      JSR L24ea       CALL $24EA
      JSR L2ddb       CALL $2DDB
      JSR L2ed4       CALL $2ED4
      JSR L2207       CALL $2207
      JSR L1a33       CALL $1A33
      JSR L2a85       CALL $2A85
      JSR L1f46       CALL $1F46
      JSR L26fa       CALL $26FA
      JSR L25f2       CALL $25F2
      BSR L19da       CALL $19DA
      JSR L03fb       CALL $03FB
      JSR L2808       CALL $2808
      JSR L281d       CALL $281D
      JSR L1e57       CALL $1E57
      BSR L1a07       CALL $1A07
      JSR L2fcb       CALL $2FCB
;                     NOP
;                     NOP
;                     NOP
      LDB $6200       LD A,($6200)    Flag - Is Mario alive?
;                     AND A
      BNE L19d9       RET NZ
      JSR L011c       CALL $011C
;                     LD HL,$6082
      LDA #$03        LD (HL),$03
      STA $6082

L19d2 LDX #$600a      LD HL,$600A     1a30 Game Screen Sequencer
      INC ,X          INC (HL)
;                     DEC HL
      LDA #$40        LD (HL),$40
      STA ,-X
L19d9 RTS             RET

L19da LDB $6203       LD A,($6203)    19ad mario X position
      LDA #$03        LD B,$03
      LDX #$6a0c      LD HL,$6A0C
L19e2 CMPB ,X         CP (HL)         19ea
      BEQ L19ed       JP Z,$19ED
      LEAX 4,X        INC L
;                     INC L
;                     INC L
;                     INC L
      DECA            DJNZ $19E2
      BNE L19e2
      RTS             RET
L19ed LDB $6205       LD A,($6205)    19e3 mario Y position
      LEAX 3,X        INC L
;                     INC L
;                     INC L
      CMPB ,X         CP (HL)
      BNE L1a06       RET NZ
;                     DEC L
;                     DEC L
      LDA ,--X        BIT 3,(HL)
      ANDA #8
      BNE L1a06       RET NZ
      LEAX -1,X       DEC L
      STX $6343       LD ($6343),HL
      CLRB            XOR A
      STB $6342       LD ($6342),A
      INCB            INC A
      STB $6340       LD ($6340),A
L1a06 RTS             RET

L1a07 LDB $6386       LD A,($6386)    19bc
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L1a1e
      FDB L1a15
      FDB L1a1f
      FDB L1a2a
      FDB L0000

L1a15 CLRB            XOR A
      STB $6387       LD ($6387),A
      LDB #$02        LD A,$02
      STB $6386       LD ($6386),A

L1a1e RTS             RET

L1a1f LDX #$6387      LD HL,$6387
      DEC ,X          DEC (HL)
      BNE L1a1e       RET NZ
      LDB #$03        LD A,$03
      STB $6386       LD ($6386),A
      RTS             RET

L1a2a LDB $6216       LD A,($6216)    Flag - Check if Mario is Jumping?
;                     AND A
      BNE L1a1e       RET NZ
      PULS X          POP HL
      JMP L19d2       JP $19D2

L1a33 LDB #$08        LD A,$08        199e
      JSR L0030       RST $30
      LDB $6203       LD A,($6203)    mario X position
      CMPB #$4b       CP $4B
      BEQ L1a4b       JP Z,$1A4B
      CMPB #$b3       CP $B3
      BEQ L1a4b       JP Z,$1A4B
      LDB $6291       LD A,($6291)
      DECB            DEC A
      BEQ L1a51       JP Z,$1A51
L1a4a RTS             RET
L1a4b LDB #$01        LD A,$01        1a40 1a3b
      STB $6291       LD ($6291),A
      RTS             RET
L1a51 STB $6291       LD ($6291),A    1a47
      STB REGB        LD B,A
      LDB $6205       LD A,($6205)    mario Y position
      DECB            DEC A
      CMPB #$d0       CP $D0
      BCC L1a4a       RET NC
      TFR B,A         RLCA
      ROLA
      ROLB
      BCC L1a62       JP NC,$1A62
      LDA REGB        SET 2,B
      ORA #4
      STA REGB 
L1a62 TFR B,A         RLCA            1a5d
      ROLA
      ROLB
      ROLA            RLCA
      ROLB
      BCC L1a69       JP NC,$1A69
      LDA REGB        SET 1,B
      ORA #2
      STA REGB 
L1a69 ANDB #$07       AND $07         1a64
      CMPB #$06       CP $06
      BNE L1a72       JP NZ,$1A72
      LDA REGB        SET 1,B
      ORA #2
      STA REGB 
L1a72 LDB $6203       LD A,($6203)    1a6d mario X position
      ROLB            RLCA
      BCC L1a7b       JP NC,$1A7B
      LDA REGB        SET 0,B
      ORA #1
      STA REGB 
L1a7b LDX #$6292      LD HL,$6292     1a76
      TFR X,D         LD A,B
      ADDB REGB       ADD A,L
      TFR D,X         LD L,A
      LDB ,X          LD A,(HL)
;                     AND A
      BEQ L1abc       RET Z
      CLR ,X          LD (HL),$00
      LDX #$6290      LD HL,$6290
      DEC ,X          DEC (HL)
      LDB REGB        LD A,B
;                     LD BC,$0005
      RORB            RRA
      BCS L1abd       JP C,$1ABD
      LDX #$02cb      LD HL,$02CB
L1a95 TSTB            AND A           1ac0
      BEQ L1a9e       JP Z,$1A9E
L1a99 LEAX $5,X       ADD HL,BC       1a9b
      DECB            DEC A
      BNE L1a99       JP NZ,$1A99
;1a9e                 LD BC,$7400     unnecessary? 1a96
L1a9e LEAX $7400,X    ADD HL,BC
      LDB #$10        LD A,$10
      STB ,X          LD (HL),A
;                     DEC L
      STB ,-X         LD (HL),A
      LEAX 2,X        INC L
;                     INC L
      STB ,X          LD (HL),A
      LDB #$01        LD A,$01
      STB $6340       LD ($6340),A
      STB $6342       LD ($6342),A
      STB $6225       LD ($6225),A
      LDB $6216       LD A,($6216)    Flag - Check if Mario is Jumping?
;                     AND A
      BNE L1abc       CALL Z,$1D95
      JSR L1d95
L1abc RTS             RET
L1abd LDX #$012b      LD HL,$012B     1a8f
      BRA L1a95       JP $1A95

L1ac3 LDB $6216       LD A,($6216)    1980 Flag - Check if Mario is Jumping?
      DECB            DEC A
      LBEQ L1bb2      JP Z,$1BB2
      LDB $621e       LD A,($621E)
;                     AND A
      LBNE L1b55      JP NZ,$1B55
      LDB $6217       LD A,($6217)
      DECB            DEC A
      BEQ L1ae6       JP Z,$1AE6
      LDB $6215       LD A,($6215)    Flag - Check if Mario is climbing a ladder
      DECB            DEC A
      BEQ L1b38       JP Z,$1B38
      LDB $6010       LD A,($6010)    Joystick inputs
      ROLB            RLA
      LBCS L1b6e      JP C,$1B6E
L1ae6 JSR L241f       CALL $241F      1ad5 note!!! Y does not hold DE from this point...
      LDB $6010       LD A,($6010)    Joystick inputs
      DEC REGE        DEC E
      BEQ L1af5       JP Z,$1AF5
      TFR B,A         BIT 0,A
      ANDA #1
      LBNE L1c8f      JP NZ,$1C8F
L1af5 DEC REGD        DEC D           1aed
      BEQ L1afe       JP Z,$1AFE
      TFR B,A         BIT 1,A
      ANDA #2
      LBNE L1cab      JP NZ,$1CAB
L1afe LDB $6217       LD A,($6217)    1af6
      DECB            DEC A
      BEQ L1b4d       RET Z
      LDB $6205       LD A,($6205)    mario Y position
      ADDB #$08       ADD A,$08
      STB REGD        LD D,A
      LDB $6203       LD A,($6203)    mario X position
      ORB #$03        OR 03
      ANDB #251       RES 2,A
      LDX #$0015      LD BC,$0015
      STX REGBC 
      JSR L236e       CALL $236E      both Y and REGDE contain DE upon return
      PSHS B          PUSH AF
      LDX #$6207      LD HL,$6207     mario sprite character #
      LDB ,X          LD A,(HL)
      ANDB #$80       AND $80
      ORB #$06        OR 06           mario climbing character
      STB ,X          LD (HL),A
      LDX #$621a      LD HL,$621A
      LDB #$04        LD A,$04
      CMPB REGC       CP C
      LDA #$01        LD (HL),$01
      STA ,X                          set as broken ladder
      BCC L1b2c       JP NC,$1B2C
      DEC ,X          DEC (HL)        set as normal ladder
L1b2c PULS B          POP AF          1b28
      TSTB            AND A
      BEQ L1b4e       JP Z,$1B4E
      LDB ,X          LD A,(HL)
;                     AND A
      BNE L1b4d       RET NZ
      LEAX 1,X        INC L
      LDA REGD        LD (HL),D
      STA ,X+         INC L           set top Y coordinate of ladder
      LDA REGB        LD (HL),B       set bottom Y coordinate of ladder
      STA ,X
L1b38 LDB $6010       LD A,($6010)    1adc Joystick inputs
      ANDB #8         BIT 3,A         are we going down?
      LBNE L1cf2      JP NZ,$1CF2     yes
      LDB $6215       LD A,($6215)    Flag - Check if Mario is climbing a ladder
;                     AND A
      BEQ L1b4d       RET Z
L1b45 LDB $6010       LD A,($6010)    1b52 Joystick inputs
      ANDB #4         BIT 2,A         are we going up?
      LBNE L1d03      JP NZ,$1D03     yes
L1b4d LDY REGDE                       restore Y
      RTS             RET
L1b4e LEAX 1,X        INC L           1b2e
      LDA REGB        LD (HL),B
      STA ,X+         INC L           set top Y coordinate of ladder
      LDA REGD        LD (HL),D       set bottom Y coordinate of ladder
      STA ,X
      BRA L1b45       JP $1B45
L1b55 LDX #$621e      LD HL,$621E     1ace
      DEC ,X          DEC (HL)
      BNE L1bb1       RET NZ
      LDB $6218       LD A,($6218)
      STB $6217       LD ($6217),A
      LDX #$6207      LD HL,$6207     mario sprite character #
      LDB ,X          LD A,(HL)
      ANDB #$80       AND $80         h-flip mario
      STB ,X          LD (HL),A
      CLRB            XOR A
      STB $6202       LD ($6202),A
      LDY REGDE                       restore Y
      JMP L1da6       JP $1DA6
L1b6e LDB #$01        LD A,$01        1ae3
      STB $6216       LD ($6216),A    Set Flag - Mario is Jumping
;                     LD HL,$6210
      LDB $6010       LD A,($6010)    Joystick inputs
      LDX #$0080      LD BC,$0080
      RORB            RRA
      BCS L1b8a       JP C,$1B8A
      LDX #$ff80      LD BC,$FF80
      RORB            RRA
      BCS L1b8a       JP C,$1B8A
      LDX #$0000      LD BC,$0000
L1b8a STX REGBC       XOR A           1b84 1b7d
      TFR X,D
      LDX #$6210
      STD ,X++        LD (HL),B
;                     INC L
;                     LD (HL),C
;                     INC L
      LDA #$01        LD (HL),$01
      STA ,X+         INC L
      LDA #$48        LD (HL),$48
      STA ,X+         INC L
      CLRB
      STB ,X          LD (HL),A
      STB $6204       LD ($6204),A
      STB $6206       LD ($6206),A
      LDB $6207       LD A,($6207)    mario sprite character #
      ANDB #$80       AND $80
      ORB #$0e        OR 0E           mario jumping character
      STB $6207       LD ($6207),A    mario sprite character #
      LDB $6205       LD A,($6205)    mario Y position
      STB $620e       LD ($620E),A
      LDX #$6081      LD HL,$6081
      LDA #$03        LD (HL),$03
      STA ,X
      LDY REGDE                       restore Y/DE register
L1bb1 RTS             RET
L1bb2 LDU #$6200      LD IX,$6200     1ac7 Mario flags
      LDB $6203       LD A,($6203)    mario X position
      STB $b,U        LD (IX+$0B),A   store initial X position before a jump
      LDB $6205       LD A,($6205)    mario Y position
      STB $c,U        LD (IX+$0C),A   store initial Y position before a jump
      JSR L239c       CALL $239C
      JSR L241f       CALL $241F      note!!! Y does not hold DE from this point on...
      DEC REGD        DEC D
      BNE L1bf2       JP NZ,$1BF2
      CLR $10,U       LD (IX+$10),$00
      LDA #$80        LD (IX+$11),$80
      STA $11,U
      LDA $7,U        SET 7,(IX+$07)  H-flip the sprite
      ORA #128
      STA $7,U 
L1bd8 LDB $6220       LD A,($6220)    1c02
      DECB            DEC A
      BEQ L1bec       JP Z,$1BEC
      JSR L2407       CALL $2407
      STX $12,U       LD (IX+$12),H
;                     LD (IX+$13),L
      CLR $14,U       LD (IX+$14),$00
L1bec JSR L239c       CALL $239C      1bdc
      BRA L1c05       JP $1C05
L1bf2 DEC REGE        DEC E           1bc9
      BNE L1c05       JP NZ,$1C05
      LDD #$ff80      LD (IX+$10),$FF
      STD $10,U       LD (IX+$11),$80
      LDA $7,U        RES 7,(IX+$07)  Un-H-flip the sprite
      ANDA #127
      STA $7,U
      BRA L1bd8       JP $1BD8
L1c05 LDY REGDE       CALL $2B1C      1bf3 1bef restore Y here...
      JSR L2b1c
      DECB            DEC A           We are jumping!
      BEQ L1c3a       JP Z,$1C3A
      LDB $621f       LD A,($621F)
      DECB            DEC A
      BEQ L1c76       JP Z,$1C76
      LDB $6214       LD A,($6214)
      SUBB #$14       SUB 14
      BNE L1c33       JP NZ,$1C33
      LDB #$01        LD A,$01        We are at the peak of the jump!
      STB $621f       LD ($621F),A
      JSR L2853       CALL $2853      Subroutine to check for bonus points!!!
      TSTB            AND A
      LBEQ L1da6      JP Z,$1DA6      Exit if no bonus
      STB $6342       LD ($6342),A
      LDB #$01        LD A,$01        Register bonus
      STB $6340       LD ($6340),A
      STB $6225       LD ($6225),A
;                     NOP
L1c33 INCB            INC A           1c18
      BNE L1c37       CALL Z,$2954
      JSR L2954
L1c37 JMP L1da6       JP $1DA6
L1c3a DEC REGB        DEC B           1c09
      BEQ L1c4f       JP Z,$1C4F
      INCB            INC A
      STB $621f       LD ($621F),A
      CLRB            XOR A
      LDX #$6210      LD HL,$6210
      LDA #$05        LD B,$05
L1c48 STB ,X+         LD (HL),A       1c4a
;                     INC L
      DECA            DJNZ $1C48
      BNE L1c48
      JMP L1da6       JP $1DA6
L1c4f STB $6216       LD ($6216),A    1c3b Flag - Mario Jumping?
      LDB $6220       LD A,($6220)
      EORB #$01       XOR 01
      STB $6200       LD ($6200),A    Flag - Set wether Mario survives a jump
      LDX #$6207      LD HL,$6207     mario sprite character #
      LDB ,X          LD A,(HL)
      ANDB #$80       AND $80
      ORB #$0f        OR 0F           mario landing character
      STB ,X          LD (HL),A
      LDB #$04        LD A,$04
      STB $621e       LD ($621E),A
      CLRB            XOR A
      STB $621f       LD ($621F),A
      LDB $6225       LD A,($6225)
      DECB            DEC A
      BNE L1c73       CALL Z,$1D95
      JSR L1d95
L1c73 JMP L1da6       JP $1DA6
L1c76 LDB $6205       LD A,($6205)    1c10 mario Y position
      LDX #$620e      LD HL,$620E
      SUBB #$0f       SUB 0F
      CMPB ,X         CP (HL)
      LBCS L1da6      JP C,$1DA6
      LDB #$01        LD A,$01
      STB $6220       LD ($6220),A
      LDX #$6084      LD HL,$6084
      LDA #$03        LD (HL),$03
      STA ,X
      JMP L1da6       JP $1DA6
L1c8f LDA #$01        LD B,$01        1af2
      STA REGB 
      LDY REGDE                       restore Y/DE register
      LDB $620f       LD A,($620F)
;                     AND A
      BNE L1cd2       JP NZ,$1CD2
      LDB $6202       LD A,($6202)
      STB REGB        LD B,A
      LDB #$05        LD A,$05
      JSR L3009       CALL $3009
      STB $6202       LD ($6202),A
      ANDB #$03       AND $03
      ORB #$80        OR 80
      BRA L1cc2       JP $1CC2
L1cab LDA #$ff        LD B,$FF        1afb
      STA REGB 
      LDY REGDE                       restore Y/DE register
      LDB $620f       LD A,($620F)
;                     AND A
      BNE L1cd2       JP NZ,$1CD2
      LDB $6202       LD A,($6202)
      STB REGB        LD B,A
      LDB #$01        LD A,$01
      JSR L3009       CALL $3009
      STB $6202       LD ($6202),A
      ANDB #$03       AND $03         animate mario running
L1cc2 LDX #$6207      LD HL,$6207     1ca8 mario sprite character #
      STB ,X          LD (HL),A       set mario character
      RORB            RRA
      BCC L1cca       CALL C,$1D8F
      JSR L1d8f
L1cca LDB #$02        LD A,$02
      STB $620f       LD ($620F),A
      JMP L1da6       JP $1DA6
L1cd2 LDX #$6203      LD HL,$6203     1cb1 1c95 mario X position
      LDB ,X          LD A,(HL)
      ADDB REGB       ADD A,B
      STB ,X          LD (HL),A
      LDB $6227       LD A,($6227)    Level Type
      DECB            DEC A
      BNE L1ceb       JP NZ,$1CEB
      LDA ,X          LD H,(HL)
      LDB $6205       LD A,($6205)    mario Y position
      TFR D,X         LD L,A
      JSR L2333       CALL $2333
      LDB REGL        LD A,L
      STB $6205       LD ($6205),A    mario Y position
L1ceb LDX #$620f      LD HL,$620F     1cdc
      DEC ,X          DEC (HL)
      JMP L1da6       JP $1DA6
L1cf2 LDY REGDE                       restore Y/DE register
      LDB $620f       LD A,($620F)    1b3d
;                     AND A
      LBNE L1d8a      JP NZ,$1D8A
      LDB #$03        LD A,$03
      STB $620f       LD ($620F),A
      LDB #$02        LD A,$02
      BRA L1d11       JP $1D11
L1d03 LDY REGDE                       restore Y/DE register
      LDB $620f       LD A,($620F)    1b4a check timer
;                     AND A
      BNE L1d76       JP NZ,$1D76     don't process yet
      LDB #$04        LD A,$04        restart timer
      STB $620f       LD ($620F),A
      LDB #$fe        LD A,$FE
L1d11 LDX #$6205      LD HL,$6205     1d00 mario Y position
      ADDB ,X         ADD A,(HL)
      STB ,X          LD (HL),A
      STB REGB        LD B,A
      LDB $6222       LD A,($6222)    another timer
      EORB #$01       XOR 01
      STB $6222       LD ($6222),A
      BNE L1d51       JP NZ,$1D51
      LDB REGB        LD A,B
      ADDB #$08       ADD A,$08
      LDX #$621c      LD HL,$621C
      CMPB ,X         CP (HL)         bottom Y coordinate of ladder
      BEQ L1d67       JP Z,$1D67      stop from climbing
;                     DEC L
      SUBB ,-X        SUB (HL)        top Y coordinate of ladder
      BEQ L1d67       JP Z,$1D67      stop from climbing
      LDA #$05        LD B,$05
      STA REGB 
      SUBB #$08       SUB 08
      BEQ L1d3f       JP Z,$1D3F
      DEC REGB        DEC B
      SUBB #$04       SUB 04
      BEQ L1d3f       JP Z,$1D3F
      DEC REGB        DEC B
L1d3f LDB #$80        LD A,$80        1d3b 1d35
      LDX #$6207      LD HL,$6207     mario sprite character #
      ANDB ,X         AND (HL)
      EORB #$80       XOR 80          h-flip mario character
      ORB REGB        OR B            ???
      STB ,X          LD (HL),A
L1d49 LDB #$01        LD A,$01        1d64
      STB $6215       LD ($6215),A    Flag - Mario is climbing a ladder
      BRA L1da6       JP $1DA6
;1d51                 DEC L           1d1f
;                     DEC L
L1d51 LDB ,--X        LD A,(HL)
      ORB #$03        OR 03
      ANDB #251       RES 2,A
      STB ,X          LD (HL),A
      LDB $6224       LD A,($6224)
      EORB #$01       XOR 01
      STB $6224       LD ($6224),A
      BNE L1d49       CALL Z,$1D8F
      BSR L1d8f
      BRA L1d49       JP $1D49
L1d67 LDB #$06        LD A,$06        1d2e 1d29 mario climbing character
      STB $6207       LD ($6207),A    set mario sprite character #
      CLRB            XOR A
      STB $6219       LD ($6219),A
      STB $6215       LD ($6215),A    UnFlag - Mario not climbing a ladder
      BRA L1da6       JP $1DA6
L1d76 LDB $621a       LD A,($621A)    1d07
;                     AND A
      BEQ L1d8a       JP Z,$1D8A
      STB $6219       LD ($6219),A
      LDB $621c       LD A,($621C)    bottom Y coordinate of ladder
      SUBB #$13       SUB 13
      LDX #$6205      LD HL,$6205     mario Y position
      CMPB ,X         CP (HL)
      BCC L1d8e       RET NC
L1d8a LDX #$620f      LD HL,$620F     1d7a 1cf6
      DEC ,X          DEC (HL)
L1d8e RTS             RET

L1d8f LDB #$03        LD A,$03        1d61 1cc7
      STB $6080       LD ($6080),A
      RTS             RET

L1d95 STB $6225       LD ($6225),A    1c70 1ab9
      LDB $6227       LD A,($6227)    Level Type
      DECB            DEC A
      BEQ L1da5       RET Z
      LDX #$608a      LD HL,$608A
      LDA #$0d        LD (HL),$0D     add coco hack to use digital sound 05 instead
      STA ,X+         INC L
      LDA #$03        LD (HL),$03
      STA ,X
L1da5 RTS             RET

; add mario character to sprite display
;
L1da6 LDX #$694c      LD HL,$694C     1d73 1d4e 1cef 1ccf 1c8c 1c7f 1c73 1c4c 1c37 1c24 1b6b
      LDB $6203       LD A,($6203)    mario X position
      andb #$fe                       coco hack to speed up sprites
      STB ,X+         LD (HL),A
      LDB $6207       LD A,($6207)    mario sprite character #
;                     INC L
      STB ,X++        LD (HL),A
;     LDB $6208       LD A,($6208)    mario sprite palette
;                     INC L
;     STB ,X+         LD (HL),A
      LDB $6205       LD A,($6205)    mario Y position
;                     INC L
      STB ,X         LD (HL),A
      RTS             RET

L1dbd LDB $6340       LD A,($6340)    197a 1641 127c
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L1e49
      FDB L1dc9
      FDB L1e4a
      FDB L0000

L1dc9 LDB #$40        LD A,$40
      STB $6341       LD ($6341),A
      LDB #$02        LD A,$02
      STB $6340       LD ($6340),A
      LDB $6342       LD A,($6342)
      RORB            RRA
      BCS L3e70       JP C,$3E70      score points for jumping over a barrel/etc
      RORB            RRA
      BCS L1e00       JP C,$1E00
      RORB            RRA
      BCS L1df5       JP C,$1DF5
      LDX #$6085      LD HL,$6085
      LDA #$03        LD (HL),$03
      STA ,X
      LDB $6229       LD A,($6229)
      DECB            DEC A
      BEQ L1e00       JP Z,$1E00
      DECB            DEC A
      BEQ L1e08       JP Z,$1E08
      BRA L1e10       JP $1E10

L1df5 LDB $6018       LD A,($6018)    1ddf Get Random Number
      RORB            RRA             50% chance for 500 points
      BCS L1e08       JP C,$1E08      Award 500 Points
      RORB            RRA             25% change for 800 points
      BCS L1e10       JP C,$1E10      Award 800 Points
L1e00 LDA #$7d        LD B,$7D        1deb 1ddb Award 300 Points, B = 300 sprite
      STA REGB 
      LDY #$0003      LD DE,$0003     Routine = Award Points, 300 pts
      BRA L1e15       JP $1E15        Go award points
L1e08 LDA #$7e        LD B,$7E        1df9 1def Award 500 Points, B = 500 sprite
      STA REGB 
      LDY #$0005      LD DE,$0005     Routine = Award Points, 500 pts
      BRA L1e15       JP $1E15        Go award points
L1e10 LDA #$7f        LD B,$7F        1dfd 1df2 Award 800 Points, B = 800 sprite
      STA REGB 
      LDY #$0008      LD DE,$0008     Routine = Award Points, 800 pts
L1e15 JSR L309f       CALL $309F      1e0d 1e05 Schedule Award Points Routine (using DE)
      LDX $6343       LD HL,($6343)   Get pointer to X position
      LDB ,X          LD A,(HL)       A = Prize X position (use for Point sprite)
      CLR ,X          LD (HL),$00     Erase Prize once collected
      LEAX 3,X        INC L           Go to Y position
;                     INC L
;                     INC L
      LDA ,X          LD C,(HL)       C = Y position (use for Point sprite)
      STA REGC 
      BRA L1e36       JP $1E36        Go program Award Sprite

L3e70 LDY #$0001      LD DE,$0001     1dd7 100 points
      LDA #$7b        LD B,$7B        100 point sprite
      STA REGB 
      RORB            RRA
      BCC L1e28       JP NC,$1E28
      LDY #$0003      LD E,$03        300 points
      LDA #$7d        LD B,$7D        300 point sprite
      STA REGB 
      RORB            RRA
      BCC L1e28       JP NC,$1E28
      LDY #$0005      LD E,$05        500 points
      LDA #$7f        LD B,$7F        500 point sprite
      STA REGB 
;     JMP L1e28       JP $1E28

L1e28 JSR L309f       CALL $309F      3e85 3e7e 3e76
      LDB $6205       LD A,($6205)    mario Y position
      ADDB #$14       ADD A,$14
      STB REGC        LD C,A
      LDB $6203       LD A,($6203)    mario X position
;                     NOP
;                     NOP
L1e36 LDX #$6a30      LD HL,$6A30     1e22 add bonus points sprite to display
      STB ,X+         LD (HL),A
;                     INC L
      LDA REGB        LD (HL),B
      STA ,X+         INC L
      LDA #$07        LD (HL),$07
      STA ,X+         INC L
      LDA REGC        LD (HL),C
      STA ,X
      LDB #$05        LD A,$05
      JSR L0030       RST $30
      LDX #$6085      LD HL,$6085
      LDA #$03        LD (HL),$03
      STA ,X
L1e49 RTS             RET

L1e4a LDX #$6341      LD HL,$6341
      DEC ,X          DEC (HL)
      BNE L1e49       RET NZ
      CLRB            XOR A
      STB $6a30       LD ($6A30),A
      STB $6340       LD ($6340),A
      RTS             RET

L1e57 LDB $6227       LD A,($6227)    19b9 Level Type
      TFR B,A         BIT 2,A
      ANDA #4
      BNE L1e80       JP NZ,$1E80
      RORB            RRA
      LDB $6205       LD A,($6205)    mario Y position
      BCS L1e7a       JP C,$1E7A
      CMPB #$51       CP $51
      BCC L1e49       RET NC
      LDB $6203       LD A,($6203)    mario X position
      ROLB            RLA
L1e6d LDB #$00        LD A,$00        1e7d
      BCS L1e74       JP C,$1E74
      LDB #$80        LD A,$80
L1e74 STB $694d       LD ($694D),A    1e6f
      BRA L1e85       JP $1E85
L1e7a CMPB #$31       CP $31          1e63
      BCS L1e6d       RET NC
      RTS             JP $1E6D
L1e80 LDB $6290       LD A,($6290)    1e5c
;                     AND A
      BNE L1e95       RET NZ
L1e85 LDB #$16        LD A,$16        1e77
      STB $600a       LD ($600A),A    Game Screen Sequencer
      PULS X,PC       POP HL
;     RTS             RET

L1e8c LDB $6350       LD A,($6350)    197d
;                     AND A
      BEQ L1e95       RET Z
      BSR L1e96       CALL $1E96
      PULS X,PC       POP HL
L1e95 RTS             RET

L1e96 LDB $6345       LD A,($6345)    1e91
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L1ea0
      FDB L1f09
      FDB L1f23

L1ea0 LDB $6351       LD A,($6352)    (endian fix!) hammer has just hit something
      LDX #$69b8      LD HL,$69B8     process hammer hit effect (start)
      CMPB #$65       CP $65
      BEQ L1eb4       JP Z,$1EB4
      LDX #$69d0      LD HL,$69D0     fireball area in sprite ram
      BCS L1eb4       JP C,$1EB4
      LDX #$6980      LD HL,$6980
L1eb4 LDU $6351       LD IX,($6351)   1eae 1ea8
      CLRA            LD D,$00
      LDB $6353       LD A,($6353)
      TFR D,Y         LD E,A
;                     LD BC,$0004
      LDB $6354       LD A,($6354)
;                     AND A
      BEQ L1ecf       JP Z,$1ECF
L1ec8 LEAX $4,X       ADD HL,BC       1ecc
      STB REGA        ADD IX,DE
      TFR Y,D
      LEAU D,U
      LDB REGA 
      DECB            DEC A
      BNE L1ec8       JP NZ,$1EC8
L1ecf CLR ,U          LD (IX+$00),$00 1ec5
      LDB #$02        LD A,$02
      LDA $15,U       LD x,(IX+$15)
;                     AND x
      BEQ L1ede       JP Z,$1EDE
      LDB #$04        LD A,$04
L1ede STB $6342       LD ($6342),A    1ed9
      STU REGIX       LD BC,$6A2C
      LDU #$6a2c
      LDB ,X          LD A,(HL)
      CLR ,X          LD (HL),$00
      STB ,U          LD (BC),A       flash sprite X coordinate
;                     INC C
;                     INC L
      LDB #$60        LD A,$60        initial hit sprite character
      STB 1,U         LD (BC),A       flash sprite character
;                     INC C
;                     INC L
;     LDB #$0c        LD A,$0C
;     STB 2,U         LD (BC),A       flash sprite palette
;                     INC C
      LEAX 3,X        INC L
      LDB ,X          LD A,(HL)
      STB 3,U         LD (BC),A       flash sprite Y coordinate
      LDU REGIX 
      LDX #$6345      LD HL,$6345
      INC ,X+         INC (HL)
;                     INC L
      LDA #$06        LD (HL),$06
      STA ,X+         INC L
      LDA #$05        LD (HL),$05
      STA ,X
      LDX #$608a      LD HL,$608A
      LDA #$06        LD (HL),$06
      STA ,X+         INC L
      LDA #$03        LD (HL),$03
      STA ,X
      RTS             RET

L1f09 LDX #$6346      LD HL,$6346     process hammer hit effect (middle)
      DEC ,X          DEC (HL)
      BNE L1f22       RET NZ
      LDA #$06        LD (HL),$06
      STA ,X+         INC L
      DEC ,X          DEC (HL)
      BEQ L1f1d       JP Z,$1F1D
      LDX #$6a2d      LD HL,$6A2D
      LDB ,X          LD A,(HL)
      EORB #$01       XOR 01          animate hit flash
      STB ,X          LD (HL),A
      RTS             RET
L1f1d LDA #$04        LD (HL),$04     1f12
      STA ,X
;                     DEC L
;                     DEC L
      INC ,--X        INC (HL)
L1f22 RTS             RET

L1f23 LDX #$6346      LD HL,$6346     process hammer hit effect (end)
      DEC ,X          DEC (HL)
      BNE L1f45       RET NZ
      LDA #$0c        LD (HL),$0C
      STA ,X+         INC L
      DEC ,X          DEC (HL)
      BEQ L1f34       JP Z,$1F34
      LDX #$6a2d      LD HL,$6A2D
      INC ,X          INC (HL)        animate hit flash
      RTS             RET
;1f34                 DEC L           1f2c
;                     DEC L
L1f34 CLRB            XOR A
      STB ,--X        LD (HL),A
      STB $6350       LD ($6350),A    stop effect process
      INCB            INC A
      STB $6340       LD ($6340),A
      LDX #$6a2c      LD HL,$6A2C
      STX $6343       LD ($6343),HL
L1f45 RTS             RET

L1f46 LDB $6221       LD A,($6221)    19a4
;                     AND A
      BEQ L1f71       RET Z
      CLRB            XOR A
      STB $6204       LD ($6204),A
      STB $6206       LD ($6206),A
      STB $6221       LD ($6221),A
      STB $6210       LD ($6210),A
      STB $6211       LD ($6211),A
      STB $6212       LD ($6212),A
      STB $6213       LD ($6213),A
      STB $6214       LD ($6214),A
      INCB            INC A
      STB $6216       LD ($6216),A    Set Flag - Mario is Jumping
      STB $621f       LD ($621F),A
      LDB $6205       LD A,($6205)    mario Y position
      STB $620e       LD ($620E),A
L1f71 RTS             RET

L1f72 LDB $6227       LD A,($6227)    1983 Level Type
      DECB            DEC A
      BNE L1f71       RET NZ
      LDU #$6700      LD IX,$6700
      LDX #$6980      LD HL,$6980
      LDY #$0020      LD DE,$0020
      LDA #$0a        LD B,$0A
      STA REGB 
L1f83 LDB ,U          LD A,(IX+$00)   1f90
      DECB            DEC A
      BEQ L1f93       JP Z,$1F93
      LEAX 3,X        INC L
;                     INC L
;                     INC L

L1f8d LEAX 1,X        INC L           21ce
      STB REGA        ADD IX,DE
      TFR Y,D
      LEAU D,U
      LDB REGA 
      DEC REGB        DJNZ $1F83
      BNE L1f83
      RTS             RET

L1f93 LDB $1,U        LD A,(IX+$01)   1f87
      DECB            DEC A
      LBEQ L20ec      JP Z,$20EC
      LDB $2,U        LD A,(IX+$02)
      RORB            RRA
      BCS L1fac       JP C,$1FAC
      RORB            RRA
      BCS L1fe5       JP C,$1FE5
      RORB            RRA
      BCS L1fef       JP C,$1FEF
      JMP L2053       JP $2053
L1fac JSR EXX         EXX             1f9e
      INC $5,U        INC (IX+$05)
      LDB $17,U       LD A,(IX+$17)
      CMPB $5,U       CP (IX+$05)
      BNE L1fce       JP NZ,$1FCE
      LDB $15,U       LD A,(IX+$15)
      TFR B,A         RLCA
      ROLA
      ROLB
      ROLA            RLCA
      ROLB
      ADDB #$15       ADD A,$15       switch downwards(sideways) barrel to rolling barrel
      STB $7,U        LD (IX+$07),A   Set sprite character #
      LDB $2,U        LD A,(IX+$02)
      EORB #$07       XOR 07
      STB $2,U        LD (IX+$02),A
      JMP L21ba       JP $21BA
L1fce LDB $f,U        LD A,(IX+$0F)   210b 1fb6
      DECB            DEC A
      BNE L1fdf       JP NZ,$1FDF
      LDB $7,U        LD A,(IX+$07)   Animate sideways barrel sprite character #
      EORB #$01       XOR 01
      STB $7,U        LD (IX+$07),A   sprite character #
      LDB #$04        LD A,$04
L1fdf STB $f,U        LD (IX+$0F),A   1fd2
      JMP L21ba       JP $21BA
L1fe5 JSR EXX         EXX             1fa2
      LDX #$0100      LD BC,$0100
      STX REGBC 
      INC $3,U        INC (IX+$03)
      BRA L1ff6       JP $1FF6
L1fef JSR EXX         EXX             1fa6
      LDX #$ff04      LD BC,$FF04
      STX REGBC 
      DEC $3,U        DEC (IX+$03)
L1ff6 LDA $3,U        LD H,(IX+$03)   1fec
      LDB $5,U        LD L,(IX+$05)
      TFR D,X
;                     LD A,H
      ANDA #$07       AND $07
      CMPA #$03       CP $03
      LBEQ L215f      JP Z,$215F
      TFR X,D         DEC L
      SUBB #3         DEC L
      TFR D,X         DEC L
      JSR L2333       CALL $2333
      LDD REGHL       INC L
      ADDB #3         INC L
      TFR D,X         INC L
;                     LD A,L
      STB $5,U        LD (IX+$05),A
      JSR L23de       CALL $23DE
      JSR L24b4       CALL $24B4
      LDB $3,U        LD A,(IX+$03)
      CMPB #$1c       CP $1C
      BCS L202f       JP C,$202F
      CMPB #$e4       CP $E4
      LBCS L21ba      JP C,$21BA
      CLRB            XOR A
      STB $10,U       LD (IX+$10),A
      LDA #$60        LD (IX+$11),$60
      STA $11,U
      BRA L2038       JP $2038
L202f CLRB            XOR A           201c
      LDA #$ff        LD (IX+$10),$FF
      STA $10,U
      LDA #$a0        LD (IX+$11),$A0
      STA $11,U
L2038 LDA #$ff        LD (IX+$12),$FF 202c
      STA $12,U
      LDA #$f0        LD (IX+$13),$F0
      STA $13,U
      STB $14,U       LD (IX+$14),A
      STB $e,U        LD (IX+$0E),A
      STB 4,U         LD (IX+$04),A
      STB 6,U         LD (IX+$06),A
      LDA #$08        LD (IX+$02),$08
      STA 2,U  
      JMP L21ba       JP $21BA
L2053 JSR EXX         EXX             1fa9
      JSR L239c       CALL $239C
      JSR L2a2f       CALL $2A2F
      TSTB            AND A
      BNE L2083       JP NZ,$2083
      LDB $3,U        LD A,(IX+$03)
      ADDB #$08       ADD A,$08
      CMPB #$10       CP $10
      BCS L2079       JP C,$2079
      JSR L24b4       CALL $24B4
      LDB $10,U       LD A,(IX+$10)
      ANDB #$01       AND $01
      LSLB            RLCA
      LSLB            RLCA
      STB REGC        LD C,A
      JSR L23de       CALL $23DE
      JMP L21ba       JP $21BA
L2079 CLRB            XOR A           2065
      STB ,U          LD (IX+$00),A
      STB $3,U        LD (IX+$03),A
      JMP L21ba       JP $21BA
L2083 INC $e,U        INC (IX+$0E)    205b
      LDB $e,U        LD A,(IX+$0E)
      DECB            DEC A
      BEQ L20a2       JP Z,$20A2
      DECB            DEC A
      BEQ L20c3       JP Z,$20C3
      LDB #$04        LD A,$04
      LDA $10,U       LD x,(IX+$10)
      DECA            DEC x
      BNE L209c       JP NZ,$209C
      LDB #$02        LD A,$02
L209c STB $2,U        LD (IX+$02),A   2097
      JMP L21ba       JP $21BA
L20a2 LDB $15,U       LD A,(IX+$15)   208a
;                     AND A
      BNE L20b5       JP NZ,$20B5
      LDX #$6205      LD HL,$6205     mario Y position
      LDB $5,U        LD A,(IX+$05)
      SUBB #$16       SUB 16          check how far mario has fallen when jumping???
      CMPB ,X         CP (HL)
      BCC L20c3       JP NC,$20C3
L20b5 LDB $10,U       LD A,(IX+$10)   20a6
;                     AND A
      BNE L20e1       JP NZ,$20E1
      STB $11,U       LD (IX+$11),A
      LDA #$ff        LD (IX+$10),$FF
      STA $10,U
L20c3 JSR L2407       CALL $2407      20e9 20b2 208e
      TFR X,D         SRL H
      LSRA
      RORB            RR L
      LSRA            SRL H
      RORB            RR L
      TFR D,X
      STD $12,U       LD (IX+$12),H
;                     LD (IX+$13),L
      CLRB            XOR A
      STB $14,U       LD (IX+$14),A
      STB $4,U        LD (IX+$04),A
      STB $6,U        LD (IX+$06),A
      JMP L21ba       JP $21BA
L20e1 LDA #$01        LD (IX+$10),$01 20b9
      STA $10,U
      CLR $11,U       LD (IX+$11),$00
      BRA L20c3       JP $20C3
L20ec JSR EXX         EXX             1f97
      JSR L239c       CALL $239C
      TFR X,D         LD A,H
      SUBA #$1a       SUB 1A
      LDB $19,U       LD B,(IX+$19)
      STB REGB 
      CMPA REGB       CP B
      BCS L2104       JP C,$2104
      JSR L2a2f       CALL $2A2F
      TSTB            AND A
      BNE L2118       JP NZ,$2118
      JSR L24b4       CALL $24B4
L2104 LDB $3,U        LD A,(IX+$03)   20f7
      ADDB #$08       ADD A,$08
      CMPB #$10       CP $10
      LBCC L1fce      JP NC,$1FCE
      CLRB            XOR A
      STB ,U          LD (IX+$00),A
      STB $3,U        LD (IX+$03),A
      JMP L21ba       JP $21BA
L2118 LDB $5,U        LD A,(IX+$05)   20fe
      CMPB #$e0       CP $E0
      BCS L2146       JP C,$2146
      LDB $7,U        LD A,(IX+$07)   something with a sprite character #
      ANDB #$fc       AND $FC         switch falling(sideways) barrel to rolling-bounce barrel
      ORB #$01        OR 01
      STB $7,U        LD (IX+$07),A
      CLRB            XOR A
      STB $1,U        LD (IX+$01),A
      STB $2,U        LD (IX+$02),A
      LDA #$ff        LD (IX+$10),$FF
      STD $10,U       LD (IX+$11),A
      STB $12,U       LD (IX+$12),A
      LDA #$b0        LD (IX+$13),$B0
      STA $13,U
      LDA #$01        LD (IX+$0E),$01
      STA $e,U
      BRA L2153       JP $2153
L2146 JSR L2407       CALL $2407      211d
      JSR L22cb       CALL $22CB
      LDB $5,U        LD A,(IX+$05)
      STB $19,U       LD (IX+$19),A
      CLRB            XOR A
L2153 STB $14,U       LD (IX+$14),A   2143
      STB $4,U        LD (IX+$04),A
      STB $6,U        LD (IX+$06),A
      JMP L21ba       JP $21BA
L215f TFR X,D         LD A,L          2001
      ADDB #$05       ADD A,$05
      STY REGDE       LD D,A
      STB REGD 
      TFR A,B         LD A,H
      LDX #$0015      LD BC,$0015
      STX REGBC 
      BSR L216d       CALL $216D
      BRA L21ba       JP $21BA

L216d JSR L236e       CALL $236E      2167
      DECB            DEC A
      BNE L21b9       RET NZ
      LDB REGB        LD A,B
      SUBB #$05       SUB 05
      STB $17,U       LD (IX+$17),A
      LDB $6348       LD A,($6348)
;                     AND A
      BEQ L21b2       JP Z,$21B2
      LDB $6205       LD A,($6205)    mario Y position
; if original release version...
ALTV  SUBB #$10       SUB 10
; if alternate release version...
;     SUBB #$04       SUB 04
      STY REGDE       CP D
      CMPB REGD 
      BCS L21b9       RET C
      LDB $6380       LD A,($6380)
      RORB            RRA
      INCB            INC A
      STB REGB        LD B,A
      LDB $6018       LD A,($6018)
      STB REGC        LD C,A
      ANDB #$03       AND $03
      CMPB REGB       CP B
      BCC L21b9       RET NC
      LDX #$6010      LD HL,$6010     Joystick inputs
      LDB $6203       LD A,($6203)    mario X position
      CMPB REGE       CP E
      BEQ L21b2       JP Z,$21B2
      BCC L21a9       JP NC,$21A9
      LDA ,X          BIT 0,(HL)
      ANDA #1
      BEQ L21ae       JP Z,$21AE
      BRA L21b2       JP $21B2
L21a9 LDA ,X          BIT 1,(HL)      219e
      ANDA #2
      BNE L21b2       JP NZ,$21B2
L21ae LDB REGC        LD A,C          21a3
      ANDB #$18       AND $18
      BNE L21b9       RET NZ
L21b2 INC $7,U        INC (IX+$07)    21ab 21a6 219b 217c sprite character #
      LDA $2,U        SET 0,(IX+$02)  switch rolling barrel to going-down-ladder barrel
      ORA #1
      STA $2,U
L21b9 RTS             RET

L21ba JSR EXX         EXX             24e7 24e0 216a 215c 2115 20de 209f 2080 2076 2050 2021 1fe2 1fcb
      LDB $3,U        LD A,(IX+$03)   set sprite X
      andb #$fe                       coco hack to speed up sprites
      STB ,X+         LD (HL),A
;                     INC L
      LDB $7,U        LD A,(IX+$07)   set sprite character #
      STB ,X++        LD (HL),A
;                     INC L
;      LDB $8,U        LD A,(IX+$08)  set Sprite Vflip & Palette
;      STB ,X+         LD (HL),A
;                     INC L
      LDB $5,U        LD A,(IX+$05)   set Sprite Y
      STB ,X          LD (HL),A
      JMP L1f8d       JP $1F8D

;                                     Attract mode - Mario's movements in level
L21d1 FCB $80,$fe,$01,$c0,$04,$50,$02,$10,$82,$60,$02,$10,$82,$ca,$01,$10
      FCB $81,$ff,$02,$38,$01,$80,$02,$ff,$04,$80,$04,$60,$80

      FCB $11,$d1,$21,$21,$cc,$63,$7e,$07,$83,$5f,$1a,$32,$10,$60,$2c,$7e
      FCB $35,$a7,$c0,$1c,$1a,$77,$2d,$34,$c9

L21ee LDY #L21d1      LD DE,$21D1     1977 Process MARIO CONTROL in attract mode
      LDX #$63cc      LD HL,$63CC
      LDB ,X+         LD A,(HL)
      LSLB            RLCA
      LEAY B,Y        ADD A,E
;                     LD E,A
      LDB ,Y          LD A,(DE)
      STB $6010       LD ($6010),A    Set Joystick inputs
;                     INC L
      LDB ,X          LD A,(HL)
      DEC ,X          DEC (HL)
      TSTB            AND A
      BNE L2206       RET NZ
      LEAY 1,Y        INC E
      LDB ,Y          LD A,(DE)
      STB ,X          LD (HL),A
;                     DEC L
      INC ,-X         INC (HL)
L2206 RTS             RET

L2207 LDB #$02        LD A,$02        199b
      JSR L0030       RST $30
      LDB $601a       LD A,($601A)
      RORB            RRA
      LDX #$6280      LD HL,$6280
      LDB ,X          LD A,(HL)
      BCS L2219       JP C,$2219
      LDX #$6288      LD HL,$6288
      LDB ,X          LD A,(HL)
L2219 PSHS X          PUSH HL         2212
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L2227
      FDB L2259
      FDB L2299
      FDB L22a2
      FDB L0000
      FDB L0000

L2227 PULS X          POP HL
      LEAX 1,X        INC L
      DEC ,X          DEC (HL)
      BNE L223a       JP NZ,$223A
;                     DEC L
      INC ,-X         INC (HL)
      LEAX 2,X        INC L
;                     INC L
      BSR L2243       CALL $2243
      LDB #$01        LD A,$01
      STB $621a       LD ($621A),A
      RTS             RET
L223a LEAX 1,X        INC L           222a
      BSR L2243       CALL $2243
      CLRB            XOR A
      STB $621a       LD ($621A),A
      RTS             RET

L2243 LDB $6205       LD A,($6205)    2276 223b 2231 mario Y position
      CMPB #$7a       CP $7A
      BCC L2257       JP NC,$2257
      LDB $6216       LD A,($6216)    Flag - Check if Mario is Jumping?
;                     AND A
      BNE L2257       JP NZ,$2257
      LDB $6203       LD A,($6203)    mario X position
      CMPB ,X         CP (HL)
      BEQ L2258       RET Z
L2257 PULS X,PC       POP HL          224f 2248
L2258 RTS             RET

L2259 PULS X          POP HL
      LEAX 4,X        INC L
;                     INC L
;                     INC L
;                     INC L
      DEC ,X          DEC (HL)
      BNE L2258       RET NZ
      LDB #$04        LD A,$04
      STB ,X          LD (HL),A
;                     DEC L
      INC ,-X         INC (HL)
      JSR L22bd       CALL $22BD
      LDB #$78        LD A,$78
      CMPB ,X         CP (HL)
      BNE L2275       JP NZ,$2275
      LEAX -3,X       DEC L
;                     DEC L
;                     DEC L
      INC ,X          INC (HL)
      LEAX 3,X        INC L
;                     INC L
;                     INC L
L2275 LEAX -1,X       DEC L           226b
      BSR L2243       CALL $2243
      LDB $6205       LD A,($6205)    mario Y position
      CMPB #$68       CP $68
      BCC L228a       JP NC,$228A
L2281 LDX #$6205      LD HL,$6205     228b mario Y position
      INC ,X          INC (HL)
      JSR L3fc0       CALL $3FC0
      INC ,X          INC (HL)
      RTS             RET
L228a RORB            RRA             227e
      BCS L2281       JP C,$2281
      RORB            RRA
      LDB #$01        LD A,$01
      BCS L2295       JP C,$2295
      CLRB            XOR A
L2295 STB $6222       LD ($6222),A    2291
      RTS             RET

L2299 PULS X          POP HL
      LDB $6018       LD A,($6018)
      ANDB #$3c       AND $3C
      BNE L22a1       RET NZ
      INC ,X          INC (HL)
L22a1 RTS             RET

L22a2 PULS X          POP HL
      LEAX 4,X        INC L
;                     INC L
;                     INC L
;                     INC L
      DEC ,X          DEC (HL)
      BNE L22bc       RET NZ
      LDA #$02        LD (HL),$02
      STA ,X
;                     DEC L
      DEC ,-X         DEC (HL)
      BSR L22bd       CALL $22BD
      LDB #$68        LD A,$68
      CMPB ,X         CP (HL)
      BNE L22bc       RET NZ
      CLRB            XOR A
      LDA #$80        LD B,$80
      STA REGB 
;                     DEC L
;                     DEC L
      STA ,--X        LD (HL),B
;                     DEC L
      STB ,-X         LD (HL),A
L22bc RTS             RET

L22bd TFR X,D                         22ad 2265
      LDA ,X          LD A,(HL)
      LDY #$694b      LD DE,$694B
      ANDB #8         BIT 3,L
      BNE L22c9       JP NZ,$22C9
      LDY #$6947      LD DE,$6947
L22c9 STA ,Y          LD (DE),A       22c3
      RTS             RET

L22cb LDB $6348       LD A,($6348)    2149
;                     AND A
      BEQ L22e1       JP Z,$22E1
      LDB $6380       LD A,($6380)
      DECB            DEC A
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L22f6
      FDB L22f6
      FDB L2303
      FDB L2303
      FDB L231a

L22e1 LDA $6229       LD A,($6229)    22cf
      LDB #$01        LD A,$01
      DECA            LD B,A
      STA REGB        DEC B
      BEQ L22f9       JP Z,$22F9
      LDB #$b1        LD A,$B1
      DEC REGB        DEC B
      BEQ L22f9       JP Z,$22F9
      LDB #$e9        LD A,$E9
      BRA L22f9       JP $22F9

L22f6 LDB $6018       LD A,($6018)

L22f9 STB $11,U       LD (IX+$11),A   22f3 22ee 22e8
      ANDB #$01       AND $01
      DECB            DEC A
      STB $10,U       LD (IX+$10),A
      RTS             RET

L2303 LDB $6018       LD A,($6018)
      STB $11,U       LD (IX+$11),A
      LDB $6203       LD A,($6203)    mario X position
      CMPB $3,U       CP (IX+$03)
      LDB #$01        LD A,$01
      BCC L2316       JP NC,$2316
      LDB #$ff        DEC A
;                     DEC A
L2316 STB $10,U       LD (IX+$10),A   2311
      RTS             RET

L231a LDB $6203       LD A,($6203)    mario X position
      SUBB $3,U       SUB (IX+$03)
      STB REGA 
      LDA #$ff        LD C,$FF
      BCS L2326       JP C,$2326
      INCA            INC C
L2326 ROL REGA        RLCA            2322
      ROLB
      ROLA            RL C
      ROL REGA        RLCA
      ROLB
      ROLA            RL C
      STA $10,U       LD (IX+$10),C
      STB $11,U       LD (IX+$11),A
      RTS             RET

L2333 LDB #$0f        LD A,$0F        33d2 2007 1ce4
      STX REGHL       AND H
      ANDB REGH 
      DEC REGB        DEC B
      BEQ L2342       JP Z,$2342
      CMPB #$0f       CP $0F
      BCS L2365       RET C
      LDA #$ff        LD B,$FF
      STA REGB 
      BRA L2347       JP $2347
L2342 CMPB #$01       CP $01          2337
      BCC L2365       RET NC
      LDA #$01        LD B,$01
      STA REGB 
L2347 LDB #$f0        LD A,$F0        233f
      CMPB REGL       CP L
      BEQ L2360       JP Z,$2360
      LDB #$4c        LD A,$4C
      CMPB REGL       CP L
      BEQ L2366       JP Z,$2366
      LDB REGL        LD A,L
      LDA REGL        BIT 5,A
      ANDA #32
      BEQ L235c       JP Z,$235C
L2359 SUBB REGB       SUB B           2362
L235a STB REGL        LD L,A          235d
      LDX REGHL 
      RTS             RET
L235c ADDB REGB       ADD A,B         236b 2356
      BRA L235a       JP $235A
L2360 LDA REGH        BIT 7,H         234a
      BMI L2359       JP NZ,$2359
L2365 RTS             RET
L2366 LDB REGH        LD A,H          2350
      CMPB #$98       CP $98
      BCS L2365       RET C
      LDB REGL        LD A,L
      BRA L235c       JP $235C

L236e LDX #$6300      LD HL,$6300     3359 216d 1b13
L2371 CMPB ,X+        CPIR            238c
      BEQ L2376
      DEC REGC 
      BNE L2371
      BRA L239a       JP NZ,$239A     equivalent to RTS RTS (skip a return)???
L2376 PSHS X          PUSH HL
      dec REGC                        added to fix CPIR translation bug!
;                     PUSH BC
;                     LD BC,$0014
      LEAX $14,X      ADD HL,BC
;                     INC C
      STB REGE        LD E,A
      LDB REGD        LD A,D
      CMPB ,X         CP (HL)
      BEQ L238f       JP Z,$238F
      LEAX $15,X      ADD HL,BC
      CMPB ,X         CP (HL)
      BEQ L2395       JP Z,$2395
      STB REGD        LD D,A
      LDB REGE        LD A,E
;                     POP BC
      PULS X          POP HL
      BRA L2371       JP $2371
L238f LEAX $15,X      ADD HL,BC       2380
      LDB #$01        LD A,$01
      BRA L2398       JP $2398
L2395 CLRB            XOR A           2385
      LEAX -21,X      SBC HL,BC
;2398                 POP BC          2392
L2398 LDA ,X          LD B,(HL)
      STA REGB 
L239a PULS X          POP HL          2373
      LDY REGDE 
      RTS             RET

L239c LDB $4,U        LD A,(IX+$04)   20ed 2054 1bec 1bc2
      ADDB $11,U      ADD A,(IX+$11)
      STB $4,U        LD (IX+$04),A
      LDB $3,U        LD A,(IX+$03)
      ADCB $10,U      ADC A,(IX+$10)
      STB $3,U        LD (IX+$03),A
      LDB $6,U        LD A,(IX+$06)
      SUBB $13,U      SUB (IX+$13)
;                     LD L,A
      LDA $5,U        LD A,(IX+$05)
      SBCA $12,U      SBC A,(IX+$12)
      TFR D,X         LD H,A
      LDB $14,U       LD A,(IX+$14)
      CLRA            AND A           clear carry
      ROLB            RLA
      INCB            INC A
;                     LD B,$00
      ROLA            RL B
      ASLB            SLA A
      ROLA            RL B
      ASLB            SLA A
      ROLA            RL B
      ASLB            SLA A
      ROLA            RL B
      STD REGBC       LD C,A
      LEAX D,X        ADD HL,BC
      STX $5,U        LD (IX+$05),H
;                     LD (IX+$06),L
      INC $14,U       INC (IX+$14)
      RTS             RET

L23de LDB $f,U        LD A,(IX+$0F)   2073 2011
      DECB            DEC A
      BNE L2403       JP NZ,$2403
      CLRB            XOR A           animate rolling barrels
      ASL $7,U        SLA (IX+$07)    toggle H & V flips
      ROLB            RLA
      ASL $8,U        SLA (IX+$08)    toggle H & V flips
      ROLB            RLA
      STB REGB        LD B,A
      LDB #$03        LD A,$03
      ORB REGC        OR C
      JSR L3009       CALL $3009
      RORB            RRA
      lda 7,U                         coco hack for modified barrel rotation
      anda #$7f
      bcc hack1
      ora #$80
hack1 ROR $8,U        RR (IX+$08)     toggle H & V flips
      RORB            RRA
      rora            RR (IX+$07)     toggle H & V flips
      sta 7,U
      LDB #$04        LD A,$04
L2403 STB $f,U        LD (IX+$0F),A   23e2
      RTS             RET

L2407 LDA $14,U       LD A,(IX+$14)   2146 20c3 1bdf
      ROLA            RLCA
      ROLA            RLCA
      ROLA            RLCA
      ROLA            RLCA
      TFR A,B         LD C,A
      ROLA
      ANDA #$0f       AND $0F
;                     LD H,A
;                     LD A,C
      ANDB #$f0       AND $F0
;                     LD L,A
;     LDX $12,U       LD C,(IX+$13)   unnecessary?
;     STX REGBC       LD B,(IX+$12)   unnecessary?
      SUBD $12,U      SBC HL,BC
      TFR D,X
      RTS             RET

L241f LDD #$0100      LD DE,$0100     2b09 1bc5 1ae6
      STB REGE 
      LDB $6203       LD A,($6203)    mario X position
      CMPB #$16       CP $16
      BCS L2440       RET C
      DECA            DEC D
      INC REGE        INC E
      CMPB #$ea       CP $EA
      BCC L2440       RET NC
      DEC REGE        DEC E
      LDB $6227       LD A,($6227)    Level Type
      RORB            RRCA
      BCC L2440       RET NC
      LDB $6205       LD A,($6205)    mario Y position
      CMPB #$58       CP $58
      BCC L2440       RET NC
      LDB $6203       LD A,($6203)    mario X position
      CMPB #$6c       CP $6C
      BCC L2440       RET NC
      INCA            INC D
L2440 STA REGD        RET
      RTS                             note!!! Y does not hold DE

;L2441 LDX #$37fa      LD HL,$37FA     0d62 (!!! anti-tampering check !!!)
;      LDB #$5e        LD A,$5E        hash numbers against copyright text
;      LDA #$06        LD B,$06
;L2448 ADDB ,X+        ADD A,(HL)      244a
;;                     INC HL
;      DECA            DJNZ $2448
;      BNE L2448
L2441  LDY #$6310      LD IY,$6310
;      TSTB            AND A
;      BEQ L2456       JP Z,$2456
;      LEAY 1,Y        INC IY
L2456 STY REGIY 
      LDB $6227       LD A,($6227)    2451 Level Type
      LDX #L3ae4      LD HL,$3AE4     LEVEL 1 (girder screen) data
      DECB            DEC A
      BEQ L2471       JP Z,$2471
      LDX #L3b5d      LD HL,$3B5D     LEVEL 2 (cement screen) data
      DECB            DEC A
      BEQ L2471       JP Z,$2471
      LDX #L3be5      LD HL,$3BE5     LEVEL 3 (elevator screen) data
      DECB            DEC A
      BEQ L2471       JP Z,$2471
      LDX #L3c8b      LD HL,$3C8B     LEVEL 4 (rivets screen) data
L2471 LDU #$6300      LD IX,$6300     246b 2464 245d
;     LDY #$0005      LD DE,$0005     unnecessary?
L2478 LDB ,X          LD A,(HL)       24b1 249b 2485
;                     AND A
      BEQ L2488       JP Z,$2488
      DECB            DEC A
      BEQ L249e       JP Z,$249E
      CMPB #$a9       CP $A9
      BEQ L2440       RET Z
      LEAX $5,X       ADD HL,DE
      BRA L2478       JP $2478
L2488 LEAX 1,X        INC HL          247a
      LDB ,X+         LD A,(HL)
      STB ,U          LD (IX+$00),A
;                     INC HL
      LDB ,X++        LD A,(HL)
      STB $15,U       LD (IX+$15),A
;                     INC HL
;                     INC HL
      LDB ,X+         LD A,(HL)
      STB $2a,U       LD (IX+$2A),A
      LEAU 1,U        INC IX
;                     INC HL
      BRA L2478       JP $2478
L249e LEAX 1,X        INC HL          247e
      LDB ,X+         LD A,(HL)
      STY REGDE 
      LDY REGIY 
      STB ,Y          LD (IY+$00),A
;                     INC HL
      LDB ,X++        LD A,(HL)
      STB $15,Y       LD (IY+$15),A
;                     INC HL
;                     INC HL
      LDB ,X+         LD A,(HL)
      STB $2a,Y       LD (IY+$2A),A
      LEAY 1,Y        INC IY
      STY REGIY 
      LDY REGDE 
;                     INC HL
      BRA L2478       JP $2478

L24b4 LDB $5,U        LD A,(IX+$05)   2101 2068 2014
      CMPB #$e8       CP $E8
      BCC L24ba       RET C
L24b9 RTS
L24ba LDB $3,U        LD A,(IX+$03)
      CMPB #$2a       CP $2A
      BCC L24b9       RET NC
      CMPB #$20       CP $20
      BCS L24b9       RET C
      LDB $15,U       LD A,(IX+$15)
;                     AND A
      BEQ L24d0       JP Z,$24D0
      LDB #$03        LD A,$03
      STB $62b9       LD ($62B9),A
      CLRB            XOR A
L24d0 STB ,U          LD (IX+$00),A   24c7
      STB $3,U        LD (IX+$03),A
;                     LD HL,$6082
      LDA #$03        LD (HL),$03
      STA $6082
      PULS X          POP HL
      LDB $6348       LD A,($6348)
;                     AND A
      LBNE L21ba      JP NZ,$21BA
      INCB            INC A
      STB $6348       LD ($6348),A
      JMP L21ba       JP $21BA

L24ea LDB #$02        LD A,$02        1992
      JSR L0030       RST $30
      BSR L2523       CALL $2523
      JSR L2591       CALL $2591
      LDU #$65a0      LD IX,$65A0
      LDA #$06        LD B,$06
      STA REGB 
      LDX #$69b8      LD HL,$69B8
L24fc LDB ,U          LD A,(IX+$00)   2519
;                     AND A
      BEQ L251c       JP Z,$251C
      LDB $3,U        LD A,(IX+$03)   set Sprite X
      andb #$fe                       coco hack to speed up sprites
      STB ,X+         LD (HL),A
;                     INC L
      LDB $7,U        LD A,(IX+$07)   set Sprite character/tile #
      STB ,X++        LD (HL),A
;                     INC L
;      LDB $8,U        LD A,(IX+$08)  set Sprite v-flip & palette
;      STB ,X+         LD (HL),A
;                     INC L
      LDB $5,U        LD A,(IX+$05)   set Sprite Y
      STB ,X+         LD (HL),A
;                     INC L
L2517 STB REGA        ADD IX,DE       2520
      TFR Y,D
      LEAU D,U
      LDB REGA 
      DEC REGB        DJNZ $24FC
      BNE L24fc
      RTS             RET
L251c LEAX 4,X        LD A,L          2500
;                     ADD A,$04
;                     LD L,A
      BRA L2517       JP $2517

L2523 LDX #$639b      LD HL,$639B     24ed
      LDB ,X          LD A,(HL)
;                     AND A
      BNE L258f       JP NZ,$258F
      LDB $639a       LD A,($639A)
;                     AND A
      BEQ L2590       RET Z
      LDA #$06        LD B,$06
      STA REGB 
      LDY #$0010      LD DE,$0010     unnecessary?
      LDU #$65a0      LD IX,$65A0
L2539 LDA ,U          BIT 0,(IX+$00)  2542
      ANDA #1
      BEQ L2545       JP Z,$2545
      LEAU $10,U      ADD IX,DE
      DEC REGB        DJNZ $2539
      BNE L2539
      RTS             RET
L2545 JSR L0057       CALL $0057      253d
      CMPB #$60       CP $60
      LDA #$7c        LD (IX+$05),$7C
      STA $5,U
      BCS L2558       JP C,$2558
      LDB $62a3       LD A,($62A3)
      DECB            DEC A
      BNE L256e       JP NZ,$256E
L2558 LDA #$cc        LD (IX+$05),$CC 254e
      STA $5,U
      LDB $62a6       LD A,($62A6)
      ROLB            RLCA
L2560 LDA #$07        LD (IX+$03),$07 2573
      STA $3,U
      BCC L2576       JP NC,$2576
      LDA #$f8        LD (IX+$03),$F8
      STA 3,U
      BRA L2576       JP $2576
L256e JSR L0057       CALL $0057      2555
      CMPB #$68       CP $68
      BRA L2560       JP $2560
L2576 LDD #$014b      LD (IX+$00),$01 256b 2564
      STA ,U
      STB $7,U        LD (IX+$07),$4B Sprite Cement Pie character #
      LDD #$0803      LD (IX+$09),$08
      STD $9,U        LD (IX+$0A),$03
      LDB #$7c        LD A,$7C
      STB $639b       LD ($639B),A
      CLRB            XOR A
      STB $639a       LD ($639A),A
L258f DEC ,X          DEC (HL)        2528
L2590 RTS             RET

L2591 LDU #$65a0      LD IX,$65A0     24f0
      LDY #$0010      LD DE,$0010     unnecessary?
      LDA #$06        LD B,$06
      STA REGB 
L259a LDA ,U          BIT 0,(IX+$00)  25bd
      ANDA #1
      BEQ L25bb       JP Z,$25BB
      LDB $3,U        LD A,(IX+$03)
      STB REGH        LD H,A
      ADDB #$07       ADD A,$07
      CMPB #$0e       CP $0E
      BCS L25d6       JP C,$25D6
      LDB $5,U        LD A,(IX+$05)
      CMPB #$7c       CP $7C
      BEQ L25c0       JP Z,$25C0
      LDB $63a6       LD A,($63A6)
      ADDB REGH       ADD A,H
      STB $3,U        LD (IX+$03),A
L25bb LEAU $10,U      ADD IX,DE       25ef 25d3 259e
      DEC REGB        DJNZ $259A
      BNE L259a
      RTS             RET
L25c0 LDB REGH        LD A,H          25b1
      CMPB #$80       CP $80
      BEQ L25d6       JP Z,$25D6
      LDB $63a5       LD A,($63A5)
      BCC L25cf       JP NC,$25CF
      LDB $63a4       LD A,($63A4)
L25cf ADDB REGH       ADD A,H         25c9
      STB $3,U        LD (IX+$03),A
      BRA L25bb       JP $25BB
L25d6 LDX #$69b8      LD HL,$69B8     25c3 25a9
      LDB #$06        LD A,$06
      SUBB REGB       SUB B
L25dc BEQ L25e7       JP Z,$25E7      25e4
      LEAX 4,X        INC L
;                     INC L
;                     INC L
;                     INC L
      DECB            DEC A
      BRA L25dc       JP $25DC
L25e7 CLRB            XOR A           25dc
      STB ,U          LD (IX+$00),A
      STB $3,U        LD (IX+$03),A
      STB ,X          LD (HL),A
      BRA L25bb       JP $25BB

L25f2 LDB #$02        LD A,$02        19aa
      JSR L0030       RST $30
      BSR L2602       CALL $2602
      BSR L262f       CALL $262F
      JSR L2679       CALL $2679
      JSR L2ad3       CALL $2AD3
      RTS             RET

L2602 LDB $601a       LD A,($601A)    25f5 16d5
      RORB            RRCA
      BCS L2616       JP C,$2616
      LDX #$62a0      LD HL,$62A0
      DEC ,X          DEC (HL)
      BNE L2616       JP NZ,$2616
      LDA #$80        LD (HL),$80
      STA ,X+
;                     INC L
      JSR L26de       CALL $26DE
L2616 LDX #$62a1      LD HL,$62A1     260d 2606
      JSR L26e9       CALL $26E9
      STB $63a3       LD ($63A3),A
      LDB $601a       LD A,($601A)
      ANDB #$1f       AND $1F
      CMPB #$01       CP $01
      BNE L262e       RET NZ
      LDY #$69e4      LD DE,$69E4
      EXG Y,X         EX DE,HL
      JSR L26a6       CALL $26A6
L262e RTS             RET

L262f LDX #$62a3      LD HL,$62A3     25f8
      LDB $6205       LD A,($6205)    mario Y position
      CMPB #$c0       CP $C0
      BCS L266f       JP C,$266F
      LDB $601a       LD A,($601A)
      RORB            RRCA
      BCS L264c       JP C,$264C
;                     DEC L
      DEC ,-X         DEC (HL)
      BNE L264c       JP NZ,$264C
      LDA #$c0        LD (HL),$C0
      STA ,X+
;                     INC L
      JSR L26de       CALL $26DE
L264c LDX #$62a3      LD HL,$62A3     2676 2671 2643 263e
      JSR L26e9       CALL $26E9
      STB $63a5       LD ($63A5),A
      NEGB            NEG
      STB $63a4       LD ($63A4),A
      LDB $601a       LD A,($601A)
      ANDB #$1f       AND $1F
      BNE L266e       RET NZ
      LEAX -1,X       DEC L
      LDY #$69ec      LD DE,$69EC
      EXG Y,X         EX DE,HL
      BSR L26a6       CALL $26A6
      ANDB #$7f       AND $7F
      LDX #$69ed      LD HL,$69ED
      STB ,X          LD (HL),A
L266e RTS             RET
L266f LDA ,X          BIT 7,(HL)      2637
      BMI L264c       JP NZ,$264C
      LDA #$ff        LD (HL),$FF
      STA ,X
      BRA L264c       JP $264C

L2679 LDB $601a       LD A,($601A)    25fb
      RORB            RRCA
      BCS L268d       JP C,$268D
      LDX #$62a5      LD HL,$62A5
      DEC ,X          DEC (HL)
      BNE L268d       JP NZ,$268D
      LDA #$ff        LD (HL),$FF
      STA ,X+
;                     INC L
      BSR L26de       CALL $26DE
L268d LDX #$62a6      LD HL,$62A6     2684 267d
      JSR L26e9       CALL $26E9
      STB $63a6       LD ($63A6),A
      LDB $601a       LD A,($601A)
      ANDB #$1f       AND $1F
      CMPB #$02       CP $02
      BNE L26a5       RET NZ
      LDY #$69f4      LD DE,$69F4
      EXG Y,X         EX DE,HL
      BSR L26a6       CALL $26A6
L26a5 RTS             RET

L26a6 LEAX 1,X        INC L           26a2 2665 262b
      LDB ,Y          LD A,(DE)
      ROLB            RLA
      BCS L26c5       JP C,$26C5
      LDB ,X          LD A,(HL)
      INCB            INC A
      CMPB #$53       CP $53
      BNE L26b5       JP NZ,$26B5
      LDB #$50        LD A,$50
L26b5 STB ,X          LD (HL),A       26b0
      TFR X,D         LD A,L
      ADDB #$04       ADD A,$04
      TFR D,X         LD L,A
      LDB ,X          LD A,(HL)
      DECB            DEC A
      CMPB #$cf       CP $CF
      BNE L26c3       JP NZ,$26C3
      LDB #$d2        LD A,$D2
L26c3 STB ,X          LD (HL),A       26be
      RTS             RET
L26c5 LDB ,X          LD A,(HL)       26a9
      DECB            DEC A
      CMPB #$4f       CP $4F
      BNE L26ce       JP NZ,$26CE
      LDB #$52        LD A,$52
L26ce STB ,X          LD (HL),A       26c9
      TFR X,D         LD A,L
      ADDB #$04       ADD A,$04
      TFR D,X         LD L,A
      LDB ,X          LD A,(HL)
      INCB            INC A
      CMPB #$d3       CP $D3
      BNE L26dc       JP NZ,$26DC
      LDB #$d0        LD A,$D0
L26dc STB ,X          LD (HL),A       26d7
      RTS             RET

L26de LDA ,X          BIT 7,(HL)      268a 2649 2613
      BPL L26e6       JP Z,$26E6
      LDA #$02        LD (HL),$02
      STA ,X
      RTS             RET
L26e6 LDA #$fe        LD (HL),$FE     26e0
      STA ,X
      RTS             RET

L26e9 LDB $601a       LD A,($601A)    2690 264f 2619
      ANDB #$01       AND $01
      BEQ L26f9       RET Z
      LDB #$ff        LD A,$FF
      LDA ,X          BIT 7,(HL)
      BMI L26f8       JP NZ,$26F8
      LDB #$01        LD A,$01
L26f8 STB ,X          LD (HL),A       26f3
L26f9 RTS             RET

L26fa LDB #$04        LD A,$04        19a7
      JSR L0030       RST $30
      LDB $6205       LD A,($6205)    mario Y position
      CMPB #$f0       CP $F0
      BCC L277f       JP NC,$277F     make mario die
      LDB $601a       LD A,($601A)
      LDA $6229       LD x,($6229)
      DECA            DEC x
      BNE L271a       JP NZ,$271A
      ANDB #$03       AND $03
      CMPB #$01       CP $01
      BEQ L271e       JP Z,$271E
      BCS L2722       JP C,$2722
      RTS             RET
L271a RORB            RRCA            270c
      BCS L2722       JP C,$2722
L271e BSR L2745       CALL $2745      2713
      RTS             RET
L2722 JSR L2797       CALL $2797      271b 2716
      JSR L27da       CALL $27DA
      LDA #$06        LD B,$06        six elevators in level
      LDY #$0010      LD DE,$0010     unnecessary?
      LDX #$6958      LD HL,$6958
      LDU #$6600      LD IX,$6600
L2734 LDB $3,U        LD A,(IX+$03)   2742 store 6 elevator coordinates?
      STB ,X          LD (HL),A
      LEAX 3,X        INC L
;                     INC L
;                     INC L
      LDB $5,U        LD A,(IX+$05)
      STB ,X+         LD (HL),A
;                     INC L
      LEAU $10,U      ADD IX,DE
      DECA            DJNZ $2734
      BNE L2734
      RTS             RET

L2745 LDB $6398       LD A,($6398)    271e Flag - check if riding elevator
;                     AND A
      BEQ L277e       RET Z
      LDB $6216       LD A,($6216)    Flag - Check if Mario is Jumping?
;                     AND A
      BNE L277e       RET NZ
      LDB $6203       LD A,($6203)    mario X position
      CMPB #$2c       CP $2C
      BCS L2766       JP C,$2766      not not elevator
      CMPB #$43       CP $43
      BCS L276f       JP C,$276F      on left elevator
      CMPB #$6c       CP $6C
      BCS L2766       JP C,$2766      not on elevator
      CMPB #$83       CP $83
      BCS L2787       JP C,$2787      on right elevator
L2766 CLRB            XOR A           275e 2754
      STB $6398       LD ($6398),A    mario got off elevator
      INCB            INC A
      STB $6221       LD ($6221),A
      RTS             RET
L276f LDB $6205       LD A,($6205)    2759 mario Y position
      CMPB #$71       CP $71
      BCS L277f       JP C,$277F      make mario die
      DECB            DEC A           Mario is on an upwards moving elevator
      STB $6205       LD ($6205),A    mario Y position
      STB $694f       LD ($694F),A
L277e RTS             RET

L277f CLRB            XOR A           278c 2774 2702 make mario die
      STB $6200       LD ($6200),A    Flag - Mario not alive
      STB $6398       LD ($6398),A    Flag - unset riding elevator
      RTS             RET

L2787 LDB $6205       LD A,($6205)    2763 mario Y position
      CMPB #$e8       CP $E8
      BCC L277f       JP NC,$277F     make mario die
      INCB            INC A           Mario is on a downwards moving elevator
      STB $6205       LD ($6205),A    mario Y position
      STB $694f       LD ($694F),A
      RTS             RET

L2797 LDA #$06        LD B,$06        2722 Move the elevators to the right side
      STA REGB 
      LDY #$0010      LD DE,$0010
      LDU #$6600      LD IX,$6600
L27a0 LDA ,U          BIT 0,(IX+$00)  27c4
      ANDA #1
      BEQ L27c2       JP Z,$27C2
      LDA $d,U        BIT 3,(IX+$0D)
      ANDA #8
      BEQ L27c7       JP Z,$27C7
      LDB $5,U        LD A,(IX+$05)
      DECB            DEC A
      STB $5,U        LD (IX+$05),A
      CMPB #$60       CP $60
      BNE L27c2       JP NZ,$27C2
      LDD #$7704      LD (IX+$03),$77
      STA $3,U
      STB $d,U        LD (IX+$0D),$04
L27c2 LEAU $10,U      ADD IX,DE       27d7 27d0 27b7 27a4
      DEC REGB        DJNZ $27A0
      BNE L27a0
      RTS             RET
L27c7 LDB $5,U        LD A,(IX+$05)   27ab
      INCB            INC A
      STB $5,U        LD (IX+$05),A
      CMPB #$f8       CP $F8
      BNE L27c2       JP NZ,$27C2
      CLR ,U          LD (IX+$00),$00
      BRA L27c2       JP $27C2

L27da LDX #$62a7      LD HL,$62A7     2725 Move the elevators to the left side
      LDB ,X          LD A,(HL)
;                     AND A
      BNE L2806       JP NZ,$2806
      LDA #$06        LD B,$06
      STA REGB 
      LDU #$6600      LD IX,$6600
L27e8 LDA ,U          BIT 0,(IX+$00)  27f1
      ANDA #1
      BEQ L27f4       JP Z,$27F4
;     STB REGA        ADD IX,DE       DE seems to be 0010
;     TFR Y,D
      LEAU $10,U
;     LDB REGA 
      DEC REGB        DJNZ $27E8
      BNE L27e8
      RTS             RET
L27f4 LDD #$0137      LD (IX+$00),$01 27ec
      STA ,U
      STB $3,U        LD (IX+$03),$37
      LDD #$f808      LD (IX+$05),$F8
      STA $5,U
      STB $d,U        LD (IX+$0D),$08
      LDA #$34        LD (HL),$34
      STA ,X
L2806 DEC ,X          DEC (HL)        27df
      RTS             RET

L2808 LDX #$6200      LD IY,$6200     19b3 Flags - Mario alive
      STX REGIY 
      LDB $6205       LD A,($6205)    mario Y position
      STB REGC        LD C,A
      LDX #$0407      LD HL,$0407
      BSR L286f       CALL $286F      live or die?
      TSTB            AND A
      BEQ L281c       RET Z
      DECB            DEC A           die
      STB $6200       LD ($6200),A    Flag - Mario is not alive
L281c RTS             RET

L281d LDA #$02        LD B,$02        19b6
      STA REGB 
;                     LD DE,$0010
      LDY #$6680      LD IY,$6680     hammer character data
L2826 LDA $01,Y       BIT 0,(IY+$01)  282f
      ANDA #1
      BNE L2832       JP NZ,$2832
      LEAY $10,Y      ADD IY,DE
      DEC REGB        DJNZ $2826
      BNE L2826
      STY REGIY 
      LDY #$0010                      unnecessary?
      RTS             RET
L2832 LDA $05,Y       LD C,(IY+$05)   282a
      STA REGC 
      LDX $09,Y       LD H,(IY+$09)   endian issue?
;                     LD L,(IY+$0A)
      STY REGIY 
;     LDY #$0010                      unnecessary?
      BSR L286f       CALL $286F
      TSTB            AND A
      BEQ L2852       RET Z
      STB $6350       LD ($6350),A
      LDB $63b9       LD A,($63B9)
      SUBB REGB       SUB B
      STB $6354       LD ($6354),A
      LDB REGE        LD A,E
      STB $6353       LD ($6353),A
      STU $6351       LD ($6351),IX
L2852 RTS             RET

L2853 LDX #$6200      LD IY,$6200     1c20 Flags - Mario alive
      STX REGIY 
      LDB $6205       LD A,($6205)    mario Y position
      ADDB #$0c       ADD A,$0C
      STB REGC        LD C,A
      LDX #$0508      LD HL,$0508
      LDB $6010       LD A,($6010)    Joystick inputs
      ANDB #$03       AND $03
      BEQ L286b       JP Z,$286B
      LDX #$1308      LD HL,$1308
L286b JSR L3e88       CALL $3E88      2865
      RTS             RET

L286f LDB $6227       LD A,($6227)    283b 2813 Level Type
      PSHS X          PUSH HL         check if hammer has hit something
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L0000
      FDB L2880                       level 1 check
      FDB L28b0                       level 2 check
      FDB L28e0                       level 3 check
      FDB L2901                       level 4 check
      FDB L0000

L2880 PULS X          POP HL          level 1 - check if hammer hits something
      LDD #$200a      LD B,$0A
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD DE,$0020
      LDU #$6700      LD IX,$6700
      JSR L2913       CALL $2913
      LDD #$2005      LD B,$05
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD E,$20
      LDU #$6400      LD IX,$6400     fireball character data
      JSR L2913       CALL $2913
      LDD #$0001      LD B,$01
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD E,$00
      LDU #$66a0      LD IX,$66A0
      BSR L2913       CALL $2913
      RTS             RET

L28b0 PULS X          POP HL          level 2 - check if hammer hits something
      LDD #$2005      LD B,$05
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD DE,$0020
      LDU #$6400      LD IX,$6400     fireball character data
      BSR L2913       CALL $2913
      LDD #$1006      LD B,$06
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD E,$10
      LDU #$65a0      LD IX,$65A0
      BSR L2913       CALL $2913
      LDD #$0001      LD B,$01
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD E,$00
      LDU #$66a0      LD IX,$66A0
      BSR L2913       CALL $2913
      RTS             RET

L28e0 PULS X          POP HL          level 3 - check if hammer hits something
      LDD #$2005      LD B,$05
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD DE,$0020
      LDU #$6400      LD IX,$6400     fireball character data
      BSR L2913       CALL $2913
      LDD #$100a      LD B,$0A
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD E,$10
      LDU #$6500      LD IX,$6500     check if hammer hits a spring, hm?
      BSR L2913       CALL $2913
      RTS             RET

L2901 PULS X          POP HL          level 4 - check if hammer hits something
      LDD #$2007      LD B,$07
      STB REGB        LD A,B
      STB $63b9       LD ($63B9),A
      STA REGE        LD DE,$0020
      LDU #$6400      LD IX,$6400     fireball character data
      BSR L2913       CALL $2913
      RTS             RET

L2913 PSHS U          PUSH IX         2a2b 2988 290f 28fd 28ee 28dc 28cd 28be 28ac 289d 288e
      STX REGHL                       swap X to be IY
      LDX REGIY                       check if hammer collides with something else
L2915 LDA ,U          BIT 0,(IX+$00)  294e
      ANDA #1
      BEQ L294c       JP Z,$294C
      LDB REGC        LD A,C
      SUBB $5,U       SUB (IX+$05)
      BCC L2925       JP NC,$2925
      NEGB            NEG
L2925 INCB            INC A           2920
      SUBB REGL       SUB L
      BCS L2930       JP C,$2930
      SUBB $a,U       SUB (IX+$0A)
      BCC L294c       JP NC,$294C
L2930 LDB $3,X        LD A,(IY+$03)   2927
      SUBB $3,U       SUB (IX+$03)
      BCC L293b       JP NC,$293B
      NEGB            NEG
L293b SUBB REGH       SUB H           2936
      BCS L2945       JP C,$2945
      SUBB $9,U       SUB (IX+$09)
      BCC L294c       JP NC,$294C
L2945 CLRA                            set/restore Y=DE
      LDB REGE
      TFR D,Y
      LDB #$01        LD A,$01        293c
      PULS U          POP IX
      LEAS 2,S        INC SP
;                     INC SP
      LDX REGHL                       restore HL
      RTS             RET
L294c LDA REGE        ADD IX,DE       2942 292d 2919
      LEAU A,U
      DEC REGB        DJNZ $2915
      BNE L2915
      CLRA                            set/restore Y=DE
      LDB REGE
      TFR D,Y
      CLRB            XOR A
      PULS U          POP IX
      LDX REGHL                       restore HL
      RTS             RET

L2954 LDB #$0b        LD A,$0B        1c34
      JSR L0030       RST $30
      BSR L2974       CALL $2974
      STB $6218       LD ($6218),A
      TFR B,A         RRCA
      ASRA
      RORB
      ASRA            RRCA
      RORB
      STB $6085       LD ($6085),A
      LDB REGB        LD A,B
;                     AND A
      BEQ L2973       RET Z
      CMPB #$01       CP $01
      BEQ L296f       JP Z,$296F
      LDA #$01        LD (IX+$01),$01
      STA 1,U
      RTS             RET
L296f STB $11,U       LD (IX+$11),$01 2967
L2973 RTS             RET

L2974 LDX #$6200      LD IY,$6200     2957 Flags - Mario alive
      STX REGIY 
      LDB $6205       LD A,($6205)    mario Y position
      STB REGC        LD C,A
      LDX #$0408      LD HL,$0408
      LDD #$0210      LD B,$02
      STA REGB 
      STB REGE        LD DE,$0010
      LDU #$6680      LD IX,$6680     hammer character data
      JSR L2913       CALL $2913
      RTS             RET

L298c LDX $63c8       LD HL,($63C8)   323e
      TFR X,D         LD A,L
      ADDB #$0e       ADD A,$0E
      TFR D,X         LD L,A
      LDA ,X+         LD D,(HL)
;                     INC L
      LDB ,X          LD A,(HL)
      ADDB #$0c       ADD A,$0C
      TFR D,X         LD E,A
;                     EX DE,HL
      JSR L2ff0       CALL $2FF0
      LDB ,X          LD A,(HL)
      CMPB #$b0       CP $B0
      BCS L29ac       JP C,$29AC
      ANDB #$0f       AND $0F
      CMPB #$08       CP $08
      BCC L29ac       JP NC,$29AC
      CLRB            XOR A
      RTS             RET
L29ac LDB #$01        LD A,$01        29a7 29a0
      RTS             RET

L29af LDB #$04        LD A,$04        2b23
      JSR L0030       RST $30
      LDX #$6200      LD IY,$6200     Flags - Mario alive
      STX REGIY 
      LDB $6205       LD A,($6205)    mario Y position
      STB REGC        LD C,A
      LDX #$0408      LD HL,$0408
      JSR L2a22       CALL $2A22
      TSTB            AND A
      BEQ L2a20       JP Z,$2A20
      LDB #$06        LD A,$06
      SUBB REGB       SUB B
L29c7 BEQ L29d0       JP Z,$29D0      29cd
;     STB REGA        ADD IX,DE
;     TFR Y,D
      LEAU $10,U
;     LDB REGA 
      DECB            DEC A
      BRA L29c7       JP $29C7
L29d0 LDA $5,U        LD A,(IX+$05)   29c7 U/IX should be 66xx
      SUBA #$04       SUB 04
      TFR D,Y         LD D,A
      STA REGD 
      LDB $620c       LD A,($620C)
      ADDB #$05       ADD A,$05
      CMPB REGD       CP D            check if on or below elevator
      BCC L29ee       JP NC,$29EE
      LDB REGD        LD A,D          on
      SUBB #$08       SUB 08
      STB $6205       LD ($6205),A    mario Y position
      LDB #$01        LD A,$01
      STB REGB        LD B,A
      STB $6398       LD ($6398),A    Flag - set as riding elevator
      LEAS 2,S        INC SP
;                     INC SP
      RTS             RET
L29ee LDB $620c       LD A,($620C)    29dc collide with side of elevator
      SUBB #$0e       SUB 0E
      CMPB REGD       CP D
      BCC L2a1b       JP NC,$2A1B
      LDB $6203       LD A,($6203)    mario X position
      LDA $6210       LD x,($6210)
;                     AND x
      BEQ L2a08       JP Z,$2A08
      ORB #$07        OR 07
      SUBB #$04       SUB 04
      BRA L2a0e       JP $2A0E
L2a08 SUBB #$08       SUB 08          29fe
      ORB #$07        OR 07
      ADDB #$04       ADD A,$04
L2a0e STB $6203       LD ($6203),A    2a05 mario X position
      STB $694c       LD ($694C),A
      LDB #$01        LD A,$01
      CLR REGB        LD B,$00
      LEAS 2,S        INC SP
;                     INC SP
      RTS             RET
L2a1b CLRB            XOR A           29f4
      STB $6200       LD ($6200),A    Flag - Mario is not alive
      RTS             RET
L2a20 STB REGB        LD B,A          29c1
      RTS             RET

L2a22 LDD #$0610      LD B,$06        29bd
      STA REGB 
      STB REGE        LD DE,$0010
      LDU #$6600      LD IX,$6600
      JSR L2913       CALL $2913
      RTS             RET

L2a2f LDA $3,U        LD A,(IX+$03)   20fa 2057
;                     LD H,A
      LDB $5,U        LD A,(IX+$05)
      ADDB #$04       ADD A,$04
      TFR D,X         LD L,A
      PSHS X          PUSH HL
      JSR L2ff0       CALL $2FF0
      PULS Y          POP DE
      LDB ,X          LD A,(HL)
      CMPB #$b0       CP $B0
      BCS L2a7b       JP C,$2A7B
      ANDB #$0f       AND $0F
      CMPB #$08       CP $08
      BCC L2a7b       JP NC,$2A7B
      LDB ,X          LD A,(HL)
      CMPB #$c0       CP $C0
      BEQ L2a7b       JP Z,$2A7B
      BCS L2a69       JP C,$2A69
      CMPB #$d0       CP $D0
      BCS L2a6e       JP C,$2A6E
      CMPB #$e0       CP $E0
      BCS L2a63       JP C,$2A63
      CMPB #$f0       CP $F0
      BCS L2a6e       JP C,$2A6E
L2a63 ANDB #$0f       AND $0F         2a5b
      DECB            DEC A
      BRA L2a72       JP $2A72
L2a69 LDB #$ff        LD A,$FF        2a51
      BRA L2a72       JP $2A72
L2a6e ANDB #$0f       AND $0F         2a60 2a56
      SUBB #$09       SUB 09
L2a72 STB REGC        LD C,A          2a6b 2a66
      TFR Y,D         LD A,E
      STB REGE 
      ANDB #$f8       AND $F8
      ADDB REGC       ADD A,C
      CMPB REGE       CP E
      BCS L2a7d       JP C,$2A7D
L2a7b CLRB            XOR A           2a4e 2a48 2a41
      RTS             RET
L2a7d SUBB #$04       SUB 04          2a78
      STB $5,U        LD (IX+$05),A
      LDB #$01        LD A,$01
      RTS             RET

L2a85 LDB $6215       LD A,($6215)    19a1 Flag - Check if Mario is climbing a ladder
;                     AND A
      BNE L2ad2       RET NZ
      LDB $6216       LD A,($6216)    Flag - Check if Mario is Jumping?
;                     AND A
      BNE L2ad2       RET NZ
      LDB $6398       LD A,($6398)    Flag - check if riding elevator
      CMPB #$01       CP $01
      BEQ L2ad2       RET Z
      LDA $6203       LD A,($6203)    mario X position
      SUBA #$03       SUB 03
;                     LD H,A
      LDB $6205       LD A,($6205)    mario Y position
      ADDB #$0c       ADD A,$0C
      TFR D,X         LD L,A
      PSHS X          PUSH HL
      JSR L2ff0       CALL $2FF0
      PULS Y          POP DE
      LDB ,X          LD A,(HL)
      CMPB #$b0       CP $B0
      BCS L2ab4       JP C,$2AB4
      ANDB #$0f       AND $0F
      CMPB #$08       CP $08
      BCC L2ab4       JP NC,$2AB4
      RTS             RET
L2ab4 TFR Y,D         LD A,D          2ab0 2aa9
      ANDA #$07       AND $07
      BEQ L2acd       JP Z,$2ACD
;                     LD BC,$0020     unnecessary?
      LEAX -32,X      SBC HL,BC
      LDB ,X          LD A,(HL)
      CMPB #$b0       CP $B0
      BCS L2acd       JP C,$2ACD
      ANDB #$0f       AND $0F
      CMPB #$08       CP $08
      BCC L2acd       JP NC,$2ACD
      RTS             RET
L2acd LDB #$01        LD A,$01        2ac9 2ac2 2ab7
      STB $6221       LD ($6221),A
L2ad2 RTS             RET

L2ad3 LDB $6203       LD A,($6203)    25fe mario X position
      STB REGB        LD B,A
      LDB $6205       LD A,($6205)    mario Y position
      CMPB #$50       CP $50
      BEQ L2aea       JP Z,$2AEA
      CMPB #$78       CP $78
      BEQ L2af6       JP Z,$2AF6
      CMPB #$c8       CP $C8
      BEQ L2af0       JP Z,$2AF0
      RTS             RET
L2aea LDB $63a3       LD A,($63A3)    2adc
      BRA L2b02       JP $2B02
L2af0 LDB $63a6       LD A,($63A6)    2ae6
      BRA L2b02       JP $2B02
L2af6 LDB REGB        LD A,B          2ae1
      CMPB #$80       CP $80
      LDB $63a5       LD A,($63A5)
      BCC L2b02       JP NC,$2B02
      LDB $63a4       LD A,($63A4)
L2b02 ADDB REGB       ADD A,B         2afc 2af3 2aed
      STB $6203       LD ($6203),A    mario X position
      STB $694c       LD ($694C),A
      JSR L241f       CALL $241F      note!!! Y does not hold DE from this point...
      LDX #$6203      LD HL,$6203     mario X position
      DEC REGE        DEC E
      BEQ L2b18       JP Z,$2B18
      DEC REGD        DEC D
      BEQ L2b1a       JP Z,$2B1A
      LDY REGDE 
      RTS             RET
L2b18 DEC ,X          DEC (HL)        2b10
      LDY REGDE 
      RTS             RET
L2b1a INC ,X          INC (HL)        2b14
      LDY REGDE 
      RTS             RET

L2b1c LDU #$6200      LD IX,$6200     1c05 Flags - Mario alive
      BSR L2b29       CALL $2B29
      JSR L29af       CALL $29AF
      CLRB            XOR A
      STB REGB        LD B,A
      RTS             RET

L2b29 LDB $6227       LD A,($6227)    2b20 Level Type
      DECB            DEC A
      BNE L2b53       JP NZ,$2B53
      LDA $6203       LD A,($6203)    mario X position
;                     LD H,A
      LDB $6205       LD A,($6205)    mario Y position
      ADDB #$07       ADD A,$07
      TFR D,X         LD L,A
      BSR L2b9b       CALL $2B9B
      TSTB            AND A
      BEQ L2b51       JP Z,$2B51
      TFR Y,D         LD A,E
      SUBB REGC       SUB C
      CMPB #$04       CP $04
      BCC L2b74       JP NC,$2B74
      LDB REGC        LD A,C
      SUBB #$07       SUB 07
      STB $6205       LD ($6205),A    mario Y position
      LDB #$01        LD A,$01
      STB REGB        LD B,A
L2b51 PULS X,PC       POP HL          2b3e
;      RTS             RET
L2b53 LDA $6203       LD A,($6203)    2b2d mario X position
      SUBA #$03       SUB 03
;                     LD H,A
      LDB $6205       LD A,($6205)    mario Y position
      ADDB #$07       ADD A,$07
      TFR D,X         LD L,A
      BSR L2b9b       CALL $2B9B
      CMPB #$02       CP $02
      BEQ L2b7a       JP Z,$2B7A
      TFR Y,D         LD A,D
      ADDA #$07       ADD A,$07
;                     LD H,A
      TFR D,X         LD L,E
      BSR L2b9b       CALL $2B9B
      TSTB            AND A
      BEQ L2b9a       RET Z
      BRA L2b7a       JP $2B7A
L2b74 CLRB            LD A,$00        2b45
      STB REGB        LD B,$00
      PULS X,PC       POP HL
;      RTS             RET
L2b7a LDB $6203       LD A,($6203)    2b71 2b64 mario X position
      LDA $6210       LD x,($6210)
;                     AND x
      BEQ L2b8b       JP Z,$2B8B
      ORB #$07        OR 07
      SUBB #$04       SUB 04
      BRA L2b91       JP $2B91
L2b8b SUBB #$08       SUB 08          2b81
      ORB #$07        OR 07
      ADDB #$04       ADD A,$04
L2b91 STB $6203       LD ($6203),A    2b88 mario X position
      STB $694c       LD ($694C),A
      LDB #$01        LD A,$01
      PULS X,PC       POP HL
L2b9a RTS             RET

L2b9b PSHS X          PUSH HL         2b6c 2b5f 2b3a
      JSR L2ff0       CALL $2FF0
      PULS Y          POP DE
      LDB ,X          LD A,(HL)
      CMPB #$b0       CP $B0
      BCS L2bd9       JP C,$2BD9
      ANDB #$0f       AND $0F
      CMPB #$08       CP $08
      BCC L2bd9       JP NC,$2BD9
      LDB ,X          LD A,(HL)
      CMPB #$c0       CP $C0
      BEQ L2bd9       JP Z,$2BD9
      BCS L2bdc       JP C,$2BDC
      CMPB #$d0       CP $D0
      BCS L2bcb       JP C,$2BCB
      CMPB #$e0       CP $E0
      BCS L2bc5       JP C,$2BC5
      CMPB #$f0       CP $F0
      BCS L2bcb       JP C,$2BCB
L2bc5 ANDB #$0f       AND $0F         2bbd
      DECB            DEC A
      BRA L2bcf       JP $2BCF
L2bcb ANDB #$0f       AND $0F         2bc2 2bb8
      SUBB #$09       SUB 09
L2bcf STB REGC        LD C,A          2bc8
      TFR Y,D         LD A,E
      STB REGE 
      ANDB #$f8       AND $F8
      ADDB REGC       ADD A,C
      STB REGC        LD C,A
      CMPB REGE       CP E
      BCS L2be1       JP C,$2BE1
L2bd9 CLRB            XOR A           2bb0 2baa 2ba3
      STB REGB        LD B,A
      RTS             RET
L2bdc TFR Y,D         LD A,E          2bb3
      STB REGE 
      ANDB #$f8       AND $F8
      DECB            DEC A
      STB REGC        LD C,A
L2be1 LDB $620c       LD A,($620C)    2bd6
      SUBB $5,U       SUB (IX+$05)
      ADDB REGE       ADD A,E
      CMPB REGC       CP C
      BEQ L2bef       JP Z,$2BEF
      BCC L2bf8       JP NC,$2BF8
L2bef LDB REGC        LD A,C          2be9
      SUBB #$07       SUB 07
      STB $6205       LD ($6205),A    mario Y position
      BRA L2bfd       JP $2BFD
L2bf8 LDB #$02        LD A,$02        2bec
      CLR REGB        LD B,$00
      RTS             RET
L2bfd LDB #$01        LD A,$01        2bf5
      STB REGB        LD B,A
      LEAS 2,S        POP HL
      PULS X          POP HL
      RTS             RET

L2c03 LDB #$01        LD A,$01        1989
      JSR L0030       RST $30
      JSR L0010       RST $10
      LDB $6393       LD A,($6393)
      RORB            RRCA
      BCS L2c32       RET C
      LDB $62b1       LD A,($62B1)
;                     AND A
      BEQ L2c32       RET Z
      STB REGC        LD C,A
      LDB $62b0       LD A,($62B0)
      SUBB #$02       SUB 02
      CMPB REGC       CP C
      BCS L2c7b       JP C,$2C7B
      LDB $6382       LD A,($6382)
      ANDB #2         BIT 1,A
      BNE L2c86       JP NZ,$2C86
      LDB $6380       LD A,($6380)
      STB REGB        LD B,A
      LDB $601a       LD A,($601A)
      ANDB #$1f       AND $1F
L2c2c CMPB REGB       CP B            2c30
      BEQ L2c33       JP Z,$2C33
      DEC REGB        DJNZ $2C2C
      BNE L2c2c
L2c32 RTS             RET
L2c33 LDB $62b0       LD A,($62B0)    2c2d
      LSRB            SRL A
      CMPB REGC       CP C
      BCS L2c41       JP C,$2C41
      LDB $6019       LD A,($6019)
      RORB            RRCA
      BCC L2c32       RET NC
L2c41 JSR L0057       CALL $0057      2c39
      ANDB #$0f       AND $0F
      BNE L2c86       JP NZ,$2C86
L2c49 LDB #$01        LD A,$01        2c7e
L2c4b STB $6382       LD ($6382),A    2c83
      INCB            INC A
L2c4f STB $638f       LD ($638F),A    2c8c
      LDB #$01        LD A,$01
      STB $6392       LD ($6392),A
      LDB $62b2       LD A,($62B2)
      CMPB REGC       CP C
      BNE L2c32       RET NZ
      SUBB #$08       SUB 08
      STB $62b2       LD ($62B2),A
;                     LD DE,$0020     unnecessary
      LDX #$6400      LD HL,$6400     fireball character data
      LDA #$05        LD B,$05
      STA REGB 
L2c69 LDB ,X          LD A,(HL)       2c6f
;                     AND A
      BEQ L2c72       JP Z,$2C72
      LEAX $20,X      ADD HL,DE
      DEC REGB        DJNZ $2C69
      BNE L2c69
      RTS             RET
L2c72 LDB $6382       LD A,($6382)    2c6b
      ORB #$80        OR 80
      STB $6382       LD ($6382),A
      RTS             RET
L2c7b ADDB #$02       ADD A,$02       2c18
      CMPB REGC       CP C
      BEQ L2c49       JP Z,$2C49
      LDB #$02        LD A,$02
      BRA L2c4b       JP $2C4B
L2c86 CLRB            XOR A           2c46 2c20
      STB $6382       LD ($6382),A
      LDB #$03        LD A,$03
      BRA L2c4f       JP $2C4F

L2c8f LDB #$01        LD A,$01        1986
      JSR L0030       RST $30
      JSR L0010       RST $10
      LDB $6393       LD A,($6393)
      RORB            RRCA
      BCS L2d15       JP C,$2D15
      LDB $6392       LD A,($6392)
      RORB            RRCA
      BCC L2cb7       RET NC
      LDU #$6700      LD IX,$6700
      LDY #$0020      LD DE,$0020
      LDA #$0a        LD B,$0A
      STA REGB 
L2ca8 LDB ,U          LD A,(IX+$00)   2cb5
      RORB            RRCA
      BCS L2cb3       JP C,$2CB3
      RORB            RRCA
      BCC L2cb8       JP NC,$2CB8
L2cb3 LEAU $20,U      ADD IX,DE       2cac
      DEC REGB        DJNZ $2CA8
      BNE L2ca8
L2cb7 RTS             RET
L2cb8 STU $62aa       LD ($62AA),IX   2cb0
      LDA #$02        LD (IX+$00),$02
      STA ,U
;                     LD D,$00
      LDB #$0a        LD A,$0A
      SUBB REGB       SUB B
      ASLB            ADD A,A
      ASLB            ADD A,A
;                     LD E,A
      LDX #$6980      LD HL,$6980
      ABX             ADD HL,DE
      STX $62ac       LD ($62AC),HL
      LDB #$01        LD A,$01
      STB $6393       LD ($6393),A
      LDY #$0501      LD DE,$0501
      JSR L309f       CALL $309F
      LDX #$62b1      LD HL,$62B1
      DEC ,X          DEC (HL)
      BNE L2ce6       JP NZ,$2CE6
      LDB #$01        LD A,$01
      STB $6386       LD ($6386),A
L2ce6 LDB ,X          LD A,(HL)       2cde
      CMPB #$04       CP $04
      BCC L2cf6       JP NC,$2CF6
      LDX #$69a8      LD HL,$69A8
      ASLB            ADD A,A
      ASLB            ADD A,A
;                     LD E,A
;                     LD D,$00
      ABX             ADD HL,DE
      CLR ,X          LD (HL),D
L2cf6 LDD #$150b      LD (IX+$07),$15 2ce9 Sprite sideways barrel character #!
      STD 7,U         LD (IX+$08),$0B
      CLR $15,U       LD (IX+$15),$00
      LDB $6382       LD A,($6382)
      ROLB            RLCA
      BCC L2d15       JP NC,$2D15
      LDA #$19        LD (IX+$07),$19 Sprite sideways blue-barrel character #!
      STA 7,U
      LDA #$0c        LD (IX+$08),$0C set blue palette for barrel
      STA 8,U
      LDA #$01        LD (IX+$15),$01
      STA $15,U
L2d15 LDX #$62af      LD HL,$62AF     2d06 2c97
      DEC ,X          DEC (HL)
      BNE L2cb7       RET NZ
      LDA #$18        LD (HL),$18
      STA ,X
      LDB $638f       LD A,($638F)
;                     AND A
      BEQ L2d51       JP Z,$2D51
      STB REGC        LD C,A
      LDX #L3932      LD HL,$3932
      LDB $6382       LD A,($6382)
      RORB            RRCA
      BCS L2d2f       JP C,$2D2F
      DEC REGC        DEC C
L2d2f LDB REGC        LD A,C          2d2b
      ASLB            ADD A,A
      ASLB            ADD A,A
      ASLB            ADD A,A
      STB REGC        LD C,A
      ASLB            ADD A,A
      ASLB            ADD A,A
      ADDB REGC       ADD A,C
;                     LD E,A
;                     LD D,$00
      ABX             ADD HL,DE
      JSR L004e       CALL $004E
      LDX #$638f      LD HL,$638F
      DEC ,X          DEC (HL)
      BNE L2d51       JP NZ,$2D51
      LDB #$01        LD A,$01
      STB $62af       LD ($62AF),A
      LDB $6382       LD A,($6382)
      RORB            RRCA
      BCS L2d83       JP C,$2D83
L2d51 LDX $62a8       LD HL,($62A8)   2d42 2d20
L2d54 LDB ,X          LD A,(HL)       2d89
      LDU $62aa       LD IX,($62AA)
      LDY $62ac       LD DE,($62AC)
      CMPB #$7f       CP $7F
      BEQ L2d8c       JP Z,$2D8C
      STB REGC        LD C,A
      ANDB #$7f       AND $7F
      STB ,Y+         LD (DE),A       create sprite data - X coord
      LDB $7,U        LD A,(IX+$07)   read sprite character #
      LDA REGC        BIT 7,C
      BPL L2d70       JP Z,$2D70
      EORB #$03       XOR 03
;2d70                 INC DE          2d6b
L2d70 STB ,Y+         LD (DE),A       create sprite data - tile # (create barrel objects)
      STB $7,U        LD (IX+$07),A   write sprite character #
      LDB $8,U        LD A,(IX+$08)
;                     INC DE
      STB ,Y+         LD (DE),A
      LEAX 1,X        INC HL
      LDB ,X+         LD A,(HL)
;                     INC DE
      STB ,Y          LD (DE),A
;                     INC HL
      STX $62a8       LD ($62A8),HL
      RTS             RET
L2d83 LDX #L39cc      LD HL,$39CC     2d4e
      STX $62a8       LD ($62A8),HL
      BRA L2d54       JP $2D54
L2d8c LDX #L39c3      LD HL,$39C3     2d5f
      STX $62a8       LD ($62A8),HL
      LDA #$01        LD (IX+$01),$01
      STA 1,U
      LDB $6382       LD A,($6382)
      RORB            RRCA
      BCS L2da5       JP C,$2DA5
      CLR 1,U         LD (IX+$01),$00
      LDA #$02        LD (IX+$02),$02
      STA 2,U
L2da5 LDA #$01        LD (IX+$00),$01 2d9a
      STA ,U
      STA $f,U        LD (IX+$0F),$01
      CLRB            XOR A
      STB $10,U       LD (IX+$10),A
      STB $11,U       LD (IX+$11),A
      STB $12,U       LD (IX+$12),A
      STB $13,U       LD (IX+$13),A
      STB $14,U       LD (IX+$14),A
      STB $6393       LD ($6393),A
      STB $6392       LD ($6392),A
      LDB ,Y          LD A,(DE)
      STB $3,U        LD (IX+$03),A
      LEAY 3,Y        INC DE
;                     INC DE
;                     INC DE
      LDB ,Y          LD A,(DE)
      STB $5,U        LD (IX+$05),A
      LDX #L385c      LD HL,$385C
      JSR L004e       CALL $004E
      LDX #$690b      LD HL,$690B
      LDA #$fc        LD C,$FC
      STA REGC 
      JSR L0038       RST $38
      RTS             RET

L2ddb LDB #$0a        LD A,$0A        1995
      JSR L0030       RST $30
      JSR L0010       RST $10
      LDB $6380       LD A,($6380)
      INCB            INC A
;                     AND A
      LSRB            RRA
      STB REGB        LD B,A
      LDB $6227       LD A,($6227)    Level Type
      CMPB #$02       CP $02
      BNE L2dee       JR NZ,$2DEE
      INC REGB        INC B
L2dee LDB #$fe        LD A,$FE        2deb
      ORCC #$01       SCF
L2df1 RORB            RRA             2df3
      CLRA            AND A           clear carry
      DEC REGB        DJNZ $2DF1
      BNE L2df1
      STB REGB        LD B,A
      LDB $601a       LD A,($601A)
      ANDB REGB       AND B
      BNE L2e03       RET NZ
      LDB #$01        LD A,$01
      STB $63a0       LD ($63A0),A
      STB $639a       LD ($639A),A
L2e03 RTS             RET

;                                     Process/animate springs in level 3
;
L2e04 LDB #$04        LD A,$04        198f
      JSR L0030       RST $30
      JSR L0010       RST $10
;     STY REGDE       LD IY,$6980     Use Y=IY instead of Y=DE for this routine
      LDY #$6980
      LDU #$6500      LD IX,$6500
      LDA #$0a        LD B,$0A
      STA REGB 
L2e12 LDB ,U          LD A,(IX+$00)   2e81 are there active springs?
      RORB            RRCA
      BCC L2ea7       JP NC,$2EA7     no? skip processing
      LDB $601a       LD A,($601A)
      ANDB #$0f       AND $0F
      BNE L2e29       JP NZ,$2E29
      LDB $1,Y        LD A,(IY+$01)   animate spring characters in sprite data
      EORB #$07       XOR 07
      STB $1,Y        LD (IY+$01),A
L2e29 LDB $d,U        LD A,(IX+$0D)   2e1e
      CMPB #$04       CP $04
      BEQ L2e84       JP Z,$2E84
      INC $3,U        INC (IX+$03)
      INC $3,U        INC (IX+$03)
      LDB $e,U        LD L,(IX+$0E)   endian issue ok (load from spring bounce data)
      LDA $f,U        LD H,(IX+$0F)
      TFR D,X
      LDB ,X          LD A,(HL)
      STB REGC        LD C,A
      CMPB #$7f       CP $7F
      BEQ L2e9c       JP Z,$2E9C
      LEAX 1,X        INC HL
      ADDB $5,U       ADD A,(IX+$05)
      STB $5,U        LD (IX+$05),A
L2e4b TFR X,D         LD (IX+$0E),L   2ea4 endian issue ok
      STB $e,U
      STA $f,U        LD (IX+$0F),H
      LDB $3,U        LD A,(IX+$03)
      CMPB #$b7       CP $B7
      BCS L2e6c       JP C,$2E6C
      LDB REGC        LD A,C
      CMPB #$7f       CP $7F
      BNE L2e6c       JP NZ,$2E6C
      LDA #$04        LD (IX+$0D),$04
      STA $d,U
;                     XOR A
      CLR $6083       LD ($6083),A
      LDB #$03        LD A,$03
      STB $6084       LD ($6084),A
L2e6c LDB $3,U        LD A,(IX+$03)   2e99 2e8e 2e5c 2e56
      STB ,Y          LD (IY+$00),A   Transfer X coordinate to sprite data
      LDB $5,U        LD A,(IX+$05)
      STB $03,Y       LD (IY+$03),A   Transfer Y coordinate to sprite data
;2e78                 LD DE,$0010     2ed1 2eab
L2e78 LEAU $10,U      ADD IX,DE       next spring data
;                     LD E,$04
      LEAY $4,Y       ADD IY,DE       next sprite data
      DEC REGB        DJNZ $2E12
      BNE L2e12
      STY REGIY                       save contents of IY (unnecessary?)
      LDY #$0004                      unnecessary? (LD DE,$0004)
      RTS             RET
L2e84 LDB #$03        LD A,$03        2e2e
      ADDB $5,U       ADD A,(IX+$05)
      STB $5,U        LD (IX+$05),A
      CMPB #$f8       CP $F8
      BCS L2e6c       JP C,$2E6C
      CLR $3,U        LD (IX+$03),$00
      CLR ,U          LD (IX+$00),$00
      BRA L2e6c       JP $2E6C
L2e9c LDX #L39aa      LD HL,$39AA     2e41
      LDB #$03        LD A,$03
      STB $6083       LD ($6083),A
      BRA L2e4b       JP $2E4B
L2ea7 LDB $6396       LD A,($6396)    2e16
      RORB            RRCA
      BCC L2e78       JP NC,$2E78
      CLRB            XOR A
      STB $6396       LD ($6396),A
      LDD #$5001      LD (IX+$05),$50
      STA $5,U
      STB $d,U        LD (IX+$0D),$01
      JSR L0057       CALL $0057
      ANDB #$0f       AND $0F
      ADDB #$f8       ADD A,$F8
      STB $3,U        LD (IX+$03),A
      LDA #$01        LD (IX+$00),$01
      STA ,U
      LDX #L39aa      LD HL,$39AA
      TFR X,D         LD (IX+$0E),L   endian issue?
      STB $e,U
      STA $f,U        LD (IX+$0F),H
      BRA L2e78       JP $2E78        end of spring processing routine

L2ed4 LDB #$0b        LD A,$0B        1998
      JSR L0030       RST $30
      JSR L0010       RST $10
      LDY #$6a18      LD DE,$6A18     location of hammers in sprite ram
      LDU #$6680      LD IX,$6680     hammer character data
      LDB $1,U        LD A,(IX+$01)
      RORB            RRCA
      BCS L2eed       JP C,$2EED
      LDY #$6a1c      LD DE,$6A1C
      LDU #$6690      LD IX,$6690
L2eed LDD #$00f0      LD (IX+$0E),$00 2ee3
      STD $e,U        LD (IX+$0F),$F0
      LDB $6217       LD A,($6217)
      RORB            RRCA
      LBCC L2f97      JP NC,$2F97
      CLRB            XOR A
      STB $6218       LD ($6218),A
      LDX #$6089      LD HL,$6089
      LDA #$04        LD (HL),$04
      STA ,X
      LDD #$0603      LD (IX+$09),$06
      STD $9,U        LD (IX+$0A),$03
      LDA #$1e        LD B,$1E
      STA REGB 
      LDB $6207       LD A,($6207)    mario sprite character #
      ASLB            SLA A
      BCC L2f1b       JP NC,$2F1B
      ORB #$80        OR 80
      LDA REGB        SET 7,B
      ORA #$80
      STA REGB 
L2f1b ORB #$08        OR 08           2f14
      STB REGC        LD C,A
      LDB $6394       LD A,($6394)
      ANDB #8         BIT 3,A
      BEQ L2f43       JP Z,$2F43
      LDD REGBC       SET 0,B
      ORA #1
      ORB #1          SET 0,C
      STD REGBC 
      LDD #$0506      LD (IX+$09),$05
      STD $9,U        LD (IX+$0A),$06
      LDD #$f000      LD (IX+$0F),$00
      STD $e,U        LD (IX+$0E),$F0
      LDA REGC        BIT 7,C
      BPL L2f43       JP Z,$2F43
      LDA #$10        LD (IX+$0E),$10
      STA $e,U
L2f43 LDB REGC        LD A,C          2f3c 2f23
      STB $694d       LD ($694D),A
      clr REGC        LD C,$07        (coco hack to make hammer flash)
      LDX #$6394      LD HL,$6394
      INC ,X          INC (HL)
      BNE L2fb7       JP NZ,$2FB7
      LDX #$6395      LD HL,$6395
      INC ,X          INC (HL)
      LDB ,X          LD A,(HL)
      CMPB #$02       CP $02
      BNE L2fbe       JP NZ,$2FBE
      CLRB            XOR A
      STB $6395       LD ($6395),A
      STB $6217       LD ($6217),A
      STB $1,U        LD (IX+$01),A
      LDB $6203       LD A,($6203)    mario X position
      NEGB            NEG
      STB $e,U        LD (IX+$0E),A
      LDB $6207       LD A,($6207)    mario sprite character #
      STB $694d       LD ($694D),A
      CLR ,U          LD (IX+$00),$00
      LDB $6389       LD A,($6389)
      STB $6089       LD ($6089),A
L2f7c EXG Y,X         EX DE,HL        2fc8 2fc3 2fbb 2fb4
      LDB $6203       LD A,($6203)    set hammer X position
      ADDB $e,U       ADD A,(IX+$0E)
      STB ,X+         LD (HL),A
      STB $3,U        LD (IX+$03),A
;                     INC HL
;     LDD REGBC       LD (HL),B       set hammer character #
;     STD ,X++        INC HL
      lda REGB                        coco hack to make hammer flash
      adda REGC
      sta ,X++
;                     LD (HL),C       set hammer palette
;                     INC HL
      LDB $6205       LD A,($6205)    set hammer Y position
      ADDB $f,U       ADD A,(IX+$0F)
      STB ,X          LD (HL),A
      STB $5,U        LD (IX+$05),A
L2f96 RTS             RET
L2f97 LDB $6218       LD A,($6218)    2ef9
      RORB            RRCA
      BCC L2f96       RET NC
      LDD #$0603      LD (IX+$09),$06
      STD $9,U        LD (IX+$0A),$03
      LDB $6207       LD A,($6207)    mario sprite character #
      ROLB            RLCA
      LDB #$3c        LD A,$3C
      RORB            RRA
      STB REGB        LD B,A          set hammer character #?
      clr REGC        LD C,$07        coco hack to make hammer red
      LDB $6089       LD A,($6089)
      STB $6389       LD ($6389),A
      BRA L2f7c       JP $2F7C
L2fb7 LDB $6395       LD A,($6395)    2f4d
;                     AND A
      BEQ L2f7c       JP Z,$2F7C
L2fbe LDB $601a       LD A,($601A)    2f57
      ANDB #8         BIT 3,A
      BEQ L2f7c       JP Z,$2F7C
      lda #-2         LD C,$01        coco hack to make hammer flash yellow
      STA REGC 
      BRA L2f7c       JP $2F7C

L2fcb LDB #$0e        LD A,$0E        19bf
      JSR L0030       RST $30
      LDX #$62b4      LD HL,$62B4
      DEC ,X          DEC (HL)
      BNE L2fef       RET NZ
      LDB #$03        LD A,$03
      STB $62b9       LD ($62B9),A
      STB $6396       LD ($6396),A
      LDY #$0501      LD DE,$0501
      JSR L309f       CALL $309F
      LDB $62b3       LD A,($62B3)
      STB ,X          LD (HL),A
      LDX #$62b1      LD HL,$62B1
      DEC ,X          DEC (HL)
      BNE L2fef       RET NZ
      LDB #$01        LD A,$01
      STB $6386       LD ($6386),A
L2fef RTS             RET

L2ff0 TFR X,D         LD A,L          299a 2b9c 2aa2 2a3a 0de4 0db7
      LSRB            RRCA
      LSRB            RRCA
      LSRB            RRCA
;     ANDB #$1f       AND $1F
;                     LD L,A
;                     LD A,H
      COMA            CPL
      ANDA #$f8       AND $F8
      STA REGE        LD E,A
      CLRA            XOR A
      TFR D,X         LD H,A
      LDB REGE        RL E
      ROLB
      ROLA            RLA
      ROLB            RL E
      ROLA            RLA
      ADDA #$74       ADD A,$74
      TFR D,Y         LD D,A
      LEAX D,X        ADD HL,DE
      RTS             RET

L3009 STB REGD        LD D,A          23f4 1cba 1c9e 18df
      RORB            RRCA
      BCS L3022       JP C,$3022
      LDA #$93        LD C,$93
      STA REGC 
      RORB            RRCA
      RORB            RRCA
      BCC L3017       JP NC,$3017
      LDA #$6c        LD C,$6C
      STA REGC 
L3017 ROLB            RLCA            3012
      BCS L3031       JP C,$3031
      LDB REGC        LD A,C
      ANDB #$f0       AND $F0
      STB REGC        LD C,A
      BRA L3031       JP $3031
L3022 LDA #$b4        LD C,$B4        300b
      STA REGC 
      RORB            RRCA
      RORB            RRCA
      BCC L302b       JP NC,$302B
      LDA #$1e        LD C,$1E
      STA REGC 
L302b LDA REGB        BIT 2,B         3026
      ANDA #4
      BEQ L3031       JP Z,$3031
      DEC REGB        DEC B
L3031 LDB REGC        LD A,C          3038 302d 301f 3018
      TFR B,A         RRCA
      RORA
      RORB
      RORA            RRCA
      RORB
      STB REGC        LD C,A
      ANDB #$03       AND $03
      CMPB REGB       CP B
      BNE L3031       JP NZ,$3031
      LDB REGC        LD A,C
      RORB            RRCA
      RORB            RRCA
      ANDB #$03       AND $03
      CMPB #$03       CP $03
      BNE L3049       RET NZ
      LDA REGD        RES 2,D
      ANDA #251
      DECA            DEC D           note!!! D/Y is not saved
      BNE L304X       RET NZ
      LDB #$04        LD A,$04
L3049 RTS             RET
L304X LDB #$03
      RTS

L304a LDY #$ffe0      LD DE,$FFE0     unnecessary? 0b38 0af0
      LDB $638e       LD A,($638E)
      CLRA            LD B,$00
      STD REGBC       LD C,A          unnecessary?
      LDX #$7600      LD HL,$7600
      BSR L3064       CALL $3064
      LDB REGC 
      LDX #$75c0      LD HL,$75C0
      BSR L3064       CALL $3064
      LDX #$638e      LD HL,$638E
      DEC ,X          DEC (HL)
      RTS             RET

L3064 LEAX D,X        ADD HL,BC       305c 3056
      LDB ,X          LD A,(HL)
;                     ADD HL,DE
      STB -32,X       LD (HL),A
      RTS             RET

L3069 JSR L0018       RST $18
      LDX $63c0       LD HL,($63C0)
      INC ,X          INC (HL)
      RTS             RET

L306f LDX #$62af      LD HL,$62AF     1757 1732 0ae8
      INC ,X          INC (HL)
      LDB ,X          LD A,(HL)
      ANDB #$07       AND $07
      BNE L3095       RET NZ
      LDX #$690b      LD HL,$690B
      LDA #$fc        LD C,$FC
      STA REGC 
      JSR L0038       RST $38
      LDA #$81        LD C,$81
      STA REGC 
      LDX #$6909      LD HL,$6909
      BSR L3096       CALL $3096
      LDX #$691d      LD HL,$691D
      BSR L3096       CALL $3096
      JSR L0057       CALL $0057
      ANDB #$80       AND $80
      LDX #$692d      LD HL,$692D
      EORB ,X         XOR (HL)
      STB ,X          LD (HL),A
L3095 RTS             RET

L3096 LDA #$02        LD B,$02        3088 3082
      STA REGB 
L3098 LDB REGC        LD A,C          309c
      EORB ,X         XOR (HL)
      STB ,X          LD (HL),A
      STB REGA        ADD HL,DE
      TFR Y,D
      LEAX D,X
      LDB REGA 
      DEC REGB        DJNZ $3098
      BNE L3098
      RTS             RET

L309f PSHS X          PUSH HL         1e28 2fde 2cd7 1e15 1958 17a6 15f6 15ed 146e 136d 1367 1328 131e 1278 0c9c 0c85 0be7 0a4c 0a46 0a40 0a3a 0a2b 0a25 09e6 09e0 0982 0970 0968 0951 0932 08c4 0813 080f 0788 0784 0203 01fd 01f7 01b6 J
      LDA #$60        LD HL,$60C0
      LDB $60b0       LD A,($60B0)
      TFR D,X         LD L,A
      LDA ,X          BIT 7,(HL)
      BPL L30bb       JP Z,$30BB
      STY ,X++        LD (HL),D
;                     INC L
;                     LD (HL),E
;                     INC L
      TFR X,D         LD A,L
      CMPB #$c0       CP $C0
      BCC L30b8       JP NC,$30B8
      LDB #$c0        LD A,$C0
L30b8 STB $60b0       LD ($60B0),A    30b3
L30bb PULS X,PC       POP HL          30a9
;                     RET

L30bd LDX #$6950      LD HL,$6950     1615 12a3
      LDA #$02        LD B,$02
      BSR L30e4       CALL $30E4
      LDX #$6980      LD L,$80
      LDA #$0a        LD B,$0A
      BSR L30e4       CALL $30E4
      LDX #$69b8      LD L,$B8
      LDA #$0b        LD B,$0B
      BSR L30e4       CALL $30E4
      LDX #$6a0c      LD HL,$6A0C
      LDA #$05        LD B,$05
      BRA L30e4       JP $30E4

L30db LDX #$694c      LD HL,$694C     12df
      CLR ,X          LD (HL),$00
      LDX #$6958      LD L,$58
      LDA #$06        LD B,$06

;30e4                 LD A,L          30d8 30d0 30c9 30c2
L30e4 CLR ,X          LD (HL),$00     30ea
      LEAX 4,X        ADD A,$04
;                     LD L,A
      DECA            DJNZ $30E5
      BNE L30e4
      RTS             RET

; Process Fireballs
;
L30ed BSR L30fa       CALL $30FA      198c dunno...
      BSR L313c       CALL $313C      spawn fireballs???
      JSR L31b1       CALL $31B1      process fireball AI???
      JSR L34f3       CALL $34F3      add fireballs to sprite display
      RTS             RET

L30fa LDB $6380       LD A,($6380)    30ed
      CMPB #$06       CP $06
      BCS L3103       JR C,$3103
      LDB #$05        LD A,$05
L3103 JSR L0028       RST $28         30ff
;                                     JUMP TABLE
      FDB L3110
      FDB L3110
      FDB L311b
      FDB L3126
      FDB L3126
      FDB L3131

L3110 LDB $601a       LD A,($601A)
      ANDB #$01       AND $01
      CMPB #$01       CP $01
      BEQ L311a       RET Z
      LEAS 2,S        INC SP
;                     INC SP
L311a RTS             RET

L311b LDB $601a       LD A,($601A)
      ANDB #$07       AND $07
      CMPB #$05       CP $05
      BMI L3125       RET M
      LEAS 2,S        INC SP
;                     INC SP
L3125 RTS             RET

L3126 LDB $601a       LD A,($601A)
      ANDB #$03       AND $03
      CMPB #$03       CP $03
      BMI L3130       RET M
      LEAS 2,S        INC SP
;                     INC SP
L3130 RTS             RET

L3131 LDB $601a       LD A,($601A)
      ANDB #$07       AND $07
      CMPB #$07       CP $07
      BMI L313b       RET M
      LEAS 2,S        INC SP
;                     INC SP
L313b RTS             RET

L313c LDU #$6400      LD IX,$6400     30f0 fireball character data
      CLRB            XOR A
      STB $63a1       LD ($63A1),A
      LDA #$05        LD B,$05
      STA REGB 
;     LDY #$0020      LD DE,$0020     unnecessary?
L3149 LDB ,U          LD A,(IX+$00)   316c
;                     CP $00
      BEQ L317c       JP Z,$317C
      LDB $63a1       LD A,($63A1)
      INCB            INC A
      STB $63a1       LD ($63A1),A
;     LDB #$01        LD A,$01        set fireballs blue!
;     STB $8,U        LD (IX+$08),A
      LDB $6217       LD A,($6217)
      CMPB #$01       CP $01
      BNE L316x       JP NZ,$316A
;     CLRB            LD A,$00        set fireballs red!
;     STB $8,U        LD (IX+$08),A
      ldb 7,U                         coco hack - swap character # instead
      andb #$70
      cmpb #$40
      bhi L316a
      ldb 7,U
      addb #$20
      stb 7,U
      bra L316a
L316x ldb 7,U                         coco hack - swap character # instead
      andb #$70
      cmpb #$50
      blo L316a
      ldb 7,U
      subb #$20
      stb 7,U
L316a LEAU $20,U      ADD IX,DE       31ae 319a 3181 3162
      DEC REGB        DJNZ $3149
      BNE L3149
      LDX #$63a0      LD HL,$63A0
      CLR ,X          LD (HL),$00
      LDB $63a1       LD A,($63A1)
;                     CP $00
      BNE L317b       RET NZ
      LEAS 2,S        INC SP
;                     INC SP
L317b RTS             RET
L317c LDB $63a1       LD A,($63A1)    314e
      CMPB #$05       CP $05
      BEQ L316a       JP Z,$316A
      LDB $6227       LD A,($6227)    Level Type
      CMPB #$02       CP $02
      BNE L3195       JP NZ,$3195     Just spawn fireball if not cement level
      LDB $63a1       LD A,($63A1)    test timers on cement level?
      STB REGC        LD C,A
      LDB $6380       LD A,($6380)
      CMPB REGC       CP C
      BEQ L317b       RET Z           Are they different?
L3195 LDB $63a0       LD A,($63A0)    3189 SPAWN A FIREBALL!
      CMPB #$01       CP $01
      BNE L316a       JP NZ,$316A
      STB ,U          LD (IX+$00),A
      STB $18,U       LD (IX+$18),A
      CLRB            XOR A
      STB $63a0       LD ($63A0),A
      LDB $63a1       LD A,($63A1)
      INCB            INC A
      STB $63a1       LD ($63A1),A
      BRA L316a       JP $316A

L31b1 BSR L31dd       CALL $31DD      30f3
      CLRB            XOR A
      STB $63a2       LD ($63A2),A
      LDX #$63e0      LD HL,$63E0
      STX $63c8       LD ($63C8),HL
L31be LDX $63c8       LD HL,($63C8)   31d9
;                     LD BC,$0020     unnecessary?
      LEAX $20,X      ADD HL,BC
      STX $63c8       LD ($63C8),HL
      LDB ,X          LD A,(HL)
;                     AND A
      BEQ L31d0       JP Z,$31D0
      BSR L3202       CALL $3202
L31d0 LDB $63a2       LD A,($63A2)    31ca
      INCB            INC A
      STB $63a2       LD ($63A2),A
      CMPB #$05       CP $05
      BNE L31be       JP NZ,$31BE
      RTS             RET

L31dd LDB $6380       LD A,($6380)    31b1
      CMPB #$03       CP $03
      BMI L31f5       RET M
      BSR L31f6       CALL $31F6
      CMPB #$01       CP $01
      BNE L31f5       RET NZ
      LDX #$6439      LD HL,$6439
      LDB #$02        LD A,$02
      STB ,X          LD (HL),A
      LDX #$6479      LD HL,$6479
      LDB #$02        LD A,$02
      STB ,X          LD (HL),A
L31f5 RTS             RET

L31f6 LDB $6018       LD A,($6018)    31e3
      ANDB #$03       AND $03
      CMPB #$01       CP $01
      BNE L31f5       RET NZ
      LDB $601a       LD A,($601A)
      RTS             RET

L3202 LDU $63c8       LD IX,($63C8)   31cd
      LDB $18,U       LD A,(IX+$18)
      CMPB #$01       CP $01
      BEQ L327a       JP Z,$327A
      LDB $d,U        LD A,(IX+$0D)
      CMPB #$04       CP $04
      BPL L3230       JP P,$3230
      LDB $19,U       LD A,(IX+$19)
      CMPB #$02       CP $02
      BEQ L327e       JP Z,$327E
      JSR L330f       CALL $330F
      LDB $6018       LD A,($6018)
      ANDB #$03       AND $03
      BNE L3233       JP NZ,$3233
L3229 LDB $d,U        LD A,(IX+$0D)   3281
;                     AND A
      BEQ L3257       JP Z,$3257
L3230 JSR L333d       CALL $333D      3213
L3233 LDB $d,U        LD A,(IX+$0D)   3226
      CMPB #$04       CP $04
      BPL L3291       JP P,$3291
      JSR L33ad       CALL $33AD
      JSR L298c       CALL $298C
      CMPB #$01       CP $01
      BEQ L3297       JP Z,$3297
      LDU $63c8       LD IX,($63C8)
      LDB $e,U        LD A,(IX+$0E)
      CMPB #$10       CP $10
      BCS L328c       JP C,$328C
      CMPB #$f0       CP $F0
      BCC L3284       JP NC,$3284
L3257 LDB $13,U       LD A,(IX+$13)   32ae 3294 3289 322d
;                     CP $00
      BNE L32b9       JP NZ,$32B9
      LDB #$11        LD A,$11
L3261 STB $13,U       LD (IX+$13),A   32ba
;     CLRA            LD D,$00        unnecessary?
;     TFR D,Y         LD E,A          unnecessary?
      LDX #L3a7a      LD HL,$3A7A
      ABX             ADD HL,DE
      LDB ,X          LD A,(HL)
      LDA $e,U        LD B,(IX+$0E)
      STA REGB 
      STA $3,U        LD (IX+$03),B
      LDA $f,U        LD C,(IX+$0F)
      STA REGC 
      ADDB REGC       ADD A,C
      STB $5,U        LD (IX+$05),A
      RTS             RET
L327a BSR L32bd       CALL $32BD      320b
      RTS             RET
L327e BSR L32d6       CALL $32D6      321b
      BRA L3229       JP $3229
L3284 LDB #$02        LD A,$02        3254
L3286 STB $d,U        LD (IX+$0D),A   328e
      BRA L3257       JP $3257
L328c LDB #$01        LD A,$01        324f
      BRA L3286       JP $3286
L3291 JSR L33e7       CALL $33E7      3238
      BRA L3257       JP $3257
L3297 LDU $63c8       LD IX,($63C8)   3243
      LDB $d,U        LD A,(IX+$0D)
      CMPB #$01       CP $01
      BNE L32b1       JP NZ,$32B1
      LDB #$02        LD A,$02
      DEC $e,U        DEC (IX+$0E)
L32a8 STB $d,U        LD (IX+$0D),A   32b6
      JSR L33c3       CALL $33C3
      BRA L3257       JP $3257
L32b1 LDB #$01        LD A,$01        32a0
      INC $e,U        INC (IX+$0E)
      BRA L32a8       JP $32A8
L32b9 DECB            DEC A           325c
      BRA L3261       JP $3261

L32bd LDB $6227       LD A,($6227)    327a Level Type
      CMPB #$01       CP $01
      BEQ L32ce       JP Z,$32CE
      CMPB #$02       CP $02
      BEQ L32d2       JP Z,$32D2
      JSR L34b9       CALL $34B9
      RTS             RET
L32ce JSR L342c       CALL $342C      32c2
      RTS             RET
L32d2 JSR L3478       CALL $3478      32c7
      RTS             RET

L32d6 LDB $1c,U       LD A,(IX+$1C)   327e
;                     CP $00
      BNE L32fd       JP NZ,$32FD
      LDB $1d,U       LD A,(IX+$1D)
      CMPB #$01       CP $01
      BNE L330b       JP NZ,$330B
      CLR $1d,U       LD (IX+$1D),$00
      LDB $6205       LD A,($6205)    mario Y position
      LDA $f,U        LD B,(IX+$0F)
      STA REGB 
      SUBB REGB       SUB B
      BCS L3303       JP C,$3303
      LDA #$ff        LD (IX+$1C),$FF
      STA $1c,U
L32f8 CLR $d,U        LD (IX+$0D),$00 3300
      RTS             RET
L32fd DEC $1c,U       DEC (IX+$1C)    32db
      BNE L32f8       JP NZ,$32F8
L3303 CLR $19,U       LD (IX+$19),$00 32f1
      CLR $1c,U       LD (IX+$1C),$00
L330b BSR L330f       CALL $330F      32e3
      RTS             RET

L330f LDB $16,U       LD A,(IX+$16)   330b 321e
;                     CP $00
      BNE L3332       JP NZ,$3332
      LDA #$2b        LD (IX+$16),$2B
      STA $16,U
      CLR $d,U        LD (IX+$0D),$00
      LDB $6018       LD A,($6018)
      RORB            RRCA
      BCC L3332       JP NC,$3332
      LDB $d,U        LD A,(IX+$0D)
      CMPB #$01       CP $01
      BEQ L3336       JP Z,$3336
      LDA #$01        LD (IX+$0D),$01
      STA $d,U
L3332 DEC $16,U       DEC (IX+$16)    333a 3323 3314
      RTS             RET
L3336 LDA #$02        LD (IX+$0D),$02 332b
      STA $d,U
      BRA L3332       JP $3332

L333d LDB $d,U        LD A,(IX+$0D)   3230
      CMPB #$08       CP $08
      BEQ L3371       JP Z,$3371
      CMPB #$04       CP $04
      BEQ L338a       JP Z,$338A
      BSR L33a1       CALL $33A1
      LDB $f,U        LD A,(IX+$0F)
      ADDB #$08       ADD A,$08
      STY REGDE       LD D,A
      STB REGD 
      LDB $e,U        LD A,(IX+$0E)
      LDX #$0015      LD BC,$0015
      STX REGBC 
      JSR L236e       CALL $236E
      TSTB            AND A
      BEQ L3399       JP Z,$3399
      LDA REGB        LD (IX+$1F),B
      STA $1f,U
      LDB $6205       LD A,($6205)    mario Y position
      STB REGB        LD B,A
      LDB $f,U        LD A,(IX+$0F)
      SUBB REGB       SUB B
      BCC L33a0       RET NC
      LDA #$04        LD (IX+$0D),$04
      STA $d,U
      RTS             RET
L3371 LDB $f,U        LD A,(IX+$0F)   3342
      ADDB #$08       ADD A,$08
      LDA $1f,U       LD B,(IX+$1F)
      STA REGB 
      CMPB REGB       CP B
      BNE L33a0       RET NZ
      CLR $d,U        LD (IX+$0D),$00
      LDB $19,U       LD A,(IX+$19)
      CMPB #$02       CP $02
      BNE L33a0       RET NZ
      LDA #$01        LD (IX+$1D),$01
      STA $1d,U
      RTS             RET
L338a LDB $f,U        LD A,(IX+$0F)   3347
      ADDB #$08       ADD A,$08
      LDA $1f,U       LD B,(IX+$1F)
      STA REGB 
      CMPB REGB       CP B
      BNE L33a0       RET NZ
      CLR $d,U        LD (IX+$0D),$00
      RTS             RET
L3399 LDA REGB        LD (IX+$1F),B   335d
      STA $1f,U
      LDA #$08        LD (IX+$0D),$08
      STA $d,U 
L33a0 RTS             RET

L33a1 LDB #$07        LD A,$07        334a
      JSR L0030       RST $30
      LDB $f,U        LD A,(IX+$0F)
      CMPB #$59       CP $59
      BCC L33a0       RET NC
      LEAS 2,S        INC SP
;                     INC SP
      RTS             RET

L33ad LDB $d,U        LD A,(IX+$0D)   323b
      CMPB #$01       CP $01
      BEQ L33d9       JP Z,$33D9
      LDB $7,U        LD A,(IX+$07)   sprite character #
      ANDB #$7f       AND $7F         unset H-flip
      STB $7,U        LD (IX+$07),A   sprite character #
      DEC $e,U        DEC (IX+$0E)
L33c0 BSR L3409       CALL $3409      33e4

L33c3 LDB $6227       LD A,($6227)    32ab Level Type
      CMPB #$01       CP $01
      BNE L33d8       RET NZ
      LDX $e,U        LD H,(IX+$0E)
;                     LD L,(IX+$0F)
      LDA $d,U        LD B,(IX+$0D)
      STA REGB 
      JSR L2333       CALL $2333
      LDA REGL        LD (IX+$0F),L
      STA $f,U 
L33d8 RTS             RET
L33d9 LDB $7,U        LD A,(IX+$07)   33b2 sprite character #
      ORB #$80        OR 80           set H-flip
      STB $7,U        LD (IX+$07),A   sprite character #
      INC $e,U        INC (IX+$0E)
      BRA L33c0       JP $33C0

L33e7 BSR L3409       CALL $3409      3291
      LDB $d,U        LD A,(IX+$0D)
      CMPB #$08       CP $08
      BNE L3405       JP NZ,$3405
      LDB $14,U       LD A,(IX+$14)
;                     AND A
      BNE L3401       JP NZ,$3401
      LDA #$02        LD (IX+$14),$02
      STA $14,U
      DEC $f,U        DEC (IX+$0F)
      RTS             RET
L3401 DEC $14,U       DEC (IX+$14)    33f6
      RTS             RET
L3405 INC $f,U        INC (IX+$0F)    33ef
      RTS             RET

L3409 LDB $15,U       LD A,(IX+$15)   33e7 33c0
;                     AND A
      BNE L3428       JP NZ,$3428
      LDA #$02        LD (IX+$15),$02
      STA $15,U
      INC $7,U        INC (IX+$07)    increment fireball animation frame
      LDB $7,U        LD A,(IX+$07)
      ANDB #$0f       AND $0F
      CMPB #$0f       CP $0F          check for fireball animation looping??
      BNE L342b       RET NZ
      LDB $7,U        LD A,(IX+$07)   sprite character #
      EORB #$02       XOR 02          reset/restart sprite animation
      STB $7,U        LD (IX+$07),A   set sprite character #
      RTS             RET
L3428 DEC $15,U       DEC (IX+$15)    340d
L342b RTS             RET

L342c LDB $1a,U       LD L,(IX+$1A)   32ce endian issue?
      LDA $1b,U       LD H,(IX+$1B)
      TFR D,X
;                     XOR A           clear carry
;                     LD BC,$0000     unnecessary?
      CMPX #0000      ADC HL,BC
      BNE L3442       JP NZ,$3442
      LDX #L3a8c      LD HL,$3A8C
      LDA #$26        LD (IX+$03),$26
      STA $3,U
L3442 INC $3,U        INC (IX+$03)    3438

L3445 LDB ,X          LD A,(HL)       34b6 34a5
      CMPB #$aa       CP $AA
      BEQ L3456       JP Z,$3456
      STB $5,U        LD (IX+$05),A
      LEAX 1,X        INC HL
      TFR X,D         LD (IX+$1A),L   endian issue?
      STB $1a,U
      STA $1b,U       LD (IX+$1B),H
      RTS             RET
L3456 CLRB            XOR A           3448
      STB $13,U       LD (IX+$13),A
      STB $18,U       LD (IX+$18),A
      STB $d,U        LD (IX+$0D),A
      STB $1c,U       LD (IX+$1C),A
      LDB $3,U        LD A,(IX+$03)
      STB $e,U        LD (IX+$0E),A
      LDB $5,U        LD A,(IX+$05)
      STB $f,U        LD (IX+$0F),A
      CLR $1a,U       LD (IX+$1A),$00
      CLR $1b,U       LD (IX+$1B),$00
      RTS             RET

L3478 LDB $1a,U       LD L,(IX+$1A)   32d2 endian issue?
      LDA $1b,U       LD H,(IX+$1B)
      TFR D,X
;                     XOR A           clear carry
;                     LD BC,$0000     unnecessary?
      CMPX #$0000     ADC HL,BC       this is just to test if HL is zero???
      BNE L349a       JP NZ,$349A
      LDX #L3aac      LD HL,$3AAC
      LDB $6203       LD A,($6203)    mario X position
;                     BIT 7,A
      BPL L34a8       JP Z,$34A8
      LDD #$017e      LD (IX+$0D),$01
      STA $d,U
      STB $3,U        LD (IX+$03),$7E
L349a LDB $d,U        LD A,(IX+$0D)   34b0 3484
      CMPB #$01       CP $01
      BNE L34b3       JP NZ,$34B3
      INC $3,U        INC (IX+$03)
      BRA L3445       JP $3445
L34a8 LDD #$0280      LD (IX+$0D),$02 348f
      STA $d,U
      STB $3,U        LD (IX+$03),$80
      BRA L349a       JP $349A
L34b3 DEC $3,U        DEC (IX+$03)    349f
      BRA L3445       JP $3445

L34b9 LDB $6227       LD A,($6227)    32ca Level Type
      CMPB #$03       CP $03
      BEQ L34ec       RET Z
      LDB $6203       LD A,($6203)    mario X position
;                     BIT 7,A
      BMI L34ed       JP NZ,$34ED
      LDX #L3ac4      LD HL,$3AC4
L34ca CLR REGB        LD B,$00        34f0
      LDB $6019       LD A,($6019)
      ANDB #$06       AND $06
;     STB REGC        LD C,A          unnecessary?
      ABX             ADD HL,BC
      LDB ,X+         LD A,(HL)
      STB $3,U        LD (IX+$03),A
      STB $e,U        LD (IX+$0E),A
;                     INC HL
      LDB ,X          LD A,(HL)
      STB $5,U        LD (IX+$05),A
      STB $f,U        LD (IX+$0F),A
      CLRB            XOR A
      STB $d,U        LD (IX+$0D),A
      STB $18,U       LD (IX+$18),A
      STB $1c,U       LD (IX+$1C),A
L34ec RTS             RET
L34ed LDX #L3ad4      LD HL,$3AD4     34c4
      BRA L34ca       JP $34CA

;                                     add fireballs to sprite display list
;
L34f3 LDX #$6400      LD HL,$6400     30f6 fireball character data
      LDY #$69d0      LD DE,$69D0     fireball area in sprite ram
      LDA #$05        LD B,$05        5 fireballs max
L34fb LDB ,X          LD A,(HL)       351b
;                     AND A
      BEQ L3517       JP Z,$351E
;                     INC L
;                     INC L
;                     INC L
      LDB 3,X         LD A,(HL)       fireball X coordinate
      andb #$fe                       coco hack to speed up sprites
      STB ,Y          LD (DE),A
;                     LD A,$04
;                     ADD A,L
;                     LD L,A
;                     INC E
      LDB 7,X         LD A,(HL)       fireball sprite character #
      STB 1,Y         LD (DE),A
;                     INC L
;                     INC E
;      LDB 8,X         LD A,(HL)      fireball palette #
;      STB 2,Y         LD (DE),A
;                     DEC L
;                     DEC L
;                     DEC L
;                     INC E
      LDB 5,X         LD A,(HL)       fireball Y coordinate
      STB 3,Y         LD (DE),A
;                     INC DE
L3517 LEAY 4,Y        LD A,$1B        3526
      LEAX $20,X      ADD A,L
;                     LD L,A
      DECA            DJNZ $34FB
      BNE L34fb
      RTS             RET
;                     LD A,$05        34fd
;                     ADD A,L
;                     LD L,A
;                     LD A,$04
;                     ADD A,E
;                     LD E,A
;                     JP $3517

L3529 FCB $00,$00,$00                 0 points
      FCB $00,$01,$00                 100 points
      FCB $00,$02,$00                 200 points
      FCB $00,$03,$00                 300 points
      FCB $00,$04,$00                 400 points
      FCB $00,$05,$00                 500 points
      FCB $00,$06,$00                 600 points
      FCB $00,$07,$00                 700 points
      FCB $00,$08,$00                 800 points
      FCB $00,$09,$00                 900 points
      FCB $00,$00,$00                 0 points
      FCB $00,$10,$00                 1000 points
      FCB $00,$20,$00                 2000 points
      FCB $00,$30,$00                 3000 points
      FCB $00,$40,$00                 4000 points
      FCB $00,$50,$00                 5000 points
      FCB $00,$60,$00                 6000 points
      FCB $00,$70,$00                 7000 points
      FCB $00,$80,$00                 8000 points
      FCB $00,$90,$00                 9000 points

;                                     High Score table & other boot data (endian issues???)
L3565 FDB $7794
;           1   S   T           0   0   7   6   5   0
      FCB $01,$23,$24,$10,$10,$00,$00,$07,$06,$05,$00,$10,$10,$10,$10,$10
      FCB $10,$10,$10,$10,$10,$10,$10,$10,$10,$3f,$00,$50,$76,$00
      FDB $76f4
      FDB $7796
      FCB $02,$1e,$14,$10,$10,$00,$00,$06,$01,$00,$00,$10,$10,$10,$10,$10
      FCB $10,$10,$10,$10,$10,$10,$10,$10,$10,$3f,$00,$00,$61,$00
      FDB $76f6
      FDB $7798
      FCB $03,$22,$14,$10,$10,$00,$00,$05,$09,$05,$00,$10,$10,$10,$10,$10
      FCB $10,$10,$10,$10,$10,$10,$10,$10,$10,$3f,$00,$50,$59,$00
      FDB $76f8
      FDB $779a
      FCB $04,$24,$18,$10,$10,$00,$00,$05,$00,$05,$00,$10,$10,$10,$10,$10
      FCB $10,$10,$10,$10,$10,$10,$10,$10,$10,$3f,$00,$50,$50,$00
      FDB $76fa
      FDB $779c
      FCB $05,$24,$18,$10,$10,$00,$00,$04,$03,$00,$00,$10,$10,$10,$10,$10
      FCB $10,$10,$10,$10,$10,$10,$10,$10,$10,$3f,$00,$00,$43,$00
      FDB $76fc

;                                     Letter coordinates in initials entry
L360f FCB $3b,$5d,$4b,$5d,$5b,$5d,$6b,$5d,$7b,$5d,$8b,$5d,$9b,$5d,$ab,$5d
      FCB $bb,$5d,$cb,$5d,$3b,$6d,$4b,$6d,$5b,$6d,$6b,$6d,$7b,$6d,$8b,$6d
      FCB $9b,$6d,$ab,$6d,$bb,$6d,$cb,$6d,$3b,$7d,$4b,$7d,$5b,$7d,$6b,$7d
      FCB $7b,$7d,$8b,$7d,$9b,$7d,$ab,$7d,$bb,$7d,$cb,$7d

;                                     Text Messages
L364b FDB L368b,$0001,L3698,L36a5,L36b2,L36bf,$0006,L36cc
      FDB $0008,L36e6,L36fd,$000b,L3715,L371c,L3730,L3738
      FDB L3747,L375d,L3773,L378b,$6100,$6122,$6144,$6166
; if original release version...
      FDB $6188,L379e,L37b6,L37d2,L37e1,$001d,L37f4,L3806
; if alternate release version...
;      FDB $6188,L379e,L37b6,L37d2,L37e1,$001d,L3f00,L3f09    ;alternate copyright text
L368b FDB $7696
      FCB $17,$11,$1d,$15,$10,$10,$1f,$26,$15,$22,$3f
L3698 FDB $7694
      FCB $20,$1c,$11,$29,$15,$22,$10,$30,$32,$31,$3f
L36a5 FDB $7694
      FCB $20,$1c,$11,$29,$15,$22,$10,$30,$33,$31,$3f
L36b2 FDB $7680
      FCB $18,$19,$17,$18,$10,$23,$13,$1f,$22,$15,$3f
L36bf FDB $759f
      FCB $13,$22,$15,$14,$19,$24,$10,$10,$10,$10,$3f
L36cc FDB $775e
      FCB $18,$1f,$27,$10,$18,$19,$17,$18,$10,$13,$11,$1e,$10,$29,$1f,$25
      FCB $10,$17,$15,$24,$10,$fb,$10,$3f
L36e6 FDB $7729
      FCB $1f,$1e,$1c,$29,$10,$01,$10,$20,$1c,$11,$29,$15,$22,$10,$12,$25
      FCB $24,$24,$1f,$1e,$3f
L36fd FDB $7729
      FCB $01,$10,$1f,$22,$10,$02,$10,$20,$1c,$11,$29,$15,$22,$23,$10,$12
      FCB $25,$24,$24,$1f,$1e,$3f 
L3715 FDB $7627
      FCB $20,$25,$23,$18,$3f
;name registration
L371c FDB $7706
      FCB $1e,$11,$1d,$15,$10,$22,$15,$17,$19,$23,$24,$22,$11,$24,$19,$1f
      FCB $1e,$3f
L3730 FDB $7688
      FCB $1e,$11,$1d,$15,$2e,$3f
L3738 FDB $75e9
      FCB $2d,$2d,$2d,$10,$10,$10,$10,$10,$10,$10,$10,$10,$3f
L3747 FDB $770b
      FCB $11,$10,$12,$10,$13,$10,$14,$10,$15,$10,$16,$10,$17,$10,$18,$10
      FCB $19,$10,$1a,$3f
L375d FDB $770d
      FCB $1b,$10,$1c,$10,$1d,$10,$1e,$10,$1f,$10,$20,$10,$21,$10,$22,$10
      FCB $23,$10,$24,$3f
L3773 FDB $770f
      FCB $25,$10,$26,$10,$27,$10,$28,$10,$29,$10,$2a,$10,$2b,$10,$2c,$44
      FCB $45,$46,$47,$48,$10,$3f
L378b FDB $76f2
      FCB $22,$15,$17,$19,$10,$24,$19,$1d,$15,$10,$10,$30,$03,$00,$31,$10
      FCB $3f
L379e FDB $7792
      FCB $22,$11,$1e,$1b,$10,$10,$23,$13,$1f,$22,$15,$10,$10,$1e,$11,$1d
      FCB $15,$10,$10,$10,$10,$3f
L37b6 FDB $7772
      FCB $29,$1f,$25,$22,$10,$1e,$11,$1d,$15,$10,$27,$11,$23,$10,$22,$15
      FCB $17,$19,$23,$24,$15,$22,$15,$14,$42,$3f
L37d2 FDB $76a7
      FCB $19,$1e,$23,$15,$22,$24,$10,$13,$1f,$19,$1e,$10,$3f
L37e1 FDB $770a
      FCB $10,$10,$20,$1c,$11,$29,$15,$22,$10,$10,$10,$10,$13,$1f,$19,$1e
      FCB $3f
;(c) NINTENDO 1981
L37f4 FDB $76fc 
      FCB $49,$4a,$10,$1e,$19,$1e,$24,$15,$1e,$14,$1f,$3f
L3806 FDB $757c
      FCB $01,$09,$08,$01,$3f

;check for endian issues?
;                                     Draw data for climb screen
L380d FCB $02,$97,$38,$68,$38,$02,$df,$54,$10,$54,$02,$ef,$6d,$20,$6d,$02
      FCB $df,$8e,$10,$8e,$02,$ef,$af,$20,$af,$02,$df,$d0,$10,$d0,$02,$ef
      FCB $f1,$10,$f1,$00,$53,$18,$53,$54,$00,$63,$18,$63,$54,$00,$93,$38
      FCB $93,$54,$00,$83,$54,$83,$f1,$00,$93,$54,$93,$f1,$aa

;                                     BONUS graphic tiles
L384a FCB $8d,$7d,$8c,$6f,$00,$7c,$6e,$00,$7c,$6d,$00,$7c,$6c,$00,$7c,$8f
      FCB $7f,$8e 
;                                     DK climbing sprites
L388c FCB $50,$34,$08,$3c,$00,$35,$08,$3c,$53,$32,$08,$40,$63,$33,$08,$40
      FCB $00,$70,$08,$48,$53,$36,$08,$50,$63,$37,$08,$50,$6b,$31,$08,$41
      FCB $00,$70,$08,$48,$6a,$14,$0a,$48 
;                                     DK intro jump up data
L38b4 FCB $fd,$fd,$fd,$fd,$fd,$fd,$fd,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$ff
      FCB $ff,$00,$00,$01,$01,$01,$7f
;                                     DK intro jump across data
L38cb FCB $ff,$ff,$ff,$ff,$ff,$00,$ff,$00,$00,$01,$00,$01,$01,$01,$01,$01
      FCB $7f 
;                                     Draw data for bending girders
L38dc FCB $04,$7f,$f0,$10,$f0,$02,$df,$f2,$70,$f8,$02,$6f,$f8,$10,$f8,$aa
      FCB $04,$df,$d0,$90,$d0,$02,$df,$dc,$20,$d1,$aa,$ff,$ff,$ff,$ff,$ff
      FCB $04,$df,$a8,$20,$a8,$04,$5f,$b0,$20,$b0,$02,$df,$b0,$20,$bb,$aa
      FCB $04,$df,$88,$30,$88,$04,$df,$90,$b0,$90,$02,$df,$9a,$20,$8f,$aa
      FCB $04,$bf,$68,$20,$68,$04,$3f,$70,$20,$70,$02,$df,$6e,$20,$79,$aa 
;                                     Draw data for bending girders (first bounce)
L392c FCB $02,$df,$58,$a0,$55,$aa 
;                                     DK throwing barrel sprites
L3932 FCB $00,$70,$08,$44,$2b,$ac,$08,$4c,$3b,$ae,$08,$4c,$3b,$af,$08,$3c
      FCB $4b,$b0,$07,$3c,$4b,$ad,$08,$4c,$00,$70,$08,$44,$00,$70,$08,$44
      FCB $00,$70,$08,$44,$00,$70,$0a,$44,$47,$27,$08,$4c,$2f,$a7,$08,$4c
      FCB $3b,$25,$08,$4c,$00,$70,$08,$44,$3b,$23,$07,$3c,$4b,$2a,$08,$3c
      FCB $4b,$2b,$08,$4c,$2b,$aa,$08,$3c,$2b,$ab,$08,$4c,$00,$70,$0a,$44
      FCB $00,$70,$08,$44,$4b,$2c,$08,$4c,$3b,$2e,$08,$4c,$3b,$2f,$08,$3c
      FCB $2b,$30,$07,$3c,$2b,$2d,$08,$4c,$00,$70,$08,$44,$00,$70,$08,$44
      FCB $00,$70,$08,$44,$00,$70,$0a,$44
;                                     Bouncing Spring data
L39aa FCB $fd,$fd,$fd,$fe,$fe,$fe,$fe,$ff,$ff,$00,$ff,$00,$00,$01,$00,$01
      FCB $01,$02,$02,$02,$02,$03,$03,$03,$7f
;                                     Barrel rolling data
L39c3 FCB $1e,$4e,$bb,$4c,$d8,$4e,$59,$4e,$7f
;                                     Barrel falling data
L39cc FCB $bb,$4d,$7f 
;                                     DK standing sprites
;L385c FCB $47,$27,$08,$50,$2f,$a7,$08,$50,$3b,$25,$08,$50,$00,$70,$08,$48
;      FCB $3b,$23,$07,$40,$46,$a9,$08,$44,$00,$70,$08,$48,$30,$29,$08,$44
;      FCB $00,$70,$08,$48,$00,$70,$0a,$48,$6f,$10,$09,$23,$6f,$11,$0a,$33 
L385c FCB $47,$27,$08,$50,$2f,$a7,$08,$50,$3b,$25,$08,$50,$00,$70,$08,$48
      FCB $3b,$23,$07,$40,$47,$a9,$08,$44,$00,$70,$08,$48,$2f,$29,$08,$44
      FCB $00,$70,$08,$48,$00,$70,$0a,$48,$6f,$10,$09,$23,$6f,$11,$0a,$33 
;                                     DK trashing right sprites
;L39cf FCB $47,$27,$08,$50,$2d,$26,$08,$50,$3b,$25,$08,$50,$00,$70,$08,$48
;      FCB $3b,$24,$07,$40,$4b,$28,$08,$40,$00,$70,$08,$48,$30,$29,$08,$44
;      FCB $00,$70,$08,$48,$00,$70,$0a,$48 
L39cf FCB $47,$27,$08,$50,$2d,$26,$08,$50,$3b,$25,$08,$50,$00,$70,$08,$48
      FCB $3b,$24,$07,$40,$4b,$28,$08,$40,$00,$70,$08,$48,$2f,$29,$08,$44
      FCB $00,$70,$08,$48,$00,$70,$0a,$48 
;                                     DK thrashing left sprites
;L39f7 FCB $49,$a6,$08,$50,$2f,$a7,$08,$50,$3b,$25,$08,$50,$00,$70,$08,$48
;      FCB $3b,$24,$07,$40,$46,$a9,$08,$44,$00,$70,$08,$48,$2b,$a8,$08,$40
;      FCB $00,$70,$08,$48,$00,$70,$0a,$48
L39f7 FCB $49,$a6,$08,$50,$2f,$a7,$08,$50,$3b,$25,$08,$50,$00,$70,$08,$48
      FCB $3b,$24,$07,$40,$47,$a9,$08,$44,$00,$70,$08,$48,$2b,$a8,$08,$40
      FCB $00,$70,$08,$48,$00,$70,$0a,$48
;                                     DK falling sprites
;L3a1f FCB $73,$a7,$88,$60,$8b,$27,$88,$60,$7f,$25,$88,$60,$00,$70,$88,$68
;      FCB $7f,$24,$87,$70,$74,$29,$88,$6c,$00,$70,$88,$68,$8a,$a9,$88,$6c
;      FCB $00,$70,$88,$68,$00,$70,$8a,$68
L3a1f FCB $73,$e7,$08,$60,$8b,$67,$08,$60,$7f,$65,$08,$60,$00,$70,$08,$68
      FCB $7f,$64,$07,$70,$75,$69,$08,$6c,$00,$70,$08,$68,$89,$e9,$08,$6c
      FCB $00,$70,$08,$68,$00,$70,$0a,$68
;                                     Draw data for end of rivets level
L3a47 FCB $05,$af,$f0,$50,$f0,$aa
L3a4d FCB $05,$af,$e8,$50,$e8,$aa
L3a53 FCB $05,$af,$e0,$50,$e0,$aa
L3a59 FCB $05,$af,$d8,$50,$d8,$aa
L3a5f FCB $05,$b7,$58,$48,$58,$aa
;                                     level sequencing list
; if original release version...
L3a65 FCB $01,$04,$01,$03,$04,$01,$02,$03,$04,$01,$02,$01,$03,$04
L3a73 FCB $01,$02,$01,$03,$01,$04,$7f
; if alternate release version...
;L3a65 FCB $01,$04,$01,$03,$04,$01,$02,$03,$04,$01,$02,$01,$03,$04
;L3a73 FCB $01,$02,$01,$03,$01,$04,$7f
; if japanese release version...
L3a6J FCB $01,$02,$03,$04,$01,$02,$03,$04,$01,$02,$03,$04,$7f,$7f
L3a7J FCB $01,$02,$03,$04,$7f,$7f,$7f
;                                     Fireball bouncing data
L3a7a FCB $ff,$00,$ff,$ff,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff
      FCB $ff,$00
;                                     Fireball jump out of barrel data
L3a8c FCB $e8,$e5,$e3,$e2,$e1,$e0,$df,$de,$dd,$dd,$dc,$dc,$dc,$dc,$dc,$dc
      FCB $dd,$dd,$de,$df,$e0,$e1,$e2,$e3,$e4,$e5,$e7,$e9,$eb,$ed,$f0,$aa
;                                     Fireball on cement level data
L3aac FCB $80,$7b,$78,$76,$74,$73,$72,$71,$70,$70,$6f,$6f,$6f,$70,$70,$71
      FCB $72,$73,$74,$75,$76,$77,$78,$aa
;                                     Fireball on rivets level data
L3ac4 FCB $ee,$f0,$db,$a0,$e6,$c8,$d6,$78,$eb,$f0,$db,$a0,$e6,$c8,$e6,$c8
;                                     Fireball rivets level starting points
L3ad4 FCB $1b,$c8,$23,$a0,$2b,$78,$12,$f0,$1b,$c8,$23,$a0,$12,$f0,$1b,$c8

;                                     Draw data Level 1 (girder)
L3ae4 FCB $02,$97,$38,$68,$38,$02,$9f,$54,$10,$54,$02,$df,$58,$a0,$55,$02
      FCB $ef,$6d,$20,$79,$02,$df,$9a,$10,$8e,$02,$ef,$af,$20,$bb,$02,$df
      FCB $dc,$10,$d0,$02,$ff,$f0,$80,$f7,$02,$7f,$f8,$00,$f8,$00,$cb,$57
      FCB $cb,$6f,$00,$cb,$99,$cb,$b1,$00,$cb,$db,$cb,$f3,$00,$63,$18,$63
      FCB $54,$01,$63,$d5,$63,$f8,$00,$33,$78,$33,$90,$00,$33,$ba,$33,$d2
      FCB $00,$53,$18,$53,$54,$01,$53,$92,$53,$b8,$00,$5b,$76,$5b,$92,$00
      FCB $73,$b6,$73,$d6,$00,$83,$95,$83,$b5,$00,$93,$38,$93,$54,$01,$bb
      FCB $70,$bb,$98,$01,$6b,$54,$6b,$75,$aa
;                                     Draw data Level 2 (cement)
L3b5d FCB $06,$8f,$90,$70,$90,$06,$8f,$98,$70,$98,$06,$8f,$a0,$70,$a0,$00
      FCB $63,$18,$63,$58,$00,$63,$80,$63,$a8,$00,$63,$d0,$63,$f8,$00,$53
      FCB $18,$53,$58,$00,$53,$a8,$53,$d0,$00,$9b,$80,$9b,$a8,$00,$9b,$d0
      FCB $9b,$f8,$01,$23,$58,$23,$80,$01,$db,$58,$db,$80,$00,$2b,$80,$2b
      FCB $a8,$00,$d3,$80,$d3,$a8,$00,$a3,$a8,$a3,$d0,$00,$2b,$d0,$2b,$f8
      FCB $00,$d3,$d0,$d3,$f8,$00,$93,$38,$93,$58,$02,$97,$38,$68,$38,$03
      FCB $ef,$58,$10,$58,$03,$f7,$80,$88,$80,$03,$77,$80,$08,$80,$02,$a7
      FCB $a8,$50,$a8,$02,$e7,$a8,$b8,$a8,$02,$3f,$a8,$18,$a8,$03,$ef,$d0
      FCB $10,$d0,$02,$ef,$f8,$10,$f8,$aa
;                                     Draw data Level 3 (elevator)
L3be5 FCB $00,$63,$18,$63,$58,$00,$63,$88,$63,$d0,$00,$53,$18,$53,$58,$00
      FCB $53,$88,$53,$d0,$00,$e3,$68,$e3,$90,$00,$e3,$b8,$e3,$d0,$00,$cb
      FCB $90,$cb,$b0,$00,$b3,$58,$b3,$78,$00,$9b,$80,$9b,$a0,$00,$93,$38
      FCB $93,$58,$00,$23,$88,$23,$c0,$00,$1b,$c0,$1b,$e8,$02,$97,$38,$68
      FCB $38,$02,$b7,$58,$10,$58,$02,$ef,$68,$e0,$68,$02,$d7,$70,$c8,$70
      FCB $02,$bf,$78,$b0,$78,$02,$a7,$80,$90,$80,$02,$67,$88,$48,$88,$02
      FCB $27,$88,$10,$88,$02,$ef,$90,$c8,$90,$02,$a7,$a0,$98,$a0,$02,$bf
      FCB $a8,$b0,$a8,$02,$d7,$b0,$c8,$b0,$02,$ef,$b8,$e0,$b8,$02,$27,$c0
      FCB $10,$c0,$02,$ef,$d0,$d8,$d0,$02,$67,$d0,$50,$d0,$02,$cf,$d8,$c0
      FCB $d8,$02,$b7,$e0,$a8,$e0,$02,$9f,$e8,$88,$e8,$02,$27,$e8,$10,$e8
      FCB $02,$ef,$f8,$10,$f8,$aa
;                                     Draw data Level 4 (rivets)
L3c8b FCB $00,$7b,$80,$7b,$a8,$00,$7b,$d0,$7b,$f8,$00,$33,$58,$33,$80,$00
      FCB $53,$58,$53,$80,$00,$ab,$58,$ab,$80,$00,$cb,$58,$cb,$80,$00,$2b
      FCB $80,$2b,$a8,$00,$d3,$80,$d3,$a8,$00,$23,$a8,$23,$d0,$00,$5b,$a8
      FCB $5b,$d0,$00,$a3,$a8,$a3,$d0,$00,$db,$a8,$db,$d0,$00,$1b,$d0,$1b
      FCB $f8,$00,$e3,$d0,$e3,$f8,$05,$b7,$30,$48,$30,$05,$cf,$58,$30,$58
      FCB $05,$d7,$80,$28,$80,$05,$df,$a8,$20,$a8,$05,$e7,$d0,$18,$d0,$05
      FCB $ef,$f8,$10,$f8,$aa
;                                     Data in How High Can You Get screen
L3cf0 FCB $10,$82,$85,$8b,$10,$85,$80,$8b,$10,$87,$85,$8b,$81,$80,$80,$8b
      FCB $81,$82,$85,$8b,$81,$85,$80,$8b
;                                     Donkey Kong title screen
L3d08 FCB $05
      FDB $7788
      FCB $01
      FDB $7768
      FCB $01
      FDB $776c
      FCB $03
      FDB $7749
      FCB $05
      FDB $7708
      FCB $01
      FDB $76e8
      FCB $01
      FDB $76ec
      FCB $05
      FDB $76c8
      FCB $05
      FDB $7688
      FCB $02
      FDB $7669
      FCB $02
      FDB $764a
      FCB $05
      FDB $7628
      FCB $05
      FDB $75e8
      FCB $01
      FDB $75ca
      FCB $03
      FDB $75a9
      FCB $01
      FDB $7588
      FCB $01
      FDB $758c
      FCB $05
      FDB $7548
      FCB $01
      FDB $7528
      FCB $01
      FDB $752a
      FCB $01
      FDB $752c
      FCB $01
      FDB $7508
      FCB $01
      FDB $750a
      FCB $01
      FDB $750c
      FCB $03
      FDB $74c8
      FCB $03
      FDB $74aa
      FCB $03
      FDB $7488
      FCB $05
      FDB $772f
      FCB $05
      FDB $770f
      FCB $02
      FDB $76f0
      FCB $02
      FDB $76cf
      FCB $02
      FDB $76d2
      FCB $05
      FDB $768f
      FCB $05
      FDB $766f
      FCB $01
      FDB $764f
      FCB $01
      FDB $7653
      FCB $05
      FDB $762f
      FCB $05
      FDB $75ef
      FCB $02
      FDB $75d0
      FCB $02
      FDB $75b1
      FCB $05
      FDB $758f
      FCB $03
      FDB $7550
      FCB $05
      FDB $752f
      FCB $01
      FDB $750f
      FCB $01
      FDB $7513
      FCB $01
      FDB $74ef
      FCB $01
      FDB $74f1
      FCB $01
      FDB $74f3
      FCB $02
      FDB $74d1
      FCB $00
;                                     level/initialize data? (endian errors!)
L3d9c FCB $00,$00,$23,$68,$01,$11,$00,$00,$00,$10,$db,$68,$01,$40,$00,$00   ;6280
      FCB $08,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00   ;6290
      FCB $80,$01,$c0,$ff,$01,$ff,$ff,$34                                   ;62a0
      FDB L39c3,$6700,$6980                                                 ;62a8
      FCB $1a,$01                                                           ;62ae
      FCB $00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$10,$00,$00,$00,$00,$00   ;62b0
;                                     Barrel sprites beside DK
L3ddc FCB $1e,$18,$0b,$4b,$14,$18,$0b,$4b,$1e,$18,$0b,$3b,$14,$18,$0b,$3b
;                                     Fireball sprite animation
L3dec FCB $3d,$01,$03,$02
;                                     Fireball (rivets-style) sprite animation
L3df0 FCB $4d,$01,$04,$01
;                                     Girders level extra sprites?
L3df4 FCB $27,$70,$01,$e0,$00,$00
;                                     Cement level extra sprites? (burning fire over barrels)
L3dfa FCB $7f,$40,$01,$78,$02,$00
;                                     Girder level oil barrel sprite
L3e00 FCB $27,$49,$0c,$f0
;                                     Cement level oil barrel sprite
L3e04 FCB $7f,$49,$0c,$88
;                                     Hammer pickups sprite
L3e08 FCB $1e,$07,$03,$09
;                                     Girder level hammer locations
L3e0c FCB $24,$64,$bb,$c0
;                                     Cement level hammer locations
L3e10 FCB $23,$8d,$7b,$b4
;                                     Rivets level hammer locations
L3e14 FCB $1b,$8c,$7c,$64
;                                     Cement pie sprites
L3e18 FCB $4b,$0e,$04,$02
;                                     Cement level moving ladder sprites
L3e1c FCB $23,$46,$03,$68,$db,$46,$03,$68
;                                     Cement level conveyor sprites
;L3e24 FCB $17,$50,$00,$5c,$e7,$d0,$00,$5c,$8c,$50,$00,$84,$73,$d0,$00,$84
;      FCB $17,$50,$00,$d4,$e7,$d0,$00,$d4
L3e24 FCB $17,$50,$00,$5c,$e7,$d0,$00,$5c,$8c,$50,$00,$84,$71,$d0,$00,$84
      FCB $17,$50,$00,$d4,$e7,$d0,$00,$d4
;                                     Cement level hat, purse, umbrella sprites
L3e3c FCB $53,$73,$0a,$a0,$8b,$74,$0a,$f0,$db,$75,$0a,$a0
;                                     Elevator level hat, purse, umbrella sprites
L3e48 FCB $5b,$73,$0a,$c8,$e3,$74,$0a,$60,$1b,$75,$0a,$80
;                                     Rivets level hat, purse, umbrella sprites
L3e54 FCB $db,$73,$0a,$c8,$93,$74,$0a,$f0,$33,$75,$0a,$50
;                                     Elevator level elevator sprite
L3e60 FCB $44,$03,$08,$04
;                                     Elevator level sprite locations (x,y)
L3e64 FCB $37,$f4,$37,$c0,$37,$8c,$77,$70,$77,$a4,$77,$d8

L3e88 LDB $6227       LD A,($6227)     286b Level Type
      PSHS X          PUSH HL
      JSR L0028       RST $28
;                                     JUMP TABLE
      FDB L0000
      FDB L3e99                       level 1 bonus check
      FDB L28b0                       level 2 bonus check
      FDB L28e0                       level 3 bonus check
      FDB L2901                       level 4 bonus check
      FDB L0000

L3e99 PULS X          POP HL          Level 1 (girders) check for jump over barrel/fire bonus
      CLRB            XOR A
      STB $6060       LD ($6060),A
      LDA #$0a        LD B,$0A
      STA REGB 
      LDY #$0020      LD DE,$0020
      LDU #$6700      LD IX,$6700
      BSR L3ec3       CALL $3EC3
      LDA #$05        LD B,$05
      STA REGB 
      LDU #$6400      LD IX,$6400     fireball character data
      BSR L3ec3       CALL $3EC3
      LDB $6060       LD A,($6060)
;                     AND A
      BEQ L3ec2       RET Z
      CMPB #$01       CP $01
      BEQ L3ec2       RET Z
      CMPB #$03       CP $03
      LDB #$03        LD A,$03
      BCS L3ec2       RET C
      LDB #$07        LD A,$07
L3ec2 RTS             RET
L3ec3 STX REGHL                       swap X to be IY
      LDX REGIY 
LFIX  LDA ,U          BIT 0,(IX+$00)  3efc 3eb0 3ea7
      ANDA #1
      BEQ L3efa       JP Z,$3EFA
      LDB REGC        LD A,C
      SUBB $5,U       SUB (IX+$05)
      BCC L3ed3       JP NC,$3ED3
      NEGB            NEG
L3ed3 INCB            INC A           3ece
      SUBB REGL       SUB L
      BCS L3ede       JP C,$3EDE
      SUBB $a,U       SUB (IX+$0A)
      BCC L3efa       JP NC,$3EFA
L3ede LDB $3,X        LD A,(IY+$03)   3ed5
      SUBB $3,U       SUB (IX+$03)
      BCC L3ee9       JP NC,$3EE9
      NEGB            NEG
L3ee9 SUBB REGH       SUB H           3ee4
      BCS L3ef3       JP C,$3EF3
      SUBB $9,U       SUB (IX+$09)
      BCC L3efa       JP NC,$3EFA
L3ef3 INC $6060       LD A,($6060)    3eea
;                     INC A
;                     LD ($6060),A
L3efa LEAU $20,U      ADD IX,DE       3ef0 3edb 3ec7
      DEC REGB        DJNZ $3EC3
      BNE LFIX
      LDX REGHL                       restore HL
      RTS             RET

; if alternate release version...
;L3f00 FDB $765c
;      FCB $49,$4a,$01,$09,$08,$01,$3f
;L3f09 FDB $777d
;      FCB $1e,$19,$1e,$24,$15,$1e,$14,$1f,$10,$1f,$16,$10,$11,$1d
;      FCB $15,$22,$19,$13,$11,$10,$19,$1e,$13,$2b,$3f                      

L3fa0 BSR L3fa6       CALL $3FA6      0cd1
      JMP L0d5f       JP $0D5F

L3fa6 LDB #$02        LD A,$02        3fa0
      JSR L0030       RST $30
      LDA #$02        LD B,$02
      STA REGB 
      LDX #$776c      LD HL,$776C
L3fae LDA #$10        LD (HL),$10     3fb7
      STA ,X++        INC HL
;                     INC HL
      LDA #$c0        LD (HL),$C0
      STA ,X
      LDX #$748c      LD HL,$748C
      DEC REGB        DJNZ $3FAE
      BNE L3fae
      RTS             RET

L3fc0 LDX #$694d      LD HL,$694D     2285
      LDA #$03        LD (HL),$03
      STA ,X++        INC L
;                     INC L
      RTS             RET

EXX   COM BAKX                        Exchange BC,DE,HL with BC',DE',HL'
      BMI EXALT
      STX BAXHL
      LDX REGBC
      STX BAXBC
      LDX BAKBC
      STX REGBC
      LDX BAKHL
      STY BAXDE
      LDY BAKDE
      RTS
EXALT STX BAKHL
      LDX REGBC
      STX BAKBC
      LDX BAXBC
      STX REGBC
      LDX BAXHL
      STY BAKDE
      LDY BAXDE
      RTS

; emulate DK palette control (by swapping character set)
;
SETPAL PSHS D,X,Y
       LDA #$29
       STA 65441
       LDD $7d86                      BG Palette select
       LSRB
       ROLA
       ANDA #3
       STA PATCH5+1
       BEQ PATCH5                     don't bother swapping characters if PAL = 0
       ADDA #$27                      add $2700
       CLRB
       TFR D,Y                        Y = Source address
       LDX #$f00                      X = Destination address
COPYT  LDD ,Y++
       STD ,X++
       CMPX #$1000
       BLO COPYT

PATCH5 LDD #0000
       RORA
       RORB
       RORA
       RORB
       LDX #OVERLAY
       ABX
       STX PATCH4+2
       LDA #57
       STA 65441
       PULS D,X,Y,PC

OVERLAY FDB $2050,$2010,$2000,$2000,$2040,$2020,$2020,$2010,$2020,$2020,$2020
        FDB $2020,$2050,$2020,$2050,$2010,$2050,$2020,$2020,$2020,$2020,$2010
        FDB $2050,$2010,$2030,$2010,$2020,$2030,$2050,$2030,$2050,$2020
        FDB $2020,$2010,$2000,$2000,$2040,$2020,$2020,$2020,$2020,$2020,$2020
        FDB $2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020
        FDB $2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020,$2020
        FDB $2000,$2010,$2000,$2000,$2040,$2000,$2000,$2000,$2000,$2000,$2000
        FDB $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
        FDB $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
        FDB $2030,$2010,$2000,$2000,$2040,$2030,$2030,$2030,$2030,$2030,$2030
        FDB $2030,$2030,$2030,$2030,$2030,$2030,$2030,$2030,$2030,$2030,$2030
        FDB $2030,$2030,$2030,$2030,$2030,$2030,$2030,$2030,$2030,$2030

; Draw/emulate DK character screen
;
DRAWC  LDY #$7440-$20                 location of character RAM
       LDX #CHRBUF+$20                location of character RAM copy/compare
       JMP CCMP

COLORC PSHS X,Y
       LDA #3                         calculate source address in character data
       LSLB
       ROLA
       LSLB
       ROLA
       TFR D,U                        U = index to source
       LDA ,U                         A = bank for source
       LDU 1,U                        U = address of source routine
       STA 65441

       TFR Y,D                        calculate destination address on screen
       ANDA #$03
       LSLB
       ROLA
       TFR D,X
       LDX ,X                         X = dest address on screen

       ANDB #$3e                      load color overlay
PATCH4 LDY #OVERLAY
       LDY B,Y                        Y = color data address

       LDB #$ff
       JSR ,U                         draw the character!

       PULS X,Y

       LDB ,Y+
       CMPB ,X+                       check if a character has changed
       BNE CGO2
CCMP3  LDD ,Y++                       switch to faster scan...
       CMPD ,X++                      check if a word has changed
       BEQ CCMP3
       CMPA -2,X                      check if A is unchanged
       BEQ CGO2                       B changed then...
       LEAY -1,Y                      A changed, so back up a byte
       LEAX -1,X
       LDB -1,Y
       BRA CGO2


NOTBLK CMPB #$4b                      check if colorizeable character
       BLO COLORC
       STX PATCH9+1
       LDA #3                         calculate source address in character data
       LSLB
       ROLA
       LSLB
       ROLA
       TFR D,U                        U = index to source
       LDA ,U                         A = bank for source
       LDU 1,U                        U = address of source routine
       STA 65441
       tfr y,d                        calculate destination address on screen
       ANDA #$03
       LSLB
       ROLA
       TFR D,X
       LDX ,X                         X = dest address on screen
       LDB #$ff
       JSR ,U                         draw the character!

PATCH9 LDX #$0000
       LDB ,Y+
       CMPB ,X+                       check if a character has changed
       BEQ CCMP2

CGO2   CMPX #CHRBUF+$3E0
       BHI PATCH3
CGO    STB -1,X
       CMPB #$10                      check if blank character
       BNE NOTBLK

       STX PATCH8+1                   PSHS X
       TFR Y,D
       ANDA #$03                      translate character address to bitmap address
       LSLB
       ROLA
       TFR D,X
       LDX ,X                         X = dest address in graphics screen
       ldb #255

       LDU #$0000                     draw blank tile...
       STU -128,X
       STU -126,X
       STU ,X
       STU 2,X
       abx
       STU -127,X
       STU -125,X
       STU 1,X
       STU 3,X
       abx
       STU -126,X
       STU -124,X
       STU 2,X
       STU 4,X
       abx
       STU -125,X
       STU -123,X
PATCH8 LDX #$0000                     PULS X

CCMP   LDB ,Y+
       CMPB ,X+                       check if a character has changed
       BNE CGO2
CCMP2  LDD ,Y++                       switch to faster scan...
       CMPD ,X++                      check if a word has changed
       BEQ CCMP2
       CMPA -2,X                      check if A is unchanged
       BEQ CGO2                       B changed then...
       LEAY -1,Y                      A changed, so back up a byte
       LEAX -1,X
       LDB -1,Y
       BRA CGO2

PATCH3 LDA #57                        self modifying value
       STA 65441
       RTS

; Erase onscreen sprites
;
ERASS  LDX #$6900-4                   location of sprite RAM
       LDY #SPRBUF-4                  location of sprite RAM copy/compare
       bra ECMP

EGO3   LDA ,Y                         A=X, B=Y : divide B by 8, mul COMA by 4
       BEQ EGO0                       skip erase if X = 0
       ADDB #7
       COMA
       LSRA
       LSRA
       LSRA
       LSRA
       RORB
       LSRA
       RORB
       LSRA
       RORB
       STU ,Y                         copy sprite data to buffer
       ADDD #CHRBUF-2                 location of character RAM copy/compare
       TFR D,U
       lda 3,x                        copy sprite data to buffer
       sta 3,y
       LDD #$4f4f                     mark tiles with $4f
       STD ,U                         make character screen redraw over sprite
       STA 2,U
       STD -32,U
       STA -30,U
       STD 32,U
       STA 34,U

ECMP   leay 4,y                       compare sprite ram to buffer
       leax 4,x
       LDU ,X                         check if sprites have changed...
       CMPU ,Y
       BEQ ECMP2
       LDB 3,Y
       CMPX #LASTSPR                  are we finished scanning?
       BLO EGO2
EFIN   RTS

ECMP2  LDB 3,Y                        check if sprites have changed...
       CMPB 3,X
       BEQ ECMP                       keep looping if sprites not changed
EGO2   lda 1,y
       cmpa #$70                      don't erase if character # = $70
       bne EGO3
EGO0   STU ,Y                         copy sprite data to buffer
       LDA 3,X
       STA 3,Y
       bra ECMP

; Draw/emulate DK sprites
;
DRAWS  LDY #$6900-4                   location of sprite RAM
       ldd #$ff00
       std LASTSPR                    mark end of sprite ram
       bra SCMP

SGO    LDB 3,Y
       LDA #112                       calculate dest address in bitmap
       MUL                            calculate Y offset into bitmap
       ADDD #$7d30                    adjust to $8000 start location
       ANDB #128                      clean up 7/8ths scaling to 128 byte boundries
       TFR D,X
       LDB ,Y
       ADDB #16
       CMPB #30
       BLO SCMP                       don't draw if X coordinate outside screen
       SUBB #22
       LSRB
       ABX                            X = dest bitmap index

       LDB 1,Y                        calculate source address in sprite data
;       LDA #8
       LDA #2
       LSLB
       ROLA
       LSLB
       ROLA
       TFR D,U                        U = index to source
;       LDA #$29
;       STA 65441
       LDA ,U                         A = bank for source
       LDU 1,U
       STA 65441
       JSR ,U                         draw the sprite!

SCMP   leay 4,y                       scan for active sprites
       LDA ,Y
       BEQ SCMP                       skip if x coordinate is zero
       CMPA #$ff                      are we finished scanning?
       BNE SGO 
       ldb 1,Y                        doublecheck next byte just in case
       bne SGO
       LDA #$39                       restore MMU bank
       STA 65441
       RTS                            finished

; Read the joystick & buttons and emulate DK I/O ports
;
JOYIN  ORCC #$40                      disable FIRQ
       LDA $ff20                      save value in DAC
       STA DPATCH+1
       LDA #$36
       STA $ff23                      disable sound output
       LDD #$d8bc
       STB $ff01                      set Y axis
       STA $ff20                      set DAC
       LDB #$35
       STB $ff03                      set joystick #0
       NOP                            (time killer)
       LDA $ff00                      read joystick button
       ANDA #1
       LDB $ff00                      read down value
       ROLB                           shift value into carry
       LDB #$24
       STB $ff20                      set DAC
       ROLA                           shift carry into A
       LEAX ,X                        (time killer)
       LDB $ff00                      read up value
       ROLB                           shift value into carry
       LDB #$b4
       STB $ff01                      set X axis
       ROLA                           shift carry into A
       LEAX 10,X                      (time killer)
       LEAX -10,X                     (time killer)
       LEAX ,X                        (time killer)
       CLR IN2                        clear coin input (time killer)
       LDB IN0                        (time killer)
       STB OLDJOY                     (time killer)
       DEC TICK                       (time killer)
       LDB $ff00                      read left value
       ROLB                           shift value into carry
       LDB #$d8
       STB $ff20                      set DAC
       ROLA                           shift carry into A
       EORA #$0b                      complement inverted bits
       LDB $ff00                      read right value
       ROLB                           shift value into carry
DPATCH LDB #$00                       self-modifying value
       STB $ff20                      restore original value in DAC
       ROLA                           shift carry into A
       STA IN0                        write to DK IN0
;      ANDA #3                        disable diagonal inputs
;      BEQ NODIAG
;      LDA IN0
;      ANDA #$f3
;      STA IN0

NODIAG LDB #$3e
       STB $ff23                      re-enable sound output
       ANDCC #$BF                     re-enable FIRQ
       LDB $6001                      # of credits
       BNE CSTART
       LDB $6007                      attract mode flag
       BEQ CSTOP
       LDA OLDJOY
       ANDA #$10
       EORA #$10
       BEQ NOCOIN
       LDA IN0
       ANDA #$10
NOCOIN LSLA
       LSLA
       LSLA
       STA IN2                        write to DK IN2 (coin trigger)
       BRA CSTOP      
CSTART LDB OLDJOY
       ANDB #$10
       BNE CSTOP
       LDA IN0
       ANDA #$10
       LSRA
       LSRA
       STA IN2                        write to DK IN2 (start button)
CSTOP  RTS

; Toggle frame buffers
;
TOGGS  LDA TOGGLE
       LSLA
       LSLA
       STA $ff9d                      set address of graphics display
       LDA TOGGLE
       ADDA #4
       CMPA #$38                      skip main program area
       BNE TSKIP
       ADDA #4
TSKIP  CMPA #$40                      check end of buffers
       BLO TOK
       LDA #$30
TOK    STA TOGGLE
       STA 65444
       INCA
       STA 65445
       INCA
       STA 65446
       INCA
       STA 65447
       RTS

; Process sound calls
;

; hacked sound alteration - make spring play in music channel instead of digital channel
DOSND  lda $7d03
       beq DOSND2
       ldb #$1a
       bra nobkg3

; original start of DOSND
DOSND2 LDB $7c00                      check music calls
; add skips to sounds 06 (hammer hit) and 0d (bonus)
       CMPB #$06
       BNE NOHAM
       STB $7d06                      coco hack to turn hammer into voice 2 effect
       BRA NOMUS
NOHAM  CMPB #$0d
       BNE NOBON
       STB $7d05                      coco hack to turn bonus into voice 2 effect
       BRA NOMUS
NOBON  cmpb #$0a
       bne nobkg3                     coco hack to remove background music 3 for use by spring
       stb MUSIC
       bra NOMUS
nobkg3 CMPB MUSIC
       BEQ NOMUS
       STB MUSIC
       LDX #M00                       index to music sample info
       ORCC #$40                      disable FIRQ
       ANDB #$0f
       BEQ NOLOOP
       LSLB
       LSLB
       LSLB
       ABX
       LDA ,X                         initial bank
       STA V1BNK
       STA 65451
       LDD 1,X                        initial MSB & LSB
       STD V1ADDR+1
       LDA 6,X                        end bank
       STA V1EBNK+1
NOLOOP LDD 3,X                        loop bank & MSB
       STA V1LBNK+1
       STB V1LMSB+1
       LDA 5,X                        loop LSB
       STA V1LLSB+1
       ANDCC #$BF                     re-enable FIRQ

NOMUS  LDA ETIME
       BEQ DOFX
       DECA
       STA ETIME
DOFX   LDX #D80
       LDA $7d80
       BEQ NODIE
       CLRB
       BRA EFFECT
NODIE  LDA $7d04
       BEQ NOFALL
       LDB #32
       BRA EFFECT
NOFALL LDA $7d06
       BEQ NOHAMH
       LDB #48
       BRA EFFECT
NOHAMH LDA $7d05
       BEQ NOBONU
       LDB #40
       BRA EFFECT
NOBONU LDA $7d01
;       BEQ NOJMP
       beq NOSPRN
       LDB #8
       BRA EFFECT
;NOJMP  LDA $7d03
;       BEQ NOSPRN
;       LDB #24
;       BRA EFFECT
NOSPRN LDA $7d02
       BEQ NOSTMP
       LDB #16
       BRA EFFECT
NOSTMP LDA $7d00
       BEQ NOEFF
       LDB $6018
       LDA #24
       MUL
       ANDA #$18
       LEAX A,X
       LDB #56
EFFECT CMPB EFFEC
       BEQ RETURN
       STB EFFEC
       ABX

       lda 7,X                        process sound priority
       cmpa ETIME
       blo RETURN
       sta ETIME

       ORCC #$40                      disable FIRQ
       LDA ,X                         initial bank
       STA V2BNK
       STA 65452
       LDD 1,X                        initial MSB & LSB
       STD V2ADDR+1
       LDB 6,X                        end bank
       STB V2EBNK+1

       lda #$bb                       modify thyself to restart voice channel
       sta V2ADDR
       ldd #$b7ff
       std V2ADDR+3
       ldd #$200a
       std V2ADDR+5

       ANDCC #$BF                     re-enable FIRQ
       LDA 7,X
       STA ETIME
RETURN RTS
NOEFF  LDB #$ff
       STB EFFEC
       RTS

; sound sample data
;          initial     loop        end
;          BNK MSB LSB BNK MSB LSB BNK time
D80    FCB $08,$9d,$a1,$06,$80,$ff,$06,170
D01    FCB $18,$9b,$d2,$18,$85,$ff,$18,29
D02    FCB $1a,$91,$c5,$1a,$80,$ff,$1a,10
D03    FCB $26,$87,$b9,$26,$80,$ff,$26,6
D04    FCB $02,$8f,$43,$01,$81,$ff,$01,60
D05    FCB $1b,$97,$d2,$1b,$83,$ff,$1b,37
D86    FCB $23,$82,$9a,$22,$80,$ff,$22,60
D001   FCB $0f,$85,$26,$0f,$80,$ff,$0f,1
D002   FCB $0e,$8f,$e3,$0e,$89,$ff,$0e,1
D003   FCB $00,$8f,$ff,$00,$89,$ff,$00,1


;M00    FCB $28,$78,$00,$28,$78,$00,$28,$00
M00    FCB $2f,$7f,$00,$2f,$7f,$00,$37,$00       hacked to make D03 > M0a hack work !@#$
M01    FCB $08,$7d,$ae,$0d,$7f,$00,$0d,$00
M02    FCB $26,$68,$24,$28,$78,$00,$28,$00
M03    FCB $0e,$70,$e4,$0e,$70,$e4,$0e,$00
M04    FCB $0f,$65,$a7,$0f,$65,$a7,$11,$00
M05    FCB $12,$60,$00,$17,$7f,$00,$17,$00
M06    FCB $28,$78,$00,$28,$78,$00,$28,$00
M07    FCB $02,$6f,$74,$05,$7e,$00,$05,$00
M08    FCB $18,$7c,$d3,$18,$7c,$d3,$19,$00
M09    FCB $1a,$72,$2b,$1a,$72,$2b,$1a,$00
;M0a    FCB $28,$78,$00,$28,$78,$00,$28,$00
M0a    FCB $2f,$78,$47,$2f,$7f,$00,$2f,$00       D03 > M0a hacked spring sound in music channel
M0b    FCB $00,$70,$e3,$00,$70,$e3,$00,$00
M0c    FCB $1b,$78,$d3,$21,$7d,$00,$21,$00
M0d    FCB $28,$78,$00,$28,$78,$00,$28,$00
M0e    FCB $23,$62,$9b,$25,$7f,$00,$25,$00
M0f    FCB $04,$65,$8b,$05,$7e,$00,$05,$00



; Setup graphics
; Copy character tiles to $0000, enable graphics, clear screen...
;
GSET   STA 65497                      fast poke
       LDB    #$FF                    CHECK FOR 6309 CPU
       FCB    $10,$4F
       TSTB
       BNE    IS6809
       LDMD   #$1                     ENABLE 6309 NATIVE MODE, FAST FIRQ

IS6809 LDU #PAL                       set palette
       TFR U,Y
       DEC 33003                      check palette "dip switch"
       BNE ISRGB
       LEAU 16,U
ISRGB  LDX #$ffb0
       CLRA
BPAL   LDB ,U+                        copy CMP palettes to palette table if required
       STB ,Y+
;       STA ,X+                        set palettes to black for now...
       leax 1,x
       CMPX #$ffc0
       BLO BPAL
       STA 65434                      set border color as well
       STA 65344                      turn off disk drive
       LDD #$3f7f
       STB 65312
       STA 65315                      enable sound

       DEC 33002                      check US/JAP level order "dip switch"
       BNE ISUS
       LDX #L3a65
       LDB #21
SETLVL LDA 21,X
       STA ,X+
       DECB
       BNE SETLVL

ISUS   DEC 33001                      check easy/hard setting
       BNE ISEASY
       LDD #$0405
       STA ALTV+1
       STB RANDP+1

ISEASY LDA 33000                      check Lives/Bonus "dip switch"
       ANDA #$f0
       BNE NOLIV
       LDA 33000
NOLIV  ANDA #$0f
       STA DSW1

       DEC 33004
       BNE SOUNDON
       CLRA
       CLRB
       STD PATCH1+1
       BRA NOSOUND

SOUNDON JSR DECMP                     decompress sound data

NOSOUND LDX #$ffb0                    set palettes black
       LDD #$0010
BLACK  STA ,X+                        set palettes to black for now...
       DECB
       BNE BLACK

       LDA #8                         copy MMU values to 2nd task
       LDX #65440
MMULP  LDB ,X+
       STB 7,X
       DECA
       BNE MMULP
       LDD V1BNK                      set initial V1 & V2 banks
       STD 65451
PATCH1 LDD #$01c8                     set GIME timer frequency
       STD 65428
       LDD #$0e00+(FIRQ&$00ff)        set FIRQ vector
       STD $fef4
       LDD #$2020                     4020
       STA 65425                      set timer clock & primary mmu task
       STB 65427                      enable FIRQ from timer

;      LDA #$79                       Set GIME/graphics mode/address
       LDA #$5c                       49 Set GIME/graphics mode/address
       STA $ff90
       LDD #$807a                     video resolution
       STD $ff98
       LDD #$0000                     set address of graphics display
       STD $ff9e
       LDD #$c030
       STA $ff9d
       STB TOGGLE

SETBUF JSR TOGGS
       LDX #BITMAP                    Clear graphics screen
       LDU #0
       LDD #$3940                     28800 bytes
CLRSC  STU ,X++
       DECB
       BNE CLRSC
       DECA
       BNE CLRSC

       LDU #CHRBUF                    interim location of character screen copy
       LDD #$1010
CLRBF  STD ,U++                       clear 1024 bytes
       CMPU #CHRBUF+CHRSIZ
       BLO CLRBF
       LDD #$9595                     terminator value
       STD ,U

       LDU #SPRBUF                    interim location of sprite copy
       LDD #$0000
CLRSP  STD ,U++                       clear 384 bytes
       CMPU #SPRBUF+SPRSIZ
       BLO CLRSP
       LDD #$9595                     terminator value
       STD ,U

       LDA TOGGLE
       CMPA #$30
       BNE SETBUF

       LDU #PAL
       LDX #$ffb0                     set palette registers to DK colors
CPAL   LDD ,U++
       STD ,X++
       CMPX #$ffc0
       BLO CPAL

       LDX #$7400                     generate character RAM address lookup table
       LDY #$0000
TRANSL TFR X,D
       SUBD #1
       STB PATCH+1
       LSRA
       RORB
       LSRA
       RORB
       COMB
       ANDB #$f8                      B = horiz offset X 2
PATCH  LDA #$00                       self modifying value
       ANDA #$1f
       STA PATCH2+1
       LSLA
       LSLA
       LSLA
PATCH2 SUBA #00                       A = vert offset X 2
       LSRA
       RORB                           D = hv offset
       ORA #128                       $8000 address adjust
       ADDD #128
       STD ,Y++
       LEAX 1,X
       CMPX #$7800
       BNE TRANSL

       LDA #$29                       copy sprite/character jump lookup into near RAM
       STA 65441
       LDX #$800
       LDY #$2000
CSCPY  LDD ,Y++
       STD ,X++
       CMPX #$1000
       BLO CSCPY
       LDA #57
       STA 65441

       RTS

; sound decompression routine
;
DECMP LDU #$b800            input  = bank B, index U
XLOOP LDX #$8000            output = bank A, index X
      LDD OUTBK
      STD 65444
OLOOP LDA #4
      STA FOUR
      lda ,u+
VLOOP LDB #128

;decompress sound data into ram
LOOP  rola                  ;ROL ,U
      BCC L160
      ADDB STEP
      CLR UP
      tst DOWN
      bne LINC
      stb DOWN
      DEC STEP
      BNE LDONE
      BRA LINC
L160  SUBB STEP
      CLR DOWN
      tst UP
      bne LINC
      stb UP
      DEC STEP
      BNE LDONE
LINC  INC STEP
LDONE STB VAL2+1            store dropped sample
      rola                  ;ROL ,U
      BCC L160B
      ADDB STEP
      CLR UP
      tst DOWN
      bne LINCB
      stb DOWN
      DEC STEP
      BNE LDONB
      BRA LINCB
L160B SUBB STEP
      CLR DOWN
      tst UP
      bne LINCB
      stb UP
      DEC STEP
      BNE LDONB
LINCB INC STEP
LDONB STB VLOOP+1
      lsrb
      lsrb
VAL2  ADDB #128             mix two 16Khz samples
      RORB
      subb #46              ;SUBB #64
      BCC NOCLP
      CLRB
NOCLP lslb
      bpl noclp3
      ldb #127
noclp3 STB ,X+               store 8Khz sample
      stb 65434                       testing - set border color
      DEC FOUR
      BNE VLOOP
      CMPX #$a000
      BLO OLOOP
      INC OUTBK
      LDA OUTBK
      CMPA #41              check if we're all done decompressing
      BEQ DONE
      CMPU #$c000
      LBLO XLOOP
      LDU #$a000
      INC INBK
      JMP XLOOP

DONE  CLR 65434                       reset border color
      ldd #$262f            add a hacked version of the spring sound to run in music channel
      std 65444
      ldx #$8000            source
      ldy #$c000            dest
hackl lda ,x+
      sta ,-y
      cmpx #$87ba
      blo hackl
      RTS

;PAL    FCB $00,$00,$08,$09,$12,$1B,$20,$22,$39,$24,$25,$26,$2E,$34,$35,$3F
;CMPPAL FCB 00,00,12,28,33,61,6,4,59,23,39,21,40,52,53,63
;CMPPAL FCB 00,00,12,12,33,61,6,4,59,23,23,21,40,52,53,63
PAL    FCB 00,00,08,09,18,27,32,34,57,36,37,38,46,52,53,63
CMPPAL FCB 00,00,16,27,33,61,22,20,59,23,39,38,40,52,53,63

       END L0000
