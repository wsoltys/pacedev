`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    08:51:54 11/08/06
// Project Name:   CoCo3FPGA
//
// CoCo3 in an FPGA
// Based on the Spartan 3 Starter board by Digilent Inc.
//
// Revision: 0.99 13:37:34 08/17/07
////////////////////////////////////////////////////////////////////////////////

module coco3fpga(
CLK50MHZ,
// RAM, ROM, and Peripherials
RAM_DATA0_I,				// 16 bit data bus to RAM 0
RAM_DATA0_O,
RAM_DATA1_I,				// 16 bit data bus to RAM 1
RAM_DATA1_O,
RAM_ADDRESS,			// Common address
RAM_RW_N,				// Common RW
RAM0_CS_N,				// Chip Select for RAM 0
RAM1_CS_N,				// Chip Select for RAM 1
RAM0_BE0_N,				// Byte Enable for RAM 0
RAM0_BE1_N,				// Byte Enable for RAM 0
RAM1_BE0_N,				// Byte Enable for RAM 1
RAM1_BE1_N,				// Byte Enable for RAM 1
RAM_OE_N,
// VGA
RED1,
GREEN1,
BLUE1,
RED0,
GREEN0,
BLUE0,
H_SYNC,
V_SYNC,
// PS/2
ps2_clk,
ps2_data,
//Serial Ports
TXD1,
RXD1,
TXD2,
RXD2,
// Display
DIGIT_N,
SEGMENT_N,
// LEDs
LED,
// CoCo Perpherial
SPEAKER,
PADDLE,
P_SWITCH,
// Extra Buttons and Switches
SWITCH,
BUTTON,
PH_2
);

input				CLK50MHZ;

// Main RAM Common
output [17:0]	RAM_ADDRESS;
output			RAM_RW_N;
reg				RAM_RW_N;

// Main RAM bank 0
input	[15:0]	RAM_DATA0_I;
output [15:0] RAM_DATA0_O;
wire [15:0] RAM_DATA0_O;
output			RAM0_CS_N;
output			RAM0_BE0_N;
output			RAM0_BE1_N;
output			RAM_OE_N;

// Main RAM bank 1
input	[15:0]	RAM_DATA1_I;
output [15:0]	RAM_DATA1_O;
wire [15:0] RAM_DATA1_O;
// output	[15:0]	RAM_DATA1;			// Testing only
output			RAM1_CS_N;
output			RAM1_BE0_N;
output			RAM1_BE1_N;

// VGA
output			RED1;
output			GREEN1;
output			BLUE1;
output			RED0;
output			GREEN0;
output			BLUE0;
output			H_SYNC;
output			V_SYNC;

// PS/2
input 			ps2_clk;
input				ps2_data;

// Serial Ports
output			TXD1;
input				RXD1;
output			TXD2;
reg				TXD2;
input				RXD2;

// Display
output [3:0]	DIGIT_N;
reg	 [3:0]	DIGIT_N;
output [7:0]	SEGMENT_N;

// LEDs
output [7:0]	LED;
// reg		[7:0]	LED;

// CoCo Perpherial
output			SPEAKER;
input		[7:0]	PADDLE;
input		[3:0]	P_SWITCH;
wire				JSTICK;

// Extra Buttons and Switches
input [7:0]		SWITCH;				//  7 LED
											//  6 LED
											//  5 Single step
											//  4 single step
											//  3 MPI [1]
											//  2 MPI [0]
											//  1 CPU_SPEED[1]
											//  0 CPU_SPEED[0]

input [3:0]		BUTTON;				//  3 RESET
											//  2 Not used
											//  1 Closed Apple
											//  0 Open Apple 

output			PH_2;
reg				PH_2;

reg				RESET_N;
reg	[15:0]	RESET_CLK;
wire	[15:0]	ADDRESS;
wire	[6:0]		BLOCK_ADDRESS;
wire				RW_N;
wire	[7:0]		DATA_IN;
wire	[7:0]		DATA_OUT;
wire				VMA;

reg	[5:0]		CLK;

// Gime Regs
reg [1:0]	ROM;
reg			RAM;
reg			ST_SCS;
reg			VEC_PAG_RAM;
reg			GIME_FIRQ;
reg			GIME_IRQ;
reg			MMU_EN;
reg			COCO1;
reg	[2:0]	V;
reg	[6:0]	VERT;
reg			RATE;
reg			TIMER_INS;
reg			MMU_TR;
reg			IRQ_TMR;
reg			IRQ_HBORD;
reg			IRQ_VBORD;
reg			IRQ_SERIAL;
reg			IRQ_KEY;
reg			IRQ_CART;
reg			FIRQ_TMR;
reg			FIRQ_HBORD;
reg			FIRQ_VBORD;
reg			FIRQ_SERIAL;
reg			FIRQ_KEY;
reg			FIRQ_CART;
reg [3:0]	TMR_MSB;
reg [7:0]	TMR_LSB;
reg			TMR_ENABLE;
reg			GRMODE;
reg			DESCEN;
reg			BLINK;
reg			MONO;
reg [2:0]	LPR;
reg [1:0]	LPF;
reg [2:0]	HRES;
reg [1:0]	CRES;
reg			VBANK;
reg [5:0]	BDR_PAL;
reg [3:0]	VERT_FIN_SCRL;
reg [7:0]	SCRN_START_MSB;
reg [7:0]	SCRN_START_LSB;
reg [6:0]	HOR_OFFSET;
reg			HVEN;
reg [5:0]	PALETTE0;
reg [5:0]	PALETTE1;
reg [5:0]	PALETTE2;
reg [5:0]	PALETTE3;
reg [5:0]	PALETTE4;
reg [5:0]	PALETTE5;
reg [5:0]	PALETTE6;
reg [5:0]	PALETTE7;
reg [5:0]	PALETTE8;
reg [5:0]	PALETTE9;
reg [5:0]	PALETTEA;
reg [5:0]	PALETTEB;
reg [5:0]	PALETTEC;
reg [5:0]	PALETTED;
reg [5:0]	PALETTEE;
reg [5:0]	PALETTEF;
reg			HSYNC_INT;
reg			HSYNC_POL;
reg [1:0]	SEL;
reg [7:0]	KEY_COLUMN;
reg			VSYNC_INT;
reg			VSYNC_POL;
reg [3:0]	VDG_CONTROL;
reg			CSS;
reg			CART_INT;
reg			CART_POL;
reg			CD_INT;
reg			CD_POL;
reg			CAS_MTR;
reg			SOUND_EN;
wire [17:0]	VIDEO_ADDRESS;
wire			READMEM;
wire			ROM_RW;
wire	[7:0]	DOA_F8;
wire			DOP_F8;
wire			ENA_F8;
wire	[7:0]	DOA_F0;
wire			DOP_F0;
wire			ENA_F0;
wire	[7:0]	DOA_E8;
wire			DOP_E8;
wire			ENA_E8;
wire	[7:0]	DOA_E0;
wire			DOP_E0;
wire			ENA_E0;
wire	[7:0]	DOA_D8;
wire			DOP_D8;
wire			ENA_D8;
wire	[7:0]	DOA_D0;
wire			DOP_D0;
wire			ENA_D0;
wire	[7:0]	DOA_C8;
wire			DOP_C8;
wire			ENA_C8;
wire	[7:0]	DOA_C0;
wire			DOP_C0;
wire			ENA_C0;
wire	[7:0]	DOA_B8;
wire			DOP_B8;
wire			ENA_B8;
wire	[7:0]	DOA_B0;
wire			DOP_B0;
wire			ENA_B0;
wire	[7:0]	DOA_A8;
wire			DOP_A8;
wire			ENA_A8;
wire	[7:0]	DOA_A0;
wire			DOP_A0;
wire			ENA_A0;
wire	[7:0]	DOA_98;
wire			DOP_98;
wire			ENA_98;
wire	[7:0]	DOA_90;
wire			DOP_90;
wire			ENA_90;
wire	[7:0]	DOA_88;
wire			DOP_88;
wire			ENA_88;
wire	[7:0]	DOA_80;
wire			DOP_80;
wire			ENA_80;
wire	[7:0]	DOA_DD8;
wire			DOP_DD8;
wire			ENA_DSKD8;
wire	[7:0]	DOA_DD0;
wire			DOP_DD0;
wire			ENA_DSKD0;
wire	[7:0]	DOA_DC8;
wire			DOP_DC8;
wire			ENA_DSKC8;
wire	[7:0]	DOA_DC0;
wire			DOP_DC0;
wire			ENA_DSKC0;
reg	[1:0]	MPI_SCS;				// IO select
reg	[1:0]	MPI_CTS;				// ROM select
reg			SBS;
reg	[7:0]	SAM00;
reg	[7:0]	SAM01;
reg	[7:0]	SAM02;
reg	[7:0]	SAM03;
reg	[7:0]	SAM04;
reg	[7:0]	SAM05;
reg	[7:0]	SAM06;
reg	[7:0]	SAM07;
reg	[7:0]	SAM10;
reg	[7:0]	SAM11;
reg	[7:0]	SAM12;
reg	[7:0]	SAM13;
reg	[7:0]	SAM14;
reg	[7:0]	SAM15;
reg	[7:0]	SAM16;
reg	[7:0]	SAM17;
reg	[4:0]	KB_CLK;
reg			CAPS_CLK;
reg	[63:0] KEY;
reg			F1;
reg			F2;
wire	[7:0]	SCAN;
wire			PRESS;
wire			EXTENDED;
wire	[7:0]	KEYBOARD_IN;
reg			DDR1;
reg			DDR2;
reg			DDR3;
reg			DDR4;
wire	[7:0]	DATA_REG1;
wire	[7:0]	DATA_REG2;
wire	[7:0]	DATA_REG3;
wire	[7:0]	DATA_REG4;
reg	[7:0]	DD_REG1;
reg	[7:0]	DD_REG2;
reg	[7:0]	DD_REG3;
reg	[7:0]	DD_REG4;
wire			ROM_SEL;
reg	[5:0]	DTOA_CODE;
reg	[6:0]	DTOA_LATCH;
reg	[6:0]	DIG_STATE;
reg			DIG_SOUND;
reg	[1:0]	B_SWITCH;
wire 			H_FLAG;

//reg	[15:0]	MEM_DISPLAY;
//reg	[15:0]	CPU_DISPLAY;
//reg	[7:0]		LED_1;
//reg	[7:0]		LED_2;
//reg				READ_WRITE;
reg	[2:0]		SWITCH_L;

wire				KEY_INT_RAW;

reg				HS_INT;
reg	[2:0]		HS_INT_SM;
reg				VS_INT;
reg	[2:0]		VS_INT_SM;
reg				CD1_INT;
reg	[2:0]		CD1_INT_SM;
reg				CART1_INT;
reg	[2:0]		CART1_INT_SM;

reg				TMR_INT;
reg	[2:0]		TMR_INT_SM;
reg				HBORD_INT;
reg	[2:0]		HBORD_INT_SM;
reg				VBORD_INT;
reg	[2:0]		VBORD_INT_SM;
reg				CD3_INT;
reg	[2:0]		CD3_INT_SM;
reg				KEY_INT;
reg	[2:0]		KEY_INT_SM;
reg				CAR_INT;
reg	[2:0]		CAR_INT_SM;

reg				TMR_FINT;
reg	[2:0]		TMR_FINT_SM;
reg				HBORD_FINT;
reg	[2:0]		HBORD_FINT_SM;
reg				VBORD_FINT;
reg	[2:0]		VBORD_FINT_SM;
reg				CD3_FINT;
reg	[2:0]		CD3_FINT_SM;
reg				KEY_FINT;
reg	[2:0]		KEY_FINT_SM;
reg				CAR_FINT;
reg	[2:0]		CAR_FINT_SM;

wire				CPU_IRQ;
wire				CPU_FIRQ;
wire				CPU_NMI;
reg	[2:0]		DIV_7;
reg	[11:0]	TIMER;
wire				TMR_CLK;
wire				CD_IRQ;
wire				SER_IRQ;
reg				CART_IRQ;
reg	[4:0]		COM1_CLOCK;
wire	[7:0]		DATA_COM1;
wire				COM1_EN;
wire				RTS1;
reg	[1:0]		XSTATE;
reg	[7:0]		XART;

// Clock
//FFCO CCYY  Century / Year
//FFC2 MMDD  Month / Day
//FFC4 WWHH  Day of week / Hour
//FFC6 MMSS  Minute / Second
reg	[4:0]		CENT;
reg	[6:0]		YEAR;
reg	[3:0]		MNTH;
reg	[4:0]		DMTH;
reg	[2:0]		DWK;
reg	[4:0]		HOUR;
reg	[5:0]		MIN;
reg	[5:0]		SEC;
reg	[5:0]		CLICK;
reg				TICK;

assign LED =	8'h00;

always @ (posedge H_SYNC)					// Anything > 200 HZ
 case(DIGIT_N)
  4'b1110:	DIGIT_N <= 4'b1101;
  4'b1101:	DIGIT_N <= 4'b1011;
  4'b1011:	DIGIT_N <= 4'b0111;
  default:  DIGIT_N <= 4'b1110;
 endcase

assign SEGMENT_N =	(DIGIT_N == 4'b1110) ?	{RESET_N, 7'b0100011}:	//o
							(DIGIT_N == 4'b1101) ?	{RESET_N, 7'b1000110}:	//C
							(DIGIT_N == 4'b1011) ?	{RESET_N, 7'b0100011}:	//o
															{RESET_N, 7'b1000110};	//C

/*****************************************************************************
* RAM signals
******************************************************************************/
assign	RAM_ADDRESS =	({PH_2, READMEM} == 2'b01)	?	{VIDEO_ADDRESS}:
																		{BLOCK_ADDRESS[5:0], ADDRESS[12:1]};

assign	BLOCK_ADDRESS =	({VEC_PAG_RAM, ADDRESS[15:8]} == 9'h1FE)		?	7'h3F:			// FE00-FEFF Vector page is RAM
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h10)	?	SAM00[6:0]:		// 10 000X	0000-1FFF
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h11)	?	SAM01[6:0]:		// 10 001X	2000-3FFF
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h12)	?	SAM02[6:0]:		// 10 010X	4000-5FFF
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h13)	?	SAM03[6:0]:		// 10 011X	6000-7FFF
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h14)	?	SAM04[6:0]:		// 10 100X	8000-9FFF
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h15)	?	SAM05[6:0]:		// 10 101X	A000-BFFF
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h16)	?	SAM06[6:0]:		// 10 110X	C000-DFFF
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h17)	?	SAM07[6:0]:		// 10 111X	E000-FEFF
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h18)	?	SAM10[6:0]:		// 11 000X
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h19)	?	SAM11[6:0]:		// 11 001X
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h1A)	?	SAM12[6:0]:		// 11 010X
									({MMU_EN, MMU_TR, ADDRESS[15:13]} == 5'h1B)	?	SAM13[6:0]:		// 11 011X
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h1C)	?	SAM14[6:0]:		// 11 100X
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h1D)	?	SAM15[6:0]:		// 11 101X
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h1E)	?	SAM16[6:0]:		// 11 110X
						({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'h1F)	?	SAM17[6:0]:		// 11 111X
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b101100)		?  7'h40:			// Slot 2 ROM 8000-9FFF
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b101101)		?  7'h41:			// Slot 2 ROM A000-BFFF
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b101110)		?  7'h42:			// Slot 2 ROM C000-DFFF
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b101111)		?  7'h43:			// Slot 2 ROM E000-FEFF
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110100)		?  7'h44:			// Slot 3 ROM 8000-9FFF
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110101)		?  7'h45:			// Slot 3 ROM A000-BFFF
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110110)		?  7'h46:			// Slot 3 ROM C000-DFFF
						({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110111)		?  7'h47:			// Slot 3 ROM E000-FEFF
// Disable slot 0
//									({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b100100)?  7'h48:				// Slot 4 ROM 8000-9FFF
//									({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b100101)?  7'h49:				// Slot 4 ROM A000-BFFF
//									({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b100110)?  7'h4A:				// Slot 4 ROM C000-DFFF
//									({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b100111)?  7'h4B:				// Slot 4 ROM E000-FEFF
																									{4'b0111,ADDRESS[15:13]};

// assign RAM_RW_N = ({PH_2, RW_N} == 2'b10)	?	1'b0:
//															1'b1;
assign	RAM0_CS_N =  	({READMEM, ROM_SEL}== 2'b01)								?	1'b1:		// Any external ROM
								({READMEM, RAM, ADDRESS[15:14]} == 4'b0010)			?	1'b1:		// ROM (8000-BFFF)
								({READMEM, RAM, ADDRESS[15:13]} == 5'b00110)			?	1'b1:		// ROM (C000-DFFF)
								({READMEM, RAM, ADDRESS[15:12]} == 6'b001110)		?	1'b1:		// ROM (E000-EFFF)
								({READMEM, RAM, ADDRESS[15:11]} == 7'b0011110)		?	1'b1:		// ROM (F000-F7FF)
								({READMEM, RAM, ADDRESS[15:10]} == 8'b00111110)		?	1'b1:		// ROM (F800-FBFF)
								({READMEM, RAM, ADDRESS[15:9]}  == 9'b001111110)	?	1'b1:		// ROM (FC00-FDFF)
								({READMEM, ADDRESS[15:8]}== 9'h0FF)						?	1'b1:		// Hardware (FF00-FFFF)
								({READMEM, BLOCK_ADDRESS[6]} == 2'b01)					?	1'b1:		// 512K - 1M
																										1'b0;		//   0K - 512K

assign	RAM0_BE0_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										ADDRESS[0];		// This is backwards

assign	RAM0_BE1_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										~ADDRESS[0];	// This is backwards

assign	RAM1_CS_N =	//		({ROM_SEL, MPI_CTS} == 3'b100)						?	1'b1:		// Slot 1 ROM (EMPTY) Turned off in ROM_SEL
								({READMEM, ROM_SEL, MPI_CTS} == 4'b0111)				?	1'b1:		// Slot 4 ROM (DISK)
								({READMEM, RAM, ADDRESS[15:14]} == 4'b0010)			?	1'b1:		// Internal ROM (8000-BFFF)
								({READMEM, RAM, ADDRESS[15:13]} == 5'b00110)			?	1'b1:		// Internal ROM (C000-DFFF)
								({READMEM, RAM, ADDRESS[15:12]} == 6'b001110)		?	1'b1:		// Internal ROM (E000-EFFF)
								({READMEM, RAM, ADDRESS[15:11]} == 7'b0011110)		?	1'b1:		// Internal ROM (F000-F7FF)
								({READMEM, RAM, ADDRESS[15:10]} == 8'b00111110)		?	1'b1:		// Internal ROM (F800-FBFF)
								({READMEM, RAM, ADDRESS[15:9]}  == 9'b001111110)	?	1'b1:		// Internal ROM (FC00-FDFF)
								({READMEM, ADDRESS[15:8]}==9'h0FF)						?	1'b1:		// Top 256 Bytes
								({READMEM, BLOCK_ADDRESS[6]} == 2'b00)					?	1'b1:		// 0K - 512K
																										1'b0;		// RAM

assign	RAM1_BE0_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										ADDRESS[0];		// This is backwards

assign	RAM1_BE1_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										~ADDRESS[0];	// This is backwards

assign	RAM_OE_N = ~(READMEM | RW_N);

//assign	RAM_DATA0[15:0] = (({READMEM, RW_N}) == 2'b00)	?	{DATA_OUT, DATA_OUT}:
//																				16'bZZZZZZZZZZZZZZZZ;
assign	RAM_DATA0_O[15:0] = {DATA_OUT, DATA_OUT};

//assign	RAM_DATA1[15:0] = (({READMEM, RW_N}) == 2'b00)	?	{DATA_OUT, DATA_OUT}:
//																				16'bZZZZZZZZZZZZZZZZ;
assign	RAM_DATA1_O[15:0] = {DATA_OUT, DATA_OUT};

/*****************************************************************************
* ROM signals
******************************************************************************/
// assign	MPI = SWITCH[3:2] ;

// ROM_SEL is 1 when the system is accessing any cartridge "ROM" including the
// Last 3 slots of the MPI, this is two ROM slots and the Disk Controller ROM,
// slot 0 is empty so we can boot without a ROM
assign	ROM_SEL =	(			 ADDRESS[15:8] 	== 8'b11111110)?	1'b0:	// Top 256 bytes (Hardware and Vectors)
							(							RAM	== 1'b1)			?	1'b0:	// All RAM Mode
							( ROM 							== 2'b10)		?	1'b0:	// All Internal
							( MPI_CTS						== 2'b00)		?	1'b0:	// ROM Slot 0 (Empty)
							({ROM[1], ADDRESS[15:14]}	== 3'b010)		?	1'b0: // 16 Internal+16 external Lower
							(			 ADDRESS[15]		== 1'b0)			?	1'b0:	// Lower 32K
																						1'b1;

assign	ENA_F8 =	({RAM, ROM, ADDRESS[15:8]} == 11'b01011111000)	?	1'b1:	// Internal ROM F800-F8FF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111001)	?	1'b1: // Internal ROM F900-F9FF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111010)	?	1'b1: // Internal ROM FA00-FAFF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111011)	?	1'b1: // Internal ROM FB00-FBFF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111100)	?	1'b1: // Internal ROM FC00-FCFF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111101)	?	1'b1: // Internal ROM FD00-FDFF
//						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111110)	?	1'b1: // Internal ROM FE00-FEFF (Vectors)
//						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111111)	?	1'b1: // Internal ROM FF00-FFFF (Hardware)
						({ADDRESS[15:4]} == 12'b111111111111)				?	1'b1:
																							1'b0;

assign	ENA_F0 =	({RAM, ROM,   ADDRESS[15:11]} == 8'b01011110)	?	1'b1:	// Internal 32K ROM F000-F7FF
																							1'b0;
assign	ENA_E8 =	({RAM, ROM,   ADDRESS[15:11]} == 8'b01011101)	?	1'b1:	// Internal 32K ROM E800-EFFF
																							1'b0;
assign	ENA_E0 =	({RAM, ROM,   ADDRESS[15:11]} == 8'b01011100)	?	1'b1:	// Internal 32K ROM E000-E7FF
																							1'b0;
assign	ENA_D8 =	({RAM, ROM,   ADDRESS[15:11]} == 8'b01011011)	?	1'b1:	// Internal 32K ROM D800-DFFF
																							1'b0;
assign	ENA_D0 =	({RAM, ROM,   ADDRESS[15:11]} == 8'b01011010)	?	1'b1:	// Internal 32K ROM D000-D7FF
																							1'b0;
assign	ENA_C8 =	({RAM, ROM,   ADDRESS[15:11]} == 8'b01011001)	?	1'b1:	// Internal 32K ROM C800-CFFF
																							1'b0;
assign	ENA_C0 =	({RAM, ROM,   ADDRESS[15:11]} == 8'b01011000)	?	1'b1:	// Internal 32K ROM C000-C7FF
																							1'b0;
assign	ENA_B8 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010111)	?	1'b1:	// Internal 32K ROM B800-BFFF 
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010111)	?	1'b1:	// Internal 16K ROM B800-BFFF
																							1'b0;
assign	ENA_B0 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010110)	?	1'b1:	// Internal 32K ROM B000-B7FF
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010110)	?	1'b1:	// Internal 16K ROM B000-B7FF
																							1'b0;
assign	ENA_A8 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010101)	?	1'b1:	// Internal 32K ROM A800-AFFF
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010101)	?	1'b1:	// Internal 16K ROM A800-AFFF
																							1'b0;
assign	ENA_A0 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010100)	?	1'b1:	// Internal 32K ROM A000-A7FF
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010100)	?	1'b1:	// Internal 16K ROM A000-A7FF
																							1'b0;
assign	ENA_98 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010011)	?	1'b1:	// Internal 32K ROM 9800-9FFF
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010011)	?	1'b1:	// Internal 16K ROM 9800-9FFF
																							1'b0;
assign	ENA_90 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010010)	?	1'b1:	// Internal 32K ROM 9000-97FF
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010010)	?	1'b1:	// Internal 16K ROM 9000-97FF
																							1'b0;
assign	ENA_88 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010001)	?	1'b1:	// Internal 32K ROM 8800-8FFF
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010001)	?	1'b1:	// Internal 16K ROM 8800-8FFF
																							1'b0;
assign	ENA_80 =	({RAM, ROM[1], ADDRESS[15:11]} == 7'b0010000)	?	1'b1:	// Internal 32K ROM 8000-87FF
						({RAM, ROM,   ADDRESS[15:11]} == 8'b01010000)	?	1'b1:	// Internal 16K ROM 8000-87FF
																							1'b0;
assign	ENA_DSKD8 =	({ROM_SEL, MPI_CTS, ADDRESS[15:11]} == 8'b11111011)	?	1'b1:	// Disk D800-DFFF
																										1'b0;
assign	ENA_DSKD0 =	({ROM_SEL, MPI_CTS, ADDRESS[15:11]} == 8'b11111010)	?	1'b1:	// Disk D000-D7FF
																										1'b0;
assign	ENA_DSKC8 = ({ROM_SEL, MPI_CTS, ADDRESS[15:11]} == 8'b11111001)	?	1'b1:	// Disk C800-CFFF
																										1'b0;
assign	ENA_DSKC0 = ({ROM_SEL, MPI_CTS, ADDRESS[15:11]} == 8'b11111000)	?	1'b1:	// Disk C000-C7FF
																										1'b0;

assign	ROM_RW = 1'b0;

assign	DATA_IN =	({RAM0_CS_N, RAM0_BE0_N}==2'b00)	?	RAM_DATA0_I[7:0]:
							({RAM0_CS_N, RAM0_BE1_N}==2'b00)	?	RAM_DATA0_I[15:8]:
							({RAM1_CS_N, RAM1_BE0_N}==2'b00)	?	RAM_DATA1_I[7:0]:
							({RAM1_CS_N, RAM1_BE1_N}==2'b00)	?	RAM_DATA1_I[15:8]:
														ENA_F8		?	DOA_F8:
														ENA_F0		?	DOA_F0:
														ENA_E8		?	DOA_E8:
														ENA_E0		?	DOA_E0:
														ENA_D8		?	DOA_D8:
														ENA_D0		?	DOA_D0:
														ENA_C8		?	DOA_C8:
														ENA_C0		?	DOA_C0:
														ENA_B8		?	DOA_B8:
														ENA_B0		?	DOA_B0:
														ENA_A8		?	DOA_A8:
														ENA_A0		?	DOA_A0:
														ENA_98		?	DOA_98:
														ENA_90		?	DOA_90:
														ENA_88		?	DOA_88:
														ENA_80		?	DOA_80:
														ENA_DSKD8	?	DOA_DD8:
														ENA_DSKD0	?	DOA_DD0:
														ENA_DSKC8	?	DOA_DC8:
														ENA_DSKC0	?	DOA_DC0:
// FF00, FF04, FF08, FF0C, FF10, FF14, FF18, FF1C
({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100000)	?	DATA_REG1:
// FF01, FF05, FF09, FF0D, FF11, FF15, FF19, FF1D
({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100001)	?	{~HS_INT, 3'd7, SEL[1], DDR1, HSYNC_POL, HSYNC_INT}:
// FF02, FF06, FF0A, FF0E, FF12, FF16, FF1A, FF1E
({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100010)	?	DATA_REG2:
// FF03, FF07, FF0B, FF0F, FF13, FF17, FF1B, FF1F
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100011)	?	{~VS_INT, 3'd7, SEL[0], DDR2, VSYNC_POL, VSYNC_INT}:
// FF20, FF24, FF28, FF2C, FF30, FF34, FF38, FF3C
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100100)	?	DATA_REG3:
// FF21, FF25, FF29, FF2D, FF31, FF35, FF39, FF3D
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100101)	?	{~CD1_INT, 3'd7, CAS_MTR, DDR3, CD_POL, CD_INT}:
// FF22, FF26, FF2A, FF2E, FF32, FF36, FF3A, FF3E
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100110)	?	DATA_REG4:
// FF23, FF27, FF2B, FF2F, FF33, FF37, FF3B, FF3F
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100111)	?	{~CART1_INT, 3'd7, SOUND_EN, DDR4, CART_POL, CART_INT}:
														COM1_EN		?	DATA_COM1:
									(ADDRESS == 16'hFF52)		?	{XART}:
									(ADDRESS == 16'hFF7F)		?	{2'b11, MPI_CTS, 2'b11, MPI_SCS}:
									(ADDRESS == 16'hFF90)		?	{COCO1, MMU_EN, GIME_IRQ, GIME_FIRQ, VEC_PAG_RAM, ST_SCS, ROM}:
									(ADDRESS == 16'hFF91)		?	{2'b00, TIMER_INS, 4'b0000, MMU_TR}:
									(ADDRESS == 16'hFF92)		?	{2'b00, ~TMR_INT,  ~HBORD_INT,  ~VBORD_INT,  ~CD3_INT,  ~KEY_INT,  ~CAR_INT}:
									(ADDRESS == 16'hFF93)		?	{2'b00, ~TMR_FINT, ~HBORD_FINT, ~VBORD_FINT, ~CD3_FINT, ~KEY_FINT, ~CAR_FINT}:
									(ADDRESS == 16'hFF94)		?	{4'h0,TMR_MSB}:
									(ADDRESS == 16'hFF95)		?	TMR_LSB:
									(ADDRESS == 16'hFF98)		?	{GRMODE, 1'b0, DESCEN, MONO, 1'b0, LPR}:
									(ADDRESS == 16'hFF99)		?	{1'b0, LPF, HRES, CRES}:
									(ADDRESS == 16'hFF9A)		?	{2'b00, BDR_PAL}:
									(ADDRESS == 16'hFF9B)		?	{7'h00, VBANK}:
									(ADDRESS == 16'hFF9C)		?	{4'h0,VERT_FIN_SCRL}:
									(ADDRESS == 16'hFF9D)		?	SCRN_START_MSB:
									(ADDRESS == 16'hFF9E)		?	SCRN_START_LSB:
									(ADDRESS == 16'hFF9F)		?	{HVEN,HOR_OFFSET}:
									(ADDRESS == 16'hFFA0)		?	SAM00:
									(ADDRESS == 16'hFFA1)		?	SAM01:
									(ADDRESS == 16'hFFA2)		?	SAM02:
									(ADDRESS == 16'hFFA3)		?	SAM03:
									(ADDRESS == 16'hFFA4)		?	SAM04:
									(ADDRESS == 16'hFFA5)		?	SAM05:
									(ADDRESS == 16'hFFA6)		?	SAM06:
									(ADDRESS == 16'hFFA7)		?	SAM07:
									(ADDRESS == 16'hFFA8)		?	SAM10:
									(ADDRESS == 16'hFFA9)		?	SAM11:
									(ADDRESS == 16'hFFAA)		?	SAM12:
									(ADDRESS == 16'hFFAB)		?	SAM13:
									(ADDRESS == 16'hFFAC)		?	SAM14:
									(ADDRESS == 16'hFFAD)		?	SAM15:
									(ADDRESS == 16'hFFAE)		?	SAM16:
									(ADDRESS == 16'hFFAF)		?	SAM17:
									(ADDRESS == 16'hFFB0)		?	{2'b00, PALETTE0}:
									(ADDRESS == 16'hFFB1)		?	{2'b00, PALETTE1}:
									(ADDRESS == 16'hFFB2)		?	{2'b00, PALETTE2}:
									(ADDRESS == 16'hFFB3)		?	{2'b00, PALETTE3}:
									(ADDRESS == 16'hFFB4)		?	{2'b00, PALETTE4}:
									(ADDRESS == 16'hFFB5)		?	{2'b00, PALETTE5}:
									(ADDRESS == 16'hFFB6)		?	{2'b00, PALETTE6}:
									(ADDRESS == 16'hFFB7)		?	{2'b00, PALETTE7}:
									(ADDRESS == 16'hFFB8)		?	{2'b00, PALETTE8}:
									(ADDRESS == 16'hFFB9)		?	{2'b00, PALETTE9}:
									(ADDRESS == 16'hFFBA)		?	{2'b00, PALETTEA}:
									(ADDRESS == 16'hFFBB)		?	{2'b00, PALETTEB}:
									(ADDRESS == 16'hFFBC)		?	{2'b00, PALETTEC}:
									(ADDRESS == 16'hFFBD)		?	{2'b00, PALETTED}:
									(ADDRESS == 16'hFFBE)		?	{2'b00, PALETTEE}:
									(ADDRESS == 16'hFFBF)		?	{2'b00, PALETTEF}:
									(ADDRESS == 16'hFFC0)		?	{3'b000, CENT}:
									(ADDRESS == 16'hFFC1)		?	{1'b0, YEAR}:
									(ADDRESS == 16'hFFC2)		?	{4'h0, MNTH}:
									(ADDRESS == 16'hFFC3)		?	{3'b000, DMTH}:
									(ADDRESS == 16'hFFC4)		?	{5'b00000, DWK}:
									(ADDRESS == 16'hFFC5)		?	{3'b000, HOUR}:
									(ADDRESS == 16'hFFC6)		?	{2'b00, MIN}:
									(ADDRESS == 16'hFFC7)		?	{2'b00, SEC}:
																			8'h00;

assign	DATA_REG1	= ~DDR1	?	DD_REG1:
											KEYBOARD_IN;

assign	DATA_REG2	= ~DDR2	?	DD_REG2:
											KEY_COLUMN;

assign	DATA_REG3	= ~DDR3	?	DD_REG3:
											{DTOA_CODE, TXD2, 1'b1};

assign	DATA_REG4	= ~DDR4	?	DD_REG4:
											{VDG_CONTROL, 1'b0, KEY_COLUMN[6], SBS, RXD2};


always @(posedge CLK50MHZ or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		COM1_CLOCK <= 5'h00;
	end
	else
	begin
		case (COM1_CLOCK)
		5'h1A:
		begin
			COM1_CLOCK <= 5'h00;
		end
		default:
		begin
			COM1_CLOCK <= COM1_CLOCK + 1'b1;
		end
		endcase
	end
end

initial
	PH_2 <= 1'b0;
always @(posedge CLK50MHZ or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CLK <= 6'h00;
		SWITCH_L <= 3'b000;
		PH_2 <= ~PH_2;
		RAM_RW_N <= 1'b1;
		B_SWITCH <= 2'b00;
	end
	else
	begin
		case (CLK)
		6'h00:
		begin
			B_SWITCH <= SWITCH[1:0];
			if(XART != 8'h00)
				SWITCH_L <= 3'b111;										// Fast speed for Disk
			else
				SWITCH_L <= {B_SWITCH, RATE};
			if(READMEM)													// Video memory about to be read (first 50 MHz clock of read cycle)
			begin															// Wait
				CLK <= 6'h00;
				PH_2 <= 1'b0;
				RAM_RW_N <= 1'b1;
			end
			else
			begin															// Video memory not being read
				CLK <= 6'h01;											// Continue on
				PH_2 <= 1'b1;
				RAM_RW_N <= RW_N;
			end
		end
		6'h01:										// 50/2 = 25
		begin
			PH_2 <= 1'b0;
			RAM_RW_N <= 1'b1;
			if(SWITCH_L == 3'b111)
				CLK <= 6'h00;
			else
				CLK <= 6'h02;
		end
		6'h03:										//  50/4 = 12.5
		begin
			if(SWITCH_L == 3'b101)
				CLK <= 6'h00;
			else
				CLK <= 6'h04;
		end
		6'h0B:										// 50/12 = 4.167
		begin
			if(SWITCH_L == 3'b011)
				CLK <= 6'h00;
			else
				CLK <= 6'h0C;
		end
		6'h1B:										// 50/28 = 1.786
		begin
			if(SWITCH_L == 3'b001)
				CLK <= 6'h00;
			else
				CLK <= 6'h1C;
		end
		6'h37:										// 50/56 = 0.893
		begin
			CLK <= 6'h00;
		end
		6'h3F:
		begin
			CLK <= 6'h00;
		end
		default:
			CLK <= CLK + 1'b1;
		endcase
	end
end

//assign RESET_N = ~BUTTON[3];

always @(posedge CLK50MHZ or posedge BUTTON[3])
begin
	if(BUTTON[3])
	begin
		RESET_CLK <= 16'h0000;
		RESET_N <= 1'b0;
	end
	else
	begin
		case (RESET_CLK)
		16'hFFFF:
		begin
			RESET_CLK <= 16'hFFFF;
			RESET_N <= 1'b1;
		end
		default:
		begin
			RESET_CLK <= RESET_CLK + 1'b1;
			RESET_N <= 1'b0;
		end
		endcase
	end
end

CPU09 GLBCPU09(
	.clk(PH_2),
	.rst(~RESET_N),
	.rw(RW_N),
	.vma(VMA),
	.address(ADDRESS),
	.data_in(DATA_IN),
	.data_out(DATA_OUT),
	.halt(1'b0),
	.hold(1'b0),
	.irq(~CPU_IRQ),
	.firq(~CPU_FIRQ),
	.nmi(CPU_NMI)
);

// Interrupt source for CART signal
always @(posedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CART_IRQ <= 1'b1;
	end
	else
	begin
		case (MPI_CTS)
		2'b00:
			CART_IRQ <= 1'b1;
		2'b01:
			CART_IRQ <= ~CART_IRQ;
		2'b10:
			CART_IRQ <= ~CART_IRQ;
		2'b11:
			CART_IRQ <= SER_IRQ;
		endcase
	end
end

// INT for COCO1
always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		HS_INT <= 1'b1;
		HS_INT_SM <= 2'b00;
	end
	else
	begin

// H_SYNC int for COCO1
// output	HS_INT
// State		HS_INT_SM
// input		H_SYNC / H_FLAG
// switch	HSYNC_INT @ FF01
// pol		HSYNC_POL
// clear    FF00

		if(HSYNC_INT == 1'b0)		// disabled
		begin
			HS_INT <= 1'b1;			// no int
			HS_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (HS_INT_SM)
			2'b00:
			begin
				if((H_SYNC | H_FLAG) ^ ~HSYNC_POL)		// 1 = int
				begin
					HS_INT <= 1'b0;
					HS_INT_SM <= 2'b01;
				end
				else
				begin
					HS_INT <= 1'b1;			// no int
					HS_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100000)		// FF00, FF04, FF08, FF0C, FF10, FF14, FF18, FF1C
				begin
					HS_INT <= 1'b1;
					HS_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(~((H_SYNC | H_FLAG) ^ ~HSYNC_POL))
				begin
					HS_INT <= 1'b1;
					HS_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		VS_INT <= 1'b1;
		VS_INT_SM <= 2'b00;
	end
	else
	begin

// V_SYNC int for COCO1
// output	VS_INT
// State		VS_INT_SM
// input		V_SYNC
// switch	VSYNC_INT @ FF03
// pol		VSYNC_POL
// clear    FF00

		if(VSYNC_INT == 1'b0)		// disabled
		begin
			VS_INT <= 1'b1;			// no int
			VS_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (VS_INT_SM)
			2'b00:
			begin
				if(V_SYNC ^ ~VSYNC_POL)		// 1 = int
				begin
					VS_INT <= 1'b0;
					VS_INT_SM <= 2'b01;
				end
				else
				begin
					VS_INT <= 1'b1;			// no int
					VS_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100010)		// FF02, FF06, FF0A, FF0E, FF12, FF16, FF1A, FF1E
				begin
					VS_INT <= 1'b1;
					VS_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(~(V_SYNC ^ ~VSYNC_POL))
				begin
					VS_INT <= 1'b1;
					VS_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

assign CD_IRQ = 1'b1;

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CD1_INT <= 1'b1;
		CD1_INT_SM <= 2'b00;
	end
	else
	begin

// CD (BitBang) int for COCO1
// output	CD1_INT
// State		CD1_INT_SM
// input		CD_IRQ
// switch	CD_INT @ FF21
// pol		CD_POL
// clear    FF20

		if(CD_INT == 1'b0)		// disabled
		begin
			CD1_INT <= 1'b1;			// no int
			CD1_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (CD1_INT_SM)
			2'b00:
			begin
				if(CD_IRQ ^ ~CD_POL)
				begin
					CD1_INT <= 1'b0;
					CD1_INT_SM <= 2'b01;
				end
				else
				begin
					CD1_INT <= 1'b1;			// no int
					CD1_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100100)		// FF20, FF24, FF28, FF2C, FF30, FF34, FF38, FF3C
				begin
					CD1_INT <= 1'b1;
					CD1_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(~(CD_IRQ ^ ~CD_POL))
				begin
					CD1_INT <= 1'b1;
					CD1_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CART1_INT <= 1'b1;
		CART1_INT_SM <= 2'b00;
	end
	else
	begin

// Cart int for COCO1
// output	CART1_INT
// State		CART1_INT_SM
// input		CART_IRQ
// switch	CART_INT @ FF23
// pol		CART_POL
// clear    FF22

		if(CART_INT == 1'b0)		// disabled
		begin
			CART1_INT <= 1'b1;			// no int
			CART1_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (CART1_INT_SM)
			2'b00:
			begin
				if(~CART_IRQ)
				begin
					CART1_INT <= 1'b0;
					CART1_INT_SM <= 2'b01;
				end
				else
				begin
					CART1_INT <= 1'b1;			// no int
					CART1_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100110)		// FF22, FF26, FF2A, FF2E, FF32, FF36, FF3A, FF3E
				begin
					CART1_INT <= 1'b1;
					CART1_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(CART_IRQ)
				begin
					CART1_INT <= 1'b1;
					CART1_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

// INT for COCO3
always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		TMR_INT <= 1'b1;
		TMR_INT_SM <= 2'b00;
	end
	else
	begin

// TIMER int for COCO3
// output	TMR_INT
// State		TMR_INT_SM
// input		TIMER == 12'h000
// switch	IRQ_TMR

		if(IRQ_TMR == 1'b0)		// disabled
		begin
			TMR_INT <= 1'b1;			// no int
			TMR_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (TMR_INT_SM)
			2'b00:
			begin
				if(TIMER == 12'h000)		// 1 = int
				begin
					TMR_INT <= 1'b0;
					TMR_INT_SM <= 2'b01;
				end
				else
				begin
					TMR_INT <= 1'b1;			// no int
					TMR_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'hFF92)
				begin
					TMR_INT <= 1'b1;
					TMR_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(TIMER != 12'H000)
				begin
					TMR_INT <= 1'b1;
					TMR_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		HBORD_INT <= 1'b1;
		HBORD_INT_SM <= 2'b00;
	end
	else
	begin

// H_SYNC int for COCO3
// output	HBORD_INT
// State		HBORD_INT_SM
// input		H_SYNC / H_FLAG
// switch	IRQ_HBORD

		if(IRQ_HBORD == 1'b0)		// disabled
		begin
			HBORD_INT <= 1'b1;			// no int
			HBORD_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (HBORD_INT_SM)
			2'b00:
			begin
				if(~(H_SYNC | H_FLAG))		// 1 = int
				begin
					HBORD_INT <= 1'b0;
					HBORD_INT_SM <= 2'b01;
				end
				else
				begin
					HBORD_INT <= 1'b1;			// no int
					HBORD_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF92)
				begin
					HBORD_INT <= 1'b1;
					HBORD_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(H_SYNC | H_FLAG)
				begin
					HBORD_INT <= 1'b1;
					HBORD_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end
always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		VBORD_INT <= 1'b1;
		VBORD_INT_SM <= 2'b00;
	end
	else
	begin

// V_SYNC int for COCO3
// output	VBORD_INT
// State		VBORD_INT_SM
// input		V_SYNC
// switch	IRQ_VBORD

		if(IRQ_VBORD == 1'b0)		// disabled
		begin
			VBORD_INT <= 1'b1;			// no int
			VBORD_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (VBORD_INT_SM)
			2'b00:
			begin
				if(~V_SYNC)
				begin
					VBORD_INT <= 1'b0;
					VBORD_INT_SM <= 2'b01;
				end
				else
				begin
					VBORD_INT <= 1'b1;			// no int
					VBORD_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF92)
				begin
					VBORD_INT <= 1'b1;
					VBORD_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(V_SYNC)
				begin
					VBORD_INT <= 1'b1;
					VBORD_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CD3_INT <= 1'b1;
		CD3_INT_SM <= 2'b00;
	end
	else
	begin

// CD (BitBang) int for COCO3
// output	CD3_INT
// State		CD3_INT_SM
// input		CD_IRQ
// switch	IRQ_SERIAL

		if(IRQ_SERIAL == 1'b0)		// disabled
		begin
			CD3_INT <= 1'b1;			// no int
			CD3_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (CD3_INT_SM)
			2'b00:
			begin
				if(~CD_IRQ)
				begin
					CD3_INT <= 1'b0;
					CD3_INT_SM <= 2'b01;
				end
				else
				begin
					CD3_INT <= 1'b1;			// no int
					CD3_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF92)
				begin
					CD3_INT <= 1'b1;
					CD3_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(CD_IRQ)
				begin
					CD3_INT <= 1'b1;
					CD3_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		KEY_INT <= 1'b1;
		KEY_INT_SM <= 2'b00;
	end
	else
	begin

// Keyboard int for COCO3
// output	KEY_INT
// State		KEY_INT_SM
// input		KEY_INT_RAW
// switch	IRQ_KEY

		if(IRQ_KEY == 1'b0)		// disabled
		begin
			KEY_INT <= 1'b1;			// no int
			KEY_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (KEY_INT_SM)
			2'b00:
			begin
				if(~KEY_INT_RAW)
				begin
					KEY_INT <= 1'b0;
					KEY_INT_SM <= 2'b01;
				end
				else
				begin
					KEY_INT <= 1'b1;			// no int
					KEY_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF92)
				begin
					KEY_INT <= 1'b1;
					KEY_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(KEY_INT_RAW)
				begin
					KEY_INT <= 1'b1;
					KEY_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CAR_INT <= 1'b1;
		CAR_INT_SM <= 2'b00;
	end
	else
	begin

// CART (Serial HDD) int for COCO3
// output	CAR_INT
// State		CAR_INT_SM
// input		CART_IRQ
// switch	IRQ_CART

		if(IRQ_CART == 1'b0)		// disabled
		begin
			CAR_INT <= 1'b1;			// no int
			CAR_INT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (CAR_INT_SM)
			2'b00:
			begin
				if(~CART_IRQ)
				begin
					CAR_INT <= 1'b0;
					CAR_INT_SM <= 2'b01;
				end
				else
				begin
					CAR_INT <= 1'b1;			// no int
					CAR_INT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF92)
				begin
					CAR_INT <= 1'b1;
					CAR_INT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(CART_IRQ)
				begin
					CAR_INT <= 1'b1;
					CAR_INT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

// FINT for COCO3
always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		TMR_FINT <= 1'b1;
		TMR_FINT_SM <= 2'b00;
	end
	else
	begin

// TIMER fint for COCO3
// output	TMR_FINT
// State		TMR_FINT_SM
// input		TIMER == 12'h000
// switch	FIRQ_TMR

		if(FIRQ_TMR == 1'b0)		// disabled
		begin
			TMR_FINT <= 1'b1;			// no int
			TMR_FINT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (TMR_FINT_SM)
			2'b00:
			begin
				if(TIMER == 12'h000)		// 1 = int
				begin
					TMR_FINT <= 1'b0;
					TMR_FINT_SM <= 2'b01;
				end
				else
				begin
					TMR_FINT <= 1'b1;			// no int
					TMR_FINT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'hFF93)
				begin
					TMR_FINT <= 1'b1;
					TMR_FINT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(TIMER != 12'H000)
				begin
					TMR_FINT <= 1'b1;
					TMR_FINT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		HBORD_FINT <= 1'b1;
		HBORD_FINT_SM <= 2'b00;
	end
	else
	begin

// H_SYNC fint for COCO3
// output	HBORD_FINT
// State		HBORD_FINT_SM
// input		H_SYNC / H_FLAG
// switch	FIRQ_HBORD

		if(FIRQ_HBORD == 1'b0)		// disabled
		begin
			HBORD_FINT <= 1'b1;			// no int
			HBORD_FINT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (HBORD_FINT_SM)
			2'b00:
			begin
				if(~(H_SYNC | H_FLAG))		// 1 = int
				begin
					HBORD_FINT <= 1'b0;
					HBORD_FINT_SM <= 2'b01;
				end
				else
				begin
					HBORD_FINT <= 1'b1;			// no int
					HBORD_FINT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF93)
				begin
					HBORD_FINT <= 1'b1;
					HBORD_FINT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(H_SYNC | H_FLAG)
				begin
					HBORD_FINT <= 1'b1;
					HBORD_FINT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		VBORD_FINT <= 1'b1;
		VBORD_FINT_SM <= 2'b00;
	end
	else
	begin

// V_SYNC int for COCO3
// output	VBORD_FINT
// State		VBORD_FINT_SM
// input		V_SYNC
// switch	FIRQ_VBORD

		if(FIRQ_VBORD == 1'b0)		// disabled
		begin
			VBORD_FINT <= 1'b1;			// no int
			VBORD_FINT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (VBORD_FINT_SM)
			2'b00:
			begin
				if(~V_SYNC)
				begin
					VBORD_FINT <= 1'b0;
					VBORD_FINT_SM <= 2'b01;
				end
				else
				begin
					VBORD_FINT <= 1'b1;			// no int
					VBORD_FINT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF93)
				begin
					VBORD_FINT <= 1'b1;
					VBORD_FINT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(V_SYNC)
				begin
					VBORD_FINT <= 1'b1;
					VBORD_FINT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CD3_FINT <= 1'b1;
		CD3_FINT_SM <= 2'b00;
	end
	else
	begin

// CD (BitBang) int for COCO3
// output	CD3_FINT
// State		CD3_FINT_SM
// input		CD_IRQ
// switch	FIRQ_SERIAL

		if(FIRQ_SERIAL == 1'b0)		// disabled
		begin
			CD3_FINT <= 1'b1;			// no int
			CD3_FINT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (CD3_FINT_SM)
			2'b00:
			begin
				if(~CD_IRQ)
				begin
					CD3_FINT <= 1'b0;
					CD3_FINT_SM <= 2'b01;
				end
				else
				begin
					CD3_FINT <= 1'b1;			// no int
					CD3_FINT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF93)
				begin
					CD3_FINT <= 1'b1;
					CD3_FINT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(CD_IRQ)
				begin
					CD3_FINT <= 1'b1;
					CD3_FINT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		KEY_FINT <= 1'b1;
		KEY_FINT_SM <= 2'b00;
	end
	else
	begin

// Keyboard int for COCO3
// output	KEY_FINT
// State		KEY_FINT_SM
// input		KEY_INT_RAW
// switch	FIRQ_KEY

		if(FIRQ_KEY == 1'b0)		// disabled
		begin
			KEY_FINT <= 1'b1;			// no int
			KEY_FINT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (KEY_FINT_SM)
			2'b00:
			begin
				if(~KEY_INT_RAW)
				begin
					KEY_FINT <= 1'b0;
					KEY_FINT_SM <= 2'b01;
				end
				else
				begin
					KEY_FINT <= 1'b1;			// no int
					KEY_FINT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF93)
				begin
					KEY_FINT <= 1'b1;
					KEY_FINT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(KEY_INT_RAW)
				begin
					KEY_FINT <= 1'b1;
					KEY_FINT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CAR_FINT <= 1'b1;
		CAR_FINT_SM <= 2'b00;
	end
	else
	begin

// CART (Serial HDD) int for COCO3
// output	CAR_FINT
// State		CAR_FINT_SM
// input		CART_FINT
// switch	FIRQ_CART

		if(FIRQ_CART == 1'b0)		// disabled
		begin
			CAR_FINT <= 1'b1;			// no int
			CAR_FINT_SM <= 2'b00;
		end
		else								// enabled
		begin
			case (CAR_FINT_SM)
			2'b00:
			begin
				if(~CART_IRQ)
				begin
					CAR_FINT <= 1'b0;
					CAR_FINT_SM <= 2'b01;
				end
				else
				begin
					CAR_FINT <= 1'b1;			// no int
					CAR_FINT_SM <= 2'b00;
				end
			end
			2'b01:
			begin
				if({ADDRESS[15:0]} == 16'HFF93)
				begin
					CAR_FINT <= 1'b1;
					CAR_FINT_SM <= 2'b10;
				end
			end
			2'b10:
			begin
				if(CART_IRQ)
				begin
					CAR_FINT <= 1'b1;
					CAR_FINT_SM <= 2'b00;
				end
			end
			endcase
		end
	end
end

assign KEY_INT_RAW = (KEYBOARD_IN == 8'hFF)			?	1'b1:
																		1'b0;

assign TMR_CLK = ~TIMER_INS	?	(H_SYNC | H_FLAG):
											DIV_7[2];

always @ (posedge CLK50MHZ or negedge RESET_N)
begin
	if(~RESET_N)
		DIV_7 <= 3'b000;
	else
	case (DIV_7)
	3'b110:
		DIV_7 <= 3'b000;
	default:
		DIV_7 <= DIV_7 + 1'b1;
	endcase
end

assign CPU_IRQ =  (HS_INT & VS_INT)
					&	(~GIME_IRQ  | (TMR_INT  & HBORD_INT  & VBORD_INT  & CD3_INT  & KEY_INT  & CAR_INT));
assign CPU_FIRQ = (CD1_INT & CART1_INT)
					&	(~GIME_FIRQ | (TMR_FINT & HBORD_FINT & VBORD_FINT & CD3_FINT & KEY_FINT & CAR_FINT));

always @(posedge TMR_CLK)
begin
	if(~TMR_ENABLE)
	begin
		BLINK <= 1'b1;
		TIMER <= 12'h000;
	end
	else
		case (TIMER)
		12'h000:
		begin
			BLINK <= ~BLINK;
			TIMER <= {TMR_MSB,TMR_LSB};
		end
		default:
			TIMER <= TIMER - 1'b1;
		endcase
end

assign COM1_EN = ({PH_2, ADDRESS[15:1]} == 16'b1111111110101000)	?	1'b1:			//FF50-FF51
					 																		1'b0;

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
// FF00
		DD_REG1 <= 8'h00;
// FF01
		HSYNC_INT <= 1'b0;
		HSYNC_POL <= 1'b0;
		DDR1 <= 1'b0;
		SEL[1] <= 1'b0;
// FF02
		DD_REG2 <= 8'h00;
		KEY_COLUMN <= 8'h00;
// FF03
		VSYNC_INT <= 1'b0;
		VSYNC_POL <= 1'b0;
		DDR2 <= 1'b0;
		SEL[0] <= 1'b0;
// FF20
		DD_REG3 <= 8'h00;
		DTOA_CODE <= 6'b000000;
		TXD2 <= 1'b0;
// FF21
		CD_INT <= 1'b0;
		CD_POL <= 1'b0;
		DDR3 <= 1'b0;
		CAS_MTR <= 1'b0;
// FF22
		DD_REG4 <= 8'h00;
		SBS <= 1'b0;
		CSS <= 1'b0;
		VDG_CONTROL <= 4'b0000;
// FF23
		CART_INT <= 1'b0;
		CART_POL <= 1'b0;
		DDR4 <= 1'b0;
		SOUND_EN <= 1'b0;
// FF7F
		MPI_SCS <= SWITCH[3:2];
		MPI_CTS <= SWITCH[3:2];
// FF90
		ROM <= 2'b00;
		ST_SCS <= 1'b0;
		VEC_PAG_RAM <= 1'b0;
		GIME_FIRQ <= 1'b0;
		GIME_IRQ <= 1'b0;
		MMU_EN <= 1'b0;
		COCO1 <= 1'b0;
// FF91
		TIMER_INS <= 1'b0;
		MMU_TR <= 1'b0;
// FF92
		IRQ_TMR <= 1'b0;
		IRQ_HBORD <= 1'b0;
		IRQ_VBORD <= 1'b0;
		IRQ_SERIAL <= 1'b0;
		IRQ_KEY <= 1'b0;
		IRQ_CART <= 1'b0;
// FF93
		FIRQ_TMR <= 1'b0;
		FIRQ_HBORD <= 1'b0;
		FIRQ_VBORD <= 1'b0;
		FIRQ_SERIAL <= 1'b0;
		FIRQ_KEY <= 1'b0;
		FIRQ_CART <= 1'b0;
// FF94
		TMR_MSB <= 4'h0;
		TMR_ENABLE <= 1'b0;
// FF95
		TMR_LSB <= 8'h00;
// FF98
		GRMODE <= 1'b0;
		DESCEN <= 1'b0;
		MONO <= 1'b0;
		LPR <= 3'b000;
// FF99
		LPF <= 2'b00;
		HRES <= 3'b000;
		CRES <= 2'b00;
// FF9A
		BDR_PAL <= 6'b000000;
// FF9B
		VBANK <= 1'b0;
// FF9C
		VERT_FIN_SCRL <= 4'h0;
// FF9D
		SCRN_START_MSB <= 8'h00;
// FF9E
		SCRN_START_LSB <= 8'h00;
// FF9F
		HVEN <= 1'b0;
		HOR_OFFSET <= 7'h00;
// FFA0
		SAM00 <= 8'h00;
// FFA1
		SAM01 <= 8'h00;
// FFA2
		SAM02 <= 8'h00;
// FFA3
		SAM03 <= 8'h00;
// FFA4
		SAM04 <= 8'h00;
// FFA5
		SAM05 <= 8'h00;
// FFA6
		SAM06 <= 8'h00;
// FFA7
		SAM07 <= 8'h00;
// FFA8
		SAM10 <= 8'h00;
// FFA9
		SAM11 <= 8'h00;
// FFAA
		SAM12 <= 8'h00;
// FFAB
		SAM13 <= 8'h00;
// FFAC
		SAM14 <= 8'h00;
// FFAD
		SAM15 <= 8'h00;
// FFAE
		SAM16 <= 8'h00;
// FFAF
		SAM17 <= 8'h00;
// FFB0
		PALETTE0 <= 6'h00;
// FFB1
		PALETTE1 <= 6'h00;
// FFB2
		PALETTE2 <= 6'h00;
// FFB3
		PALETTE3 <= 6'h00;
// FFB4
		PALETTE4 <= 6'h00;
// FFB5
		PALETTE5 <= 6'h00;
// FFB6
		PALETTE6 <= 6'h00;
// FFB7
		PALETTE7 <= 6'h00;
// FFB8
		PALETTE8 <= 6'h00;
// FFB9
		PALETTE9 <= 6'h00;
// FFBA
		PALETTEA <= 6'h00;
// FFBB
		PALETTEB <= 6'h00;
// FFBC
		PALETTEC <= 6'h00;
// FFBD
		PALETTED <= 6'h00;
// FFBE
		PALETTEE <= 6'h00;
// FFBF
		PALETTEF <= 6'h00;
// FFC0 / FFC1
		V[0] <= 1'b0;
// FFC2 / FFC3
		V[1] <= 1'b0;
// FFC4 / FFC5
		V[2] <= 1'b0;
// FFC6 / FFC7
		VERT[0] <= 1'b0;
// FFC8 / FFC9
		VERT[1] <= 1'b0;
// FFCA / FFCB
		VERT[2] <= 1'b0;
// FFCC / FFCD
		VERT[3] <= 1'b0;
// FFCE / FFCF
		VERT[4] <= 1'b0;
// FFD0 / FFD1
		VERT[5] <= 1'b0;
// FFD2 / FFD3
		VERT[6] <= 1'b0;
// FFD8 / FFD9
		RATE <= 1'b0;
// FFDE / FFDF
		RAM <= 1'b0;
	end
	else
	begin
		if(~RW_N)
		begin
			case (ADDRESS)
			16'hFF00:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF01:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF02:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF03:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF04:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF05:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF06:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF07:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF08:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF09:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF0A:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF0B:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF0C:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF0D:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF0E:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF0F:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF10:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF11:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF12:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF13:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF14:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF15:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF16:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF17:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF18:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF19:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF1A:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF1B:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF1C:
			begin
				if(~DDR1)
					DD_REG1 <= DATA_OUT;
			end
			16'hFF1D:
			begin
					HSYNC_INT <= DATA_OUT[0];
					HSYNC_POL <= DATA_OUT[1];
					DDR1 <= DATA_OUT[2];
					SEL[1] <= DATA_OUT[3];
			end
			16'hFF1E:
			begin
				if(~DDR2)
					DD_REG2 <= DATA_OUT;
				else
					KEY_COLUMN <= DATA_OUT;
			end
			16'hFF1F:
			begin
				VSYNC_INT <= DATA_OUT[0];
				VSYNC_POL <= DATA_OUT[1];
				DDR2 <= DATA_OUT[2];
				SEL[0] <= DATA_OUT[3];
			end
			16'hFF20:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF21:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF22:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF23:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF24:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF25:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF26:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF27:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF28:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF29:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF2A:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF2B:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF2C:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF2D:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF2E:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF2F:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF30:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF31:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF32:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF33:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF34:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF35:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF36:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF37:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF38:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF39:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF3A:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF3B:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF3C:
			begin
				if(~DDR3)
					DD_REG3 <= DATA_OUT;
				else
					DTOA_CODE <= DATA_OUT[7:2];
					TXD2 <= DATA_OUT[1];
			end
			16'hFF3D:
			begin
				CD_INT <= DATA_OUT[0];
				CD_POL <= DATA_OUT[1];
				DDR3 <= DATA_OUT[2];
				CAS_MTR <= DATA_OUT[3];
			end
			16'hFF3E:
			begin
				if(~DDR4)
					DD_REG4 <= DATA_OUT;
				else
					SBS <= DATA_OUT[1];
					CSS <= DATA_OUT[3];
					VDG_CONTROL <= DATA_OUT[7:4];
			end
			16'hFF3F:
			begin
				CART_INT <= DATA_OUT[0];
				CART_POL <= DATA_OUT[1];
				DDR4 <= DATA_OUT[2];
				SOUND_EN <= DATA_OUT[3];
			end
			16'hFF7F:
			begin
				MPI_SCS <= DATA_OUT[1:0];
				MPI_CTS <= DATA_OUT[5:4];
			end
			16'hFF90:
			begin
				ROM <= DATA_OUT[1:0];
				ST_SCS <= DATA_OUT[2];
				VEC_PAG_RAM <= DATA_OUT[3];
				GIME_FIRQ <= DATA_OUT[4];
				GIME_IRQ <= DATA_OUT[5];
				MMU_EN <= DATA_OUT[6];
				COCO1 <= DATA_OUT[7];
			end
			16'hFF91:
			begin
				TIMER_INS <= DATA_OUT[5];
				MMU_TR <= DATA_OUT[0];
			end
			16'hFF92:
			begin
				IRQ_TMR <= DATA_OUT[5];
				IRQ_HBORD <= DATA_OUT[4];
				IRQ_VBORD <= DATA_OUT[3];
				IRQ_SERIAL <= DATA_OUT[2];
				IRQ_KEY <= DATA_OUT[1];
				IRQ_CART <= DATA_OUT[0];
			end
			16'hFF93:
			begin
				FIRQ_TMR <= DATA_OUT[5];
				FIRQ_HBORD <= DATA_OUT[4];
				FIRQ_VBORD <= DATA_OUT[3];
				FIRQ_SERIAL <= DATA_OUT[2];
				FIRQ_KEY <= DATA_OUT[1];
				FIRQ_CART <= DATA_OUT[0];
			end
			16'hFF94:
			begin
				TMR_MSB <= DATA_OUT[3:0];
				TMR_ENABLE <= 1'b1;
			end
			16'hFF95:
			begin
				TMR_LSB <= DATA_OUT;
			end
			16'hFF98:
			begin
				GRMODE <= DATA_OUT[7];
				DESCEN <= DATA_OUT[5];
				MONO <= DATA_OUT[4];
				LPR <= DATA_OUT[2:0];
			end
			16'hFF99:
			begin
				LPF <= DATA_OUT[6:5];
				HRES <= DATA_OUT[4:2];
				CRES <= DATA_OUT[1:0];
			end
			16'hFF9A:
			begin
				BDR_PAL <= DATA_OUT[5:0];
			end
			16'hFF9B:
			begin
				VBANK <= DATA_OUT[0];
			end
			16'hFF9C:
			begin
				VERT_FIN_SCRL <= DATA_OUT[3:0];
			end
			16'hFF9D:
			begin
				SCRN_START_MSB <= DATA_OUT;
			end
			16'hFF9E:
			begin
				SCRN_START_LSB <= DATA_OUT;
			end
			16'hFF9F:
			begin
				HVEN <= DATA_OUT[7];
				HOR_OFFSET <= DATA_OUT[6:0];
			end
			16'hFFA0:
			begin
				SAM00 <= DATA_OUT;
			end
			16'hFFA1:
			begin
				SAM01 <= DATA_OUT;
			end
			16'hFFA2:
			begin
				SAM02 <= DATA_OUT;
			end
			16'hFFA3:
			begin
				SAM03 <= DATA_OUT;
			end
			16'hFFA4:
			begin
				SAM04 <= DATA_OUT;
			end
			16'hFFA5:
			begin
				SAM05 <= DATA_OUT;
			end
			16'hFFA6:
			begin
				SAM06 <= DATA_OUT;
			end
			16'hFFA7:
			begin
				SAM07 <= DATA_OUT;
			end
			16'hFFA8:
			begin
				SAM10 <= DATA_OUT;
			end
			16'hFFA9:
			begin
				SAM11 <= DATA_OUT;
			end
			16'hFFAA:
			begin
				SAM12 <= DATA_OUT;
			end
			16'hFFAB:
			begin
				SAM13 <= DATA_OUT;
			end
			16'hFFAC:
			begin
				SAM14 <= DATA_OUT;
			end
			16'hFFAD:
			begin
				SAM15 <= DATA_OUT;
			end
			16'hFFAE:
			begin
				SAM16 <= DATA_OUT;
			end
			16'hFFAF:
			begin
				SAM17 <= DATA_OUT;
			end
			16'hFFB0:
			begin
				PALETTE0 <= DATA_OUT[5:0];
			end
			16'hFFB1:
			begin
				PALETTE1 <= DATA_OUT[5:0];
			end
			16'hFFB2:
			begin
				PALETTE2 <= DATA_OUT[5:0];
			end
			16'hFFB3:
			begin
				PALETTE3 <= DATA_OUT[5:0];
			end
			16'hFFB4:
			begin
				PALETTE4 <= DATA_OUT[5:0];
			end
			16'hFFB5:
			begin
				PALETTE5 <= DATA_OUT[5:0];
			end
			16'hFFB6:
			begin
				PALETTE6 <= DATA_OUT[5:0];
			end
			16'hFFB7:
			begin
				PALETTE7 <= DATA_OUT[5:0];
			end
			16'hFFB8:
			begin
				PALETTE8 <= DATA_OUT[5:0];
			end
			16'hFFB9:
			begin
				PALETTE9 <= DATA_OUT[5:0];
			end
			16'hFFBA:
			begin
				PALETTEA <= DATA_OUT[5:0];
			end
			16'hFFBB:
			begin
				PALETTEB <= DATA_OUT[5:0];
			end
			16'hFFBC:
			begin
				PALETTEC <= DATA_OUT[5:0];
			end
			16'hFFBD:
			begin
				PALETTED <= DATA_OUT[5:0];
			end
			16'hFFBE:
			begin
				PALETTEE <= DATA_OUT[5:0];
			end
			16'hFFBF:
			begin
				PALETTEF <= DATA_OUT[5:0];
			end
			16'hFFC0:
			begin
				V[0] <= 1'b0;
			end
			16'hFFC1:
			begin
				V[0] <= 1'b1;
			end
			16'hFFC2:
			begin
				V[1] <= 1'b0;
			end
			16'hFFC3:
			begin
				V[1] <= 1'b1;
			end
			16'hFFC4:
			begin
				V[2] <= 1'b0;
			end
			16'hFFC5:
			begin
				V[2] <= 1'b1;
			end
			16'hFFC6:
			begin
				VERT[0] <= 1'b0;
			end
			16'hFFC7:
			begin
				VERT[0] <= 1'b1;
			end
			16'hFFC8:
			begin
				VERT[1] <= 1'b0;
			end
			16'hFFC9:
			begin
				VERT[1] <= 1'b1;
			end
			16'hFFCA:
			begin
				VERT[2] <= 1'b0;
			end
			16'hFFCB:
			begin
				VERT[2] <= 1'b1;
			end
			16'hFFCC:
			begin
				VERT[3] <= 1'b0;
			end
			16'hFFCD:
			begin
				VERT[3] <= 1'b1;
			end
			16'hFFCE:
			begin
				VERT[4] <= 1'b0;
			end
			16'hFFCF:
			begin
				VERT[4] <= 1'b1;
			end
			16'hFFD0:
			begin
				VERT[5] <= 1'b0;
			end
			16'hFFD1:
			begin
				VERT[5] <= 1'b1;
			end
			16'hFFD2:
			begin
				VERT[6] <= 1'b0;
			end
			16'hFFD3:
			begin
				VERT[6] <= 1'b1;
			end
			16'hFFD8:
			begin
				RATE <= 1'b0;
			end
			16'hFFD9:
			begin
				RATE <= 1'b1;
			end
			16'hFFDE:
			begin
				RAM <= 1'b0;
			end
			16'hFFDF:
			begin
				RAM <= 1'b1;
			end
			endcase
		end
	end
end

assign SPEAKER =	(SOUND_EN==1'b0)					?	SBS:
						({SOUND_EN, SEL} == 3'b100)	?	DIG_SOUND:
																	1'b0;

always @(posedge KB_CLK[2] or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		DIG_SOUND <= 1'b0;
		DTOA_LATCH <= 7'b0000000;
		DIG_STATE  <= 7'b0000000;
	end
	else
	begin
		case(DIG_STATE)
		7'b0000000:
		begin
			DIG_STATE <= 7'b0000001;
			DIG_SOUND <= 1'b0;
			DTOA_LATCH[6] <= SBS;
			if({SOUND_EN, SEL} == 3'b100)
				DTOA_LATCH[5:0] <= DTOA_CODE;
		end
		7'b0000001:
		begin
			DIG_STATE <= 7'b0000010;
			if(DTOA_LATCH[6:1] == 6'b000000)
				DIG_SOUND <= 1'b1;
			else
				DIG_SOUND <= 1'b0;
		end
		7'b1111111:
		begin
			DIG_SOUND <= 1'b1;
			DIG_STATE <= 6'b000000;
		end
		default:
		begin
			DIG_STATE <= DIG_STATE + 1'b1;
			if(DIG_STATE == DTOA_LATCH)
				DIG_SOUND <= 1'b1;
		end
		endcase
	end
end

`include "CC3_80_NODSK.v"
`include "CC3_88_NODSK.v"
`include "CC3_90_NODSK.v"
`include "CC3_98_NODSK.v"
`include "CC3_A0_NODSK.v"
`include "CC3_A8_NODSK.v"
`include "CC3_B0_NODSK.v"
`include "CC3_B8_NODSK.v"
`include "CC3_C0_NODSK.v"
`include "CC3_C8_NODSK.v"
`include "CC3_D0_NODSK.v"
`include "CC3_D8_NODSK.v"
`include "CC3_E0_NODSK.v"
`include "CC3_E8_NODSK.v"
`include "CC3_F0_NODSK.v"
`include "CC3_F8_NODSK.v"
`include "DSK_C0.v"
`include "DSK_C8.v"
`include "DSK_D0.v"
`include "DSK_D8.v"
/*****************************************************************************
* Digital Joystick to CoCo compatable
* 000000 0
* 010000	16
* 100000 32
* 110000 48
* 111111 63
* left right signal  digtal code
* 10                 000000-001111 0-15
* 11                 010000-101111 16-47
* 01                 110000-111111 48-63
******************************************************************************/

assign JSTICK =	({SEL, PADDLE[1:0], DTOA_CODE[5:3]}	== 7'b1101000)		?	1'b1:	// 0-7
						({SEL, PADDLE[1:0], DTOA_CODE[5]}	== 5'b11110)		?	1'b1: // 0-31
						({SEL, PADDLE[1:0], DTOA_CODE[5]}	== 5'b11100)		?	1'b1: // 0-31
						({SEL, PADDLE[1:0], DTOA_CODE[5:4]}	== 6'b111010)		?	1'b1: // 32-47
						({SEL, PADDLE[1:0], DTOA_CODE[5:3]}	== 7'b1110110)		?	1'b1: // 48-55

						({SEL, PADDLE[3:2], DTOA_CODE[5:3]}	== 7'b1001000)		?	1'b1:	// 0-7
						({SEL, PADDLE[3:2], DTOA_CODE[5]}	== 5'b10110)		?	1'b1: // 0-31
						({SEL, PADDLE[3:2], DTOA_CODE[5]}	== 5'b10100)		?	1'b1: // 0-31
						({SEL, PADDLE[3:2], DTOA_CODE[5:4]}	== 6'b101010)		?	1'b1: // 32-47
						({SEL, PADDLE[3:2], DTOA_CODE[5:3]}	== 7'b1010110)		?	1'b1: // 48-55

						({SEL, PADDLE[5:4], DTOA_CODE[5:3]}	== 7'b0101000)		?	1'b1:	// 0-7
						({SEL, PADDLE[5:4], DTOA_CODE[5]}	== 5'b01110)		?	1'b1: // 0-31
						({SEL, PADDLE[5:4], DTOA_CODE[5]}	== 5'b01100)		?	1'b1: // 0-31
						({SEL, PADDLE[5:4], DTOA_CODE[5:4]}	== 6'b011010)		?	1'b1: // 32-47
						({SEL, PADDLE[5:4], DTOA_CODE[5:3]}	== 7'b0110110)		?	1'b1: // 48-55

						({SEL, PADDLE[7:6], DTOA_CODE[5:3]}	== 7'b0001000)		?	1'b1:	// 0-7
						({SEL, PADDLE[7:6], DTOA_CODE[5]}	== 5'b00110)		?	1'b1: // 0-31
						({SEL, PADDLE[7:6], DTOA_CODE[5]}	== 5'b00100)		?	1'b1: // 0-31
						({SEL, PADDLE[7:6], DTOA_CODE[5:4]}	== 6'b001010)		?	1'b1: // 32-47
						({SEL, PADDLE[7:6], DTOA_CODE[5:3]}	== 7'b0010110)		?	1'b1: // 48-55

																									1'b0;

/*****************************************************************************
* Convert PS/2 keyboard to ASCII keyboard
******************************************************************************/
// Changes from CoCo keyboard
// Shift 2 on PS2 becomes unshifted @
// also unused ` ~ key becomes shifted and unshifted @
assign KEYBOARD_IN[0] =  ~((~KEY_COLUMN[0] & KEY[62] & (KEY[1] | KEY[2]))	// KEY[62] is PS2 2 @
								 | (~KEY_COLUMN[0] & KEY[49])								// KEY[49] is PS2 ` ~
								 | (~KEY_COLUMN[1] & KEY[14])		// A
								 | (~KEY_COLUMN[2] & KEY[20])		// B
								 | (~KEY_COLUMN[3] & KEY[22])		// C
								 | (~KEY_COLUMN[4] & KEY[30])		// D
								 | (~KEY_COLUMN[5] & KEY[38])		// E
								 | (~KEY_COLUMN[6] & KEY[29])		// F
								 | (~KEY_COLUMN[7] & KEY[28])		// G
								 | (~P_SWITCH[0]));

