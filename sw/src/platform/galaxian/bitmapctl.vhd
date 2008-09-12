library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Galaxian Starfield Generator
--

entity bitmapCtl_1 is          
port               
(
    clk         	: in std_logic;
		reset					: in std_logic;

		-- video control signals		
		stb           : in std_logic;
    hblank      	: in std_logic;
		vblank				: in std_logic;
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

	signal clk_ena_s : std_logic;
	
begin

	-- this is only required for pixel-doubling!!!
	process (clk, stb, reset)
	begin
		if reset = '1' then
			clk_ena_s <= '0';
		elsif rising_edge(clk) and stb = '1' then
			clk_ena_s <= not clk_ena_s;
		end if;
	end process;

	-- another, and possibly better solution, is to latch the value
	-- of the lfsr during hblank in every even line, and then
	-- preload the lfsr with that value during hblank of every
	-- odd line!?!
		
  process (clk, clk_ena_s, reset)

    -- need to count x ourselves as the controller double-clocks
    variable xcount          	: std_logic_vector(9 downto 0);

    variable lfsr_reg        	: std_logic_vector(16 downto 0);
    variable s               	: std_logic;

    variable latch_reg       	: std_logic_vector(16 downto 0);
    variable line_latch      	: std_logic_vector(16 downto 0);
		variable pix_y_0_r				: std_logic;
		
  begin

		if reset = '1' then
    	lfsr_reg := (others => '0');
    
		elsif rising_edge (clk) and clk_ena_s = '1' then

			-- default values
    	rgb.r <= (others => '0'); rgb.g <= (others => '0'); rgb.b <= (others => '0');

      -- this isn't right - need to re-think...
      -- also need to add pipeline delay to match longest delay
      if (vblank = '1') or (hblank = '1') then
      	xcount := (others => '0');
			else

				--if xcount = 0 then
				--	if pix_y(0) = pix_y_0_r then
				--		line_latch := lfsr_reg;
				--	else
				--		lfsr_reg := line_latch;
				--	end if;
				--	pix_y_0_r := pix_y(0);
				--end if;

      	-- paranoid - check within 256x256 square
        if (xcount(8) = '0') and (y(8) = '0') then

        	-- set the star colour
          if (lfsr_reg(16) = '0') and (lfsr_reg(7 downto 0) = "11111111") then
          	if ((xcount(0) xor y(3)) = '1') then
            	rgb.r(rgb.r'left downto rgb.r'left-1) <= not lfsr_reg(9 downto 8);
              rgb.g(rgb.g'left downto rgb.g'left-1) <= not lfsr_reg(11 downto 10);
              rgb.b(rgb.b'left downto rgb.b'left-1) <= not lfsr_reg(13 downto 12);
            end if;
          end if;

          if (xcount = 0) and (y = 0) then
          	-- start of screen
            if (s = '1') then
            	lfsr_reg(16 downto 0) := lfsr_reg(15 downto 0) & ((not lfsr_reg(16)) xor lfsr_reg(4));
            else
            	lfsr_reg(16 downto 0) := latch_reg(15 downto 0) & ((not latch_reg(16)) xor latch_reg(4));
            end if;
            s := not s;
          else
         		-- latch for scrolling effect
            if (xcount = 254) and (y = 254) then
            	latch_reg := lfsr_reg(15 downto 0) & ((not lfsr_reg(16)) xor lfsr_reg(4));
            end if;

            lfsr_reg(16 downto 0) := lfsr_reg(15 downto 0) & ((not lfsr_reg(16)) xor lfsr_reg(4));
          end if;

          --lfsr_reg = (lfsr_reg << 1) | (((~(lfsr_reg >> 16)) ^ (lfsr_reg >> 4)) & 1);
          --if (((lfsr_reg >> 16) & 1) == 0 && (lfsr_reg & 0xFF) == 0xFF)
          --{
          --    if ((x & 1) ^ ((y >> 3) & 1))
          --        putpixel (screen, x, y, (~(lfsr_reg >> 8)) & 0x3f);
          --}

          xcount := xcount + 1;

        end if; -- within 256x256
      end if; -- hblank = '1'
    end if; -- rising_edge(clk)

  end process;

	bitmap_a <= (others => '0');
	bitmap_on <= '1';
	
end SYN;

