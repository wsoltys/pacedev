library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity mc6847 is
	generic
	(
		T1_VARIANT      : boolean := false;
		CHAR_ROM_FILE	  : string := "";
		
    CVBS_NOT_VGA    : boolean := true
	);
	port
	(
		clk				: in std_logic;
		clk_ena   : in std_logic;
		reset			: in std_logic;

    -- address output lines
    da0     	: out std_logic;

    -- data inputs
		dd				: in std_logic_vector(7 downto 0);

    -- synchronising outputs
    hs_n    	: out std_logic;
    fs_n    	: out std_logic;

    -- mode control lines
    an_g      : in std_logic;
    an_s      : in std_logic;
    intn_ext  : in std_logic;
    gm        : in std_logic_vector(2 downto 0);
    css       : in std_logic;
    inv       : in std_logic;

    -- VGA output
    red     	: out std_logic_vector(7 downto 0);
    green   	: out std_logic_vector(7 downto 0);
    blue    	: out std_logic_vector(7 downto 0);
    hsync   	: out std_logic;
    vsync			: out std_logic;
    
    -- CVBS output
    cvbs      : out std_logic_vector(7 downto 0)
	);
end mc6847;

architecture SYN of mc6847 is

  constant VGA_NOT_CVBS         : boolean := not CVBS_NOT_VGA;
  
  constant BUILD_DEBUG          : boolean := false;
  constant DEBUG_AN_G           : std_logic := '0';
  constant DEBUG_AN_S           : std_logic := '1';
  constant DEBUG_INTN_EXT       : std_logic := '1';
  constant DEBUG_GM             : std_logic_vector(2 downto 0) := (others => '0');
  constant DEBUG_CSS            : std_logic := '1';
  constant DEBUG_INV            : std_logic := '0';
  
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

  -- (not used)
  --constant V_FRONT_PORCH      : integer := 2-1;
  --constant V_VERTICAL_SYNC    : integer := V_FRONT_PORCH + 2;
  --constant V_BACK_PORCH       : integer := V_VERTICAL_SYNC + 25;
  --constant V_TOP_BORDER       : integer := V_BACK_PORCH + 8 + 48;
  --constant V_VIDEO            : integer := V_TOP_BORDER +  384;
  --constant V_BOTTOM_BORDER    : integer := V_VIDEO + 8 + 48;
  --constant V_TOTAL_PER_FIELD  : integer := V_BOTTOM_BORDER;

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

  -- internal version of control ports
  
  signal an_g_s                 : std_logic;
  signal an_s_s                 : std_logic;
  signal intn_ext_s             : std_logic;
  signal gm_s                   : std_logic_vector(2 downto 0);
  signal css_s                  : std_logic;
  signal inv_s                  : std_logic;
  
  -- VGA signals

  signal vga_hsync            : std_logic;
  signal vga_vsync            : std_logic;
  signal vga_hblank           : std_logic;
  signal vga_vblank           : std_logic;
	signal vga_linebuf_addr			: std_logic_vector(8 downto 0);
	signal vga_data							: std_logic_vector(7 downto 0);
		
	-- CVBS signals
	
	signal cvbs_clk_ena					: std_logic;	        -- PAL/NTSC*2
  signal cvbs_hsync           : std_logic;
  signal cvbs_vsync           : std_logic;
  signal cvbs_hblank          : std_logic;
  signal cvbs_vblank          : std_logic;
	signal cvbs_linebuf_we			: std_logic;
	signal cvbs_linebuf_addr		: std_logic_vector(8 downto 0);
  signal cvbs_dd              : std_logic_vector(7 downto 0); -- CVBS data in latch
	signal cvbs_data						: std_logic_vector(7 downto 0); -- CVBS data out
	--signal semi4_dd             : std_logic_vector(7 downto 0);
	signal semi6_dd             : std_logic_vector(7 downto 0);
  signal rg123_dd             : std_logic_vector(7 downto 0);
  signal rg6_dd               : std_logic_vector(7 downto 0);
  signal cg1_dd               : std_logic_vector(7 downto 0);
  signal cg236_dd             : std_logic_vector(7 downto 0);
  
  alias hs_int     	          : std_logic is cvbs_hblank;
  alias fs_int     	          : std_logic is cvbs_vblank;
  signal da0_int              : std_logic_vector(4 downto 0);

  -- character rom signals
  signal char_addr            : std_logic_vector(10 downto 0);
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

  -- assign control inputs for debug/release build
  an_g_s <= DEBUG_AN_G when BUILD_DEBUG else an_g;
  an_s_s <= DEBUG_AN_S when BUILD_DEBUG else an_s;
  intn_ext_s <= DEBUG_INTN_EXT when BUILD_DEBUG else intn_ext;
  gm_s <= DEBUG_GM when BUILD_DEBUG else gm;
  css_s <= DEBUG_CSS when BUILD_DEBUG else css;
  inv_s <= DEBUG_INV when BUILD_DEBUG else inv;

  -- generate horizontal timing for VGA
  -- generate line buffer address for reading VGA data
  PROC_VGA : process (clk, reset)
    variable h_count : integer range 0 to H_TOTAL_PER_LINE;
    variable pix_count : std_logic_vector(7 downto 0);
    variable vga_vblank_r : std_logic;
  begin
    if reset = '1' then
      h_count := 0;
      vga_hsync <= '1';
      vga_vsync <= '1';
      vga_hblank <= '0';
      cvbs_clk_ena <= '0';

    elsif rising_edge (clk) and clk_ena = '1' then

      cvbs_clk_ena <= not cvbs_clk_ena;

      -- start hsync when cvbs comes out of vblank
      if vga_vblank_r = '1' and vga_vblank = '0' then
        h_count := 0;
      else
        if h_count = H_TOTAL_PER_LINE then
          h_count := 0;
        else
          h_count := h_count + 1;
        end if;
                
        if h_count = H_FRONT_PORCH then
          vga_hsync <= '0';
        elsif h_count = H_HORIZ_SYNC then
          vga_hsync <= '1';
        elsif h_count = H_BACK_PORCH then
          null;
        elsif h_count = H_LEFT_BORDER then
          vga_hblank <= '0';
          pix_count := (others => '0');
        elsif h_count = H_VIDEO then
          vga_hblank <= '1';
        elsif h_count = H_RIGHT_BORDER then
          null;
        else
          pix_count := pix_count + 1;
        end if;

      end if;

      -- vertical syncs, blanks are the same
      vga_vsync <= cvbs_vsync;

      -- generate linebuffer address
      -- - alternate every 2nd line
      vga_linebuf_addr <= (not v_count(0)) & pix_count;

      vga_vblank_r := vga_vblank;

    end if;
  end process;

  PROC_CVBS : process (cvbs_clk_ena, reset)
    variable h_count : integer range 0 to H_TOTAL_PER_LINE;
    variable pix_count : std_logic_vector(7 downto 0);
    variable old_cvbs_hblank : std_logic := '0';
    variable semi4_dd : std_logic_vector(7 downto 0);
    variable semi6_dd : std_logic_vector(7 downto 0);
    variable luma : std_logic;
    variable chroma : std_logic_vector(2 downto 0);
    --variable row_v : std_logic_vector(3 downto 0);
    -- for debug only
    variable active_v_count : std_logic_vector(v_count'range);
    variable an_s_r : std_logic_vector(3 downto 0);
    alias an_s_rr : std_logic is an_s_r(an_s_r'left);
    variable inv_r : std_logic_vector(3 downto 0);
    alias inv_rr : std_logic is inv_r(inv_r'left);
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
      an_s_r := (others => '0');
      inv_r := (others => '0');

    elsif rising_edge (cvbs_clk_ena) then

      if h_count = H_TOTAL_PER_LINE then
        h_count := 0;
        if v_count = V2_TOTAL_PER_FIELD then
          v_count := (others => '0');
        else
          v_count := v_count + 1;
        end if;

        -- VGA vblank is 1 line behind CVBS
        -- - because we need to fill the line buffer
        vga_vblank <= cvbs_vblank;
        
        if v_count = V2_FRONT_PORCH then
          cvbs_vsync <= '0';
        elsif v_count = V2_VERTICAL_SYNC then
          cvbs_vsync <= '1';
        elsif v_count = V2_BACK_PORCH then
          null;
        elsif v_count = V2_TOP_BORDER then
          cvbs_vblank <= '0';
          row_v := (others => '0');
          active_v_count := (others => '0');        -- debug only
        elsif v_count = V2_VIDEO then
          cvbs_vblank <= '1';
        else
          if row_v = 11 then
            row_v := (others => '0');
            active_v_count := active_v_count + 5;   -- debug only
          else
            row_v := row_v + 1;
            active_v_count := active_v_count + 1;   -- debug only
          end if;
        end if;
        
      else
        h_count := h_count + 1;
        
        if h_count = H_FRONT_PORCH then
          cvbs_hsync <= '0';
        elsif h_count = H_HORIZ_SYNC then
          cvbs_hsync <= '1';
        elsif h_count = H_BACK_PORCH then
        elsif h_count = H_LEFT_BORDER then
          cvbs_hblank <= '0';
          pix_count := (others => '0');
        elsif h_count = H_VIDEO then
          cvbs_hblank <= '1';
          -- only needed for debug???
          pix_count := pix_count + 1;
        elsif h_count = H_RIGHT_BORDER then
          null;
        else
          pix_count := pix_count + 1;
        end if;

        -- latch data on DD pins
        if pix_count(3 downto 0) = "0000" then
          cg1_dd <= dd;
          rg123_dd <= dd;
        elsif pix_count(1 downto 0) = "11" then
          cg1_dd <= cg1_dd(cg1_dd'left-2 downto 0) & "00";
        elsif pix_count(0) = '1' then
          rg123_dd <= rg123_dd(rg123_dd'left-1 downto 0) & '0';
        end if;
        if pix_count(2 downto 0) = "000" then
          if BUILD_DEBUG then
            --cvbs_dd <= active_v_count(6 downto 4) & pix_count(7 downto 3);
            cvbs_dd <= active_v_count(6 downto 4) & 
                        pix_count(7) & not pix_count(3) & pix_count(4) & not pix_count(6) & pix_count(5);
            if row_v < 6 then
              semi4_dd := pix_count(6) & pix_count(6) & pix_count(6) & pix_count(6) &
                          pix_count(5) & pix_count(5) & pix_count(5) & pix_count(5);
            else
              semi4_dd := pix_count(4) & pix_count(4) & pix_count(4) & pix_count(4) &
                          pix_count(3) & pix_count(3) & pix_count(3) & pix_count(3);
            end if;
            if row_v < 4 then
              semi6_dd := active_v_count(4) & active_v_count(4) & active_v_count(4) & active_v_count(4) &
                          pix_count(7) & pix_count(7) & pix_count(7) & pix_count(7);
            elsif row_v < 8 then
              semi6_dd := pix_count(6) & pix_count(6) & pix_count(6) & pix_count(6) &
                          pix_count(5) & pix_count(5) & pix_count(5) & pix_count(5);
            else
              semi6_dd := pix_count(4) & pix_count(4) & pix_count(4) & pix_count(4) &
                          pix_count(3) & pix_count(3) & pix_count(3) & pix_count(3);
            end if;
          else
            cvbs_dd <= dd;
            rg6_dd <= dd;
            cg236_dd <= dd;
            if row_v < 6 then
              semi4_dd := dd(3) & dd(3) & dd(3) & dd(3) & dd(2) & dd(2) & dd(2) & dd(2);
            else
              semi4_dd := dd(1) & dd(1) & dd(1) & dd(1) & dd(0) & dd(0) & dd(0) & dd(0);
            end if;
            if row_v < 4 then
              semi6_dd := dd(5) & dd(5) & dd(5) & dd(5) & dd(4) & dd(4) & dd(4) & dd(4);
            elsif row_v < 8 then
              semi6_dd := dd(3) & dd(3) & dd(3) & dd(3) & dd(2) & dd(2) & dd(2) & dd(2);
            else
              semi6_dd := dd(1) & dd(1) & dd(1) & dd(1) & dd(0) & dd(0) & dd(0) & dd(0);
            end if;
          end if;
        else
          rg6_dd <= rg6_dd(rg6_dd'left-1 downto 0) & '0';
          if pix_count(0) = '1' then
            cg236_dd <= cg236_dd(cg236_dd'left-2 downto 0) & "00";
          end if;
        end if;
				cvbs_dd_r <= cvbs_dd;
				
      end if;

			-- DA0 high during FS
			if cvbs_vblank = '1' then
				da0_int <= (others => '1');
			elsif cvbs_hblank = '1' then
        da0_int <= (others => '0');
      elsif old_cvbs_hblank = '1' and cvbs_hblank = '0' then
				da0_int <= "01000";
      else
        da0_int <= da0_int + 1;
			end if;

      -- generate character rom address
      char_addr <= '0' & cvbs_dd(5 downto 0) & row_v(3 downto 0);

      -- generate pixel from character rom data
      -- *** replace this with a shift register
      case pix_count(2 downto 0) is
        when "000" =>
          luma := char_data(1);
        when "001" =>
          luma := char_data(0);
        when "010" =>
          luma := char_data(7);
        when "011" =>
          luma := char_data(6);
        when "100" =>
          luma := char_data(5);
        when "101" =>
          luma := char_data(4);
        when "110" =>
          luma := char_data(3);
        when "111" =>
          luma := char_data(2);
        when others =>
      end case;
      
      -- alpha/graphics mode
      if an_g_s = '0' then
        -- alphanumeric & semi-graphics mode
        if an_s_rr = '0' then
          -- alphanumeric
          if intn_ext_s = '0' then
            -- internal rom
            chroma := (others => css_s);
            if inv_rr = '1' then
              luma := not luma;
            end if; -- normal/inverse
          else
            -- external ROM?!?
          end if; -- internal/external
        else
          -- semi-graphics
          if intn_ext_s = '0' then
            -- semi-4
            luma := semi4_dd(semi4_dd'left);
            semi4_dd := semi4_dd(semi4_dd'left-1 downto 0) & '0';
            chroma := cvbs_dd_r(6 downto 4);
          else
            -- semi-6
            luma := semi6_dd(semi4_dd'left);
            semi6_dd := semi6_dd(semi6_dd'left-1 downto 0) & '0';
            chroma := css_s & cvbs_dd_r(7 downto 6);
          end if; -- semi-4/6
        end if; -- alphanumeric/semi-graphics
      else
        -- graphics mode
        case gm_s is
          when "000" =>                     -- CG1 64x64x4
            luma := '1';
            chroma := css_s & cg1_dd(7 downto 6);
          when "001" | "011" | "101" =>     -- RG1/2/3 128x64/96/192x2
            luma := rg123_dd(7);
            chroma := css_s & "00";         -- green/buff
          when "010" | "100" | "110" =>     -- CG2/3/6 128x64/96/192x4
            luma := '1';
            chroma := css_s & cg236_dd(7 downto 6);
          when others =>                    -- RG6 256x192x2
            luma := rg6_dd(7);
            chroma := css_s & "00";         -- green/buff
        end case;
      end if; -- alpha/graphics mode

      if luma = '1' then
        case chroma is
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
        -- not quite black in alpha mode
        if an_g_s = '0' and an_s_rr = '0' then
          cvbs_data <= "010" & css_s & "0100"; -- dark green/orange
        else
          cvbs_data <= "01000000"; -- black
        end if;
      end if;
      
      an_s_r := an_s_r(an_s_r'left-1 downto 0) & an_s_s;
      inv_r := inv_r(inv_r'left-1 downto 0) & inv_s;
      
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

	cvbs <= '0' & cvbs_vsync & "000000" when cvbs_vblank = '1' else
				  '0' & cvbs_hsync & "000000" when cvbs_hblank = '1' else
				  cvbs_data;

  -- assign outputs

  hs_n <= not hs_int;
  fs_n <= not fs_int;
  da0 <= da0_int(4) when (gm_s = "001" or gm_s = "011" or gm_s = "101") else
         da0_int(3);

	GEN_CVBS_OUTPUT : if CVBS_NOT_VGA generate

		process (cvbs_clk_ena)
		begin
			if rising_edge(cvbs_clk_ena) then
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
	
	  process (clk)
	  begin
	    if rising_edge(clk) and clk_ena = '1' then
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
			wrclock		=> cvbs_clk_ena,
			wren			=> cvbs_linebuf_we_rr,
			wraddress	=> cvbs_linebuf_addr_rr,
			data			=> cvbs_data,

			rdclock		=> clk,
			rdaddress	=> vga_linebuf_addr,
			q					=> vga_data
		);

  -- Character ROM
  -- - technically the rom size is 1KB or 1.5KB (T1)
  charrom_inst : entity work.sprom
		generic map
		(
			init_file				=> CHAR_ROM_FILE,
			numwords_a			=> 2048,
			widthad_a				=> 11
		)                               
    port map
    (
      clock  		  => clk,
      address 	  => char_addr,
      q 			    => char_data
    );

end SYN;
