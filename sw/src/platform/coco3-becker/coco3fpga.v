`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Project Name:	CoCo3FPGA Version 1.1
// File Name:		coco3fpga.v
//
// CoCo3 in an FPGA
// Based on the Spartan 3 Starter board by Digilent Inc.
// with the 1000K gate upgrade
//
// Revision: 1.0 08/31/08
//           1.1 10/22/08
////////////////////////////////////////////////////////////////////////////////
//
// CPU section copyrighted by John Kent
//
////////////////////////////////////////////////////////////////////////////////
//
// Color Computer 3 compatible system on a chip
//
// Version : 1.1
//
// Copyright (c) 2008 Gary Becker (gary_l_becker@yahoo.com)
//
// All rights reserved
//
// Redistribution and use in source and synthezised forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in synthesized form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// Neither the name of the author nor the names of other contributors may
// be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Please report bugs to the author, but before you do so, please
// make sure that this is not a derivative work and that
// you have the latest version of this file.
//
// The latest version of this file can be found at:
//      http://groups.yahoo.com/group/CoCo3FPGA
//
// File history :
//
//  1.0		Full release
//  1.1		Full Release
//			Included Disk from Software version 1.01
//			Fixed Joystick
//			Added Orchastra-90 CC Stereo Music Synthesizer
//
////////////////////////////////////////////////////////////////////////////////
// Gary Becker
// gary_L_becker@yahoo.com
////////////////////////////////////////////////////////////////////////////////

`define SIX_BIT_COLOR

module coco3fpga(
CLK50MHZ,
// RAM, ROM, and Peripherials
RAM_DATA0_I,				// 16 bit data bus to RAM 0
RAM_DATA0_O,				// 16 bit data bus to RAM 0
RAM_DATA1_I,				// 16 bit data bus to RAM 1
RAM_DATA1_O,				// 16 bit data bus to RAM 1
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
TXD3,
RXD3,
RTS3,
CTS3,
// Display
DIGIT_N,
SEGMENT_N,
// LEDs
LED,
// CoCo Perpherial
SPEAKER,
PADDLE,
PADDLE_RST,
P_SWITCH,

// Extra Buttons and Switches
SWITCH,
BUTTON
);

input				CLK50MHZ;

// Main RAM Common
output [18:0]	RAM_ADDRESS;
output			RAM_RW_N;
reg				RAM_RW_N;

// Main RAM bank 0
input	[15:0]	RAM_DATA0_I;
output	[15:0]	RAM_DATA0_O;
output			RAM0_CS_N;
output			RAM0_BE0_N;
output			RAM0_BE1_N;
output			RAM_OE_N;

// Main RAM bank 1
input	[15:0]	RAM_DATA1_I;
output	[15:0]	RAM_DATA1_O;
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
wire				REDX1;
wire				GREENX1;
wire				BLUEX1;
wire				REDX0;
wire				GREENX0;
wire				BLUEX0;
			
// PS/2
input 			ps2_clk;
input				ps2_data;

// Serial Ports
output			TXD1;
input				RXD1;
output			TXD2;
reg				TXD2;
input				RXD2;
output			TXD3;
input				RXD3;
output			RTS3;
input				CTS3;

// Display
output [3:0]	DIGIT_N;
reg	 [3:0]	DIGIT_N;
output [7:0]	SEGMENT_N;

// LEDs
output [7:0]	LED;

// CoCo Perpherial
output	[1:0]	SPEAKER;
input		[3:0]	PADDLE;
output	[3:0]	PADDLE_RST;
reg		[3:0]	PADDLE_RST;
input		[3:0]	P_SWITCH;

// Extra Buttons and Switches
input [7:0]		SWITCH;				//  7 Special Boink Speed
											//  6 Disk speed 25 / 12.5
											//  5 Swap Left and Right Joystick
											//  4 CART INT Disable
											//  3 MPI [1]
											//  2 MPI [0]
											//  1 CPU_SPEED[1]
											//  0 CPU_SPEED[0]

input [3:0]		BUTTON;				//  3 RESET
											//  2 PAUSE
											//  1 MPI Status / CoCo
											//  0 Easter Egg

reg				PH_2;
reg				RESET_N;
reg				CPU_RESET;
wire				RESET;
wire				RESET_P;
reg	[13:0]		RESET_SM;
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
reg	[5:0]	PIXEL;
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

wire	[7:0]	DOA_RC0;
wire			DOP_RC0;
wire			ENA_RS232C0;

wire	[7:0]	DOA_RC8;
wire			DOP_RC8;
wire			ENA_RS232C8;

wire	[7:0]	DOA_C0_S2;
wire			DOP_C0_S2;
wire			ENA_C0_S2;

reg	[1:0]	MPI_SCS;				// IO select
reg	[1:0]	MPI_CTS;				// ROM select
reg	[1:0]	W_PROT;
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
wire	[55:0] KEY;
wire			SHIFT_OVERRIDE;
wire			SHIFT;
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
wire	[7:0]	SOUND;
wire	[8:0]	DAC_LEFT;
wire	[8:0]	DAC_RIGHT;
reg	[9:0]	PWM_LEFT;
reg	[9:0]	PWM_RIGHT;
reg	[7:0]	ORCH_LEFT;
reg	[7:0]	ORCH_RIGHT;
reg	[1:0]	B_SWITCH;
wire 			H_FLAG;

// wire	[7:0]	STATE;

//reg	[15:0]	MEM_DISPLAY;
//reg	[15:0]	CPU_DISPLAY;
//reg	[7:0]		LED_1;
//reg	[7:0]		LED_2;
//reg				READ_WRITE;
reg	[2:0]		SWITCH_L;

wire				KEY_INT_RAW;

reg				HS_INT;
reg	[1:0]		HS_INT_SM;
reg				VS_INT;
reg	[1:0]		VS_INT_SM;
reg				CD1_INT;
reg	[1:0]		CD1_INT_SM;
reg				CART1_INT;
reg	[1:0]		CART1_INT_SM;

reg				TMR_INT;
reg	[1:0]		TMR_INT_SM;
reg				HBORD_INT;
reg	[1:0]		HBORD_INT_SM;
reg				VBORD_INT;
reg	[1:0]		VBORD_INT_SM;
reg				CD3_INT;
reg	[1:0]		CD3_INT_SM;
reg				KEY_INT;
reg	[1:0]		KEY_INT_SM;
reg				CAR_INT;
reg	[1:0]		CAR_INT_SM;

