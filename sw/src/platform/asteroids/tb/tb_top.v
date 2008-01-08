`include "timescale.v"

`define TB_TOP tb_asteroids
module `TB_TOP;

reg fpga_rst;

//
//  CLOCK GENERATION
//

reg     clk_24M;
reg     clk_40M;
initial
begin
  clk_24M = 1'b0;
  clk_40M = 1'b0;
end

  // clock1 - 24MHz
always
  #20.083333 clk_24M = ~clk_24M;
always
  #12.5 clk_40M = ~clk_40M;

wire [0:3]    clk;
assign clk[0] = clk_24M;
assign clk[1] = clk_40M;

// outputs
wire [9:0]    red;
wire [9:0]    green;
wire [9:0]    blue;

// Main simulation loop

integer fp;
integer v;
reg [9:0] x_vector;
reg [9:0] y_vector;
reg [3:0] z_vector;
reg [9:0] rx;
reg [9:0] ry;
reg [3:0] rz;
reg       beam_on;
reg       beam_ena;
integer n;

initial
begin
  // initialise simulation environment
  $init_signal_spy ("pace_1/beam_on", "beam_on");
  $init_signal_spy ("pace_1/beam_ena", "beam_ena");
  $init_signal_spy ("pace_1/x_vector", "x_vector");
  $init_signal_spy ("pace_1/y_vector", "y_vector");
  $init_signal_spy ("pace_1/z_vector", "z_vector");

  v = 0;
  rx = 10'b0;
  ry = 10'b0;
  rz = 4'b0;
  n = 0;

  fp = $fopen ("ast.dat");

  // reset processor for a few clocks 
  fpga_rst = 1'b1;
  repeat (30) @(posedge clk_24M);
  fpga_rst = 1'b0;

  // wait a bit
  @(posedge beam_on);

  //while (v < 1000000)
  while (v < 10000)
  begin
    @(posedge beam_ena);
    n = n + 1;
    if ({rx,ry,rz} !== {x_vector,y_vector,z_vector})
    begin
      //$fdisplay (fp, "%d, %d, %d, %d", x_vector, y_vector, z_vector, n);
      rx = x_vector;
      ry = y_vector;
      rz = z_vector;
      v = v + 1;
      n = 0;
    end
  end

  $fclose (fp);
  $stop;

end

PACE pace_1
(
	// clocks and resets
  .clk             (clk),
  .test_button     (1'b0),
  .reset           (fpga_rst),

  // game I/O
  //.ps2clk          (1'b0),
  //.ps2data         (1'b0),
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
