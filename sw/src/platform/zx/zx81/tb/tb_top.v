`include "timescale.v"

`define TB_TOP tb_zx81
module `TB_TOP;

reg fpga_rst;

//
//  CLOCK GENERATION
//

reg     ref_clk;
initial
begin
  ref_clk = 1'b0;
end

  // clock1 - 13MHz
always
  #38.462 ref_clk = ~ref_clk;

// inputs
wire [1:4]    clk;
assign clk[1] = ref_clk;

// outputs
wire          ps2clk;
wire          ps2data;
wire [9:0]    red;
wire [9:0]    green;
wire [9:0]    blue;
wire          hsync;
wire          vsync;

reg           video81_vsync;

// Main simulation loop

initial
begin
  // initialise simulation environment
  $init_signal_spy ("PACE_1/zx01_inst/c_top/c_video81/vsync3", "video81_vsync");

  // reset processor for a few clocks 
  fpga_rst = 1'b1;
  repeat (30) @(posedge ref_clk);
  fpga_rst = 1'b0;

  // wait a bit
  @(posedge video81_vsync);
  @(posedge video81_vsync);
  //@(posedge video81_vsync);

  $stop;

end

PACE PACE_1
(
  // clocks and resets
  .clk             (clk),
  .test_button     (1'b0),
  .reset           (fpga_rst),

  // game I/O
  //.ps2clk          : inout std_logic;
  //.ps2data         : inout std_logic;
  .dip             (8'h00),
	//.jamma						: in JAMMAInputsType;

  // external RAM
  //.sram_addr       : out std_logic_vector(23 downto 0);
  //.sram_data       : inout std_logic_vector(7 downto 0);
  //.sram_cs         : out std_logic;
  //.sram_oe         : out std_logic;
  //.sram_we         : out std_logic;

  // VGA video
	//.vga_clk					: out std_logic;
  .red             (red),
  .green           (green),
  .blue            (blue),
	//.lcm_data				:	out std_logic_vector(9 downto 0);
  .hsync           (hsync),
  .vsync           (vsync),

  // composite video
  //.BW_CVBS         : out std_logic_vector(1 downto 0);
  //.GS_CVBS         : out std_logic_vector(7 downto 0);

  // sound
  //.snd_clk         : out std_logic;
  //.snd_data        : out std_logic_vector(7 downto 0);

  // SPI (flash)
  //.spi_clk         : out std_logic;
  //.spi_mode        : out std_logic;
  //.spi_sel         : out std_logic;
  .spi_din         (1'b0),
  //.spi_dout        : out std_logic;

  // serial
  //.ser_tx          : out std_logic;
  .ser_rx          (1'b0)

  // debug
  //.leds            : out std_logic_vector(7 downto 0)
);

endmodule