reg				TMR_FINT;
reg	[1:0]		TMR_FINT_SM;
reg				HBORD_FINT;
reg	[1:0]		HBORD_FINT_SM;
reg				VBORD_FINT;
reg	[1:0]		VBORD_FINT_SM;
reg				CD3_FINT;
reg	[1:0]		CD3_FINT_SM;
reg				KEY_FINT;
reg	[1:0]		KEY_FINT_SM;
reg				CAR_FINT;
reg	[1:0]		CAR_FINT_SM;

wire				CPU_IRQ;
wire				CPU_FIRQ;
wire				CPU_NMI;
reg	[2:0]		DIV_7;
reg	[11:0]	TIMER;
wire				TMR_CLK;
wire				CD_IRQ;
wire				DISK_IRQ;
wire				SER_IRQ;
reg				CART_IRQ;
reg	[4:0]		COM1_CLOCK;
wire	[7:0]		DATA_COM1;
wire				COM1_EN;
wire				COM2_EN;
wire				RTS1;
wire				DTR3;
reg	[1:0]		XSTATE;
reg	[7:0]		XART;
reg	[4:0]		CLK_6551;
wire				RX_CLK2;
wire	[7:0]		DATA_COM2;
reg	[3:0]		ROM_BANK;
wire				SLOT3_HW;

// Clock
//FFCO CCYY  Century / Year
//FFC2 MMDD  Month / Day
//FFC4 WWHH  Day of week / Hour
//FFC6 MMSS  Minute / Second
reg	[4:0]		CENT;
// reg				FLAG;
reg	[6:0]		YEAR;
reg	[3:0]		MNTH;
reg	[4:0]		DMTH;
reg	[2:0]		DWK;
reg	[4:0]		HOUR;
reg	[5:0]		MIN;
reg	[5:0]		SEC;
reg	[5:0]		CLICK;
reg				TICK;

// Joystick
reg	[8:0]		JOY_CLK;
reg	[7:0]		JOY1_MEM;
reg	[7:0]		JOY2_MEM;
reg	[7:0]		JOY3_MEM;
reg	[7:0]		JOY4_MEM;
reg	[5:0]		JOY1_COUNT;
reg	[5:0]		JOY2_COUNT;
reg	[5:0]		JOY3_COUNT;
reg	[5:0]		JOY4_COUNT;
reg	[3:0]		JOY_STATUS;
reg	[7:0]		JOY_STATE;
wire				JSTICK;
wire				JOY1;
wire				JOY2;
wire				JOY3;
wire				JOY4;

assign LED =	{MPI_SCS, CPU_IRQ, CAR_INT, CART_IRQ, IRQ_CART,	CAR_INT_SM};

//assign LED =	(~BUTTON[1])	?	{COM1_EN, ROM_SEL & MPI_CTS[1] & ~MPI_CTS[0], SLOT3_HW, COM2_EN, GIME_IRQ, GIME_FIRQ, CPU_NMI, RW_N}:
//											{2'b00, MPI_CTS, W_PROT, MPI_SCS};

always @ (posedge H_SYNC)					// Anything > 200 HZ
 case(DIGIT_N)
  4'b1110:	DIGIT_N <= 4'b1101;
  4'b1101:	DIGIT_N <= 4'b1011;
  4'b1011:	DIGIT_N <= 4'b0111;
  default:  DIGIT_N <= 4'b1110;
 endcase

