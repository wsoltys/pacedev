library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

ENTITY nes_wram IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END nes_wram;

architecture SYN of nes_wram is
begin
	wram_inst : ENTITY work.spram
		generic map
		(
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
			clock			=> clock,
			address		=> address,
			data			=> data,
			wren			=> wren,
			q					=> q
		);
end SYN;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

ENTITY dblscan_ram IS
	GENERIC
	(
		WIDTH	: natural
	);
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock_a		: IN STD_LOGIC ;
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '1';
		wren_b		: IN STD_LOGIC  := '1';
		q_a		: OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0)
	);
END dblscan_ram;

architecture SYN of dblscan_ram is
begin
	ram_inst : entity work.dpram
		generic map
		(
			numwords_a	=> 2048,
			widthad_a		=> 11,
			width_a 		=> WIDTH
		)
		port map
		(
			clock_a			=> clock_a,
			address_a		=> address_a,
			data_a			=> data_a,
			wren_a			=> wren_a,
			q_a					=> q_a,

			clock_b			=> clock_b,
			address_b		=> address_b,
			data_b			=> data_b,
			wren_b			=> wren_b,
			q_b					=> q_b
		);
end SYN;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

ENTITY ppu_ciram IS
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock_a		: IN STD_LOGIC ;
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '1';
		wren_b		: IN STD_LOGIC  := '1';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END ppu_ciram;

architecture SYN of ppu_ciram is
begin
	ciram_inst : entity work.dpram
		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		generic map
		(
			init_file		=> "../../../../src/platform/nes/rams/vram.hex",
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
      -- register interface
			clock_b			=> clock_b,
			address_b   => address_b,
			wren_b			=> wren_b,
			data_b			=> data_b,
			q_b					=> q_b,

      -- rendering engine interface
			clock_a			=> clock_a,
			address_a		=> address_a,
			wren_a			=> wren_a,
			data_a			=> data_a,
			q_a					=> q_a
		);
end SYN;
