library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.platform_variant_pkg.all;
use work.project_pkg.all;

entity platform is
  generic
  (
    NUM_INPUT_BYTES   : integer
  );
  port
  (
    -- clocking and reset
    clkrst_i        : in from_CLKRST_t;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_MAPPED_INPUTS_t(0 to NUM_INPUT_BYTES-1);

    -- FLASH/SRAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_FLASH_t;
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;
    sdram_i         : in from_SDRAM_t;
    sdram_o         : out to_SDRAM_t;
    
    -- graphics
    
    bitmap_i        : in from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    bitmap_o        : out to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    
    tilemap_i       : in from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    tilemap_o       : out to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);

    sprite_reg_o    : out to_SPRITE_REG_t;
    sprite_i        : in from_SPRITE_CTL_t;
    sprite_o        : out to_SPRITE_CTL_t;
		spr0_hit				: in std_logic;

    -- various graphics information
    graphics_i      : in from_GRAPHICS_t;
    graphics_o      : out to_GRAPHICS_t;
    
    -- OSD
    osd_i           : in from_OSD_t;
    osd_o           : out to_OSD_t;

    -- sound
    snd_i           : in from_SOUND_t;
    snd_o           : out to_SOUND_t;
    
    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;

    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
  );

end platform;

architecture SYN of platform is

	alias clk_sys				  : std_logic is clkrst_i.clk(0);
	alias rst_sys				  : std_logic is clkrst_i.rst(0);
	alias clk_video       : std_logic is clkrst_i.clk(1);
	
  -- cpu signals  
  signal clk_3M_en			: std_logic;
  signal cpu_clk_en     : std_logic;
  signal cpu_rst        : std_logic;
  signal cpu_a          : std_logic_vector(15 downto 0);
  signal cpu_d_i        : std_logic_vector(7 downto 0);
  signal cpu_d_o        : std_logic_vector(7 downto 0);
  signal cpu_mem_rd     : std_logic;
  signal cpu_mem_wr     : std_logic;
  signal cpu_nmireq     : std_logic;

  -- ROM signals        
	signal rom_cs					: std_logic;
  signal rom_d_o        : std_logic_vector(7 downto 0);
  
  -- keyboard signals
	                        
  -- VRAM signals       
	signal vram_cs				: std_logic;
	signal vram_wr				: std_logic;
  signal vram_d_o       : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal wram_cs        : std_logic;
  signal wram_wr        : std_logic;
  signal wram_d_o       : std_logic_vector(7 downto 0);

  -- CRAM/SPRITE signals        
  signal cram_cs        : std_logic;
  signal cram_wr        : std_logic;
	signal cram_d_o		    : std_logic_vector(7 downto 0);
	signal sprite_cs      : std_logic;
  
  -- input signals      
  signal in_cs          : std_logic_vector(0 to PACE_INPUTS_NUM_BYTES-1);
	
  -- other signals
  signal rst_platform   : std_logic;
  signal pause          : std_logic;
  signal rot_en         : std_logic;

  -- frogger, scramble signals
  signal pia0_cs        : std_logic;
  signal pia0_d_o       : std_logic_vector(7 downto 0);
  signal pia1_cs        : std_logic;
  signal pia1_d_o       : std_logic_vector(7 downto 0);

  -- jumpbug signals
  signal extra_rom_cs     : std_logic;
  signal extra_rom_d_o    : std_logic_vector(7 downto 0);
  signal jumpbug_prot_cs  : std_logic;
  signal jumpbug_prot_d   : std_logic_vector(7 downto 0);
  
