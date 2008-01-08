library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.platform_pkg.all;
use work.project_pkg.all;

--
-- Model 1541B
--

entity c1541_logic is
	generic
	(
		DEVICE_SELECT		: std_logic_vector(1 downto 0)
	);
	port
	(
		clk_32M					: in std_logic;
		reset						: in std_logic;

		-- serial bus
		sb_data_oe			: out std_logic;
		sb_data_in			: in std_logic;
		sb_clk_oe				: out std_logic;
		sb_clk_in				: in std_logic;
		sb_atn_oe				: out std_logic;
		sb_atn_in				: in std_logic;
		
		-- drive-side interface
		ds							: in std_logic_vector(1 downto 0);		-- device select
		di							: in std_logic_vector(7 downto 0);		-- disk write data
		do							: out std_logic_vector(7 downto 0);		-- disk read data
		mode						: out std_logic;											-- read/write
		stp							: out std_logic_vector(1 downto 0);		-- stepper motor control
		mtr							: out std_logic;											-- stepper motor on/off
		freq						: out std_logic_vector(1 downto 0);		-- motor frequency
		sync_n					: in std_logic;												-- reading SYNC bytes
		byte_n					: in std_logic;												-- byte ready
		wps_n						: in std_logic;												-- write-protect sense
		tr00_sense_n		: in std_logic;												-- track 0 sense (unused?)
		act							: out std_logic												-- activity LED
	);
end c1541_logic;

architecture SYN of c1541_logic is

begin

end SYN;
