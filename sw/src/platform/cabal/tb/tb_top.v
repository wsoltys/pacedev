`include "timescale.v"

`define TB_TOP tb_cabal
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

  // clock1 - 12MHz
always
  //#20.833 ref_clk = ~ref_clk;
  #41.667 ref_clk = ~ref_clk;

// inputs

// outputs
wire          ps2clk;
wire          ps2data;
wire [23:0]   sram_addr;
wire          sram_cs;
wire [15:0]   sram_di;
wire [15:0]   sram_do;
wire          sram_oe;
wire          sram_we;
wire [1:4]    clk;

wire [15:0]   sram_data;

assign clk[1] = ref_clk;

// Main simulation loop

initial
begin
  // initialise simulation environment

  // reset processor for a few clocks 
  fpga_rst = 1'b1;
  repeat (30) @(posedge ref_clk);
  fpga_rst = 1'b0;

  // wait a bit
  repeat (500) @(posedge ref_clk);

  $stop;

end

Game Game_1
(
  // clocking and reset
  .clk             (clk),
  .reset           (fpga_rst),
  .test_button     (1'b0),

  // inputs
  .ps2clk          (ps2clk),
  .ps2data         (ps2data),
  .dip             (8'h00),
	//.jamma						: in JAMMAInputsType;
	
  // micro buses
  //.upaddr          : out std_logic_vector(15 downto 0);   
  //.updatao         : out std_logic_vector(7 downto 0);    

  // SRAM
  .sram_a          (sram_addr),
  .sram_di         (sram_di),
  .sram_do         (sram_do),
  .sram_cs         (sram_cs),
  .sram_oe         (sram_oe),
  .sram_we         (sram_we),

  //.gfxbank_data    : out std_logic_vector(7 downto 0);
	//.palette_data		: out ByteArrayType(15 downto 0);

  // graphics (bitmap)
	.bitmap_addr			(16'h0000),
	//.bitmap_data			: out std_logic_vector(7 downto 0);
	
  // graphics (tilemap)
  .tilemapaddr     (16'h0000),
  //.tilemapdatao    : out std_logic_vector(15 downto 0);    
  .tileaddr        (16'h0000),
  //.tiledatao       : out std_logic_vector(7 downto 0);    
  .attr_addr       (10'b0),
  //.attr_dout       : out std_logic_vector(15 downto 0);   

  // graphics (sprite)
  //.sprite_reg_addr : out std_logic_vector(7 downto 0);    
  //.sprite_wr       : out std_logic;                       
  .spriteaddr      (16'h0000),
  //.spritedata      : out std_logic_vector(31 downto 0);   

  // graphics (control)
  .vblank          (1'b0),
	//.xcentre					: out std_logic_vector(9 downto 0);
	//.ycentre					: out std_logic_vector(9 downto 0);
	
  // sound
  //.snd_rd          : out std_logic;                       
  //.snd_wr          : out std_logic;
  .sndif_datai     (8'h00),

  // spi interface
  //.spi_clk         : out std_logic;                       
  .spi_din         (1'b0),
  //.spi_dout        : out std_logic;                       
  //.spi_ena         : out std_logic;                       
  //.spi_mode        : out std_logic;                       
  //.spi_sel         : out std_logic;                       

  // serial
  .ser_rx          (1'b0)
  //.ser_tx          : out std_logic;                       

  // on-board leds
  //.leds            : out std_logic_vector(7 downto 0)    
);

wire [15:0] rom_data;

// use sram with no write for eeprom
SRAM8MBit
#(
  .clear_on_power_up(1'b1),
  .download_on_power_up(1'b1),
  .download_filename("epromload.dat"),   // load some values
  .tAA_max (100-0.1),
  .tOHA_min ( 5),
  .tACE_max(100-0.1),
  .tDOE_max (50-0.1),
  .tLZOE_min(50-0.1),
  .tHZOE_max(50-0.1),
  .tLZCE_min(50-0.1),
  .tHZCE_max(50-0.1),
  .tWC_min  (5),
  .tHZWE_max(20), // no spec, but needed even for READ
  .tLZWE_min(5)  // no spec
)
CPU_ROM
(
  .A          ({sram_addr[18:0]}),
  .D          (rom_data),
  .NOE        (~sram_oe),
  .NCE1       (~sram_cs),
  .CE2        (1'b1),
  .NWE        (~sram_we),
  .NBHE       (1'b0),
  .NBLE       (1'b0),
  .NBYTE      (1'b1)
);

assign sram_data = (sram_cs && sram_we ? sram_do : rom_data);
assign sram_di = rom_data;

endmodule
