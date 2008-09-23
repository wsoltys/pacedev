library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Williams Defender Bitmap Controller
--

entity bitmapCtl_1 is          
port               
(
    clk         	: in std_logic;
		clk_ena				: in std_logic;
		reset					: in std_logic;

		-- video control signals	
		stb           : in std_logic;	
    hblank      	: in std_logic;
    vblank      	: in std_logic;
    x       	    : in std_logic_vector(10 downto 0);
    y       	    : in std_logic_vector(10 downto 0);

		scroll_data		: in std_logic_vector(7 downto 0);
		palette_data	: in ByteArrayType(15 downto 0);
		
    -- tilemap interface
    bitmap_d   		: in std_logic_vector(7 downto 0);
    bitmap_a   		: out std_logic_vector(15 downto 0);

		-- RGB output (10-bits each)
		rgb						: out RGB_t;
		bitmap_on			: out std_logic
);
end bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

begin

	-- constant for a whole line
	bitmap_a(6 downto 0) <= not y(7 downto 1);

  -- generate pixel
  process (clk, clk_ena, reset)

		variable pel 				: std_logic_vector(3 downto 0);
		variable pal_entry 	: std_logic_vector(7 downto 0);
		
  begin
  	if rising_edge(clk) and clk_ena = '1' then

      -- 1st stage of pipeline
      -- - read data from bitmap
      if stb = '1' then
        if (y < 64) then
          bitmap_a(14 downto 7) <= x(7 downto 0) + 16;
        else
          bitmap_a(14 downto 7) <= x(7 downto 0) + 16 + scroll_data;
        end if;
      end if;
      
      case y(0) is
        when '0' =>
          pel := bitmap_d(7 downto 4);
        when others =>
          pel := bitmap_d(3 downto 0);
      end case;
                
      -- extract R,G,B from colour palette
      pal_entry := palette_data(conv_integer(pel));
      rgb.r <= pal_entry(2 downto 0) & "0000000";
      rgb.g <= pal_entry(5 downto 3) & "0000000";
      rgb.b <= pal_entry(7 downto 6) & "00000000";
				
		end if;				

    bitmap_on <= '1';

  end process;

end SYN;
