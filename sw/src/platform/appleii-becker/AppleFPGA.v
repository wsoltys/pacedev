/*****************************************************************************
* AppleFPGA APPLE ][e core.
*
*
* Ver 1.0
* July 2006
* Latest version from gbfpgaapple.tripod.com
*
******************************************************************************
*
* CPU section copyrighted by Daniel Wallner
*
******************************************************************************
*
* Apple ][e compatible system on a chip
*
* Version : 1.0
*
* Copyright (c) 2006 Gary Becker (gary_l_becker@yahoo.com)
*
* All rights reserved
*
* Redistribution and use in source and synthezised forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* Redistributions of source code must retain the above copyright notice,
* this list of conditions and the following disclaimer.
*
* Redistributions in synthesized form must reproduce the above copyright
* notice, this list of conditions and the following disclaimer in the
* documentation and/or other materials provided with the distribution.
*
* Neither the name of the author nor the names of other contributors may
* be used to endorse or promote products derived from this software without
* specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*
* Please report bugs to the author, but before you do so, please
* make sure that this is not a derivative work and that
* you have the latest version of this file.
*
* The latest version of this file can be found at:
*      http://gbfpgaapple.tripod.com
*
* Limitations :
*
*  AppleFPGA is not designed to share the C800-CFFF address space.
*  There is enough ROM space in the C400-C4FF to store a few routines
*  for the C700 (Serial Drive) ROM.
*
* File history :
*
*  0.9 	First release (ALPHA)
*  0.95	Second release (BETA)
*  1.0	Full release
*
******************************************************************************/

module AppleFPGA(
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
RED,
GREEN,
BLUE,
H_SYNC,
V_SYNC,
// PS/2
ps2_clk,
ps2_data,
//Serial Ports
TXD1,
RXD1,
// Display
DIGIT_N,
SEGMENT_N,
// LEDs
LED,
// Apple Perpherial
SPEAKER,
PADDLE,
P_SWITCH,
DTOA_CODE,
// Extra Buttons and Switches
SWITCH,
BUTTON
);

input				CLK50MHZ;

// Main RAM Common
output [17:0]	RAM_ADDRESS;
output			RAM_RW_N;

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
output			RED;
output			GREEN;
output			BLUE;
output			H_SYNC;
output			V_SYNC;

// PS/2
input 			ps2_clk;
input				ps2_data;

// Serial Ports
output			TXD1;
input				RXD1;

// Display
output [3:0]	DIGIT_N;
output [7:0]	SEGMENT_N;

// LEDs
output [7:0]	LED;

// Apple Perpherial
output			SPEAKER;
input		[3:0]	PADDLE;
input		[2:0]	P_SWITCH;
output	[7:0]	DTOA_CODE;

// Extra Buttons and Switches
input [7:0]		SWITCH;				//  7 System type 1	Not used
											//  6 System type 0	Not used
											//  5 Serial Port speed
											//  4 Swap floppy
											//  3 Write protect floppy 2
											//  2 Write protect floppy 1
											//  1 CPU_SPEED[1]
											//  0 CPU_SPEED[0]

input [3:0]		BUTTON;				//  3 RESET
											//  2 Not used
											//  1 Closed Apple
											//  0 Open Apple 

reg	[7:0]		DTOA_CODE;

reg	[7:0]	CLK;
reg				VGA_CLK;
reg	[6:0]		COM1_CLOCK;
wire				RTS1;
wire				RESET_N;
reg				PH_2;
reg				RAM0_CS_Y;
reg				COM1_CLK;
// Processor
wire				IRQ;
wire				NMI;
wire				RW_N;
wire				READY;
wire				SYNC;
wire	[7:0]		DATA_IN;
wire	[7:0]		DATA_OUT;
wire	[15:0]	ADDRESS;
wire	[7:0]		CPU_BANK;
wire				ENA_F8;
wire				ENA_F0;
wire				ENA_E8;
wire				ENA_E0;
wire				ENA_D8;
wire				ENA_D0;
wire				ENA_C8;
wire				SLOT_4IO;	// Clock
wire				SLOT_6IO;	// Floppy
wire				SLOT_7IO;	// Serial Port Prodos drive

wire	[7:0]		DOA_F8;
wire	[7:0]		DOA_F0;
wire	[7:0]		DOA_E8;
wire	[7:0]		DOA_E0;
wire	[7:0]		DOA_D8;
wire	[7:0]		DOA_D0;
wire	[7:0]		DOA_C8;
wire	[7:0]		DOA_C0I;
wire	[7:0]		DOA_C0S;
wire				ROM_RW;
wire				APPLE_C0;
reg				APPLE_PRESSED;
wire				APPLE_STATUS_BIT;
wire				A_KEY_PRESSED;
reg	[6:0]		ASCII;
wire	[7:0]		VRAM_DATA0;
wire				V_BLANKING;
reg	[63:0]	KEY;
reg	[57:0]	LAST_KEY;
reg				CAPS_CLK;
reg				CAPS;
wire	[7:0]		SCAN;
wire				PRESS;
wire				EXTENDED;

wire	[10:0]	VROM_ADDRESS;
wire	[7:0]		DATA_COM1;

reg				ARAM_RD;
reg				ARAM_WR;
reg				SLOTCXROM;
reg				ALT_ZP;
reg				SLOT_C3ROM;
reg				STORE_80;
reg				ALT_CHAR;
reg				TEXT_80;
wire				OPEN_APL;
wire				CLOSED_APL;
reg				TEXT;
reg				MIXED;
reg				SECONDARY;
reg				HGR;
reg				DHRES;
reg				SPEAKER;
wire				RAM0_CS_X;
reg	[3:0]		DIGIT_N;
reg	[3:0]		KB_CLK;
reg	[3:0]		YEARS_TENS;
reg	[3:0]		YEARS_ONES;
reg				MONTHS_TENS;
reg	[3:0]		MONTHS_ONES;
reg	[2:0]		DAY_WEEK;
reg	[1:0]		DAYS_TENS;
reg	[3:0]		DAYS_ONES;
reg	[1:0]		HOURS_TENS;
reg	[3:0]		HOURS_ONES;
reg	[2:0]		MINUTES_TENS;
reg	[3:0]		MINUTES_ONES;
reg	[2:0]		SECONDS_TENS;
reg	[3:0]		SECONDS_ONES;
reg	[7:0]		DEB_COUNTER;
reg	[14:0]	TIME;
reg	[42:0]	TIME_SET;
wire	[7:0]		CLK_IN;
wire	[7:0]		CLOCK_MUX;
reg				ROM_WR_EN;
reg	[2:0]		USER_C;
wire	[15:0]	APPLE_ADDRESS;
wire				CLK_MOD;
reg	[12:0]	FLOPPY_BYTE;
reg	[4:0]		FLOPPY_CLK;
reg	[1:0]		STEPPER1;
reg	[1:0]		STEPPER2;
reg	[16:0]	TRACK1;
reg	[16:0]	TRACK2;
wire	[16:0]	TRACK;
wire	[16:0]	TRACK1_UP;
wire	[16:0]	TRACK1_DOWN;
wire	[16:0]	TRACK2_UP;
wire	[16:0]	TRACK2_DOWN;
wire	[17:0]	FLOPPY_ADDRESS;
reg	[7:0]		FLOPPY_WRITE_DATA;
reg	[7:0]		LAST_WRITE_DATA;
wire	[7:0]		FLOPPY_RD_DATA;
wire	[7:0]		FLOPPY_DATA;
wire				FLOPPY_READ;
wire				FLOPPY_WRITE;
wire				FLOPPY_WP_READ;
reg				PHASE0;
reg				PHASE0_1;
reg				PHASE0_2;
reg				PHASE1;
reg				PHASE1_1;
reg				PHASE1_2;
reg				PHASE2;
reg				PHASE2_1;
reg				PHASE2_2;
reg				PHASE3;
reg				PHASE3_1;
reg				PHASE3_2;
reg				DRIVE1;
reg				MOTOR;
reg				Q6;
reg				Q7;
wire				DRIVE1_EN;
wire				DRIVE2_EN;
wire				DRIVE1_X;
wire				DRIVE2_X;
reg				LC_BANK1;
reg				LC_BANK2;
reg				LC_BANK1_W;
reg				LC_BANK2_W;
reg				LC_BANK;
reg	[4:0]		BANK;
wire	[1:0]		BANK_ADDRESS;
reg				LC_WE;
wire				APPLE_TXT_RAM;
wire				APPLE_HR_RAM;
wire				APPLE_LC_RAM;
wire				APPLE_ZP_RAM;
wire				APPLE_MAIN_RAM;
reg	[4:0]		JOY_TIMER;

assign IRQ = 1'b1;
assign NMI = 1'b1;
assign READY = 1'b1;
assign RESET_N = !BUTTON[3];

always @ (posedge H_SYNC)					// Anything > 200 HZ
 case(DIGIT_N)
  4'b1110:	DIGIT_N <= 4'b1101;
  4'b1101:	DIGIT_N <= 4'b1011;
  4'b1011:	DIGIT_N <= 4'b0111;
  default:  DIGIT_N <= 4'b1110;
 endcase

