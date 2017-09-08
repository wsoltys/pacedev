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

; Memory Map

SWSDK_VectorRAMStart						= 0x0000
SWSDK_VectorRAMEnd							= 0x2FFF
SWSDK_VectorROMStart						= 0x3000
SWSDK_VectorROMEnd							= 0x3FFF
SWSDK_CpuRAMStart								= 0x4800
SWSDK_CpuRAMEnd									= 0x4FFF
SWSDK_MathRAMStart							= 0x5000
SWSDK_MathRAMEnd								= 0x5FFF
SWSDK_Bank1Start								= 0x6000
SWSDK_Bank1End									= 0x7FFF
SWSDK_CpuROMStart								= 0x8000
SWSDK_CpuROMEnd									= 0xFFFF

; Hardware I/O

SWSDK_AVGGo											= 0x4600
SWSDK_AVGReset									= 0x4620
SWSDK_Watchdog									= 0x4640
SWSDK_IRQAck										= 0x4660
SWSDK_LED3											= 0x4682
SWSDK_LED2											= 0x4683
SWSDK_BankSwitch								= 0x4684
SWSDK_PRNGReset									= 0x4685
SWSDK_LED1											= 0x4686
SWSDK_PRNG											= 0x4703

				.macro SWSDK_RESET_AVG
				sta			SWSDK_AVGReset
				.endm
				
				.macro SWSDK_KICK_WDOG
				sta			SWSDK_Watchdog
				.endm

				.macro SWSDK_ACK_IRQ
				sta			SWSDK_IRQAck
				.endm

				.macro SWSDK_RESET_PRNG
				sta			SWSDK_PRNGReset
				.endm
				
				.globl	SWSDK_Init
