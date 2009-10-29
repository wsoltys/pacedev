library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trs80_rom is
  port
  (
    clock     : in std_logic;
    address   : in std_logic_vector(10 downto 0);
    q         : out std_logic_vector(7 downto 0)
  );
end entity trs80_rom;

architecture SYN of trs80_rom is
begin
	trs80_rom_inst : entity work.trs80_m3_rom
		port map
		(
			clock			=> clock,
			address		=> address,
			q					=> q
		);
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trs80_ram is
  PORT
  (
    address		: in std_logic_vector(10 downto 0);
    clock		  : in std_logic;
    data		  : in std_logic_vector(7 downto 0);
    wren		  : in std_logic;
    q		      : out std_logic_vector(7 downto 0)
  );
end entity trs80_ram;

architecture SYN of trs80_ram is
begin
  trs80_ram_inst : entity work.spram
    generic map
    (
      numwords_a		=> 2048,
      widthad_a			=> 11
    )
    port map
    (
      address		=> address,
      clock		  => clock,
      data		  => data,
      wren		  => wren,
      q		      => q
    );
end architecture SYN;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trs80_tile_rom is
  port
  (
    clock     : in std_logic;
    address   : in std_logic_vector(11 downto 0);
    q         : out std_logic_vector(7 downto 0)
  );
end entity trs80_tile_rom;

architecture SYN of trs80_tile_rom is
begin
	tilerom_inst : entity work.sprom
		generic map
		(
			init_file		    => "../../../../../src/platform/trs80/m3/roms/trstile.hex",
			numwords_a	    => 4096,
			widthad_a		    => 12
		)
		port map
		(
			clock			=> clock,
			address		=> address,
			q					=> q
		);
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trs80_vram is
  port
  (
    clock_b     : in std_logic;
    address_b   : in std_logic_vector(9 downto 0);
    wren_b      : in std_logic;
    data_b      : in std_logic_vector(7 downto 0);
    q_b         : out std_logic_vector(7 downto 0);
    
    clock_a     : in std_logic;
    address_a   : in std_logic_vector(9 downto 0);
    wren_a      : in std_logic;
    data_a      : in std_logic_vector(7 downto 0);
    q_a         : out std_logic_vector(7 downto 0)
  );
end entity trs80_vram;

architecture SYN of trs80_vram is
begin
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.dpram
		generic map
		(
			init_file		=> "../../../../../src/platform/trs80/m3/roms/trsvram.hex",
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

      clock_a			=> clock_a,
      address_a		=> address_a,
      wren_a			=> wren_a,
      data_a			=> data_a,
      q_a					=> q_a
		);
end architecture SYN;

--
-- ************************************************************************
--    Here are all the guest roms
--    - only one will be instantiated in the platform
-- ************************************************************************
--

library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.pace_pkg.all;
use work.project_pkg.all;

ENTITY guest_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END guest_rom;

architecture SYN of guest_rom is
begin

  GEN_PACMAN : if LDR_PLATFORM = PLATFORM_PACMAN generate
    rom_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../../src/platform/pacman/roms/pacrom.hex",
        numwords_a	=> 16384,
        widthad_a		=> 14
      )
      port map
      (
        clock			=> clock,
        address		=> address,
        q					=> q
      );
  end generate GEN_PACMAN;
  
end SYN;

