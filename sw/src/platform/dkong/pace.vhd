library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic_vector(0 to 3);

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
	
	signal mapped_inputs		: from_MAPPED_INPUTS_t(0 to 4-1);
		
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

	reset_n <= not reset_i(0);

	-- map inputs
	
	leds_o <= std_logic_vector(resize(unsigned(leds_s), leds_o'length));

	inputs_inst : entity work.inputs
		generic map
		(
      NUM_DIPS        => PACE_NUM_SWITCHES,
			NUM_INPUTS	    => 4,
			CLK_1US_DIV	    => 25
		)
	  port map
	  (
	    clk     	      => clk_i(1),
	    reset   	      => reset_i(1),
	    ps2clk  	      => inputs_i.ps2_kclk,
	    ps2data 	      => inputs_i.ps2_kdat,
			jamma			      => inputs_i.jamma_n,
	
	    dips     	      => switches_i,
	    inputs		      => mapped_inputs
	  );

	dkong_top_inst : dkong_top
		port map
		(
			--    FPGA_USE
			I_CLK_24576M				=> clk_i(1),
			I_RESETn						=> reset_n,

			--    ROM IF
			O_ROM_AB						=> rom_addr,
			I_ROM_DB						=> rom_data,
			O_ROM_CSn						=> rom_cs_n,
			O_ROM_OEn						=> rom_oe_n,
			O_ROM_WEn						=> rom_we_n,

			--    INPORT SW IF
			--I_PSW,
			I_U1								=> mapped_inputs(0).d(0),
			I_D1								=> mapped_inputs(0).d(1),
			I_L1								=> mapped_inputs(0).d(2),
			I_R1								=> mapped_inputs(0).d(3),
			I_J1								=> mapped_inputs(0).d(4),
			I_U2								=> mapped_inputs(1).d(0),
			I_D2								=> mapped_inputs(1).d(1),
			I_L2								=> mapped_inputs(1).d(2),
			I_R2								=> mapped_inputs(1).d(3),
			I_J2								=> mapped_inputs(1).d(4),
			I_S1								=> mapped_inputs(2).d(0),
			I_S2								=> mapped_inputs(2).d(1),
			I_C1								=> mapped_inputs(2).d(2),

			O_DAT								=> open,
			--    SOUND IF
			O_SOUND_OUT_L				=> open,
			O_SOUND_OUT_R				=> open,

			--    VGA (VIDEO) IF
			O_VGA_R							=> video_o.rgb.r(9 downto 7),
			O_VGA_G							=> video_o.rgb.g(9 downto 7),
			O_VGA_B							=> video_o.rgb.b(9 downto 8),
			O_VGA_H_SYNCn				=> video_o.hsync,
			O_VGA_V_SYNCn				=> video_o.vsync
		);

  -- CPU ROM mapped to $0000-$3FFF (16K)

  assert (not (DKONG_ROM_IN_FLASH and DKONG_ROM_IN_SRAM))
    report "Cannot choose *BOTH* ROM_IN_FLASH and ROM_IN_SRAM"
      severity failure;

	GEN_FLASH_ROM : if DKONG_ROM_IN_FLASH generate
	
		-- hook up external sram for the ROM
		flash_o.a <= std_logic_vector(resize(unsigned(rom_addr(13 downto 0)), flash_o.a'length));
		flash_o.d(7 downto 0) <= rom_data;
		flash_o.cs <= not rom_cs_n;
		flash_o.oe <= not rom_oe_n;
    flash_o.we <= '0';

    cpu_rom_data <= flash_i.d(cpu_rom_data'range);

	end generate GEN_FLASH_ROM;

	GEN_SRAM_ROM : if DKONG_ROM_IN_SRAM generate
	
		-- hook up external sram for the ROM
		sram_o.a <= std_logic_vector(resize(unsigned(rom_addr(13 downto 0)), sram_o.a'length));
		sram_o.d(7 downto 0) <= rom_data;
		sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
		sram_o.cs <= not rom_cs_n;
		sram_o.oe <= not rom_oe_n;
    sram_o.we <= '0';

    cpu_rom_data <= sram_i.d(cpu_rom_data'range);

	end generate GEN_SRAM_ROM;

	GEN_INTERNAL_ROM : if not (DKONG_ROM_IN_FLASH or DKONG_ROM_IN_SRAM) generate
	
		cpu_rom_inst : entity work.sprom
			generic map
			(
				init_file					=> "../../../../src/platform/dkong/roms/dkong_rom.hex",
				numwords_a				=> 16384,
				widthad_a					=> 14
			)
			port map
			(
				clock							=> clk_i(1),
				address						=> rom_addr(13 downto 0),
				q									=> cpu_rom_data
			);

	end generate GEN_INTERNAL_ROM;
	
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
      clock							=> clk_i(1),
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
      clock							=> clk_i(1),
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
      clock							=> clk_i(1),
      address						=> rom_addr(11 downto 0),
      q									=> col_rom_data
    );

  rom_data <= cpu_rom_data when rom_addr(15 downto 14) = "00" else
              vid_rom_data when rom_addr(15 downto 13) = "011" else
              col_rom_data when rom_addr(15 downto 12) = X"F" else
              obj_rom_data;
			
	-- used video colour resolution
	video_o.rgb.r(6 downto 0) <= (others => '0');
	video_o.rgb.g(6 downto 0) <= (others => '0');
	video_o.rgb.b(6 downto 0) <= (others => '0');
	
end SYN;