begin

  -- handle special keys
  process (clk_sys, rst_sys)
    variable spec_keys_r  : std_logic_vector(7 downto 0);
    alias spec_keys       : std_logic_vector(7 downto 0) is inputs_i(PACE_INPUTS_NUM_BYTES-1).d;
  begin
    if rst_sys = '1' then
      rst_platform <= '0';
      pause <= '0';
      rot_en <= '0';  -- to default later
      spec_keys_r := (others => '0');
    elsif rising_edge(clk_sys) then
      rst_platform <= spec_keys(0);
      if spec_keys_r(1) = '0' and spec_keys(1) = '1' then
        pause <= not pause;
      end if;
      if spec_keys_r(2) = '0' and spec_keys(2) = '1' then
        rot_en <= not rot_en;
      end if;
      spec_keys_r := spec_keys;
    end if;
  end process;
  
  graphics_o.bit8(0)(1) <= rot_en;
  
  -- chip select logic
  -- ROM $0000-$3FFF
  rom_cs <=     '1' when STD_MATCH(cpu_a, GALAXIAN_ROM_A) else 
                    -- ckongg $0000-$5FFF
                '1' when PLATFORM_VARIANT = "ckongg" and
                      STD_MATCH(cpu_a, "010-------------") else 
                '0';
  -- every thing else is variant-dependent
  wram_cs <=    '1' when STD_MATCH(cpu_a, GALAXIAN_WRAM_A) else '0';
  vram_cs <=    '1' when STD_MATCH(cpu_a, GALAXIAN_VRAM_A) else '0';
  cram_cs <=    '1' when STD_MATCH(cpu_a, GALAXIAN_CRAM_A) else '0';
  sprite_cs <=  '1' when STD_MATCH(cpu_a, GALAXIAN_SPRITE_A) else '0';
  in_cs(0) <=   '1' when not GALAXIAN_HAS_PIA8255 and
                        STD_MATCH(cpu_a, GALAXIAN_INPUTS_A) else 
                '0';
  in_cs(1) <=   '1' when not GALAXIAN_HAS_PIA8255 and
                        STD_MATCH(cpu_a, GALAXIAN_INPUTS_A+GALAXIAN_INPUTS_INC) else
                '0';
  in_cs(2) <=   '1' when not GALAXIAN_HAS_PIA8255 and
                        STD_MATCH(cpu_a, GALAXIAN_INPUTS_A+GALAXIAN_INPUTS_INC+GALAXIAN_INPUTS_INC) else 
                '0';
  
                -- PIA_8255 $C000-$FFFF (frogger only)
  pia0_cs <=    '1' when PLATFORM_VARIANT = "frogger" and
                          STD_MATCH(cpu_a, "11--------------") else
                -- PIA_8255 $8000-$FFFF (scramble only)
                '1' when PLATFORM_VARIANT = "scramble" and
                          STD_MATCH(cpu_a, "1------1--------") else
                '0';
                -- PIA_8255 $C000-$FFFF (frogger only)
  pia1_cs <=    '1' when PLATFORM_VARIANT = "frogger" and
                          STD_MATCH(cpu_a, "11--------------") else
                -- PIA_8255 $8000-$FFFF (scramble only)
                '1' when PLATFORM_VARIANT = "scramble" and
                          STD_MATCH(cpu_a, "1-----1---------") else
                '0';
  
  -- ROM $8000-$AFFF (jumpbug only)
  extra_rom_cs <= '1' when PLATFORM_VARIANT = "jumpbug" and
                            (STD_MATCH(cpu_a, "100-------------") or
                             STD_MATCH(cpu_a, "1010------------")) else 
                  '0';
  jumpbug_prot_cs <=  '1' when PLATFORM_VARIANT = "jumpbug" and
                            STD_MATCH(cpu_a, X"B---") else
                      '0';
                    
	-- memory read mux
	cpu_d_i <=  rom_d_o when rom_cs = '1' else
							wram_d_o when wram_cs = '1' else
							vram_d_o when vram_cs = '1' else
							cram_d_o when cram_cs = '1' else
              inputs_i(0).d when in_cs(0) = '1' else
              inputs_i(1).d when in_cs(1) = '1' else
              inputs_i(2).d when in_cs(2) = '1' else
              extra_rom_d_o when extra_rom_cs = '1' else
              pia0_d_o when pia0_cs = '1' else
              pia1_d_o when pia1_cs = '1' else
              jumpbug_prot_d when jumpbug_prot_cs = '1' else
							(others => '0');
	
	vram_wr <= cpu_mem_wr and vram_cs;
	cram_wr <= cram_cs and cpu_mem_wr;
	wram_wr <= wram_cs and cpu_mem_wr;

  -- sprite registers
  sprite_reg_o.clk <= clk_sys;
  sprite_reg_o.clk_ena <= clk_3M_en;
  sprite_reg_o.a <= cpu_a(7 downto 0);
  sprite_reg_o.d <= cpu_d_o;
  sprite_reg_o.wr <=  sprite_cs and cpu_mem_wr;

  --
  -- COMPONENT INSTANTIATION
  --

  assert false
    report  "CLK0_FREQ_MHz = " & integer'image(CLK0_FREQ_MHz) & "\n" &
            "CPU_FREQ_MHz = " &  integer'image(CPU_FREQ_MHz) & "\n" &
            "CPU_CLK_ENA_DIV = " & integer'image(GALAXIAN_CPU_CLK_ENA_DIVIDE_BY)
      severity note;

  BLK_CPU : block
  begin
    -- generate CPU enable clock (3MHz from 27/30MHz)
    clk_en_inst : entity work.clk_div
      generic map
      (
        DIVISOR		=> GALAXIAN_CPU_CLK_ENA_DIVIDE_BY
      )
      port map
      (
        clk				=> clk_sys,
        reset			=> rst_sys,
        clk_en		=> clk_3M_en
      );
    
    -- gated CPU signals
    cpu_clk_en <= clk_3M_en and not pause;
    cpu_rst <= rst_sys or rst_platform;
    
    cpu_inst : entity work.Z80                                                
      port map
      (
        clk 		=> clk_sys,                                   
        clk_en	=> cpu_clk_en,
        reset  	=> cpu_rst,

        addr   	=> cpu_a,
        datai  	=> cpu_d_i,
        datao  	=> cpu_d_o,

        mem_rd 	=> cpu_mem_rd,
        mem_wr 	=> cpu_mem_wr,
        io_rd  	=> open,
        io_wr  	=> open,

        intreq 	=> '0',
        intvec 	=> cpu_d_i,
        intack 	=> open,
        nmi    	=> cpu_nmireq
      );
  end block BLK_CPU;
  
  GEN_JUMPBUG_PROTECTION : if PLATFORM_VARIANT = "jumpbug" generate
    jumpbug_prot_d <= X"4F" when STD_MATCH(cpu_a, X"-114") else
                      X"D3" when STD_MATCH(cpu_a, X"-118") else
                      X"CF" when STD_MATCH(cpu_a, X"-214") else
                      X"02" when STD_MATCH(cpu_a, X"-235") else
                      X"FF" when STD_MATCH(cpu_a, X"-311") else
                      X"FF";
  end generate GEN_JUMPBUG_PROTECTION;
  
  BLK_INTERRUPTS : block
  
    signal vblank_int     : std_logic;
    signal nmiena_s       : std_logic;

  begin
  
		process (clk_sys, rst_sys)
			variable vblank_r : std_logic_vector(3 downto 0);
			alias vblank_prev : std_logic is vblank_r(vblank_r'left);
			alias vblank_um   : std_logic is vblank_r(vblank_r'left-1);
      -- 1us duty for VBLANK_INT
      variable count    : integer range 0 to CLK0_FREQ_MHz * 1000;
		begin
			if rst_sys = '1' then
				vblank_int <= '0';
				vblank_r := (others => '0');
        count := count'high;
			elsif rising_edge(clk_sys) then
        -- rising edge vblank only
        if vblank_prev = '0' and vblank_um = '1' then
          count := 0;
        end if;
        if count /= count'high then
          vblank_int <= '1';
          count := count + 1;
        else
          vblank_int <= '0';
        end if;
        vblank_r := vblank_r(vblank_r'left-1 downto 0) & graphics_i.vblank;
			end if; -- rising_edge(clk_sys)
		end process;

    -- latch interrupt enables
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
        nmiena_s <= '0';
      elsif rising_edge (clk_sys) then
        if cpu_mem_wr then
          if STD_MATCH(cpu_a, GALAXIAN_NMIENA_A) then
            nmiena_s <= cpu_d_o(0);
          end if;
        end if;
      end if; -- rising_edge(clk_sys)
    end process;
    
    -- generate INT
    cpu_nmireq <= '1' when (vblank_int and nmiena_s) /= '0' else '0';
    
  end block BLK_INTERRUPTS;
  
  --
  --  Here we implement the various protection schemes on the CPU ROMs
  --  - either ROM address or data lines may be munged
  --
  
  BLK_CPU_ROMS : block
  
    type rom_d_a is array(0 to 7) of std_logic_vector(7 downto 0);
    signal rom_d          : rom_d_a;

    signal rom_device_a   : std_logic_vector(cpu_a'range);
    signal rom_device_d_o : std_logic_vector(rom_d_o'range);
    
  begin
  
    GEN_DECRYPT : if PLATFORM_VARIANT = "ckongg" generate
    
      -- I'm sure this is done via NOT & XOR in a GAL, but I can't derive the algorithm...
      -- - tried brute-force approach but didn't get any matches
      rom_device_a(cpu_a'left downto 15) <= cpu_a(cpu_a'left downto 15);
      rom_device_a(14 downto 10) <= "00101" when cpu_a(14 downto 10) = "00000" else
                                    "01011" when cpu_a(14 downto 10) = "00001" else
                                    "10000" when cpu_a(14 downto 10) = "00010" else
                                    "00011" when cpu_a(14 downto 10) = "00011" else
                                    "01110" when cpu_a(14 downto 10) = "00100" else
                                    "10011" when cpu_a(14 downto 10) = "00101" else
                                    "00110" when cpu_a(14 downto 10) = "00110" else
                                    "00001" when cpu_a(14 downto 10) = "00111" else
                                    "01100" when cpu_a(14 downto 10) = "01000" else
                                    "00000" when cpu_a(14 downto 10) = "01001" else
                                    "00111" when cpu_a(14 downto 10) = "01010" else
                                    "10010" when cpu_a(14 downto 10) = "01011" else
                                    "10100" when cpu_a(14 downto 10) = "01100" else
                                    "01000" when cpu_a(14 downto 10) = "01101" else
                                    "01101" when cpu_a(14 downto 10) = "01110" else
                                    "10101" when cpu_a(14 downto 10) = "01111" else
                                    "01111" when cpu_a(14 downto 10) = "10000" else
                                    "00100" when cpu_a(14 downto 10) = "10001" else
                                    "00010" when cpu_a(14 downto 10) = "10010" else
                                    "01001" when cpu_a(14 downto 10) = "10011" else
                                    "01010" when cpu_a(14 downto 10) = "10100" else
                                    "10001";
      rom_device_a(9 downto 0) <= cpu_a(9 downto 0);
      rom_d_o <= rom_device_d_o;
      
    elsif PLATFORM_VARIANT = "mooncrst" generate
        signal res  : std_logic_vector(rom_d_o'range);
      begin
      
      rom_device_a <= cpu_a;
      
      -- *** MAME code
      -- UINT8 data = rom[offs];
      -- if (BIT(data,1)) res ^= 0x40;
      -- if (BIT(data,5)) res ^= 0x04;
      -- if ((offs & 1) == 0) res = BITSWAP8(res,7,2,5,4,3,6,1,0);
      -- dest[offs] = res;

      res <= rom_device_d_o(7) & 
              (rom_device_d_o(6) xor rom_device_d_o(1)) & 
              rom_device_d_o(5 downto 3) & 
              (rom_device_d_o(2) xor rom_device_d_o(5)) & 
              rom_device_d_o(1 downto 0);
              
      rom_d_o <=  res when cpu_a(0) = '1' else
                  res(7) & res(2) & res(5) & res(4) & res(3) & res(6) & res(1) & res(0);

    elsif PLATFORM_VARIANT = "zigzag" generate
      signal bank : std_logic;
    begin
    
      process (clk_sys, rst_sys)
      begin
        if rst_sys = '1' then
          bank <= '0';
        elsif rising_edge(clk_sys) then
          if cpu_mem_wr = '1' then
            if cpu_a = X"7002" then
              if cpu_d_o = X"00" then
                bank <= '0';
              else
                bank <= '1';
              end if; -- cpu_d_o=X"00"
            end if; -- cpu_a=X"7002"
          end if; -- cpu_mem_wr
        end if;
      end process;

      rom_device_a(rom_device_a'left downto 13) <= cpu_a(cpu_a'left downto 13);
      -- allow banks $2000,$3000 to swap based on bank bit
      rom_device_a(12) <= (cpu_a(12) xor bank) when cpu_a(13) = '1' else
                          cpu_a(12);
      rom_device_a(11 downto 0) <= cpu_a(11 downto 0);
      
      rom_d_o <= rom_device_d_o;

    else generate

      rom_device_a <= cpu_a;
      rom_d_o <= rom_device_d_o;
      
    end generate GEN_DECRYPT;
    
    rom_device_d_o <= rom_d(0) when rom_device_a(GALAXIAN_ROM_WIDTHAD+2 downto GALAXIAN_ROM_WIDTHAD) = "000" else
                      rom_d(1) when rom_device_a(GALAXIAN_ROM_WIDTHAD+2 downto GALAXIAN_ROM_WIDTHAD) = "001" else
                      rom_d(2) when rom_device_a(GALAXIAN_ROM_WIDTHAD+2 downto GALAXIAN_ROM_WIDTHAD) = "010" else
                      rom_d(3) when rom_device_a(GALAXIAN_ROM_WIDTHAD+2 downto GALAXIAN_ROM_WIDTHAD) = "011" else
                      rom_d(4) when rom_device_a(GALAXIAN_ROM_WIDTHAD+2 downto GALAXIAN_ROM_WIDTHAD) = "100" else
                      rom_d(5) when rom_device_a(GALAXIAN_ROM_WIDTHAD+2 downto GALAXIAN_ROM_WIDTHAD) = "101" else
                      rom_d(6) when rom_device_a(GALAXIAN_ROM_WIDTHAD+2 downto GALAXIAN_ROM_WIDTHAD) = "110" else
                      rom_d(7);

    GEN_CPU_ROMS : for i in GALAXIAN_ROM'range generate
      rom_inst : entity work.sprom
        generic map
        (
          init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" &
                          GALAXIAN_ROM(i) & ".hex",
          numwords_a  => 0, -- not needed
          widthad_a		=> GALAXIAN_ROM_WIDTHAD
        )
        port map
        (
          clock			=> clk_sys,
          address		=> rom_device_a(GALAXIAN_ROM_WIDTHAD-1 downto 0),
          q					=> rom_d(i)
        );
    end generate GEN_CPU_ROMS;

    extra_rom_d_o <=  rom_d(4) when cpu_a(GALAXIAN_ROM_WIDTHAD+1 downto GALAXIAN_ROM_WIDTHAD) = "00" else
                      rom_d(5) when cpu_a(GALAXIAN_ROM_WIDTHAD+1 downto GALAXIAN_ROM_WIDTHAD) = "01" else
                      rom_d(6);
    
    GEN_JUMPBUG_EXTRA_ROMS : for i in GALAXIAN_EXTRA_ROM'range generate
      rom_inst : entity work.sprom
        generic map
        (
          init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" &
                          GALAXIAN_EXTRA_ROM(i) & ".hex",
          numwords_a  => 0, -- not needed
          widthad_a		=> GALAXIAN_ROM_WIDTHAD
        )
        port map
        (
          clock			=> clk_sys,
          address		=> cpu_a(GALAXIAN_ROM_WIDTHAD-1 downto 0),
          q					=> rom_d(i)
        );
    end generate GEN_JUMPBUG_EXTRA_ROMS;
    
  end block BLK_CPU_ROMS;
  
  BLK_GFX_ROMS : block

    type gfx_rom_d_a is array(0 to 5) of std_logic_vector(7 downto 0);
    signal gfx_rom_d      : gfx_rom_d_a;
    signal spr_rom_left   : gfx_rom_d_a;
    signal spr_rom_right  : gfx_rom_d_a;
    
    type bank_a is array(0 to 4) of std_logic_vector(7 downto 0);
    signal bank     : bank_a;
    signal tile_a   : std_logic_vector(12 downto 0);
    signal sprite_a : std_logic_vector(12 downto 0);

    alias code : std_logic_vector(7 downto 0) is tilemap_i(1).tile_a(10 downto 3);
    
  begin
  
    -- implement gfxbank registers
    process (clk_sys, rst_sys)
      variable i : integer range 0 to 3;
    begin
      if rst_sys = '1' then
        bank <= (others => (others => '0'));
      elsif rising_edge(clk_sys) then
        if cpu_clk_en = '1' and cpu_mem_wr = '1' then
          if PLATFORM_VARIANT = "jumpbug" then
            if STD_MATCH(cpu_a, X"600"&"0---") then
              i := to_integer(unsigned(cpu_a(2 downto 0))) - 2;
              if i < 3 then
                bank(i) <= cpu_d_o;
              end if;
            end if; -- STD_MATCH
          elsif PLATFORM_VARIANT = "mooncrst" or
              PLATFORM_VARIANT = "mooncrstu" then
            if STD_MATCH(cpu_a, X"A00"&"00--") then
              i := to_integer(unsigned(cpu_a(1 downto 0)));
              if i < 3 then
                bank(i) <= cpu_d_o;
              end if;
            end if; -- STD_MATCH
          elsif PLATFORM_VARIANT = "pacmanbl" then
            if STD_MATCH(cpu_a, X"6002") then
              bank(0) <= cpu_d_o;
            end if;  -- STD_MATCH
          end if; -- PLATFORM_VARIANT
        end if; -- cpu_mem_wr
      end if; -- rising_edge(clk_sys)
    end process;

    GEN_TILE_A : if PLATFORM_VARIANT = "ckongg" generate
      -- all 9 bits are 'code' (generated in controller)
      tile_a(12 downto 3) <= tilemap_i(1).tile_a(12 downto 3);
    elsif PLATFORM_VARIANT = "jumpbug" generate
    
      --if ((*code & 0xc0) == 0x80 && (state->m_gfxbank[2] & 0x01))
      --  *code += 128 + (( state->m_gfxbank[0] & 0x01) << 6) +
      --         (( state->m_gfxbank[1] & 0x01) << 7) +
      --         ((~state->m_gfxbank[4] & 0x01) << 8);
      tile_a(12 downto 3) <= code + 
                              128 +
                              ('0' & bank(4)(0) & bank(1)(0) & bank(0)(0) & "000000")
                                when (code(7 downto 6) = "10" and bank(2)(0) /= '0') else
                              "00" & code;
      
    elsif PLATFORM_VARIANT = "mooncrst" or
          PLATFORM_VARIANT = "mooncrstu" generate
      -- mooncrst_extend_tile_info
      -- if (state->m_gfxbank[2] && (*code & 0xc0) == 0x80)
      -- 	*code = (*code & 0x3f) | (state->m_gfxbank[0] << 6) | (state->m_gfxbank[1] << 7) | 0x0100;
      tile_a(12 downto 3) <= "01" & bank(1)(0) & bank(0)(0) & code(5 downto 0)
                                  when (bank(2) /= X"00" and code(7 downto 6) = "10") else
                             "00" & code;
    else generate
      tile_a(12 downto 3) <= "00" & code;
    end generate GEN_TILE_A;

    -- the non-code (row) part of the tile address
    tile_a(2 downto 0) <= tilemap_i(1).tile_a(2 downto 0);
    
    tilemap_o(1).tile_d(15 downto 0) <= gfx_rom_d(0) & gfx_rom_d(1)(7 downto 2) & gfx_rom_d(1)(0) & gfx_rom_d(1)(1)
                                          when PLATFORM_VARIANT = "frogger" else
                                        gfx_rom_d(0) & gfx_rom_d(1) when tile_a(GALAXIAN_TILE_ROM_WIDTHAD) = '0' else
                                        gfx_rom_d(2) & gfx_rom_d(3);

    GEN_TILE_ROMS : for i in GALAXIAN_TILE_ROM'range generate
      tile_rom_inst : entity work.sprom
        generic map
        (
          init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" &
                          GALAXIAN_TILE_ROM(i) & ".hex",
          numwords_a  => 0, -- not needed
          widthad_a		=> GALAXIAN_TILE_ROM_WIDTHAD
        )
        port map
        (
          clock			=> clk_video,
          address		=> tile_a(GALAXIAN_TILE_ROM_WIDTHAD-1 downto 0),
          q					=> gfx_rom_d(i)
        );
    end generate GEN_TILE_ROMS;

    GEN_SPRITE_A : if PLATFORM_VARIANT = "mooncrst" or
                      PLATFORM_VARIANT = "mooncrstu" generate
      -- mooncrst_extend_sprite_info(running_machine &machine, const UINT8 *base, UINT8 *sx, UINT8 *sy, UINT8 *flipx, UINT8 *flipy, UINT16 *code, UINT8 *color)
      -- if (state->m_gfxbank[2] && (*code & 0x30) == 0x20)
      -- 	*code = (*code & 0x0f) | (state->m_gfxbank[0] << 4) | (state->m_gfxbank[1] << 5) | 0x40;
      -- - code = (10..5)
      sprite_a <= "01" & bank(1)(0) & bank(0)(0) & sprite_i.a(8 downto 0) when
                    (bank(2) /= X"00" and sprite_i.a(10 downto 9) = "10") else
                  "00" & sprite_i.a(10 downto 0);
    else generate
      sprite_a <= std_logic_vector(resize(unsigned(sprite_i.a(GALAXIAN_SPRITE_ROM_WIDTHAD-1 downto 0)),sprite_a'length));
    end generate GEN_SPRITE_A;
                      
    GEN_SPRITE_ROMS : for i in GALAXIAN_SPRITE_ROM'range generate
      sprite_rom_inst : entity work.dprom_2r
        generic map
        (
          init_file		=> PLATFORM_VARIANT_SRC_DIR & "roms/" &
                          GALAXIAN_SPRITE_ROM(i) & ".hex",
          widthad_a		=> GALAXIAN_SPRITE_ROM_WIDTHAD,
          widthad_b		=> GALAXIAN_SPRITE_ROM_WIDTHAD
        )
        port map
        (
          clock			              => clk_video,
          address_a(GALAXIAN_SPRITE_ROM_WIDTHAD-1 downto 4)  
                                  => sprite_a(GALAXIAN_SPRITE_ROM_WIDTHAD-1 downto 4),
          address_a(3)            => '0',
          address_a(2 downto 0)   => sprite_a(2 downto 0),
          q_a 			              => spr_rom_left(i),
          address_b(GALAXIAN_SPRITE_ROM_WIDTHAD-1 downto 4)  
                                  => sprite_a(GALAXIAN_SPRITE_ROM_WIDTHAD-1 downto 4),
          address_b(3)            => '1',
          address_b(2 downto 0)   => sprite_a(2 downto 0),
          q_b                     => spr_rom_right(i)
        );
    end generate GEN_SPRITE_ROMS;

    sprite_o.d(sprite_o.d'left downto 32) <= (others => '0');
    sprite_o.d(31 downto 0) <=  spr_rom_left(0) & spr_rom_right(0) & 
                                spr_rom_left(1) & spr_rom_right(1)
                                  when sprite_a(GALAXIAN_SPRITE_ROM_WIDTHAD) = '0' else
                                spr_rom_left(2) & spr_rom_right(2) & 
                                spr_rom_left(3) & spr_rom_right(3);
    
  end block BLK_GFX_ROMS;

	-- wren_a *MUST* be GND for CYCLONEII_SAFE_WRITE=VERIFIED_SAFE
	vram_inst : entity work.galaxian_vram
		port map
		(
			clock_b			=> clk_sys,
			address_b		=> cpu_a(9 downto 0),
			wren_b			=> vram_wr,
			data_b			=> cpu_d_o,
			q_b					=> vram_d_o,

			clock_a			=> clk_video,
			address_a		=> tilemap_i(1).map_a(9 downto 0),
			wren_a			=> '0',
			data_a			=> (others => 'X'),
			q_a					=> tilemap_o(1).map_d(7 downto 0)
		);
  tilemap_o(1).map_d(15 downto 8) <= (others => '0');

  BLK_CRAM : block
    signal cram_d_i   : std_logic_vector(7 downto 0);
  begin
  
    GEN_CRAM_D : if PLATFORM_VARIANT = "frogger" generate
                    -- data = (data >> 4) | (data << 4);
      cram_d_i <= cpu_d_o(3 downto 0) & cpu_d_o(7 downto 4) 
                      when cpu_a(0) = '0' else
                    -- *color = ((*color >> 1) & 0x03) | ((*color << 2) & 0x04);
                    "00000" & cpu_d_o(0) & cpu_d_o(2 downto 1);
    else generate
      cram_d_i <= cpu_d_o;
    end generate GEN_CRAM_D;
    
    -- tilemap colour ram
    -- - even addresses: scroll position
    -- - odd addresses: colour base for row
    cram_inst : entity work.galaxian_cram
      port map
      (
        clock_b			=> clk_sys,
        address_b		=> cpu_a(7 downto 0),
        wren_b			=> cram_wr,
        data_b			=> cram_d_i,
        q_b					=> cram_d_o,
        
        clock_a			=> clk_video,
        address_a		=> tilemap_i(1).attr_a(7 downto 1),
        q_a					=> tilemap_o(1).attr_d(15 downto 0)
      );
      
  end block BLK_CRAM;
  
  GEN_WRAM : if GALAXIAN_USE_INTERNAL_WRAM generate
  
    wram_inst : entity work.spram
      generic map
      (
        numwords_a  => 0, -- not needed
      	widthad_a => GALAXIAN_WRAM_WIDTHAD
      )
      port map
      (
        clock				=> clk_sys,
        address			=> cpu_a(GALAXIAN_WRAM_WIDTHAD-1 downto 0),
        data				=> cpu_d_o,
        wren				=> wram_wr,
        q						=> wram_d_o
      );
  
    sram_o <= NULL_TO_SRAM;
    
  else generate
  
    -- SRAM signals (may or may not be used)
    sram_o.a <= std_logic_vector(resize(unsigned(cpu_a(13 downto 0)), sram_o.a'length));
    sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length));
    wram_d_o <= sram_i.d(wram_d_o'range);
    sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
    sram_o.cs <= '1';
    sram_o.oe <= wram_cs and not cpu_mem_wr;
    sram_o.we <= wram_wr;

  end generate GEN_WRAM;

  BLK_BITMAP : block
    signal bitmap_en      : std_logic;
  begin
  
    process (clk_sys, rst_sys)
    begin
      if rst_sys = '1' then
        bitmap_en <= '1';
      elsif rising_edge(clk_sys) then
        if PLATFORM_VARIANT = "ckongg" or
            PLATFORM_VARIANT = "pacmanbl" then
          bitmap_en <= '0';
        else
        end if;
      end if;
    end process;
    
    graphics_o.bit8(0)(0) <= bitmap_en;
    
  end block BLK_BITMAP;
  
  GEN_PIA8255 : if PLATFORM_VARIANT = "frogger" or
                    PLATFORM_VARIANT = "scramble" generate
                    
    component pia8255 is
      port
      (
        -- uC interface
        clk     : in std_logic;
        clken   : in std_logic;
        reset   : in std_logic;
        a       : in std_logic_vector(1 downto 0);
        d_i     : in std_logic_vector(7 downto 0);
        d_o     : out std_logic_vector(7 downto 0);
        cs    	: in std_logic;
        rd  	  : in std_logic;
        wr	    : in std_logic;

        -- I/O interface
        pa_i    : in std_logic_vector(7 downto 0);
        pb_i    : in std_logic_vector(7 downto 0);
        pc_i    : in std_logic_vector(7 downto 0);
        pa_o    : out std_logic_vector(7 downto 0);
        pb_o    : out std_logic_vector(7 downto 0);
        pc_o    : out std_logic_vector(7 downto 0)
      );
    end component pia8255;
  
    signal pia8255_a  : std_logic_vector(1 downto 0);
    signal pia0_pc_i  : std_logic_vector(7 downto 0);
    signal pia1_pc_i  : std_logic_vector(7 downto 0);
    signal pia1_pc_o  : std_logic_vector(7 downto 0);
    
    signal prot_d_o   : std_logic_vector(7 downto 0);
    
  begin
  
    pia8255_a <=  cpu_a(2 downto 1) when PLATFORM_VARIANT = "frogger" else
                  cpu_a(1 downto 0) when PLATFORM_VARIANT = "scramble";
  
    pia0_pc_i <=  prot_d_o(7) & inputs_i(2).d(6) & prot_d_o(7) & inputs_i(2).d(4 downto 0)
                    when PLATFORM_VARIANT = "scramble" else
                  inputs_i(2).d;
                  
    pia8255_0_inst : pia8255
      port map
      (
        -- uC interface
        clk			=> clk_sys,
        clken		=> '1',
        reset		=> cpu_rst,
        a				=> pia8255_a,
        d_i			=> cpu_d_o,
        d_o			=> pia0_d_o,
        cs			=> pia0_cs,
        rd			=> cpu_mem_rd,
        wr			=> cpu_mem_wr,
        
        -- I/O interface
        pa_i		=> inputs_i(0).d,
        pa_o		=> open,
        pb_i		=> inputs_i(1).d,
        pb_o		=> open,
        pc_i		=> pia0_pc_i,
        pc_o		=> open
      );

    pia8255_1_inst : pia8255
      port map
      (
        -- uC interface
        clk			=> clk_sys,
        clken		=> '1',
        reset		=> cpu_rst,
        a				=> pia8255_a,
        d_i			=> cpu_d_o,
        d_o			=> pia1_d_o,
        cs			=> pia1_cs,
        rd			=> cpu_mem_rd,
        wr			=> cpu_mem_wr,
        
        -- I/O interface
        pa_i		=> (others => '0'),
        pa_o		=> open,
        pb_i		=> (others => '0'),
        pb_o		=> open,
        pc_i		=> pia1_pc_i,
        pc_o		=> pia1_pc_o
      );

    GEN_SCRAMBLE_PROT : if PLATFORM_VARIANT = "scramble" generate
    begin
      --  state->m_protection_state = (state->m_protection_state << 4) | (data & 0x0f);
      --	switch (state->m_protection_state & 0xfff)
      --	{
      --		/* scramble */
      --		case 0xf09:		state->m_protection_result = 0xff;	break;
      --		case 0xa49:		state->m_protection_result = 0xbf;	break;
      --		case 0x319:		state->m_protection_result = 0x4f;	break;
      --		case 0x5c9:		state->m_protection_result = 0x6f;	break;
      --
      --		/* scrambls */
      --		case 0x246:		state->m_protection_result ^= 0x80;	break;
      --		case 0xb5f:		state->m_protection_result = 0x6f;	break;
      --	}
      process (clk_sys, cpu_rst)
        variable prot_state : std_logic_vector(11 downto 0);
        variable pc_o_r     : std_logic_vector(7 downto 0);
      begin
        if cpu_rst = '1' then
          prot_state := (others => '0');
          prot_d_o <= (others => '0');
        elsif rising_edge(clk_sys) then
          if pia1_pc_o /= pc_o_r then
            prot_state := prot_state(7 downto 0) & pia1_pc_o(3 downto 0);
            case prot_state is
              -- scramble
              when X"F09" =>
                prot_d_o <= X"FF";
              when X"A49" =>
                prot_d_o <= X"BF";
              when X"319" =>
                prot_d_o <= X"4F";
              when X"5C9" =>
                prot_d_o <= X"6F";
              -- scrambls
              when X"246" =>
                prot_d_o(7) <= prot_d_o(7) xor '1';
              when X"B5F" =>
                prot_d_o <= X"6F";
              when others =>
                null;
            end case;
          end if; -- pia1_pc_o /= pc_o_r
          pc_o_r := pia1_pc_o;
        end if; -- rising_egde(clk_sys)
      end process;
      
      pia1_pc_i <= prot_d_o;
      
    end generate GEN_SCRAMBLE_PROT;
    
  end generate GEN_PIA8255;
  
  -- unused outputs

  flash_o <= NULL_TO_FLASH;
  bitmap_o <= (others => NULL_TO_BITMAP_CTL);
  sprite_o.ld <= '0';
  --graphics_o <= NULL_TO_GRAPHICS;
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  spi_o <= NULL_TO_SPI;
  ser_o <= NULL_TO_SERIAL;
  leds_o <= (others => '0');
  
end SYN;
