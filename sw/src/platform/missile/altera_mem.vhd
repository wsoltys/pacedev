library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;

ENTITY prg_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END prg_rom;

architecture SYN of prg_rom is
begin
	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/missile/roms/missile.hex",
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

ENTITY vram IS
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock_a		: IN STD_LOGIC ;
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '1';
		wren_b		: IN STD_LOGIC  := '1';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END vram;

architecture SYN of vram is
begin
	dpram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../src/platform/pacman/roms/pacvram.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		port map
		(
			clock_b			=> clock_b,
			address_b		=> address_b,
			wren_b			=> wren_b,
			data_b			=> data_b,
			q_b					=> q_b,
			
			-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
			clock_a			=> clock_a,
			address_a		=> address_a,
			wren_a			=> wren_a,
			data_a			=> data_a,
			q_a					=> q_a
		);
end SYN;

library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;

ENTITY cram IS
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock_a		: IN STD_LOGIC ;
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '1';
		wren_b		: IN STD_LOGIC  := '1';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END cram;

architecture SYN of cram is
begin
	dpram_inst : entity work.dpram
		generic map
		(
			numwords_a	=> 1024,
			widthad_a		=> 10
		)
		port map
		(
			clock_b			=> clock_b,
			address_b		=> address_b,
			wren_b			=> wren_b,
			data_b			=> data_b,
			q_b					=> q_b,
			
			-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
			clock_a			=> clock_a,
			address_a		=> address_a,
			wren_a			=> wren_a,
			data_a			=> data_a,
			q_a					=> q_a
		);
end SYN;

library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;

ENTITY tile_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END tile_rom;

architecture SYN of tile_rom is
begin
	sprom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/pacman/roms/pactile.hex",
			numwords_a	=> 4096,
			widthad_a		=> 12
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

ENTITY sprite_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END sprite_rom;

architecture SYN of sprite_rom is
begin
	sprom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/pacman/roms/pacsprite32.hex",
			numwords_a	=> 1024,
			widthad_a		=> 10,
			width_a			=> 32
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

library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

ENTITY snd_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END snd_rom;

architecture SYN of snd_rom is
begin
  sprom_inst : entity work.sprom
    generic map
    (
			init_file		=> SOUND_ROM_INIT_FILE,
			numwords_a	=> 256,
			widthad_a		=> 8
    )
    port map
    (
			clock			=> clock,
			address		=> address,
			q					=> q
    );
end SYN;