assign KEYBOARD_IN[1] =	 ~((~KEY_COLUMN[0] & KEY[27])		// H
								 | (~KEY_COLUMN[1] & KEY[33])		// I
								 | (~KEY_COLUMN[2] & KEY[26])		// J
								 | (~KEY_COLUMN[3] & KEY[25])		// K
								 | (~KEY_COLUMN[4] & KEY[46])		// L
								 | (~KEY_COLUMN[5] & KEY[18])		// M
								 | (~KEY_COLUMN[6] & KEY[19])		// N
								 | (~KEY_COLUMN[7] & KEY[45])		// O
								 | (~P_SWITCH[1]));

assign KEYBOARD_IN[2] =	 ~((~KEY_COLUMN[0] & KEY[9])		// P
								 | (~KEY_COLUMN[1] & KEY[15])		// Q
								 | (~KEY_COLUMN[2] & KEY[37])		// R
								 | (~KEY_COLUMN[3] & KEY[31])		// S
								 | (~KEY_COLUMN[4] & KEY[36])		// T
								 | (~KEY_COLUMN[5] & KEY[34])		// U
								 | (~KEY_COLUMN[6] & KEY[21])		// V
								 | (~KEY_COLUMN[7] & KEY[39])		// W
								 | (~P_SWITCH[2]));

