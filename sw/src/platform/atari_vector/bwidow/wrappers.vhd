library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_pgma is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_pgma is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(0) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_pgmb is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_pgmb is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(1) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_pgmc is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_pgmc is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(2) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_pgmd is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_pgmd is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(3) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_pgme is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_pgme is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(4) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_pgmf is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_pgmf is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(5) & ".hex"
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

entity RAMB16_S9  is
  port 
	(
      do   : out std_logic_vector(7 downto 0);
      dop  : out std_logic;
      addr : in std_logic_vector(10 downto 0);
      clk  : in std_logic;
      di   : in std_logic_vector(7 downto 0);
      dip  : in std_logic_vector(0 downto 0);
      en   : in std_logic;
      ssr  : in std_logic;
      we   : in std_logic
  );
end RAMB16_S9;

architecture SYN of RAMB16_S9 is
begin

  spram_inst : entity work.spram
		generic map
		(
			numwords_a	=> 2048,
			widthad_a		=> 11
		)
    port map 
		(
      q   			=> do,
      address 	=> addr,
      clock			=> clk,
      data   		=> di,
      wren   		=> we
    );

	dop <= '0';
	
end architecture SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_veca is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(10 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_veca is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 2048,
			widthad_a			=> BWIDOW_ROM_WIDTHAD-1,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(6) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_vecb is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_vecb is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(7) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_vecc is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_vecc is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(8) & ".hex"
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

library work;
use work.platform_variant_pkg.all;
use work.pkg_bwidow.all;

entity rom_vecd is
  port (
    CLK         : in    std_logic;
    ADDR        : in    std_logic_vector(11 downto 0);
    DATA        : out   std_logic_vector(7 downto 0)
    );
end entity;

architecture SYN of rom_vecd is
begin

	rom_inst : entity work.sprom
		generic map
		(
			--numwords_a		=> 4096,
			widthad_a			=> BWIDOW_ROM_WIDTHAD,
			init_file			=> PLATFORM_VARIANT_SRC_DIR & "roms/" & BWIDOW_ROM(9) & ".hex"
		)
		port map
		(
			clock					=> CLK,
			address				=> ADDR,
			q							=> DATA
		);

end SYN;

