library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.STD_MATCH;
use ieee.std_logic_arith.EXT;

entity nes_ppu is
  generic
  (
    NTSC              : boolean := true;
    HSYNC_POLARITY    : std_logic := '0';
    VSYNC_POLARITY    : std_logic := '0'
  );
  port
  (
    clk         : in std_logic;
    clk_21M_en  : in std_logic;
    reset       : in std_logic;

		-- cpu interface
    cpu_clken   : in std_logic;
		cpu_a				: in std_logic_vector(2 downto 0);
		cpu_d_i			: in std_logic_vector(7 downto 0);
		cpu_d_o			: out std_logic_vector(7 downto 0);
		cpu_cs			: in std_logic;
		cpu_rw_n		: in std_logic;
		vbl					: out std_logic;

		-- CHR bus interface		
    chr_a       : out std_logic_vector(13 downto 0);
    chr_d_i     : in std_logic_vector(7 downto 0);
    chr_d_o     : out std_logic_vector(7 downto 0);
    chr_d_oe    : out std_logic;
    ale         : out std_logic;
		rd_n        : out std_logic;
    wr_n        : out std_logic;

		-- composite video output
    r           : out std_logic_vector(5 downto 0);
    g           : out std_logic_vector(5 downto 0);
    b           : out std_logic_vector(5 downto 0);
    hsync       : out std_logic;
    vsync       : out std_logic
  );
end nes_ppu;