assign KEYBOARD_IN[3] =	 ~((~KEY_COLUMN[0] & KEY[23])		// X
								 | (~KEY_COLUMN[1] & KEY[35])		// Y
								 | (~KEY_COLUMN[2] & KEY[13])		// Z
								 | (~KEY_COLUMN[3] & KEY[32])		// up
								 | (~KEY_COLUMN[4] & KEY[8])		// down
								 | (~KEY_COLUMN[5] & KEY[16])		// left
								 | (~KEY_COLUMN[5] & KEY[50])		// Backspace
								 | (~KEY_COLUMN[6] & KEY[24])		// right
								 | (~KEY_COLUMN[7] & KEY[12])		// space
								 | (~P_SWITCH[3]));

// Changes from CoCo keyboard
// Caps Lock on PS2 becomes shifted 0
// Shifted ' on PS2 becomes shifted 2(")
// Shifted 7 on PS2 becomes shifted 6(&)
// Shifted 6 on PS2 is also shifted 6(&) since ^ is not used
// Unshifted ' on PS2 becomes shifted 7(')
assign KEYBOARD_IN[4] =	 ~((~KEY_COLUMN[0] & KEY[53] & ~(KEY[1] | KEY[2]))		// KEY[53] is PS2 0 )
								 | (~KEY_COLUMN[0] & CAPS_CLK)								// Caps Lock
								 | (~KEY_COLUMN[1] & KEY[63])									// KEY[63] is PS2 1 !
								 | (~KEY_COLUMN[2] & KEY[62] & ~(KEY[1] | KEY[2]))		// KEY[62] is PS2 2 @
								 | (~KEY_COLUMN[2] & KEY[40] &  (KEY[1] | KEY[2]))		// KEY[40] is PS2 ' "
								 | (~KEY_COLUMN[3] & KEY[61])		// 3
								 | (~KEY_COLUMN[4] & KEY[60])		// 4
								 | (~KEY_COLUMN[5] & KEY[59])		// 5
								 | (~KEY_COLUMN[6] & KEY[58])		// 6
								 | (~KEY_COLUMN[6] & KEY[57] &  (KEY[1] | KEY[2]))		// KEY[57] is PS2 7 &
								 | (~KEY_COLUMN[7] & KEY[57] & ~(KEY[1] | KEY[2]))
								 | (~KEY_COLUMN[7] & KEY[40] & ~(KEY[1] | KEY[2])));	// KEY[49] is PS2 ' "