assign SEGMENT_N =	(DIGIT_N == 4'b1110) ?	{RESET_N, 7'b0110000}:	//E
							(DIGIT_N == 4'b1101) ?	{RESET_N, 7'b0110001}:	//[
							(DIGIT_N == 4'b1011) ?	{RESET_N, 7'b0000111}:	//]
															{RESET_N, 7'b0001000};	//A
// LEDs
//
//	0	Floppy PH_3
// 1	Floppy PH_2
// 2	Floppy PH_1
// 3	Floppy PH_0
// 4	ROMs write enabled
// 5	Floppy drive 1 busy
//	6	Floppy drive 2 busy
// 7	Serial drive busy

assign LED = {SLOT_7IO, DRIVE2_X, DRIVE1_X, ROM_WR_EN, PHASE3, PHASE2, PHASE1, PHASE0};

/*****************************************************************
* Generates the Clocks from the 50 MHz clock 
*
* VGA_CLK is 25 MHz (VGA pixel clock)
*
* SWITCH		1		0
* 				ON		ON				Stop
*				ON		OFF			PH_2 = 16.07 MHz
* 				OFF	ON				PH_2 = 2.083 MHz
* 				OFF	OFF			PH_2 = 1.042 MHz
******************************************************************/

always @(negedge CLK50MHZ)
	VGA_CLK <= !VGA_CLK;

// CPU clock
always @(posedge CLK50MHZ)
begin
	case (CLK)
	8'h00:
		if(!CLK_MOD)
		begin
			PH_2 <= 1'b1;
			CLK <= 8'h01;
		end
	8'h01:
		if(!CLK_MOD)
		begin
			PH_2 <= 1'b1;
			CLK <= 8'h02;
		end
	8'h02:
	begin
		PH_2 <= 1'b0;
		if(SWITCH[1:0] == 2'b10)
			CLK <= 8'h00;
		else
			CLK <= 8'h03;
	end
	8'h17:
	begin
		if(SWITCH[1:0] == 2'b01)
			CLK <= 8'h00;
		else
			CLK <= 8'h18;
	end
	8'h2F:
	begin
		if(SWITCH[1:0] == 2'b00)
			CLK <= 8'h00;
		else
			CLK <= 8'h30;
	end
	8'hFF:
	begin
		if(SWITCH[1:0] != 2'b11)
			CLK <= 8'h00;
		else
			CLK <= 8'hFF;
	end
	default:
	begin
		CLK <= CLK + 1'b1;
	end
	endcase
end

always @(posedge CLK50MHZ)
	begin
		case (COM1_CLOCK)
		7'h00:
		begin
			COM1_CLK <= !COM1_CLK;
			COM1_CLOCK <= 7'h01;
		end
		7'h1A:											// 50/(27*2) = 925925.93 921600/16 = 57600
		begin
			if(!SWITCH[5])
				COM1_CLOCK <= 7'h00;
			else
				COM1_CLOCK <= 7'h1B;
		end
		7'h51:											// 50/(82*2) = 304878.05 307200/16 = 19200
		begin
				COM1_CLOCK <= 7'h00;
		end
		default:
			COM1_CLOCK <= COM1_CLOCK + 1'b1;
		endcase
	end

/*****************************************************************************
* 6502 Processor 
******************************************************************************/

T65 GLB6502(
  .Clk(~PH_2),
  .Abort_n(1'b1),
  .NMI_n(NMI),
  .Rdy(1'b1),
  .Enable(1'b1),
  .Res_n(RESET_N),
  .SO_n(1'b1),
  .IRQ_n(IRQ),
  .EF(EF),
  .R_W_n(RW_N),
  .VDA(VDA),
  .MF(MF),
  .VPA(VPA),
  .ML_n(ML_N),
  .XF(XF),
  .Sync(SYNC),
  .VP_n(VP_N),
  .DI(DATA_IN),
  .Mode(2'b00),
  .DO(DATA_OUT),
  .A({CPU_BANK, ADDRESS})
);

/*****************************************************************************
* Enables for internal memory
******************************************************************************/
//	F800 - FFFF
assign ENA_F8 = 	({LC_BANK1, LC_BANK2, ADDRESS[15:11]} == 7'b0011111)	?	1'b1:
																									1'b0;

// F000 - F7FF
assign ENA_F0 = 	({LC_BANK1, LC_BANK2, ADDRESS[15:11]} == 7'b0011110)	?	1'b1:
																									1'b0;

// E800 - EFFF
assign ENA_E8 = 	({LC_BANK1, LC_BANK2, ADDRESS[15:11]} == 7'b0011101)	?	1'b1:
																									1'b0;

// E000 - E7FF
assign ENA_E0 =	({LC_BANK1, LC_BANK2, ADDRESS[15:11]} == 7'b0011100)	?	1'b1:
																									1'b0;

// D800 - DFFF
assign ENA_D8 =	({LC_BANK1, LC_BANK2, ADDRESS[15:11]} == 7'b0011011)	?	1'b1:
																									1'b0;
// D000 - D7FF
assign ENA_D0 =	({LC_BANK1, LC_BANK2, ADDRESS[15:11]} == 7'b0011010)	?	1'b1:
																									1'b0;

// C800 - CFFF
assign ENA_C8 =	({ADDRESS[15:11]} == 5'b11001) 								?	1'b1:
																									1'b0;

// C100 - C7FF Slot ROMs
assign ENA_C0S =	({SLOTCXROM, ADDRESS[15:8]} == 9'h0C1)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h0C2)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h0C4)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h0C5)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h0C6)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h0C7)						?	1'b1:
																									1'b0;
// C100 - C7FF Internal ROM
assign ENA_C0I =	({SLOTCXROM, ADDRESS[15:8]} == 9'h1C1)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h1C2)						?	1'b1:
						({(SLOTCXROM | !SLOT_C3ROM),ADDRESS[15:8]} == 9'h1C3)	?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h1C4)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h1C5)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h1C6)						?	1'b1:
						({SLOTCXROM, ADDRESS[15:8]} == 9'h1C7)						?	1'b1:
																									1'b0;

// C060 Text Color and ROM write enable
// Write a color value into this location to change text screen color
// This also write enables the ROMs
// Color = 
// read from this location to write protect the ROMs
always @ (negedge PH_2 or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		ROM_WR_EN <= 1'b0;
		USER_C <= 3'd2;
	end
	else
		case ({RW_N, ADDRESS})
			17'H0C060:
			begin
				USER_C <= DATA_OUT[2:0];		// Set user Color
				ROM_WR_EN <= 1'b1;				// Apple write protect ROM
			end
//			17'H0C070:	DTOA_CODE <= DATA_OUT[7:0];
			17'H1C060:	ROM_WR_EN <= 1'b0;				// Apple write protect ROM
		endcase
end

/*****************************************************************************
* Apple Memory Enables
*****************************************************************************/

assign APPLE_C0	= (ADDRESS[15:7]	== 9'b110000000)							?	1'b1:
																									1'b0;

assign SLOT_4IO	= (ADDRESS[15:4]	== 12'hC0C)									?	1'b1:
																									1'b0;

assign SLOT_6IO	= (ADDRESS[15:4]	== 12'hC0E)									?	1'b1:
																									1'b0;

assign SLOT_7IO	= (ADDRESS[15:4]	== 12'hC0F)									?	1'b1:
																									1'b0;

/*****************************************************************************
* Most of the standard 2E mode selection bits
******************************************************************************/

assign OPEN_APL =		 KEY[7]				// Left ALT key decoded
						| 	!P_SWITCH[0]		// Paddle button 0
						|	 BUTTON[0];			// Push button 0

assign CLOSED_APL =	 KEY[44]				// Right ALT key decoded
						|	!P_SWITCH[1]		// Paddle button 1
						|	 BUTTON[1];			// Push button 1

assign SHIFT_KEY	=	(KEY[1]
						|	 KEY[2]
//						|	 CAPS					//AppleWin does not have this
						|	!P_SWITCH[2]
						|	 BUTTON[2]);

assign APPLE_STATUS_BIT =	({APPLE_C0, ADDRESS[7:0]} == 9'h100)	?	APPLE_PRESSED:
									({APPLE_C0, ADDRESS[7:0]} == 9'h110)	?	A_KEY_PRESSED:
									({APPLE_C0, ADDRESS[7:0]} == 9'h111)	?	LC_BANK:
									({APPLE_C0, ADDRESS[7:0]} == 9'h112)	?	(LC_BANK1 | LC_BANK2):
									({APPLE_C0, ADDRESS[7:0]} == 9'h113)	?	ARAM_RD:
									({APPLE_C0, ADDRESS[7:0]} == 9'h114)	?	ARAM_WR:
									({APPLE_C0, ADDRESS[7:0]} == 9'h115)	?	SLOTCXROM:
									({APPLE_C0, ADDRESS[7:0]} == 9'h116)	?	ALT_ZP:
									({APPLE_C0, ADDRESS[7:0]} == 9'h117)	?	SLOT_C3ROM:
									({APPLE_C0, ADDRESS[7:0]} == 9'h118)	?	STORE_80:
									({APPLE_C0, ADDRESS[7:0]} == 9'h119)	?	V_BLANKING:
									({APPLE_C0, ADDRESS[7:0]} == 9'h11A)	?	TEXT:
									({APPLE_C0, ADDRESS[7:0]} == 9'h11B)	?	MIXED:
									({APPLE_C0, ADDRESS[7:0]} == 9'h11C)	?	SECONDARY:
									({APPLE_C0, ADDRESS[7:0]} == 9'h11D)	?	HGR:
									({APPLE_C0, ADDRESS[7:0]} == 9'h11E)	?	ALT_CHAR:
									({APPLE_C0, ADDRESS[7:0]} == 9'h11F)	?	TEXT_80:
//									({APPLE_C0, ADDRESS[7:0]} == 9'h160)	?	P_SWITCH[2]:
									({APPLE_C0, ADDRESS[7:0]} == 9'h161)	?	OPEN_APL:
									({APPLE_C0, ADDRESS[7:0]} == 9'h162)	?	CLOSED_APL:
									({APPLE_C0, ADDRESS[7:0]} == 9'h163)	?	SHIFT_KEY:
									({APPLE_C0, ADDRESS[7:0]} == 9'h164)	?	!PADDLE[0]:
									({APPLE_C0, ADDRESS[7:0]} == 9'h165)	?	!PADDLE[1]:
									({APPLE_C0, ADDRESS[7:0]} == 9'h166)	?	!PADDLE[2]:
									({APPLE_C0, ADDRESS[7:0]} == 9'h167)	?	!PADDLE[3]:
									({APPLE_C0, ADDRESS[7:0]} == 9'h17F)	?	DHRES:
																							1'b1;

always @(negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		TEXT_80 <= 1'b0;
		ALT_CHAR <= 1'b0;
		TEXT	<= 1'b1;
		MIXED <= 1'b0;
		SECONDARY <= 1'b0;
		DHRES <= 1'b0;
		HGR <= 1'b0;
		SPEAKER <= 1'b0;
		STORE_80 <= 1'b0;
		ARAM_RD <= 1'b0;
		ARAM_WR <= 1'b0;
		SLOTCXROM <= 1'b0;
		ALT_ZP <= 1'b0;
		SLOT_C3ROM <= 1'b0;
	end
	else
	begin
			if(~RW_N)
			begin
				case({APPLE_C0, ADDRESS[7:0]})
				9'h100:		STORE_80 <= 1'b0;
				9'h101:		STORE_80 <= 1'b1;
				9'h102:		ARAM_RD <= 1'b0;
				9'h103:		ARAM_RD <= 1'b1;
				9'h104:		ARAM_WR <= 1'b0;
				9'h105:		ARAM_WR <= 1'b1;
				9'h106:		SLOTCXROM <= 1'b0;
				9'h107:		SLOTCXROM <= 1'b1;
				9'h108:		ALT_ZP <= 1'b0;
				9'h109:		ALT_ZP <= 1'b1;
				9'h10A:		SLOT_C3ROM <= 1'b0;
				9'h10B:		SLOT_C3ROM <= 1'b1;
				9'h10C:		TEXT_80 <= 1'b0;			// Text 40 Mode
				9'h10D:		TEXT_80 <= 1'b1;			// Text 80 Mode
				9'h10E:		ALT_CHAR <= 1'b0;			// Text 40 Mode
				9'h10F:		ALT_CHAR <= 1'b1;			// Text 80 Mode
				9'h150:		TEXT <= 1'b0;			// Set Graphics Mode
				9'h151:		TEXT <= 1'b1;			// Set Text Mode
				9'h152:		MIXED <= 1'b0;			// Set Full Screen Graphics Mode
				9'h153:		MIXED <= 1'b1;			//	Set Mixed-Screen Graphics Mode
				9'h154:		SECONDARY <= 1'b0;	//	Set HI-RES Page 2 off
				9'h155:		SECONDARY <= 1'b1;	//	Set HI-RES Page 2 on
				9'h156:		HGR <= 1'b0;			//	Set HI-RES mode off
				9'h157:		HGR <= 1'b1;			//	Set HI-RES mode on
				9'h15E:		DHRES <= 1'b1;					// Clear Game I/O AN-3 output = 1
				9'h15F:		DHRES <= 1'b0;					// Set Game I/O AN-3 output = 0
				endcase
			end
			else
			begin
				case({APPLE_C0, ADDRESS[7:0]})
				9'h130:		SPEAKER <= ~SPEAKER;
				9'h150:		TEXT <= 1'b0;			// Set Graphics Mode
				9'h151:		TEXT <= 1'b1;			// Set Text Mode
				9'h152:		MIXED <= 1'b0;			// Set Full Screen Graphics Mode
				9'h153:		MIXED <= 1'b1;			//	Set Mixed-Screen Graphics Mode
				9'h154:		SECONDARY <= 1'b0;	//	Set HI-RES Page 2 off
				9'h155:		SECONDARY <= 1'b1;	//	Set HI-RES Page 2 on
				9'h156:		HGR <= 1'b0;			//	Set HI-RES mode off
				9'h157:		HGR <= 1'b1;			//	Set HI-RES mode on
				9'h15E:		DHRES <= 1'b1;					// Clear Game I/O AN-3 output = 1
				9'h15F:		DHRES <= 1'b0;					// Set Game I/O AN-3 output = 0
				endcase
			end
	end
end

/*****************************************************************************
* RAM Drive card 384k
*
* Looks like RAMWorks III card with 1 Bank of 256K
* and 3 more banks of 64K
******************************************************************************/

always @(negedge PH_2 or negedge RESET_N)
begin
	if(!RESET_N)
		BANK <= 5'b00000;
	else
		if({RW_N, ADDRESS[15:0]} == 17'h0C073)
			BANK <= {(DATA_OUT[7]|DATA_OUT[6]|DATA_OUT[5]|DATA_OUT[4]),DATA_OUT[3:0]};
end

/*****************************************************************************
* Joystick interface
* Replace charging cap with R-2R Ladder Digital to Analog Converter
* The original timing would change digital values every 11 clock cycles
* Calculated 13.5 uS with our circuit
* Since our circuit is different count starts at 28
******************************************************************************/
assign PADDLE_RESET = ({RW_N, ADDRESS[15:0]} == 17'h1C070)			?	1'b0:
																							1'b1;

parameter	OFFSET =	8'hB8;
parameter	RANGE  =	5'h12;

always @(negedge PH_2 or negedge PADDLE_RESET)
	if(!PADDLE_RESET)
		JOY_TIMER <= 5'b00000;
	else
		case (JOY_TIMER)
			RANGE:
				JOY_TIMER <= 5'b00000;
			default:
				JOY_TIMER <= JOY_TIMER + 1'b1;
		endcase

always @(negedge JOY_TIMER[4] or negedge PADDLE_RESET)
begin
	if(!PADDLE_RESET)
		DTOA_CODE <= OFFSET;
	else
		case(DTOA_CODE)
		8'h00:	DTOA_CODE <= 8'h00;
		default:	DTOA_CODE <= DTOA_CODE - 1'b1;
		endcase
end

/*****************************************************************************
* Language Card Memory
*
*           $C080 ;LC RAM bank2, Read and WR-protect RAM 
*ROMIN =    $C081 ;LC RAM bank2, Read ROM instead of RAM, 
*                 ;two or more successive reads WR-enables RAM 
*           $C082 ;LC RAM bank2, Read ROM instead of RAM, 
*                 ;WR-protect RAM 
*LCBANK2 =  $C083 ;LC RAM bank2, Read RAM 
*                 ;two or more successive reads WR-enables RAM 
*           $C088 ;LC RAM bank1, Read and WR-protect RAM 
*           $C089 ;LC RAM bank1, Read ROM instead of RAM, 
*                 ;two or more successive reads WR-enables RAM 
*           $C08A ;LC RAM bank1, Read ROM instead of RAM, 
*                 ;WR-protect RAM 
*LCBANK1 =  $C08B ;LC RAM bank1, Read RAM 
*                 ;two or more successive reads WR-enables RAM 
*           $C084-$C087 are echoes of $C080-$C083 
*           $C08C-$C08F are echoes of $C088-$C08B 
*  
******************************************************************************/
always @(negedge PH_2 or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		LC_BANK1 <= 1'b0;
		LC_BANK2 <= 1'b0;
		LC_BANK1_W <= 1'b0;
		LC_BANK2_W <= 1'b0;
		LC_BANK	<= 1'b0;
		LC_WE <= 1'b0;
	end
	else
	begin
		case(ADDRESS[15:0])
		16'hC080:							// Read RAM bank 2 no write
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b1;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b0;
		end
		16'hC081:							// Read ROM write RAM bank 2 (RR)
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= LC_WE | !RW_N;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b1;
		end
		16'hC082:							// Read ROM no write
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b0;
		end
		16'hC083:							// Read bank 2 write bank 2(RR)
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b1;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= LC_WE | !RW_N;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b1;
		end
		16'hC084:							// Read bank 2 no write
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b1;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b0;
		end
		16'hC085:
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= LC_WE | !RW_N;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b1;
		end
		16'hC086:
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b0;
		end
		16'hC087:
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b1;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= LC_WE | !RW_N;
			LC_BANK	<= 1'b1;
			LC_WE <= 1'b1;
		end
		16'hC088:
		begin
			LC_BANK1 <= 1'b1;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b0;
		end
		16'hC089:
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= LC_WE | !RW_N;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b1;
		end
		16'hC08A:
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b0;
		end
		16'hC08B:
		begin
			LC_BANK1 <= 1'b1;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= LC_WE | !RW_N;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b1;
		end
		16'hC08C:
		begin
			LC_BANK1 <= 1'b1;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b0;
		end
		16'hC08D:
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= LC_WE | !RW_N;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b1;
		end
		16'hC08E:
		begin
			LC_BANK1 <= 1'b0;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= 1'b0;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b0;
		end
		16'hC08F:
		begin
			LC_BANK1 <= 1'b1;
			LC_BANK2 <= 1'b0;
			LC_BANK1_W <= LC_WE | !RW_N;
			LC_BANK2_W <= 1'b0;
			LC_BANK	<= 1'b0;
			LC_WE <= 1'b1;
		end
		endcase
	end
end

/*****************************************************************************
* Data bus mux
******************************************************************************/
assign DATA_IN	=		(ENA_F8)			?	DOA_F8:
                		(ENA_F0)			?	DOA_F0:
					 		(ENA_E8)			?	DOA_E8:
					 		(ENA_E0)			?	DOA_E0:
					 		(ENA_D8)			?	DOA_D8:
					 		(ENA_D0)			?	DOA_D0:
					 		(ENA_C8)			?	DOA_C8:
					 		(ENA_C0I)		?	DOA_C0I:
					 		(ENA_C0S)		?	DOA_C0S:
							(APPLE_C0)		?	{APPLE_STATUS_BIT, ASCII}:
							(SLOT_4IO)		?	CLK_IN:
							(SLOT_7IO)		?	DATA_COM1:
							(SLOT_6IO)		?	FLOPPY_DATA:
							(!RAM0_BE0_N)	?	RAM_DATA0_I[7:0]:
							(!RAM0_BE1_N)	?	RAM_DATA0_I[15:8]:
													8'h00;

/*****************************************************************************
* 32 Bit output data to external RAM
******************************************************************************/
`ifdef XILINX_RUBBISH
	bufif0(RAM_DATA0[0], DATA_OUT[0], RAM_RW_N);
	bufif0(RAM_DATA0[1], DATA_OUT[1], RAM_RW_N);
	bufif0(RAM_DATA0[2], DATA_OUT[2], RAM_RW_N);
	bufif0(RAM_DATA0[3], DATA_OUT[3], RAM_RW_N);
	bufif0(RAM_DATA0[4], DATA_OUT[4], RAM_RW_N);
	bufif0(RAM_DATA0[5], DATA_OUT[5], RAM_RW_N);
	bufif0(RAM_DATA0[6], DATA_OUT[6], RAM_RW_N);
	bufif0(RAM_DATA0[7], DATA_OUT[7], RAM_RW_N);

	bufif0(RAM_DATA0[8],  DATA_OUT[0], RAM_RW_N);
	bufif0(RAM_DATA0[9],  DATA_OUT[1], RAM_RW_N);
	bufif0(RAM_DATA0[10], DATA_OUT[2], RAM_RW_N);
	bufif0(RAM_DATA0[11], DATA_OUT[3], RAM_RW_N);
	bufif0(RAM_DATA0[12], DATA_OUT[4], RAM_RW_N);
	bufif0(RAM_DATA0[13], DATA_OUT[5], RAM_RW_N);
	bufif0(RAM_DATA0[14], DATA_OUT[6], RAM_RW_N);
	bufif0(RAM_DATA0[15], DATA_OUT[7], RAM_RW_N);

	bufif0(RAM_DATA1[0], FLOPPY_WRITE_DATA[0], RAM_RW_N);
	bufif0(RAM_DATA1[1], FLOPPY_WRITE_DATA[1], RAM_RW_N);
	bufif0(RAM_DATA1[2], FLOPPY_WRITE_DATA[2], RAM_RW_N);
	bufif0(RAM_DATA1[3], FLOPPY_WRITE_DATA[3], RAM_RW_N);
	bufif0(RAM_DATA1[4], FLOPPY_WRITE_DATA[4], RAM_RW_N);
	bufif0(RAM_DATA1[5], FLOPPY_WRITE_DATA[5], RAM_RW_N);
	bufif0(RAM_DATA1[6], FLOPPY_WRITE_DATA[6], RAM_RW_N);
	bufif0(RAM_DATA1[7], FLOPPY_WRITE_DATA[7], RAM_RW_N);

	bufif0(RAM_DATA1[8],  FLOPPY_WRITE_DATA[0], RAM_RW_N);
	bufif0(RAM_DATA1[9],  FLOPPY_WRITE_DATA[1], RAM_RW_N);
	bufif0(RAM_DATA1[10], FLOPPY_WRITE_DATA[2], RAM_RW_N);
	bufif0(RAM_DATA1[11], FLOPPY_WRITE_DATA[3], RAM_RW_N);
	bufif0(RAM_DATA1[12], FLOPPY_WRITE_DATA[4], RAM_RW_N);
	bufif0(RAM_DATA1[13], FLOPPY_WRITE_DATA[5], RAM_RW_N);
	bufif0(RAM_DATA1[14], FLOPPY_WRITE_DATA[6], RAM_RW_N);
	bufif0(RAM_DATA1[15], FLOPPY_WRITE_DATA[7], RAM_RW_N);
`else
	assign RAM_DATA0_O[7:0] = DATA_OUT[7:0];
	assign RAM_DATA0_O[15:8] = DATA_OUT[7:0];
	assign RAM_DATA1_O[7:0] = FLOPPY_WRITE_DATA[7:0];
	assign RAM_DATA1_O[15:8] = FLOPPY_WRITE_DATA[7:0];
`endif

/*****************************************************************************
* Other external RAM signals
******************************************************************************/
assign APPLE_MAIN_RAM	=	({APPLE_ZP_RAM, APPLE_TXT_RAM, ADDRESS[15:12]} == 6'h00)	?	1'b1:
									(ADDRESS[15:12] == 4'h1)											?	1'b1:
									({APPLE_HR_RAM, ADDRESS[15:12]} == 5'h02)						?	1'b1:
									({APPLE_HR_RAM, ADDRESS[15:12]} == 5'h03)						?	1'b1:
									(ADDRESS[15:12] == 4'h4)											?	1'b1:
									(ADDRESS[15:12] == 4'h5)											?	1'b1:
									(ADDRESS[15:12] == 4'h6)											?	1'b1:
									(ADDRESS[15:12] == 4'h7)											?	1'b1:
									(ADDRESS[15:12] == 4'h8)											?	1'b1:
									(ADDRESS[15:12] == 4'h9)											?	1'b1:
									(ADDRESS[15:12] == 4'hA)											?	1'b1:
									(ADDRESS[15:12] == 4'hB)											?	1'b1:
																													1'b0;

assign APPLE_ZP_RAM		=	(ADDRESS[15:8] == 8'h00)											?	1'b1:				// 0000 - 00FF
									(ADDRESS[15:8]	== 8'h01)											?	1'b1:				// 0100 - 01FF
																													1'b0;

assign APPLE_HR_RAM		=	({STORE_80, HGR,	ADDRESS[15:13]} == 5'b11001)				?  1'b1:
																											 		1'b0;

assign APPLE_TXT_RAM		=	({STORE_80, ADDRESS[15:10]}	== 7'b1000001)					?  1'b1:
																													1'b0;

assign APPLE_LC_RAM		=	(ADDRESS[15:12] == 4'hF)											?	1'b1:
									(ADDRESS[15:12] == 4'hE)											?	1'b1:
									(ADDRESS[15:12] == 4'hD)											?	1'b1:
																													1'b0;

assign RAM0_CS_N = !(CLK_MOD | (RW_N & !RAM0_CS_X) | !RAM0_CS_Y);

// RAM enables
assign RAM0_CS_X = 	(ADDRESS[15] == 1'b0)													?	1'b0:		// 0000 - 7FFF
							(ADDRESS[15:13] == 3'b100)												?	1'b0:		// 8000 - 9FFF
							(ADDRESS[15:13] == 3'b101)												?	1'b0:		// A000 - BFFF
							({SLOT_6IO, ADDRESS[3:0]} == 5'h1C)									?	1'b0:		// Floppy
							(ADDRESS[15:12] == 4'b1101)											?	1'b0:		// D000 - DFFF
							(ADDRESS[15:13] == 3'b111)												?	1'b0:		// E000 - FFFF
																												1'b1;

// Modifies the RAM chip select for 20 nS
// This is used to cause a transistion to the memory CS
// when apple video reads
always @(negedge CLK50MHZ)
begin
	case (CLK)
	20'h00001:
	begin
			RAM0_CS_Y <= RW_N | RAM0_CS_X;
	end
	20'h00002:
	begin
		RAM0_CS_Y <= 1'b1;
	end
	default:
		RAM0_CS_Y <= 1'b1;
	endcase
end

assign RAM_OE_N = 1'b0;

assign RAM_RW_N =	  (CLK_MOD)							? 1'b1:			// Video always reads from memory
						  (FLOPPY_WRITE )					? 1'b0:			// When we write to a floppy we are actually reading a registar
																  RW_N;			// Normal RW

/*****************************************************************************
* RAM Address MUX
******************************************************************************/
//								Video
assign RAM_ADDRESS =		(CLK_MOD)																			?	{2'b00, APPLE_ADDRESS[15:0]}:
//								Floppy
								({PH_2, SLOT_6IO} == 2'b11)												?	FLOPPY_ADDRESS:
//								Language Card bank 2
			({PH_2, ((LC_BANK2 & RW_N) | (LC_BANK2_W & !RW_N)), ADDRESS[15:12]} == 6'h3D)	?	{BANK_ADDRESS, ADDRESS[15:13], 1'b0, ADDRESS[11:0]}:
																														{BANK_ADDRESS, ADDRESS[15:0]};

assign RAM1_CS_N =	!((FLOPPY_READ | FLOPPY_WRITE) & PH_2);

assign BANK_ADDRESS =	({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h01F)	?	2'b01:
								({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h02F)	?	2'b10:
								({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h03F)	?	2'b11:
								({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h04F)	?	2'b01:
								({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h08F)	?	2'b10:
								({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h0CF)	?	2'b11:
							({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h01E)?	2'b01:
							({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h02E)?	2'b10:
							({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h03E)?	2'b11:
							({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h04E)?	2'b01:
							({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h08E)?	2'b10:
							({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h0CE)?	2'b11:
							({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0000111)										?	2'b01:
							({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0001011)										?	2'b10:
							({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0001111)										?	2'b11:
							({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0010011)										?	2'b01:
							({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0100011)										?	2'b10:
							({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0110011)										?	2'b11:
							({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b00001111)							?	2'b01:
							({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b00010111)							?	2'b10:
							({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b00011111)							?	2'b11:
							({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b00100111)							?	2'b01:
							({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b01000111)							?	2'b10:
							({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b01100111)							?	2'b11:
							({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b00001110)							?	2'b01:
							({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b00010110)							?	2'b10:
							({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b00011110)							?	2'b11:
							({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b00100110)							?	2'b01:
							({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b01000110)							?	2'b10:
							({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b01100110)							?	2'b11:
																																2'b00;

assign RAM0_BE0_N =	// Video
							( CLK_MOD	 		== 1'b1)																?	1'b0:
							// Language Card Area reads
							({APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 4'b1011)		?	1'b0:
					({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h04F)		?	1'b0:
					({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h08F)		?	1'b0:
					({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 9'h0CF)		?	1'b0:
							// Language Card Area writes
							({APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 4'b1010)	?	1'b0:
					({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h04E)	?	1'b0:
					({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h08E)	?	1'b0:
					({BANK, APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 9'h0CE)	?	1'b0:
							// ZP and stack
							({APPLE_ZP_RAM, ALT_ZP} == 2'b10)												?	1'b0:
					({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0010011)											?	1'b0:
					({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0100011)											?	1'b0:
					({BANK, APPLE_ZP_RAM, ALT_ZP} == 7'b0110011)											?	1'b0:
				 			// Video Memory Text and lowres
							({APPLE_TXT_RAM, SECONDARY} == 2'b10)											?	1'b0:
							// Hires
							({APPLE_HR_RAM, SECONDARY} == 2'b10)											?	1'b0:
							// Main RAM
							({APPLE_MAIN_RAM, ARAM_RD, RW_N} == 3'b101)									?	1'b0:
					({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b00100111)								?	1'b0:
					({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b01000111)								?	1'b0:
					({BANK, APPLE_MAIN_RAM, ARAM_RD, RW_N} == 8'b01100111)								?	1'b0:
							({APPLE_MAIN_RAM, ARAM_WR, RW_N} == 3'b100)									?	1'b0:
					({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b00100110)								?	1'b0:
					({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b01000110)								?	1'b0:
					({BANK, APPLE_MAIN_RAM, ARAM_WR, RW_N} == 8'b01100110)								?	1'b0:
																															1'b1;

assign RAM0_BE1_N =	// Video
							( CLK_MOD	 		== 1'b1)																?	1'b0:
							// Language Card Area reads
				({BANK[4:2], APPLE_LC_RAM, ALT_ZP, (LC_BANK1 | LC_BANK2), RW_N} == 7'b0001111)	?	1'b0:
							// Language Card Area writes
				({BANK[4:2], APPLE_LC_RAM, ALT_ZP, (LC_BANK1_W | LC_BANK2_W), RW_N} == 7'b0001110)	?	1'b0:
							// ZP and stack
				({BANK[4:2], APPLE_ZP_RAM, ALT_ZP} == 5'b00011)											?	1'b0:
				 			// Video Memory Text and lowres
							({APPLE_TXT_RAM, SECONDARY} == 2'b11)											?	1'b0:
							// Hires
							({APPLE_HR_RAM, SECONDARY} == 2'b11)											?	1'b0:
							// Main RAM
				({BANK[4:2], APPLE_MAIN_RAM, ARAM_RD, RW_N} == 6'b000111)								?	1'b0:
				({BANK[4:2], APPLE_MAIN_RAM, ARAM_WR, RW_N} == 6'b000110)								?	1'b0:
																															1'b1;

assign RAM1_BE0_N =	!DRIVE1_EN;																				// Byte 0 Enable for RAM 1
assign RAM1_BE1_N =	!DRIVE2_EN;																				// Byte 1 Enable for RAM 1

assign ROM_RW = 	ROM_WR_EN & ~RW_N;

/*****************************************************************************
* ROMs
* List Groups
******************************************************************************/
`include "../../../../src/platform/appleii-becker/rom_f8.v"
`include "../../../../src/platform/appleii-becker/rom_f0.v"
`include "../../../../src/platform/appleii-becker/rom_e8.v"
`include "../../../../src/platform/appleii-becker/rom_e0.v"
`include "../../../../src/platform/appleii-becker/rom_d8.v"
`include "../../../../src/platform/appleii-becker/rom_d0.v"
`include "../../../../src/platform/appleii-becker/rom_c8.v"
`include "../../../../src/platform/appleii-becker/rom_c0i.v"
`include "../../../../src/platform/appleii-becker/rom_c0s.v"
`include "../../../../src/platform/appleii-becker/chargen.v"

/*****************************************************************************
* Hardware Clock
******************************************************************************/
assign CLK_IN =
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10000)?  8'h32:							// Year thousand
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10001)?  8'h30:							// Year hundreds
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10010)? {4'h3,  YEARS_TENS}:			// Year tens
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10011)? {4'h3,  YEARS_ONES}:			// Year ones
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10100)? {7'h18, MONTHS_TENS}:		// Month tens
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10101)? {4'h3,  MONTHS_ONES}:		// Month ones
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10110)? {5'h06, DAY_WEEK}:			// Day of week
		({SLOT_4IO, ADDRESS[3:0]}== 5'b10111)? {6'h0C, DAYS_TENS}:
		({SLOT_4IO, ADDRESS[3:0]}== 5'b11000)? {4'h3,  DAYS_ONES}:
		({SLOT_4IO, ADDRESS[3:0]}== 5'b11001)? {6'h0C, HOURS_TENS}:
		({SLOT_4IO, ADDRESS[3:0]}== 5'b11010)? {4'h3,  HOURS_ONES}:
		({SLOT_4IO, ADDRESS[3:0]}== 5'b11011)? {5'h06, MINUTES_TENS}:
		({SLOT_4IO, ADDRESS[3:0]}== 5'b11100)? {4'h3,  MINUTES_ONES}:
		({SLOT_4IO, ADDRESS[3:0]}== 5'b11101)? {5'h06, SECONDS_TENS}:
		({SLOT_4IO, ADDRESS[3:0]}== 5'b11110)? {4'h3,  SECONDS_ONES}:
															DEB_COUNTER;		/*Not needed for Apple*/

always @ (negedge PH_2 or negedge RESET_N)
begin
	if(~RESET_N)
		TIME_SET <= 43'h000000;
	else
		case({SLOT_4IO, RW_N, ADDRESS[3:0]})
		6'b100000:	TIME_SET[42]    <= DATA_OUT[7];				// set
		6'b100001:	TIME_SET[42]    <= DATA_OUT[7];				// set
		6'b100010:	TIME_SET[41:38] <= DATA_OUT[3:0];			// Years tens
		6'b100011:	TIME_SET[37:34] <= DATA_OUT[3:0];			// Years ones
		6'b100100:	TIME_SET[33]    <= DATA_OUT[0];				// Months tens
		6'b100101:	TIME_SET[32:29] <= DATA_OUT[3:0];			// Months ones
		6'b100110:	TIME_SET[28:26] <= DATA_OUT[2:0];			// Day of Week
		6'b100111:	TIME_SET[25:24] <= DATA_OUT[1:0];			// Days tens
		6'b101000:	TIME_SET[23:20] <= DATA_OUT[3:0];			// Days ones
		6'b101001:	TIME_SET[19:18] <= DATA_OUT[1:0];			// Hours tens
		6'b101010:	TIME_SET[17:14] <= DATA_OUT[3:0];			// Hours ones
		6'b101011:	TIME_SET[13:11] <= DATA_OUT[2:0];			// Minutes tens
		6'b101100:	TIME_SET[10:7]  <= DATA_OUT[3:0];			// Minutes ones
		6'b101101:	TIME_SET[6:4]   <= DATA_OUT[2:0];			// Seconds tens
		6'b101110:	TIME_SET[3:0]   <= DATA_OUT[3:0];			// Seconds ones
		endcase
end

always @ (posedge VGA_CLK)
begin
	case(TIME)
	15'H7A59:	TIME <= 15'H0000;
	default:	TIME <= TIME + 1;
	endcase
end

always @ (posedge TIME[0])
	DEB_COUNTER <= DEB_COUNTER + 1;

always @ (negedge TIME[14] or posedge TIME_SET[42])
begin
	if(TIME_SET[42])
	begin
		SECONDS_ONES <= TIME_SET[3:0];
		SECONDS_TENS <= TIME_SET[6:4];
	end
	else
	begin
		case(SECONDS_ONES)
		4'D9:	SECONDS_ONES <= 4'D0;
		default:	SECONDS_ONES <= SECONDS_ONES + 1;
		endcase

		case(SECONDS_TENS)
		3'D5:
			if(SECONDS_ONES == 4'H9)
				SECONDS_TENS <= 3'D0;
		default:
			if(SECONDS_ONES == 4'H9)
				SECONDS_TENS <= SECONDS_TENS + 1;
		endcase
	end
end

always @ (negedge SECONDS_TENS[2] or posedge TIME_SET[42])
begin
	if(TIME_SET[42])
	begin
		MINUTES_ONES <= TIME_SET[10:7];
		MINUTES_TENS <= TIME_SET[13:11];
	end
	else
	begin
		case(MINUTES_ONES)
		4'D9:	MINUTES_ONES <= 4'D0;
		default:	MINUTES_ONES <= MINUTES_ONES + 1;
		endcase

		case(MINUTES_TENS)
		3'D5:
			if(MINUTES_ONES == 4'H9)
				MINUTES_TENS <= 3'D0;
		default:
			if(MINUTES_ONES == 4'H9)
				MINUTES_TENS <= MINUTES_TENS + 1;
		endcase
	end
end

always @ (negedge MINUTES_TENS[2] or posedge TIME_SET[42])
begin
	if(TIME_SET[42])
	begin
		HOURS_ONES <= TIME_SET[17:14];
		HOURS_TENS <= TIME_SET[19:18];
	end
	else
	begin
		case(HOURS_ONES)
		4'D9:	HOURS_ONES <= 4'D0;
		4'D3:
			if(HOURS_TENS == 2'D2)
				HOURS_ONES <= 4'D0;
			else
				HOURS_ONES <= 4'D4;
		default:	HOURS_ONES <= HOURS_ONES + 1;
		endcase

		case(HOURS_TENS)
		2'D2:
			if(HOURS_ONES == 4'H3)
				HOURS_TENS <= 2'D0;
		default:
			if(HOURS_ONES == 4'H9)
				HOURS_TENS <= HOURS_TENS + 1;
		endcase
	end
end

always @ (negedge HOURS_TENS[1] or posedge TIME_SET[42])
begin
	if(TIME_SET[42])
	begin
		YEARS_TENS <= TIME_SET[41:38];
		YEARS_ONES <= TIME_SET[37:34];
		MONTHS_TENS <= TIME_SET[33];
		MONTHS_ONES <= TIME_SET[32:29];
		DAY_WEEK <= TIME_SET[28:26];
		DAYS_TENS <= TIME_SET[25:24];
		DAYS_ONES <= TIME_SET[23:20];
	end
	else
	begin
		if(DAY_WEEK == 3'h6)
			DAY_WEEK <= 3'h0;
		else
			DAY_WEEK <= DAY_WEEK + 1;

		case(DAYS_ONES)
		4'D9:	DAYS_ONES <= 4'D0;
		4'D1:
			if(DAYS_TENS == 2'D3)
				DAYS_ONES <= 4'D1;
			else
				DAYS_ONES <= 4'D2;
		default:	DAYS_ONES <= DAYS_ONES + 1;
		endcase

		case(DAYS_TENS)
		2'D3:
			if(DAYS_ONES == 4'D1)
				DAYS_TENS <= 2'D0;
		default:
			if(DAYS_ONES == 4'D9)
				DAYS_TENS <= DAYS_TENS + 1;
		endcase
	end
end

/*****************************************************************************
* Convert PS/2 keyboard to ASCII keyboard
******************************************************************************/

assign CLR_STB =	(RESET_N == 1'b0)							?	1'b1:
						({APPLE_C0, ADDRESS[6:0]} == 8'h90)	?	1'b1:
																			1'b0;

always @(posedge KB_CLK[3] or posedge CLR_STB)
begin
	if(CLR_STB)
		APPLE_PRESSED <= 1'b0;
	else
	if(LAST_KEY != {KEY[63:45],KEY[43:8],KEY[5:4]})
	begin
		LAST_KEY <= {KEY[63:45],KEY[43:8],KEY[5:4]};
		APPLE_PRESSED <= APPLE_PRESSED | PRESS;
	end
end
	
assign A_KEY_PRESSED = (KEY[63:1] == 63'h0000000000000000) ?	1'b0:
																					1'b1;

always @(posedge KB_CLK[3] or negedge RESET_N)
begin
	if(~RESET_N)
	begin
		KEY <= 64'h1;
		CAPS_CLK <= 1'b0;
		ASCII <= 7'h20;
	end
	else
	begin
		KEY[0] <= CAPS;
		case(SCAN)
		8'h16:
		begin
			KEY[63] <= PRESS;	// 1 !
			if(PRESS && (KEY[63]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h21;
				else
					ASCII <= 7'h31;
			end
		end
		8'h1E:
		begin
			KEY[62] <= PRESS;	// 2 @
			if(PRESS && (KEY[62]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h40;
				else
					ASCII <= 7'h32;
			end
		end
		8'h26:
		begin
			KEY[61] <= PRESS;	// 3 #
			if(PRESS && (KEY[61]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h23;
				else
					ASCII <= 7'h33;
			end
		end
		8'h25:
		begin
			KEY[60] <= PRESS;	// 4 $
			if(PRESS && (KEY[60]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h24;
				else
					ASCII <= 7'h34;
			end
		end
		8'h2E:
		begin
			KEY[59] <= PRESS;	// 5 %
			if(PRESS && (KEY[59]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h25;
				else
					ASCII <= 7'h35;
			end
		end
		8'h36:
		begin
			KEY[58] <= PRESS;	// 6 ^
			if(PRESS && (KEY[58]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h5E;
				else
					ASCII <= 7'h36;
			end
		end
		8'h3D:
		begin
			KEY[57] <= PRESS;	// 7 &
			if(PRESS && (KEY[57]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h26;
				else
					ASCII <= 7'h37;
			end
		end
		8'h0D:
		begin
			KEY[56] <= PRESS;	// TAB
			if(PRESS && (KEY[56]!=PRESS))
					ASCII <= 7'h09;
		end
		8'h3E:
		begin
			KEY[55] <= PRESS;	// 8 *
			if(PRESS && (KEY[55]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h2A;
				else
					ASCII <= 7'h38;
			end
		end
		8'h46:
		begin
			KEY[54] <= PRESS;	// 9 (
			if(PRESS && (KEY[54]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h28;
				else
					ASCII <= 7'h39;
			end
		end
		8'h45:
		begin
			KEY[53] <= PRESS;	// 0 )
			if(PRESS && (KEY[53]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h29;
				else
					ASCII <= 7'h30;
			end
		end
		8'h4E:
		begin
			KEY[52] <= PRESS;	// - _
			if(PRESS && (KEY[52]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h5F;
				else
					ASCII <= 7'h2D;
			end
		end
		8'h55:
		begin
			KEY[51] <= PRESS;	// = +
			if(PRESS && (KEY[51]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h2B;
				else
					ASCII <= 7'h3D;
			end
		end
		8'h66:
		begin
			KEY[50] <= PRESS;	// backspace
			if(PRESS && (KEY[50]!=PRESS))
			begin
				ASCII <= 7'h08;
			end
		end
		8'h0E:
		begin
			KEY[49] <= PRESS;	// ` ~
			if(PRESS && (KEY[49]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h7E;
				else
					ASCII <= 7'h60;
			end
		end
		8'h5D:
		begin
			KEY[48] <= PRESS;	// \ |
			if(PRESS && (KEY[48]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h7C;
				else
					ASCII <= 7'h5C;
			end
		end
		8'h49:
		begin
			KEY[47] <= PRESS;	// . >
			if(PRESS && (KEY[47]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h3E;
				else
					ASCII <= 7'h2E;
			end
		end
		8'h4b:
		begin
			KEY[46] <= PRESS;	// L
			if(PRESS && (KEY[46]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h0C;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h4C;
					else
						ASCII <= 7'h6C;
				end
			end
		end
		8'h44:
		begin
			KEY[45] <= PRESS;	// O
			if(PRESS && (KEY[45]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h0F;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h4F;
					else
						ASCII <= 7'h6F;
				end
			end
		end
//		8'h11			KEY[44] <= PRESS; // line feed (really right ALT (Extended) see below
		8'h5A:
		begin
			KEY[43] <= PRESS;	// CR
			if(PRESS && (KEY[43]!=PRESS))
			begin
				ASCII <= 7'h0D;
			end
		end
		8'h54:
		begin
			KEY[42] <= PRESS;	// [ {
			if(PRESS && (KEY[42]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h7B;
				else
					ASCII <= 7'h5B;
			end
		end
		8'h5B:
		begin
			KEY[41] <= PRESS;	// ] }
			if(PRESS && (KEY[41]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h7D;
				else
					ASCII <= 7'h5D;
			end
		end
		8'h52:
		begin
			KEY[40] <= PRESS;	// ' "
			if(PRESS && (KEY[40]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h22;
				else
					ASCII <= 7'h27;
			end
		end
		8'h1D:
		begin
			KEY[39] <= PRESS;	// W
			if(PRESS && (KEY[39]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h17;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h57;
					else
						ASCII <= 7'h77;
				end
			end
		end
		8'h24:
		begin
			KEY[38] <= PRESS;	// E
			if(PRESS && (KEY[38]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h05;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h45;
					else
						ASCII <= 7'h65;
				end
			end
		end
		8'h2D:
		begin
			KEY[37] <= PRESS;	// R
			if(PRESS && (KEY[37]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h12;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h52;
					else
						ASCII <= 7'h72;
				end
			end
		end
		8'h2C:
		begin
			KEY[36] <= PRESS;	// T
			if(PRESS && (KEY[36]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h14;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h54;
					else
						ASCII <= 7'h74;
				end
			end
		end
		8'h35:
		begin
			KEY[35] <= PRESS;	// Y
			if(PRESS && (KEY[35]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h19;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h59;
					else
						ASCII <= 7'h79;
				end
			end
		end
		8'h3C:
		begin
			KEY[34] <= PRESS;	// U
			if(PRESS && (KEY[34]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h15;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h55;
					else
						ASCII <= 7'h75;
				end
			end
		end
		8'h43:
		begin
			KEY[33] <= PRESS;	// I
			if(PRESS && (KEY[33]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h09;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h49;
					else
						ASCII <= 7'h69;
				end
			end
		end
		8'h75:
		begin
			KEY[32] <= PRESS;	// up
			ASCII <= 7'h0B;
		end
		8'h1B:
		begin
			KEY[31] <= PRESS;	// S
			if(PRESS && (KEY[31]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h13;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h53;
					else
						ASCII <= 7'h73;
				end
			end
		end
		8'h23:
		begin
			KEY[30] <= PRESS;	// D
			if(PRESS && (KEY[30]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h04;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h44;
					else
						ASCII <= 7'h64;
				end
			end
		end
		8'h2B:
		begin
			KEY[29] <= PRESS;	// F
			if(PRESS && (KEY[29]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h06;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h46;
					else
						ASCII <= 7'h66;
				end
			end
		end
		8'h34:
		begin
			KEY[28] <= PRESS;	// G
			if(PRESS && (KEY[28]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h07;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h47;
					else
						ASCII <= 7'h67;
				end
			end
		end
		8'h33:
		begin
			KEY[27] <= PRESS;	// H
			if(PRESS && (KEY[27]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h08;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h48;
					else
						ASCII <= 7'h68;
				end
			end
		end
		8'h3B:
		begin
			KEY[26] <= PRESS;	// J
			if(PRESS && (KEY[26]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h0A;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h4A;
					else
						ASCII <= 7'h6A;
				end
			end
		end
		8'h42:
		begin
			KEY[25] <= PRESS;	// K
			if(PRESS && (KEY[25]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h0B;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h4B;
					else
						ASCII <= 7'h6B;
				end
			end
		end
		8'h74:
		begin
			KEY[24] <= PRESS;	// right
			ASCII <= 7'h15;
		end
		8'h22:
		begin
			KEY[23] <= PRESS;	// X
			if(PRESS && (KEY[23]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h18;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h58;
					else
						ASCII <= 7'h78;
				end
			end
		end
		8'h21:
		begin
			KEY[22] <= PRESS;	// C
			if(PRESS && (KEY[22]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h03;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h43;
					else
						ASCII <= 7'h63;
				end
			end
		end
		8'h2a:
		begin
			KEY[21] <= PRESS;	// V
			if(PRESS && (KEY[21]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h16;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h56;
					else
						ASCII <= 7'h76;
				end
			end
		end
		8'h32:
		begin
			KEY[20] <= PRESS;	// B
			if(PRESS && (KEY[20]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h02;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h42;
					else
						ASCII <= 7'h62;
				end
			end
		end
		8'h31:
		begin
			KEY[19] <= PRESS;	// N
			if(PRESS && (KEY[19]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h0E;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h4E;
					else
						ASCII <= 7'h6E;
				end
			end
		end
		8'h3a:
		begin
			KEY[18] <= PRESS;	// M
			if(PRESS && (KEY[18]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h0D;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h4D;
					else
						ASCII <= 7'h6D;
				end
			end
		end
		8'h41:
		begin
			KEY[17] <= PRESS;	// , <
			if(PRESS && (KEY[17]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h3C;
				else
					ASCII <= 7'h2C;
			end
		end
		8'h6B:
		begin
			KEY[16] <= PRESS;	// left
			ASCII <= 7'h08;
		end
		8'h15:
		begin
			KEY[15] <= PRESS;	// Q
			if(PRESS && (KEY[15]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h11;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h51;
					else
						ASCII <= 7'h71;
				end
			end
		end
		8'h1C:
		begin
			KEY[14] <= PRESS;	// A
			if(PRESS && (KEY[14]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h01;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h41;
					else
						ASCII <= 7'h61;
				end
			end
		end
		8'h1A:
		begin
			KEY[13] <= PRESS;	// Z
			if(PRESS && (KEY[13]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h1A;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h5A;
					else
						ASCII <= 7'h7A;
				end
			end
		end
		8'h29:
		begin
			KEY[12] <= PRESS;	// Space
			ASCII <= 7'h20;
		end
		8'h4A:
		begin
			KEY[11] <= PRESS;	// / ?
			if(PRESS && (KEY[11]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h3F;
				else
					ASCII <= 7'h2F;
			end
		end
		8'h4C:
		begin
			KEY[10] <= PRESS;	// ; :
			if(PRESS && (KEY[10]!=PRESS))
			begin
				if(KEY[1] || KEY[2])
					ASCII <= 7'h3A;
				else
					ASCII <= 7'h3B;
			end
		end
		8'h4D:
		begin
			KEY[9] <= PRESS;	// P
			if(PRESS && (KEY[9]!=PRESS))
			begin
				if(KEY[6])
					ASCII <= 7'h10;
				else
				begin
					if(CAPS || KEY[1] || KEY[2])
						ASCII <= 7'h50;
					else
						ASCII <= 7'h70;
				end
			end
		end
		8'h72:
		begin
			KEY[8] <= PRESS;	// down
			ASCII <= 7'h0A;
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
			if(PRESS && (KEY[5]!=PRESS))
			begin
				ASCII <= 7'h1B;
			end
		end
//		8'h2C:		KEY[4] <= PRESS;	// na
//		8'h35:		KEY[3] <= PRESS;	// na
		8'h12:		KEY[2] <= PRESS;	// L-Shift
		8'h59:		KEY[1] <= PRESS;	// R-Shift
		8'h58:		CAPS_CLK <= PRESS;	// Caps
		endcase
	end
end

always @(posedge CAPS_CLK or negedge RESET_N)
begin
	if(~RESET_N)
		CAPS <= 1'b1;
	else
		CAPS <= ~CAPS;
end

always @ (posedge VGA_CLK)				//25 MHz
	KB_CLK <= KB_CLK + 1'b1;			// 25/16 = 1.5625 MHz

ps2_keyboard KEYBOARD(
		.RESET_N(RESET_N),
		.CLK(KB_CLK[3]),
		.PS2_CLK(ps2_clk),
		.PS2_DATA(ps2_data),
		.RX_SCAN(SCAN),
		.RX_PRESSED(PRESS),
		.RX_EXTENDED(EXTENDED)
);

/*****************************************************************************
* Serial Ports
******************************************************************************/
glb6850 COM1(
.RESET_N(RESET_N),
.RX_CLK(COM1_CLK),
.TX_CLK(COM1_CLK),
.E(PH_2),
.DI(DATA_OUT),
.DO(DATA_COM1),
.CS(SLOT_7IO),
.RW_N(RW_N),
.RS(ADDRESS[0]),
.TXDATA(TXD1),
.RXDATA(RXD1),
.RTS(RTS1),
.CTS(RTS1),
.DCD(RTS1)
);

/*****************************************************************************
* Floppy
******************************************************************************/
// 6312 bytes per track
// New byte every 32 CPU clock cycles 
// or 8 bits * 4 clock cycles
always @(negedge PH_2 or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		FLOPPY_CLK <= 5'b00000;
		LAST_WRITE_DATA <= 8'b00;
	end
	else
	begin
		if(FLOPPY_WRITE)
		begin
			FLOPPY_CLK <= FLOPPY_CLK + 1'b1;
			LAST_WRITE_DATA <= FLOPPY_WRITE_DATA;
		end
		else
		begin
			if(!(Q7 && (FLOPPY_CLK == 5'b00000) && (LAST_WRITE_DATA == 8'hFF)))
				FLOPPY_CLK <= FLOPPY_CLK + 1'b1;
		end
	end
end

always @(negedge PH_2 or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		PHASE0 <= 1'b0;
		PHASE1 <= 1'b0;
		PHASE2 <= 1'b0;
		PHASE3 <= 1'b0;
		MOTOR <= 1'b0;
		DRIVE1<= 1'b1;
		FLOPPY_WRITE_DATA <= 8'h00;
	end
	else
	begin
		case ({SLOT_6IO, ADDRESS[3:0]})
		5'h10:	PHASE0 <= 1'b0;
		5'h11:	PHASE0 <= 1'b1;
		5'h12:	PHASE1 <= 1'b0;
		5'h13:	PHASE1 <= 1'b1;
		5'h14:	PHASE2 <= 1'b0;
		5'h15:	PHASE2 <= 1'b1;
		5'h16:	PHASE3 <= 1'b0;
		5'h17:	PHASE3 <= 1'b1;
		5'h18:	MOTOR <= 1'b0;
		5'h19:	MOTOR <= 1'b1;
		5'h1A:	DRIVE1 <= 1'b1;
		5'h1B:	DRIVE1 <= 1'b0;
		5'h1C:	Q6 <= 1'b0;
		5'h1D:
		begin
				FLOPPY_WRITE_DATA <= DATA_OUT[7:0];
				Q6 <= 1'b1;
		end
		5'h1E:	Q7 <= 1'b0;
		5'h1F:
		begin
				FLOPPY_WRITE_DATA <= DATA_OUT[7:0];
				Q7 <= 1'b1;
		end

		endcase
	end
end

assign DRIVE1_X =  DRIVE1 & MOTOR;
assign DRIVE2_X = !DRIVE1 & MOTOR;

assign DRIVE1_EN = (SWITCH[4] ^  DRIVE1) & MOTOR;
assign DRIVE2_EN = (SWITCH[4] ^ !DRIVE1) & MOTOR;
assign FLOPPY_READ		= ({Q7, SLOT_6IO, ADDRESS[3:0]} == 6'h1C)	?	1'b1:
																							1'b0;
assign FLOPPY_WRITE		= ({Q7, SLOT_6IO, ADDRESS[3:0]} == 6'h3C)	?	1'b1:
																							1'b0;
assign FLOPPY_WP_READ	= ({Q6, SLOT_6IO, ADDRESS[3:0]} == 6'h3E)	?	1'b1:
																							1'b0;

assign FLOPPY_VALID 		=	(!FLOPPY_CLK[4] & !FLOPPY_CLK[3]);

assign FLOPPY_RD_DATA	=	DRIVE1_EN	?	{FLOPPY_VALID, RAM_DATA1_I[6:0]}:
									DRIVE2_EN	?	{FLOPPY_VALID, RAM_DATA1_I[14:8]}:
														8'H00;

assign FLOPPY_DATA		=	(FLOPPY_READ)									?	FLOPPY_RD_DATA:
									({DRIVE1_EN, FLOPPY_WP_READ} == 2'b11)	?	{SWITCH[2], 7'h00}:
									({DRIVE2_EN, FLOPPY_WP_READ} == 2'b11)	?	{SWITCH[3], 7'h00}:
									(FLOPPY_WRITE)									?	FLOPPY_WRITE_DATA:
																							8'h00;

always @(posedge FLOPPY_CLK[4])
begin
	case(FLOPPY_BYTE)
	13'h18A7:
		FLOPPY_BYTE <= 13'h0000;
	default:
		FLOPPY_BYTE <= FLOPPY_BYTE + 1'b1;
	endcase
end

assign TRACK		=	(DRIVE1_EN)		?	TRACK1:
							(DRIVE2_EN)		?	TRACK2:
													TRACK;

assign TRACK1_UP = TRACK1 + 12'h62A;
assign TRACK1_DOWN = TRACK1 - 12'h62A;
assign TRACK2_UP = TRACK2 + 12'h62A;
assign TRACK2_DOWN = TRACK2 - 12'h62A;

assign FLOPPY_ADDRESS = {TRACK, 1'b0} + {5'b00000, FLOPPY_BYTE};

always @ (posedge PH_2)
begin
	PHASE0_1 <= PHASE0;
	PHASE0_2 <= PHASE0_1;					// Delay 2 clock cycles
	PHASE1_1 <= PHASE1;
	PHASE1_2 <= PHASE1_1;					// Delay 2 clock cycles
	PHASE2_1 <= PHASE2;
	PHASE2_2 <= PHASE2_1;					// Delay 2 clock cycles
	PHASE3_1 <= PHASE3;
	PHASE3_2 <= PHASE3_1;					// Delay 2 clock cycles
end

always @(negedge PH_2 or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		STEPPER1 <= 2'b00;
		STEPPER2 <= 2'b00;
		TRACK1 <= 17'd00000;
		TRACK2 <= 17'd00000;
	end
	else
	begin
		if(DRIVE1^SWITCH[4])
		begin
			case ({PHASE0_2, PHASE1_2, PHASE2_2, PHASE3_2})
			4'b1000:
			begin
				if(STEPPER1 == 2'b11)
				begin
					if(TRACK1 != 17'h1E0CC)
					begin
						TRACK1 <= TRACK1_UP;
						STEPPER1 <= 2'b00;
					end
				end
				else
				if(STEPPER1 == 2'b01)
				begin
					if(TRACK1 != 17'h0)
					begin
						TRACK1 <= TRACK1_DOWN;
						STEPPER1 <= 2'b00;
					end
				end
			end
			4'b0100:
			begin
				if(STEPPER1 == 2'b00)
				begin
					if(TRACK1 != 17'h1E0CC)
					begin
						TRACK1 <= TRACK1_UP;
						STEPPER1 <= 2'b01;
					end
				end
				else
				if(STEPPER1 == 2'b10)
				begin
					if(TRACK1 != 17'h0)
					begin
						TRACK1 <= TRACK1_DOWN;
						STEPPER1 <= 2'b01;
					end
				end
			end
			4'b0010:
			begin
				if(STEPPER1 == 2'b01)
				begin
					if(TRACK1 != 17'h1E0CC)
					begin
						TRACK1 <= TRACK1_UP;
						STEPPER1 <= 2'b10;
					end
				end
				else
				if(STEPPER1 == 2'b11)
				begin
					if(TRACK1 != 17'h0)
					begin
						TRACK1 <= TRACK1_DOWN;
						STEPPER1 <= 2'b10;
					end
				end
			end
			4'b0001:
			begin
				if(STEPPER1 == 2'b10)
				begin
					if(TRACK1 != 17'h1E0CC)
					begin
						TRACK1 <= TRACK1_UP;
						STEPPER1 <= 2'b11;
					end
				end
				else
				if(STEPPER1 == 2'b00)
				begin
					if(TRACK1 != 17'h0)
					begin
						TRACK1 <= TRACK1_DOWN;
						STEPPER1 <= 2'b11;
					end
				end
			end
			endcase
		end
		else
		begin
			case ({PHASE0_2, PHASE1_2, PHASE2_2, PHASE3_2})
			4'b1000:
			begin
				if(STEPPER2 == 2'b11)
				begin
					if(TRACK2 != 17'h1E0CC)
					begin
						TRACK2 <= TRACK2_UP;
						STEPPER2 <= 2'b00;
					end
				end
				else
				if(STEPPER2 == 2'b01)
				begin
					if(TRACK2 != 17'h0)
					begin
						TRACK2 <= TRACK2_DOWN;
						STEPPER2 <= 2'b00;
					end
				end
			end
			4'b0100:
			begin
				if(STEPPER2 == 2'b00)
				begin
					if(TRACK2 != 17'h1E0CC)
					begin
						TRACK2 <= TRACK2_UP;
						STEPPER2 <= 2'b01;
					end
				end
				else
				if(STEPPER2 == 2'b10)
				begin
					if(TRACK2 != 17'h0)
					begin
						TRACK2 <= TRACK2_DOWN;
						STEPPER2 <= 2'b01;
					end
				end
			end
			4'b0010:
			begin
				if(STEPPER2 == 2'b01)
				begin
					if(TRACK2 != 17'h1E0CC)
					begin
						TRACK2 <= TRACK2_UP;
						STEPPER2 <= 2'b10;
					end
				end
				else
				if(STEPPER2 == 2'b11)
				begin
					if(TRACK2 != 17'h0)
					begin
						TRACK2 <= TRACK2_DOWN;
						STEPPER2 <= 2'b10;
					end
				end
			end
			4'b0001:
			begin
				if(STEPPER2 == 2'b10)
				begin
					if(TRACK2 != 17'h1E0CC)
					begin
						TRACK2 <= TRACK2_UP;
						STEPPER2 <= 2'b11;
					end
				end
				else
				if(STEPPER2 == 2'b00)
				begin
					if(TRACK2 != 17'h0)
					begin
						TRACK2 <= TRACK2_DOWN;
						STEPPER2 <= 2'b11;
					end
				end
			end
			endcase
		end
	end
end

/*****************************************************************************
* Video
******************************************************************************/

assign CLOCK_MUX =	(APPLE_ADDRESS[5:0] == 6'd7) ?	{6'b101100, HOURS_TENS}:
							(APPLE_ADDRESS[5:0] == 6'd8) ?	{4'b1011, HOURS_ONES}:
							(APPLE_ADDRESS[5:0] == 6'd9) ?	 8'hBA:
							(APPLE_ADDRESS[5:0] == 6'd10) ?	{5'b10110, MINUTES_TENS}:
							(APPLE_ADDRESS[5:0] == 6'd11) ?	{4'b1011, MINUTES_ONES}:
							(APPLE_ADDRESS[5:0] == 6'd12) ?	 8'hBA:
							(APPLE_ADDRESS[5:0] == 6'd13) ?	{5'b10110, SECONDS_TENS}:
							(APPLE_ADDRESS[5:0] == 6'd14) ?	{4'b1011, SECONDS_ONES}:
																		 8'hA0;

APPLE_VIDEO A_VIDEO(
		.CLK(VGA_CLK),
		.APPLE_VID(1'b1),
		.ADDRESS(APPLE_ADDRESS),
		.DATA(RAM_DATA0_I),
		.CHAR_ADD(VROM_ADDRESS),
		.CHAR_DATA(VRAM_DATA0),
		.CLK_MOD(CLK_MOD),
		.RED(RED),
		.GREEN(GREEN),
		.BLUE(BLUE),
		.HSYNC(H_SYNC),
		.VSYNC(V_SYNC),
		.CLOCK_MUX(CLOCK_MUX),
		.TEXT(TEXT),
		.MIXED(MIXED),
		.TEXT_80(TEXT_80),
		.SECONDARY((SECONDARY & ~STORE_80)),
		.HI_RES(HGR),
		.ALT_CHAR(ALT_CHAR),
		.DHRES(DHRES),
		.TEXT_COLOR(USER_C),
		.V_BLANKING(V_BLANKING),
		.CLK_1HZ(TIME[14]));

endmodule
