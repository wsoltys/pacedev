;
; Star Wars SDK
; msmcdoug@gmail.com
;

SWSDK_OP_VCTR                   = 0x0000
SWSDK_OP_HALT                   = 0x2000
SWSDK_OP_SVEC                   = 0x4000
SWSDK_OP_COLOR                  = 0x6000
SWSDK_OP_SCAL                   = 0x7000
SWSDK_OP_CNTR                   = 0X8040
SWSDK_OP_JSRL                   = 0xA000
SWSDK_OP_RTSL                   = 0xC000
SWSDK_OP_JMPL                   = 0xE000

        ; dx, dy signed 13 bits (-4096..4095)
        ; z unsigned 3 bits (0..7)
        .macro SWSDK_VCTR dx,dy,z
        .dw     #SWSDK_OP_VCTR | (dy&0x1FFF)
        .dw     #((z&0x07)<<13) | (dx&0x1FFF)
        .endm

        ; dx, dy signed 5 bits (-16..15)
        ; - but represent *half* the distance
        ; *** should this macro halve the parameter values???
        ; dz unsigned 3 bits (0..7)
        .macro SVEC dx,dy,z
        .dw     #SWSDK_OP_SVEC | ((dy&0x1F)<<8) | ((z&0x07)<<5) | ((dx&0x1F))
        .endm

        .macro RTSL
        .dw			#SWSDK_OP_RTSL
        .endm
