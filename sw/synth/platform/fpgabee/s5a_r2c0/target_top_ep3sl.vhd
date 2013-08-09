library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;

entity target_top_ep3sl is
	port
	(
		ddr64_odt     : out std_logic_vector(0 downto 0);
		--ddr64_clk     : inout std_logic_vector(0 downto 0);
		--ddr64_clk_n   : inout std_logic_vector(0 downto 0);
		ddr64_cs_n    : out std_logic_vector(0 downto 0);
		ddr64_cke     : out std_logic_vector(0 downto 0);
		ddr64_a       : out std_logic_vector(12 downto 0);
		ddr64_ba      : out std_logic_vector(2 downto 0);
		ddr64_ras_n   : out std_logic;
		ddr64_cas_n   : out std_logic;
		ddr64_we_n    : out std_logic;
		ddr64_dq      : inout std_logic_vector(63 downto 0);
		--ddr64_dqs     : inout std_logic_vector(7 downto 0);
		--ddr64_dqsn    : inout std_logic_vector(7 downto 0);
		ddr64_dm      : out std_logic_vector(7 downto 0);
		ddr64_reset_n : out std_logic;

    -- DVI output, 1V5 I/O 1 pix/clk, 24-bit mode
		vdo_red			  : out std_logic_vector(7 downto 0);
		vdo_green		  : out std_logic_vector(7 downto 0);
		vdo_blue		  : out std_logic_vector(7 downto 0);
		vdo_idck		  : out std_logic;
		vdo_hsync		  : out std_logic;
		vdo_vsync		  : out std_logic;
		vdo_de			  : out std_logic;

    -- DVI input, 1 pix/clk, 24-bit mode
		vdi_odck			: in std_logic;
		vdi_red				: in std_logic_vector(7 downto 0);
		vdi_green			: in std_logic_vector(7 downto 0);
		vdi_blue			: in std_logic_vector(7 downto 0);
		vdi_de				: in std_logic;
		vdi_vsync			: in std_logic;
		vdi_hsync			: in std_logic;
		vdi_scdt			: in std_logic;
		--vdi_pdn				: out std_logic;

    -- VGA input, 1 pix/clk, 30-bit mode
		vai_dataclk		: in std_logic;
		vai_extclk		: out std_logic;
		vai_red				: in std_logic_vector(9 downto 0);
		vai_green			: in std_logic_vector(9 downto 0);
		vai_blue			: in std_logic_vector(9 downto 0);
		vai_vsout			: in std_logic;
		vai_hsout			: in std_logic;
		vai_sogout		: in std_logic;
		vai_fidout		: in std_logic;
		--vai_pwdn			: out std_logic;
		vai_resetb_n	: out std_logic;
		vai_coast			: in std_logic;
		--vai_scl				: inout std_logic;
		--vai_sda				: inout std_logic;

		-- LVDS video from the Cyclone
		vli_red         : in std_logic_vector(7 downto 0); -- 7..0
		vli_green       : in std_logic_vector(7 downto 0); -- 15..8
		vli_blue        : in std_logic_vector(7 downto 0); -- 23..16
		vli_hsync       : in std_logic;  -- 24
		vli_vsync       : in std_logic;  -- 25
		vli_de          : in std_logic;  -- 26
		vli_locked      : in std_logic;  -- 27
		vli_clk			  	: in std_logic;

    -- I2C to the Cyclone
		vid_scl			  : inout std_logic;
		vid_sda			  : inout std_logic;

    -- SDVO to LVDS input, dual 4 channel x 7 
		vsi_clk			  : in std_logic_vector(1 downto 0);
		vsi_data		  : in std_logic_vector(7 downto 0);
		vsi_enavdd	  : in std_logic;
		vsi_enabkl	  : in std_logic;
		
		vlo_clk			  : out std_logic;
		vlo_data		  : out std_logic_vector(2 downto 0);

    -- VGA output, 1 pix/clk, 30-bit mode
		vao_clk	  	  : out std_logic;
		vao_red			  : out std_logic_vector(9 downto 0);
		vao_green		  : out std_logic_vector(9 downto 0);
		vao_blue		  : out std_logic_vector(9 downto 0);
		vao_hsync     : out std_logic;
		vao_vsync     : out std_logic;
		vao_blank_n   : out std_logic;
		vao_sync_n	  : out std_logic;
		vao_sync_t	  : out std_logic;
		vao_m1			  : out std_logic;
		vao_m2			  : out std_logic;

    -- Connection to video FPGA
		vid_address			  : in std_logic_vector(10 downto 0);
		vid_data				  : inout std_logic_vector(15 downto 0);
		vid_write_n			  : in std_logic;
		vid_read_n			  : in std_logic;
		vid_waitrequest_n	: out std_logic;
		vid_irq_n				  : out std_logic;
		vid_clk					  : in std_logic;
    vid_reset_core_n  : in std_logic;
    vid_reset_n       : in std_logic;
    
		vid_spare		  : in std_logic_vector(29 downto 28);

		clk24_b			  : in std_logic;
		veb_ck_b		  : in std_logic;

		clk24_c			  : in std_logic;
		veb_ck_c		  : in std_logic;

		clk24_d			  : in std_logic;
		veb_ck_d		  : in std_logic

--		ddr_clk			: in std_logic;
	);

