library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INVADERS_ROM_H is
  port 
	(
		CLK         : in std_logic;
		ENA         : in std_logic;
		ADDR        : in std_logic_vector(10 downto 0);
		DATA        : out std_logic_vector(7 downto 0)
	);
end INVADERS_ROM_H;

architecture SYN of INVADERS_ROM_H is
begin

	rom_inst : entity work.sprom
		generic map
		(
			numwords_a		=> 2048,
			widthad_a			=> 11,
			init_file			=> "../../../../src/platform/invaders-fpgaarcade/roms/rom_h.hex"
		)
		port map
		(
			clock					=> CLK,
			address				=> ADDR,
			q							=> DATA
		);

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INVADERS_ROM_G is
  port 
	(
		CLK         : in std_logic;
		ENA         : in std_logic;
		ADDR        : in std_logic_vector(10 downto 0);
		DATA        : out std_logic_vector(7 downto 0)
	);
end INVADERS_ROM_G;

architecture SYN of INVADERS_ROM_G is
begin

	rom_inst : entity work.sprom
		generic map
		(
			numwords_a		=> 2048,
			widthad_a			=> 11,
			init_file			=> "../../../../src/platform/invaders-fpgaarcade/roms/rom_g.hex"
		)
		port map
		(
			clock					=> CLK,
			address				=> ADDR,
			q							=> DATA
		);

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INVADERS_ROM_F is
  port 
	(
		CLK         : in std_logic;
		ENA         : in std_logic;
		ADDR        : in std_logic_vector(10 downto 0);
		DATA        : out std_logic_vector(7 downto 0)
	);
end INVADERS_ROM_F;

architecture SYN of INVADERS_ROM_F is
begin

	rom_inst : entity work.sprom
		generic map
		(
			numwords_a		=> 2048,
			widthad_a			=> 11,
			init_file			=> "../../../../src/platform/invaders-fpgaarcade/roms/rom_f.hex"
		)
		port map
		(
			clock					=> CLK,
			address				=> ADDR,
			q							=> DATA
		);

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity INVADERS_ROM_E is
  port 
	(
		CLK         : in std_logic;
		ENA         : in std_logic;
		ADDR        : in std_logic_vector(10 downto 0);
		DATA        : out std_logic_vector(7 downto 0)
	);
end INVADERS_ROM_E;

architecture SYN of INVADERS_ROM_E is
begin

	rom_inst : entity work.sprom
		generic map
		(
			numwords_a		=> 2048,
			widthad_a			=> 11,
			init_file			=> "../../../../src/platform/invaders-fpgaarcade/roms/rom_e.hex"
		)
		port map
		(
			clock					=> CLK,
			address				=> ADDR,
			q							=> DATA
		);

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAMB16_S9_S9 is
	port 
	(
	  -- output
	  DOPB  : out std_logic;
	  DOB   : out std_logic_vector(7 downto 0);
	  DIPB  : in std_logic_vector(0 downto 0);
	  DIB   : in std_logic_vector(7 downto 0);
	  ADDRB : in std_logic_vector(10 downto 0);	-- 10..0
	  WEB   : in std_logic;
	  ENB   : in std_logic;
	  SSRB  : in std_logic;
	  CLKB  : in std_logic;

	  -- input
	  DOPA  : out std_logic;
	  DOA   : out std_logic_vector(7 downto 0);
	  DIPA  : in std_logic_vector(0 downto 0);
	  DIA   : in std_logic_vector(7 downto 0);
	  ADDRA : in std_logic_vector(10 downto 0);
	  WEA   : in std_logic;
	  ENA   : in std_logic;
	  SSRA  : in std_logic;
	  CLKA  : in std_logic
  );
end RAMB16_S9_S9;

architecture SYN of RAMB16_S9_S9 is
begin

	-- port A must be read-only for Cyclone-II SAFE WRITE
	-- in fpgaarcade invaders
	-- - port B is the read-only port
	-- - ENA inputs hard-wired ON
	
	dpram_inst : entity work.dpram
		generic map
		(
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
		port map
		(
			clock_a			=> CLKB,
			address_a		=> ADDRB,
			data_a			=> DIB,
			wren_a			=> WEB,
			q_a					=> DOB,

			clock_b			=> CLKA,
			address_b		=> ADDRA,
			data_b			=> DIA,
			wren_b			=> WEA,
			q_b					=> DOA
		);

end SYN;

