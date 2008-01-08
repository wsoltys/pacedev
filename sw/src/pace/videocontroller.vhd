library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity VGAController is
	generic
	(
		COMPOSITE_VIDEO : boolean := true
	);
  port
  (
    clk        	: in  std_logic;
		reset				: in std_logic;

    strobe     	: out std_logic;                          
		pixel_x			: out std_logic_vector(9 downto 0);
		pixel_y			: out std_logic_vector(9 downto 0);
    hblank     	: out std_logic;                          
    vblank     	: out std_logic;                          

		r_i					: in std_logic_vector(9 downto 0);
		g_i					: in std_logic_vector(9 downto 0);
		b_i					: in std_logic_vector(9 downto 0);

    red        	: out std_logic_vector(9 downto 0);       
    green      	: out std_logic_vector(9 downto 0);       
    blue       	: out std_logic_vector(9 downto 0);       
    hsync      	: out std_logic;
    vsync      	: out std_logic
  );
end VGAController;

architecture SYN of VGAController is

	-- 14.31818 MHz : 256 X 384
  constant H_FRONT_PORCH      : integer := 11-1+1;
  constant H_HORIZ_SYNC       : integer := H_FRONT_PORCH + 35+2;
  constant H_BACK_PORCH       : integer := H_HORIZ_SYNC + 34+1;
  constant H_LEFT_BORDER      : integer := H_BACK_PORCH + 61+1;
  constant H_VIDEO            : integer := H_LEFT_BORDER + 256;
  constant H_RIGHT_BORDER     : integer := H_VIDEO + 61+1;
  constant H_TOTAL_PER_LINE   : integer := H_RIGHT_BORDER;

	-- not used - for reference only
  constant V_FRONT_PORCH      : integer := 2-1;
  constant V_VERTICAL_SYNC    : integer := V_FRONT_PORCH + 2;
  constant V_BACK_PORCH       : integer := V_VERTICAL_SYNC + 25;
  constant V_TOP_BORDER       : integer := V_BACK_PORCH + 8; -- + 48;
  constant V_VIDEO            : integer := V_TOP_BORDER + 480; --384;
  constant V_BOTTOM_BORDER    : integer := V_VIDEO + 8; -- + 48;
  constant V_TOTAL_PER_FIELD  : integer := V_BOTTOM_BORDER;

  constant V2_FRONT_PORCH      : integer := 2;
  constant V2_VERTICAL_SYNC    : integer := V2_FRONT_PORCH + 2;
  constant V2_BACK_PORCH       : integer := V2_VERTICAL_SYNC + 12;
  constant V2_TOP_BORDER       : integer := V2_BACK_PORCH + 3; --27;
  constant V2_VIDEO            : integer := V2_TOP_BORDER + 240; --192;
  constant V2_BOTTOM_BORDER    : integer := V2_VIDEO + 3; --27;
  constant V2_TOTAL_PER_FIELD  : integer := V2_BOTTOM_BORDER;

  -- VGA signals

	alias vga_pix_clk						: std_logic is clk;		-- 14M31818 Hz
  signal vga_hsync            : std_logic;
  signal vga_vsync            : std_logic;
  signal vga_hblank           : std_logic;
  signal vga_vblank           : std_logic;
	signal vga_linebuf_addr			: std_logic_vector(8 downto 0);
	signal vga_data							: std_logic_vector(7 downto 0);
		
	-- CVBS signals
	
	signal cvbs_pix_clk_ena			: std_logic;	-- 7M15909 Hz
  signal cvbs_hsync           : std_logic;
  signal cvbs_vsync           : std_logic;
  signal cvbs_hblank          : std_logic;
  signal cvbs_vblank          : std_logic;
	signal cvbs_red							: std_logic_vector(7 downto 0) := (others => '0');
	signal cvbs_green						: std_logic_vector(7 downto 0) := (others => '0');
	signal cvbs_blue						: std_logic_vector(7 downto 0) := (others => '0');
	signal cvbs_linebuf_we			: std_logic;
	signal cvbs_linebuf_addr		: std_logic_vector(8 downto 0);
  signal cvbs_dd              : std_logic_vector(7 downto 0); -- CVBS data in latch
	signal cvbs_data						: std_logic_vector(7 downto 0); -- CVBS data out

  -- character rom signals
  signal char_addr            : std_logic_vector(11 downto 0);
  signal char_data            : std_logic_vector(7 downto 0);
	signal cvbs_linebuf_we_r    : std_logic;
	signal cvbs_linebuf_addr_r  : std_logic_vector(8 downto 0);
	signal cvbs_linebuf_we_rr   : std_logic;
	signal cvbs_linebuf_addr_rr : std_logic_vector(8 downto 0);
	signal cvbs_dd_r						: std_logic_vector(7 downto 0);

	-- this was an output port!
	signal gs_cvbs							: std_logic_vector(7 downto 0);
	
  -- used by both CVBS and VGA
  shared variable v_count : std_logic_vector(8 downto 0);

  --shared variable row_v : std_logic_vector(8 downto 0);

