// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	3-Wire Serial Bus Controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Chen       :| 06/03/23  :|      Initial Revision
// --------------------------------------------------------------------

module I2S_Controller(	//	Host Side
						iCLK,
						iRST,
						iDATA,
						iSTR,
						oACK,
						oRDY,
						oCLK,
						//	Serial Side
						I2S_EN,
						I2S_DATA,
						I2S_CLK	);
//	Host Side
input			iCLK;
input			iRST;
input			iSTR;
input	[15:0]	iDATA;
output			oACK;
output			oRDY;
output			oCLK;
//	Serial Side
output			I2S_EN;
inout			I2S_DATA;
output			I2S_CLK;
//	Internal Register and Wire
reg				mI2S_CLK;
reg		[15:0]	mI2S_CLK_DIV;
reg				mSEN;
reg				mSDATA;
reg				mSCLK;
reg				mACK;
reg		[4:0]	mST;

parameter	CLK_Freq	=	50000000;	//	50	MHz
parameter	I2S_Freq	=	20000;		//	20	KHz

//	Serial Clock Generator
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mI2S_CLK	<=	0;
		mI2S_CLK_DIV	<=	0;
	end
	else
	begin
		if( mI2S_CLK_DIV	< (CLK_Freq/I2S_Freq) )
		mI2S_CLK_DIV	<=	mI2S_CLK_DIV+1;
		else
		begin
			mI2S_CLK_DIV	<=	0;
			mI2S_CLK		<=	~mI2S_CLK;
		end
	end
end
//	Parallel to Serial
always@(negedge mI2S_CLK or negedge iRST)
begin
	if(!iRST)
	begin
		mSEN	<=	1'b1;
		mSCLK	<=	1'b0;
		mSDATA	<=	1'bz;
		mACK	<=	1'b0;
		mST		<=	4'h00;
	end
	else
	begin
		if(iSTR)
		begin
			if(mST<17)
			mST	<=	mST+1'b1;
			if(mST==0)
			begin
				mSEN	<=	1'b0;
				mSCLK	<=	1'b1;
			end
			else if(mST==8)
			mACK	<=	I2S_DATA;
			else if(mST==16 && mSCLK)
			begin
				mSEN	<=	1'b1;
				mSCLK	<=	1'b0;	
			end
			if(mST<16)
			mSDATA	<=	iDATA[15-mST];
		end
		else
		begin
			mSEN	<=	1'b1;
			mSCLK	<=	1'b0;
			mSDATA	<=	1'bz;
			mACK	<=	1'b0;
			mST		<=	4'h00;
		end
	end
end

assign	oACK		=	mACK;
assign	oRDY		=	(mST==17)	?	1'b1	:	1'b0;
assign	I2S_EN		=	mSEN;
assign	I2S_CLK		=	mSCLK	&	mI2S_CLK;
assign	I2S_DATA	=	(mST==8)	?	1'bz	:
						(mST==17)	?	1'bz	:
										mSDATA	;
assign	oCLK		=	mI2S_CLK;

endmodule