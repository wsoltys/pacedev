Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk             : in std_logic_vector(0 to 3);
    test_button     : in std_logic;
    reset           : in std_logic;

    -- game I/O
    ps2clk          : inout std_logic;
    ps2data         : inout std_logic;
    dip             : in std_logic_vector(7 downto 0);
		jamma						: in JAMMAInputsType;

    -- external RAM
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
    hsync           : out std_logic;
    vsync           : out std_logic;

    -- composite video
    BW_CVBS         : out std_logic_vector(1 downto 0);
    GS_CVBS         : out std_logic_vector(7 downto 0);

    -- sound
    snd_clk         : out std_logic;
    snd_data_l      : out std_logic_vector(15 downto 0);
    snd_data_r      : out std_logic_vector(15 downto 0);

    -- SPI (flash)
    spi_clk         : out std_logic;
    spi_mode        : out std_logic;
    spi_sel         : out std_logic;
    spi_din         : in std_logic;
    spi_dout        : out std_logic;

    -- serial
    ser_tx          : out std_logic;
    ser_rx          : in std_logic;

    -- debug
    leds            : out std_logic_vector(7 downto 0)
  );

end PACE;

architecture SYN of PACE is

	alias clk_10M4832				: std_logic is clk(0);
	alias clk_20mhz_s				: std_logic is clk(1);
	
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

	reset_n <= not reset;

	-- external memory logic
	sram_o.a <= EXT(address, sram_o.a'length);
	sram_o.d(data'range) <= data when (ram_cs_n = '0' and we_n = '0') else (others => 'Z');
	sram_o.be <= EXT("1", sram_o.be'length);
	sram_o.cs <= not ram_cs_n;
	sram_o.oe <= not oe_n;
	sram_o.we <= not we_n;
	data <= rom_data when (rom_cs_n = '0' and oe_n = '0') else
					sram_i.d(data'range) when (ram_cs_n = '0' and oe_n = '0') else 
					(others => 'Z');

	vga_clk <= clk(1);	-- fudge

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
				PS2_Clk		=> ps2clk,
				PS2_Data	=> ps2data,
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
			PS2_Clk			=> ps2clk,
			PS2_Data		=> ps2data,
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

		red <= (others => video(video'left));
		green <= (others => video(video'left));
		blue <= (others => video(video'left));
		vsync <= '1';
		hsync <= csync_s;
		
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
		red <= rgb_out(rgb_out'left) & "000000000";
		green <= rgb_out(rgb_out'left) & "000000000";
		blue <= rgb_out(rgb_out'left) & "000000000";
		hsync <= not hsync_out_n;
		vsync <= not vsync_out_n;
		
	end generate GEN_VGA;

  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';
  
	leds <= leds_s;

end SYN;

