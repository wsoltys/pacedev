--
-- This module is based *heavily* on the fpga64_hexy.vhd module from:
--
-- FPGA64
-- Reconfigurable hardware based commodore64 emulator.
-- Copyright 2005-2008 Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity quickload_hexy is
	generic 
	(
		yOffset : integer := 100;
		xOffset : integer := 100
	);
	port 
	(
		clk       : in std_logic;
		clk_ena   : in std_logic;
		vSync     : in std_logic;
		hSync     : in std_logic;
		video     : out std_logic;
		dim       : out std_logic;
		
		image     : in unsigned(8*8-1 downto 0);
		start_a   : in unsigned(15 downto 0);
		end_a     : in unsigned(15 downto 0);
		exec_a    : in unsigned(15 downto 0)
	);
end entity quickload_hexy;

architecture SYN of quickload_hexy is
	signal oldV : std_logic;
	signal oldH : std_logic;
	
	signal vPos : integer range 0 to 1023;
	signal hPos : integer range 0 to 2047;
	
	signal localX : unsigned(8 downto 0);
	signal localX2 : unsigned(8 downto 0);
	signal localX3 : unsigned(8 downto 0);
	signal localY : unsigned(3 downto 0);
	signal runY : std_logic;
	signal runX : std_logic;
	
	signal cChar : unsigned(5 downto 0);
	signal pixels : unsigned(0 to 63);
	
