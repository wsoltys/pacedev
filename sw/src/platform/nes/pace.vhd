library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;
use work.nes_cart_pkg.all;

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
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
		hblank					: out std_logic;
		vblank					: out std_logic;
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

	alias clk_21M						: std_logic is clk(1);
	
	signal ppu_r						: std_logic_vector(5 downto 0) := (others => '0');
	signal ppu_g						: std_logic_vector(5 downto 0) := (others => '0');
	signal ppu_b						: std_logic_vector(5 downto 0) := (others => '0');
	signal ppu_hsync				: std_logic := '0';
	signal ppu_vsync				: std_logic := '0';

	signal prg_a						: std_logic_vector(14 downto 0) := (others => '0');
	signal prg_d						: std_logic_vector(7 downto 0) := (others => '0');
	
	signal chr_a						: std_logic_vector(13 downto 0) := (others => '0');
	signal chr_d						: std_logic_vector(7 downto 0) := (others => '0');
	
	signal irq_line_n				: std_logic := '0';
	signal irq_oe_nes				: std_logic := '0';
	signal irq_oe_cart			: std_logic := '0';
	
	signal joypad_rst				: std_logic := '0';
	signal joypad_rd				: std_logic_vector(1 to 2) := (others => '0');
	signal joypad_d					: std_logic_vector(1 to 2) := (others => '0');
	signal ps2_joypad_d			: std_logic_vector(1 to 2) := (others => '0');
	signal jamma_joypad_d		: std_logic_vector(1 to 2) := (others => '0');
	
	signal snd1							: std_logic_vector(15 downto 0) := (others => '0');
	signal snd2							: std_logic_vector(15 downto 0) := (others => '0');
	
