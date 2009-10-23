library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

  alias palette_bank  : std_logic is graphics_i.bit8_1(1);
  alias clut_bank     : std_logic is graphics_i.bit8_1(0);
  
  signal flipData : std_logic_vector(31 downto 0);   -- flipped row data
   
begin

  flipData <= flip_row (ctl_i.d, reg_i.xflip);
  
	process (clk, clk_ena, reg_i)

   	variable rowStore : std_logic_vector(31 downto 0);  -- saved row of spt to show during visibile period
		--alias pel     : std_logic_vector(1 downto 0) is rowStore(31 downto 30);
		variable pel      : std_logic_vector(1 downto 0);
    variable x        : unsigned(video_ctl.x'range);
    variable y        : unsigned(video_ctl.y'range);
    variable yMat     : boolean;    -- raster is between first and last line of sprite
    variable xMat     : boolean;    -- raster in between left edge and end of line

		-- the width of rowCount determines the scanline multipler
		-- - eg.	(4 downto 0) is 1:1
		-- 				(5 downto 0) is 2:1 (scan-doubling)
  	variable rowCount : std_logic_vector(3+PACE_VIDEO_V_SCALE downto 0);

		variable pal_i : std_logic_vector(3 downto 0);
		variable clut_entry : clut_entry_typ;
		variable pal_entry : pal_entry_typ;

  begin

		if rising_edge(clk) and clk_ena = '1' then

      -- the 1st 3 sprites have an off-by-one bug in pacman (only)
      if INDEX < 3 then
        x := unsigned(reg_i.x) - XOFFSETHACK + 1;
      else
        x := unsigned(reg_i.x) + 1;
      end if;
      y := unsigned(reg_i.y) + 16;    -- offset adjustment for sprites
      -- video is clipped left and right (only 224 wide)
      x := x - (256-PACE_VIDEO_H_SIZE)/2;
      
			if video_ctl.hblank = '1' then

				xMat := false;
				-- stop sprites wrapping from bottom of screen
				if unsigned(video_ctl.y) = 0 then
					yMat := false;
				end if;
				
				if y = unsigned(video_ctl.y) then
					-- start counting sprite row
					rowCount := (others => '0');
					yMat := true;
				elsif rowCount(rowCount'left downto rowCount'left-4) = "10000" then
					yMat := false;				
				end if;

				-- sprites not visible before row 16				
				if ctl_i.ld = '1' then
					if yMat and y > 16 then
						rowStore := flipData;			-- load sprite data
					else
						rowStore := (others => '0');
					end if;
				end if;
						
			end if;
			
			if video_ctl.stb = '1' then
			
				if unsigned(video_ctl.x) = x then
					-- count up at left edge of sprite
					rowCount := std_logic_vector(unsigned(rowCount) + 1);
					-- start of sprite
					if unsigned(video_ctl.x) /= 0 and unsigned(video_ctl.x) < 240 then
						xMat := true;
					end if;
				end if;
				
				if xMat then
          -- shift in next pixel
          --pel := rowStore(rowStore'left downto rowStore'left-pel'length+1);
          -- reverse bits
          pel := rowStore(rowStore'left-1) & rowStore(rowStore'left);
          rowStore := rowStore(rowStore'left-2 downto 0) & "00";
				end if;

      end if;

      -- extract R,G,B from colour palette
      clut_entry := clut(to_integer(unsigned(clut_bank & reg_i.colour(4 downto 0))));
      pal_i := clut_entry(to_integer(unsigned(pel)));
      pal_entry := pal(to_integer(unsigned(palette_bank & pal_i)));
      ctl_o.rgb.r <= pal_entry(0) & "0000";
      ctl_o.rgb.g <= pal_entry(1) & "0000";
      ctl_o.rgb.b <= pal_entry(2) & "0000";

      -- set pixel transparency based on match
      ctl_o.set <= '0';
      --if xMat and pel /= "00" then
      if xMat and yMat and (pal_entry(0)(5 downto 4) /= "00" or
                            pal_entry(1)(5 downto 4) /= "00" or
                            pal_entry(2)(5 downto 4) /= "00") then
        ctl_o.set <= '1';
      end if;

    end if;

	  ctl_o.a(15 downto 4) <= reg_i.n;
	  if reg_i.yflip = '1' then
	  	ctl_o.a(3 downto 0) <= not rowCount(rowCount'left-1 downto rowCount'left-4);		-- flip Y
	  else
	  	ctl_o.a(3 downto 0) <= rowCount(rowCount'left-1 downto rowCount'left-4);
	  end if;

  end process;

end SYN;
