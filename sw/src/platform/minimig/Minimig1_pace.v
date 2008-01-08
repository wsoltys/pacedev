
module Minimig1_pace(	cpudata_out,cpuaddress,o_ipl,i_as,i_uds,i_lds,r_w,o_dtack,o_cpureset,cpuclk,
				ramdata,ramaddress,o_ramsel0,o_ramsel1,o_ub,o_lb,o_we,o_oe,
				c_7m_in,c_28m,
				txd,rxd,cts,rts,
				i_joy1,i_joy2,i_15khz,pwrled,msdat,msclk,kbddat,kbdclk,cpudata_in,
				floppy_ena,user_ena,user_clk,di_floppy,do_floppy,floppy_clk,exrst,di_user,
				o_hsyncout,o_vsyncout,redout,greenout,blueout,
				ldata,rdata,sd_wr_data,do_user);
//m68k pins
input 	[15:0]cpudata_in;		//m68k data bus
output 	[15:0]cpudata_out;		//m68k data bus
input	[23:1]cpuaddress;	//m68k address bus
output	[2:0]o_ipl;		//m68k interrupt request
input	i_as;				//m68k address strobe
input	i_uds;			//m68k upper data strobe
input	i_lds;			//m68k lower data strobe
input	r_w;				//m68k read / write
output	o_dtack;			//m68k data acknowledge
output	o_cpureset;		//m68k reset
output	cpuclk;			//m68k clock
//sram pins
input	[15:0]ramdata;		//sram data bus
output	[19:1]ramaddress;	//sram address bus
output	o_ramsel0;			//sram enable bank 0
output	o_ramsel1;			//sram enable bank 1
output	o_ub;				//sram upper byte select
output	o_lb;				//sram lower byte select
output	o_we;				//sram write enable
output	o_oe;				//sram output enable
//system	pins
input	c_7m_in;			//master system clock (4.433619MHz)
input	c_28m;
//rs232 pins
input	rxd;				//rs232 receive
output	txd;				//rs232 send
input	cts;				//rs232 clear to send
output	rts;				//rs232 request to send
//I/O
input	[5:0]i_joy1;		//joystick 1 [fire2,fire,up,down,left,right] (default mouse port)
input	[5:0]i_joy2;		//joystick 2 [fire2,fire,up,down,left,right] (default joystick port)
input	i_15khz;			//scandoubler disable
output	pwrled;			//power led
inout	msdat;			//PS2 mouse data
inout	msclk;			//PS2 mouse clk
inout	kbddat;			//PS2 keyboard data
inout	kbdclk;			//PS2 keyboard clk
//host controller interface (SPI)
input	floppy_ena;			//SPI enable 0
input	user_ena;			//SPI enable 1
input	user_clk;			//SPI enable 2
input	[15:0]di_floppy;
output	[15:0]do_floppy;			//SPI data output
input	floppy_clk;			//SPI clock
input   exrst;
input	[7:0]di_user;
//video
output	o_hsyncout;		//horizontal sync
output	o_vsyncout;		//vertical sync
output	[3:0]redout;		//red
output	[3:0]greenout;		//green
output	[3:0]blueout;		//blue
//audio
//output	left;			//audio bitstream left
//output	right;			//audio bitstream right
output	[13:0]ldata;			//left DAC data
output	[13:0]rdata; 			//right DAC data
output	[15:0]sd_wr_data;	//sdram 
output	[7:0]do_user;	//sdram 

Minimig1 minmig1_inst 
(	
	.cpudata_out	(cpudata_out),
	.cpuaddress   (cpuaddress),
	._ipl         (o_ipl),
	._as          (i_as),
	._uds         (i_uds),
	._lds         (i_lds),
	.r_w          (r_w),
	._dtack       (o_dtack),
	._cpureset    (o_cpureset),
	.cpuclk       (cpuclk),
	.ramdata      (ramdata),
	.ramaddress   (ramaddress),
	._ramsel0     (o_ramsel0),
	._ramsel1     (o_ramsel1),
	._ub          (o_ub),
	._lb          (o_lb),
	._we          (o_we),
	._oe          (o_oe),
	.c_7m_in      (c_7m_in),
	.c_28m        (c_28m),
	.txd          (txd),
	.rxd          (rxd),
	.cts          (cts),
	.rts          (rts),
	._joy1        (i_joy1),
	._joy2        (i_joy2),
	._15khz       (i_15khz),
	.pwrled       (pwrled),
	.msdat        (msdat),
	.msclk        (msclk),
	.kbddat       (kbddat),
	.kbdclk       (kbdclk),
	.cpudata_in   (cpudata_in),
	.floppy_ena   (floppy_ena),
	.user_ena     (user_ena),
	.user_clk     (user_clk),
	.di_floppy    (di_floppy),
	.do_floppy    (do_floppy),
	.floppy_clk   (floppy_clk),
	.exrst        (exrst),
	.di_user      (di_user),
	._hsyncout    (o_hsyncout),
	._vsyncout    (o_vsyncout),
	.redout       (redout),
	.greenout     (greenout),
	.blueout      (blueout),
	.ldata        (ldata),
	.rdata        (rdata),
	.sd_wr_data   (sd_wr_data),
	.do_user      (do_user)
);

endmodule
