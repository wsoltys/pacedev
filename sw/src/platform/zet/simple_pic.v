//`include "defines.v"

module simple_pic (
`ifdef DEBUG
    output reg [1:0] irr,
`endif
    input        clk,
    input        rst,
    input  [7:0] int,
    input        inta,
    output       intr,
    output reg [2:0]  iid
  );

  // Registers
`ifndef DEBUG
  reg [7:0] irr;
`endif

  // Continuous assignments
  // - note that only IRQs 0,1&4 are driven atm
  assign intr = irr[4]|irr[1]|irr[0];

`ifdef USE_ORIGINAL_CODE

  // Behaviour
  // irr
  always @(posedge clk)
    irr[0] <= rst ? 1'b0 : (int[0] | irr[0] & (iid | !inta));

  always @(posedge clk)
    irr[1] <= rst ? 1'b0 : (int[1] | irr[1] & !(iid & inta));

  // iid
  always @(posedge clk)
    iid <= rst ? 3'b0 : { 2'b0, (!irr[0] | inta) };
      
`else

  reg inta_r;
  always @(posedge clk)
    inta_r <= inta;

  always @(posedge clk)
    irr[0] <= rst ? 1'b0 : (int[0] | irr[0] & !(iid == 3'b000 && inta_r && !inta));
  
  always @(posedge clk)
    irr[1] <= rst ? 1'b0 : (int[1] | irr[1] & !(iid == 3'b001 && inta_r && !inta));

  reg int4_r;
  always @(posedge clk)
  begin
    irr[4] <= rst ? 1'b0 : ((int[4] && !int4_r) | irr[4] & !(iid == 3'b100 && inta_r && !inta));
    int4_r <= rst ? 1'b0 : int[4];
  end
  
  always @(posedge clk)
    iid <= rst ? 3'b0 : (inta ? iid :
                        (irr[0] ? 3'b000 :
                        (irr[1] ? 3'b001 :
                        (irr[4] ? 3'b100 : 3'b000))));
    
`endif

endmodule
