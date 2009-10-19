LIBRARY ieee;
USE ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity pll is
  generic
  (
    -- CLK0
    CLK0_DIVIDE_BY          : integer := 1;
    CLK0_MULTIPLY_BY        : natural := 1;
    CLK0_DUTY_CYCLE         : integer := 50;
    CLK0_PHASE_SHIFT        : string := "0";

    -- CLK1
    CLK1_DIVIDE_BY          : natural := 1;
    CLK1_MULTIPLY_BY        : natural := 1;
    CLK1_DUTY_CYCLE         : natural := 50;
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

   signal CLKIN_BUFG      : std_logic;
   signal CLKFX_0         : std_logic;
   signal CLKFX_1         : std_logic;

begin

  -- buffer from pin to DCM clock input
  CLKIN_BUFG_INST : BUFG
    port map (I=>inclk0, O=>CLKIN_BUFG);

  -- buffer from CLKFX output to FPGA logic
  CLKFX_0_BUFG_INST : BUFG
    port map (I=>CLKFX_0, O=>c0);
   
  -- buffer from CLKFX output to FPGA logic
  CLKFX_1_BUFG_INST : BUFG
    port map (I=>CLKFX_1, O=>c1);

   DCM_SP_0_inst : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE => CLK0_DIVIDE_BY,   --  Can be any interger from 1 to 32
      CLKFX_MULTIPLY => CLK0_MULTIPLY_BY, --  Can be any integer from 1 to 32
      CLKIN_DIVIDE_BY_2 => FALSE, --  TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD => 69.841, --  Specify period of input clock
      CLKOUT_PHASE_SHIFT => "NONE", --  Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
      CLK_FEEDBACK => "NONE",         --  Specify clock feedback of "NONE", "1X" or "2X" 
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                             --     an integer from 0 to 15
      DFS_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for 
                                       -- frequency synthesis
      DLL_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for DLL
      DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
      FACTORY_JF => X"C080",          --  FACTORY JF Values
      PHASE_SHIFT => 0,        --  Amount of fixed phase shift from -255 to 255
      STARTUP_WAIT => FALSE) --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
   port map (
      --CLK0 => CLK0,     -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180, -- 180 degree DCM CLK output
      --CLK270 => CLK270, -- 270 degree DCM CLK output
      --CLK2X => CLK2X,   -- 2X DCM CLK output
      --CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,   -- 90 degree DCM CLK output
      --CLKDV => CLKDV,   -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX => CLKFX_0,   -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
      --LOCKED => LOCKED, -- DCM LOCK status output
      --PSDONE => PSDONE, -- Dynamic phase adjust done output
      --STATUS => STATUS, -- 8-bit DCM status bits output
      --CLKFB => CLKFB,   -- DCM clock feedback
      CLKIN => CLKIN_BUFG   -- Clock input (from IBUFG, BUFG or DCM)
      --PSCLK => PSCLK,   -- Dynamic phase adjust clock input
      --PSEN => PSEN,     -- Dynamic phase adjust enable input
      --PSINCDEC => PSINCDEC, -- Dynamic phase adjust increment/decrement
      --RST => RST        -- DCM asynchronous reset input
   );

   DCM_SP_1_inst : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE => CLK1_DIVIDE_BY,   --  Can be any interger from 1 to 32
      CLKFX_MULTIPLY => CLK1_MULTIPLY_BY, --  Can be any integer from 1 to 32
      CLKIN_DIVIDE_BY_2 => FALSE, --  TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD => 69.841, --  Specify period of input clock
      CLKOUT_PHASE_SHIFT => "NONE", --  Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
      CLK_FEEDBACK => "NONE",         --  Specify clock feedback of "NONE", "1X" or "2X" 
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                             --     an integer from 0 to 15
      DFS_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for 
                                       -- frequency synthesis
      DLL_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for DLL
      DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
      FACTORY_JF => X"C080",          --  FACTORY JF Values
      PHASE_SHIFT => 0,        --  Amount of fixed phase shift from -255 to 255
      STARTUP_WAIT => FALSE) --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
   port map (
      --CLK0 => CLK0,     -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180, -- 180 degree DCM CLK output
      --CLK270 => CLK270, -- 270 degree DCM CLK output
      --CLK2X => CLK2X,   -- 2X DCM CLK output
      --CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,   -- 90 degree DCM CLK output
      --CLKDV => CLKDV,   -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX => CLKFX_1,   -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
      --LOCKED => LOCKED, -- DCM LOCK status output
      --PSDONE => PSDONE, -- Dynamic phase adjust done output
      --STATUS => STATUS, -- 8-bit DCM status bits output
      --CLKFB => CLKFB,   -- DCM clock feedback
      CLKIN => CLKIN_BUFG   -- Clock input (from IBUFG, BUFG or DCM)
      --PSCLK => PSCLK,   -- Dynamic phase adjust clock input
      --PSEN => PSEN,     -- Dynamic phase adjust enable input
      --PSINCDEC => PSINCDEC, -- Dynamic phase adjust increment/decrement
      --RST => RST        -- DCM asynchronous reset input
   );

END SYN;
