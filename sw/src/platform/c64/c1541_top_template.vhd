library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.EXT;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library work;
use work.platform_pkg.all;
use work.project_pkg.all;

entity c1541_top is
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
		act							: out std_logic;											-- activity LED

		-- generic drive mechanism i/o ports
		mech_in					: in std_logic_vector(63 downto 0);
		mech_out				: out std_logic_vector(63 downto 0);
		mech_io					: inout std_logic_vector(63 downto 0)
	);
end c1541_top;

architecture SYN of c1541_top is

		signal rd_data					: std_logic_vector(7 downto 0);
		signal wr_data					: std_logic_vector(7 downto 0);

		signal mode 						: std_logic;
		signal stp 							: std_logic_vector(1 downto 0);
		signal mtr 							: std_logic;
		signal freq							: std_logic_vector(1 downto 0);
		signal soe							: std_logic;
		signal sync_n						: std_logic;
		signal byte_n						: std_logic;
		signal wps_n						: std_logic;
		signal tr00_sense_n			: std_logic;

	begin
	
		c1541_logic_inst : entity work.c1541_logic
			generic map
			(
				DEVICE_SELECT		=> C64_1541_DEVICE_SELECT(1 downto 0)
			)
			port map
			(
				clk_32M					=> clk_32M,
--				clk							=> clk_32M,
--				clk_en_32M			=> '1',
				reset						=> reset,

				-- serial bus
				sb_data_oe			=> sb_data_oe,
				sb_data_in			=> sb_data_in,
				sb_clk_oe				=> sb_clk_oe,
				sb_clk_in				=> sb_clk_in,
				sb_atn_oe				=> sb_atn_oe,
				sb_atn_in				=> sb_atn_in,

				-- drive-side interface				
				ds							=> ds,
				di							=> rd_data,
				do							=> wr_data,
				mode						=> mode,
				stp							=> stp,
				mtr							=> mtr,
				freq						=> freq,
				sync_n					=> sync_n,
				byte_n					=> byte_n,
				wps_n						=> wps_n,
				tr00_sense_n		=> tr00_sense_n,
				act							=> act
			);

		c1541_diskif_inst : entity work.c1541_diskif
			port map 
			(
				clk							=> clk_32M,
				clk_en_32M			=> '1',
				reset						=> reset,

				-- generic drive mechanism i/o ports
				mech_in					=> mech_in,
				mech_out				=> mech_out,
				mech_io					=> mech_io,

				-- drive-side interface				
				di							=> rd_data,
				do							=> wr_data,
				mode						=> mode,
				stp							=> stp,
				mtr							=> mtr,
				freq						=> freq,
				sync_n					=> sync_n,
				byte_n					=> byte_n,
				wps_n						=> wps_n,
				tr00_sense_n		=> tr00_sense_n
			);
			
end SYN;
