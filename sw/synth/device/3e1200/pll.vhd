LIBRARY ieee;
USE ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity pll is
  generic
  (
    -- INCLK
    INCLK0_INPUT_FREQUENCY  : natural;

    -- CLK0
    CLK0_DIVIDE_BY          : real := 2.0;
    CLK0_DUTY_CYCLE         : natural := 50;
    CLK0_PHASE_SHIFT        : string := "0";

    -- CLK1
    CLK1_DIVIDE_BY          : natural := 1;
    CLK1_DUTY_CYCLE         : natural := 50;
    CLK1_MULTIPLY_BY        : natural := 1;
    CLK1_PHASE_SHIFT        : string := "0"
  );
	port
	(
		inclk0		: in std_logic  := '0';
		c0		    : out std_logic ;
		c1		    : out std_logic 
	);
END pll;

ARCHITECTURE SYN OF pll IS

   signal CLKDV_BUF       : std_logic;
   signal CLKFB_IN        : std_logic;
   signal CLKFX_BUF       : std_logic;
   signal CLKIN_IBUFG     : std_logic;
   signal CLK0_BUF        : std_logic;
   signal GND1            : std_logic;

	-- for compatibility
	alias CLKIN_IN					: std_logic is inclk0;
	alias CLKDV_OUT					: std_logic is c0;
	alias CLKFX_OUT					: std_logic is c1;
	signal CLKIN_IBUFG_OUT	: std_logic;
	signal CLK0_OUT					: std_logic;
	signal LOCKED_OUT				: std_logic;

begin

   GND1 <= '0';
   CLKIN_IBUFG_OUT <= CLKIN_IBUFG;
   CLK0_OUT <= CLKFB_IN;
   CLKDV_BUFG_INST : BUFG
      port map (I=>CLKDV_BUF,
                O=>CLKDV_OUT);
   
   CLKFX_BUFG_INST : BUFG
      port map (I=>CLKFX_BUF,
                O=>CLKFX_OUT);
   
   CLKIN_IBUFG_INST : IBUFG
      port map (I=>CLKIN_IN,
                O=>CLKIN_IBUFG);
   
   CLK0_BUFG_INST : BUFG
      port map (I=>CLK0_BUF,
                O=>CLKFB_IN);
   
   DCM_INST : DCM
   generic map( CLK_FEEDBACK => "1X",
            CLKDV_DIVIDE => CLK0_DIVIDE_BY,
            CLKFX_DIVIDE => CLK1_DIVIDE_BY,
            CLKFX_MULTIPLY => CLK1_MULTIPLY_BY,
            CLKIN_DIVIDE_BY_2 => FALSE,
            CLKIN_PERIOD => 20.000,
            CLKOUT_PHASE_SHIFT => "NONE",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            DFS_FREQUENCY_MODE => "LOW",
            DLL_FREQUENCY_MODE => "LOW",
            DUTY_CYCLE_CORRECTION => TRUE,
            FACTORY_JF => x"8080",
            PHASE_SHIFT => 0,
            STARTUP_WAIT => FALSE)
      port map (CLKFB=>CLKFB_IN,
                CLKIN=>CLKIN_IBUFG,
                DSSEN=>GND1,
                PSCLK=>GND1,
                PSEN=>GND1,
                PSINCDEC=>GND1,
                RST=>GND1,
                CLKDV=>CLKDV_BUF,
                CLKFX=>CLKFX_BUF,
                CLKFX180=>open,
                CLK0=>CLK0_BUF,
                CLK2X=>open,
                CLK2X180=>open,
                CLK90=>open,
                CLK180=>open,
                CLK270=>open,
                LOCKED=>LOCKED_OUT,
                PSDONE=>open,
                STATUS=>open);

END SYN;
