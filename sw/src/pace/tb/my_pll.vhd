LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

entity pll is
  generic
  (
    -- INCLK
    INCLK0_INPUT_FREQUENCY  : natural;

    -- CLK0
    CLK0_DIVIDE_BY          : natural := 1;
    CLK0_DUTY_CYCLE         : natural := 50;
    CLK0_MULTIPLY_BY        : natural := 1;
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

	signal clk_20M	: std_logic := '0';
	signal clk_40M	: std_logic := '0';

BEGIN

	clk_20M <= not clk_20M after 12500 ps;
	clk_40M <= not clk_20M after  6250 ps;

	c0 <= clk_20M;
	c1 <= clk_40M;

END SYN;
