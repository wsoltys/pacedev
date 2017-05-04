--
--	This file is a *derivative* work of MikeJ's Asteroids Deluxe implementation.
--	The original source can be downloaded from <http://www.fpgaarcade.com>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clkrst_i        : in from_CLKRST_t;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_INPUTS_t;

    -- external ROM/RAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_flash_t;
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;
		sdram_i         : in from_SDRAM_t;
		sdram_o         : out to_SDRAM_t;

    -- video
    video_i         : in from_VIDEO_t;
    video_o         : out to_VIDEO_t;

    -- audio
    audio_i         : in from_AUDIO_t;
    audio_o         : out to_AUDIO_t;
    
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
end entity PACE;

architecture SYN of PACE is

  alias clk_24M               : std_logic is clkrst_i.clk_ref;
	alias clk_12M								: std_logic is clkrst_i.clk(0);
	alias clk_video						  : std_logic is clkrst_i.clk(1);
	signal reset_n							: std_logic;

  -- black widow signals	
  alias cpu_reset_h           : std_logic is clkrst_i.rst(0);
  signal soundval             :	STD_LOGIC_VECTOR(7 downto 0);
  signal xval                 :	STD_LOGIC_VECTOR(9 downto 0);
  signal yval                 :	STD_LOGIC_VECTOR(9 downto 0);
  signal zval	                :	STD_LOGIC_VECTOR(7 downto 0);
  signal rgb	                :	STD_LOGIC_VECTOR(2 downto 0);
  signal O_DBG                : STD_LOGIC_VECTOR(15 downto 0);
  signal buttons              :	STD_LOGIC_VECTOR(14 downto 0);

	-- video generator signals
  signal beam_on              : std_logic;
  signal beam_ena             : std_logic;
	signal vid_addr							: std_logic_vector(15 downto 0);
	signal vid_q								: std_logic_vector(23 downto 0);
	
	-- video ram signals
	signal vram_addr						: std_logic_vector(14 downto 0);
	signal vram_data						: std_logic_vector(23 downto 0);
	signal vram_wren						: std_logic;
	signal vram_q								: std_logic_vector(23 downto 0);
	signal pixel_data						: std_logic_vector(23 downto 0);

	signal mapped_inputs				: from_MAPPED_INPUTS_t(0 to 2);
	alias game_reset						: std_logic is mapped_inputs(2).d(0);				
	alias toggle_erase					: std_logic is mapped_inputs(2).d(1);
	signal cpu_reset						: std_logic;
	signal erase								: std_logic;

  signal to_osd               : to_OSD_t;

