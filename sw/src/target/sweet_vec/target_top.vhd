library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
	port
	(
    BUTTON                  : in    std_logic_vector(15 downto 1); -- active low
    SELF_TEST_SWITCH_L      : in		std_logic; 
    --
    AUDIO_OUT               : out   std_logic_vector(7 downto 0);
    --
    X_VECTOR                : out   std_logic_vector(9 downto 0);
    Y_VECTOR                : out   std_logic_vector(9 downto 0);
    Z_VECTOR                : out   std_logic_vector(3 downto 0);
    BEAM_ON                 : out   std_logic;
    BEAM_ENA                : out   std_logic;
    START1_LED_L		        : out 	std_logic;
    START2_LED_L		        : out	std_logic;
    --
    PROG_ROM_ADDR		        : out std_logic_vector(15 downto 0);
    PROG_ROM_DATA		        : in	std_logic_vector(7 downto 0);
     --
    RESET_6_L               : in    std_logic;
    CLK_6                   : in    std_logic
	);
end entity target_top;

architecture SYN of target_top is

  constant ONBOARD_CLOCK_SPEED  : integer := 6000000;

  -- reset signals
  signal init               : std_logic := '1';
	signal reset					    : std_logic := '1';
	signal reset_n            : STD_LOGIC := '0';
	--signal soft_reset_n		    : STD_LOGIC := '0';

  -- aliased clock pins
  alias clk_6M              : std_logic is clk_6;

  signal pll_locked         : std_logic := '0';
  
  -- clocks
  signal clkrst_i       : from_CLKRST_t;
  signal buttons_i    	: from_BUTTONS_t;
  signal switches_i   	: from_SWITCHES_t;
  signal leds_o         : to_LEDS_t;
  signal inputs_i       : from_INPUTS_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;

  signal ps2_kclk       : std_logic;
  signal ps2_kdat       : std_logic;
  signal ps2_mclk       : std_logic;
  signal ps2_mdat       : std_logic;

begin

	reset_gen : process (clk_6M)
		variable reset_cnt : integer := 999999;
	begin
		if rising_edge(clk_6M) then
			if reset_cnt > 0 then
				init <= '1';
				reset_cnt := reset_cnt - 1;
			else
				init <= '0';
			end if;
		end if;
	end process reset_gen;

  clkrst_i.arst <= init; -- or not vid_reset_n;
	clkrst_i.arst_n <= not clkrst_i.arst;
  -- for the EP4C-derived logic
  reset <= init;
  reset_n <= not reset;

  BLK_CLOCKING : block
  
  component pll is
    port (
      refclk   : in  std_logic := '0'; --  refclk.clk
      rst      : in  std_logic := '0'; --   reset.reset
      outclk_0 : out std_logic;        -- outclk0.clk
      outclk_1 : out std_logic;        -- outclk1.clk
      outclk_2 : out std_logic;        -- outclk2.clk
      locked   : out std_logic         --  locked.export
    );
  end component pll;

  begin

    clkrst_i.clk_ref <= clk_6M;
    
    GEN_PLL : if PACE_HAS_PLL generate
    
      pll_inst : pll
--        generic map
--        (
--          -- INCLK0
--          INCLK0_INPUT_FREQUENCY  => 41666,
--
--          -- CLK0
--          CLK0_DIVIDE_BY          => PACE_CLK0_DIVIDE_BY,
--          CLK0_MULTIPLY_BY        => PACE_CLK0_MULTIPLY_BY,
--      
--          -- CLK1
--          CLK1_DIVIDE_BY          => PACE_CLK1_DIVIDE_BY,
--          CLK1_MULTIPLY_BY        => PACE_CLK1_MULTIPLY_BY
--        )
        port map
        (
          refclk      => clk_6M,
          rst         => reset,
          outclk_0    => clkrst_i.clk(0),
          outclk_1    => clkrst_i.clk(1),
          outclk_2    => open,
          locked      => pll_locked
        );
    
    else generate

      -- feed input clocks into PACE core
      clkrst_i.clk(0) <= clk_6M;
      clkrst_i.clk(1) <= clk_6M;
        
    end generate GEN_PLL;

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
  process (clkrst_i)
    variable kdat_r : std_logic_vector(2 downto 0);
    variable mdat_r : std_logic_vector(2 downto 0);
    variable kclk_r : std_logic_vector(2 downto 0);
    variable mclk_r : std_logic_vector(2 downto 0);
  begin
    if clkrst_i.rst(0) = '1' then
      kdat_r := (others => '0');
      mdat_r := (others => '0');
      kclk_r := (others => '0');
      mclk_r := (others => '0');
    elsif rising_edge(clkrst_i.clk(0)) then
      kdat_r := kdat_r(kdat_r'left-1 downto 0) & ps2_kdat;
      mdat_r := mdat_r(mdat_r'left-1 downto 0) & ps2_mdat;
      kclk_r := kclk_r(kclk_r'left-1 downto 0) & ps2_kclk;
      mclk_r := mclk_r(mclk_r'left-1 downto 0) & ps2_mclk;
    end if;
    inputs_i.ps2_kdat <= kdat_r(kdat_r'left);
    inputs_i.ps2_mdat <= mdat_r(mdat_r'left);
    inputs_i.ps2_kclk <= kclk_r(kclk_r'left);
    inputs_i.ps2_mclk <= mclk_r(mclk_r'left);
  end process;
  
  BLK_JAMMA : block
  
  begin
  
    inputs_i.jamma_n.coin(1) <= '1';
    inputs_i.jamma_n.p(1).start <= '1';
    inputs_i.jamma_n.p(1).up <= '1';
    inputs_i.jamma_n.p(1).down <= '1';
    inputs_i.jamma_n.p(1).left <= '1';
    inputs_i.jamma_n.p(1).right <= '1';
    inputs_i.jamma_n.p(1).button(1) <= '1';
    inputs_i.jamma_n.p(1).button(2) <= '1';
    inputs_i.jamma_n.p(1).button(3) <= '1';
    inputs_i.jamma_n.p(1).button(4) <= '1';
    inputs_i.jamma_n.p(1).button(5) <= '1';
    
    inputs_i.jamma_n.coin(2) <= '1';
    inputs_i.jamma_n.p(2).start <= '1';
    inputs_i.jamma_n.p(2).up <= '1';
    inputs_i.jamma_n.p(2).down <= '1';
    inputs_i.jamma_n.p(2).left <= '1';
    inputs_i.jamma_n.p(2).right <= '1';
    inputs_i.jamma_n.p(2).button(1) <= '1';
    inputs_i.jamma_n.p(2).button(2) <= '1';
    inputs_i.jamma_n.p(2).button(3) <= '1';
    inputs_i.jamma_n.p(2).button(4) <= '1';
    inputs_i.jamma_n.p(2).button(5) <= '1';

    inputs_i.jamma_n.coin_cnt <= (others => '1');
    inputs_i.jamma_n.service <= '1';
    inputs_i.jamma_n.tilt <= '1';
    inputs_i.jamma_n.test <= '1';
    
  end block BLK_JAMMA;

  pace_inst : entity work.bwidow
    port map
    (
      reset_h             => reset,
      clk			            => clk_6M,
      analog_sound_out    => audio_out,
      analog_x_out        => x_vector,
      analog_y_out        => open,
      analog_z_out        => open,
      rgb_out             => open,
      buttons				      => button,
      
      ext_prog_rom_addr   => prog_rom_addr(14 downto 0),
      ext_prog_rom_data   => prog_rom_data,
      
      dbg				          => open
    );

    -- not used
    prog_rom_addr(15) <= '0';
    
end;
