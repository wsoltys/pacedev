library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use	ieee.numeric_std.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.platform_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
    clk         		: in std_logic_vector(0 to 3);
    reset           : in    std_logic;                       
    test_button     : in    std_logic;                       

    -- inputs
    ps2clk          : inout std_logic;                       
    ps2data         : inout std_logic;                       
    dip             : in    std_logic_vector(7 downto 0);    

    -- micro buses
    upaddr          : out   std_logic_vector(15 downto 0);   
    updatao         : out   std_logic_vector(7 downto 0);    

    -- SRAM
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    gfxextra_data   : out std_logic_vector(7 downto 0);

    -- graphics (control)
    red							: out		std_logic_vector(7 downto 0);
		green						: out		std_logic_vector(7 downto 0);
		blue						: out		std_logic_vector(7 downto 0);
		hsync						: out		std_logic;
		vsync						: out		std_logic;

    cvbs            : out   std_logic_vector(7 downto 0);
			  
    -- sound
    snd_rd          : out   std_logic;                       
    snd_wr          : out   std_logic;
    sndif_datai     : in    std_logic_vector(7 downto 0);    

    -- spi interface
    spi_clk         : out   std_logic;                       
    spi_din         : in    std_logic;                       
    spi_dout        : out   std_logic;                       
    spi_ena         : out   std_logic;                       
    spi_mode        : out   std_logic;                       
    spi_sel         : out   std_logic;                       

    -- serial
    ser_rx          : in    std_logic;                       
    ser_tx          : out   std_logic;                       

    -- on-board leds
    leds            : out   std_logic_vector(7 downto 0)    
  );

end Game;

architecture SYN of Game is

  --
  -- COMPONENTS
  --

  component crtc6845s is
    port
    (
      -- INPUT
      I_E         : in std_logic;
      I_DI        : in std_logic_vector(7 downto 0);
      I_RS        : in std_logic;
      I_RWn       : in std_logic;
      I_CSn       : in std_logic;
      I_CLK       : in std_logic;
      I_RSTn      : in std_logic;

      -- OUTPUT
      O_RA        : out std_logic_vector(4 downto 0);
      O_MA        : out std_logic_vector(13 downto 0);
      O_H_SYNC    : out std_logic;
      O_V_SYNC    : out std_logic;
      O_DISPTMG   : out std_logic
    );
  end component crtc6845s;

  --
  -- SIGNALS
  --

  signal reset_n            : std_logic;

  alias clk_16M             : std_logic is clk(0);
  signal clk_8M_en          : std_logic;
  signal clk_4M_en          : std_logic;
  signal clk_2M_en          : std_logic;  -- CPU
  signal clk_1M_en          : std_logic;  -- SAA5050

  -- CPU signals
	alias cpu_clk_en					: std_logic is clk_2M_en;
	signal cpu_a_ext					: std_logic_vector(23 downto 0);
	alias cpu_a								: std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i            : std_logic_vector(7 downto 0);
  signal cpu_d_o            : std_logic_vector(7 downto 0);
	signal cpu_rw_n						: std_logic;

  -- VULA signals
  signal videoula_cs_n      : std_logic;
  
  -- CRTC6845 signals
  signal crtc6845_cs_n      : std_logic;
  signal crtc6845_rs        : std_logic;
  signal crtc6845_e         : std_logic;
  signal crtc6845_rw_n      : std_logic;
  signal crtc6845_disptmg   : std_logic;

	signal video_ram_a				: std_logic_vector(14 downto 0);
	signal video_ram_d				: std_logic_vector(7 downto 0);

  -- System 6522 VIA $40-$4F
  signal sysVIA_PB    : std_logic_vector(7 downto 0);
  alias c             : std_logic_vector(1 downto 0) is sysVIA_PB(5 downto 4);

