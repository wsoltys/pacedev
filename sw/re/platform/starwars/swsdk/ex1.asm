;
;	ARCADE ASTEROIDS
; - ported from the original arcade version
; - by tcdev 2017 msmcdoug@gmail.com
; - graphics kindly supplied by Norbert Kehrer
;
				.list		(meb)										; macro expansion binary
       	.area   _CODE (ABS,OVR)
				.module ex1

.include "swsdk.inc"

; *** BUILD OPTIONS
;.define BUILD_OPT_PROFILE
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

        .org    0xE000

RESET::
        
        SWSDK_KICK_WDOG
				bra			RESET

IRQ::
				rti
