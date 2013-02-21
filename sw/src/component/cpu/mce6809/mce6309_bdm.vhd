library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
use work.mce6309_pack.all;

entity mce6309_bdm is
	port
	(
    bdm_clk   : in std_logic;
    bdm_i     : in std_logic;
    bdm_o     : out std_logic;
    bdm_oe    : out std_logic;
  
    -- registers      
  	cc	      : in std_logic_vector(7 downto 0);
  	a         : in std_logic_vector(7 downto 0);
  	b         : in std_logic_vector(7 downto 0);
  	dp	      : in std_logic_vector(7 downto 0);
  	x		      : in std_logic_vector(15 downto 0);
  	y		      : in std_logic_vector(15 downto 0);
  	u		      : in std_logic_vector(15 downto 0);
  	s		      : in std_logic_vector(15 downto 0);
  	pc	      : in std_logic_vector(15 downto 0)
	);
end entity mce6309_bdm;

architecture SYN of mce6309_bdm is
begin
end architecture SYN;
