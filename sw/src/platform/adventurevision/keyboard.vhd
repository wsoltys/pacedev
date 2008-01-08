library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.kbd_pkg.all;

entity avKeyboard is
port
(
    clk       	: in     std_logic;
    reset     	: in     std_logic;

		-- inputs from PS/2 port
    ps2_clk  		: inout  std_logic;                            
    ps2_data 		: inout  std_logic;                            

    -- user outputs
		inputs			: out		 std_logic_vector(7 downto 0)
);
end avKeyboard;

architecture SYN of avKeyboard is

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

  signal rst_n			: std_logic;

  -- 1us tick for PS/2 interface
  signal tick1us		: std_logic;

  signal ps2_reset      : std_logic;
  signal ps2_press      : std_logic;
  signal ps2_release    : std_logic;
  signal ps2_scancode   : std_logic_vector(7 downto 0);

begin

	rst_n <= not reset;
	
	-- produce a 1us tick from the 20MHz ref clock
  process (clk, reset)
		variable count : integer range 0 to 19;
	begin
	  if reset = '1' then
			tick1us <= '0';
			count := 0;
	  elsif rising_edge (clk) then
			if count = 19 then
		  	tick1us <= '1';
		  	count := 0;
			else
		  	tick1us <= '0';
		  	count := count + 1;
			end if;
	  end if;
	end process;
	
    latchInputs: process (clk, rst_n)

    begin

         -- note: all inputs are active LOW

        if rst_n = '0' then
           inputs <= (others => '1');
        elsif rising_edge (clk) then
          if (ps2_press or ps2_release) = '1' then
               case ps2_scancode is

										when SCANCODE_Z =>
                         inputs(0) <= not ps2_press;
                    when SCANCODE_X =>
                         inputs(1) <= not ps2_press;
                    when SCANCODE_C =>
                         inputs(2) <= not ps2_press;
                    when SCANCODE_V =>
                         inputs(3) <= not ps2_press;
                    when SCANCODE_LEFT =>
                         inputs(4) <= not ps2_press;
                    when SCANCODE_RIGHT =>
                         inputs(5) <= not ps2_press;
                    when SCANCODE_UP =>
                         inputs(6) <= not ps2_press;
                    when SCANCODE_DOWN =>
                         inputs(7) <= not ps2_press;

                    when others =>
               end case;
            end if; -- ps2_press or release
            if (ps2_reset = '1') then
               inputs <= (others => '1');
            end if;
        end if; -- rising_edge (clk)
    end process latchInputs;

  ps2kbd_inst : ps2kbd                                        
    port map
    (
      clk      	=> clk,                                     
      rst_n    	=> rst_n,
      tick1us  	=> tick1us,
      ps2_clk  	=> ps2_clk,
      ps2_data 	=> ps2_data,

      reset    	=> ps2_reset,
      press 	=> ps2_press,
      release  	=> ps2_release,
      scancode 	=> ps2_scancode
    );

end SYN;
