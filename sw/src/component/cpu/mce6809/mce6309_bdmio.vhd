library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
use work.mce6309_pack.all;

entity mce6309_bdmio is
	port
	(
		-- external signals
    bdm_clk   	: in std_logic;
    bdm_i     	: in std_logic;
    bdm_o     	: out std_logic;
    bdm_oe    	: out std_logic;

		-- internal signals
		
		-- in
		bdm_enabled	: out std_logic;
		bdm_rdy			: out std_logic;
		bdm_ir			: out std_logic_vector(23 downto 0);
		
		-- out
		bdm_wr			: in std_logic;
		bdm_data		: in std_logic_vector(15 downto 0)
	);
end entity mce6309_bdmio;

architecture SYN of mce6309_bdmio is
begin
end architecture SYN;
