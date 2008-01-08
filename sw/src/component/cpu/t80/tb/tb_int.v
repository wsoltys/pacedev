`include "timescale.v"

`define TB_TOP tb_int
module `TB_TOP;

reg fpga_rst;
initial
begin
    fpga_rst = 1'b1;
    #10 fpga_rst = 1'b0;
end

//
//  CLOCK GENERATION
//

reg     ref_clk;
initial
begin
  ref_clk = 1'b0;
end

  // REF_CLK - 20MHz
always
  #25 ref_clk = ~ref_clk;

integer count;
initial count = 0;
reg clk2M_en;
always @(posedge ref_clk)
begin
  if (count == 10)
  begin
    clk2M_en = 1'b1;
    count = 0;
  end
  else
  begin
    clk2M_en = 1'b0;
    count = count + 1;
  end
end

// inputs
reg           int;
reg[7:0]      di;

// outputs
wire          m1;
wire          mem_rd;
wire          mem_wr;
wire          io_rd;
wire          io_wr;
wire[15:0]    a;
wire[7:0]     do;

// Main simulation loop

initial
begin
  // initialise simulation environment
  int = 1'b0;

  // wait for reset to go away
  @(negedge fpga_rst);

  // wait a bit
  repeat (16) @(posedge clk2M_en);
  #1 int = 1'b1;
  repeat (48) @(posedge clk2M_en);

  $stop;

end

always @(posedge ref_clk)
  di <= (a === 16'b0 ? 8'hFB : 8'h00);

uPse upse_1
(
   .reset           (fpga_rst),
   .clk        	    (ref_clk),
   .clk_en				  (clk2M_en),
   .intreq          (int),
   .nmi             (1'b0),
   .intack          (intack),
   .datai           (di),
   .addr            (a),
   .mem_rd          (mem_rd),
   .mem_wr          (mem_wr),
   .io_rd           (io_rd),
   .io_wr           (io_wr),
   .datao           (do),
   .intvec          (8'h00),
   .m1              (m1)
);

endmodule


