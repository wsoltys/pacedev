library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;    
use work.platform_variant_pkg.all;

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

  flipData(31 downto 16) <= flip_1 (ctl_i.d(31 downto 16), reg_i.xflip);
  flipData(15 downto 0) <= flip_1 (ctl_i.d(15 downto 0), reg_i.xflip);
  
	process (clk, clk_ena)

   	variable rowStore : std_logic_vector(31 downto 0);  -- saved row of spt to show during visibile period
		variable pel      : std_logic_vector(1 downto 0);
    variable x        : std_logic_vector(video_ctl.x'range);
    variable y        : std_logic_vector(video_ctl.y'range);
    variable yMat     : boolean;      -- raster is between first and last line of sprite
    variable xMat     : boolean;      -- raster in between left edge and end of line

		-- the width of rowCount determines the scanline multipler
		-- - eg.	(4 downto 0) is 1:1
		-- 				(5 downto 0) is 2:1 (scan-doubling)
  	variable rowCount : unsigned(3+PACE_VIDEO_V_SCALE downto 0);
    alias row         : unsigned(4 downto 0) is 
                          rowCount(rowCount'left downto rowCount'left-4);

    variable tbl_i      : std_logic_vector(5 downto 0);   -- 64 table entries
    variable pal_i      : integer range 0 to 15;
		variable pal_rgb    : pal_rgb_t;
    
  begin

		if rising_edge(clk) then
      if clk_ena = '1' then

        x := std_logic_vector(unsigned(video_ctl.x) - PACE_VIDEO_PIPELINE_DELAY);
        -- not entirely sure why we need an offset of 19?
        y := std_logic_vector(to_unsigned(257-19,y'length) - unsigned(video_ctl.y));
        
        if video_ctl.hblank = '1' then

          xMat := false;
          -- stop sprites wrapping from bottom of screen
          if unsigned(y) = 0 then
            yMat := false;
          end if;
          
          if reg_i.y = y then
            -- start counting sprite row
            rowCount := (others => '0');
            yMat := true;
          elsif row = "10000" then
            yMat := false;				
          end if;

          -- sprites not visible before row 16				
          if ctl_i.ld = '1' then
            if yMat and unsigned(y) > 16 then
              rowStore := flipData;			-- load sprite data
            else
              rowStore := (others => '0');
            end if;
          end if;
              
        end if;
        
        if video_ctl.stb = '1' then
      
          if x = reg_i.x then
            -- count up at left edge of sprite
            rowCount := rowCount + 1;
            -- start of sprite
            if unsigned(x) /= 0 and unsigned(x) < 240 then
              xMat := true;
            end if;
          end if;
          
          if xMat then
            -- shift in next pixel
            pel := rowStore(rowStore'left) & rowStore(rowStore'left-16);
            rowStore(31 downto 16) := rowStore(30 downto 16) & '0';
            rowStore(15 downto 0) := rowStore(14 downto 0) & '0';
          end if;

        end if;

        -- the sprite table is pre-calculated and
        --   contains 64 entries for palette look-up
        -- the palette itself contains just 16 entries
        tbl_i := reg_i.colour(3 downto 0) & pel;
        pal_i := sprite_table(to_integer(unsigned(tbl_i)));
        pal_rgb := sprite_pal(pal_i);
        rgb.r <= pal_rgb(0) & "00";
        rgb.g <= pal_rgb(1) & "00";
        rgb.b <= pal_rgb(2) & "00";

        -- set pixel transparency based on match
        ctl_o.set <= '0';
        if xMat and pel /= "00" then
          if graphics_i.bit8(0)(4) = '1' then
            ctl_o.set <= '1';
          end if;
        end if;

      end if; -- clk_ena='1'
    end if; -- rising_edge(clk)
    
    -- generate sprite data address
    ctl_o.a(11 downto 5) <= reg_i.n(6 downto 0);
    ctl_o.a(4) <= '0'; -- dual-port RAM
    if reg_i.yflip = '0' then
      ctl_o.a(3 downto 0) <= std_logic_vector(row(3 downto 0));
    else
      ctl_o.a(3 downto 0) <=  not std_logic_vector(row(3 downto 0));
    end if;

  end process;

end architecture SYN;
