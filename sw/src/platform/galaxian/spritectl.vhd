library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;    

entity spritectl is
	generic
	(
		INDEX		: natural;
		DELAY   : integer
	);
	port               
	(
    -- sprite registers
    reg_i       : in from_SPRITE_REG_t;
    
    -- video control signals
    video_ctl   : in from_VIDEO_CTL_t;

    -- sprite control signals
    ctl_i       : in to_SPRITE_CTL_t;
    ctl_o       : out from_SPRITE_CTL_t;
    
		graphics_i  : in to_GRAPHICS_t
	);
end entity spritectl;

architecture SYN of spritectl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  
  signal flipData : std_logic_vector(31 downto 0);   -- flipped row data
   
  alias rgb       : RGB_t is ctl_o.rgb;
  
begin

  flipData <= flip_row (ctl_i.d(31 downto 0), reg_i.xflip);
  
	process (clk, clk_ena)

   	variable rowStore : std_logic_vector(31 downto 0);  -- saved row of spt to show during visibile period
    variable pel_r    : std_logic_vector((DELAY-3)*2-1 downto 0);
		alias pel         : std_logic_vector(1 downto 0) is pel_r(pel_r'left downto pel_r'left-1);
    variable x        : std_logic_vector(video_ctl.x'range);
    variable y        : std_logic_vector(video_ctl.y'range);
    variable yMat     : boolean;      -- raster is between first and last line of sprite
    variable xMat     : boolean;      -- raster in between left edge and end of line

		-- the width of rowCount determines the scanline multipler
		-- - eg.	(4 downto 0) is 1:1
		-- 				(5 downto 0) is 2:1 (scan-doubling)
  	variable rowCount : std_logic_vector(3+PACE_VIDEO_V_SCALE downto 0);

		variable pal_entry  : pal_entry_typ;

  begin

		if rising_edge(clk) and clk_ena = '1' then

			-- different offsets for sprites & bullets/bombs
			if INDEX < 8 then
        x := reg_i.x;
        y := reg_i.y;
			else
        x := reg_i.x + 1;
		  	y := reg_i.y - 5;
			end if;
			-- video is clipped left and right (only 224 wide)
			x := x - (256-PACE_VIDEO_H_SIZE)/2;
			
			if video_ctl.hblank = '1' then

				xMat := false;
				-- stop sprites wrapping from bottom of screen
				if video_ctl.y = 0 then
					yMat := false;
				end if;
				
				if y = video_ctl.y then
					-- start counting sprite row
					rowCount := (others => '0');
					yMat := true;
				elsif rowCount(rowCount'left downto rowCount'left-4) = "10000" then
					yMat := false;				
				end if;

				-- sprites not visible before row 16				
				if ctl_i.ld = '1' then
					if yMat and y > 16 then
						if INDEX < 8 then
							rowStore := flipData;			-- load sprite data
						else
							-- bullet/bomb sprite
							if rowCount(rowCount'left downto rowCount'left-4) < 4 then
								rowStore := ('1', '1', others => '0');
							else
								rowStore := (others => '0');
							end if;
						end if;
					else
						rowStore := (others => '0');
					end if;
				end if;
						
			end if;
			
      if video_ctl.stb = '1' then
    
        if video_ctl.x = x then
          -- count up at left edge of sprite
          rowCount := rowCount + 1;
          -- start of sprite
          if video_ctl.x /= 0 and video_ctl.x < 240 then
            xMat := true;
          end if;
        end if;
        
        if xMat then
          -- shift in next pixel
          -- pel is pipelined to match the delay in the tilemap controller
          pel_r := pel_r(pel_r'left-2 downto 0) & rowStore(rowStore'left downto rowStore'left-1);
          rowStore := rowStore(rowStore'left-2 downto 0) & "00";
        end if;

      end if;

      -- extract R,G,B from colour palette
      -- apparently only 3 bits of colour info (aside from pel)
      pal_entry := pal(conv_integer(reg_i.colour(2 downto 0) & pel));
      rgb.r(rgb.r'left downto rgb.r'left-5) <= pal_entry(0);
      rgb.r(rgb.r'left-6 downto 0) <= (others => '0');
      rgb.g(rgb.g'left downto rgb.g'left-5) <= pal_entry(1);
      rgb.g(rgb.g'left-6 downto 0) <= (others => '0');
      rgb.b(rgb.b'left downto rgb.b'left-5) <= pal_entry(2);
      rgb.b(rgb.b'left-6 downto 0) <= (others => '0');

      -- set pixel transparency based on match
      ctl_o.set <= '0';
      --if xMat and pel /= "00" then
      if xMat and yMat and (pal_entry(0)(5 downto 4) /= "00" or
                            pal_entry(1)(5 downto 4) /= "00" or
                            pal_entry(2)(5 downto 4) /= "00") then
        ctl_o.set <= '1';
      end if;

		end if;

    -- generate sprite data address
    ctl_o.a(15 downto 4) <= reg_i.n;
    if reg_i.yflip = '1' then
      ctl_o.a(3 downto 0) <=  not rowCount(rowCount'left-1 downto rowCount'left-4);
    else
      ctl_o.a(3 downto 0) <= rowCount(rowCount'left-1 downto rowCount'left-4);
    end if;

  end process;

end architecture SYN;
