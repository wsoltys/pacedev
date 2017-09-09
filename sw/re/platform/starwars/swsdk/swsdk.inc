; Star Wars SDK
;

SWSDK_OP_VCTR 									= 0x0000
SWSDK_OP_HALT										= 0x2000
SWSDK_OP_SVEC										= 0x4000
SWSDK_OP_COLOR									= 0x6000
SWSDK_OP_SCAL										= 0x7000
SWSDK_OP_CNTR										= 0X8040
SWSDK_OP_JSRL 									= 0xA000
SWSDK_OP_RTSL										= 0xC000
SWSDK_OP_JMPL										= 0xE000

; Macros to add AVG instructions to the display list
; - all assume register Y points to the display list buffer
; - all macros use D register

				; dx, dy signed 13 bits (-4096..4095)
				; z unsigned 3 bits (0..7)
				.macro SWSDK_VCTR dx,dy,z
				ldd			#SWSDK_OP_VCTR | (dy&0x1FFF)
				std			,y++
				ldd			#((z&0x07)<<13) | (dx&0x1FFF)
				std			,y++
				.endm
				
				.macro SWSDK_HALT
				ldd			#SWSDK_OP_HALT
				std			,y++
				.endm

				; dx, dy signed 5 bits (-32..31)
				; - but represent *half* the distance
				; *** should this macro halve the parameter values???
				; dz unsigned 3 bits (0..7)
				.macro SWSDK_SVEC dx,dy,z
				ldd			#SWSDK_OP_SVEC | ((dy&0x1F)<<8) | ((z&0x07)<<5) | ((dx&0x1F))
				std			,y++
				.endm

				; bit 3 of color is ignored				
				.macro SWSDK_COLOR color,zstat
				ldd			#SWSDK_OP_COLOR | ((color&0x0F)<<8) | (zstat&0xFF) 
				std			,y++
				.endm

				; bin (0..7) multiplies all lengths by 2^(1-bin)
				; lin (0..255) multiplies all lengths by 1-(lin/256)
				.macro SWSDK_SCAL bin,lin
				ldd			#SWSDK_OP_SCAL | ((bin&0x07)<<8) | (lin&0xFF)
				std			,y++
				.endm
				
				.macro SWSDK_CNTR
				ldd			#SWSDK_OP_CNTR
				std			,y++
				.endm

				.macro SWSDK_JSRL addr
				ldd			#SWSDK_OP_JSRL | ((addr&0x3FFF)>>1)
				std			,y++
				.endm

				.macro SWSDK_RTSL
				ldd			#SWSDK_OP_RTSL
				std			,y++
				.endm
								
				.macro SWSDK_JMPL addr
				ldd			#SWSDK_OP_JMPL | ((addr&0x3FFF)>>1)
				std			,y++
				.endm
				
SWSDK_BLUE											= 1
SWSDK_GREEN											= 2
SWSDK_CYAN											= (SWSDK_BLUE|SWSDK_GREEN)
SWSDK_RED												= 4
SWSDK_MAGENTA										= (SWSDK_BLUE|SWSDK_RED)
SWSDK_YELLOW										= (SWSDK_GREEN|SWSDK_RED)
SWSDK_WHITE											= (SWSDK_BLUE|SWSDK_GREEN|SWSDK_RED)
												
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

; Vector ROM addresses

SWSDK_Font 											= 0x3002				; font table & renders character set
SWSDK_Crosshairs 								= 0x3300
SWSDK_UpperRightTurret					= 0x341A
SWSDK_LowerRightTurret					= 0x34B4
SWSDK_XWingNose									= 0x3558
SWSDK_UpperLeftTurret						= 0x35CC
SWSDK_LowerLeftTurret						= 0x3666

; all DeathStar routines reset SCAL BIN=2, LIN=0 at the end
SWSDK_DeathStarOutline					= 0x3AD0
SWSDK_DeathStarEquator					= 0x3B4C
SWSDK_DeathStarFocusLensOutline	= 0x3B64
SWSDK_DeathStarFocusLensPanels	= 0x3BB4
SWSDK_DeathStarPanels						= 0x3C0C


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
				.globl	SWSDK_RenderString