// Changes from CoCo keyboard
// Shifted 9 on PS2 becomes Shifted 8(()
// Shifted 0 on PS2 becomes shifted 9())
// Shifted ; on PS2 becomes unshifted :
// Shifted 8 on PS2 becomes shift :(*)
// Shifted = on PS2 becomes shifted ;(+)
// Unshifted = on PS2 becomes shifted -(=)
assign KEYBOARD_IN[5] =	 ~((~KEY_COLUMN[0] & KEY[55] & ~(KEY[1] | KEY[2]))		// KEY[55] is PS2 8 *
								 | (~KEY_COLUMN[0] & KEY[54] &  (KEY[1] | KEY[2]))		// KEY[54] is PS2 9 (
								 | (~KEY_COLUMN[1] & KEY[54] & ~(KEY[1] | KEY[2]))
								 | (~KEY_COLUMN[1] & KEY[53] &  (KEY[1] | KEY[2]))		// KEY[53] is PS2 0 )
								 | (~KEY_COLUMN[2] & KEY[10] &  (KEY[1] | KEY[2]))		// KEY[10] is PS2 ; :
								 | (~KEY_COLUMN[2] & KEY[55] &  (KEY[1] | KEY[2]))
								 | (~KEY_COLUMN[3] & KEY[10] & ~(KEY[1] | KEY[2]))
								 | (~KEY_COLUMN[3] & KEY[51] &  (KEY[1] | KEY[2]))		// KEY[51] is PS2 = +
								 | (~KEY_COLUMN[4] & KEY[17])		// , <
								 | (~KEY_COLUMN[5] & KEY[52] & ~(KEY[1] | KEY[2]))		// KEY[52] is PS2 - _
								 | (~KEY_COLUMN[5] & KEY[51] & ~(KEY[1] | KEY[2]))
								 | (~KEY_COLUMN[6] & KEY[47])		// . >
								 | (~KEY_COLUMN[7] & KEY[11]));	// / ?

