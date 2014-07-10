LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY pll IS
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
    CLK1_PHASE_SHIFT        : string := "0";
    
    -- CLK2
    CLK2_DIVIDE_BY          : natural := 1;
    CLK2_DUTY_CYCLE         : natural := 50;
    CLK2_MULTIPLY_BY        : natural := 1;
    CLK2_PHASE_SHIFT        : string := "0"
  );
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		c2		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END pll;


ARCHITECTURE SYN OF pll IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC ;
	SIGNAL sub_wire3	: STD_LOGIC ;
	SIGNAL sub_wire4	: STD_LOGIC ;
	SIGNAL sub_wire5	: STD_LOGIC ;
	SIGNAL sub_wire6	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL sub_wire7_bv	: BIT_VECTOR (0 DOWNTO 0);
	SIGNAL sub_wire7	: STD_LOGIC_VECTOR (0 DOWNTO 0);



	COMPONENT altpll
	GENERIC (
		bandwidth_type		: STRING;
		clk0_divide_by		: NATURAL;
		clk0_duty_cycle		: NATURAL;
		clk0_multiply_by		: NATURAL;
		clk0_phase_shift		: STRING;
		clk1_divide_by		: NATURAL;
		clk1_duty_cycle		: NATURAL;
		clk1_multiply_by		: NATURAL;
		clk1_phase_shift		: STRING;
		clk2_divide_by		: NATURAL;
		clk2_duty_cycle		: NATURAL;
		clk2_multiply_by		: NATURAL;
		clk2_phase_shift		: STRING;
		compensate_clock		: STRING;
		inclk0_input_frequency		: NATURAL;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		operation_mode		: STRING;
		pll_type		: STRING;
		port_activeclock		: STRING;
		port_areset		: STRING;
		port_clkbad0		: STRING;
		port_clkbad1		: STRING;
		port_clkloss		: STRING;
		port_clkswitch		: STRING;
		port_configupdate		: STRING;
		port_fbin		: STRING;
		port_inclk0		: STRING;
		port_inclk1		: STRING;
		port_locked		: STRING;
		port_pfdena		: STRING;
		port_phasecounterselect		: STRING;
		port_phasedone		: STRING;
		port_phasestep		: STRING;
		port_phaseupdown		: STRING;
		port_pllena		: STRING;
		port_scanaclr		: STRING;
		port_scanclk		: STRING;
		port_scanclkena		: STRING;
		port_scandata		: STRING;
		port_scandataout		: STRING;
		port_scandone		: STRING;
		port_scanread		: STRING;
		port_scanwrite		: STRING;
		port_clk0		: STRING;
		port_clk1		: STRING;
		port_clk2		: STRING;
		port_clk3		: STRING;
		port_clk4		: STRING;
		port_clk5		: STRING;
		port_clkena0		: STRING;
		port_clkena1		: STRING;
		port_clkena2		: STRING;
		port_clkena3		: STRING;
		port_clkena4		: STRING;
		port_clkena5		: STRING;
		port_extclk0		: STRING;
		port_extclk1		: STRING;
		port_extclk2		: STRING;
		port_extclk3		: STRING;
		self_reset_on_loss_lock		: STRING;
		width_clock		: NATURAL
	);
	PORT (
			inclk	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			locked	: OUT STD_LOGIC ;
			clk	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	sub_wire7_bv(0 DOWNTO 0) <= "0";
	sub_wire7    <= To_stdlogicvector(sub_wire7_bv);
	sub_wire3    <= sub_wire0(2);
	sub_wire2    <= sub_wire0(1);
	sub_wire1    <= sub_wire0(0);
	c0    <= sub_wire1;
	c1    <= sub_wire2;
	c2    <= sub_wire3;
	locked    <= sub_wire4;
	sub_wire5    <= inclk0;
	sub_wire6    <= sub_wire7(0 DOWNTO 0) & sub_wire5;

	altpll_component : altpll
	GENERIC MAP (
		bandwidth_type => "AUTO",
		clk0_divide_by => CLK1_DIVIDE_BY,
		clk0_duty_cycle => CLK1_DUTY_CYCLE,
		clk0_multiply_by => CLK1_MULTIPLY_BY,
		clk0_phase_shift => CLK1_PHASE_SHIFT,
		clk1_divide_by => CLK1_DIVIDE_BY,
		clk1_duty_cycle => CLK1_DUTY_CYCLE,
		clk1_multiply_by => CLK1_MULTIPLY_BY,
		clk1_phase_shift => "0",
		clk2_divide_by => CLK2_DIVIDE_BY,
		clk2_duty_cycle => CLK2_DUTY_CYCLE,
		clk2_multiply_by => CLK2_MULTIPLY_BY,
		clk2_phase_shift => CLK2_PHASE_SHIFT,
		compensate_clock => "CLK0",
		inclk0_input_frequency => INCLK0_INPUT_FREQUENCY,
		intended_device_family => "Cyclone III",
		lpm_hint => "CBX_MODULE_PREFIX=pll",
		lpm_type => "altpll",
		operation_mode => "NORMAL",
		pll_type => "AUTO",
		port_activeclock => "PORT_UNUSED",
		port_areset => "PORT_UNUSED",
		port_clkbad0 => "PORT_UNUSED",
		port_clkbad1 => "PORT_UNUSED",
		port_clkloss => "PORT_UNUSED",
		port_clkswitch => "PORT_UNUSED",
		port_configupdate => "PORT_UNUSED",
		port_fbin => "PORT_UNUSED",
		port_inclk0 => "PORT_USED",
		port_inclk1 => "PORT_UNUSED",
		port_locked => "PORT_USED",
		port_pfdena => "PORT_UNUSED",
		port_phasecounterselect => "PORT_UNUSED",
		port_phasedone => "PORT_UNUSED",
		port_phasestep => "PORT_UNUSED",
		port_phaseupdown => "PORT_UNUSED",
		port_pllena => "PORT_UNUSED",
		port_scanaclr => "PORT_UNUSED",
		port_scanclk => "PORT_UNUSED",
		port_scanclkena => "PORT_UNUSED",
		port_scandata => "PORT_UNUSED",
		port_scandataout => "PORT_UNUSED",
		port_scandone => "PORT_UNUSED",
		port_scanread => "PORT_UNUSED",
		port_scanwrite => "PORT_UNUSED",
		port_clk0 => "PORT_USED",
		port_clk1 => "PORT_USED",
		port_clk2 => "PORT_USED",
		port_clk3 => "PORT_UNUSED",
		port_clk4 => "PORT_UNUSED",
		port_clk5 => "PORT_UNUSED",
		port_clkena0 => "PORT_UNUSED",
		port_clkena1 => "PORT_UNUSED",
		port_clkena2 => "PORT_UNUSED",
		port_clkena3 => "PORT_UNUSED",
		port_clkena4 => "PORT_UNUSED",
		port_clkena5 => "PORT_UNUSED",
		port_extclk0 => "PORT_UNUSED",
		port_extclk1 => "PORT_UNUSED",
		port_extclk2 => "PORT_UNUSED",
		port_extclk3 => "PORT_UNUSED",
		self_reset_on_loss_lock => "OFF",
		width_clock => 5
	)
	PORT MAP (
		inclk => sub_wire6,
		clk => sub_wire0,
		locked => sub_wire4
	);



END SYN;