end entity target_top_ep3sl;

architecture SYN of target_top_ep3sl is

  constant ONBOARD_CLOCK_SPEED  : integer := 24000000;

  alias clk_24M       : std_logic is clk24_d;
  
  signal clk_108M     : std_logic := '0';
  signal vip_clk      : std_logic := '0';
  signal vdo_clk_x2   : std_logic := '0';
  
  signal pll_locked     : std_logic := '0';

  signal init       	  : std_logic := '1';
  signal arst           : std_logic;
  signal rst            : std_logic;
  
  signal clk_100M       : std_logic;
  signal clk_37M125     : std_logic;
  signal clk_3M375_en   : std_logic;
  signal clk_40M        : std_logic;
  
  -- MEMORY (ROM+RAM) signals
  signal ram_a          : std_logic_vector(17 downto 0);
  signal ram_d_i        : std_logic_vector(7 downto 0);
  signal ram_d_o        : std_logic_vector(7 downto 0);
  signal ram_wr         : std_logic;

  -- ROM signals
  signal rom_d_o        : std_logic_vector(7 downto 0);
  
  -- SRAM signals
  signal sram_d_o       : std_logic_vector(7 downto 0);
  signal sram_wr        : std_logic;

  signal ps2_clk        : std_logic;
  signal ps2_dat        : std_logic;
  
begin

	reset_gen : process (clk_24M)
		variable reset_cnt : integer := 999999;
	begin
		if rising_edge(clk_24M) then
			if reset_cnt > 0 then
				init <= '1';
				reset_cnt := reset_cnt - 1;
			else
				init <= '0';
			end if;
		end if;
	end process reset_gen;

  arst <= init;

  clockcore_inst : entity work.clockcore
    port map
    (
      inclk0		=> clk_24M,
      c0		    => clk_37M125,
      c1		    => clk_100M,
      c2		    => clk_40M
    );

  process (clk_37M125, rst)
    -- 3.375 * 11 = 37.125
    variable count : integer range 0 to 11-1;
  begin
    if rst = '1' then
      count := 0;
      clk_3M375_en <= '0';
    elsif rising_edge(clk_37M125) then
      clk_3M375_en <= '0';  -- default
      if count = count'high then
        clk_3M375_en <= '1';
        count := 0;
      else
        count := count + 1;
      end if;
    end if;
  end process;
  
  fpgabee_inst : entity work.FpgaBeeCore
    port map
    ( 
      clock_100_000       => clk_100M,
      clock_40_000        => clk_40M,
      clktb_3_375         => clk_37M125,
      clken_3_375         => clk_3M375_en,
      reset               => arst,
      monitor_key         => '0',
      show_status_panel   => '1',
      
      ram_addr            => ram_a,
      ram_rd_data         => ram_d_o,
      ram_wr_data         => ram_d_i,
      ram_wr              => ram_wr,
      ram_rd              => open,
      ram_wait            => '0',
      
      vga_red             => vao_red(vao_red'left downto vao_red'left-1),
      vga_green           => vao_green(vao_green'left downto vao_green'left-1),
      vga_blue            => vao_blue(vao_blue'left downto vao_blue'left-1),
      vga_hsync           => vao_hsync,
      vga_vsync           => vao_vsync,
      vga_pixel_x         => open,
      vga_pixel_y         => open,

      sd_sclk             => open,
      sd_mosi             => open,
      sd_miso             => '0',
      sd_ss_n             => open,

      ps2_keyboard_data   => ps2_dat,
      ps2_keyboard_clock  => ps2_clk,

      speaker             => open
    );

    	-- Access to 256K of off-chip RAM
	-- 
	-- 0x00000 - 0x1FFFF = 128K Main Microbee Memory (4 x 32K banks)
	-- 0x20000 - 0x23FFF - 16K Rom Pack 0 (maps to Microbee Z80 addr 0x8000)
	-- 0x24000 - 0x27FFF - 16K Rom Pack 1 (maps to Microbee Z80 addr 0xC000)
	-- 0x28000 - 0x2BFFF - 16K Rom Pack 2 (maps to Microbee Z80 addr 0xC000)
	-- 0x2C000 - 0x2FFFF - Unused
	-- 0x30000 - 0x3FFFF - 64K PCU ROM/RAM (maps to Microbee Z80 addr 0x0000 when in pcu_mode)

  -- memory MUX
  --          32KB @0x00000-0x07FFF
  ram_d_o <=  sram_d_o when ram_a(17 downto 15) = "000" else
  --          16KB @0x20000-0x23FFF (Basic 5.10) 
              rom_d_o when ram_a(17 downto 14) = "1000" else
              (others => '1');
  sram_wr <= ram_wr when ram_a(17 downto 15) = "000" else
              '0';
              
  sram_inst : entity work.spram
    generic map
    (
      numwords_a		=> 2**15,
      widthad_a			=> 15,
      width_a				=> 8
    )
    port map
    (
      clock		      => clk_37M125,
      address		    => ram_a(14 downto 0),
      data		      => ram_d_i,
      wren		      => sram_wr,
      q		          => sram_d_o
    );

  BLK_ROMS : block
    type rom_a is array (natural range <>) of string;
    constant MBEE_ROM   : rom_a(0 to 3) := 
                          (
                            0 => "bas510a.ic25", 
                            1 => "bas510b.ic27",
                            2 => "bas510c.ic28",
                            3 => "bas510d.ic30"
                          );
