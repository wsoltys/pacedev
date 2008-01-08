library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mon_rom is
    Port (
       clk   : in  std_logic;
       rst   : in  std_logic;
       cs    : in  std_logic;
       rw    : in  std_logic;
       addr  : in  std_logic_vector (10 downto 0);
       wdata : in  std_logic_vector (7 downto 0);
       rdata : out std_logic_vector (7 downto 0)
    );
end mon_rom;

architecture SYN of mon_rom is
begin

	rom_inst : entity work.sprom
		generic map
		(
			init_file => "../../../../src/platform/system09/roms/kbug_rom.mif",
			numwords_a => 2048,
			widthad_a => 11
		)
		port map
		(
			clock		=> clk,
			address => addr,
			q				=> rdata
		);

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity char_rom is
    Port (
       clk   : in  std_logic;
       rst   : in  std_logic;
       cs    : in  std_logic;
       rw    : in  std_logic;
       addr  : in  std_logic_vector (10 downto 0);
       wdata : in  std_logic_vector (7 downto 0);
       rdata : out std_logic_vector (7 downto 0)
    );
end char_rom;

architecture SYN of char_rom is
	signal we : std_logic;
begin

	we <= cs and not rw;
	
	rom_inst : entity work.spram
		generic map
		(
			init_file => "../../../../src/platform/system09/roms/char_rom.mif",
			numwords_a => 2048,
			widthad_a => 11
		)
		port map
		(
			clock			=> clk,
			address		=> addr,
			data			=> wdata,
			wren			=> we,
			q					=> rdata
		);

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_2k is
    Port (
       clk   : in  std_logic;
       rst   : in  std_logic;
       cs    : in  std_logic;
       rw    : in  std_logic;
       addr  : in  std_logic_vector (10 downto 0);
       wdata : in  std_logic_vector (7 downto 0);
       rdata : out std_logic_vector (7 downto 0)
    );
end ram_2k;

architecture SYN of ram_2k is
	signal we : std_logic;
begin
	we <= cs and not rw;
	
	ram_inst : entity work.spram
		generic map
		(
			init_file => "../../../../src/platform/system09/roms/ram2k.mif",
			numwords_a => 2048,
			widthad_a => 11
		)
		port map
		(
			clock			=> clk,
			address		=> addr,
			data			=> wdata,
			wren			=> we,
			q					=> rdata
		);

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BUFG is
	port
	(
		i	: in std_logic;
		o : out std_logic
	);
end BUFG;

architecture SYN of BUFG is
begin
	o <= i;
end SYN;
