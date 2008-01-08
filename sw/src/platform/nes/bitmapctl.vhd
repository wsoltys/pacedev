library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

--
--	NES Background Generator
--

entity bitmapCtl_1 is          
	port               
	(
	    clk         	: in std_logic;
			clk_ena				: in std_logic;
			reset					: in std_logic;

			-- video control signals		
	    hblank      	: in std_logic;
			vblank				: in std_logic;
	    pix_x       	: in std_logic_vector(9 downto 0);
	    pix_y       	: in std_logic_vector(9 downto 0);

	    -- tilemap interface
			scroll_data		: in std_logic_vector(7 downto 0);
			palette_data	: in ByteArrayType(15 downto 0);
	    bitmap_d    	: in std_logic_vector(7 downto 0);
	    bitmap_a    	: out std_logic_vector(15 downto 0);

			-- RGB output (10-bits each)
			rgb						: out RGBType;
			bitmap_on	  	: out std_logic
	);
end bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

	signal clut_entry		: std_logic_vector(7 downto 0);
	signal pal_entry 		: pal_entry_typ;

begin

	clut_entry <= clut(0);
	pal_entry <= pal(conv_integer(clut_entry(5 downto 0)));
	rgb.r <= pal_entry(0) & "0000";
	rgb.g <= pal_entry(1) & "0000";
	rgb.b <= pal_entry(2) & "0000";

	bitmap_a <= (others => '0');
	bitmap_on <= '1';
	
end SYN;