assign KEYBOARD_IN[6] =	 ~((~KEY_COLUMN[0] & KEY[43])		// CR
								 | (~KEY_COLUMN[1] & KEY[56])		// TAB
								 | (~KEY_COLUMN[2] & KEY[5])		// esc
								 | (~KEY_COLUMN[3] & KEY[7])		// Left ALT
								 | (~KEY_COLUMN[3] & KEY[44])		// Right ALT
								 | (~KEY_COLUMN[3] & BUTTON[2])	// Button 2 for Easter Egg
								 | (~KEY_COLUMN[4] & KEY[6])		// Ctrl
								 | (~KEY_COLUMN[4] & BUTTON[2])	// Button 2 for Easter Egg
								 | (~KEY_COLUMN[5] & F1)
								 | (~KEY_COLUMN[6] & F2)
								 | (~KEY_COLUMN[7] & KEY[2] & ~KEY[62] & ~KEY[10])		// NEVER Shift PS2 2 @ and ; :
								 | (~KEY_COLUMN[7] & KEY[1] & ~KEY[62] & ~KEY[10])
								 | (~KEY_COLUMN[7] & CAPS_CLK)								// Always shift Caps Lock
								 | (~KEY_COLUMN[7] & KEY[51])									// Always shift PS2 = +
								 | (~KEY_COLUMN[7] & KEY[40]));								// Always shift PS2 ' "
					