begin

	-- map inputs
	
	reset_n <= not clkrst_i.arst;

	-- process to toggle erase with <F4>
	process (clk_24M, clkrst_i.arst)
		variable f4_r : std_logic := '0';
	begin
		if clkrst_i.arst = '1' then
			erase <= '1';
		elsif rising_edge(clk_24M) then
			if f4_r = '0' and toggle_erase = '1' then
				erase <= not erase;
			end if;
			-- latch for rising_edge detect
			f4_r := toggle_erase;
		end if;
	end process;
	
  -- *** FIXME
  beam_on <= '1';
  beam_ena <= '1';
  
	-- process to update video ram and do a _crude_ decay
	-- decay just wipes one byte of video ram
	-- each time a set number of points is displayed
	-- given by (count'length - vram_addr'length)
	process (clk_24M, reset_n)
		variable state 				: integer range 0 to 4;
    variable beam_ena_r 	: std_logic := '0';
		variable count				: std_logic_vector(18 downto 0);
    variable pel          : std_logic_vector(1 downto 0);
	begin
		if reset_n = '0' then
			state := 0;
      beam_ena_r := '0';
			count := (others => '0');
		elsif rising_edge(clk_24M) then

			-- default case
			vram_wren <= '0' after 2 ns;

			case state is
			
				when 0 =>
					-- prepare to draw a pixel if it's on
					--if beam_on = '1' and beam_ena_r = '0' and beam_ena = '1' then
					if beam_on = '1' and beam_ena = '1' then
						vram_addr(14 downto 6) <= 256 + not xval(9 downto 1);
						vram_addr(BWIDOW_H_BITS-4 downto 0) <= 32 + yval(9 downto 4);
						case yval(3 downto 1) is
							when "000" =>		pixel_data <= "000000000000000000000" & rgb;
							when "001" =>		pixel_data <= "000000000000000000" & rgb & "000";
							when "010" =>		pixel_data <= "000000000000000" & rgb & "000000";
							when "011" =>		pixel_data <= "000000000000" & rgb & "000000000";
							when "100" =>		pixel_data <= "000000000" & rgb & "000000000000";
							when "101" =>		pixel_data <= "000000" & rgb & "000000000000000";
							when "110" =>		pixel_data <= "000" & rgb & "000000000000000000";
							when others =>	pixel_data <=      rgb & "000000000000000000000";
						end case;
						-- only draw if beam intensity is non-zero
						if zval(7 downto 4) /= "0000" then
							state := 1;
						else
							state := 3;
						end if;
					end if;

				when 1 =>
          state := 2;

				when 2 =>
					-- do the write-back
					vram_data <= pixel_data or vram_q after 2 ns;
					vram_wren <= '1' after 2 ns;
					state := 3;

				when 3 =>
					state := 4;
					
				when 4 =>
					-- only erase if it's activated
					if erase = '1' then
						-- latch the 'erase' counter value for vram_addr
						vram_addr <= count(count'left downto count'length-vram_addr'length);
						-- only erase once per address
						if count(count'length-vram_addr'length-1 downto 0) = 0 then
							-- erase the whole byte
							vram_data <= (others => '0') after 2 ns;
							vram_wren <= '1' after 2 ns;
						end if;
					end if;
					count := count + 1;
					state := 0;

				when others =>
					state := 0;
			end case;
			-- latch for rising-edge detect
      beam_ena_r := beam_ena;
		end if;
	end process;

  atari_vector_inst : entity work.bwidow 
    port map 
    (
      clk => clk_12M,
      reset_h => cpu_reset_h,
      analog_sound_out => soundval,
      analog_x_out => yval,
      analog_y_out => xval,
      analog_z_out => zval,
      rgb_out => rgb,
		ext_prog_rom_addr => open,
		ext_prog_rom_data => (others => '0'),
      dbg => O_DBG,
      buttons => buttons
    );

  --psxbuttons(15 downto 0): 
  --15:SQUARE 14:CROSS 13:CIRCLE 12:TRIANGLE 11:R1 10:L1 9:R2 8:L2 
  --7:LEFT 6:DOWN 5:RIGHT 4:UP 3:START 2:X 1:X 0:SELECT
  --buttons(12 downto 0): COINAUX COINL COINR START2 START1 FD FU FL FR MU MD ML MR
  buttons <= mapped_inputs(1).d(6 downto 0) & mapped_inputs(0).d;

	vram_inst : entity work.dpram
		generic map
		(
			--numwords_a				=> 32768,
			widthad_a					=> 15,
      width_a           => 24
  -- pragma translate_off
      ,init_file         => "null32k.hex"
  -- pragma translate_on
		)
		port map
		(
			-- video interface
			clock_a						=> clk_video,
			address_a					=> vid_addr(14 downto 0),
			wren_a						=> '0',
			data_a						=> (others => 'X'),
			q_a								=> vid_q,
			
			-- vector-generator interface
			clock_b						=> clk_24M,
			address_b					=> vram_addr(14 downto 0),
			wren_b						=> vram_wren,
			data_b						=> vram_data,
			q_b								=> vram_q
		);

	inputs_inst : entity work.inputs
		generic map
		(
			NUM_INPUTS	    => PACE_INPUTS_NUM_BYTES,
			CLK_1US_DIV	    => 24
		)
	  port map
	  (
	    clk     	      => clkrst_i.clk(0),
	    reset   	      => clkrst_i.rst(0),
	    ps2clk  	      => inputs_i.ps2_kclk,
	    ps2data 	      => inputs_i.ps2_kdat,
			jamma			      => inputs_i.jamma_n,
	
	    dips     	      => switches_i(7 downto 0),
	    inputs		      => mapped_inputs
	  );

  BLK_GRAPHICS : block

    signal to_tilemap_ctl   : to_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);
    signal from_tilemap_ctl : from_TILEMAP_CTL_a(1 to PACE_VIDEO_NUM_TILEMAPS);

    signal to_bitmap_ctl    : to_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);
    signal from_bitmap_ctl  : from_BITMAP_CTL_a(1 to PACE_VIDEO_NUM_BITMAPS);

    signal to_sprite_reg    : to_SPRITE_REG_t;
    signal to_sprite_ctl    : to_SPRITE_CTL_t;
    signal from_sprite_ctl  : from_SPRITE_CTL_t;
    signal spr0_hit					: std_logic;

    signal to_graphics      : to_GRAPHICS_t;
    signal from_graphics    : from_GRAPHICS_t;

    signal to_osd           : to_OSD_t;
    signal from_osd         : from_OSD_t;

  begin
  
    vid_addr <= from_bitmap_ctl(1).a;
    to_bitmap_ctl(1).d <= vid_q;
    
    graphics_inst : entity work.Graphics                                    
      Port Map
      (
        bitmap_ctl_i    => to_bitmap_ctl,
        bitmap_ctl_o    => from_bitmap_ctl,

        tilemap_ctl_i   => to_tilemap_ctl,
        tilemap_ctl_o   => from_tilemap_ctl,

        sprite_reg_i    => to_sprite_reg,
        sprite_ctl_i    => to_sprite_ctl,
        sprite_ctl_o    => from_sprite_ctl,
        spr0_hit				=> spr0_hit,
        
        graphics_i      => to_graphics,
        graphics_o      => from_graphics,
        
        -- OSD
        to_osd          => to_osd,
        from_osd        => from_osd,

        -- video (incl. clk)
        video_i					=> video_i,
        video_o					=> video_o
      );

  end block BLK_GRAPHICS;
  
  -- hook up sound
  audio_o.ldata(15 downto 8) <= soundval;
  audio_o.ldata(7 downto 0) <= (others => '0');
  audio_o.rdata(15 downto 8) <= soundval;
  audio_o.rdata(7 downto 0) <= (others => '0');

	-- no SRAM required
	sram_o <= NULL_TO_SRAM;
  spi_o <= NULL_TO_SPI;
	leds_o <= (others => '0');

end SYN;

