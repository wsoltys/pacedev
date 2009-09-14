library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

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
    
    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t;

		-- SB (IEC) port
		ext_sb_data_in	: in std_logic;
		ext_sb_data_oe	: out std_logic;
		ext_sb_clk_in		: in std_logic;
		ext_sb_clk_oe		: out std_logic;
		ext_sb_atn_in		: in std_logic;
		ext_sb_atn_oe		: out std_logic;

		-- generic drive mechanism i/o ports
		mech_in					: in std_logic_vector(63 downto 0);
		mech_out				: out std_logic_vector(63 downto 0);
		mech_io					: inout std_logic_vector(63 downto 0)
  );
end entity PACE;

architecture SYN of PACE is

  component c1541_top is
    generic
    (
      DEVICE_SELECT		: std_logic_vector(1 downto 0)
    );
    port
    (
      clk_32M					: in std_logic;
      reset						: in std_logic;

      -- serial bus
      sb_data_oe			: out std_logic;
      sb_data_in			: in std_logic;
      sb_clk_oe				: out std_logic;
      sb_clk_in				: in std_logic;
      sb_atn_oe				: out std_logic;
      sb_atn_in				: in std_logic;
      
      -- drive-side interface
      ds							: in std_logic_vector(1 downto 0);		-- device select
      act							: out std_logic;											-- activity LED

      -- generic drive mechanism i/o ports
      mech_in					: in std_logic_vector(63 downto 0);
      mech_out				: out std_logic_vector(63 downto 0);
      mech_io					: inout std_logic_vector(63 downto 0)
    );
  end component c1541_top;

	alias clk_32M								: std_logic is clk_i(0);
	alias clk_50M								: std_logic is clk_i(1);  -- not reallly 50MHz
  signal reset_n              : std_logic;
  
	signal sram_addr_s					: unsigned(16 downto 0);
	signal sram_cs_n            : std_logic;
	signal sram_we_n            : std_logic;
	signal r_s									: unsigned(7 downto 0);
	signal g_s									: unsigned(7 downto 0);
	signal b_s									: unsigned(7 downto 0);
	signal leds_s								: unsigned(leds_o'range);
	signal snd_data_s						: std_logic_vector(17 downto 0);

	signal c64_sb_data_oe				: std_logic;
	signal c64_sb_clk_oe				: std_logic;
	signal c64_sb_atn_oe				: std_logic;
	signal c64_ramdata_i        : unsigned(7 downto 0);
	signal c64_ramdata_o				: unsigned(7 downto 0);

	signal c1541_sb_data_oe			: std_logic;
	signal c1541_sb_clk_oe			: std_logic;
	signal c1541_sb_atn_oe			: std_logic;

	-- internal serial bus
	signal int_sb_data					: std_logic;
	signal int_sb_clk						: std_logic;
	signal int_sb_atn						: std_logic;

	signal c1541_activity_led		: std_logic;

	signal joyA_s								: unsigned(5 downto 0);
	
begin

  reset_n <= not reset_i;
  
  GEN_SRAM : if PACE_HAS_SRAM generate
    sram_o.a <= "0000000" & std_logic_vector(sram_addr_s);
    sram_o.d(c64_ramdata_o'range) <= std_logic_vector(c64_ramdata_o);
    sram_o.cs <= not sram_cs_n;
    sram_o.oe <= sram_we_n;
    sram_o.we <= not sram_we_n;
    c64_ramdata_i <= unsigned(sram_i.d(c64_ramData_i'range));
  end generate GEN_SRAM;
  
  GEN_NO_SRAM : if not PACE_HAS_SRAM generate

    BLK_NO_SRAM : block
      signal c64_ramdata_i_s  : std_logic_vector(c64_ramdata_i'range) := (others => '0');
    begin
  
      c64_ram_inst : entity work.spram
        generic map
        (
          --init_file		=> "../../../../../src/platform/trs80/m3/roms/trsvram.hex",
          numwords_a	=> 128*1024,
          widthad_a		=> 17
        )
        port map
        (
          clock			=> clk_32M,
          address		=> std_logic_vector(sram_addr_s),
          wren			=> not sram_we_n,
          data			=> std_logic_vector(c64_ramdata_o),
          q					=> c64_ramdata_i_s
        );

      c64_ramdata_i <= unsigned(c64_ramdata_i_s);
    
    end block BLK_NO_SRAM;
  
  end generate GEN_NO_SRAM;
    
	video_o.clk <= clk_32M; -- for DE2
	video_o.rgb.r <= std_logic_vector(r_s) & "00";
	video_o.rgb.g <= std_logic_vector(g_s) & "00";
	video_o.rgb.b <= std_logic_vector(b_s) & "00";
	-- not used, need to generate DE manually
  video_o.hblank <= '0';
  video_o.vblank <= '0';
  
	leds_o <= std_logic_vector(leds_s(leds_s'left downto 1)) & c1541_activity_led;

	-- generate DAC clock
	process (clk_32M, reset_i)
		-- 32MHz/8 = 4MHz
		variable count : std_logic_vector(2 downto 0);
	begin
		if reset_i = '1' then
			count := (others => '0');
		elsif rising_edge(clk_32M) then
			count := count + 1;
		end if;
		audio_o.clk <= count(count'left);
	end process;
	
	audio_o.ldata <= snd_data_s(snd_data_s'left downto snd_data_s'left+1-audio_o.ldata'length);
	audio_o.rdata <= snd_data_s(snd_data_s'left downto snd_data_s'left+1-audio_o.rdata'length);

	GEN_C64 : if C64_HAS_C64 generate
		
		-- active high
		joyA_s(5) <= '0';
		joyA_s(4) <= not inputs_i.jamma_n.p(1).button(1);
		joyA_s(3) <= not inputs_i.jamma_n.p(1).right;
		joyA_s(2) <= not inputs_i.jamma_n.p(1).left;
		joyA_s(1) <= not inputs_i.jamma_n.p(1).down;
		joyA_s(0) <= not inputs_i.jamma_n.p(1).up;
		
		fpga64_pace_inst : entity work.fpga64_pace
			generic map
			(
				resetCycles => C64_RESET_CYCLES
			)
			port map
			(
				sysclk				=> clk_50M,
				clk32					=> clk_32M,
				reset_n       => reset_n,

				-- keyboard interface (use any ordinairy PS2 keyboard)
				kbd_clk				=> inputs_i.ps2_kclk,
				kbd_dat				=> inputs_i.ps2_kdat,

				video_select	=> '0',

				-- external memory, since the 64K RAM is relatively big to implement in a FPGA
				ramAddr				=> sram_addr_s,
				ramData_i			=> c64_ramdata_i,
				ramData_o			=> c64_ramdata_o,
				
				ramCE					=> sram_cs_n,
				ramWe					=> sram_we_n,
				
				hsync					=> video_o.hsync,
				vsync					=> video_o.vsync,
				r 						=> r_s,
				g 						=> g_s,
				b 						=> b_s,

        -- cartridge port
        game          => '0',
        exrom         => '0',
        irq_n         => '1',
        nmi_n         => '1',
        dma_n         => '1',
        ba            => open,
        dot_clk       => open,
        cpu_clk       => open,

				-- joystick interface
				joyA					=> joyA_s,
				joyB					=> (others => '0'),

				-- serial port, for connection to pheripherals
	    	serioclk		  => open,
	    	ces		        => open,

				leds					=> leds_s(7 downto 0),
				
				-- video-out connect the FPGA to your PAL-monitor, using the CVBS-input
				cvbsOutput		=> open,
				
				-- (internal) SID connections
				sid_pot_x				=> open,
				sid_pot_y				=> open,
				sid_audio_out		=> open,
				sid_audio_data	=> snd_data_s,
			
				-- IEC
				sb_data_oe			=> c64_sb_data_oe,
				sb_data_in			=> int_sb_data,
				sb_clk_oe				=> c64_sb_clk_oe,
				sb_clk_in				=> int_sb_clk,
				sb_atn_oe				=> c64_sb_atn_oe,
				sb_atn_in				=> int_sb_atn,
					
				--Connector to the SID
				SIDclk					=> open,
				still						=> open
			);

	end generate GEN_C64;

	GEN_NO_C64 : if not C64_HAS_C64 generate
	
		c64_sb_data_oe <= '0';
		c64_sb_clk_oe <= '0';
		c64_sb_atn_oe <= '0';
		
	end generate GEN_NO_C64;
	
	GEN_1541 : if C64_HAS_1541 generate

		c1541_inst : c1541_top
			generic map
			(
				DEVICE_SELECT		=> C64_1541_DEVICE_SELECT(1 downto 0)
			)
			port map
			(
				clk_32M					=> clk_32M,
				reset						=> reset_i,

				-- serial bus
				sb_data_oe			=> c1541_sb_data_oe,
				sb_data_in			=> int_sb_data,
				sb_clk_oe				=> c1541_sb_clk_oe,
				sb_clk_in				=> int_sb_clk,
				sb_atn_oe				=> c1541_sb_atn_oe,
				sb_atn_in				=> int_sb_atn,

				-- drive-side interface				
				ds							=> switches_i(1 downto 0),
				act							=> c1541_activity_led,

				-- generic drive mechanism i/o ports
				mech_in					=> mech_in,
				mech_out				=> mech_out,
				mech_io					=> mech_io
			);

	end generate GEN_1541;

	GEN_NO_1541 : if not C64_HAS_1541 generate

		c1541_sb_data_oe <= '0';
		c1541_sb_clk_oe <= '0';
		c1541_sb_atn_oe <= '0';
		
		c1541_activity_led <= '0';
		
	end generate GEN_NO_1541;

	-- wire up the internal, external SB bus
	
	GEN_EXT_SB : if C64_HAS_EXT_SB generate

		BLK_EXT_SB : block
		
			constant UNMETA_STAGES : natural := 2;
			
			signal um_sb_data_in 	: std_logic_vector(UNMETA_STAGES-1 downto 0);
			signal um_sb_clk_in 	: std_logic_vector(UNMETA_STAGES-1 downto 0);
			signal um_sb_atn_in 	: std_logic_vector(UNMETA_STAGES-1 downto 0);
			
		begin
	
			process (clk_32M, reset_i)
			begin
				if reset_i = '1' then
					um_sb_data_in <= (others => '1');
					um_sb_clk_in <= (others => '1');
					um_sb_atn_in <= (others => '1');
				elsif rising_edge(clk_32M) then
					um_sb_data_in <= um_sb_data_in(um_sb_data_in'left-1 downto 0) & ext_sb_data_in;
					um_sb_clk_in <= um_sb_clk_in(um_sb_clk_in'left-1 downto 0) & ext_sb_clk_in;
					um_sb_atn_in <= um_sb_atn_in(um_sb_atn_in'left-1 downto 0) & ext_sb_atn_in;
				end if;
			end process;
					
			int_sb_data <= 	'0' when (c64_sb_data_oe = '1' or c1541_sb_data_oe = '1') else
											um_sb_data_in(um_sb_data_in'left);
			int_sb_clk <= 	'0' when (c64_sb_clk_oe = '1' or c1541_sb_clk_oe = '1') else
											um_sb_clk_in(um_sb_clk_in'left);
			int_sb_atn <= 	'0' when (c64_sb_atn_oe = '1' or c1541_sb_atn_oe = '1') else
											um_sb_atn_in(um_sb_atn_in'left);

		end block BLK_EXT_SB;
	
	end generate GEN_EXT_SB;
			
	GEN_NO_EXT_SB : if not C64_HAS_EXT_SB generate
	
		int_sb_data <=	not (c64_sb_data_oe or c1541_sb_data_oe);
		int_sb_clk <= 	not (c64_sb_clk_oe or c1541_sb_clk_oe);
		int_sb_atn <= 	not (c64_sb_atn_oe or c1541_sb_atn_oe);

	end generate GEN_NO_EXT_SB;

	-- doesn't matter if no external bus is connected
	ext_sb_data_oe <= c64_sb_data_oe or c1541_sb_data_oe;
	ext_sb_clk_oe <= c64_sb_clk_oe or c1541_sb_clk_oe;
	ext_sb_atn_oe <= c64_sb_atn_oe or c1541_sb_atn_oe;

	-- unused
	spi_o <= NULL_TO_SPI;
	ser_o <= NULL_TO_SERIAL;

end SYN;

