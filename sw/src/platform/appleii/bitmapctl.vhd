library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;

--
--	Apple II Bitmap Controller
--

entity bitmapCtl_1 is          
  generic
  (
    DELAY         : integer
  );
  port               
  (
    reset					: in std_logic;

    -- video control signals		
    video_ctl     : in from_VIDEO_CTL_t;

    -- bitmap controller signals
    ctl_i         : in to_BITMAP_CTL_t;
    ctl_o         : out from_BITMAP_CTL_t;

    graphics_i    : in to_GRAPHICS_t
  );
end bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
  alias rgb       : RGB_t is ctl_o.rgb;
  
  signal aaa : std_logic_vector(12 downto 0); -- 1st part of addr calc
  signal bbb : std_logic_vector(12 downto 0); -- 2nd part of addr calc

begin

	ctl_o.a(15 downto 13) <= (others => '0');
	
	-- these are constant for a whole line
  -- the apple video screen is interlaced
  -- calculate what we can w/o maths operations
  -- we want: a = ((y&7)<<10)|((y&0x38)<<4)|(((y>>3)&0x18)*5+x)
  -- this is: ((y&7)<<10)|((y&0x38)<<4)
  aaa <= y(2 downto 0) & y(5 downto 3) & "0000000";
  -- and this is ((y>>3)&0x18)*5
  bbb <= "000000" & y(7 downto 6) & y(7 downto 6) & "000";
  -- so we just need (aaa | (bbb+x))

  -- generate pixel
  process (clk, clk_ena, reset)

		variable x_count		: std_logic_vector(8 downto 0);
		variable pix_x_r		: std_logic_vector(2 downto 0);
		variable pel 				: std_logic;
		
  begin
		if reset = '1' then
			null;
			
  	elsif rising_edge(clk) and clk_ena = '1' then

			if vblank = '1' then
				null;
				
			elsif hblank = '1' then
				x_count := (others => '0');

			elsif hblank = '0' then
						
				-- 1st stage of pipeline
				-- - read tile from tilemap
				-- - read attribute data
        ctl_o.a(12 downto 0) <= aaa or (bbb + (std_logic_vector(resize(unsigned(x_count(8 downto 3)), bbb'length))));

				case pix_x_r is
					when "000" =>
						pel := ctl_i.d(0);
					when "001" =>
						pel := ctl_i.d(1);
					when "010" =>
						pel := ctl_i.d(2);
					when "011" =>
						pel := ctl_i.d(3);
					when "100" =>
						pel := ctl_i.d(4);
					when "101" =>
						pel := ctl_i.d(5);
					when "110" =>
						pel := ctl_i.d(6);
					when others =>
						pel := '0'; --ctl_i.d(7);
				end case;
									
	      -- green-screen display
				rgb.r <= (others => '0');
				rgb.g <= (others => pel);
				rgb.b <= (others => '0');
				
			end if; -- hblank = '0'
		
			-- pipelined because of tile data loopkup
			pix_x_r := x_count(2 downto 0);
			if x_count(2 downto 0) = "110" then
				x_count := x_count + 2;
			else
				x_count := x_count + 1;
			end if;
			
		end if;				

	ctl_o.set <= pel;

  end process;

end SYN;

