;
; Star Wars SDK
; - Vectex emulation layer

        .list   (meb)                   ; macro expansion binary
        .module vectrex

.include "swsdk.inc"
.include "vectrex.inc"

				.area		DATA (ABS,OVR)
        .org    SWSDK_CpuRAMStart+0x200
        
fred::
        .ds     1

				.bank   ROM (BASE=0xE000,SIZE=0x1FE0)
       	.area   ROM (REL,CON,BANK=ROM)

Select_Game::
        rts