begin
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			if hSync = '0' and oldH = '1' then
				hPos <= 0;
				vPos <= vPos + 1;
			else
				hPos <= hPos + 1;
			end if;
			if vSync = '0' and oldV = '1' then
				vPos <= 0;
			end if;				
			oldH <= hSync;
			oldV <= vSync;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			if hPos = xOffset then
				localX <= (others => '0');
				runX <= '1';
				if vPos = yOffset then
					localY <= (others => '0');
					runY <= '1';
				end if;
			elsif runX = '1' and localX = "111111111" then
				runX <= '0';
				if localY = "111" then
					runY <= '0';
				else	
					localY <= localY + 1;
				end if;									
			else				
				localX <= localX + 1;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			case localX(8 downto 3) is
			when "000000" => cChar <= "010010"; -- I
			when "000001" => cChar <= "010110"; -- M
			when "000010" => cChar <= "001010"; -- A       
			when "000011" => cChar <= "010000"; -- G
			when "000100" => cChar <= "001110"; -- E
			when "000101" => cChar <= "111110"; -- :       
			when "000110" => cChar <= image(8*8-3 downto 8*7);
			when "000111" => cChar <= image(8*7-3 downto 8*6);
			when "001000" => cChar <= image(8*6-3 downto 8*5);
			when "001001" => cChar <= image(8*5-3 downto 8*4);
			when "001010" => cChar <= image(8*4-3 downto 8*3);
			when "001011" => cChar <= image(8*3-3 downto 8*2);
			when "001100" => cChar <= image(8*2-3 downto 8*1);
			when "001101" => cChar <= image(8*1-3 downto 8*0);
			when "001110" => cChar <= "111111"; --         
			when "001111" => cChar <= "111111"; --         
			when "010000" => cChar <= "011100"; -- S       
			when "010001" => cChar <= "011101"; -- T
			when "010010" => cChar <= "001010"; -- A       
			when "010011" => cChar <= "011011"; -- R       
			when "010100" => cChar <= "011101"; -- T
			when "010101" => cChar <= "111110"; -- :       
			when "010110" => cChar <= "00" & start_a(15 downto 12);
			when "010111" => cChar <= "00" & start_a(11 downto 8);
			when "011000" => cChar <= "00" & start_a(7 downto 4);
			when "011001" => cChar <= "00" & start_a(3 downto 0);
			when "011010" => cChar <= "111111"; --         
			when "011011" => cChar <= "111111"; --         
			when "011100" => cChar <= "001110"; -- E       
			when "011101" => cChar <= "010111"; -- N       
			when "011110" => cChar <= "001101"; -- D
			when "011111" => cChar <= "111110"; -- :       
			when "100000" => cChar <= "00" & end_a(15 downto 12);
			when "100001" => cChar <= "00" & end_a(11 downto 8);
			when "100010" => cChar <= "00" & end_a(7 downto 4);
			when "100011" => cChar <= "00" & end_a(3 downto 0);
			when "100100" => cChar <= "111111"; --         
			when "100101" => cChar <= "111111"; --         
			when "100110" => cChar <= "001110"; -- E       
			when "100111" => cChar <= "100001"; -- X
			when "101000" => cChar <= "001110"; -- E       
			when "101001" => cChar <= "001100"; -- C       
			when "101010" => cChar <= "111110"; -- :       
			when "101011" => cChar <= "00" & exec_a(15 downto 12);
			when "101100" => cChar <= "00" & exec_a(11 downto 8);
			when "101101" => cChar <= "00" & exec_a(7 downto 4);
			when "101110" => cChar <= "00" & exec_a(3 downto 0);
			when "101111" => cChar <= "111111"; --         
			when "110000" => cChar <= "111111"; --         
			when "110001" => cChar <= "111111"; --         
			when "110010" => cChar <= "111111"; --         
			when "110011" => cChar <= "111111"; --         
			when "110100" => cChar <= "111111"; --         
			when "110101" => cChar <= "111111"; --         
			when "110110" => cChar <= "111111"; --         
			when "110111" => cChar <= "111111"; --         
			when "111000" => cChar <= "111111"; --         
			when others => cChar <= (others => '1');
			end case;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			localX2 <= localX;
			localX3 <= localX2;
			if (runY = '0')
			or (runX = '0') then
				pixels <= (others => '0');
			else
				case cChar is
				when "000000" => pixels <= X"3C666E7666663C00"; -- 0
				when "000001" => pixels <= X"1818381818187E00"; -- 1
				when "000010" => pixels <= X"3C66060C30607E00"; -- 2
				when "000011" => pixels <= X"3C66061C06663C00"; -- 3
				when "000100" => pixels <= X"060E1E667F060600"; -- 4
				when "000101" => pixels <= X"7E607C0606663C00"; -- 5
				when "000110" => pixels <= X"3C66607C66663C00"; -- 6
				when "000111" => pixels <= X"7E660C1818181800"; -- 7
				when "001000" => pixels <= X"3C66663C66663C00"; -- 8
				when "001001" => pixels <= X"3C66663E06663C00"; -- 9

				when "001010" => pixels <= X"183C667E66666600"; -- A
				when "001011" => pixels <= X"7C66667C66667C00"; -- B
				when "001100" => pixels <= X"3C66606060663C00"; -- C
				when "001101" => pixels <= X"786C6666666C7800"; -- D
				when "001110" => pixels <= X"7E60607860607E00"; -- E
				when "001111" => pixels <= X"7E60607860606000"; -- F
				when "010000" => pixels <= X"3C66606E66663C00"; -- G
				when "010001" => pixels <= X"6666667E66666600"; -- H
				when "010010" => pixels <= X"3C18181818183C00"; -- I
				when "010011" => pixels <= X"1E0C0C0C0C6C3800"; -- J
				when "010100" => pixels <= X"666C7870786C6600"; -- K
				when "010101" => pixels <= X"6060606060607E00"; -- L
				when "010110" => pixels <= X"63777F6B63636300"; -- M
				when "010111" => pixels <= X"66767E7E6E666600"; -- N
				when "011000" => pixels <= X"3C66666666663C00"; -- O
				when "011001" => pixels <= X"7C66667C60606000"; -- P
				when "011010" => pixels <= X"3C666666663C0E00"; -- Q
				when "011011" => pixels <= X"7C66667C786C6600"; -- R
				when "011100" => pixels <= X"3C66603C06663C00"; -- S
				when "011101" => pixels <= X"7E18181818181800"; -- T
				when "011110" => pixels <= X"6666666666663C00"; -- U
				when "011111" => pixels <= X"66666666663C1800"; -- V
				when "100000" => pixels <= X"6363636B7F776300"; -- W
				when "100001" => pixels <= X"66663C183C666600"; -- X
				when "100010" => pixels <= X"6666663C18181800"; -- Y
				when "100011" => pixels <= X"7E060C1830607E00"; -- Z
				when "111110" => pixels <= X"0000180000180000"; -- :
				when others   => pixels <= X"0000000000000000"; -- space
				end case;
			end if;
		end if;			
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			video <= pixels(to_integer(localY & localX3(2 downto 0)));
		end if;
	end process;
	
	dim <= runX and runY;
	
end architecture SYN;

