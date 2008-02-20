library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

entity PACE is
  port
  (
     -- clocks and resets
     clk							: in    std_logic_vector(0 to 3);
     test_button      : in    std_logic;
     reset            : in    std_logic;

     -- game I/O
     ps2clk           : inout std_logic;
     ps2data          : inout std_logic;
     dip              : in    std_logic_vector(7 downto 0);
		 jamma						: in JAMMAInputsType;

     -- external RAM
			sram_i					: in from_SRAM_t;
			sram_o					: out to_SRAM_t;

     -- VGA video
     vga_clk          : out std_logic;
     lcm_data         : out std_logic_vector(9 downto 2);
     red              : out   std_logic_vector(9 downto 0);
     green            : out   std_logic_vector(9 downto 0);
     blue             : out   std_logic_vector(9 downto 0);
     hsync            : out   std_logic;
     vsync            : out   std_logic;

     -- composite video
     BW_CVBS          : out   std_logic_vector(1 downto 0);
     GS_CVBS          : out   std_logic_vector(7 downto 0);

     -- sound
     snd_clk          : out   std_logic;
     snd_data_l       : out   std_logic_vector(15 downto 0);
     snd_data_r       : out   std_logic_vector(15 downto 0);

     -- SPI (flash)
     spi_clk          : out   std_logic;
     spi_mode         : out   std_logic;
     spi_sel          : out   std_logic;
     spi_din          : in    std_logic;
     spi_dout         : out   std_logic;

     -- serial
     ser_tx           : out   std_logic;
     ser_rx           : in    std_logic;

     -- debug
     leds             : out   std_logic_vector(7 downto 0)
  );
  attribute MacroCell : boolean;

end PACE;

architecture SYN of PACE is

  -- uP signals
  signal uPaddr           : std_logic_vector(15 downto 0);
  signal uPdatao          : std_logic_vector(7 downto 0);

	signal vga_red					: std_logic_vector(9 downto 0);
	signal vga_green				: std_logic_vector(9 downto 0);
	signal vga_blue					: std_logic_vector(9 downto 0);
	signal vga_hsync				: std_logic;
	signal vga_vsync				: std_logic;
			        
  -- sound signals
  signal snd_rd           : std_logic;
  signal snd_wr           : std_logic;
  signal sndif_data       : std_logic_vector(7 downto 0);

  -- spi signals
  signal spi_clk_s        : std_logic;
  signal spi_dout_s       : std_logic;
  signal spi_ena          : std_logic;
  signal spi_mode_s       : std_logic;
  signal spi_sel_s        : std_logic;

begin

  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';

	-- hook up VGA output
  vga_clk <= clk(0);
	red <= vga_red;
	green <= vga_green;
	blue <= vga_blue;
	hsync <= vga_hsync;
	vsync <= vga_vsync;
	    
  U_Game : entity work.Game                                            
    Port Map
    (
      -- clocking and reset
      clk							=> clk,
      reset           => reset,
      test_button     => test_button,
  
      -- inputs
      ps2clk          => ps2clk,
      ps2data         => ps2data,
      dip             => dip,
      jamma           => jamma,

      -- micro buses
      upaddr          => uPaddr,
      updatao         => uPdatao,
  
      -- SRAM
			sram_i					=> sram_i,
			sram_o					=> sram_o,
  
      -- graphics (control)
	    red     				=> vga_red,
	    green   				=> vga_green,
	    blue    				=> vga_blue,
  	  hsync   				=> vga_hsync,
	    vsync						=> vga_vsync,

      cvbs            => GS_CVBS,

      -- sound
      snd_rd          => snd_rd,
      snd_wr          => snd_wr,
      sndif_datai     => sndif_data,
  
      -- spi interface
      spi_clk         => spi_clk_s,
      spi_din         => spi_din,
      spi_dout        => spi_dout_s,
      spi_ena         => spi_ena,
      spi_mode        => spi_mode_s,
      spi_sel         => spi_sel_s,
  
      -- serial
      ser_rx          => ser_rx,
      ser_tx          => ser_tx,
  
      -- on-board leds
      leds            => leds
    );

	SOUND_BLOCK : block
		signal snd_data		: std_logic_vector(7 downto 0);
	begin
	
	  U_Sound : entity work.Sound                                          
	    Port Map
	    (
	      sysclk      => clk(0),    -- fudge for now
	      reset       => reset,

	      sndif_rd    => snd_rd,              
	      sndif_wr    => snd_wr,              
	      sndif_addr  => uPaddr,
	      sndif_datai => uPdatao,

	      snd_clk     => snd_clk,
	      snd_data    => snd_data,           
	      sndif_datao => sndif_data
	    );

		-- route audio to both channels
		snd_data_l <= snd_data & "00000000";
		snd_data_r <= snd_data & "00000000";
	
	end block SOUND_BLOCK;
		
end SYN;

