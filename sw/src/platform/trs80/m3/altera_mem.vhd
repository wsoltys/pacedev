library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trs80_rom is
  port
  (
    clock     : in std_logic;
    address   : in std_logic_vector(13 downto 0);
    q         : out std_logic_vector(7 downto 0)
  );
end entity trs80_rom;

architecture SYN of trs80_rom is
begin
	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/trs80/m3/roms/m3rom.hex",
			numwords_a	=> 16384,
			widthad_a		=> 14
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
library work;
use work.project_pkg.all;

entity trs80_hires_ram is
  port 
  (
    clock_b     : in std_logic;
    address_b   : in std_logic_vector(TRS80_M3_HIRES_WIDTHA-1 downto 0);
    wren_b      : in std_logic;
    data_b      : in std_logic_vector(7 downto 0);
    q_b         : out std_logic_vector(7 downto 0);
    
    clock_a     : in std_logic;
    address_a   : in std_logic_vector(TRS80_M3_HIRES_WIDTHA-1 downto 0);
    wren_a      : in std_logic;
    data_a      : in std_logic_vector(7 downto 0);
    q_a         : out std_logic_vector(7 downto 0)
  );
end entity trs80_hires_ram;

architecture SYN of trs80_hires_ram is
begin
  hires_ram_inst : entity work.dpram
    generic map
    (
      init_file		=> "", --"../../../../../src/platform/trs80/m3/roms/trsvram.hex",
      numwords_a	=> 2**TRS80_M3_HIRES_WIDTHA,
      widthad_a		=> TRS80_M3_HIRES_WIDTHA
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
