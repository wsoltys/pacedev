library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

--
--	Video Controller Test Bitmap Controller
--

entity bitmapCtl_1 is          
port               
(
    clk         	: in std_logic;
		reset					: in std_logic;

		-- video control signals		
		stb				    : in std_logic;
    hblank      	: in std_logic;
    vblank      	: in std_logic;
    x       	    : in std_logic_vector(10 downto 0);
    y       	    : in std_logic_vector(10 downto 0);

    -- tilemap interface
		scroll_data		: in std_logic_vector(7 downto 0);
		palette_data	: in ByteArrayType(15 downto 0);
    bitmap_d   		: in std_logic_vector(7 downto 0);
    bitmap_a   		: out std_logic_vector(15 downto 0);

		-- RGB output (10-bits each)
		rgb						: out RGB_t;
		bitmap_on			: out std_logic
);
end bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

  constant PIPELINE_EMULATION : natural := PACE_VIDEO_PIPELINE_DELAY;

begin

	-- these are constant for a whole line
	bitmap_a(15 downto 13) <= (others => '0');
  bitmap_a(12 downto 8) <= y(7 downto 3);

  -- generate pixel
  process (clk)

    variable p_x  : std_logic_vector(PIPELINE_EMULATION*3-1 downto 0) := (others => '0');
		
  begin
  	if rising_edge(clk) then

			-- 1st stage of pipeline
      if stb = '1' then
        bitmap_a(7 downto 0) <= x(7 downto 0);
      end if;

			rgb.r <= (others => '0');
			rgb.g <= (others => '0');
			rgb.b <= (others => '0');

      case y(2 downto 0) is
        when "000" =>
          rgb.r(9 downto 8) <= "11";	-- red
        when "111" =>
          rgb.g(9 downto 8) <= "11";	-- green
        when others =>
          null;
      end case;

      case p_x(p_x'left downto p_x'left-2) is
        when "000" =>
          rgb.r(9 downto 8) <= "11";	-- red
        when "110" =>
          rgb.b(9 downto 8) <= "11";	-- blue
        when "111" =>
          rgb.g(9 downto 8) <= "11";	-- green
        when others =>
          null;
      end case;

      -- pipelined X
      p_x := p_x(p_x'left-3 downto 0) & x(2 downto 0);

		end if; -- rising_edge(clk)

  end process;

	bitmap_on <= '1';

end SYN;

