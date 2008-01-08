library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity coco3fpga is
	port
	(
		CLK50MHZ			: in std_logic;
		
		-- RAM, ROM, and Peripherials
		RAM_DATA0_I		: in std_logic_vector(15 downto 0);
		RAM_DATA0_O		: out std_logic_vector(15 downto 0);
		RAM_DATA1			: inout std_logic_vector(15 downto 0);
		RAM_ADDRESS		: out std_logic_vector(17 downto 0);
		RAM_RW_N			: out std_logic;
		RAM0_CS_N			: out std_logic;
		RAM1_CS_N			: out std_logic;
		RAM0_BE0_N		: out std_logic;
		RAM0_BE1_N		: out std_logic;
		RAM1_BE0_N		: out std_logic;
		RAM1_BE1_N		: out std_logic;
		RAM_OE_N			: out std_logic;
		
		-- VGA
		RED1					: out std_logic;
		GREEN1				: out std_logic;
		BLUE1					: out std_logic;
		RED0					: out std_logic;
		GREEN0				: out std_logic;
		BLUE0					: out std_logic;
		H_SYNC				: out std_logic;
		V_SYNC				: out std_logic;
		
		-- PS/2
		ps2_clk				: in std_logic;
		ps2_data			: in std_logic;
		
		--Serial Ports
		TXD1					: out std_logic;
		RXD1					: in std_logic;
		TXD2					: out std_logic;
		RXD2					: in std_logic;
		
		-- Display
		DIGIT_N				: out std_logic;
		SEGMENT_N			: out std_logic;
		
		-- LEDs
		LED						: out std_logic_vector(7 downto 0);
		
		-- CoCo Perpherial
		SPEAKER				: out std_logic;
		PADDLE				: in std_logic_vector(7 downto 0);
		P_SWITCH			: in std_logic_vector(3 downto 0);
		
		-- Extra Buttons and Switches
		SWITCH				: in std_logic_vector(7 downto 0);
		BUTTON				: in std_logic_vector(3 downto 0);
		PH_2					: out std_logic
	);
end coco3fpga;

architecture SIM of coco3fpga is

	alias clk		: std_logic is CLK50MHZ;
	alias reset : std_logic is button(3);

	constant DELAY : time := 2 ns;

begin

	process
	begin
	
		ram_data0_o <= X"0000" after DELAY;
		ram_rw_n <= '1';
		ram0_cs_n <= '1';
		ram0_be0_n <= '1';
		ram0_be1_n <= '1';
		ram_oe_n <= '1';

		-- write
		wait until reset = '0';
		wait until clk = '1';
		ram_address <= "11"&X"55AA" after DELAY;
		ram_data0_o <= X"1234" after DELAY;
		ram0_be0_n <= '0';
		ram0_be1_n <= '1';
		ram0_cs_n <= '0' after DELAY;
		ram_oe_n <= '0' after DELAY;
		ram_rw_n <= '0' after DELAY;

		-- finish write
		wait until clk = '1';
		ram0_cs_n <= '1' after DELAY;
		ram_oe_n <= '1' after DELAY;
		ram_rw_n <= '1' after DELAY;

		-- start a read
		wait until clk = '1';
		wait until clk = '1';
		ram0_cs_n <= '0' after DELAY;
		ram_oe_n <= '0' after DELAY;

		-- finish read
		wait until clk = '1';
		ram0_cs_n <= '1' after DELAY;
		ram_oe_n <= '1' after DELAY;

	end process;

end;

