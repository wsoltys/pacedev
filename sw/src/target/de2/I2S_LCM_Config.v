module I2S_LCM_Config (	//	Host Side
						iCLK,
						iRST_N,
						//	I2C Side
						I2S_SCLK,
						I2S_SDAT,
						I2S_SCEN	);
//	Host Side
input			iCLK;
input			iRST_N;
//	I2C Side
output		I2S_SCLK;
inout		I2S_SDAT;
output		I2S_SCEN;
//	Internal Registers/Wires
reg			mI2S_STR;
wire		mI2S_RDY;
wire		mI2S_ACK;
wire		mI2S_CLK;
reg	[15:0]	mI2S_DATA;
reg	[15:0]	LUT_DATA;
reg	[5:0]	LUT_INDEX;
reg	[3:0]	mSetup_ST;

//	LUT Data Number
parameter	LUT_SIZE	=	8;

I2S_Controller	u0	(	//	Host Side
						.iCLK(iCLK),
						.iRST(iRST_N),
						.iDATA(mI2S_DATA),
						.iSTR(mI2S_STR),
						.oACK(mI2S_ACK),
						.oRDY(mI2S_RDY),
						.oCLK(mI2S_CLK),
						//	Serial Side
						.I2S_EN(I2S_SCEN),
						.I2S_DATA(I2S_SDAT),
						.I2S_CLK(I2S_SCLK)	);

//////////////////////	Config Control	////////////////////////////
always@(posedge mI2S_CLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mSetup_ST	<=	0;
		mI2S_STR	<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mSetup_ST)
			0:	begin
					mI2S_DATA	<=	LUT_DATA;
					mI2S_STR	<=	1;
					mSetup_ST	<=	1;
				end
			1:	begin
					if(mI2S_RDY)
					begin
						if(mI2S_ACK)
						mSetup_ST	<=	2;
						else
						mSetup_ST	<=	0;							
						mI2S_STR	<=	0;
					end
				end
			2:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mSetup_ST	<=	0;
				end
			endcase
		end
	end
end
////////////////////////////////////////////////////////////////////
/////////////////////	Config Data LUT	  //////////////////////////	
always
begin
	case(LUT_INDEX)
	0		:	LUT_DATA	<=	{6'h02,2'b0,8'h02};
	1		:	LUT_DATA	<=	{6'h03,2'b0,8'h01};
	2		:	LUT_DATA	<=	{6'h04,2'b0,8'h3F};
	3		:	LUT_DATA	<=	{6'h09,2'b0,8'h20};
	4		:	LUT_DATA	<=	{6'h10,2'b0,8'h3F};
	5		:	LUT_DATA	<=	{6'h11,2'b0,8'h3F};
	6		:	LUT_DATA	<=	{6'h12,2'b0,8'h2F};
	7		:	LUT_DATA	<=	{6'h13,2'b0,8'h2F};
	default	:	LUT_DATA	<=	16'h0000;
	endcase
end
////////////////////////////////////////////////////////////////////
endmodule