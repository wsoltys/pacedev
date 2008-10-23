Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
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
    sram_i          : in from_SRAM_t;
    sram_o          : out to_SRAM_t;

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

	component dkong_top is
		port
		(
			--    FPGA_USE
			I_CLK_24576M				: in std_logic;
			I_RESETn						: in std_logic;

			--    ROM IF
			O_ROM_AB						: out std_logic_vector(18 downto 0);
			I_ROM_DB						: in std_logic_vector(7 downto 0);
			O_ROM_CSn						: out std_logic;
			O_ROM_OEn						: out std_logic;
			O_ROM_WEn						: out std_logic;
			--    INPORT SW IF
			--I_PSW,

			I_U1								: in std_logic;
			I_D1								: in std_logic;
			I_L1								: in std_logic;
			I_R1								: in std_logic;
			I_J1								: in std_logic;
			I_U2								: in std_logic;
			I_D2								: in std_logic;
			I_L2								: in std_logic;
			I_R2								: in std_logic;
			I_J2								: in std_logic;
			I_S1								: in std_logic;
			I_S2								: in std_logic;
			I_C1								: in std_logic;

			O_DAT								: out std_logic;
			--    SOUND IF
			O_SOUND_OUT_L				: out std_logic;
			O_SOUND_OUT_R				: out std_logic;

			--    VGA (VIDEO) IF
			O_VGA_R							: out std_logic_vector(2 downto 0);
			O_VGA_G							: out std_logic_vector(2 downto 0);
			O_VGA_B							: out std_logic_vector(1 downto 0);
			O_VGA_H_SYNCn				: out std_logic;
			O_VGA_V_SYNCn				: out std_logic
		);
	end component;

	signal reset_n					: std_logic;
	
	signal inputs						: in8(0 to 3);
		
	signal rom_addr					: std_logic_vector(18 downto 0);
	signal rom_data					: std_logic_vector(7 downto 0);
	signal rom_cs_n					: std_logic;
	signal rom_oe_n					: std_logic;
	signal rom_we_n					: std_logic;
	
	signal cpu_rom_data			: std_logic_vector(7 downto 0);
	signal vid_rom_addr			: std_logic_vector(11 downto 0);
	signal vid_rom_data			: std_logic_vector(7 downto 0);
	signal obj_rom_addr			: std_logic_vector(12 downto 0);
	signal obj_rom_data			: std_logic_vector(7 downto 0);
	signal col_rom_data			: std_logic_vector(7 downto 0);
		
  -- spi signals
  signal spi_clk_s        : std_logic;
  signal spi_dout_s       : std_logic;
  signal spi_ena          : std_logic;
  signal spi_mode_s       : std_logic;
  signal spi_sel_s        : std_logic;

	signal leds_s						: std_logic_vector(7 downto 0);
	