architecture SYN of nes_ppu is

  constant PAL                : boolean := not NTSC;

	subtype obj_pal_entry_t is std_logic_vector(5 downto 0);
	type obj_pal_t is array (natural range <>) of obj_pal_entry_t;
	signal image_pal		: obj_pal_t(0 to 15);
	signal sprite_pal		: obj_pal_t(0 to 15);

	--type clut_typ is array (0 to 31) of std_logic_vector(7 downto 0);

	-- clut entries for TENNIS in-game palette	
	--constant clut : clut_typ :=
	--(
	--	-- tile palette
	--	X"17", X"0F", X"30", X"19", X"17", X"0F", X"30", X"27", 
	--	X"17", X"21", X"30", X"02", X"17", X"0F", X"30", X"02", 
	--	-- sprite palette
	--	X"17", X"0F", X"27", X"21", X"17", X"07", X"27", X"20", 
	--	X"17", X"39", X"0F", X"17", X"17", X"07", X"36", X"2B"
	--);

	type ppu_pal_entry_t is array (0 to 2) of std_logic_vector(5 downto 0);
	type ppu_pal_t is array (0 to 63) of ppu_pal_entry_t;

	constant ppu_palette : ppu_pal_t :=
	(
		-- PAL palette taken from NINTENDULATOR emulator
		0 => (0=>"100000", 1=>"100000", 2=>"100000"),
		1 => (0=>"000000", 1=>"001111", 2=>"101001"),
		2 => (0=>"000000", 1=>"000100", 2=>"101100"),
		3 => (0=>"010001", 1=>"000000", 2=>"100101"),
		4 => (0=>"101000", 1=>"000000", 2=>"010111"),
		5 => (0=>"110001", 1=>"000000", 2=>"001010"),
		6 => (0=>"101110", 1=>"000001", 2=>"000000"),
		7 => (0=>"100011", 1=>"000101", 2=>"000000"),
		8 => (0=>"010111", 1=>"001011", 2=>"000000"),
		9 => (0=>"000100", 1=>"010001", 2=>"000000"),
		10 => (0=>"000001", 1=>"010010", 2=>"000000"),
		11 => (0=>"000000", 1=>"010001", 2=>"001011"),
		12 => (0=>"000000", 1=>"010000", 2=>"011001"),
		14 => (0=>"000001", 1=>"000001", 2=>"000001"),
		15 => (0=>"000001", 1=>"000001", 2=>"000001"),
		16 => (0=>"110001", 1=>"110001", 2=>"110001"),
		17 => (0=>"000000", 1=>"011101", 2=>"111111"),
		18 => (0=>"001000", 1=>"010101", 2=>"111111"),
		19 => (0=>"100000", 1=>"001101", 2=>"111110"),
		20 => (0=>"111010", 1=>"001011", 2=>"101101"),
		21 => (0=>"111111", 1=>"001010", 2=>"010100"),
		22 => (0=>"111111", 1=>"001000", 2=>"000000"),
		23 => (0=>"110101", 1=>"001100", 2=>"000000"),
		24 => (0=>"110001", 1=>"011000", 2=>"000000"),
		25 => (0=>"001101", 1=>"100000", 2=>"000000"),
		26 => (0=>"000001", 1=>"100011", 2=>"000000"),
		27 => (0=>"000000", 1=>"100010", 2=>"010101"),
		28 => (0=>"000000", 1=>"100110", 2=>"110011"),
		29 => (0=>"001000", 1=>"001000", 2=>"001000"),
		30 => (0=>"000010", 1=>"000010", 2=>"000010"),
		31 => (0=>"000010", 1=>"000010", 2=>"000010"),
		32 => (0=>"111111", 1=>"111111", 2=>"111111"),
		33 => (0=>"000011", 1=>"110101", 2=>"111111"),
		34 => (0=>"011010", 1=>"101000", 2=>"111111"),
		35 => (0=>"110101", 1=>"100000", 2=>"111111"),
		36 => (0=>"111111", 1=>"010001", 2=>"111100"),
		37 => (0=>"111111", 1=>"011000", 2=>"100010"),
		38 => (0=>"111111", 1=>"100010", 2=>"001100"),
		39 => (0=>"111111", 1=>"100111", 2=>"000100"),
		40 => (0=>"111110", 1=>"101111", 2=>"001000"),
		41 => (0=>"100111", 1=>"111000", 2=>"000011"),
		42 => (0=>"001010", 1=>"111100", 2=>"001101"),
		43 => (0=>"000011", 1=>"111100", 2=>"101001"),
		44 => (0=>"000001", 1=>"111110", 2=>"111111"),
		45 => (0=>"010111", 1=>"010111", 2=>"010111"),
		46 => (0=>"000011", 1=>"000011", 2=>"000011"),
		47 => (0=>"000011", 1=>"000011", 2=>"000011"),
		48 => (0=>"111111", 1=>"111111", 2=>"111111"),
		49 => (0=>"101001", 1=>"111111", 2=>"111111"),
		50 => (0=>"101100", 1=>"111011", 2=>"111111"),
		51 => (0=>"110110", 1=>"101010", 2=>"111010"),
		52 => (0=>"111111", 1=>"101010", 2=>"111110"),
		53 => (0=>"111111", 1=>"101010", 2=>"101100"),
		54 => (0=>"111111", 1=>"110100", 2=>"101100"),
		55 => (0=>"111111", 1=>"111011", 2=>"101001"),
		56 => (0=>"111111", 1=>"111101", 2=>"100111"),
		57 => (0=>"110101", 1=>"111010", 2=>"100101"),
		58 => (0=>"101001", 1=>"111011", 2=>"101011"),
		59 => (0=>"101000", 1=>"111100", 2=>"110110"),
		60 => (0=>"100110", 1=>"111111", 2=>"111111"),
		61 => (0=>"110111", 1=>"110111", 2=>"110111"),
		62 => (0=>"000100", 1=>"000100", 2=>"000100"),
		63 => (0=>"000100", 1=>"000100", 2=>"000100"),
		others => (others => (others => '0'))
	);

	type ppu_reg_t is array (natural range <>) of std_logic_vector(7 downto 0);
	signal ppu_reg 							: ppu_reg_t(7 downto 0);
	alias ppu_ctl1 							: std_logic_vector(7 downto 0) is ppu_reg(0);
	alias ppu_ctl2 							: std_logic_vector(7 downto 0) is ppu_reg(1);
	alias ppu_status 						: std_logic_vector(7 downto 0) is ppu_reg(2);
	alias ppu_sptmem_a 					: std_logic_vector(7 downto 0) is ppu_reg(3);
	alias ppu_sptmem_d 					: std_logic_vector(7 downto 0) is ppu_reg(4);
	alias ppu_bg_scroll					: std_logic_vector(7 downto 0) is ppu_reg(5);
	alias ppu_mem_a 						: std_logic_vector(7 downto 0) is ppu_reg(6);
	alias ppu_mem_d 						: std_logic_vector(7 downto 0) is ppu_reg(7);
	signal pal_wr								: std_logic;
	signal hscroll							: std_logic_vector(7 downto 0);
	signal vscroll							: std_logic_vector(7 downto 0);

	signal spr0_hit							: std_logic := '0';
	signal more_than_8_flag			: std_logic := '0';
				
  signal scanline             : std_logic_vector(8 downto 0) := (others => '0');
  signal renderline           : std_logic_vector(scanline'range);
  signal cycle                : std_logic_vector(10 downto 0) := (others => '0');
  signal frame                : std_logic := '0';
  alias ppu_cycle             : std_logic_vector(7 downto 0) is cycle(10 downto 3);
  alias ppu_pixel             : std_logic_vector(8 downto 0) is cycle(10 downto 2);
  alias ppu_sub_cycle         : std_logic_vector(2 downto 0) is cycle(2 downto 0);
  signal ppu_sub_tick         : std_logic := '0';
	signal pixel_tick						: std_logic := '0';
  signal hblank               : std_logic := '0';
  signal vblank               : std_logic := '0';
                   
	-- eventually this will be SPRAM           
  signal ciram_a              : std_logic_vector(10 downto 0);
  signal ciram_d_o            : std_logic_vector(7 downto 0);
  signal ciram_a_r            : std_logic_vector(15 downto 0);
  signal ciram_d_o_r          : std_logic_vector(7 downto 0);
  signal ciram_d_i_r          : std_logic_vector(7 downto 0);
	signal ciram_wr_r						: std_logic;
                              
  signal name_table_data      : std_logic_vector(7 downto 0);
  signal attr_table_data      : std_logic_vector(7 downto 0);
	signal attr									: std_logic_vector(1 downto 0);
  signal patt_table_data      : std_logic_vector(15 downto 0);
	signal patt_table_temp			: std_logic_vector(15 downto 8);

	type sptmem_t is array (natural range <>) of std_logic_vector(7 downto 0);
	signal sptmem								: sptmem_t(255 downto 0) := (others => (others => '0'));
	-- temporary memory for 8 sprites
	signal spttmp								: sptmem_t(32 downto 0) := (others => (others => '0'));
	signal n_spttmp							: natural range 0 to 8 := 0;
	
	signal image_pal_entry			: obj_pal_entry_t;
	signal sprite_pal_entry			: obj_pal_entry_t;
	signal ppu_pal_entry 				: ppu_pal_entry_t;
	
begin

  ale <= '0';
  rd_n <= '1';
  wr_n <= '1';

	chr_d_o <= (others => '0');
	chr_d_oe <= '0';
	
	--
	--	*** REGISTERS
	--
	
	process (clk, clk_21M_en, reset)
	
		variable vblank_flag	: std_logic;
		variable state_5 			: std_logic;
		variable state_6 			: std_logic;
		variable ciram_buffer	: std_logic_vector(7 downto 0);
		variable vblank_r 		: std_logic;
		variable spr0_hit_r		: std_logic;
				
	begin
		if reset = '1' then

			vblank_flag := '0';
			vblank_r := '0';
			ciram_wr_r <= '0';
			pal_wr <= '0';
			ppu_reg <= (others => (others => '0'));
			state_5 := '0';
			state_6 := '0';
			spr0_hit_r := '0';
			
		elsif rising_edge(clk) and clk_21M_en = '1' then
		
			-- handle events triggered by vblank
			if vblank_r = '0' and vblank = '1' then
				vblank_flag := '1';
			elsif vblank = '0' then
				if vblank_r = '1' then
					spr0_hit_r := '0';
				end if;
				if spr0_hit = '1' then
					spr0_hit_r := '1';
				end if;
				vblank_flag := '0';
			end if;

			-- post-increment CIRAM address on falling edge of write strobe
			if ciram_wr_r = '1' or pal_wr = '1' then
				if ppu_ctl1(2) = '1' then
					ciram_a_r <= ciram_a_r + 32;
				else
					ciram_a_r <= ciram_a_r + 1;
				end if;
			end if;
				
			-- defaults
			ciram_wr_r <= '0';
			pal_wr <= '0';
											
			if cpu_cs = '1' and cpu_clken = '1' then
				if cpu_rw_n = '1' then
				
					--
					-- REGISTER READS
					--
					
					if cpu_a = "010" then
						-- PPU STATUS
						cpu_d_o <= vblank_flag & spr0_hit_r & more_than_8_flag & "00000";
					elsif cpu_a = "111" then
						-- VRAM DATA
						-- - a quirk in the PPU
						--   the 1st read after setting the address doesn't work
						cpu_d_o <= ciram_buffer;
						ciram_buffer := ciram_d_o_r;
					else
						cpu_d_o <= ppu_reg(conv_integer(cpu_a));
					end if;
					
					-- side-effects
					case cpu_a is
						when "010" =>
							vblank_flag := '0';		-- reset flag
							state_5 := '0';
							state_6 := '0';
						when others =>
							null;
					end case;
					
				else
				
					--
					-- REGISTER WRITES
					--
					
					ppu_reg(conv_integer(cpu_a)) <= cpu_d_i;
					
					-- side-effects
					case cpu_a is
						when "101" =>
							if state_5 = '0' then
								-- horizontal
								hscroll <= cpu_d_i;
							else
								-- vertical
								vscroll <= cpu_d_i;
							end if;
							state_5 := not state_5;
						when "100" =>
							-- write to sprite memory
							sptmem(conv_integer(ppu_sptmem_a)) <= cpu_d_i;
							-- increment sprite memory address
							ppu_sptmem_a <= ppu_sptmem_a + 1;
						when "110" =>
							-- write VRAM address
							if state_6 = '0' then
								ciram_a_r(15 downto 8) <= cpu_d_i;		-- high byte
							else
								ciram_a_r(7 downto 0) <= cpu_d_i;			-- low byte
							end if;
							state_6 := not state_6;
						when "111" =>
							-- write to VRAM
							if ciram_a_r(15 downto 12) = X"2" then
								-- PPU name tables
								ciram_d_i_r <= cpu_d_i;
								ciram_wr_r <= '1';
							elsif ciram_a_r(15 downto 8) = X"3F" then
								-- palette register
								if ciram_a_r(4) = '0' then
									image_pal(conv_integer(ciram_a_r(3 downto 0))) <= cpu_d_i(5 downto 0);
								else
									sprite_pal(conv_integer(ciram_a_r(3 downto 0))) <= cpu_d_i(5 downto 0);
								end if;
								pal_wr <= '1';
							end if;
						when others =>
							null;
					end case;
				end if; -- cpu_rw_n
			end if; -- cpu_cs
			vblank_r := vblank;
		end if; -- rising_edge()

		-- drive outputs
		if ppu_ctl1(7) = '1' then
			vbl <= vblank_flag;
		else
			vbl <= '0';
		end if;

	end process;

	--
	--	*** VIDEO RENDERING
	--
	
  -- generate NTSC video counters
  process (clk, clk_21M_en, reset)
  begin
    if reset = '1' then
      scanline <= (others => '0');
      renderline <= (others => '0');
      cycle <= (others => '0');
      frame <= '0';
    elsif rising_edge(clk) and clk_21M_en = '1' then
      ppu_sub_tick <= '0';
      if ppu_sub_cycle = "000" then
        ppu_sub_tick <= '1';
      end if;
			pixel_tick <= '0';
			if ppu_sub_cycle(1 downto 0) = "00" then
				pixel_tick <= '1';
			end if;
			-- scanline 21 is a short line apparently
      if (frame = '1' and scanline = 261 and cycle = 1359) or cycle = 1363 then
        cycle <= (others => '0');
        if scanline = 261 then
          scanline <= (others => '0');
          frame <= not frame;
        else
          if scanline <= 20 then
            renderline <= (others => '0');
          else
            renderline <= renderline + 1;
          end if;
          scanline <= scanline + 1;
        end if;
      else
        cycle <= cycle + 1;
      end if;
    end if;
  end process;

  -- generate NTSC video blanks, syncs
  process (clk, clk_21M_en, reset)
  begin
    if reset = '1' then
      hblank <= '1';
      hsync <= not HSYNC_POLARITY;
      vblank <= '1';
      vsync <= not VSYNC_POLARITY;
    elsif rising_edge(clk) and clk_21M_en = '1' then
      if cycle = -1+32+4 then
        hblank <= '0';
      elsif cycle = 1023+32+4 then
        hblank <= '1';
      elsif cycle = 1156 then
        hsync <= HSYNC_POLARITY;
      elsif cycle = 1256 then
        hsync <= not HSYNC_POLARITY;
      elsif (frame = '1' and scanline = 261 and cycle = 1359) or cycle = 1363 then
        if scanline = 1 then
          vsync <= not VSYNC_POLARITY;
        elsif scanline = 20 then
          vblank <= '0';
        elsif scanline = 260 then
          vblank <= '1';
        elsif scanline = 261 then
          vsync <= VSYNC_POLARITY;
        end if;
      end if;
    end if;
  end process;

  -- drive the CHR address bus and latch the result
  process (clk, clk_21M_en, reset, ppu_sub_tick)
		variable attr_b	: std_logic_vector(1 downto 0);
  begin
    if reset = '1' then
    elsif rising_edge(clk) and clk_21M_en = '1' then
      if ppu_sub_tick = '1' then
        if ppu_cycle < 128+8 then
          -- render tilemaps
          case ppu_cycle(1 downto 0) is
            when "00" =>
							-- calculate 2 attribute bits
							case attr_b is
								when "00" =>
									attr <= attr_table_data(1 downto 0);
								when "01" =>
									attr <= attr_table_data(3 downto 2);					
								when "10" =>
									attr <= attr_table_data(5 downto 4);
								when others =>
									attr <= attr_table_data(7 downto 6);
							end case;
              -- latch last pattern table data byte and fetch new name table byte
              patt_table_data <= chr_d_i & patt_table_temp;
              ciram_a <= renderline(8 downto 3) & ppu_cycle(6 downto 2);
            when "01" =>
              -- latch name table byte and fetch attribute table byte
              name_table_data <= ciram_d_o;
              -- high bit is actually set by a register...
              ciram_a <= "01111" & renderline(7 downto 5) & ppu_cycle(6 downto 4);
							-- latch the bits that determine which attribute bits to use
							attr_b := renderline(4) & ppu_cycle(3);
            when "10" =>
              -- latch attribute table byte and fetch 1st pattern table access
              attr_table_data <= ciram_d_o;
              chr_a <= "01" & name_table_data & '0' & renderline(2 downto 0);
            when others =>
              -- latch 1st pattern table byte and fetch 2nd pattern table access
              patt_table_temp <= chr_d_i;
              chr_a <= "01" & name_table_data & '1' & renderline(2 downto 0);
          end case;
        elsif ppu_cycle < 160 then
          -- read sprite data
          null;
        else
          null;
        end if;
			end if;
			if pixel_tick = '1' and ppu_pixel(2 downto 0) /= "000" then
        -- shift in the next pixel data
        patt_table_data(15 downto 8) <= patt_table_data(14 downto 8) & '0';
				patt_table_data(7 downto 0) <= patt_table_data(6 downto 0) & '0';
      end if;
    end if;
  end process;

	-- scan for active sprites on this row
	process (clk, clk_21M_en, reset)
		variable spriteline 				: std_logic_vector(renderline'range) := (others => '0');
		variable n_spttmp_v					: std_logic_vector(3 downto 0) := (others => '0');
		--alias sptnum : std_logic_vector(5 downto 0) is ppu_cycle(6 downto 1);
    --alias ppu_cycle             : std_logic_vector(7 downto 0) is cycle(10 downto 3);
		alias sptnum : std_logic_vector(5 downto 0) is cycle(9 downto 4);
		variable spt_y							: std_logic_vector(7 downto 0) := (others => '0');
		variable spt_endline				: std_logic_vector(renderline'range) := (others => '0');
	begin
		spriteline := renderline - 1;
		if reset = '1' then
		elsif rising_edge(clk) and clk_21M_en = '1' then
			if ppu_cycle < 128 then
				spt_y := sptmem(conv_integer(sptnum & "00"));
				if ppu_cycle(0) = '0' then
					-- calculate the last line of the sprite
					if ppu_ctl1(5) = '0' then
						spt_endline := EXT(spt_y + 8, spt_endline'length);
					else
						spt_endline := EXT(spt_y + 16, spt_endline'length);
					end if;
				else
					-- check y-coordinate
					if spriteline >= spt_y and spriteline < spt_endline then
						-- this sprite is visible on this line
						if n_spttmp_v < 8 then
							-- copy the sprite registers (use delta Y)
							spttmp(conv_integer(n_spttmp_v & "00")) <= spt_y - spriteline(7 downto 0);
							spttmp(conv_integer(n_spttmp_v & "01")) <= sptmem(conv_integer(sptnum & "01"));
							spttmp(conv_integer(n_spttmp_v & "10")) <= sptmem(conv_integer(sptnum & "11"));
							spttmp(conv_integer(n_spttmp_v & "11")) <= sptmem(conv_integer(sptnum & "11"));
							n_spttmp_v := n_spttmp_v + 1;
						else
							more_than_8_flag <= '1';
						end if;
					end if;
				end if;
			elsif ppu_cycle < 160 then
			else
				n_spttmp <= conv_integer(n_spttmp_v);
				n_spttmp_v := (others => '0');
				more_than_8_flag <= '0';
			end if;
		end if;
	end process;
	
  -- tile pixel rendering
  process (clk, clk_21M_en, reset)
  begin
    if reset = '1' then
      r <= (others => '0');
      g <= (others => '0');
      b <= (others => '0');
    elsif rising_edge(clk) and clk_21M_en = '1' then
      if vblank = '1' or hblank = '1' then
        r <= (others => '0');
        g <= (others => '0');
        b <= (others => '0');
      else
				image_pal_entry <= image_pal(conv_integer(attr & patt_table_data(15) & patt_table_data(7)));
				ppu_pal_entry <= ppu_palette(conv_integer(image_pal_entry(5 downto 0)));
        --r <= cycle(cycle'left downto cycle'length-r'length);
        --g <= scanline(scanline'left downto scanline'length-g'length);
        --b <= ppu_cycle(ppu_cycle'left downto ppu_cycle'length-b'length);
				r <= ppu_pal_entry(0);
				g <= ppu_pal_entry(1);
				b <= ppu_pal_entry(2);
      end if;
    end if;
  end process;

	ciram_inst : entity work.ppu_ciram
		-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
		port map
		(
      -- register interface
			clock_b			=> clk,
			address_b   => ciram_a_r(10 downto 0),
			wren_b			=> ciram_wr_r,
			data_b			=> ciram_d_i_r,
			q_b					=> ciram_d_o_r,

      -- rendering engine interface
			clock_a			=> clk,
			address_a		=> ciram_a,
			wren_a			=> '0',
			data_a			=> "XXXXXXXX",
			q_a					=> ciram_d_o
		);

end SYN;
