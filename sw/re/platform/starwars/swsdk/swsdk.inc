;
; Star Wars SDK
; msmcdoug@gmail.com
;

SWSDK_VERSION                   = 0x0006
        .macro SWSDK_SZ_VERSION
        .ascii    "0.0."
        .byte     (1<<7)|0x30|<SWSDK_VERSION
        .endm

SWSDK_OP_VCTR                   = 0x0000
SWSDK_OP_HALT                   = 0x2000
SWSDK_OP_SVEC                   = 0x4000
SWSDK_OP_COLOR                  = 0x6000
SWSDK_OP_SCAL                   = 0x7000
SWSDK_OP_CNTR                   = 0X8040
SWSDK_OP_JSRL                   = 0xA000
SWSDK_OP_RTSL                   = 0xC000
SWSDK_OP_JMPL                   = 0xE000

; Macros to add AVG instructions to the display list
; - all assume register Y points to the display list buffer
; - all macros use D register

        ; dx, dy signed 13 bits (-4096..4095)
        ; z unsigned 3 bits (0..7)
        .macro SWSDK_VCTR dx,dy,z
        ldd     #SWSDK_OP_VCTR | (dy&0x1FFF)
        std     ,y++
        ldd     #((z&0x07)<<13) | (dx&0x1FFF)
        std     ,y++
        .endm
        
        .macro SWSDK_HALT
        ldd     #SWSDK_OP_HALT
        std     ,y++
        .endm

        ; dx, dy signed 5 bits (-16..15)
        ; - but represent *half* the distance
        ; *** should this macro halve the parameter values???
        ; dz unsigned 3 bits (0..7)
        .macro SWSDK_SVEC dx,dy,z
        ldd     #SWSDK_OP_SVEC | ((dy&0x1F)<<8) | ((z&0x07)<<5) | ((dx&0x1F))
        std     ,y++
        .endm

        ; bit 3 of color is ignored       
        .macro SWSDK_COLOR color,zstat
        ldd     #SWSDK_OP_COLOR | ((color&0x0F)<<8) | (zstat&0xFF) 
        std     ,y++
        .endm

        ; bin (0..7) multiplies all lengths by 2^(1-bin)
        ; lin (0..255) multiplies all lengths by 1-(lin/256)
        .macro SWSDK_SCAL bin,lin
        ldd     #SWSDK_OP_SCAL | ((bin&0x07)<<8) | (lin&0xFF)
        std     ,y++
        .endm
        
        .macro SWSDK_CNTR
        ldd     #SWSDK_OP_CNTR
        std     ,y++
        .endm

        .macro SWSDK_JSRL addr
        ldd     #SWSDK_OP_JSRL | ((addr&0x3FFF)>>1)
        std     ,y++
        .endm

        .macro SWSDK_RTSL
        ldd     #SWSDK_OP_RTSL
        std     ,y++
        .endm
                
        .macro SWSDK_JMPL addr
        ldd     #SWSDK_OP_JMPL | ((addr&0x3FFF)>>1)
        std     ,y++
        .endm
        
SWSDK_BLUE                      = 1
SWSDK_GREEN                     = 2
SWSDK_CYAN                      = (SWSDK_BLUE|SWSDK_GREEN)
SWSDK_RED                       = 4
SWSDK_MAGENTA                   = (SWSDK_BLUE|SWSDK_RED)
SWSDK_YELLOW                    = (SWSDK_GREEN|SWSDK_RED)
SWSDK_WHITE                     = (SWSDK_BLUE|SWSDK_GREEN|SWSDK_RED)
                        
; Memory Map

SWSDK_VectorRAMStart            = 0x0000
SWSDK_VectorRAMEnd              = 0x2FFF
SWSDK_VectorROMStart            = 0x3000
SWSDK_VectorROMEnd              = 0x3FFF
SWSDK_CpuRAMStart               = 0x4800
SWSDK_CpuRAMEnd                 = 0x4FFF
SWSDK_MathRAMStart              = 0x5000
SWSDK_MathRAMEnd                = 0x5FFF
SWSDK_Bank1Start                = 0x6000
SWSDK_Bank1End                  = 0x7FFF
SWSDK_CpuROMStart               = 0x8000
SWSDK_CpuROMEnd                 = 0xFFFF

SWSDK_VariableStart             = SWSDK_CpuRAMEnd-0x03FF
SWSDK_Stack                     = SWSDK_VariableStart-1

; Vector ROM addresses

SWSDK_Font                      = 0x3002        ; font table & renders character set
SWSDK_Crosshairs                = 0x3300
SWSDK_Crosshairs                = 0x3300
SWSDK_BlueCornerDots            = 0x333C
SWSDK_UpperRightTurret          = 0x341A
SWSDK_LowerRightTurret          = 0x34B4
SWSDK_XWingNose                 = 0x3558
SWSDK_UpperLeftTurret           = 0x35CC
SWSDK_LowerLeftTurret           = 0x3666