begin

	reset_n <= not reset;

	-- map inputs
	
	vga_clk <= clk(1);	-- fudge

  spi_clk <= spi_clk_s when (spi_ena = '1') else 'Z';
  spi_dout <= spi_dout_s when (spi_ena = '1') else 'Z';
  spi_mode <= spi_mode_s when (spi_ena = '1') else 'Z';
  spi_sel <= spi_sel_s when (spi_ena = '1') else 'Z';
  
	leds <= leds_s;

	inputs_inst : entity work.Inputs
		generic map
		(
			NUM_INPUTS 			=> 4,
			CLK_1US_DIV			=> 20
		)
	  port map
	  (
	    clk     				=> clk(0),
	    reset   				=> reset,
	    ps2clk  				=> ps2clk,
	    ps2data 				=> ps2data,
			jamma						=> jamma,
			
			dips						=> (others => '0'),
			inputs					=> inputs
	  );

	dkong_top_inst : dkong_top
		port map
		(
			--    FPGA_USE
			I_CLK_24576M				=> clk(1),
			I_RESETn						=> reset_n,

			--    ROM IF
			O_ROM_AB						=> rom_addr,
			I_ROM_DB						=> rom_data,
			O_ROM_CSn						=> rom_cs_n,
			O_ROM_OEn						=> rom_oe_n,
			O_ROM_WEn						=> rom_we_n,

			--    INPORT SW IF
			--I_PSW,
			I_U1								=> inputs(0)(0),
			I_D1								=> inputs(0)(1),
			I_L1								=> inputs(0)(2),
			I_R1								=> inputs(0)(3),
			I_J1								=> inputs(0)(4),
			I_U2								=> inputs(1)(0),
			I_D2								=> inputs(1)(1),
			I_L2								=> inputs(1)(2),
			I_R2								=> inputs(1)(3),
			I_J2								=> inputs(1)(4),
			I_S1								=> inputs(2)(0),
			I_S2								=> inputs(2)(1),
			I_C1								=> inputs(2)(2),

			O_DAT								=> open,
			--    SOUND IF
			O_SOUND_OUT_L				=> open,
			O_SOUND_OUT_R				=> open,

			--    VGA (VIDEO) IF
			O_VGA_R							=> red(9 downto 7),
			O_VGA_G							=> green(9 downto 7),
			O_VGA_B							=> blue(9 downto 8),
			O_VGA_H_SYNCn				=> hsync,
			O_VGA_V_SYNCn				=> vsync
		);

	GEN_INTERNAL_ROM : if DKONG_INTERNAL_ROM generate
	
		-- mapped to $0000-$3FFF (16K)
		cpu_rom_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../src/platform/dkong/roms/dkong_rom.hex",
				numwords_a				=> 16384,
				widthad_a					=> 14
			)
			port map
			(
				clock							=> clk(1),
				address						=> rom_addr(13 downto 0),
				q									=> cpu_rom_data
			);

		-- mapped to $6000 (2K) and $7000 (2K)
		-- bits 15:12 = 0110,0111
		-- - use           0,   1
		vid_rom_addr <= rom_addr(12) & rom_addr(10 downto 0);
					
		video_rom_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../src/platform/dkong/roms/dkong_vid.hex",
				numwords_a				=> 4096,
				widthad_a					=> 12
			)
			port map
			(
				clock							=> clk(1),
				address						=> vid_rom_addr,
				q									=> vid_rom_data
			);

		-- mapped to $A000,$B000,$C000,$D000 (each 2K)
		-- - bits 15:12 = 1010,1011,1100,1101
		-- - use           0 0, 0 1, 1 0, 1 1
		obj_rom_addr <= rom_addr(14) & rom_addr(12) & rom_addr(10 downto 0);
					
		object_rom_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../src/platform/dkong/roms/dkong_obj.hex",
				numwords_a				=> 8192,
				widthad_a					=> 13
			)
			port map
			(
				clock							=> clk(1),
				address						=> obj_rom_addr,
				q									=> obj_rom_data
			);

		-- mapped to $F000
					
		colour_rom_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../src/platform/dkong/roms/dkong_col.hex",
				numwords_a				=> 4096,
				widthad_a					=> 12
			)
			port map
			(
				clock							=> clk(1),
				address						=> rom_addr(11 downto 0),
				q									=> col_rom_data
			);

		rom_data <= cpu_rom_data when rom_addr(15 downto 14) = "00" else
								vid_rom_data when rom_addr(15 downto 13) = "011" else
								col_rom_data when rom_addr(15 downto 12) = X"F" else
								obj_rom_data;
			
	end generate GEN_INTERNAL_ROM;
	
	GEN_EXTERNAL_ROM : if not DKONG_INTERNAL_ROM generate
	
		-- hook up external sram for the ROM
		sram_o.a(18 downto 0) <= rom_addr;
		sram_o.d(7 downto 0) <= rom_data;
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
		sram_o.cs <= not rom_cs_n;
		sram_o.oe <= not rom_oe_n;

	end generate GEN_EXTERNAL_ROM;

	-- used video colour resolution
	red(6 downto 0) <= (others => '0');
	green(6 downto 0) <= (others => '0');
	blue(6 downto 0) <= (others => '0');
	
	
	-- unused SRAM signals
	sram_o.a(23 downto 19) <= (others => '0');
	sram_o.we <= '0';
	
end SYN;

