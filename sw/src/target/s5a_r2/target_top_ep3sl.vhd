library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top_ep3sl is
	port
	(
		ddr64_odt : out std_logic_vector(0 downto 0);
		--ddr64_clk : inout std_logic_vector(1 downto 0);
		--ddr64_clk_n : inout std_logic_vector(1 downto 0);
		ddr64_cs_n : out std_logic_vector(0 downto 0);
		ddr64_cke : out std_logic_vector(0 downto 0);
		ddr64_a : out std_logic_vector(13 downto 0);
		ddr64_ba : out std_logic_vector(2 downto 0);
		ddr64_ras_n : out std_logic;
		ddr64_cas_n : out std_logic;
		ddr64_we_n : out std_logic;
		ddr64_dq : inout std_logic_vector(63 downto 0);
		--ddr64_dqs : inout std_logic_vector(7 downto 0);
		--ddr64_dqsn : out std_logic_vector(7 downto 0);
		ddr64_dm : out std_logic_vector(7 downto 0);
		ddr64_reset_n : out std_logic;

    -- DVI output, 1V5 I/O 1 pix/clk, 24-bit mode
		vdo_red			: out std_logic_vector(7 downto 0);
		vdo_green		: out std_logic_vector(7 downto 0);
		vdo_blue		: out std_logic_vector(7 downto 0);
		vdo_idck		: out std_logic;
		vdo_hsync		: out std_logic;
		vdo_vsync		: out std_logic;
		vdo_de			: out std_logic;

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
		vai_resetb_n	: in std_logic;
		vai_coast			: in std_logic;
		--vai_scl				: inout std_logic;
		--vai_sda				: inout std_logic;

	-- I2C to the Cyclone
		vid_scl			: inout std_logic;
		vid_sda			: inout std_logic;

    -- SDVO to LVDS input, dual 4 channel x 7 
		vsi_clk			: in std_logic_vector(1 downto 0);
		vsi_data		: in std_logic_vector(7 downto 0);
		vsi_enavdd	: in std_logic;
		vsi_enabkl	: in std_logic;
		
		vlo_clk			: out std_logic;
		vlo_data		: out std_logic_vector(2 downto 0);

	-- VGA output, 1 pix/clk, 30-bit mode
		vao_clk	  	: out std_logic;
		vao_red			: out std_logic_vector(9 downto 0);
		vao_green		: out std_logic_vector(9 downto 0);
		vao_blue		: out std_logic_vector(9 downto 0);
		vao_hsync   : out std_logic;
		vao_vsync   : out std_logic;
		vao_blank_n : out std_logic;
		vao_sync_n	: out std_logic;
		vao_sync_t	: out std_logic;
		vao_m1			: out std_logic;
		vao_m2			: out std_logic;

	-- Connection to video FPGA
		vid_address			: in std_logic_vector(10 downto 0);
		vid_data				: inout std_logic_vector(15 downto 0);
		vid_write_n			: in std_logic;
		vid_read_n			: in std_logic;
		vid_waitrequest	: out std_logic;
		vid_irq_n				: out std_logic;
		vid_clk					: in std_logic;

		vid_spare		: inout std_logic_vector(31 downto 0);
		vid_sp_clk	: in std_logic;

		clk24_b			: in std_logic;
		veb_ck_b		: in std_logic;

		clk24_c			: in std_logic;
		veb_ck_c		: in std_logic;

		clk24_d			: in std_logic;
		veb_ck_d		: in std_logic

--		ddr_clk			: in std_logic;
	);

end entity target_top_ep3sl;

