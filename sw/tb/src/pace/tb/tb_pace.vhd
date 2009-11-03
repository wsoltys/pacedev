library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity tb_pace is
	port (
		fail:				out  boolean := false
	);
end tb_pace;

architecture SYN of tb_pace is

	signal reset_i	  : std_logic	:= '1';
  signal clk_i      : std_logic_vector(0 to 3) := (others => '0');
                    	
	signal clk_20M 		: std_logic := '0';
	signal clk_40M 		: std_logic := '0';

	signal buttons_i	: from_BUTTONS_t;
	signal switches_i	: from_SWITCHES_t;
	signal inputs_i		: from_INPUTS_t;
	signal flash_i		: from_FLASH_t;
	signal sram_i			: from_SRAM_t;
  signal sram_o     : to_SRAM_t;
  signal sdram_i    : from_SDRAM_t;
	signal video_i		: from_VIDEO_t;
	signal audio_i		:	from_AUDIO_t;
	signal spi_i			: from_SPI_t;
	signal ser_i			: from_SERIAL_t;
  signal project_i  : from_PROJECT_IO_t;
  signal project_o  : to_PROJECT_IO_t;
  signal platform_i : from_PLATFORM_IO_t;
  signal platform_o : to_PLATFORM_IO_t;
  signal target_i   : from_TARGET_IO_t;
  signal target_o   : to_TARGET_IO_t;

  signal sram_a     : std_logic_vector(16 downto 0) := (others => '0');
  signal sram_d     : std_logic_vector(7 downto 0) := (others => '0');
  signal sram_ncs   : std_logic_vector(1 downto 0) := (others => '0');
  signal sram_noe   : std_logic := '0';
  signal sram_nwe   : std_logic := '0';
    
begin
	-- Generate CLK and reset
  clk_20M <= not clk_20M after 25000 ps; -- 20MHz
  clk_40M <= not clk_40M after 12500 ps; -- 40MHz

	reset_i <= '0' after 10 ns;
  clk_i(0) <= clk_20M;
  clk_i(1) <= clk_20M;
  clk_i(2) <= '0';
  clk_i(3) <= '0';
  
	video_i.clk <= clk_40M;
	video_i.clk_ena <= '1';
  video_i.reset <= reset_i;

  GEN_SRAM : if PACE_HAS_SRAM generate
  
    sram_a <= sram_o.a(sram_a'range);
    sram_d <= sram_o.d(sram_d'range) when sram_o.cs = '1' and sram_o.we = '1' else (others => 'Z');
    sram_ncs <= '1' & not sram_o.cs;
    sram_noe <= not sram_o.oe;
    --sram_nwe <= not sram_o.we;
    --sram_i.d <= std_logic_vector(resize(unsigned(sram_d),sram_i.d'length));
    
    -- pulse the we
    process (clk_i(0), reset_i)
      variable we_r : std_logic := '0';
    begin
      if reset_i = '1' then
        we_r := '0';
      elsif rising_edge(clk_i(0)) then
        sram_nwe <= '1';  -- default
        if we_r = '0' and sram_o.we = '1' then
          sram_nwe <= '0';
        end if;
        we_r := sram_o.we;
        -- latch read data, because cpu latches data on falling edge MEM_RD
        -- and A changes at the same time DI is latched
        -- so if clock-to-input(DI) is slower than clock-to-out(A)
        -- we could be getting corrupt reads?!?
        sram_i.d <= std_logic_vector(resize(unsigned(sram_d),sram_i.d'length));
      end if;
    end process;
    
  end generate GEN_SRAM;

	pace_inst : entity work.PACE
	  port map
	  (
	  	-- clocks and resets
	    clk_i           => clk_i,
	    reset_i         => reset_i,
	
	    -- misc I/O
	    buttons_i       => buttons_i,
	    switches_i      => switches_i,
	    leds_o          => open,
	
	    -- controller inputs
	    inputs_i        => inputs_i,
	
	    -- external ROM/RAM
	    flash_i         => flash_i,
	    flash_o         => open,
	    sram_i       		=> sram_i,
			sram_o					=> sram_o,
	    sdram_i       	=> sdram_i,
			sdram_o					=> open,

	    -- video
	    video_i         => video_i,
	    video_o         => open,
	
	    -- audio
	    audio_i         => audio_i,
	    audio_o         => open,
	    
	    -- SPI (flash)
	    spi_i           => spi_i,
	    spi_o           => open,
	
	    -- serial
	    ser_i           => ser_i,
	    ser_o           => open,
	    
      -- custom i/o
      project_i       => project_i,
      project_o       => project_o,
      platform_i      => platform_i,
      platform_o      => platform_o,
      target_i        => target_i,
      target_o        => target_o
	  );
		
end SYN;
