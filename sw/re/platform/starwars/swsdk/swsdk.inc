; Star Wars SDK
;

; Vector ROM addresses

SWSDK_Font 											= 0x3002
SWSDK_Crosshairs 								= 0x3300
SWSDK_UpperRightTurret					= 0x341A
SWDSK_LowerRightTurret					= 0x34B4
SWDSK_XWingNose									= 0x3558
SWDSK_UpperLeftTurret						= 0x35CC
SWDSK_LowerLeftTurret						= 0x3666

SWDSK_DeathStarOutline					= 0x3AD0
SWDSK_DeathStarEquator					= 0x3B4C
SWDSK_DeathStarFocusLensOutline	= 0x3B64
SWDSK_DeathStarFocusLensPanels	= 0x3BB4
SWDSK_DeathStarPanels						= 0x3C0C

; Hardware I/O

SWSDK_Watchdog									= 0x4640

				.macro SWSDK_KICK_WDOG
				sta			SWSDK_Watchdog
				.endm
