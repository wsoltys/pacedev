`include "timescale.v"

`define TB_TOP tb_top
module `TB_TOP;

reg fpga_rst;

//
//  CLOCK GENERATION
//

reg     ref_clk;
reg     fifo_wrclk;
initial
begin
  ref_clk = 1'b0;
  fifo_wrclk = 1'b0;
end

  // clock1 - 32MHz
always
  #15.625 ref_clk = ~ref_clk;
always
  #8 fifo_wrclk = ~fifo_wrclk;

// inputs

// Main simulation loop

reg [7:0] fifo_data;
reg fifo_wrreq;
reg [1:0] stp;
reg mtr;

wire fifo_wrfull;
wire [7:0] fifo_wrusedw;

integer i;

initial
begin
  // initialise simulation environment

  $signal_force ("c1541_core_inst/c1541_logic_inst/stp[0]", "0", 0, 1);
  $signal_force ("c1541_core_inst/c1541_logic_inst/stp[1]", "0", 0, 1);

  // reset processor for a few clocks 
  fpga_rst = 1'b1;
  repeat (30) @(posedge ref_clk);
  fpga_rst = 1'b0;

  fifo_data = 8'h55;
  fifo_wrreq = 1'b0;
  $signal_force ("c1541_core_inst/c1541_logic_inst/mtr", "0", 0, 1);

  repeat (50) @(posedge fifo_wrclk);

  $signal_force ("c1541_core_inst/c1541_logic_inst/mtr", "1", 0, 1);
  #30000; //wait 30us
  for (i=0; i<32; i=i+1)
  begin
    if (i>=2 && i<=6) fifo_data = 8'hFF; else fifo_data = i;
    @(posedge fifo_wrclk) fifo_wrreq = 1'b1;
    repeat (4) @(posedge fifo_wrclk);
    @(posedge fifo_wrclk) fifo_wrreq = 1'b0;
  end

  #301000;  // wait 300.1us

  // turn the motor off for a bit
  $signal_force ("c1541_core_inst/c1541_logic_inst/mtr", "0", 0, 1);
  #40000;  // wait 40us
  $signal_force ("c1541_core_inst/c1541_logic_inst/mtr", "1", 0, 1);

  #60000; // 

  $signal_force ("c1541_core_inst/c1541_logic_inst/stp[0]", "0", 0, 1);
  $signal_force ("c1541_core_inst/c1541_logic_inst/stp[1]", "1", 0, 1);

  #100000;

  // now fill the fifo
  while (fifo_wrfull != 1'b1)
  begin
    @(posedge fifo_wrclk) fifo_wrreq = 1'b1;
    repeat (4) @(posedge fifo_wrclk);
    @(posedge fifo_wrclk) fifo_wrreq = 1'b0;
  end

  #100000;
  $stop;

end

c1541_core c1541_core_inst
(
	.clk_32M					(ref_clk),
	.reset						(fpga_rst),

	// serial bus
	//.sb_data_oe			  (),
	.sb_data_in			  (1'b0),
	//.sb_clk_oe				(),
	.sb_clk_in				(1'b0),
	//.sb_atn_oe				(),
	.sb_atn_in				(1'b0),
	
	// drive-side interface
	.ds							  (2'b00),
	//.act							(),

	// mechanism interface signals				
	.wps_n						(1'b1),
	.tr00_sense_n		  (1'b0),
	.stp_in					  (stp_in),
	.stp_out					(stp_out),

	// fifo signals
  .fifo_wrclk       (fifo_wrclk),
  .fifo_data        (fifo_data),
  .fifo_wrreq       (fifo_wrreq),
  .fifo_wrfull      (fifo_wrfull),
  .fifo_wrusedw     (fifo_wrusedw)
);

endmodule
