library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

entity T80s is
	generic(
		Mode : integer := 0;    -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 0;  -- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait : integer := 1   -- 0 => Single cycle I/O, 1 => Std I/O cycle
	);
	port(
		RESET_n         : in  std_logic;
		CLK_n           : in  std_logic;
		WAIT_n          : in  std_logic;
		INT_n           : in  std_logic;
		NMI_n           : in  std_logic;
		BUSRQ_n         : in  std_logic;
		M1_n            : out std_logic;
		MREQ_n          : out std_logic;
		IORQ_n          : out std_logic;
		RD_n            : out std_logic;
		WR_n            : out std_logic;
		RFSH_n          : out std_logic;
		HALT_n          : out std_logic;
		BUSAK_n         : out std_logic;
		A               : out std_logic_vector(15 downto 0);
		DI              : in  std_logic_vector(7 downto 0);
		DO              : out std_logic_vector(7 downto 0)
	);
end T80s;

architecture SYN of T80s is
begin

	T80se_inst : entity work.T80se
		generic map
		(
			Mode => Mode,
			T2Write => T2Write,
			IOWait => IOWait
		)
		port map
		(
			RESET_n         => RESET_n,
			CLK_n           => CLK_n,
			CLKEN           => '1',
			WAIT_n          => WAIT_n,
			INT_n           => INT_n,
			NMI_n           => NMI_n,
			BUSRQ_n         => BUSRQ_n,
			M1_n            => M1_n,
			MREQ_n          => MREQ_n,
			IORQ_n          => IORQ_n,
			RD_n            => RD_n,
			WR_n            => WR_n,
			RFSH_n          => RFSH_n,
			HALT_n          => HALT_n,
			BUSAK_n         => BUSAK_n,
			A               => A,
			DI              => DI,
			DO              => DO
		);

end SYN;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SSRAM is
	generic 
	(
		AddrWidth : natural;
		DataWidth : natural := 8
	);
	port 
	(
		Clk 		: in std_logic;
    CE_n 		: in std_logic;
    WE_n 		: in std_logic;
    A 			: in std_logic_vector(AddrWidth-1 downto 0);
    DIn 		: in std_logic_vector(DataWidth-1 downto 0);
    DOut 		: out std_logic_vector(DataWidth-1 downto 0)
	);
end SSRAM;

architecture SYN of SSRAM is
	signal we	: std_logic;
begin

	we <= not CE_n and not WE_n;
	
	ram_inst : entity work.spram
		generic map
		(
			numwords_a	=> 2**(AddrWidth),
			widthad_a		=> AddrWidth,
			width_a			=> DataWidth
		)
		port map
		(
			clock				=> Clk,
			address			=> A,
			wren				=> we,
			data				=> DIn,
			q						=> DOut
		);

end SYN;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.project_pkg.all;

entity trs_rom1 is
  port 
	(
		Clk	: in std_logic;
		A	: in std_logic_vector(13 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end trs_rom1;

architecture SYN of trs_rom1 is
begin

	rom_inst : entity work.sprom
		generic map
		(
			init_file		=> "../../../../../src/platform/zx/trs/roms/" & TRS_ROM_FILENAME,
			numwords_a	=> 16384,
			widthad_a		=> 14
		)
		port map
		(
			clock				=> Clk,
			address			=> A,
			q						=> D
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
