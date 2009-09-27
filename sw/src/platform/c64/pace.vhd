library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
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

  component c1541_core is
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

      -- mechanism interface signals				
      wps_n						: in std_logic;
      tr00_sense_n		: in std_logic;
      stp_in					: out std_logic;
      stp_out					: out std_logic;

      -- fifo signals
      fifo_wrclk      : in std_logic;
      fifo_data       : in std_logic_vector(7 downto 0);
      fifo_wrreq      : in std_logic;
      fifo_wrfull     : out std_logic;
      fifo_wrusedw    : out std_logic_vector(7 downto 0)
    );
  end component c1541_core;

	alias clk_32M								: std_logic is clk_i(0);
	alias clk_50M								: std_logic is clk_i(1);
		
	signal sram_addr_s					: unsigned(16 downto 0);
	signal sram_cs_n            : std_logic;
	signal sram_oe_n            : std_logic;
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
  signal c64_romdata_i        : unsigned(7 downto 0);
  
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

  GEN_SRAM : if PACE_HAS_SRAM generate
    sram_o.a <= "0000000" & std_logic_vector(sram_addr_s);
    sram_o.d(c64_ramdata_o'range) <= std_logic_vector(c64_ramdata_o);
    sram_o.be <= "0001";
    sram_o.cs <= not sram_cs_n;
    sram_o.oe <= sram_we_n; --not sram_oe_n;
    sram_o.we <= not sram_we_n;
    c64_ramdata_i <= unsigned(sram_i.d(c64_ramData_i'range));
  end generate GEN_SRAM;
  
  GEN_NO_SRAM : if not PACE_HAS_SRAM generate

    BLK_NO_SRAM : block
      signal c64_ramdata_i_s  : std_logic_vector(c64_ramdata_i'range) := (others => '0');
      signal wren             : std_logic := '0';
    begin

      wren <= not (sram_cs_n or sram_we_n);
      
      c64_ram_inst : entity work.spram
        generic map
        (
          widthad_a		    => 17,
          numwords_a	    => 2**17          -- 128KB
          --outdata_reg_a   => "CLOCK0"
        )
        port map
        (
          clock			=> clk_32M,
          address		=> std_logic_vector(sram_addr_s),
          wren			=> wren,
          data			=> std_logic_vector(c64_ramdata_o),
          q					=> c64_ramdata_i_s
        );

      c64_ramdata_i <= unsigned(c64_ramdata_i_s);
    
    end block BLK_NO_SRAM;
  
  end generate GEN_NO_SRAM;

  GEN_FLASH : if PACE_HAS_FLASH generate
  
		flash_o.a(flash_o.a'left downto 20) <= (others => '0');
		-- switches define 16KB bank in flash
		flash_o.a(19 downto 14) <= switches_i(9 downto 4);
		flash_o.a(13 downto 0) <= std_logic_vector(sram_addr_s(13 downto 0));
		flash_o.d <= (others => '0');
		flash_o.we <= '0';
		flash_o.cs <= '1';
		flash_o.oe <= '1';
  
    c64_romdata_i <= unsigned(flash_i.d(7 downto 0));
    
  end generate GEN_FLASH;
  
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

  -- pipe it up to custom i/o as well
  platform_o.snd_data <= snd_data_s;
  
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
        ENABLE_VIDEO_CFG_OSD  => true,
        ENABLE_OSD            => true,
				resetCycles           => C64_RESET_CYCLES
			)
			port map
			(
				sysclk			  => clk_50M,		  -- for carts
				clk32					=> clk_32M,
				reset_n	      => not reset_i,

				-- keyboard interface (use any ordinairy PS2 keyboard)
				kbd_clk				=> inputs_i.ps2_kclk,
				kbd_dat				=> inputs_i.ps2_kdat,

				--video_select	=> '0',

				-- external memory, since the 64K RAM is relatively big to implement in a FPGA
				ramAddr				=> sram_addr_s,
				ramData_i			=> c64_ramdata_i,
				ramData_o			=> c64_ramdata_o,
        romData_i     => c64_romdata_i,
				
				ramCE					=> sram_cs_n,
				ramWe					=> sram_we_n,
				
				hsync					=> video_o.hsync,
				vsync					=> video_o.vsync,
				r 						=> r_s,
				g 						=> g_s,
				b 						=> b_s,

        -- cartridge port
        game          => not switches_i(2),
        exrom         => not switches_i(3),
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

				--leds					=> leds_s(7 downto 0),
				
				-- video-out connect the FPGA to your PAL-monitor, using the CVBS-input
				--cvbsOutput		=> open,
				
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

		c1541_inst : c1541_core
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

        -- mechanism interface signals				
        wps_n						=> platform_i.wps_n,
        tr00_sense_n		=> platform_i.tr00_sense_n,
        stp_in					=> platform_o.stp_in,
        stp_out					=> platform_o.stp_out,

        -- fifo signals
        fifo_wrclk      => platform_i.fifo_wrclk,
        fifo_data       => platform_i.fifo_data,
        fifo_wrreq      => platform_i.fifo_wrreq,
        fifo_wrfull     => platform_o.fifo_wrfull,
        fifo_wrusedw    => platform_o.fifo_wrusedw
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
			
			signal sb_data_in_r 	: std_logic_vector(UNMETA_STAGES-1 downto 0);
			alias sb_data_in_um   : std_logic is sb_data_in_r(sb_data_in_r'left);
			signal sb_clk_in_r 	  : std_logic_vector(UNMETA_STAGES-1 downto 0);
			alias sb_clk_in_um    : std_logic is sb_clk_in_r(sb_clk_in_r'left);
			signal sb_atn_in_r 	  : std_logic_vector(UNMETA_STAGES-1 downto 0);
			alias sb_atn_in_um    : std_logic is sb_atn_in_r(sb_atn_in_r'left);
			
		begin
	
			process (clk_32M, reset_i)
			begin
				if reset_i = '1' then
					sb_data_in_r <= (others => '1');
					sb_clk_in_r <= (others => '1');
					sb_atn_in_r <= (others => '1');
				elsif rising_edge(clk_32M) then
					sb_data_in_r <= sb_data_in_r(sb_data_in_r'left-1 downto 0) & platform_i.sb_data_in;
					sb_clk_in_r <= sb_clk_in_r(sb_clk_in_r'left-1 downto 0) & platform_i.sb_clk_in;
					sb_atn_in_r <= sb_atn_in_r(sb_atn_in_r'left-1 downto 0) & platform_i.sb_atn_in;
				end if;
			end process;
					
			int_sb_data <= 	'0' when (c64_sb_data_oe = '1' or c1541_sb_data_oe = '1') else
											sb_data_in_um;
			int_sb_clk <= 	'0' when (c64_sb_clk_oe = '1' or c1541_sb_clk_oe = '1') else
											sb_clk_in_um;
			int_sb_atn <= 	'0' when (c64_sb_atn_oe = '1' or c1541_sb_atn_oe = '1') else
											sb_atn_in_um;

		end block BLK_EXT_SB;
	
	end generate GEN_EXT_SB;
			
	GEN_NO_EXT_SB : if not C64_HAS_EXT_SB generate
	
		int_sb_data <=	not (c64_sb_data_oe or c1541_sb_data_oe);
		int_sb_clk <= 	not (c64_sb_clk_oe or c1541_sb_clk_oe);
		int_sb_atn <= 	not (c64_sb_atn_oe or c1541_sb_atn_oe);

	end generate GEN_NO_EXT_SB;

	-- doesn't matter if no external bus is connected
	platform_o.sb_data_oe <= c64_sb_data_oe or c1541_sb_data_oe;
	platform_o.sb_clk_oe <= c64_sb_clk_oe or c1541_sb_clk_oe;
	platform_o.sb_atn_oe <= c64_sb_atn_oe or c1541_sb_atn_oe;

	-- unused
	spi_o <= NULL_TO_SPI;
	ser_o <= NULL_TO_SERIAL;

end SYN;

