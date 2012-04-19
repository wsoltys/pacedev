library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
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

	alias clk_24M					    : std_logic is clkrst_i.clk(0);
  alias rst_24M             : std_logic is clkrst_i.rst(0);
	alias clk_video				    : std_logic is clkrst_i.clk(1);
	signal cpu_reset			    : std_logic;
  
  -- uP signals  
  signal clk_6M_en			    : std_logic;
  signal clk_1M5_en			    : std_logic;
	signal cpu_clk_en         : std_logic;
	signal cpu_r_wn				    : std_logic;
	signal cpu_a				      : std_logic_vector(15 downto 0);
	signal cpu_d_i			      : std_logic_vector(7 downto 0);
	signal cpu_d_o			      : std_logic_vector(7 downto 0);
	signal cpu_irq				    : std_logic;

  -- cart signals        
	signal cart_cs				    : std_logic;
  signal cart_d_o           : std_logic_vector(7 downto 0);

  -- RAM signals        
	signal ram_cs				      : std_logic;
  signal ram_wr             : std_logic;
  alias ram_d_o      	      : std_logic_vector(7 downto 0) is sram_i.d(7 downto 0);
  
  -- ROM signals        
	signal rom_cs				      : std_logic;
  signal rom_d_o            : std_logic_vector(7 downto 0);
	
  -- 6522 signals
  signal via_cs             : std_logic;
  signal via_d_o            : std_logic_vector(7 downto 0);
  signal via_d_oe_n         : std_logic;
  signal via_pa_o           : std_logic_vector(7 downto 0);
  signal via_pa_oe_n        : std_logic_vector(7 downto 0);
  signal via_i_p2_h         : std_logic;
  signal via_irq_n          : std_logic;
  
  -- AY-3-8912 signals
  signal ay38912_bc1        : std_logic;
  signal ay38912_bdir       : std_logic;
  signal ay38912_a_o        : std_logic_vector(7 downto 0);
  signal ay38912_b_o        : std_logic_vector(7 downto 0);
  signal ay38912_c_o        : std_logic_vector(7 downto 0);
  signal ay38912_d_o        : std_logic_vector(7 downto 0);

  -- DAC
  signal dac_d_i            : std_logic_vector(7 downto 0);

  -- other signals   
  signal s_hn               : std_logic;
  signal sel                : std_logic_vector(1 downto 0);
  signal compare            : std_logic;
  signal ramp_n             : std_logic;
  alias sw                  : std_logic_vector(7 downto 0) is inputs_i(0).d;
  signal zero_n             : std_logic;
  signal blank_n            : std_logic;

  -- vector types
  constant VECTOR_SIZE      : natural := 20;
  subtype vector_t is signed(VECTOR_SIZE-1 downto 0);
  
  -- integrators
  signal x_v                : vector_t;
  signal y_v                : vector_t;
  signal z                  : std_logic_vector(7 downto 0);
  signal offset             : vector_t;
  -- vector outputs
  signal x_vector           : vector_t;
  signal y_vector           : vector_t;
  
	alias platform_reset			: std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(0);
	alias osd_toggle          : std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(1);
	alias platform_pause      : std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(2);
	alias erase               : std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(3);
	alias use_blank           : std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(4);
	alias use_z               : std_logic is inputs_i(PACE_INPUTS_NUM_BYTES-1).d(5);

  attribute noprune             : boolean;
  attribute noprune of x_v      : signal is true;
  attribute noprune of y_v      : signal is true;
  attribute noprune of x_vector : signal is true;
  attribute noprune of y_vector : signal is true;
  attribute noprune of z        : signal is true;

