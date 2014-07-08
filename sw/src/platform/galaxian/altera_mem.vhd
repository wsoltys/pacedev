library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity galaxian_rom is
  port
  (
    clock   : in std_logic;
    address   : in std_logic_vector(13 downto 0);
    q         : out std_logic_vector(7 downto 0)
  );
end entity galaxian_rom;

architecture SYN of galaxian_rom is
begin
	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../src/platform/galaxian/roms/galxrom.hex",
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

entity galaxian_vram is
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
end entity galaxian_vram;
 
architecture SYN of galaxian_vram is
begin
  -- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
  vram_inst : entity work.dpram
    generic map
    (
      init_file		=> "../../../../src/platform/galaxian/roms/galxvram.hex",
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity galaxian_cram is
  port
  (
    clock_b     : in std_logic;
    address_b   : in std_logic_vector(7 downto 0);
    wren_b      : in std_logic;
    data_b      : in std_logic_vector(7 downto 0);
    q_b         : out std_logic_vector(7 downto 0);
    
    clock_a     : in std_logic;
    address_a   : in std_logic_vector(6 downto 0);
    q_a         : out std_logic_vector(15 downto 0)
  );
end entity galaxian_cram;

architecture SYN of galaxian_cram is
  
  signal q0_b     : std_logic_vector(7 downto 0) := (others => '0');
  signal q1_b     : std_logic_vector(7 downto 0) := (others => '0');
  signal wren0_b  : std_logic := '0';
  signal wren1_b  : std_logic := '0';
  
begin
		
  wren0_b <= wren_b when address_b(0) = '0' else '0';
  wren1_b <= wren_b when address_b(0) = '1' else '0';

  q_b <= q0_b when address_b(0) = '0' else q1_b;
  
	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram0_inst : entity work.dpram
		generic map
		(
			numwords_a	=> 128,
			widthad_a		=> 7
		)
		port map
		(
      clock_b			=> clock_b,
      address_b		=> address_b(7 downto 1),
      wren_b			=> wren0_b,
      data_b			=> data_b,
      q_b					=> q0_b,

      clock_a			=> clock_a,
      address_a		=> address_a,
      wren_a			=> '0',
      data_a			=> (others => 'X'),
      q_a					=> q_a(7 downto 0)
		);

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	cram1_inst : entity work.dpram
		generic map
		(
			numwords_a	=> 128,
			widthad_a		=> 7
		)
		port map
		(
      clock_b			=> clock_b,
      address_b		=> address_b(7 downto 1),
      wren_b			=> wren1_b,
      data_b			=> data_b,
      q_b					=> q1_b,

      clock_a			=> clock_a,
      address_a		=> address_a,
      wren_a			=> '0',
      data_a			=> (others => 'X'),
      q_a					=> q_a(15 downto 8)
		);

end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity galaxian_gfxrom is
  port
  (
    clock       : in std_logic;
    address_a   : in std_logic_vector(11 downto 0);
    q_a         : out std_logic_vector(7 downto 0);
    
    address_b   : in std_logic_vector(9 downto 0);
    q_b         : out std_logic_vector(31 downto 0)
  );
end entity galaxian_gfxrom;

architecture SYN of galaxian_gfxrom is
begin
	gfxrom_inst : entity work.dprom_2r
		generic map
		(
			init_file		=> "../../../../src/platform/galaxian/roms/gfxrom.hex",
			--numwords_a	=> 4096,
			widthad_a		=> 12,
			--numwords_b	=> 1024,
			widthad_b		=> 10,
			width_b			=> 32
		)
		port map
		(
			clock										=> clock,
			address_a								=> address_a,
			q_a											=> q_a,
			
			address_b								=> address_b,
			q_b                     => q_b
		);
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity galaxian_wram is
  port
  (
    clock     : in std_logic;
    address   : in std_logic_vector(10 downto 0);
    data      : in std_logic_vector(7 downto 0);
    wren      : in std_logic;
    q         : out std_logic_vector(7 downto 0)
  );
end entity galaxian_wram;

architecture SYN of galaxian_wram is
begin
  wram_inst : entity work.spram
    generic map
    (
    	numwords_a => 2048,
    	widthad_a => 11
    )
    port map
    (
      clock				=> clock,
      address			=> address,
      data				=> data,
      wren				=> wren,
      q						=> q
    );
end architecture SYN;
		
