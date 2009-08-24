module	LCD_TEST (	//	Host Side
					iCLK,iRST_N,iLINE1,iLINE2,
					//	LCD Side
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS);
//	Host Side
input			iCLK,iRST_N;
input [127:0] iLINE1;
input [127:0] iLINE2;
//	LCD Side
output	[7:0]	LCD_DATA;
output			LCD_RW,LCD_EN,LCD_RS;
//	Internal Wires/Registers
reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg			mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
wire		mLCD_Done;

parameter	LCD_INTIAL	=	0;
parameter	LCD_LINE1	=	5;
parameter	LCD_CH_LINE	=	LCD_LINE1+16;
parameter	LCD_LINE2	=	LCD_LINE1+16+1;
parameter	LUT_SIZE	=	LCD_LINE1+32+1;

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		mLCD_Start	<=	0;
		mLCD_DATA	<=	0;
		mLCD_RS		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mLCD_ST)
			0:	begin
					mLCD_DATA	<=	LUT_DATA[7:0];
					mLCD_RS		<=	LUT_DATA[8];
					mLCD_Start	<=	1;
					mLCD_ST		<=	1;
				end
			1:	begin
					if(mLCD_Done)
					begin
						mLCD_Start	<=	0;
						mLCD_ST		<=	2;					
					end
				end
			2:	begin
					if(mDLY<18'h3FFFE)
					mDLY	<=	mDLY+1;
					else
					begin
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
			3:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mLCD_ST	<=	0;
				end
			endcase
		end
	end
end

always
begin
	case(LUT_INDEX)
	//	Initial
	LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
	LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
	LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
	LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
	LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
	//	Line 1
	LCD_LINE1+0: 	LUT_DATA	<=	{1'b1, iLINE1[7:0]};
	LCD_LINE1+1: 	LUT_DATA	<=	{1'b1, iLINE1[15:8]};
	LCD_LINE1+2: 	LUT_DATA	<=	{1'b1, iLINE1[23:16]};
	LCD_LINE1+3: 	LUT_DATA	<=	{1'b1, iLINE1[31:24]};
	LCD_LINE1+4: 	LUT_DATA	<=	{1'b1, iLINE1[39:32]};
	LCD_LINE1+5: 	LUT_DATA	<=	{1'b1, iLINE1[47:40]};
	LCD_LINE1+6:	LUT_DATA	<=	{1'b1, iLINE1[55:48]};
	LCD_LINE1+7:	LUT_DATA	<=	{1'b1, iLINE1[63:56]};
	LCD_LINE1+8:	LUT_DATA	<=	{1'b1, iLINE1[71:64]};
	LCD_LINE1+9:	LUT_DATA	<=	{1'b1, iLINE1[79:72]};
	LCD_LINE1+10: LUT_DATA	<=	{1'b1, iLINE1[87:80]};
	LCD_LINE1+11: LUT_DATA	<=	{1'b1, iLINE1[95:88]};
	LCD_LINE1+12: LUT_DATA	<=	{1'b1, iLINE1[103:96]};
	LCD_LINE1+13: LUT_DATA	<=	{1'b1, iLINE1[111:104]};
	LCD_LINE1+14: LUT_DATA	<=	{1'b1, iLINE1[119:112]};
	LCD_LINE1+15: LUT_DATA	<=	{1'b1, iLINE1[127:120]};
	//	Change Line
	LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
	//	Line 2
	LCD_LINE2+0: 	LUT_DATA	<=	{1'b1, iLINE2[7:0]};
	LCD_LINE2+1: 	LUT_DATA	<=	{1'b1, iLINE2[15:8]};
	LCD_LINE2+2: 	LUT_DATA	<=	{1'b1, iLINE2[23:16]};
	LCD_LINE2+3: 	LUT_DATA	<=	{1'b1, iLINE2[31:24]};
	LCD_LINE2+4: 	LUT_DATA	<=	{1'b1, iLINE2[39:32]};
	LCD_LINE2+5: 	LUT_DATA	<=	{1'b1, iLINE2[47:40]};
	LCD_LINE2+6:	LUT_DATA	<=	{1'b1, iLINE2[55:48]};
	LCD_LINE2+7:	LUT_DATA	<=	{1'b1, iLINE2[63:56]};
	LCD_LINE2+8:	LUT_DATA	<=	{1'b1, iLINE2[71:64]};
	LCD_LINE2+9:	LUT_DATA	<=	{1'b1, iLINE2[79:72]};
	LCD_LINE2+10: LUT_DATA	<=	{1'b1, iLINE2[87:80]};
	LCD_LINE2+11: LUT_DATA	<=	{1'b1, iLINE2[95:88]};
	LCD_LINE2+12: LUT_DATA	<=	{1'b1, iLINE2[103:96]};
	LCD_LINE2+13: LUT_DATA	<=	{1'b1, iLINE2[111:104]};
	LCD_LINE2+14: LUT_DATA	<=	{1'b1, iLINE2[119:112]};
	LCD_LINE2+15: LUT_DATA	<=	{1'b1, iLINE2[127:120]};
	default:		LUT_DATA	<=	9'h000;
	endcase
end

LCD_Controller 		u0	(	//	Host Side
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(iCLK),
							.iRST_N(iRST_N),
							//	LCD Interface
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule