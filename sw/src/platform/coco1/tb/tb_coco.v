`include "timescale.v"

`define TB_TOP tb_coco
module `TB_TOP;

reg fpga_rst;
initial
begin
    fpga_rst = 1'b1;
    #1000 fpga_rst = 1'b0;
end

//
//  CLOCK GENERATION
//

reg [0:3]   clk;
initial
begin
  clk = 4'b0;
end

  // CLOCK0 - 20MHz
always
  #25 clk[0] = ~clk[0];

  // CLOCK1 - 57M272Hz
always
  #8.73 clk[1] = ~clk[1];

// inputs
wire    ps2clk;
wire    ps2data;

wire [9:0] vga_red;
wire [9:0] vga_green;
wire [9:0] vga_blue;
wire vga_hsync;
wire vga_vsync;

// SRAM
wire [23:0]   sram_addr;
wire          sram_cs;
wire [7:0]    sram_data;
wire          sram_oe;
wire          sram_we;

// Main simulation loop

reg fs_n;
reg [15:0] vdg_addr;
reg vram_wr;

initial
begin

  $init_signal_spy ("pace_inst/u_game/fs_n", "fs_n");
  $init_signal_spy ("pace_inst/u_game/mpu_addr", "vdg_addr");
  $init_signal_spy ("pace_inst/u_game/vram_wr", "vram_wr");

  begin : bananas
    fork
  
    begin
      // wait for reset to go away
      @(negedge fpga_rst);
    
      @(posedge fs_n);
      #1 @(posedge fs_n);
  
      while (1)
        ;
    end
  
    begin
      while (1)
      begin
        @(posedge vram_wr);
        //if ((vdg_addr < 'h0400) || (vdg_addr > 'h0600))
        //  disable bananas;
      end
    end
  
    join
  end // bananas

  $stop;

end

PACE pace_inst
(
   // clocks and resets
   .clk               (clk),
   .test_button       (1'b0),
   .reset             (fpga_rst),

   // game I/O
   //.ps2clk           : inout std_logic;
   //.ps2data          : inout std_logic;
   .dip               (8'b0),

   // external RAM
   .sram_addr         (sram_addr),
   .sram_data         (sram_data),
   .sram_cs           (sram_cs),
   .sram_oe           (sram_oe),
   .sram_we           (sram_we),

   // VGA video
   .red               (vga_red),
   .green             (vga_green),
   .blue              (vga_blue),
   .hsync             (vga_hsync),
   .vsync             (vga_vsync),

   // composite video
   //.BW_CVBS          : out   std_logic_vector(1 downto 0);
   //.GS_CVBS          : out   std_logic_vector(7 downto 0);

   // sound
   //.snd_clk          : out   std_logic;
   //.snd_data         : out   std_logic_vector(7 downto 0);

   // SPI (flash)
   //.spi_clk          : out   std_logic;
   //.spi_mode         : out   std_logic;
   //.spi_sel          : out   std_logic;
   .spi_din           (1'b0),
   //.spi_dout         : out   std_logic;

   // serial
   //.ser_tx           : out   std_logic;
   .ser_rx            (1'b1)

   // debug
   //.leds             : out   std_logic_vector(7 downto 0)
);

ram SRAM
(
  .addr           (sram_addr[15:0]),
  .data           (sram_data),
  .cs_n           (sram_cs),
  .oe_n           (sram_oe),
  .we_n           (sram_we)
);

endmodule

module ram (addr, data, cs_n, oe_n, we_n);

  input [15:0] addr;
  inout [7:0] data;
  input cs_n;
  input oe_n;
  input we_n;

  reg [7:0] mem[(1<<16)-1:0];

  initial
  begin
  end

  assign data = (!cs_n && !oe_n) ? mem[addr] : 8'bz;

  always @(cs_n or we_n)
    if (!cs_n && !we_n)
    begin
      mem[addr] = data;
      //#1 $display ("wrote: %H, %H (=>%H)", addr, data, mem[addr]);
    end
    //else
    //if (!cs_n && we_n)
    //begin
    //  #1 $display ("read: %H, (%H<=)", addr, mem[addr]);
    //end

`ifdef SAUSAGES
  always @(we_n or oe_n)
    if (!we_n && !oe_n)
      $display ("%t: err", $time);
`endif

endmodule