architecture SYN of target_top_ep3sl is

  constant ONBOARD_CLOCK_SPEED  : integer := 24576000;

  signal init         : std_logic := '1';
  signal reset        : std_logic := '1';
  signal reset_n      : std_logic := '0';
  alias clk_24M       : std_logic is clk24_d;
  
  signal clk_108M     : std_logic := '0';
  signal vip_clk      : std_logic := '0';
  signal vdo_clk      : std_logic := '0';
  
  signal pll_locked     : std_logic := '0';
    
  signal clkrst_i       : from_CLKRST_t;
  signal buttons_i    	: from_BUTTONS_t;
  signal switches_i   	: from_SWITCHES_t;
  signal leds_o         : to_LEDS_t;
  signal inputs_i       : from_INPUTS_t;
  signal flash_i        : from_FLASH_t;
  signal flash_o        : to_FLASH_t;
	signal sram_i			    : from_SRAM_t;
	signal sram_o			    : to_SRAM_t;	
	signal sdram_i        : from_SDRAM_t;
	signal sdram_o        : to_SDRAM_t;
	signal video_i        : from_VIDEO_t;
  signal video_o        : to_VIDEO_t;
  signal audio_i        : from_AUDIO_t;
  signal audio_o        : to_AUDIO_t;
  signal ser_i          : from_SERIAL_t;
  signal ser_o          : to_SERIAL_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;

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

  clkrst_i.arst <= init;
	clkrst_i.arst_n <= not reset;

  BLK_CLOCKING : block
  begin
  
    pll_inst : entity work.ep3sl_pll
      port map
      (
        inclk0  => clk_24M,
        c0      => open,              -- 108MHz
        c1      => clkrst_i.clk(1),   -- 108MHz
        c2      => clkrst_i.clk(0),   -- 40MHz
        locked  => pll_locked
      );

    --vo_idck_n <= '0';

  end block BLK_CLOCKING;

  GEN_RESETS : for i in 0 to 3 generate

    process (clkrst_i.clk(i), clkrst_i.arst)
      variable rst_r : std_logic_vector(2 downto 0) := (others => '0');
    begin
      if clkrst_i.arst = '1' then
        rst_r := (others => '1');
      elsif rising_edge(clkrst_i.clk(i)) then
        rst_r := rst_r(rst_r'left-1 downto 0) & '0';
      end if;
      clkrst_i.rst(i) <= rst_r(rst_r'left);
    end process;

  end generate GEN_RESETS;
	
  -- buttons
  buttons_i <= std_logic_vector(to_unsigned(0, buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(to_unsigned(0, switches_i'length));
  -- leds
  --ledout <= leds_o(0);
  
  -- inputs
  inputs_i.ps2_kclk <= '1';
  inputs_i.ps2_kdat <= '1';
  inputs_i.ps2_mclk <= '1';
  inputs_i.ps2_mdat <= '1';

  GEN_JAMMA : for i in 1 to 2 generate
    inputs_i.jamma_n.coin(i) <= '1';
    inputs_i.jamma_n.p(i).start <= '1';
    inputs_i.jamma_n.p(i).up <= '1';
    inputs_i.jamma_n.p(i).down <= '1';
    inputs_i.jamma_n.p(i).left <= '1';
    inputs_i.jamma_n.p(i).right <= '1';
    inputs_i.jamma_n.p(i).button <= (others => '1');
  end generate GEN_JAMMA;

  inputs_i.jamma_n.coin_cnt <= (others => '1');
  inputs_i.jamma_n.service <= '1';
  inputs_i.jamma_n.tilt <= '1';
  inputs_i.jamma_n.test <= '1';
  
  inputs_i.analogue <= (others => (others => '0'));

  BLK_VIDEO : block
    type state_t is (IDLE, S1, S2, S3);
    signal state : state_t := IDLE;
  begin
  
    video_i.clk <= clkrst_i.clk(1);
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.rst(1);

    -- DVI (digital) output
    vdo_idck <= video_o.clk;
    vdo_red <= video_o.rgb.r(9 downto 2);
    vdo_green <= video_o.rgb.g(9 downto 2);
    vdo_blue <= video_o.rgb.b(9 downto 2);
    vdo_hsync <= video_o.hsync;
    vdo_vsync <= video_o.vsync;
    vdo_de <= not (video_o.hblank or video_o.vblank);

    -- VGA (analogue) output
		vao_clk <= video_o.clk;
		vao_red <= video_o.rgb.r;
		vao_green <= video_o.rgb.g;
		vao_blue <= video_o.rgb.b;
    vao_hsync <= video_o.hsync;
    vao_vsync <= video_o.vsync;
		vao_blank_n <= '1';
		vao_sync_t <= '0';

    -- configure the THS8135 video DAC
    process (video_o.clk, reset)
      subtype count_t is integer range 0 to 9;
      variable count : count_t := 0;
    begin
      if reset = '1' then
        state <= IDLE;
        vao_sync_n <= '1';
        vao_m1 <= '0';
        vao_m2 <= '0';
      elsif rising_edge(video_o.clk) then
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
  
  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clk_i							=> clkrst_i.clk,
      reset_i          	=> clkrst_i.rst,

      -- misc inputs and outputs
      buttons_i         => buttons_i,
      switches_i        => switches_i,
      leds_o            => leds_o,
      
      -- controller inputs
      inputs_i          => inputs_i,

     	-- external ROM/RAM
     	flash_i           => flash_i,
      flash_o           => flash_o,
      sram_i        		=> sram_i,
      sram_o        		=> sram_o,
     	sdram_i           => sdram_i,
     	sdram_o           => sdram_o,
  
      -- VGA video
      video_i           => video_i,
      video_o           => video_o,
      
      -- sound
      audio_i           => audio_i,
      audio_o           => audio_o,

      -- SPI (flash)
      spi_i.din         => '0',
      spi_o             => open,
  
      -- serial
      ser_i             => ser_i,
      ser_o             => ser_o,
      
      -- custom i/o
      project_i         => project_i,
      project_o         => project_o,
      platform_i        => platform_i,
      platform_o        => platform_o,
      target_i          => target_i,
      target_o          => target_o
    );

  vid_spare <= (others => 'Z');
  
end;
