library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity mc6847 is
	generic
	(
    CVBS_NOT_VGA  : boolean := true;
		CHAR_ROM_FILE	: string := ""
	);
	port
	(
		clk				: in std_logic;
		clk_ena   : in std_logic;
		reset			: in std_logic;

    hs_n    	: out std_logic;
    fs_n    	: out std_logic;
    da0     	: out std_logic;

		-- VRAM data
		dd				: in std_logic_vector(7 downto 0);
			
    -- VGA output
    hsync   	: out std_logic;
    vsync			: out std_logic;

    red     	: out std_logic_vector(7 downto 0);
    green   	: out std_logic_vector(7 downto 0);
    blue    	: out std_logic_vector(7 downto 0);

    cvbs    	: out std_logic_vector(7 downto 0)
	);
end mc6847;

architecture SYN of mc6847 is

  constant VGA_NOT_CVBS       : boolean := not CVBS_NOT_VGA;
  
  -- H_TOTAL_PER_LINE must be divisible by 16
  -- so that sys_count is the same on each line when
  -- the video comes out of hblank
  -- so the phase relationship between data from the 6847 and character timing is maintained

	-- 14.31818 MHz : 256 X 384
  constant H_FRONT_PORCH      : integer := 11-1+1;
  constant H_HORIZ_SYNC       : integer := H_FRONT_PORCH + 35+2;
  constant H_BACK_PORCH       : integer := H_HORIZ_SYNC + 34+1;
  constant H_LEFT_BORDER      : integer := H_BACK_PORCH + 61+1+3; -- adjust for hblank de-assert @sys_count=6
  constant H_VIDEO            : integer := H_LEFT_BORDER + 256;
  constant H_RIGHT_BORDER     : integer := H_VIDEO + 61+1-3;      -- "
  constant H_TOTAL_PER_LINE   : integer := H_RIGHT_BORDER;

  constant V_FRONT_PORCH      : integer := 2-1;
  constant V_VERTICAL_SYNC    : integer := V_FRONT_PORCH + 2;
  constant V_BACK_PORCH       : integer := V_VERTICAL_SYNC + 25;
  constant V_TOP_BORDER       : integer := V_BACK_PORCH + 8 + 48;
  constant V_VIDEO            : integer := V_TOP_BORDER +  384;
  constant V_BOTTOM_BORDER    : integer := V_VIDEO + 8 + 48;
  constant V_TOTAL_PER_FIELD  : integer := V_BOTTOM_BORDER;

  constant V2_FRONT_PORCH      : integer := 2;
  constant V2_VERTICAL_SYNC    : integer := V2_FRONT_PORCH + 2;
  constant V2_BACK_PORCH       : integer := V2_VERTICAL_SYNC + 12;
  constant V2_TOP_BORDER       : integer := V2_BACK_PORCH + 27;
  constant V2_VIDEO            : integer := V2_TOP_BORDER +  192;
  constant V2_BOTTOM_BORDER    : integer := V2_VIDEO + 27;
  constant V2_TOTAL_PER_FIELD  : integer := V2_BOTTOM_BORDER;

	component linebuf_dpram is
		port
		(
			data			: in std_logic_vector (7 downto 0);
			wren			: in std_logic  := '1';
			wraddress	: in std_logic_vector (8 downto 0);
			rdaddress	: in std_logic_vector (8 downto 0);
			wrclock		: in std_logic ;
			rdclock		: in std_logic ;
			q					: out std_logic_vector (7 downto 0)
		);
	end component;

  component tiledata is
  	port
  	(
  		address		: in std_logic_vector (11 downto 0);
  		clock		  : in std_logic;
  		q			    : out std_logic_vector (7 downto 0)
  	);
  end component;

  -- VGA signals

	alias vga_pix_clk						: std_logic is clk;		-- 14M31818 Hz
  signal vga_hsync            : std_logic;
  signal vga_vsync            : std_logic;
  signal vga_hblank           : std_logic;
  signal vga_vblank           : std_logic;
	signal vga_linebuf_addr			: std_logic_vector(8 downto 0);
	signal vga_data							: std_logic_vector(7 downto 0);
		
	-- CVBS signals
	
	signal cvbs_pix_clk					: std_logic;	-- 7M15909 Hz
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

  alias hs_int     	          : std_logic is cvbs_hblank;
  alias fs_int     	          : std_logic is cvbs_vblank;
  signal da0_int              : std_logic_vector(3 downto 0);

  -- character rom signals
  signal char_addr            : std_logic_vector(11 downto 0);
  signal char_data            : std_logic_vector(7 downto 0);
	signal cvbs_linebuf_we_r    : std_logic;
	signal cvbs_linebuf_addr_r  : std_logic_vector(8 downto 0);
	signal cvbs_linebuf_we_rr   : std_logic;
	signal cvbs_linebuf_addr_rr : std_logic_vector(8 downto 0);
	signal cvbs_dd_r						: std_logic_vector(7 downto 0);
	
  -- used by both CVBS and VGA
  shared variable v_count : std_logic_vector(8 downto 0);

  shared variable row_v : std_logic_vector(3 downto 0);