begin

  reset_n <= not reset;

  -- unused outputs
  gfxextra_data <= (others => '0');
  cvbs <= (others => '0');
  snd_rd <= '0';
  snd_wr <= '0';
  spi_clk <= '0';
  spi_dout <= '0';
  spi_ena <= '0';
  spi_mode <= '0';
  spi_sel <= '0';
  ser_tx <= '0';
  leds <= (others => '0');

  --
  --  COMPONENT INSTANTIATION
  --

  BLK_VIDEO : block

    -- CRTC6545 signals
    signal crtc6845_clk   : std_logic;
	  signal crtc6845_ra    : std_logic_vector(4 downto 0);
	  signal crtc6845_ma    : std_logic_vector(13 downto 0);
    signal crtc6845_hsync : std_logic;
    signal crtc6845_vsync : std_logic;

    -- SAA5050 signals
    signal saa5050_dew    : std_logic;
    signal saa5050_de     : std_logic;

    signal video_ULA_de   : std_logic;
		signal video_r				: std_logic_vector(0 downto 0);
		signal video_g				: std_logic_vector(0 downto 0);
		signal video_b				: std_logic_vector(0 downto 0);

  begin

    BLK_VIDEO_ULA : block

			signal control_r		: std_logic_vector(7 downto 0);
			alias flash_r				: std_logic is control_r(0);
			alias teletext_r		: std_logic is control_r(1);
			alias cpl_r					: std_logic_vector(1 downto 0) is control_r(3 downto 2);	-- 10/20/40/80
			alias clk_rate_r		: std_logic is control_r(4);                              -- 1/2MHz
			alias cursor_w_r		: std_logic_vector(1 downto 0) is control_r(6 downto 5);	-- 1/NA/2/4
			alias m_cursor_w_r	: std_logic is control_r(7);

			signal palette_r		: std_logic_vector(7 downto 0);
			alias log_clr_r			: std_logic_vector(3 downto 0) is palette_r(7 downto 4);
			alias act_clr_r			: std_logic_vector(3 downto 0) is palette_r(3 downto 0);

    begin

      -- clock generation - phase-aligned
      process (clk_16M, reset)
        variable count : std_logic_vector(3 downto 0);
      begin
        if reset = '1' then
          count := (others => '0');
        elsif rising_edge(clk_16M) then
          clk_8M_en <= '0';
          clk_4M_en <= '0';
          clk_2M_en <= '0';
          clk_1M_en <= '0';
          if count(0) = '0' then
            clk_8M_en <= '1';
            if count(1) = '0' then
              clk_4M_en <= '1';
              if count(2) = '0' then
                clk_2M_en <= '1';
                if count(3) = '0' then
                  clk_1M_en <= '1';
                end if;
              end if;
            end if;
          end if;
          count := count + 1;
        end if;
      end process;

      -- registers
      process (clk_16M, reset)
      begin
        if reset = '1' then
					-- MODE 6
					control_r <= X"88"; --(others => '0');
					palette_r <= (others => '0');
        elsif rising_edge(clk_16M) then
					if cpu_clk_en = '1' then
						if cpu_rw_n = '1' then
							case cpu_a(0) is
								when '0' =>
									control_r <= cpu_d_o;
								when others =>
									palette_r <= cpu_d_o;
							end case;
						end if;
					end if;
        end if;
      end process;

			-- de-serialiser
			process (clk_16M, reset)
				variable video_data : std_logic_vector(7 downto 0) := (others => '0');
			begin
				if reset = '1' then
					video_data := (others => '0');
				elsif rising_edge(clk_16M) then
					if clk_1M_en = '1' then
						-- latch data
						video_data := video_ram_d;
					elsif clk_8M_en = '1' then
						-- rotate
						video_data := video_data(6 downto 0) & '0';
					end if;
				end if;
				-- assign RGB outputs
				video_r(video_r'left) <= video_data(video_data'left);
				video_g(video_g'left) <= video_data(video_data'left);
				video_b(video_b'left) <= video_data(video_data'left);
			end process;

      -- the CRTC6845 implementation is not synchronous!!!
      crtc6845_clk <= clk_1M_en when clk_rate_r = '0' else clk_2M_en;

    end block BLK_VIDEO_ULA;

    crtc6845s_inst : crtc6845s
      port map
      (
        -- INPUT
        I_E         => crtc6845_e,
        I_DI        => cpu_d_o,
        I_RS        => crtc6845_rs,
        I_RWn       => crtc6845_rw_n,
        I_CSn       => crtc6845_cs_n,
        I_CLK       => crtc6845_clk,
        I_RSTn      => reset_n,

        -- OUTPUT
        O_RA        => crtc6845_ra,
        O_MA        => crtc6845_ma,
        O_H_SYNC    => crtc6845_hsync,
        O_V_SYNC    => crtc6845_vsync,
        O_DISPTMG   => crtc6845_disptmg
      );

    -- enable output of the video ULA
    video_ULA_de <= crtc6845_disptmg and not crtc6845_ra(3);

    BLK_VIDADDR : block

      signal b  : std_logic_vector(4 downto 1);
      signal s  : std_logic_vector(4 downto 1);

    begin
      -- fudge
      c <= "01"; -- mode 6

      -- IC36/40/27
      b(1) <= not (c(0) and c(1) and crtc6845_ma(12));
      b(2) <= not (c(1) and b(3) and crtc6845_ma(12));
      b(3) <= c(0) nand crtc6845_ma(12);
      b(4) <= b(3) nand crtc6845_ma(12);

      -- IC39 (74LS283)
      s <= crtc6845_ma(11 downto 8) + b + 1;

      -- MA13=0 (hires), MA13=1 (teletext)
      video_ram_a <=  s(4) & "1111" & crtc6845_ma(9 downto 0) when crtc6845_ma(13) = '1' else
                      s & crtc6845_ma(7 downto 0) & crtc6845_ra(2 downto 0);

    end block BLK_VIDADDR;

    saa505x_inst : entity work.saa505x
      port map
      (
        clk				=> clk(0),
        reset			=> reset,

        si_i_n		=> '0',               -- hard-wired text mode
        si_o			=> open,              -- not used
        data_n		=> '0',               -- not used
        d					=> (others => '0'),
        dlim			=> '0',               -- not used
        glr				=> '0',               -- not used
        dew				=> saa5050_dew,
        crs				=> '0',
        bcs_n			=> '1',
        tlc_n			=> open,
        tr6				=> '0',
        f1				=> '0',
        y					=> open,
        b					=> open,
        g					=> open,
        r					=> open,
        blan			=> open,
        lose			=> '0',
        po				=> '0',
        de				=> saa5050_de
      );

    -- drive VGA outputs
    -- fudge for now
    hsync <= not crtc6845_hsync;
    vsync <= not crtc6845_vsync;
    red <= (others => video_r(video_r'left)) when video_ULA_de = '1' else (others => '0');
    green <= (others => video_g(video_g'left)) when video_ULA_de = '1' else (others => '0');
    blue <= (others => video_b(video_b'left)) when video_ULA_de = '1' else (others => '0');

  end block BLK_VIDEO;

	-- this is a fudge for now...
	dram_inst : entity work.dram
		port map
		(
			clock				=> clk_16M,
			address			=> video_ram_a(12 downto 0),
			data				=> cpu_d_o,
			wren				=> '0',
			q						=> video_ram_d
		);
		
end SYN;
