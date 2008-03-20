Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk             : in std_logic_vector(0 to 3);
    test_button     : in std_logic;
    reset           : in std_logic;

    -- game I/O
    ps2clk          : inout std_logic;
    ps2data         : inout std_logic;
    dip             : in std_logic_vector(7 downto 0);
		jamma						: in JAMMAInputsType;

    -- external RAM
		sram_i					: in from_SRAM_t; 
		sram_o					: out to_SRAM_t;
		
    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
    hsync           : out std_logic;
    vsync           : out std_logic;

    -- composite video
    BW_CVBS         : out std_logic_vector(1 downto 0);
    GS_CVBS         : out std_logic_vector(7 downto 0);

    -- sound
    snd_clk         : out std_logic;
    snd_data_l      : out std_logic_vector(15 downto 0);
    snd_data_r      : out std_logic_vector(15 downto 0);

    -- SPI (flash)
    spi_clk         : out std_logic;
    spi_mode        : out std_logic;
    spi_sel         : out std_logic;
    spi_din         : in std_logic;
    spi_dout        : out std_logic;

    -- serial
    ser_tx          : out std_logic;
    ser_rx          : in std_logic;

    -- debug
    leds            : out std_logic_vector(7 downto 0)
  );

end PACE;

architecture SYN of PACE is

	alias clk_24M								: std_logic is clk(0);
	alias clk_40M								: std_logic is clk(1);
	signal reset_n							: std_logic;
	alias reset_6_l							: std_logic is reset_n;
	
  signal clk_6                : std_logic := '0';

  signal audio_s              : std_logic_vector(7 downto 0);

  signal x_vector             : std_logic_vector(9 downto 0);
  signal y_vector             : std_logic_vector(9 downto 0);
  signal z_vector             : std_logic_vector(3 downto 0);
  signal beam_on              : std_logic;
  signal beam_ena             : std_logic;

	-- video generator signals
	signal vid_addr							: std_logic_vector(15 downto 0);
	signal vid_q								: std_logic_vector(7 downto 0);
	
	-- video ram signals
	signal vram_addr						: std_logic_vector(14 downto 0);
	signal vram_data						: std_logic_vector(7 downto 0);
	signal vram_wren						: std_logic;
	signal vram_q								: std_logic_vector(7 downto 0);
	signal pixel_data						: std_logic_vector(7 downto 0);

	signal inputs								: in8(0 to 1);
	alias game_reset						: std_logic is inputs(1)(0);				
	alias toggle_erase					: std_logic is inputs(1)(1);
	signal cpu_reset						: std_logic;
	signal erase								: std_logic;

  signal to_osd               : to_OSD_t;

begin

	-- map inputs
	
	vga_clk <= clk(1);	-- fudge
	reset_n <= not reset;

	-- PLL can't produce a 6M clock
	process (clk_24M, reset)
		variable count : std_logic_vector(1 downto 0) := (others => '0');
	begin
		if reset = '1' then
      count := (others => '0');
			clk_6 <= '0';
		elsif rising_edge(clk_24M) then
			count := count + 1;
			clk_6 <= count(1);
		end if;
	end process;
		
	-- process to toggle erase with <F4>
	process (clk_24M, reset)
		variable f4_r : std_logic := '0';
	begin
		if reset = '1' then
			erase <= '1';
		elsif rising_edge(clk_24M) then
			if f4_r = '0' and toggle_erase = '1' then
				erase <= not erase;
			end if;
			-- latch for rising_edge detect
			f4_r := toggle_erase;
		end if;
	end process;
	
	-- process to update video ram and do a _crude_ decay
	-- decay just wipes one byte of video ram
	-- each time a set number of points is displayed
	-- given by (count'length - vram_addr'length)
	process (clk_24M, reset_6_l)
		variable state 				: integer range 0 to 4;
    variable beam_ena_r 	: std_logic := '0';
		variable count				: std_logic_vector(15 downto 0);
	begin
		if reset_6_l = '0' then
			state := 0;
      beam_ena_r := '0';
			count := (others => '0');
		elsif rising_edge(clk_24M) then

			-- default case
			vram_wren <= '0' after 2 ns;

			case state is
			
				when 0 =>
					-- prepare to draw a pixel if it's on
					if beam_on = '1' and beam_ena_r = '0' and beam_ena = '1' then
						vram_addr(5 downto 0) <= x_vector(9 downto 4);
						vram_addr(14 downto 6) <= not y_vector(9 downto 1);
						case x_vector(3 downto 1) is
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
						if z_vector /= "0000" then
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

	-- construct the pixel address and data value
	--vram_addr(5 downto 0) <= x_vector(9 downto 4);
	--vram_addr(14 downto 6) <= not y_vector(9 downto 1);
		
	asteroids_inst : entity work.ASTEROIDS
	  port map
		(
	    BUTTON            => inputs(0),
	    --
	    AUDIO_OUT         => audio_s,
	    --
	    X_VECTOR          => x_vector,
	    Y_VECTOR          => y_vector,
	    Z_VECTOR          => z_vector,
	    BEAM_ON           => beam_on,
	    BEAM_ENA          => beam_ena,
	    --
	    RESET_6_L         => reset_6_l,
	    CLK_6             => clk_6
		);

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
			clock_a						=> clk_40M,
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

inputs_inst : entity work.Inputs
	generic map
	(
		NUM_INPUTS 			=> 2,
		CLK_1US_DIV			=> 24
	)
  port map
  (
    clk     				=> clk_24M,
    reset   				=> reset,
    ps2clk  				=> ps2clk,
    ps2data 				=> ps2data,
		jamma						=> jamma,
		
		dips						=> (others => '0'),
		inputs					=> inputs
  );

graphics_inst : entity work.Graphics
  port map
  (
    clk             		=> clk_40M,
		reset								=> reset,

		xcentre							=> (others => '0'),
		ycentre							=> (others => '0'),

    extra_data       		=> (others => 'X'),
		palette_data				=> (others => (others => '0')),
						
    bitmapa        			=> vid_addr,
    bitmapd        			=> vid_q,
    tilemapa        		=> open,
    tilemapd        		=> (others => 'X'),
    tilea           		=> open,
    tiled           		=> (others => 'X'),
    attra           		=> open,
    attrd           		=> (others => 'X'),

    spriteaddr      		=> open,
    spritedata      		=> (others => 'X'),
    sprite_reg_addr 		=> (others => 'X'),
    updata          		=> (others => 'X'),
    sprite_wr       		=> 'X',

    to_osd              => to_osd,

    red             		=> red,
    green           		=> green,
    blue            		=> blue,
		lcm_data						=> open,
    hsync           		=> hsync,
    vsync           		=> vsync,

		vblank							=> open,

    bw_cvbs         		=> open,
    gs_cvbs         		=> open
  );

  -- hook up sound
  snd_data_l(15 downto 8) <= audio_s;
  snd_data_l(7 downto 0) <= (others => '0');
  snd_data_r(15 downto 8) <= audio_s;
  snd_data_r(7 downto 0) <= (others => '0');

	-- no SRAM required
	sram_o.d <= (others => 'X');
	sram_o.be <= (others => '0');
	sram_o.cs <= '0';
	sram_o.oe <= '0';
	sram_o.we <= '0';
	
  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';
  
	leds <= (others => '0');

end SYN;