begin

  process (vga_pix_clk, reset)
    variable h_count : integer range 0 to H_TOTAL_PER_LINE;
    variable pix_count : std_logic_vector(7 downto 0);
    variable old_vga_vblank : std_logic;
		variable row_v : std_logic_vector(8 downto 0);
  begin
    if reset = '1' then
      h_count := 0;
      vga_hsync <= '1';
      vga_vsync <= '1';
      vga_hblank <= '0';
      cvbs_pix_clk_ena <= '0';
			row_v := (others => '0');
    elsif rising_edge (vga_pix_clk) then

      cvbs_pix_clk_ena <= not cvbs_pix_clk_ena;

      -- start hsync when cvbs comes out of vblank
      if old_vga_vblank = '1' and vga_vblank = '0' then
        h_count := 0;
				row_v := (others => '0');
      else
        if h_count = H_TOTAL_PER_LINE then
          h_count := 0;
					row_v := row_v + 1;
        else
          if h_count = H_FRONT_PORCH then
            vga_hsync <= '0';
          elsif h_count = H_HORIZ_SYNC then
            vga_hsync <= '1';
          elsif h_count = H_BACK_PORCH then
          elsif h_count = H_LEFT_BORDER then
            vga_hblank <= '0';
          elsif h_count = H_VIDEO then
            vga_hblank <= '1';
          elsif h_count = H_RIGHT_BORDER then
          end if;

          if h_count = H_LEFT_BORDER-1 then
            pix_count := (others => '0');
          else
            -- only valid during active video portion
            pix_count := pix_count + 1;
          end if;

          h_count := h_count + 1;
        end if;
      end if;

      -- vertical syncs, blanks are the same
      vga_vsync <= cvbs_vsync;

			if not COMPOSITE_VIDEO then
				-- generate pixel coordinates for map controller
				-- - note that x must be 0 during hblank
				if vga_hblank = '0' then
					pixel_x <= "00" & pix_count;
				else
					pixel_x <= (others => '0');
				end if;
				pixel_y <= '0' & row_v;
			end if;
			
      -- generate linebuffer address
      -- - alternate every 2nd line
      vga_linebuf_addr <= (not v_count(0)) & pix_count;

      old_vga_vblank := vga_vblank;

    end if;
  end process;

  process (vga_pix_clk, reset)
    variable h_count : integer range 0 to H_TOTAL_PER_LINE;
    variable pix_count : std_logic_vector(7 downto 0);
    variable row_v : std_logic_vector(8 downto 0);
  begin
    if reset = '1' then
    
      h_count := H_TOTAL_PER_LINE;
      v_count := conv_std_logic_vector(V2_TOTAL_PER_FIELD, 9);
      pix_count := (others => '0');
      cvbs_hsync <= '1';
      cvbs_vsync <= '1';
      cvbs_hblank <= '0';
      cvbs_vblank <= '1';
			vga_vblank <= '1';
      row_v := (others => '1');

    elsif rising_edge (vga_pix_clk) and cvbs_pix_clk_ena = '1' then

      if h_count = H_TOTAL_PER_LINE then
        h_count := 0;
        cvbs_red <= (others => '0');
        cvbs_blue <= (others => '0');
        if v_count = V2_TOTAL_PER_FIELD then
          v_count := (others => '0');
          cvbs_green <= (others => '0');
        else
          cvbs_green <= cvbs_green + 1;
          if v_count = V2_FRONT_PORCH then
            cvbs_vsync <= '0';
          elsif v_count = V2_VERTICAL_SYNC then
            cvbs_vsync <= '1';
          elsif v_count = V2_BACK_PORCH then
          elsif v_count = V2_TOP_BORDER then
            cvbs_green <= (others => '0');
            cvbs_vblank <= '0';
            row_v := (others => '1');
					elsif v_count = V2_TOP_BORDER+1 then
						vga_vblank <= '0';
          elsif v_count = V2_VIDEO then
            cvbs_vblank <= '1';
					elsif v_count = V2_VIDEO+1 then
						vga_vblank <= '1';
          end if;
          v_count := v_count + 1;
          row_v := row_v + 1;
        end if;
      else
        cvbs_red <= cvbs_red + 1;
				cvbs_blue <= cvbs_blue + 1;
        if h_count = H_FRONT_PORCH then
          cvbs_hsync <= '0';
        elsif h_count = H_HORIZ_SYNC then
          cvbs_hsync <= '1';
        elsif h_count = H_BACK_PORCH then
        elsif h_count = H_LEFT_BORDER then
          cvbs_red <= (others => '0');
					cvbs_blue <= cvbs_green;
          cvbs_hblank <= '0';
          pix_count := (others => '1');
        elsif h_count = H_VIDEO then
          cvbs_hblank <= '1';
        elsif h_count = H_RIGHT_BORDER then
        else
        end if;

        -- only valid during active video portion
        pix_count := pix_count + 1;

        h_count := h_count + 1;
      end if;

			if COMPOSITE_VIDEO then
				-- generate pixel coordinates for map controller
				-- - note that x must be 0 during hblank
				if cvbs_hblank = '0' then
					pixel_x <= "00" & pix_count;
				else
					pixel_x <= (others => '0');
				end if;
				pixel_y <= '0' & row_v;
			
	      -- generate linebuffer address
	      -- - alternate every line
	      cvbs_linebuf_addr <= v_count(0) & pix_count;

	      -- pipeline writes to linebuf because data is delayed 1 clock as well!
				cvbs_linebuf_we_r <= cvbs_linebuf_we;
				cvbs_linebuf_addr_r <= cvbs_linebuf_addr;
				cvbs_linebuf_we_rr <= cvbs_linebuf_we_r;
				cvbs_linebuf_addr_rr <= cvbs_linebuf_addr_r;
			end if;

    end if;
  end process;

  hsync <= vga_hsync;
  vsync <= vga_vsync;

	GEN_VGA_OUTPUT : if not COMPOSITE_VIDEO generate

		strobe <= '1';
		hblank <= vga_hblank;
		vblank <= vga_vblank;

	  process (vga_pix_clk)
	  begin
	    if rising_edge(vga_pix_clk) then
	      if (vga_hblank = '0' and vga_vblank = '0') then
	        red <= r_i;
	        green <= g_i;
	        blue <= b_i;
	      else
	        red <= (others => '0');
	        green <= (others => '0');
	        blue <= (others => '0');
	      end if;
			end if;
		end process;
					
	end generate GEN_VGA_OUTPUT;
	
	GEN_LINE_BUFFER : if COMPOSITE_VIDEO generate
	
		-- video data control signals
  	strobe <= cvbs_pix_clk_ena;
    hblank <= cvbs_hblank;
    vblank <= cvbs_vblank;

    -- fudge - 2-bit resolution only atm!
    cvbs_data <= "00" & r_i(9 downto 8) & g_i(9 downto 8) & b_i(9 downto 8);

	  -- only write to the linebuffer during active display
	  cvbs_linebuf_we <= not (cvbs_vblank or cvbs_hblank);

		-- video output
		gs_cvbs <= 	'0' & cvbs_vsync & "000000" when cvbs_vblank = '1' else
					  		'0' & cvbs_hsync & "000000" when cvbs_hblank = '1' else
					  		cvbs_data;

	  process (vga_pix_clk)
	  begin
	    if rising_edge(vga_pix_clk) then
	      if (vga_hblank = '0' and vga_vblank = '0') then
	        red <= vga_data(5 downto 4) & "00000000";
	        green <= vga_data(3 downto 2) & "00000000";
	        blue <= vga_data(1 downto 0) & "00000000";
	      else
	        red <= (others => '0');
	        green <= (others => '0');
	        blue <= (others => '0');
	      end if;
	    end if;
	  end process;

		linebuf : entity work.dpram_1r1w
			generic map
			(
				numwords_a	=> 512,
				widthad_a		=> 9
			)
			port map
			(
				wrclock		=> vga_pix_clk,
				wrclocken	=> cvbs_pix_clk_ena,
				wren			=> cvbs_linebuf_we_rr,
				wraddress	=> cvbs_linebuf_addr_rr,
				data			=> cvbs_data,

				rdclock		=> vga_pix_clk,
				rdaddress	=> vga_linebuf_addr,
				q					=> vga_data
			);

	end generate GEN_LINE_BUFFER;
	
end SYN;

