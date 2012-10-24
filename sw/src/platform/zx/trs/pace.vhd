library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clkrst_i        : in from_CLKRST_t;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_INPUTS_t;

    -- external ROM/RAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_flash_t;
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;
    sdram_i         : in from_SDRAM_t;
    sdram_o         : out to_SDRAM_t;
    
    -- video
    video_i         : in from_VIDEO_t;
    video_o         : out to_VIDEO_t;

    -- audio
    audio_i         : in from_AUDIO_t;
    audio_o         : out to_AUDIO_t;
    
    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;
    
    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );
end entity PACE;

architecture SYN of PACE is

	alias clk_10M4832				: std_logic is clkrst_i.clk(0);
	alias clk_20mhz_s				: std_logic is clkrst_i.clk(1);
	
	signal reset_n					: std_logic;
	signal address					: std_logic_vector(16 downto 0);
	signal data							: std_logic_vector(7 downto 0);
	signal oe_n							: std_logic;
	signal we_n							: std_logic;
	signal ram_cs_n					: std_logic;
	signal rom_cs_n					: std_logic;
	signal rom_data					: std_logic_vector(7 downto 0);

	signal europe						: std_logic;
	signal video						: std_logic_vector(2 downto 0);	
	signal rgb_in						: std_logic_vector(7 downto 0);
	signal rgb_out					: std_logic_vector(7 downto 0);
	signal hsync_n_s				: std_logic;
	signal vsync_n_s				: std_logic;
	signal csync_s					: std_logic;
	signal hsync_s					: std_logic;
	signal vsync_s					: std_logic;
	signal hsync_out_n			: std_logic;
	signal vsync_out_n			: std_logic;
	
  -- spi signals
  signal spi_clk_s        : std_logic;
  signal spi_dout_s       : std_logic;
  signal spi_ena          : std_logic;
  signal spi_mode_s       : std_logic;
  signal spi_sel_s        : std_logic;

	signal leds_s						: std_logic_vector(7 downto 0);
	
begin

	reset_n <= not clkrst_i.rst(0);

	-- external memory logic
	sram_o.a <= std_logic_vector(resize(unsigned(address), sram_o.a'length));
	sram_o.d(sram_o.d'left downto data'length) <= (others => '0');
	sram_o.d(data'range) <= data when (ram_cs_n = '0' and we_n = '0') else (others => 'Z');
	sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
	sram_o.cs <= not ram_cs_n;
	sram_o.oe <= not oe_n;
	sram_o.we <= not we_n;
	data <= rom_data when (rom_cs_n = '0' and oe_n = '0') else
					sram_i.d(data'range) when (ram_cs_n = '0' and oe_n = '0') else 
					(others => 'Z');

	video_o.clk <= clkrst_i.clk(1);	-- by convention

	assert (not (TRS_LEVEL1_INTERNAL and TRS_EXTERNAL_ROM_RAM))
		report "Cannot choose both internal and external configurations"
		severity error;

	europe <= '1' when PACE_ADV724_STD = ADV724_STD_PAL else '0';
	
	GEN_L1_INT : if TRS_LEVEL1_INTERNAL generate

		trs80_inst : entity work.trs80
			port map
			(
				Rst_n			=> reset_n,
				Clk				=> clk_10M4832,
				Eur				=> europe,
				PS2_Clk		=> inputs_i.ps2_kclk,
				PS2_Data	=> inputs_i.ps2_kdat,
				CVBS			=> open,
				Video			=> video(video'left),
				HSync			=> hsync_n_s,
				Vsync			=> vsync_n_s,
				CSync			=> csync_s
			);
			
			oe_n <= '1';
			we_n <= '1';
			ram_cs_n <= '1';
			
	end generate GEN_L1_INT;
	
	GEN_EXT : if TRS_EXTERNAL_ROM_RAM generate
		trs80_inst : entity work.trs80xm
		port map
		(
			Rst_n				=> reset_n,
			Clk					=> clk_10M4832,
			Eur					=> europe,
			PS2_Clk			=> inputs_i.ps2_kclk,
			PS2_Data		=> inputs_i.ps2_kdat,
			CVBS				=> open,
			Video				=> video(video'left),
			HSync				=> hsync_n_s,
			Vsync				=> vsync_n_s,
			CSync				=> csync_s,
			OE_n				=> oe_n,
			WE_n				=> we_n,
			RAMCS_n			=> ram_cs_n,
			ROMCS_n			=> rom_cs_n,
			PGM_n				=> open,
			A						=> address,
			D						=> data
		);

	u_ROM	: entity work.trs_rom1
		port map 
		(
			Clk 				=> clk_10M4832,
			A 					=> address(13 downto 0),
			D 					=> rom_data
		);

	end generate GEN_EXT;
	
	GEN_CVBS : if TRS_VIDEO_CVBS = '1' generate

		video_o.rgb.r <= (others => video(video'left));
		video_o.rgb.g <= (others => video(video'left));
		video_o.rgb.b <= (others => video(video'left));
		video_o.vsync <= '1';
		video_o.hsync <= csync_s;
		
	end generate GEN_CVBS;
	
	GEN_VGA : if TRS_VIDEO_VGA = '1' generate
	
		-- extend the video to a vector
		rgb_in(rgb_in'left) <= video(video'left);
		hsync_s <= not hsync_n_s;
		vsync_s <= not vsync_n_s;
		
	  -----------------------------------------------------------------------------
	  -- VGA Scan Doubler
	  -----------------------------------------------------------------------------
		dblscan_b : entity work.DBLSCAN
		  port map
			(
				RGB_IN        => rgb_in,
				HSYNC_IN      => hsync_s,
				VSYNC_IN      => vsync_s,

				RGB_OUT       => rgb_out,
				HSYNC_OUT     => hsync_out_n,
				VSYNC_OUT     => vsync_out_n,
				--  NOTE CLOCKS MUST BE PHASE LOCKED !!
				CLK           => clk_10M4832,
				CLK_X2        => clk_20mhz_s
			);

		-- wire the vga signals - gated with hblank
		video_o.rgb.r <= rgb_out(rgb_out'left) & "000000000";
		video_o.rgb.g <= rgb_out(rgb_out'left) & "000000000";
		video_o.rgb.b <= rgb_out(rgb_out'left) & "000000000";
		video_o.hsync <= not hsync_out_n;
		video_o.vsync <= not vsync_out_n;
		
	end generate GEN_VGA;

  flash_o <= NULL_TO_FLASH;
  audio_o <= NULL_TO_AUDIO;
  spi_o <= NULL_TO_SPI;
  
	leds_o <= std_logic_vector(resize(unsigned(leds_s), leds_o'length));

end SYN;