begin

  process (vga_pix_clk, reset)
    variable h_count : integer range 0 to H_TOTAL_PER_LINE;
    variable pix_count : std_logic_vector(7 downto 0);
    variable old_vga_vblank : std_logic;
  begin
    if reset = '1' then
      h_count := 0;
      vga_hsync <= '1';
      vga_vsync <= '1';
      vga_hblank <= '0';
      cvbs_pix_clk <= '0';

    elsif rising_edge (vga_pix_clk) and clk_ena = '1' then

      cvbs_pix_clk <= not cvbs_pix_clk;

      -- start hsync when cvbs comes out of vblank
      if old_vga_vblank = '1' and vga_vblank = '0' then
        h_count := 0;
      else
        if h_count = H_TOTAL_PER_LINE then
          h_count := 0;
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

      -- generate linebuffer address
      -- - alternate every 2nd line
      vga_linebuf_addr <= (not v_count(0)) & pix_count;

      old_vga_vblank := vga_vblank;

    end if;
  end process;

  process (cvbs_pix_clk, reset)
    variable h_count : integer range 0 to H_TOTAL_PER_LINE;
    variable pix_count : std_logic_vector(7 downto 0);
    variable old_cvbs_hblank : std_logic := '0';
    variable c1 : std_logic;
    --variable row_v : std_logic_vector(3 downto 0);
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
      da0_int <= (others => '0');
      old_cvbs_hblank := '0';
      row_v := (others => '0');

    elsif rising_edge (cvbs_pix_clk) then

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
          if row_v = 11 then
            row_v := (others => '0');
          else
            row_v := row_v + 1;
          end if;
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

        -- latch data on DD pins
        if pix_count(2 downto 0) = "000" then
          cvbs_dd <= dd;
        end if;
				cvbs_dd_r <= cvbs_dd;
				
        h_count := h_count + 1;
      end if;

			-- DA0 high during FS
			if cvbs_vblank = '1' then
				da0_int <= (others => '1');
			elsif cvbs_hblank = '1' then
        da0_int <= (others => '0');
      elsif old_cvbs_hblank = '1' and cvbs_hblank = '0' then
				da0_int <= "1000";
      else
        da0_int <= da0_int + 1;
			end if;

      -- generate character rom address
      char_addr <= cvbs_dd & row_v(3 downto 0);

      -- generate pixel from character rom data
      case pix_count(2 downto 0) is
        when "000" =>
          c1 := char_data(1);
        when "001" =>
          c1 := char_data(0);
        when "010" =>
          c1 := char_data(7);
        when "011" =>
          c1 := char_data(6);
        when "100" =>
          c1 := char_data(5);
        when "101" =>
          c1 := char_data(4);
        when "110" =>
          c1 := char_data(3);
        when "111" =>
          c1 := char_data(2);
        when others =>
      end case;
      
  		if cvbs_dd_r(7 downto 6) = "00" then
  		  -- inverse video
  		  if c1 = '1' then
    			cvbs_data <= "01000100"; -- dark green
  		  else
    			cvbs_data <= "01001100"; -- green
  		  end if;
  		elsif cvbs_dd_r(7) = '0' then
        -- normal video
  		  if c1 = '1' then
    			cvbs_data <= "01000000"; -- black
  		  else
    			cvbs_data <= "01001100"; -- green
  		  end if;
  		else
  	    -- semi-block graphics
	      if c1 = '1' then
			    case cvbs_dd_r(6 downto 4) is
    				when "000" => -- green
    					cvbs_data <= "01001100";
    				when "001" => -- yellow
    					cvbs_data <= "01111100";
    				when "010" => -- blue
    					cvbs_data <= "01000011";
    				when "011" => -- red
    					cvbs_data <= "01110000";
    				when "100" => -- white
    					cvbs_data <= "01111111";
    				when "101" => -- cyan
    					cvbs_data <= "01001111";
    				when "110" => -- magenta
    					cvbs_data <= "01110011";
    				when others => -- orange
    					cvbs_data <= "01111000";
			    end case;
		    else
			    cvbs_data <= "01000000"; -- black
		    end if;
  		end if;

      -- generate linebuffer address
      -- - alternate every line
      cvbs_linebuf_addr <= v_count(0) & pix_count;

      -- pipeline writes to linebuf because data is delayed 1 clock as well!
			cvbs_linebuf_we_r <= cvbs_linebuf_we;
			cvbs_linebuf_addr_r <= cvbs_linebuf_addr;
			cvbs_linebuf_we_rr <= cvbs_linebuf_we_r;
			cvbs_linebuf_addr_rr <= cvbs_linebuf_addr_r;

      old_cvbs_hblank := cvbs_hblank;

    end if;
  end process;

  -- only write to the linebuffer during active display
  cvbs_linebuf_we <= not (cvbs_vblank or cvbs_hblank);
  --cvbs_data <= "01" & cvbs_red(7 downto 6) & cvbs_green(7 downto 6) & cvbs_blue(7 downto 6);
  --cvbs_data <= "01" & cvbs_dd(6 downto 5) & cvbs_dd(4 downto 3) & cvbs_dd(2 downto 1);

	cvbs <= '0' & cvbs_vsync & "000000" when cvbs_vblank = '1' else
				  '0' & cvbs_hsync & "000000" when cvbs_hblank = '1' else
				  cvbs_data;

  -- assign outputs

  hs_n <= not hs_int;
  fs_n <= not fs_int;
  da0 <= da0_int(3);      -- fudge - divide by 8

	GEN_CVBS_OUTPUT : if CVBS_NOT_VGA generate

		process (cvbs_pix_clk)
		begin
			if rising_edge(cvbs_pix_clk) then
				if cvbs_hblank = '0' and cvbs_vblank = '0' then				
					red <= cvbs_data(5 downto 4) & "000000";
					green <= cvbs_data(3 downto 2) & "000000";
					blue <= cvbs_data(1 downto 0) & "000000";
				else
	        red <= (others => '0');
	        green <= (others => '0');
	        blue <= (others => '0');
				end if;
			end if;
		end process;
				
		hsync <= cvbs_hsync;
		vsync <= cvbs_vsync;
		
	end generate GEN_CVBS_OUTPUT;
	
	GEN_VGA_OUTPUT : if VGA_NOT_CVBS generate
	
	  process (vga_pix_clk)
	  begin
	    if rising_edge(vga_pix_clk) and clk_ena = '1' then
	      if (vga_hblank = '0' and vga_vblank = '0') then
	        red <= vga_data(5 downto 4) & "000000";
	        green <= vga_data(3 downto 2) & "000000";
	        blue <= vga_data(1 downto 0) & "000000";
	      else
	        red <= (others => '0');
	        green <= (others => '0');
	        blue <= (others => '0');
	      end if;
	    end if;
	  end process;

	  hsync <= vga_hsync;
	  vsync <= vga_vsync;
	
	end generate GEN_VGA_OUTPUT;
	
	linebuf : entity work.dpram_1r1w
		generic map
		(
			numwords_a	=> 512,
			widthad_a		=> 9
		)
		port map
		(
			wrclock		=> cvbs_pix_clk,
			wren			=> cvbs_linebuf_we_rr,
			wraddress	=> cvbs_linebuf_addr_rr,
			data			=> cvbs_data,

			rdclock		=> vga_pix_clk,
			rdaddress	=> vga_linebuf_addr,
			q					=> vga_data
		);

  -- Character ROM
  charrom_inst : entity work.sprom
		generic map
		(
			init_file				=> CHAR_ROM_FILE,
			numwords_a			=> 4096,
			widthad_a				=> 12
		)                               
    port map
    (
      clock  		  => clk,
      address 	  => char_addr,
      q 			    => char_data
    );

end SYN;