begin

	-- open-collector IRQ line resolution
	irq_line_n <= not (irq_oe_nes or irq_oe_cart);
	
	nes_inst : entity work.nes
    generic map
    (
      ENABLE_SOUND    => true
    )
	  port map
	  (
	    clk         		=> clk_21M,
	    clk_21M_en  		=> '1',
	    reset       		=> reset,

			prg_a						=> prg_a,
			prg_d_i					=> prg_d,
			prg_d_o					=> open,
			prg_d_oe				=> open,
			prg_rom_ce_n		=> open,
			prg_rw_n				=> open,
			
	    chr_a       		=> chr_a,
	    chr_d_i     		=> chr_d,
	    chr_d_o     		=> open,
	    chr_d_oe    		=> open,
			chr_ram_rd_n		=> open,
			chr_ram_wr_n		=> open,
			
			vram_ce_n				=> '1',
			chr_a13_n				=> open,

			irq_i_n					=> irq_line_n,
			irq_oe					=> irq_oe_nes,
			
			joypad_rst			=> joypad_rst,
			joypad_rd				=> joypad_rd,
			joypad_d_i			=> joypad_d,
			
	    r           		=> ppu_r,
	    g           		=> ppu_g,
	    b           		=> ppu_b,
	    hsync       		=> ppu_hsync,
	    vsync       		=> ppu_vsync,
	
			snd1						=> snd1,
			snd2						=> snd2
	  );

	nes_cart_inst : entity work.nes_cart(TENNIS)
	--nes_cart_inst : entity work.nes_cart(WRECKCRW)
		generic map
		(
			NTSC						=> true
		)
	  port map
	  (
	    clk         		=> clk_21M,
	    reset       		=> reset,

			prg_a						=> prg_a,
			prg_d_i					=> (others => '0'),
			prg_d_o					=> prg_d,
			prg_d_oe				=> open,
			prg_rom_ce_n		=> '1',
			prg_rw_n				=> '1',
			
	    chr_a       		=> chr_a,
	    chr_d_i     		=> (others => '0'),
	    chr_d_o     		=> chr_d,
	    chr_d_oe    		=> open,
			chr_ram_rd_n		=> '1',
			chr_ram_wr_n		=> '1',
			
			vram_ce_n				=> open,
			chr_a13_n				=> '0',
			
			irq_i_n					=> irq_line_n,
			irq_oe					=> irq_oe_cart
	  );

	BLK_PS2 : block
	
		signal clk_1M_en	: std_logic := '0';
		
	begin
	
		process (clk_21M, reset)
			variable count : integer range 0 to 20 := 0;
		begin
			if reset = '1' then
				count := 0;
			elsif rising_edge(clk_21M) then
				clk_1M_en <= '0'; -- default
				if count = 20 then
					clk_1M_en <= '1';
					count := 0;
				else
					count := count + 1;
				end if;
			end if;
		end process;
		
		ps2_joypad_inst : entity work.ps2_joypad
		  port map
		  (
		    clk     				=> clk_21M,
				clk_1M_en				=> clk_1M_en,
		    reset   				=> reset,

		    ps2clk  				=> ps2clk,
		    ps2data 				=> ps2data,

				joypad_rst			=> joypad_rst,
				joypad_rd				=> joypad_rd,
				joypad_d_o			=> ps2_joypad_d
		  );

	end block BLK_PS2;

	jamma_joypad_inst : entity work.jamma_joypad
	  port map
	  (
	    clk     				=> clk_21M,
	    reset   				=> reset,

			jamma						=> jamma,

			joypad_rst			=> joypad_rst,
			joypad_rd				=> joypad_rd,
			joypad_d_o			=> jamma_joypad_d
	  );

	-- combine joypad inputs	
	joypad_d <= ps2_joypad_d or jamma_joypad_d;
	
	GEN_COMPOSITE : if PACE_ENABLE_ADV724 = '1' generate
	
		red <= ppu_r & "0000";
		green <= ppu_g & "0000";
		blue <= ppu_b & "0000";
		hsync <= ppu_hsync;
		vsync <= ppu_vsync;
		
	end generate GEN_COMPOSITE;

	GEN_VGA : if PACE_ENABLE_ADV724 = '0' generate

		BLK_SCANDBL : block

			signal clk_10M					: std_logic;

			signal ppu_rgb					: std_logic_vector(17 downto 0);
			signal ppu_hsync_p			: std_logic;
			signal ppu_vsync_p			: std_logic;
			
			signal vga_rgb					: std_logic_vector(17 downto 0);
			signal vga_hsync				: std_logic;
			signal vga_vsync				: std_logic;

		begin

			process (clk_21M, reset)
			begin
				if reset = '1' then
					clk_10M <= '0';
				elsif rising_edge(clk_21M) then
					clk_10M <= not clk_10M;
				end if;
			end process;
			
			ppu_rgb <= ppu_r & ppu_g & ppu_b;
			ppu_hsync_p <= not ppu_hsync;
			ppu_vsync_p <= not ppu_vsync;
		
			dblscan_inst : entity work.DBLSCAN
				generic map
				(
					WIDTH					=> 18
				)
			  port map
				(
					RGB_IN        => ppu_rgb,
					HSYNC_IN      => ppu_hsync_p,
					VSYNC_IN      => ppu_vsync_p,
				
					RGB_OUT       => vga_rgb,
					HSYNC_OUT     => vga_hsync,
					VSYNC_OUT     => vga_vsync,

					--  NOTE CLOCKS MUST BE PHASE LOCKED !!
					CLK           => clk_10M,
					CLK_X2        => clk_21M
				);

			red <= vga_rgb(17 downto 12) & "0000";
			green <= vga_rgb(11 downto 6) & "0000";
			blue <= vga_rgb(5 downto 0) & "0000";
			hsync <= not vga_hsync;
			vsync <= not vga_vsync;

		end block BLK_SCANDBL;
	
	end generate GEN_VGA;

	-- SOUND
	
	SND_BLK : block
		signal count : std_logic_vector(1 downto 0);
	begin
		process (clk_21M, reset)
		begin
			if reset = '1' then
				count <= (others => '0');
			elsif rising_edge(clk_21M) then
				count <= count + 1;
			end if;
		end process;
		snd_data_l <= snd1;
		snd_data_r <= snd2;
		-- approx 5MHz
		snd_clk <= count(1);
	end block SND_BLK;
	
	-- UNUSED
	
	vga_clk <= clk_21M;
	lcm_data <= (others => '0');
	hblank <= '0';
	vblank <= '0';
	bw_cvbs <= (others => '0');
	gs_cvbs <= (others => '0');
	ser_tx <= '0';
  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';
  
	leds <= (others => '0');
	sram_o.a <= (others => '0');
	sram_o.d <= (others => '0');
	sram_o.be <= (others => '0');
	sram_o.cs <= '0';
	sram_o.oe <= '0';
	sram_o.we <= '0';
	  
end SYN;

--configuration cfg_PACE of PACE is
--	for SYN
--		for nes_cart_inst : nes_cart
--			use entity work.nes_cart(TENNIS);
--		end for;
--	end for;
--end configuration cfg_PACE;