begin

  -- SRAM signals (may or may not be used)
  sram_o.a(sram_o.a'left downto 10) <= (others => '0');
  -- 1KB
  sram_o.a(9 downto 0) <= std_logic_vector(resize(unsigned(cpu_a), 10));
  sram_o.d <= std_logic_vector(resize(unsigned(cpu_d_o), sram_o.d'length)) 
								when (ram_wr = '1') else (others => 'Z');
  sram_o.be <= std_logic_vector(to_unsigned(1, sram_o.be'length));
  sram_o.cs <= '1';
  sram_o.oe <= not ram_wr;
  sram_o.we <= ram_wr;

	-- cartridge $0000-$7FFF
	cart_cs <=		'1' when STD_MATCH(cpu_a,  "0---------------") else
								'0';
  -- RAM $C800-$CFFF (1KB shadowed)
  ram_cs <=		  '1' when STD_MATCH(cpu_a, X"C"&"1-----------") else
                '0';
  -- registers $D000-$DFFF
  via_cs <=		  '1' when STD_MATCH(cpu_a, X"D"&"------------") else
                '0';
  -- ROM $E000-$FFFF
	rom_cs  <= 	  '1' when STD_MATCH(cpu_a,  "111-------------") else 
                '0';

  -- memory block write enables
  ram_wr <= ram_cs and clk_1M5_en and not cpu_r_wn;

	-- memory read mux
	cpu_d_i <=  cart_d_o when cart_cs = '1' else
							ram_d_o when ram_cs = '1' else
							via_d_o when via_cs = '1' else
              rom_d_o when rom_cs = '1' else
							(others => 'Z');
		
  -- system timing
  process (clk_24M, rst_24M)
    variable cnt_16   : unsigned(3 downto 0);
  begin
    if rst_24M = '1' then
      clk_6M_en <= '0'; -- default
      clk_1M5_en <= '0'; -- default
      cnt_16 := (others => '0');
    elsif rising_edge(clk_24M) then
      clk_6M_en <= '0'; -- default
      clk_1M5_en <= '0'; -- default
      if cnt_16(1 downto 0) = "10" then
        clk_6M_en <= '1';
        if cnt_16(3 downto 2) = "00" then
          clk_1M5_en <= '1';
        end if;
      end if;
      cnt_16 := cnt_16 + 1;
    end if;
    via_i_p2_h <= not cnt_16(cnt_16'left);
  end process;

	-- cpu09 core uses negative clock edge
	--cpu_clk_en <= not (clk_1M5_en and not platform_pause);
	cpu_clk_en <= clk_1M5_en and not platform_pause;

	-- add game reset later
	cpu_reset <= rst_24M or platform_reset;
  cpu_irq <= not via_irq_n;
  
	cpu_inst : entity work.cpu09
    generic map
    (
      CLK_POL   => '1'
    )
		port map
		(	
			clk				=> clk_24M,
      clk_en    => cpu_clk_en,
			rst				=> cpu_reset,
			rw				=> cpu_r_wn,
			vma				=> open,
      --ba        => open,
      --bs        => open,
			addr		  => cpu_a,
		  data_in		=> cpu_d_i,
		  data_out	=> cpu_d_o,
			halt			=> '0',
			hold			=> '0',
			irq				=> cpu_irq,
			firq			=> '0',
			nmi				=> '0'
		);

  BLK_VECTOR_HW : block
    subtype delay_t is integer range 0 to 187-1;
  begin
  
    -- Vector analogue hardware modules have a 
    -- propagation delay of ~7800ns (187 clocks @24MHz)
    -- - important for vector operations
  
    -- Analogue MUX
    process (clk_24M, rst_24M)
      variable s_hn_r     : std_logic;
      variable s_hn_d     : std_logic;
      variable sel_d      : std_logic_vector(sel'range);
      variable dac_d      : std_logic_vector(dac_d_i'range);
      variable delay_cnt  : delay_t;
    begin
      if rst_24M = '1' then
        offset <= (others => '0');
        x_v <= (others => '0');
        y_v <= (others => '0');
        z <= (7 => '1', others => '0');
        s_hn_r := '1';
        delay_cnt := 0;
      elsif rising_edge(clk_24M) then
--        -- handle delay
--        if s_hn /= s_hn_r then
--          delay_cnt := delay_cnt'high;
--        elsif delay_cnt = 0 then
          s_hn_d := s_hn;
          sel_d := sel;
          dac_d := dac_d_i;
--        else
--          delay_cnt := delay_cnt - 1;
--        end if;
--        s_hn_r := s_hn;
        -- handle mux
        if s_hn_d = '0' then
          case sel_d is
            when "00" =>
              y_v <= resize(signed(dac_d), y_v'length);
            when "01" =>
              -- offset must be same scale as output vector
              offset(offset'left downto offset'left-7) <= signed(dac_d);
              offset(offset'left-8 downto 0) <= (others => dac_d(0));
            when "10" =>
              z <= dac_d;
            when others =>
              null;
          end case;
        else
          x_v <= resize(signed(dac_d), x_v'length);
        end if; -- s_hn='0'
      end if;
    end process;

    dac_d_i <= via_pa_o;
    
    -- integrator
    process (clk_24M, rst_24M)
      variable x : vector_t;
      variable y : vector_t;
      -- fine(r) gain control
      variable count : integer range 0 to 24-1;
      -- ramp delay
      variable ramp_n_r   : std_logic;
      variable ramp_d     : std_logic;
      variable ramp_d_cnt : delay_t;
      variable zero_n_r   : std_logic;
      variable zero_d     : std_logic;
      variable zero_d_cnt : delay_t;
    begin
      if rst_24M = '1' then
        count := 0;
        ramp_n_r := '1';
        ramp_d := '0';
        ramp_d_cnt := 0;
      elsif rising_edge(clk_24M) then
        -- handle ramp delay
        if ramp_n_r /= ramp_n then
          ramp_d_cnt := ramp_d_cnt'high;
        elsif ramp_d_cnt = 0 then
          -- assume min pulse width > delay
          ramp_d := not ramp_n;
        else
          ramp_d_cnt := ramp_d_cnt - 1;
        end if;
        ramp_n_r := ramp_n;
        -- handle zero delay
        if zero_n_r /= zero_n then
          zero_d_cnt := zero_d_cnt'high;
        elsif zero_d_cnt = 0 then
          -- assume min pulse width > delay
          zero_d := not zero_n;
        else
          zero_d_cnt := zero_d_cnt - 1;
        end if;
        zero_n_r := zero_n;
        -- intgerate
        if zero_d = '1' then
          -- offset to middle of screen
          x := (x'left => '1', others => '0');
          y := (y'left => '1', others => '0');
          count := 0;
  --      elsif count = count'high then
        else
          if ramp_d = '1' then
            x := x + x_v;
            y := y + y_v;
          end if;
          count := 0;
  --      else
  --        count := count + 1;
        end if;
      end if;
      x_vector <= x + offset;
      y_vector <= y + offset;
    end process;

  end block BLK_VECTOR_HW;
  
  BLK_VIA : block
    signal via_pb_i         : std_logic_vector(7 downto 0);
    signal via_pb_o         : std_logic_vector(7 downto 0);
    signal via_pb_oe_n      : std_logic_vector(7 downto 0);
    signal via_o_ca2        : std_logic;
    signal via_o_ca2_oe_n   : std_logic;
    signal via_o_cb2        : std_logic;
    signal via_o_cb2_oe_n   : std_logic;
    
    signal pot              : signed(7 downto 0);
  begin
  
    via_pb_i(5) <= compare;

    -- handle analogue joysticks
    -- - 'sel' selects input
    pot <= X"00";
    compare <= '1' when pot > signed(via_pa_o) else '0';

    process (clk_24M, rst_24M)
    begin
      if rst_24M = '1' then
        blank_n <= '0';
      elsif rising_edge(clk_24M) then
        -- Port 'B' Data - Vectrex Hardware Control [CNTRL]
        if via_pb_oe_n(0) = '0' then
          s_hn <= via_pb_o(0);
        end if;
        if via_pb_oe_n(1) = '0' then
          sel(0) <= via_pb_o(1);
        end if;
        if via_pb_oe_n(2) = '0' then
          sel(1) <= via_pb_o(2);
        end if;
        if via_pb_oe_n(3) = '0' then
          ay38912_bc1 <= via_pb_o(3);
        end if;
        if via_pb_oe_n(4) = '0' then
          ay38912_bdir <= via_pb_o(4);
        end if;
        if via_pb_oe_n(7) = '0' then
          ramp_n <= via_pb_o(7);
        end if;
        -- CA2/CB2 - vector zero/blank control
        if via_o_ca2_oe_n = '0' then
          zero_n <= via_o_ca2;
        end if;
        if via_o_cb2_oe_n = '0' then
          blank_n <= via_o_cb2;
        end if;
      end if;
    end process;
    
    -- VIA clocking:
    -- PHI2 runs off the CPU E clock (1.5MHz = 24/16)
    -- ENA4 is 4x the PHI2 clock  (6MHz = 24/4)
    -- - with the following phase relationship:
    -- high for phase 2 clock  ____----__
    -- 4x system clock (4HZ)   _-_-_-_-_-
    
    via_inst : entity work.M6522
      port map
      (
        I_RS              => cpu_a(3 downto 0),
        I_DATA            => cpu_d_o,
        O_DATA            => via_d_o,
        O_DATA_OE_L       => via_d_oe_n,

        I_RW_L            => cpu_r_wn,
        I_CS1             => via_cs,      -- really A12
        I_CS2_L           => not via_cs,

        O_IRQ_L           => via_irq_n,
        -- port a
        I_CA1             => sw(7),
        I_CA2             => '0',
        O_CA2             => via_o_ca2,
        O_CA2_OE_L        => via_o_ca2_oe_n,

        I_PA              => ay38912_d_o,
        O_PA              => via_pa_o,
        O_PA_OE_L         => via_pa_oe_n,

        -- port b
        I_CB1             => '0',
        O_CB1             => open,
        O_CB1_OE_L        => open,

        I_CB2             => '0',
        O_CB2             => via_o_cb2,
        O_CB2_OE_L        => via_o_cb2_oe_n,

        I_PB              => via_pb_i,
        O_PB              => via_pb_o,
        O_PB_OE_L         => via_pb_oe_n,

        I_P2_H            => via_i_p2_h,  -- high for phase 2 clock  ____----__
        RESET_L           => not rst_24M,
        ENA_4             => clk_6M_en,
        CLK               => clk_24M
      );
    
  end block BLK_VIA;

  BLK_AY3_8912 : block 
  begin
    ay3_8912_inst : entity work.ay_3_8910
      port map
      (
        -- AY-3-8910 sound controller
        clk         => clk_24M,
        reset       => rst_24M,
        clk_en      => clk_1M5_en,

        -- CPU I/F
        cpu_d_in    => via_pa_o,
        cpu_d_out   => ay38912_d_o,
        cpu_bdir    => ay38912_bdir,
        cpu_bc1     => ay38912_bc1,
        cpu_bc2     => '1',

        -- I/O I/F
        io_a_in     => sw,
        io_b_in     => (others => '0'),
        io_a_out    => open,
        io_b_out    => open,

        -- Sound output
        snd_A       => ay38912_a_o,
        snd_B       => ay38912_b_o,
        snd_C       => ay38912_c_o
      );
  end block BLK_AY3_8912;
  
	GEN_FPGA_ROMS : if true generate
  begin
  
    cart_d_o <= X"FF";
    
    system_rom_inst : entity work.sprom
      generic map
      (
        init_file		=> VECTREX_ROM_DIR & "system.hex",
        widthad_a		=> 13
      )
      port map
      (
        clock			=> clk_24M,
        address		=> cpu_a(12 downto 0),
        q					=> rom_d_o
      );
    
	end generate GEN_FPGA_ROMS;

  BLK_VRAM : block
  
    signal pixel_data : std_logic_vector(7 downto 0);
    
    signal vram_d_i   : std_logic_vector(7 downto 0);
    signal vram_d_o   : std_logic_vector(7 downto 0);
    signal vram_a     : std_logic_vector(14 downto 0);
    signal vram_we    : std_logic;
  
  begin
  
    -- process to update video ram and do a _crude_ decay
    -- decay just wipes one byte of video ram
    -- each time a set number of points is displayed
    -- given by (count'length - vram_addr'length)
    process (clk_24M, clkrst_i.arst)
      variable state 				: integer range 0 to 4;
      variable beam_ena_r 	: std_logic := '0';
      variable count				: unsigned(15 downto 0);
    begin
      if clkrst_i.arst = '1' then
        state := 0;
        beam_ena_r := '0';
        count := (others => '0');
      elsif rising_edge(clk_24M) then

        -- default case
        vram_we <= '0' after 2 ns;

        case state is
        
          when 0 =>
            -- prepare to draw a pixel if it's on
            vram_a(5 downto 0) <= std_logic_vector(x_vector(x_vector'left downto x_vector'left-5));
            vram_a(14 downto 6) <= not std_logic_vector(y_vector(y_vector'left downto y_vector'left-8));
            case x_vector(x_vector'left-6 downto x_vector'left-8) is
              when "000" =>		pixel_data <= "00000001";
              when "001" =>		pixel_data <= "00000010";
              when "010" =>		pixel_data <= "00000100";
              when "011" =>		pixel_data <= "00001000";
              when "100" =>		pixel_data <= "00010000";
              when "101" =>		pixel_data <= "00100000";
              when "110" =>		pixel_data <= "01000000";
              when others =>	pixel_data <= "10000000";
            end case;
            -- only draw if beam intensity is non-zero
            if (use_blank = '1' and blank_n = '0') or
                (use_z = '1' and (z(7) = '1' or z = X"00")) then
              state := 3;
            else
              state := 1;
            end if;

          when 1 =>
            state := 2;

          when 2 =>
            -- do the write-back
            vram_d_i <= pixel_data or vram_d_o after 2 ns;
            vram_we <= '1' after 2 ns;
            state := 3;

          when 3 =>
            state := 4;
            
          when 4 =>
            -- only erase if it's activated (and we're not paused)
            if erase = '1' and platform_pause = '0' then
              -- latch the 'erase' counter value for vram_addr
              vram_a <= std_logic_vector(count(count'left downto count'length-vram_a'length));
              -- only erase once per address
              if count(count'length-vram_a'length-1 downto 0) = 0 then
                -- erase the whole byte
                vram_d_i <= (others => '0') after 2 ns;
                vram_we <= '1' after 2 ns;
              end if;
            end if;
            count := count + 1;
            state := 0;

          when others =>
            state := 0;
        end case;
        -- latch for rising-edge detect
        --beam_ena_r := beam_ena;
      end if;
    end process;

    vram_inst : entity work.dpram
      generic map
      (
        numwords_a				=> 32768,
        widthad_a					=> 15
    -- pragma translate_off
        ,init_file         => "null32k.hex"
    -- pragma translate_on
      )
      port map
      (
        -- video interface
        clock_a						=> clk_video,
        address_a					=> bitmap_i(1).a(14 downto 0),
        wren_a						=> '0',
        data_a						=> (others => 'X'),
        q_a								=> bitmap_o(1).d(7 downto 0),
        
        -- vector-generator interface
        clock_b						=> clk_24M,
        address_b					=> vram_a(14 downto 0),
        wren_b						=> vram_we,
        data_b						=> vram_d_i,
        q_b								=> vram_d_o
      );

  end block BLK_VRAM;
  
  -- unused outputs
  flash_o <= NULL_TO_FLASH;
  graphics_o.bit16(0) <= (others => '0');
  osd_o <= NULL_TO_OSD;
  snd_o <= NULL_TO_SOUND;
  ser_o <= NULL_TO_SERIAL;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

end SYN;