assign SEGMENT_N =	(DIGIT_N == 4'b1110) ?	{~RESET_N, 7'b1100010}:	//o
							(DIGIT_N == 4'b1101) ?	{~RESET_N, 7'b0110001}:	//C
							(DIGIT_N == 4'b1011) ?	{~RESET_N, 7'b1100010}:	//o
															{~RESET_N, 7'b0110001};	//C

/*****************************************************************************
* RAM signals
******************************************************************************/
assign	RAM_ADDRESS =	({PH_2, READMEM} == 2'b01)	?	{VBANK, VIDEO_ADDRESS}:
																		{~RAM1_CS_N, BLOCK_ADDRESS[5:0], ADDRESS[12:1]};

assign	BLOCK_ADDRESS =		({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b10000)			?	SAM00[6:0]:		// 10 000X	0000-1FFF
										({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b10001)			?	SAM01[6:0]:		// 10 001X	2000-3FFF
										({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b10010)			?	SAM02[6:0]:		// 10 010X	4000-5FFF
										({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b10011)			?	SAM03[6:0]:		// 10 011X	6000-7FFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'b010100)			?	SAM04[6:0]:		//010 100X	8000-9FFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'b010101)			?	SAM05[6:0]:		//010 101X	A000-BFFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'b010110)			?	SAM06[6:0]:		//010 110X	C000-DFFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:12]} == 7'b0101110)		?	SAM07[6:0]:		//010 1110 X		E000-EFFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:11]} == 8'b01011110)		?	SAM07[6:0]:		//010 1111 0X		F000-F7FF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:10]} == 9'b010111110)		?	SAM07[6:0]:		//010 1111 10X		F800-FBFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:9]} == 10'b0101111110)	?	SAM07[6:0]:		//010 1111 110X	FC00-FDFF
					  ({VEC_PAG_RAM, MMU_EN, MMU_TR, ADDRESS[15:8]} == 11'b01011111110)	?	SAM07[6:0]:		//010 1111 1110 X	FE00-FEFF Vector page as RAM

										({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b11000)			?	SAM10[6:0]:		// 11 000X
										({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b11001)			?	SAM11[6:0]:		// 11 001X
										({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b11010)			?	SAM12[6:0]:		// 11 010X
										({MMU_EN, MMU_TR, ADDRESS[15:13]} ==  5'b11011)			?	SAM13[6:0]:		//011 011X
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'b011100)			?	SAM14[6:0]:		//011 100X
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'b011101)			?	SAM15[6:0]:		//011 101X
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:13]} == 6'b011110)			?	SAM16[6:0]:		//011 110X
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:12]} == 7'b0111110)		?	SAM17[6:0]:		//011 1110 X		E000-EFFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:11]} == 8'b01111110)		?	SAM17[6:0]:		//011 1111 0X		F000-F7FF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:10]} == 9'b011111110)		?	SAM17[6:0]:		//011 1111 10X		F800-FBFF
							({ROM_SEL, MMU_EN, MMU_TR, ADDRESS[15:9]} == 10'b0111111110)	?	SAM17[6:0]:		//011 1111 110X	FC00-FDFF
					  ({VEC_PAG_RAM, MMU_EN, MMU_TR, ADDRESS[15:8]} == 11'b01111111110)	?	SAM17[6:0]:		//011 1111 1110 X	FE00-FEFF Vector page as RAM

							({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110100)					?  {2'b11, ROM_BANK, 1'b0}:	// Slot 3 ROM 8000-9FFF
							({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110101)					?  {2'b11, ROM_BANK, 1'b1}:	// Slot 3 ROM A000-BFFF
							({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110110)					?  {2'b11, ROM_BANK, 1'b0}:	// Slot 3 ROM C000-DFFF Mirror Image of 8000-9FFF
							({ROM_SEL, MPI_CTS, ADDRESS[15:13]} == 6'b110111)					?  {2'b11, ROM_BANK, 1'b1}:	// Slot 3 ROM E000-FDFF Mirror Image of A000-BDFF
																													{4'b0111,ADDRESS[15:13]};

assign	RAM0_CS_N =		({READMEM, ROM_SEL}== 2'b01)								?	1'b1:		// Any slot
//							  	({READMEM, ROM_SEL, MPI_CTS}== 4'b0100)				?	1'b1:		// Slot 1 ROM (RS232)
//								({READMEM, ROM_SEL, MPI_CTS}== 4'b0101)				?	1'b1:		// Slot 2 ROM (CART Loader)
//								({READMEM, ROM_SEL, MPI_CTS}== 4'b0111)				?	1'b1:		// Slot 4 ROM (Disk)
								({READMEM, RAM, ADDRESS[15:14]} == 4'b0010)			?	1'b1:		// ROM (8000-BFFF)
								({READMEM, RAM, ADDRESS[15:13]} == 5'b00110)			?	1'b1:		// ROM (C000-DFFF)
								({READMEM, RAM, ADDRESS[15:12]} == 6'b001110)		?	1'b1:		// ROM (E000-EFFF)
								({READMEM, RAM, ADDRESS[15:11]} == 7'b0011110)		?	1'b1:		// ROM (F000-F8FF)
								({READMEM, RAM, ADDRESS[15:10]} == 8'b00111110)		?	1'b1:		// ROM (F800-FBFF)
								({READMEM, RAM, ADDRESS[15:9]}  == 9'b001111110)	?	1'b1:		// ROM (FC00-FDFF)
// FE00-FEFF enabled unless turned off by BLOCK_ADDRESS[6]=1
								({READMEM, ADDRESS[15:8]}== 9'h0FF)						?	1'b1:		// Hardware (FF00-FFFF)
								({READMEM, BLOCK_ADDRESS[6]} == 2'b01)					?	1'b1:		// 512K - 1M
																										1'b0;		//   0K - 512K

assign	RAM0_BE0_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										ADDRESS[0];		// This is backwards

assign	RAM0_BE1_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										~ADDRESS[0];	// This is backwards

assign	RAM1_CS_N =		({READMEM, ROM_SEL, MPI_CTS} == 4'b0100)							?	1'b1:		// Slot 1 ROM (RS232)
								({READMEM, ROM_SEL, MPI_CTS} == 4'b0101)							?	1'b1:		// Slot 2 ROM (Cart)
								({READMEM, ROM_SEL, MPI_CTS} == 4'b0111)							?	1'b1:		// Slot 4 ROM (DISK)
//								({READMEM, ROM_SEL, RAM, ADDRESS[15:14]} == 5'b00010)			?	1'b1:		// ROM (8000-BFFF)
//								({READMEM, ROM_SEL, RAM, ADDRESS[15:13]} == 6'b000110)		?	1'b1:		// ROM (C000-DFFF)
//								({READMEM, ROM_SEL, RAM, ADDRESS[15:12]} == 7'b0001110)		?	1'b1:		// ROM (E000-EFFF)
//								({READMEM, ROM_SEL, RAM, ADDRESS[15:11]} == 8'b00011110)		?	1'b1:		// ROM (F000-F8FF)
//								({READMEM, ROM_SEL, RAM, ADDRESS[15:10]} == 9'b000111110)	?	1'b1:		// ROM (F800-FBFF)
//								({READMEM, ROM_SEL, RAM, ADDRESS[15:9]}  ==10'b0001111110)	?	1'b1:		// ROM (FC00-FDFF)
// FE00-FEFF enabled unless turned off by BLOCK_ADDRESS[6]=0

								({READMEM, ROM_SEL, RAM, ADDRESS[15]} == 4'b0001)	?	1'b1:		// Internal ROM (8000-FFFF)
								({READMEM, ADDRESS[15:8]}==9'h0FF)						?	1'b1:		// Hardware (FF00-FFFF)
								({READMEM, BLOCK_ADDRESS[6]} == 2'b00)					?	1'b1:		// 0K - 512K
																										1'b0;		// RAM

assign	RAM1_BE0_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										ADDRESS[0];		// This is backwards

assign	RAM1_BE1_N =  	({PH_2, READMEM} == 2'b01)									?	1'b0:
																										~ADDRESS[0];	// This is backwards

assign	RAM_OE_N = ~((~PH_2 & READMEM) | RW_N);
// PH_2	READMEM	RW_N	RAM_OE_N
//	0		0			0		1
//	0		0			1		0
//	0		1			0		0
//	0		1			1		0
//	1		0			0		1
//	1		0			1		0
//	1		1			0		1
//	1		1			1		0

//assign	RAM_DATA0[15:0] = (({READMEM, RW_N}) == 2'b00)	?	{DATA_OUT, DATA_OUT}:
//																				16'bZZZZZZZZZZZZZZZZ;
assign	RAM_DATA0_O[15:0] = {DATA_OUT, DATA_OUT};

//assign	RAM_DATA1[15:0] = (({READMEM, RW_N}) == 2'b00)	?	{DATA_OUT, DATA_OUT}:
//																				16'bZZZZZZZZZZZZZZZZ;
assign	RAM_DATA1_O[15:0] = {DATA_OUT, DATA_OUT};

/*****************************************************************************
* ROM signals
******************************************************************************/

// ROM_SEL is 1 when the system is accessing any cartridge "ROM" meaning the
// 4 slots of the MPI, this is:
//		Slot 1 	RS232 ROM
//		Slot 2	Cart loader ROM
//		Slot 3	Cart slot
//		Slot 4	Disk Controller ROM
assign	ROM_SEL =( RAM								== 1'b1)		?	1'b0:	// All RAM Mode
						( ROM 							== 2'b10)	?	1'b0:	// All Internal
						({ROM[1], ADDRESS[15:14]}	== 3'b010)	?	1'b0: // Lower (Internal) 16 Internal+16 external
						(			 ADDRESS[15]		== 1'b0)		?	1'b0:	// Lower 32K
						(			 ADDRESS[15:8]		== 8'hFE)	?	1'b0:	// Vector space
						(			 ADDRESS[15:8]		== 8'hFF)	?	1'b0:	// Hardware space
																				1'b1;
//ROM
//00		16 Internal + 16 External
//01		16 Internal + 16 External
//10		32 Internal
//11		32 External

assign	ENA_F8 =	({RAM, ROM, ADDRESS[15:8]} == 11'b01011111000)	?	1'b1:	// Internal ROM F800-F8FF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111001)	?	1'b1: // Internal ROM F900-F9FF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111010)	?	1'b1: // Internal ROM FA00-FAFF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111011)	?	1'b1: // Internal ROM FB00-FBFF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111100)	?	1'b1: // Internal ROM FC00-FCFF
						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111101)	?	1'b1: // Internal ROM FD00-FDFF
//						({RAM, ROM, ADDRESS[15:8]} == 11'b01011111110)	?	1'b1: // Internal ROM FE00-FEFF
						({ADDRESS[15:4]} == 12'b111111111111)				?	1'b1:	// Vectors
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
assign	ENA_RS232C8 = ({ROM_SEL, MPI_CTS, ADDRESS[15:11]} == 8'b10011001)	?	1'b1:	// RS232 C800-CFFF
																										1'b0;
assign	ENA_RS232C0 = ({ROM_SEL, MPI_CTS, ADDRESS[15:11]} == 8'b10011000)	?	1'b1:	// RS232 C000-C7FF
																										1'b0;
assign	ENA_C0_S2 =   ({ROM_SEL, MPI_CTS, ADDRESS[15:11]} == 8'b10111000)	?	1'b1:	// CART C000-C7FF
																										1'b0;

assign	COM1_EN = ({MPI_SCS, ADDRESS[15:1]} == 17'b11111111110101000)		?	1'b1:			//FF50-FF51 with MPI switch = 4
																										1'b0;
assign	COM2_EN = (ADDRESS[15:2] == 14'b11111111011010)							?	1'b1:			//FF68-FF6B
																										1'b0;

// If W_PROT[1] = 1 then ROM_RW is 0, else ROM_RW = ~RW_N
assign	ROM_RW = ~(W_PROT[1] | RW_N);

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
														ENA_RS232C0	?	DOA_RC0:
														ENA_RS232C8	?	DOA_RC8:
														ENA_C0_S2	?	DOA_C0_S2:
// FF00, FF04, FF08, FF0C, FF10, FF14, FF18, FF1C
({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100000)	?	DATA_REG1:
// FF01, FF05, FF09, FF0D, FF11, FF15, FF19, FF1D
({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100001)	?	{~HS_INT, 3'd7, SEL[0], DDR1, HSYNC_POL, HSYNC_INT}:
// FF02, FF06, FF0A, FF0E, FF12, FF16, FF1A, FF1E
({ADDRESS[15:5], ADDRESS[1:0]} == 13'b1111111100010)	?	DATA_REG2:
// FF03, FF07, FF0B, FF0F, FF13, FF17, FF1B, FF1F
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100011)	?	{~VS_INT, 3'd7, SEL[1], DDR2, VSYNC_POL, VSYNC_INT}:
// FF20, FF24, FF28, FF2C, FF30, FF34, FF38, FF3C
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100100)	?	DATA_REG3:
// FF21, FF25, FF29, FF2D, FF31, FF35, FF39, FF3D
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100101)	?	{~CD1_INT, 3'd7, CAS_MTR, DDR3, CD_POL, CD_INT}:
// FF22, FF26, FF2A, FF2E, FF32, FF36, FF3A, FF3E
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100110)	?	DATA_REG4:
// FF23, FF27, FF2B, FF2F, FF33, FF37, FF3B, FF3F
({ADDRESS[15:5], ADDRESS[1:0]} == 16'b1111111100111)	?	{~CART1_INT, 3'd7, SOUND_EN, DDR4, CART_POL, CART_INT}:
														COM1_EN		?	DATA_COM1:
														COM2_EN		?	DATA_COM2:
					({MPI_SCS, ADDRESS} == 18'h3FF52)		?	XART:
													SLOT3_HW			?	{4'b0000, ROM_BANK}:
									(ADDRESS == 16'hFF7F)		?	{2'b11, MPI_CTS, W_PROT, MPI_SCS}:
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

always @(posedge CLK50MHZ or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		CLK <= 6'h00;
		SWITCH_L <= 3'b000;
		PH_2 <= 1'b1;
		RAM_RW_N <= 1'b1;
		B_SWITCH <= 2'b00;
	end
	else
	begin
		case (CLK)
		6'h00:
		begin
			B_SWITCH <= SWITCH[1:0];
			if((XART != 8'h00) & ~SWITCH[6])
				SWITCH_L <= 3'b111;									//  High speed for Disk
			else
			begin
				if((XART != 8'h00) & SWITCH[6])
					SWITCH_L <= 3'b101;								//  Lower speed for Disk
				else
					SWITCH_L <= {B_SWITCH, RATE};					// Normal speed
			end
			if(READMEM | BUTTON[2])													// Video memory about to be read (first 50 MHz clock of read cycle)
			begin															// Wait
				CLK <= 6'h00;
				PH_2 <= 1'b0;
				RAM_RW_N <= 1'b1;
			end
			else
			begin															// Video memory not being read
				CLK <= 6'h01;											// Continue on
				PH_2 <= 1'b1;
//								Normal
				RAM_RW_N <= RW_N
//								Protected	and	ROM		and	Slot 3							and	Address >= 8000
							| (~W_PROT[1]	&		ROM_SEL	&		MPI_CTS[1] & ~MPI_CTS[0]	&		ADDRESS[15]);
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
		6'h19:										// 50/24 =  2.083 Test for boink
		begin											// 16.4% overclock
			if(SWITCH[7])
				CLK <= 6'h00;
			else
				CLK <= 6'h1A;
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
assign RESET_P = BUTTON[3] | RESET;
always @ (negedge PIXEL[5] or posedge RESET_P)
begin
	if(RESET_P)
	begin
		RESET_SM <= 14'h0000;
		CPU_RESET <= 1'b1;
		RESET_N <= 1'b0;
	end
	else
		case (RESET_SM)
		14'h3800:
		begin
			RESET_N <= 1'b1;
			CPU_RESET <= 1'b1;
			RESET_SM <= 14'h3801;
		end
		14'h3FFF:
		begin
			RESET_N <= 1'b1;
			CPU_RESET <= 1'b0;
			RESET_SM <= 14'h3FFF;
		end
		default:
			RESET_SM <= RESET_SM + 1'b1;
		endcase
end

CPU09 GLBCPU09(
	.clk(PH_2),
	.rst(CPU_RESET),
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
		case (MPI_SCS)
		2'b00:
			CART_IRQ <= SER_IRQ | SWITCH[4];
		2'b01:
			CART_IRQ <= ~CART_IRQ | SWITCH[4];
		2'b10:
			CART_IRQ <= ~CART_IRQ | SWITCH[4];
		2'b11:
			CART_IRQ <= (DISK_IRQ & SER_IRQ) | SWITCH[4];
		endcase
	end
end

// INT for COCO1
always @ (negedge PH_2)
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
// Start SM at last step to makse sure you see a deasserted trigger
// before triggering the first time
			HS_INT_SM <= 2'b10;
		end
		else								// enabled
		begin
			case (HS_INT_SM)
			2'b00:
			begin
				if((~H_SYNC ^ HSYNC_POL) & H_FLAG)		// 1 = int
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
				if(~((~H_SYNC ^ HSYNC_POL) & H_FLAG))
				begin
					HS_INT <= 1'b1;
					HS_INT_SM <= 2'b00;
				end
			end
			endcase
		end
end

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// V_SYNC int for COCO1
// output	VS_INT
// State		VS_INT_SM
// input		V_SYNC
// switch	VSYNC_INT @ FF03
// pol		VSYNC_POL
// clear    FF02

		if(VSYNC_INT == 1'b0)		// disabled
		begin
			VS_INT <= 1'b1;			// no int
// Start SM at last step to makse sure you see a deasserted trigger
// before triggering the first time
			VS_INT_SM <= 2'b10;
		end
		else								// enabled
		begin
			case (VS_INT_SM)
			2'b00:
			begin
				if(~V_SYNC ^ VSYNC_POL)		// 1 = int
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
				if(~(~V_SYNC ^ VSYNC_POL))
				begin
					VS_INT <= 1'b1;
					VS_INT_SM <= 2'b00;
				end
			end
			endcase
		end
end

assign CD_IRQ = 1'b1;

always @ (negedge PH_2) //  or negedge RESET_N)
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
			CD1_INT_SM <= 2'b10;
		end
		else								// enabled
		begin
			case (CD1_INT_SM)
			2'b00:
			begin
				if(~CD_IRQ ^ CD_POL)
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
				if(~(~CD_IRQ ^ CD_POL))
				begin
					CD1_INT <= 1'b1;
					CD1_INT_SM <= 2'b00;
				end
			end
			endcase
		end
end

always @ (negedge PH_2) //  or negedge RESET_N)
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
			CART1_INT_SM <= 2'b10;
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

// INT for COCO3

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// TIMER int for COCO3
// output	TMR_INT
// State		TMR_INT_SM
// input		TIMER == 12'h000
// switch	IRQ_TMR

		if(IRQ_TMR == 1'b0)		// disabled
		begin
			TMR_INT <= 1'b1;			// no int
			TMR_INT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// H_SYNC int for COCO3
// output	HBORD_INT
// State		HBORD_INT_SM
// input		H_SYNC / H_FLAG
// switch	IRQ_HBORD

		if(IRQ_HBORD == 1'b0)		// disabled
		begin
			HBORD_INT <= 1'b1;			// no int
			HBORD_INT_SM <= 2'b10;
		end
		else								// enabled
		begin
			case (HBORD_INT_SM)
			2'b00:
			begin
				if(~H_SYNC & H_FLAG)		// 1 = int
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
				if(~(~H_SYNC & H_FLAG))
				begin
					HBORD_INT <= 1'b1;
					HBORD_INT_SM <= 2'b00;
				end
			end
			endcase
		end
end
always @ (negedge PH_2) //  or negedge RESET_N)
begin
// V_SYNC int for COCO3
// output	VBORD_INT
// State		VBORD_INT_SM
// input		V_SYNC
// switch	IRQ_VBORD

		if(IRQ_VBORD == 1'b0)		// disabled
		begin
			VBORD_INT <= 1'b1;			// no int
			VBORD_INT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// CD (BitBang) int for COCO3
// output	CD3_INT
// State		CD3_INT_SM
// input		CD_IRQ
// switch	IRQ_SERIAL

		if(IRQ_SERIAL == 1'b0)		// disabled
		begin
			CD3_INT <= 1'b1;			// no int
			CD3_INT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// Keyboard int for COCO3
// output	KEY_INT
// State		KEY_INT_SM
// input		KEY_INT_RAW
// switch	IRQ_KEY

		if(IRQ_KEY == 1'b0)		// disabled
		begin
			KEY_INT <= 1'b1;			// no int
			KEY_INT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// CART (Serial HDD) int for COCO3
// output	CAR_INT
// State		CAR_INT_SM
// input		CART_IRQ
// switch	IRQ_CART
		if(IRQ_CART == 1'b0)		// disabled
		begin
			CAR_INT <= 1'b1;			// no int
			CAR_INT_SM <= 2'b10;
		end
		else								// enabled
		begin
			case (CAR_INT_SM)
			2'b00:							// Wait for int
			begin
				if(~CART_IRQ)				// Int in?
				begin							// Yes
					CAR_INT <= 1'b0;
					CAR_INT_SM <= 2'b01;
				end
				else
				begin
					CAR_INT <= 1'b1;			// No int
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

// FINT for COCO3
always @ (negedge PH_2) //  or negedge RESET_N)
begin
// TIMER fint for COCO3
// output	TMR_FINT
// State		TMR_FINT_SM
// input		TIMER == 12'h000
// switch	FIRQ_TMR

		if(FIRQ_TMR == 1'b0)		// disabled
		begin
			TMR_FINT <= 1'b1;			// no int
			TMR_FINT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// H_SYNC fint for COCO3
// output	HBORD_FINT
// State		HBORD_FINT_SM
// input		H_SYNC / H_FLAG
// switch	FIRQ_HBORD

		if(FIRQ_HBORD == 1'b0)		// disabled
		begin
			HBORD_FINT <= 1'b1;			// no int
			HBORD_FINT_SM <= 2'b10;
		end
		else								// enabled
		begin
			case (HBORD_FINT_SM)
			2'b00:
			begin
				if(~H_SYNC & H_FLAG)		// 1 = int
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
				if((H_SYNC & H_FLAG))
				begin
					HBORD_FINT <= 1'b1;
					HBORD_FINT_SM <= 2'b00;
				end
			end
			endcase
		end
end

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// V_SYNC int for COCO3
// output	VBORD_FINT
// State		VBORD_FINT_SM
// input		V_SYNC
// switch	FIRQ_VBORD

		if(FIRQ_VBORD == 1'b0)		// disabled
		begin
			VBORD_FINT <= 1'b1;			// no int
			VBORD_FINT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// CD (BitBang) int for COCO3
// output	CD3_FINT
// State		CD3_FINT_SM
// input		CD_IRQ
// switch	FIRQ_SERIAL

		if(FIRQ_SERIAL == 1'b0)		// disabled
		begin
			CD3_FINT <= 1'b1;			// no int
			CD3_FINT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// Keyboard int for COCO3
// output	KEY_FINT
// State		KEY_FINT_SM
// input		KEY_INT_RAW
// switch	FIRQ_KEY

		if(FIRQ_KEY == 1'b0)		// disabled
		begin
			KEY_FINT <= 1'b1;			// no int
			KEY_FINT_SM <= 2'b10;
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

always @ (negedge PH_2) //  or negedge RESET_N)
begin
// CART (Serial HDD) int for COCO3
// output	CAR_FINT
// State		CAR_FINT_SM
// input		CART_FINT
// switch	FIRQ_CART

		if(FIRQ_CART == 1'b0)		// disabled
		begin
			CAR_FINT <= 1'b1;			// no int
			CAR_FINT_SM <= 2'b10;
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

// The Cart interrupts had to be modified because they are not self clearing
assign CPU_IRQ =  (HS_INT & VS_INT)
					&	(~GIME_IRQ  | (TMR_INT  & HBORD_INT  & VBORD_INT  & CD3_INT  & KEY_INT  & (!IRQ_CART | CART_IRQ)));
assign CPU_FIRQ = (CD1_INT & CART1_INT)
					&	(~GIME_FIRQ | (TMR_FINT & HBORD_FINT & VBORD_FINT & CD3_FINT & KEY_FINT & (!FIRQ_CART | CART_IRQ)));

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
		SEL[0] <= 1'b0;
// FF02
		DD_REG2 <= 8'h00;
		KEY_COLUMN <= 8'h00;
// FF03
		VSYNC_INT <= 1'b0;
		VSYNC_POL <= 1'b0;
		DDR2 <= 1'b0;
		SEL[1] <= 1'b0;
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
// FF7A
		ORCH_LEFT <= 8'b10000000;
// FF7B
		ORCH_RIGHT <= 8'b10000000;
// FF7F
		W_PROT <= 2'b11;
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
					SEL[0] <= DATA_OUT[3];
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
				SEL[1] <= DATA_OUT[3];
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
			16'hFF7A:
				ORCH_LEFT <= DATA_OUT;
			16'hFF7B:
				ORCH_RIGHT <= DATA_OUT;
			16'hFF7F:
			begin
				W_PROT[0] <=  DATA_OUT[2] | ~DATA_OUT[3];
				W_PROT[1] <= ~DATA_OUT[2] |  DATA_OUT[3] | W_PROT[0];
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

assign SLOT3_HW = ({MPI_SCS, ADDRESS[15:5]} == 13'b1011111111010)	?	1'b1:
																							1'b0;

always @(negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
		ROM_BANK <= 4'b0000;
	else
		if({SLOT3_HW, RW_N} == 2'b10)
			ROM_BANK <= DATA_OUT[3:0];
end

assign SPEAKER[0] =	PWM_LEFT[9];

assign SPEAKER[1] =	PWM_RIGHT[9];

// Internal Sound generation
assign SOUND		=	({SOUND_EN, SEL} == 3'b100)	?	{1'b0, SBS, 6'b000000} + {1'b0, DTOA_CODE, 1'b0}:
																		{1'b0, SBS, 6'b000000};

assign DAC_LEFT	=	ORCH_LEFT	+ SOUND;
assign DAC_RIGHT	=	ORCH_RIGHT	+ SOUND;

always @(posedge PIXEL[3])												// Clock = 50/16 = 3.125 MHz
begin
	PWM_LEFT		<= PWM_LEFT[8:0]	+ DAC_LEFT;
	PWM_RIGHT	<= PWM_RIGHT[8:0]	+ DAC_RIGHT;
end

// ROMS
`include "CC3_80.v"
`include "CC3_88.v"
`include "CC3_90.v"
`include "CC3_98.v"
`include "CC3_A0.v"
`include "CC3_A8.v"
`include "CC3_B0.v"
`include "CC3_B8.v"
`include "CC3_C0.v"
`include "CC3_C8.v"
`include "CC3_D0.v"
`include "CC3_D8.v"
`include "CC3_E0.v"
`include "CC3_E8.v"
`include "CC3_F0.v"
`include "CC3_F8.v"
`include "DSK_C0.v"
`include "DSK_C8.v"
`include "DSK_D0.v"
`include "DSK_D8.v"
`include "RS232_C0.v"
`include "RS232_C8.v"
`include "CART_C0.v"

/*****************************************************************************
* Joystick to CoCo compatable
******************************************************************************/
always @(posedge CLK50MHZ or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		JOY_CLK <= 9'h000;
	end
	else
		case(JOY_CLK)
		9'd288:
		begin
			JOY_CLK <= 9'd000;
		end
		default:
			JOY_CLK <= JOY_CLK + 1'b1;			//  JOY_CLK = 50MHz/288 = 173,611.1 Hz
		endcase
end

always @(posedge JOY_CLK[8] or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		PADDLE_RST <= 4'b0000;				// Reset all Joysticks
		JOY1_MEM <= 8'h00;
		JOY2_MEM <= 8'h00;
		JOY3_MEM <= 8'h00;
		JOY4_MEM <= 8'h00;
		JOY_STATE <= 8'h00;
		JOY_STATUS <= 4'b0000;
	end
	else
	begin
		JOY_STATUS <= PADDLE;
		case(JOY_STATE)
		8'h00:
		begin
			JOY_STATE <= 8'h01;
			PADDLE_RST <= 4'b1111;
			if(!PADDLE[0])
				JOY1_MEM <= 8'h00;
			if(!PADDLE[1])
				JOY2_MEM <= 8'h00;
			if(!PADDLE[2])
				JOY3_MEM <= 8'h00;
			if(!PADDLE[3])
				JOY4_MEM <= 8'h00;
		end
		8'hFC:
		begin
			JOY_STATE <= 8'hFD;
			if({JOY_STATUS[0],PADDLE[0]} != 2'b00)
				JOY1_MEM <= 8'hFF;
			if({JOY_STATUS[1],PADDLE[1]} != 2'b00)
				JOY2_MEM <= 8'hFF;
			if({JOY_STATUS[2],PADDLE[2]} != 2'b00)
				JOY3_MEM <= 8'hFF;
			if({JOY_STATUS[3],PADDLE[3]} != 2'b00)
				JOY4_MEM <= 8'hFF;
		end
		8'hFD:
		begin
			JOY1_COUNT <= JOY1_MEM[7:2];
			JOY2_COUNT <= JOY2_MEM[7:2];
			JOY3_COUNT <= JOY3_MEM[7:2];
			JOY4_COUNT <= JOY4_MEM[7:2];
			if(CLICK[3])						// Wait here until DEB_COUNTER[3] goes high
			begin
				JOY_STATE <= 8'hFE;
			end
		end
		8'hFE:
		begin
			if(!CLICK[3])						// Wait here until DEB_COUNTER[3] goes low
			begin
				JOY_STATE <= 8'hFF;
				PADDLE_RST <= 4'b0000;
			end
		end
		8'hFF:
		begin
			JOY_STATE <= 8'h00;
			PADDLE_RST <= 4'b1111;
		end
		default:
		begin
			JOY_STATE <= JOY_STATE + 1'b1;

			if({JOY_STATUS[0],PADDLE[0]} == 2'b10)		//Edge detect falling edge
			begin
				JOY1_MEM <= JOY_STATE;
			end

			if({JOY_STATUS[1],PADDLE[1]} == 2'b10)		//Edge detect falling edge
			begin
				JOY2_MEM <= JOY_STATE;
			end

			if({JOY_STATUS[2],PADDLE[2]} == 2'b10)		//Edge detect falling edge
			begin
				JOY3_MEM <= JOY_STATE;
			end

			if({JOY_STATUS[3],PADDLE[3]} == 2'b10)		//Edge detect falling edge
			begin
				JOY4_MEM <= JOY_STATE;
			end

		end
		endcase
	end
end

assign JSTICK =	({SWITCH[5], SEL} == 3'b011)		?	JOY4:			// Left Y
						({SWITCH[5], SEL} == 3'b010)		?	JOY3:			// Left X
						({SWITCH[5], SEL} == 3'b001)		?	JOY2:			// Right Y
						({SWITCH[5], SEL} == 3'b000)		?	JOY1:			// Right X
						({SWITCH[5], SEL} == 3'b111)		?	JOY2:			// Right Y
						({SWITCH[5], SEL} == 3'b110)		?	JOY1:			// Right X
						({SWITCH[5], SEL} == 3'b101)		?	JOY4:			// Left Y
																		JOY3;			// Left X

assign JOY1 = (JOY1_COUNT >= DTOA_CODE)	?	1'b1:
															1'b0;

assign JOY2 = (JOY2_COUNT >= DTOA_CODE)	?	1'b1:
															1'b0;

assign JOY3 = (JOY3_COUNT >= DTOA_CODE)	?	1'b1:
															1'b0;

assign JOY4 = (JOY4_COUNT >= DTOA_CODE)	?	1'b1:
															1'b0;

/*****************************************************************************
* Convert PS/2 keyboard to ASCII keyboard
******************************************************************************/
assign KEYBOARD_IN[0] =  ~((~KEY_COLUMN[0] & KEY[0])				// @
								 | (~KEY_COLUMN[1] & KEY[1])				// A
								 | (~KEY_COLUMN[2] & KEY[2])				// B
								 | (~KEY_COLUMN[3] & KEY[3])				// C
								 | (~KEY_COLUMN[4] & KEY[4])				// D
								 | (~KEY_COLUMN[5] & KEY[5])				// E
								 | (~KEY_COLUMN[6] & KEY[6])				// F
								 | (~KEY_COLUMN[7] & KEY[7])				// G
								 | (~SWITCH[5]     & ~P_SWITCH[0])		// Right Joystick Switch 1
								 | ( SWITCH[5]     & ~P_SWITCH[2]));	// Left Joystick Switch 1

assign KEYBOARD_IN[1] =	 ~((~KEY_COLUMN[0] & KEY[8])				// H
								 | (~KEY_COLUMN[1] & KEY[9])				// I
								 | (~KEY_COLUMN[2] & KEY[10])				// J
								 | (~KEY_COLUMN[3] & KEY[11])				// K
								 | (~KEY_COLUMN[4] & KEY[12])				// L
								 | (~KEY_COLUMN[5] & KEY[13])				// M
								 | (~KEY_COLUMN[6] & KEY[14])				// N
								 | (~KEY_COLUMN[7] & KEY[15])				// O
								 | (~SWITCH[5]     & ~P_SWITCH[2])		// Left Joystick Switch 1
								 | ( SWITCH[5]     & ~P_SWITCH[0]));	// Right Joystick Switch 1

assign KEYBOARD_IN[2] =	 ~((~KEY_COLUMN[0] & KEY[16])				// P
								 | (~KEY_COLUMN[1] & KEY[17])				// Q
								 | (~KEY_COLUMN[2] & KEY[18])				// R
								 | (~KEY_COLUMN[3] & KEY[19])				// S
								 | (~KEY_COLUMN[4] & KEY[20])				// T
								 | (~KEY_COLUMN[5] & KEY[21])				// U
								 | (~KEY_COLUMN[6] & KEY[22])				// V
								 | (~KEY_COLUMN[7] & KEY[23])				// W
								 | (~SWITCH[5]     & ~P_SWITCH[1])		// Left Joystick Switch 2
								 | ( SWITCH[5]     & ~P_SWITCH[3]));	// Right Joystick Switch 2

assign KEYBOARD_IN[3] =	 ~((~KEY_COLUMN[0] & KEY[24])				// X
								 | (~KEY_COLUMN[1] & KEY[25])				// Y
								 | (~KEY_COLUMN[2] & KEY[26])				// Z
								 | (~KEY_COLUMN[3] & KEY[27])				// up
								 | (~KEY_COLUMN[4] & KEY[28])				// down
								 | (~KEY_COLUMN[5] & KEY[29])				// Backspace & left
								 | (~KEY_COLUMN[6] & KEY[30])				// right
								 | (~KEY_COLUMN[7] & KEY[31])				// space
								 | (~SWITCH[5]     & ~P_SWITCH[3])		// Right Joystick Switch 2
								 | ( SWITCH[5]     & ~P_SWITCH[1]));	// Left Joystick Switch 2

assign KEYBOARD_IN[4] =	 ~((~KEY_COLUMN[0] & KEY[32])		// 0
								 | (~KEY_COLUMN[1] & KEY[33])		// 1
								 | (~KEY_COLUMN[2] & KEY[34])		// 2
								 | (~KEY_COLUMN[3] & KEY[35])		// 3
								 | (~KEY_COLUMN[4] & KEY[36])		// 4
								 | (~KEY_COLUMN[5] & KEY[37])		// 5
								 | (~KEY_COLUMN[6] & KEY[38])		// 6
								 | (~KEY_COLUMN[7] & KEY[39]));	// 7

assign KEYBOARD_IN[5] =	 ~((~KEY_COLUMN[0] & KEY[40])		// 8
								 | (~KEY_COLUMN[1] & KEY[41])		// 9
								 | (~KEY_COLUMN[2] & KEY[42])		// :
								 | (~KEY_COLUMN[3] & KEY[43])		// ;
								 | (~KEY_COLUMN[4] & KEY[44])		// ,
								 | (~KEY_COLUMN[5] & KEY[45])		// -
								 | (~KEY_COLUMN[6] & KEY[46])		// .
								 | (~KEY_COLUMN[7] & KEY[47]));	// /

assign KEYBOARD_IN[6] =	 ~((~KEY_COLUMN[0] & KEY[48])		// CR
								 | (~KEY_COLUMN[1] & KEY[49])		// TAB
								 | (~KEY_COLUMN[2] & KEY[50])		// ESC
								 | (~KEY_COLUMN[3] & KEY[51])		// ALT
								 | (~KEY_COLUMN[4] & KEY[52])		// CTRL
								 | (~KEY_COLUMN[5] & KEY[53])		// F1
								 | (~KEY_COLUMN[6] & KEY[54])		// F2
								 | (~KEY_COLUMN[7] & KEY[55] & !SHIFT_OVERRIDE)	// shift
								 |	(~KEY_COLUMN[7] & SHIFT));		// Forced Shift

assign KEYBOARD_IN[7] =	 JSTICK;									// Joystick input

COCOKEY coco_keyboard(
		.RESET_N(RESET_N),
		.CLK50MHZ(CLK50MHZ),
		.PS2_CLK(ps2_clk),
		.PS2_DATA(ps2_data),
		.KEY(KEY),
		.SHIFT(SHIFT),
		.SHIFT_OVERRIDE(SHIFT_OVERRIDE),
		.RESET(RESET)
);

/*****************************************************************************
* Video
******************************************************************************/
`ifdef SIX_BIT_COLOR
	assign RED1 = REDX1;
	assign RED0 = REDX0;
	assign GREEN1 = GREENX1;
	assign GREEN0 = GREENX0;
	assign BLUE1 = BLUEX1;
	assign BLUE0 = BLUEX0;
`else

//	X1	X0
// 0	0		Not asserted
//	0	1		asserted in fourth quarter of pixel
//	1	0		asserted in second half of pixel
//	1	1		asserted in last 3/4 of pixel clock

	assign RED1		= (REDX1 & PIXEL[0])						// 1/2 of the pixel clock
						| (REDX0 & (~PIXEL[0] & CLK50MHZ));	// 1/4 of the pixel clock
	assign RED0		= 1'b0;											// not connected
	assign GREEN1	= (GREENX1 & PIXEL[0])						// 1/2 of the pixel clock
						| (GREENX0 & (~PIXEL[0] & CLK50MHZ));	// 1/4 of the pixel clock
	assign GREEN0	= 1'b0;											// not connected
	assign BLUE1	= (BLUEX1 & PIXEL[0])						// 1/2 of the pixel clock
						| (BLUEX0 & (~PIXEL[0] & CLK50MHZ));	// 1/4 of the pixel clock
	assign BLUE0	= 1'b0;											// not connected
`endif

always @(posedge CLK50MHZ)
	PIXEL <= PIXEL + 1'b1;

COCO3VIDEO COCOVID(
	.PIX_CLK(PIXEL[0]),
	.RESET_N(RESET_N),
	.RED1(REDX1),
	.GREEN1(GREENX1),
	.BLUE1(BLUEX1),
	.RED0(REDX0),
	.GREEN0(GREENX0),
	.BLUE0(BLUEX0),
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
		if({MPI_SCS, RW_N, ADDRESS} == 19'b1101111111101010010)
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
.IRQ(DISK_IRQ),
.RS(ADDRESS[0]),
.TXDATA(TXD1),
.RXDATA(RXD1),
.RTS(RTS1),
.CTS(RTS1),
.DCD(RTS1)
);

always @(posedge CLK50MHZ or negedge RESET_N)
begin
	if(~RESET_N)
		CLK_6551 <= 5'd0;
	else
		case(CLK_6551)
		5'd26:
			CLK_6551 <= 5'd0;
		default:
			CLK_6551 <= CLK_6551 + 1'b1;
		endcase
end

glb6551 COM2(
.RESET_N(RESET_N),
.RX_CLK(RX_CLK2),
.RX_CLK_IN(CLK_6551[4]),
.XTAL_CLK_IN(CLK_6551[4]),
.PH_2(PH_2),
.DI(DATA_OUT),
.DO(DATA_COM2),
.IRQ(SER_IRQ),
.CS({1'b0, COM2_EN}),
.RW_N(RW_N),
.RS(ADDRESS[1:0]),
.TXDATA_OUT(TXD3),
.RXDATA_IN(RXD3),
.RTS(RTS3),
.CTS(CTS3),
.DCD(DTR3),
.DTR(DTR3),
.DSR(DTR3)
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
//			FLAG <= ~FLAG;
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
