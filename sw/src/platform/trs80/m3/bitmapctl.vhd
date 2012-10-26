library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

--
--	TRS-80 Microlabs Model III Hires Graphics Bitmap Controller
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
end entity bitmapCtl_1;

architecture SYN of bitmapCtl_1 is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
  alias alt_char  : std_logic is graphics_i.bit8(0)(3);
  alias dbl_width : std_logic is graphics_i.bit8(0)(2);
  
  alias rgb       : RGB_t is ctl_o.rgb;
  
begin

  -- generate pixel
  process (clk)

		variable hblank_r		: std_logic_vector(DELAY-1 downto 0);
		alias hblank_prev		: std_logic is hblank_r(hblank_r'left);
		alias hblank_v			: std_logic is hblank_r(hblank_r'left-1);
		variable vcount			: std_logic_vector(8 downto 0);
		constant X_PIPELINE_BITS  : integer := 4;
		variable x_r	      : std_logic_vector(2*X_PIPELINE_BITS-1 downto 0);
		variable xc         : std_logic_vector(2 downto 0);
		variable pel_r      : std_logic_vector(DELAY-1-2 downto 0); -- 2 from above
		alias pel           : std_logic is pel_r(pel_r'right);
		
  begin

    -- not used
    ctl_o.a(ctl_o.a'left downto 14) <= (others => '0');
    
  	if rising_edge(clk) and clk_ena = '1' then

      if vblank = '1' then
        vcount := (others => '0');

      -- update vcount at the end of each line
			elsif hblank_v = '1' and hblank_prev = '0' then

        -- in effect we have vcount / 12 and vcount % 12
				if vcount(2+PACE_VIDEO_V_SCALE downto 0) = X"B" & 
						std_logic_vector(to_signed(-1,PACE_VIDEO_V_SCALE-1)) then
					vcount := vcount + 4 * PACE_VIDEO_V_SCALE + 1;
				else
					vcount := vcount + 1;
				end if;

        -- fixed for the line
        -- VCOUNT%12*1KiB
        ctl_o.a(13 downto 10) <= vcount(2+PACE_VIDEO_V_SCALE downto -1+PACE_VIDEO_V_SCALE);
        -- VCOUNT/12*64
  			ctl_o.a(9 downto 6) <= vcount(6+PACE_VIDEO_V_SCALE downto 3+PACE_VIDEO_V_SCALE);
          
			end if;
        
      -- 1st stage of pipeline
      -- - read tile from tilemap
      if stb = '1' then
        ctl_o.a(5 downto 1) <= x(8 downto 4);
        ctl_o.a(0) <= x(3) and not dbl_width;
      end if;

      -- pipeline pel by 2 clocks
      pel_r(pel_r'left downto 1) := pel_r(pel_r'left-1 downto 0);

      -- each byte contains information for 8 pixels
      if dbl_width = '0' then
        xc := x_r(x_r'left-1 downto x_r'left-3);
      else
        xc := x_r(x_r'left downto x_r'left-2);
      end if;
      case xc is
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
          pel := ctl_i.d(7);
      end case;

      -- green-screen display
      ctl_o.rgb.r <= (others => '0');
      ctl_o.rgb.g <= (others => pel_r(pel_r'left));
      ctl_o.rgb.b <= (others => '0');
      
			-- pipelined because of tile data loopkup
      x_r := x_r(x_r'left-X_PIPELINE_BITS downto 0) & x(X_PIPELINE_BITS-1 downto 0);

      -- for end-of-line detection
			hblank_r := hblank_r(hblank_r'left-1 downto 0) & hblank;
		
      ctl_o.set <= pel_r(pel_r'left);

		end if; -- rising_edge(clk)

  end process;

  -- may need to pipeline video to match tilemap
  
end architecture SYN;

