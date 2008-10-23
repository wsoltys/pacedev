library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;

--
--	Asteroids Bitmap Controller
--

entity bitmapCtl_1 is          
port               
(
    clk         	: in std_logic;
		clk_ena				: in std_logic;
		reset					: in std_logic;

		-- video control signals		
    hblank      	: in std_logic;
    vblank      	: in std_logic;
    pix_x       	: in std_logic_vector(9 downto 0);
    pix_y       	: in std_logic_vector(9 downto 0);

    -- tilemap interface
		scroll_data		: in std_logic_vector(7 downto 0);
		palette_data	: in ByteArrayType(15 downto 0);
    bitmap_d   		: in std_logic_vector(7 downto 0);
    bitmap_a   		: out std_logic_vector(15 downto 0);

		-- RGB output (10-bits each)
		rgb						: out RGBType;
		bitmap_on			: out std_logic
);
end bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

begin

	-- these are constant for a whole line
	bitmap_a(15) <= '0';
	bitmap_a(14 downto 6) <= pix_y(8 downto 0);

  -- generate pixel
  process (clk, clk_ena)

		variable pel : std_logic;
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

			if hblank = '0' then
						
				-- 1st stage of pipeline
				-- - read bitmap data
				bitmap_a(5 downto 0) <= pix_x(8 downto 3);

				-- each byte contains information for 8 pixels
				case pix_x(2 downto 0) is
	        when "000" =>
	          pel := bitmap_d(6);
	        when "001" =>
	          pel := bitmap_d(7);
	        when "010" =>
	          pel := bitmap_d(0);
	        when "011" =>
	          pel := bitmap_d(1);
	        when "100" =>
	          pel := bitmap_d(2);
	        when "101" =>
	          pel := bitmap_d(3);
	        when "110" =>
	          pel := bitmap_d(4);
	        when others =>
	          pel := bitmap_d(5);
				end case;

				-- slight blue tinge
				rgb.r <= (rgb.r'left-2 => '0', others => pel);
				rgb.g <= (rgb.g'left-2 => '0', others => pel);
				rgb.b <= (others => pel);
				
			end if; -- hblank = '0'
				
		end if;				

  end process;

	bitmap_on <= '1';

end SYN;

