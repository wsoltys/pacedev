library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package pkg_vic20_xilinx_prims is

	component RAMB4_S4 is
	  port 
		(
	    do   	: out std_logic_vector(3 downto 0);
	    di   	: in std_logic_vector(3 downto 0);
	    addr 	: in std_logic_vector(9 downto 0);
	    we   	: in std_logic;
	    en   	: in std_logic;
	    rst  	: in std_logic;
	    clk  	: in std_logic
	  );
	end component;

	component RAMB4_S1 is
	  port 
		(
	    do   	: out std_logic_vector(0 downto 0);
	    di   	: in std_logic_vector(0 downto 0);
	    addr 	: in std_logic_vector(11 downto 0);
	    we   	: in std_logic;
	    en   	: in std_logic;
	    rst  	: in std_logic;
	    clk  	: in std_logic
	  );
	end component;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAMB4_S4 is
  port 
	(
    do   	: out std_logic_vector(3 downto 0);
    di   	: in std_logic_vector(3 downto 0);
    addr 	: in std_logic_vector(9 downto 0);
    we   	: in std_logic;
    en   	: in std_logic;
    rst  	: in std_logic;
    clk  	: in std_logic
  );
end RAMB4_S4;

architecture SYN of RAMB4_S4 is
begin

	ram_inst : entity work.spram
		generic map
		(
			numwords_a		=> 1024,
			widthad_a			=> 10,
			width_a				=> 4
		)
		port map
		(
			clock					=> clk,
			address				=> addr,
			q							=> do,
			wren					=> we,
			data					=> di
		);

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAMB4_S1 is
  port 
	(
    do   	: out std_logic_vector(0 downto 0);
    di   	: in std_logic_vector(0 downto 0);
    addr 	: in std_logic_vector(11 downto 0);
    we   	: in std_logic;
    en   	: in std_logic;
    rst  	: in std_logic;
    clk  	: in std_logic
  );
end RAMB4_S1;

architecture SYN of RAMB4_S1 is
begin

	ram_inst : entity work.spram
		generic map
		(
			numwords_a		=> 4096,
			widthad_a			=> 12,
			width_a				=> 1
		)
		port map
		(
			clock					=> clk,
			address				=> addr,
			q							=> do,
			wren					=> we,
			data					=> di
		);

end SYN;
