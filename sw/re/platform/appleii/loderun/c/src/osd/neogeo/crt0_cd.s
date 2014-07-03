* $Id: crt0_cd.s,v 1.2 2001/04/13 10:05:56 fma Exp $

********************* Vector Definitions *********************
IRQ1			= _irq1_handler
IRQ2			= _irq2_handler
IRQ3			= _irq3_handler
DUMMY			= _dummy_exc_handler
TRAP00			= _dummy_exc_handler
TRAP01			= _dummy_exc_handler
TRAP02			= _dummy_exc_handler
TRAP03			= _dummy_exc_handler
TRAP04			= _dummy_exc_handler
TRAP05			= _dummy_exc_handler
TRAP06			= _dummy_exc_handler
TRAP07			= _dummy_exc_handler
TRAP08			= _dummy_exc_handler
TRAP09			= _dummy_exc_handler
TRAP10			= _dummy_exc_handler
TRAP11			= _dummy_exc_handler
TRAP12			= _dummy_exc_handler
TRAP13			= _dummy_exc_handler
TRAP14			= _dummy_exc_handler
TRAP15			= _dummy_exc_handler
ENTRY_POINT1	= _start
ENTRY_POINT2	= _dummy_config_handler
ENTRY_POINT3	= _dummy_config_handler
ENTRY_POINT4	= _dummy_config_handler

************************ Definitions *************************
CDDA_FLAG 		= 0
GUID			= 0x1234
DEBUG_DIPS		= 0x10E000
LOGO_START		= 1

	.include	"../system/common_crt0_cd.s"

* Names MUST be 16 characters long
*           <---------------->
_jp_config:
	.ascii	"NEO THUNDER     "
	.long	0xFFFFFFFF
	.word	0x0364
	.byte	0x14, 0x13, 0x24, 0x01

_us_config:
	.ascii	"NEO THUNDER     "
	.long	0xFFFFFFFF
	.word	0x0364
	.byte	0x14, 0x13, 0x24, 0x01

_sp_config:
	.ascii	"NEO THUNDER     "
	.long	0xFFFFFFFF
	.word	0x0364
	.byte	0x14, 0x13, 0x24, 0x01
	
	.align	4

	.end

	