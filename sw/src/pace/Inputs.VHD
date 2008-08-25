Library IEEE;
Use     IEEE.std_logic_1164.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;

entity Inputs is
	generic
	(
		NUM_INPUTS 			: positive := 2;
		CLK_1US_DIV			: natural := 30
	);
  port
  (
    clk     : in std_logic;                               
    reset   : in std_logic;                               
    ps2clk  : in std_logic;                               
    ps2data : in std_logic;                               
		jamma		: in from_JAMMA_t;
		
		dips		: in		std_logic_vector(7 downto 0);
		inputs	: out		in8(0 to NUM_INPUTS-1)
  );
end Inputs;

architecture SYN of Inputs is

  component ps2kbd                                          
    port
    (
      clk      : in  std_logic;                            
      rst_n    : in  std_logic;                            
      tick1us  : in  std_logic;
      ps2_clk  : in  std_logic;                            
      ps2_data : in  std_logic;                            

      reset    : out std_logic;                            
      press    : out std_logic;                            
      release  : out std_logic;                            
      scancode : out std_logic_vector(7 downto 0)
    );
  end component;

  signal reset_n        : std_logic;
  signal tick_1us       : std_logic;
  signal ps2_reset      : std_logic;
  signal ps2_press      : std_logic;
  signal ps2_release    : std_logic;
  signal ps2_scancode   : std_logic_vector(7 downto 0);
    
begin

  reset_n <= not reset;

--  ps2clk <= 'Z';
--  ps2data <= 'Z';
    
  ps2kbd_inst : ps2kbd                                        
    port map
    (
      clk      => clk,                                     
      rst_n    => reset_n,
      tick1us  => tick_1us,
      ps2_clk  => ps2clk,
      ps2_data => ps2data,
			
      reset    => ps2_reset,
      press    => ps2_press,
      release  => ps2_release,
      scancode => ps2_scancode
    );

  inputmapper_inst : entity work.inputmapper
		generic map
		(
			NUM_INPUTS	=> NUM_INPUTS
		)
    port map
    (
      clk     => clk,
      rst_n   => reset_n,

      reset   => ps2_reset,
      press   => ps2_press,
      release => ps2_release,
      data    => ps2_scancode,
			jamma		=> jamma,
			
			dips		=> dips,
      inputs	=> inputs
    );

    process (clk, reset)
      variable count : integer range 0 to CLK_1US_DIV := 0;
    begin
      if reset = '1' then
        count := 0;
        tick_1us <= '0';
      elsif rising_edge(clk) then
        tick_1us <= '0';
        count := count + 1;
        if count = CLK_1US_DIV then
          count := 0;
          tick_1us <= '1';
         end if;
      end if;
    end process;
    
end SYN;