assign KEYBOARD_IN[7] =	 JSTICK;									// Joystick input

always @(posedge KB_CLK[4] or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		KEY <= 64'h0;
		CAPS_CLK <= 1'b0;
	end
	else
	begin
		case(SCAN)
		8'h16:
		begin
			KEY[63] <= PRESS;	// 1 !
		end
		8'h1E:
		begin
			KEY[62] <= PRESS;	// 2 @
		end
		8'h26:
		begin
			KEY[61] <= PRESS;	// 3 #
		end
		8'h25:
		begin
			KEY[60] <= PRESS;	// 4 $
		end
		8'h2E:
		begin
			KEY[59] <= PRESS;	// 5 %
		end
		8'h36:
		begin
			KEY[58] <= PRESS;	// 6 ^
		end
		8'h3D:
		begin
			KEY[57] <= PRESS;	// 7 &
		end
		8'h0D:
		begin
			KEY[56] <= PRESS;	// TAB
		end
		8'h3E:
		begin
			KEY[55] <= PRESS;	// 8 *
		end
		8'h46:
		begin
			KEY[54] <= PRESS;	// 9 (
		end
		8'h45:
		begin
			KEY[53] <= PRESS;	// 0 )
		end
		8'h4E:
		begin
			KEY[52] <= PRESS;	// - _
		end
		8'h55:
		begin
			KEY[51] <= PRESS;	// = +
		end
		8'h66:
		begin
			KEY[50] <= PRESS;	// backspace
		end
		8'h0E:
		begin
			KEY[49] <= PRESS;	// ` ~
		end
		8'h5D:
		begin
			KEY[48] <= PRESS;	// \ |
		end
		8'h49:
		begin
			KEY[47] <= PRESS;	// . >
		end
		8'h4b:
		begin
			KEY[46] <= PRESS;	// L
		end
		8'h44:
		begin
			KEY[45] <= PRESS;	// O
		end
//		8'h11			KEY[44] <= PRESS; // line feed (really right ALT (Extended) see below
		8'h5A:
		begin
			KEY[43] <= PRESS;	// CR
		end
		8'h54:
		begin
			KEY[42] <= PRESS;	// [ {
		end
		8'h5B:
		begin
			KEY[41] <= PRESS;	// ] }
		end
		8'h52:
		begin
			KEY[40] <= PRESS;	// ' "
		end
		8'h1D:
		begin
			KEY[39] <= PRESS;	// W
		end
		8'h24:
		begin
			KEY[38] <= PRESS;	// E
		end
		8'h2D:
		begin
			KEY[37] <= PRESS;	// R
		end
		8'h2C:
		begin
			KEY[36] <= PRESS;	// T
		end
		8'h35:
		begin
			KEY[35] <= PRESS;	// Y
		end
		8'h3C:
		begin
			KEY[34] <= PRESS;	// U
		end
		8'h43:
		begin
			KEY[33] <= PRESS;	// I
		end
		8'h75:
		begin
			KEY[32] <= PRESS;	// up
		end
		8'h1B:
		begin
			KEY[31] <= PRESS;	// S
		end
		8'h23:
		begin
			KEY[30] <= PRESS;	// D
		end
		8'h2B:
		begin
			KEY[29] <= PRESS;	// F
		end
		8'h34:
		begin
			KEY[28] <= PRESS;	// G
		end
		8'h33:
		begin
			KEY[27] <= PRESS;	// H
		end
		8'h3B:
		begin
			KEY[26] <= PRESS;	// J
		end
		8'h42:
		begin
			KEY[25] <= PRESS;	// K
		end
		8'h74:
		begin
			KEY[24] <= PRESS;	// right
		end
		8'h22:
		begin
			KEY[23] <= PRESS;	// X
		end
		8'h21:
		begin
			KEY[22] <= PRESS;	// C
		end
		8'h2a:
		begin
			KEY[21] <= PRESS;	// V
		end
		8'h32:
		begin
			KEY[20] <= PRESS;	// B
		end
		8'h31:
		begin
			KEY[19] <= PRESS;	// N
		end
		8'h3a:
		begin
			KEY[18] <= PRESS;	// M
		end
		8'h41:
		begin
			KEY[17] <= PRESS;	// , <
		end
		8'h6B:
		begin
			KEY[16] <= PRESS;	// left
		end
		8'h15:
		begin
			KEY[15] <= PRESS;	// Q
		end
		8'h1C:
		begin
			KEY[14] <= PRESS;	// A
		end
		8'h1A:
		begin
			KEY[13] <= PRESS;	// Z
		end
		8'h29:
		begin
			KEY[12] <= PRESS;	// Space
		end
		8'h4A:
		begin
			KEY[11] <= PRESS;	// / ?
		end
		8'h4C:
		begin
			KEY[10] <= PRESS;	// ; :
		end
		8'h4D:
		begin
			KEY[9] <= PRESS;	// P
		end
		8'h72:
		begin
			KEY[8] <= PRESS;	// down
		end
		8'h11:
		begin
			if(~EXTENDED)
						KEY[7] <= PRESS;	// Repeat really left ALT
			else
						KEY[44] <= PRESS;	// LF really right ALT
		end
		8'h14:		KEY[6] <= PRESS;	// Ctrl either left or right
		8'h76:
		begin
			KEY[5] <= PRESS;	// Esc
		end
//		8'h2C:		KEY[4] <= PRESS;	// na
//		8'h35:		KEY[3] <= PRESS;	// na
		8'h12:		KEY[2] <= PRESS;	// L-Shift
		8'h59:		KEY[1] <= PRESS;	// R-Shift
		8'h58:		CAPS_CLK <= PRESS;	// Caps
		8'h05:		F1	<= PRESS;
		8'h06:		F2	<= PRESS;
		endcase
	end
end

//always @(posedge CAPS_CLK or negedge RESET_N)
//begin
//	if(~RESET_N)
//		CAPS <= 1'b1;
//	else
//		CAPS <= ~CAPS;
//end

initial
	KB_CLK <= 0;
always @ (posedge CLK50MHZ)				//50 MHz
	KB_CLK <= KB_CLK + 1'b1;				//50/32 = 1.5625 MHz

wire [2:0] ps2_keyboard_test;
ps2_keyboard KEYBOARD(
		.RESET_N(RESET_N),
		.CLK(KB_CLK[4]),
		.PS2_CLK(ps2_clk),
		.PS2_DATA(ps2_data),
		.RX_SCAN(SCAN),
		.RX_PRESSED(PRESS),
		.RX_EXTENDED(EXTENDED),
    .test(ps2_keyboard_test)
);
/*****************************************************************************
* Video
******************************************************************************/

COCO3VIDEO COCOVID(
	.PIX_CLK(KB_CLK[0]),
	.RESET_N(RESET_N),
	.RED1(RED1),
	.GREEN1(GREEN1),
	.BLUE1(BLUE1),
	.RED0(RED0),
	.GREEN0(GREEN0),
	.BLUE0(BLUE0),
	.HSYNC(H_SYNC),
	.SYNC_FLAG(H_FLAG),
	.VSYNC(V_SYNC),
	.READMEM(READMEM),
	.RAM_ADDRESS(VIDEO_ADDRESS),
	.RAM_DATA({RAM_DATA1_I, RAM_DATA0_I}),
	.VBANK(VBANK),
	.COCO(COCO1),
	.V(V),
	.BP(GRMODE),
	.VERT(VERT),
	.VID_CONT(VDG_CONTROL),
	.HVEN(HVEN),
	.HOR_OFFSET(HOR_OFFSET),
	.SCRN_START_MSB(SCRN_START_MSB),
	.SCRN_START_LSB(SCRN_START_LSB),
 	.CSS(CSS),
	.LPF(LPF),
	.VERT_FIN_SCRL(VERT_FIN_SCRL),
	.LPR(LPR),
	.HRES(HRES),
	.CRES(CRES),
	.BDR_PAL(BDR_PAL),
	.BLINK(BLINK),
	.PALETTE0(PALETTE0),
	.PALETTE1(PALETTE1),
	.PALETTE2(PALETTE2),
	.PALETTE3(PALETTE3),
	.PALETTE4(PALETTE4),
	.PALETTE5(PALETTE5),
	.PALETTE6(PALETTE6),
	.PALETTE7(PALETTE7),
	.PALETTE8(PALETTE8),
	.PALETTE9(PALETTE9),
	.PALETTEA(PALETTEA),
	.PALETTEB(PALETTEB),
	.PALETTEC(PALETTEC),
	.PALETTED(PALETTED),
	.PALETTEE(PALETTEE),
	.PALETTEF(PALETTEF)
);
/*****************************************************************************
* UART timer to kill DOS after an error
******************************************************************************/
assign CPU_NMI = (XART == 8'hFF)	?	1'b1:
												1'b0;
// Write to address sets this to a number of 1/60 second clock tics
// i.e. a 80h selects 127/60 seconds delay before the NMI is issued
// The NMI handler needs to clear this register or set it back to another delay
always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		XART <= 8'h00;
		XSTATE <= 2'b00;
	end
	else
	begin
		if({RW_N, ADDRESS} == 17'H0FF52)
		begin
			XART <= DATA_OUT;
			XSTATE <= 2'b00;
		end
		else
		begin
			case(XSTATE)
			2'b00:
				if(XART != 7'h00)
					XSTATE <= 2'b01;
			2'b01:
				if(V_SYNC == 1'b0)
				begin
					XSTATE <= 2'b10;
				end
			2'b10:
				if(V_SYNC == 1'b1)
				begin
					XSTATE <= 2'b00;
					XART <= XART + 1'b1;
				end
			default:
				XSTATE <= 4'h0;
			endcase
		end
	end
end

/*****************************************************************************
* UART = Floppy
******************************************************************************/
glb6850 COM1(
.RESET_N(RESET_N),
.RX_CLK(COM1_CLOCK[4]),
.TX_CLK(COM1_CLOCK[4]),
.E(PH_2),
.DI(DATA_OUT),
.DO(DATA_COM1),
.CS(COM1_EN),
.RW_N(RW_N),
.IRQ(SER_IRQ),
.RS(ADDRESS[0]),
.TXDATA(TXD1),
.RXDATA(RXD1),
.RTS(RTS1),
.CTS(RTS1),
.DCD(RTS1)
);

/*****************************************************************************
* Hardware based clock
******************************************************************************/
//FFCO CCYY  Century / Year
//FFC2 MMDD  Month / Day
//FFC4 WWHH  Day of week / Hour
//FFC6 MMSS  Minute / Second
//									(ADDRESS == 16'hFFC0)		?	{3'b000, CENT}:
//									(ADDRESS == 16'hFFC1)		?	{1'b1, YEAR}:
//									(ADDRESS == 16'hFFC2)		?	{4'h0, MNTH}:
//									(ADDRESS == 16'hFFC3)		?	{3'b000, DMTH}:
//									(ADDRESS == 16'hFFC4)		?	{5'b00000, DWK}:
//									(ADDRESS == 16'hFFC5)		?	{3'b000, HOUR}:
//									(ADDRESS == 16'hFFC6)		?	{2'b00, MIN}:
//									(ADDRESS == 16'hFFC7)		?	{2'b00, SEC}:

always @(negedge PH_2)
begin
	case({RW_N, ADDRESS})
		17'h0FFC0:
		begin
			CENT <= DATA_OUT[4:0];
		end
		17'h0FFC1:
		begin
			YEAR <= DATA_OUT[6:0];
		end
		17'h0FFC2:
		begin
			MNTH <= DATA_OUT[3:0];
		end
		17'h0FFC3:
		begin
			DMTH <= DATA_OUT[4:0];
		end
		17'h0FFC4:
		begin
			DWK <= DATA_OUT[2:0];
		end
		17'h0FFC5:
		begin
			HOUR <= DATA_OUT[4:0];
		end
		17'h0FFC6:
		begin
			MIN <= DATA_OUT[5:0];
		end
		17'h0FFC7:
		begin
			SEC <= DATA_OUT[5:0];
		end
		default
		begin
			TICK <= V_SYNC;
			if(TICK & ~V_SYNC)
			begin
// 1/60 timer
				if(CLICK == 6'd59)
				begin
					CLICK <= 6'd0;
					if(SEC == 6'd59)
					begin
						SEC <= 6'd0;
						if(MIN == 6'd59)
						begin
							MIN <= 6'd0;
							if(HOUR == 5'd23)
							begin
								HOUR <= 5'd0;
								DMTH <= DMTH + 1'b1;
								if(DWK == 3'd6)
									DWK <= 3'd0;
								else
									DWK <= DWK + 1'b1;
							end
							else
								HOUR <= HOUR + 1'b1;
						end
						else
							MIN <= MIN + 1'b1;
					end
					else
						SEC <= SEC + 1'b1;
				end
				else
					CLICK <= CLICK + 1'b1;
			end	
		end
		endcase
end

endmodule
