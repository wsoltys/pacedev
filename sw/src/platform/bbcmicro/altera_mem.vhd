library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;

ENTITY mos_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		  : IN STD_LOGIC ;
		q		      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END mos_rom;

architecture SYN of mos_rom is
begin
	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/bbc/roms/os12.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clock,
			address		=> address,
			q					=> q
		);
end SYN;

library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;

ENTITY basic_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		  : IN STD_LOGIC ;
		q		      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END basic_rom;

architecture SYN of basic_rom is
begin
	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/bbc/roms/basic2.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock			=> clock,
			address		=> address,
			q					=> q
		);
end SYN;

library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;

ENTITY wram IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END wram;

architecture SYN of wram is
begin
	spram_inst : entity work.spram
		generic map
		(
			numwords_a => 1024,
			widthad_a => 10
		)
		port map
		(
			clock				=> clock,
			address			=> address,
			data				=> data,
			wren				=> wren,
			q						=> q
		);
end SYN;