; all DeathStar routines reset SCAL BIN=2, LIN=0 at the end
SWSDK_DeathStarOutline          = 0x3AD0
SWSDK_DeathStarEquator          = 0x3B4C
SWSDK_DeathStarFocusLensOutline = 0x3B64
SWSDK_DeathStarFocusLensPanels  = 0x3BB4
SWSDK_DeathStarPanels           = 0x3C0C

SWSDK_IntensityTestPattern      = 0x3D4E
SWSDK_CrossHatchAndFont         = 0x3DFA
SWSDK_SquareHatch               = 0x3E40
SWSDK_ScreenBorder              = 0x3F5C

; Hardware I/O

SWSDK_IN0                       = 0x4300
  SWSDK_IN0_COIN2n              = (1<<0)
  SWSDK_IN0_COIN1n              = (1<<1)
  SWSDK_IN0_SERVICE1n           = (1<<2)
  SWSDK_IN0_TILTn               = (1<<3)
  SWSDK_IN0_SERVICEn            = (1<<4)
  SWSDK_IN0_BUTTON4n            = (1<<6)
  SWSDK_IN0_BUTTON1n            = (1<<7)
SWSDK_IN1                       = 0x4320
  SWSDK_IN1_SERVICEn            = (1<<2)
  SWSDK_IN1_BUTTON3n            = (1<<4)
  SWSDK_IN1_BUTTON2n            = (1<<5)
  SWSDK_IN1_AVG_HALT            = (1<<6)
  SWSDK_IN1_MATH_RUN            = (1<<7)
SWSDK_DSW0                      = 0x4340
SWSDK_DSW1                      = 0x4360
SWSDK_MainRW                    = 0x4400
SWSDK_MainReadyFlag             = 0x4401
SWSDK_AVGGo                     = 0x4600
SWSDK_AVGReset                  = 0x4620
SWSDK_Watchdog                  = 0x4640
SWSDK_IRQAck                    = 0x4660
SWSDK_LED3                      = 0x4682
SWSDK_LED2                      = 0x4683
SWSDK_BankSwitch                = 0x4684
SWSDK_PRNGReset                 = 0x4685
SWSDK_LED1                      = 0x4686
SWSDK_MATHW_MW0                 = 0x4700
SWSDK_MATHW_MW1                 = 0x4701
SWSDK_MATHW_MW2                 = 0x4702
SWSDK_MATHW_PRNG                = 0x4703
SWSDK_MATHW_DVSRH               = 0x4704
SWSDK_MATHW_DVSRL               = 0x4705
SWSDK_MATHW_DVDDH               = 0x4706
SWSDK_MATHW_DVDDL               = 0x4707

; Mathbox routines (word addresses)

SWSDK_MATH_OP_00                = 0x00
SWSDK_MATH_OP_0E                = 0x0E
SWSDK_MATH_OP_1C                = 0x1C
SWSDK_MATH_OP_2A                = 0x2A

; 3x3 matrix multiplication
; |$24 $28 $2C|   |$14 $15 $16|   |$03 $04 $05|
; |$25 $29 $2D| X |$18 $19 $1A| = |$06 $07 $08|
; |$26 $2A $2E|   |$1C $1D $1E|   |$09 $0A $0B|
; and you need to set $0F = 0
SWSDK_MATH_OP_3x3MatrixMultiply = 0x40

SWSDK_MATH_OP_67                = 0x67
SWSDK_MATH_OP_77                = 0x77
SWSDK_MATH_OP_80                = 0x80

; 1x2 vector by scalar multiplication
; [$01 $02] X $00 = [$01 $02]
; and you need to set $0F = 0
SWSDK_MATH_OP_86                = 0x86

