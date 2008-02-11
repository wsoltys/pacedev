library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

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
			init_file		=> BBCMICRO_SRC_DIR & "/roms/os12.hex",
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
use work.platform_pkg.all;

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
			init_file		=> BBCMICRO_SRC_DIR & "/roms/basic2.hex",
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

ENTITY dram IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		clock			: IN STD_LOGIC ;
		data			: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren			: IN STD_LOGIC ;
		q					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END dram;

architecture SYN of dram is
begin
	spram_inst : entity work.spram
		generic map
		(
			init_file => "dram.hex",
			numwords_a => 8192,
			widthad_a => 13
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
