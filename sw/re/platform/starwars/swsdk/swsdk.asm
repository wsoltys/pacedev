
				.list		(meb)										; macro expansion binary
       	.area   _CODE (ABS, OVR)
				.module swsdk
				
.include "swsdk.inc"

; *** BUILD OPTIONS
.define BUILD_OPT_NO_SPLASH
; *** end of BUILD OPTIONS

; *** derived - do not edit
; *** end of derived

        .org    0xF000

SWSDK_Init::
				rts