; Sound CPU commands
SWSDK_SND_OP_00                                         = 0x00
SWSDK_SND_OP_TEST_TUNE_01                               = 0x01    ; (pokey 1,2)
SWSDK_SND_OP_TEST_TUNE_02                               = 0x02    ; (pokey 3,4)
; TMS5220 sounds
SWSDK_SND_OP_ALWAYS                                     = 0x03    ; Obi-Wan
SWSDK_SND_OP_WOOKIEE_GROWL                              = 0x04    ; Chewbacca
SWSDK_SND_OP_THE_FORCE_WILL_BE_WITH_YOU_ALWAYS          = 0x05    ; Obi-Wan
SWSDK_SND_OP_THE_FORCE_WIL_BE_WITH_YOU                  = 0x06    ; Obi-Wan
SWSDK_SND_OP_GREAT_SHOT_KID_THAT_WAS_ONE_IN_A_MILLION   = 0x07    ; 
SWSDK_SND_OP_I_HAVE_YOU_NOW                             = 0x08    ; Darth Vader
SWSDK_SND_OP_IM_HIT_BUT_NOT_BAD_R2___CAN_DO_WITH_IT     = 0x09    ; Luke?
SWSDK_SND_OP_IM_ON_THE_LEADER                           = 0x0B    ; Darth Vader
SWSDK_SND_OP_LET_GO_LUKE                                = 0x0C    ; Obi-Wan
SWSDK_SND_OP_IVE_LOST_R2                                = 0x0D    ; Luke?
SWSDK_SND_OP_BLEEPS                                     = 0x0E    ; 
SWSDK_SND_OP_R2_TRY_TO_INCREASE_THE_POWER               = 0x0F    ; Luke?
SWSDK_SND_OP_RED_5_STANDING_BY                          = 0x10    ; Red 5
SWSDK_SND_OP_REMEMBER                                   = 0x11    ; Obi-Wan
SWSDK_SND_OP_I_CANT_SHAKE_HIM                           = 0x12    ; Luke
SWSDK_SND_OP_LOOK_AT_THE_SIZE_OF_THAT_THING             = 0x13    ; 
SWSDK_SND_OP_STAY_IN_ATTACK_FORMATION                   = 0x15    ; Darth Vader
SWSDK_SND_OP_THE_FORCE_IS_STRONG_WITH_THIS_ONE          = 0x16    ; Darth Vader
SWSDK_SND_OP_THIS_IS_RED_5_IM_GOING_IN                  = 0x17    ; Red 5
SWSDK_SND_OP_LUKE_TRUST_ME                              = 0x18    ; Obi-Wan
SWSDK_SND_OP_USE_THE_FORCE_LUKE                         = 0x19    ; Obi-Wan
SWSDK_SND_OP_YAHOO_YOURE_ALL_CLEAR_KID                  = 0x1A    ; 
; Pokey 3,4 sounds
SWSDK_SND_OP_STAR_WARS_THEME                            = 0x1B
SWSDK_SND_OP_STAR_WARS_THEME_CANTINA                    = 0x1C
SWSDK_SND_OP_STAR_WARS_THEME_DARK_SIDE                  = 0x1D
SWSDK_SND_OP_STAR_WARS_THEME_TWEENER                    = 0x1E
SWSDK_SND_OP_STAR_WARS_END_STAGE                        = 0x1F
SWSDK_SND_OP_MUSIC_6                                    = 0x20
SWSDK_SND_OP_MUSIC_7                                    = 0x21
SWSDK_SND_OP_MUSIC_8                                    = 0x22
SWSDK_SND_OP_LASER_FIRE_1                               = 0x23
SWSDK_SND_OP_MUSIC_9                                    = 0x24
SWSDK_SND_OP_MUSIC_10                                   = 0x25
; Pokey 1,2 sounds
SWSDK_SND_OP_EXPLOSION                                  = 0x26
SWSDK_SND_OP_DOUBLE_EXPLOSION                           = 0x27
SWSDK_SND_OP_NOISE_1                                    = 0x28
SWSDK_SND_OP_NOISE_2                                    = 0x29
SWSDK_SND_OP_NEARBY_ENEMY_FIRE                          = 0x2A
SWSDK_SND_OP_NOISE_3                                    = 0x2C
SWSDK_SND_OP_LASER_FIRE_2                               = 0x2D
SWSDK_SND_OP_LASER_FIRE_3                               = 0x2E
SWSDK_SND_OP_R2D2_1                                     = 0x2F
SWSDK_SND_OP_R2D2_2                                     = 0x30
SWSDK_SND_OP_R2D2_3                                     = 0x31
SWSDK_SND_OP_R2D2_4                                     = 0x32
SWSDK_SND_OP_NOISE_4                                    = 0x33
SWSDK_SND_OP_NOISE_5                                    = 0x34
SWSDK_SND_OP_EXPLOSION_3                                = 0x35
SWSDK_SND_OP_LASER_FIRE_4                               = 0x36
SWSDK_SND_OP_NOISE_6                                    = 0x38
SWSDK_SND_OP_LASER_FIRE_5                               = 0x39
SWSDK_SND_OP_LASER_FIRE_6                               = 0x3A
SWSDK_SND_OP_NOISE_7                                    = 0x3B

        .macro SWSDK_AVG_HALTED
        lda     SWSDK_IN1
        bita    #SWSDK_IN1_AVG_HALT
        .endm
        
        .macro SWSDK_GO_AVG
        sta     SWSDK_AVGGo
        .endm
        
        .macro SWSDK_RESET_AVG
        sta     SWSDK_AVGReset
        .endm
        
        .macro SWSDK_KICK_WDOG
        sta     SWSDK_Watchdog
        .endm

        .macro SWSDK_ACK_IRQ
        sta     SWSDK_IRQAck
        .endm

        .macro SWSDK_RESET_PRNG
        sta     SWSDK_PRNGReset
        .endm

        ; imported memory variables
        
        .globl  SWSDK_in0_shadow
        .globl  SWSDK_in1_shadow
        .globl  SWSDK_dsw0_shadow
        .globl  SWSDK_dsw1_shadow
        
        ; imported routines
        
        .globl  SWSDK_Init
        .globl  SWSDK_RenderString
        .globl  SWSDK_RenderInt8Hex
        .globl  SWSDK_ButtonState
        .globl  SWSDK_GoMathAndWait
        .globl  SWSDK_WriteSoundCmd
        .globl  SWSDK_IRQ