--    constant MBEE_ROM   : rom_a(0 to 1) := 
--                          (
--                            0 => "bas522a.rom", 
--                            1 => "bas522b.rom"
--                          );
    type rom_d_a is array (natural range <>) of std_logic_vector(7 downto 0);
    signal rom_device_d_o  : rom_d_a(MBEE_ROM'range);
  begin
    rom_d_o <=  rom_device_d_o(0) when ram_a(13 downto 12) = "00" else
                rom_device_d_o(1) when ram_a(13 downto 12) = "01" else
                rom_device_d_o(2) when ram_a(13 downto 12) = "10" else
                rom_device_d_o(3);
    GEN_ROM : for i in MBEE_ROM'range generate
    begin
      rom_inst : entity work.sprom
        generic map
        (
          init_file     => "../../../../../src/platform/fpgabee/roms/" & MBEE_ROM(i) & ".hex",
          widthad_a			=> 12,
          width_a				=> 8
        )
        port map
        (
          clock		      => clk_37M125,
          address		    => ram_a(11 downto 0),
          q		          => rom_device_d_o(i)
        );
      end generate GEN_ROM;
    end block BLK_ROMS;
    
--  -- inputs
--  process (clkrst_i)
--    variable kdat_r : std_logic_vector(2 downto 0);
--    variable mdat_r : std_logic_vector(2 downto 0);
--    variable kclk_r : std_logic_vector(2 downto 0);
--    variable mclk_r : std_logic_vector(2 downto 0);
--  begin
--    if clkrst_i.rst(0) = '1' then
--      kdat_r := (others => '0');
--      mdat_r := (others => '0');
--      kclk_r := (others => '0');
--      mclk_r := (others => '0');
--    elsif rising_edge(clkrst_i.clk(0)) then
--      kdat_r := kdat_r(kdat_r'left-1 downto 0) & vid_address(3);
--      mdat_r := mdat_r(mdat_r'left-1 downto 0) & vid_address(2);
--      kclk_r := kclk_r(kclk_r'left-1 downto 0) & vid_address(1);
--      mclk_r := mclk_r(mclk_r'left-1 downto 0) & vid_address(0);
--    end if;
--    inputs_i.ps2_kdat <= kdat_r(kdat_r'left);
--    inputs_i.ps2_mdat <= mdat_r(mdat_r'left);
--    inputs_i.ps2_kclk <= kclk_r(kclk_r'left);
--    inputs_i.ps2_mclk <= mclk_r(mclk_r'left);
--  end process;
  
  BLK_VIDEO : block
    type state_t is (IDLE, S1, S2, S3);
    signal state : state_t := IDLE;
  begin
  
--    -- DVI (digital) output
--    GEN_VDO_IDCK : if not S5AR2_DOUBLE_VDO_IDCK generate
--      vdo_idck <= video_o.clk;
--    end generate GEN_VDO_IDCK;
--    GEN_VDO_IDCKx2 : if S5AR2_DOUBLE_VDO_IDCK generate
--      vdo_idck <= vdo_clk_x2;
--    end generate GEN_VDO_IDCKx2;
--    vdo_red <= video_o.rgb.r(9 downto 2);
--    vdo_green <= video_o.rgb.g(9 downto 2);
--    vdo_blue <= video_o.rgb.b(9 downto 2);
--    vdo_hsync <= video_o.hsync;
--    vdo_vsync <= video_o.vsync;
--    vdo_de <= not (video_o.hblank or video_o.vblank);

    -- VGA (analogue) output
		vao_clk <= clk_40M;
		vao_red(vao_red'left-2 downto 0) <= (others => '0');
		vao_green(vao_green'left-2 downto 0) <= (others => '0');
		vao_blue(vao_blue'left-2 downto 0) <= (others => '0');
--    vao_hsync <= vga_hs;
--    vao_vsync <= vga_vs;
		vao_blank_n <= '1';
		vao_sync_t <= '0';

    -- configure the THS8135 video DAC
    process (clk_40M, arst)
      subtype count_t is integer range 0 to 9;
      variable count : count_t := 0;
    begin
      if arst = '1' then
        state <= IDLE;
        vao_sync_n <= '1';
        vao_m1 <= '0';
        vao_m2 <= '0';
      elsif rising_edge(clk_40M) then
        case state is
          when IDLE =>
            count := 0;
            state <= S1;
          when S1 =>
            vao_sync_n <= '0';
            vao_m1 <= '0';  -- BLNK_INT (full-range)
            vao_m2 <= '0';  -- sync insertion on 1?
            if count = count_t'high then
              count := 0;
              state <= S2;
            else
              count := count + 1;
            end if;
          when S2 =>
            vao_sync_n <= '1';
            -- RGB mode
            vao_m1 <= '0';
            vao_m2 <= '0';
            if count = count_t'high then
              state <= S3;
            else
              count := count + 1;
            end if;
          when S3 =>
            null;
        end case;
      end if;
    end process;
    
  end block BLK_VIDEO;
  
--  -- emulate some FLASH
--  GEN_FLASH : if false generate
--    flash_inst : entity work.sprom
--      generic map
--      (
--        init_file     => S5AR2_EMULATED_FLASH_INIT_FILE,
--        widthad_a			=> S5AR2_EMULATED_FLASH_WIDTH_AD,
--        width_a				=> S5AR2_EMULATED_FLASH_WIDTH
--      )
--      port map
--      (
--        clock		      => clkrst_i.clk(0),
--        address		    => flash_o.a(S5AR2_EMULATED_FLASH_WIDTH_AD-1 downto 0),
--        q		          => flash_i.d(S5AR2_EMULATED_FLASH_WIDTH-1 downto 0)
--      );
--    flash_i.d(flash_i.d'left downto S5AR2_EMULATED_FLASH_WIDTH) <= (others => '0');
--  end generate GEN_FLASH;
  
  BLK_CHASER : block
  begin
    -- flash the led so we know it's alive
    process (clk_24M, arst)
      variable count : std_logic_vector(21 downto 0);
    begin
      if arst = '1' then
        count := (others => '0');
      elsif rising_edge(clk_24M) then
        count := std_logic_vector(unsigned(count) + 1);
      end if;
      --vid_spare(8) <= count(count'left);
    end process;
  end block BLK_CHASER;

  --vid_data(7 downto 0) <= leds_o(7 downto 0);
  
  --vid_spare(31 downto 10) <= (others => 'Z');
  -- route the leds to the cyclone
  --vid_spare(9) <= '1';  -- don't care
  --vid_spare(7 downto 0) <= not leds_o(7 downto 0);
  
end;
