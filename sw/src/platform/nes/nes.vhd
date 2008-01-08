library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.STD_MATCH;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity nes is
  generic
  (
    NTSC              : boolean := true;
		ENABLE_SOUND			: boolean := true
  );
  port
  (
    clk         	: in std_logic;
    clk_21M_en  	: in std_logic;
    reset       	: in std_logic;

    prg_a       	: out std_logic_vector(14 downto 0);
    prg_d_i     	: in std_logic_vector(7 downto 0);
    prg_d_o     	: out std_logic_vector(7 downto 0);
    prg_d_oe    	: out std_logic;
		prg_rom_ce_n	: out std_logic;
		prg_rw_n			: out std_logic;

    chr_a       	: out std_logic_vector(13 downto 0);
    chr_d_i     	: in std_logic_vector(7 downto 0);
    chr_d_o     	: out std_logic_vector(7 downto 0);
    chr_d_oe    	:	out std_logic;
		chr_ram_rd_n	: out std_logic;
		chr_ram_wr_n	: out std_logic;
		
		vram_ce_n			: in std_logic;
		chr_a13_n			: out std_logic;

		-- IRQ (open-collector)
		irq_i_n				: in std_logic;
		irq_oe				: out std_logic;

		joypad_rst		: out std_logic;
		joypad_rd			: out std_logic_vector(1 to 2);
		joypad_d_i		: in std_logic_vector(1 to 2);
						
    r           	: out std_logic_vector(5 downto 0);
    g           	: out std_logic_vector(5 downto 0);
    b           	: out std_logic_vector(5 downto 0);
    hsync       	: out std_logic;
    vsync       	: out std_logic;

		snd1					: out std_logic_vector(15 downto 0);
		snd2					: out std_logic_vector(15 downto 0)
  );
end nes;

architecture SYN of nes is

	signal reset_n						: std_logic := '0';
	signal machine_reset_n		: std_logic := '0';

	signal clk_1M77_en				: std_logic := '0';

  signal chr_a_s            : std_logic_vector(chr_a'range);
	
	signal cpu_rdy						: std_logic := '1';
	signal cpu_irq_n					: std_logic := '1';
	signal cpu_nmi_n					: std_logic := '1';
	signal cpu_rw_n						: std_logic := '1';
	signal cpu_a_ext					: std_logic_vector(23 downto 0) := (others => '0');
	alias cpu_a								: std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
	signal cpu_d_i						: std_logic_vector(7 downto 0) := (others => '0');
	signal cpu_d_o						: std_logic_vector(7 downto 0) := (others => '0');

	signal wram_cs						: std_logic := '0';
	signal wram_wr						: std_logic := '0';
	signal wram_a							: std_logic_vector(10 downto 0) := (others => '0');
	signal wram_d_i						: std_logic_vector(7 downto 0) := (others => '0');
	
	signal ppu_cs							: std_logic := '0';
	signal ppu_d_i					  : std_logic_vector(7 downto 0) := (others => '0');
	signal ppu_vbl						: std_logic := '0';
	
	signal dmc_cs							: std_logic := '0';
	
	signal prg_cs							: std_logic := '0';
					
begin

	reset_n <= not reset;
	machine_reset_n <= not reset; -- to be changed
	
	cpu_irq_n <= '1';
	cpu_nmi_n <= not ppu_vbl;

	--
	-- address decoding
	--

	-- WRAM $0000-$1FFF (mirrored 4 times)
	wram_cs <= 		'1' when STD_MATCH(cpu_a, "000-------------") else '0';
	-- PPU registers $2000-$3FFF (mirrored)
	ppu_cs <=     '1' when STD_MATCH(cpu_a, "001-------------") else '0';
	-- DMC registers $4010-$4015
	-- don't worry about overlap with DMA yet...
	dmc_cs <=			'1' when STD_MATCH(cpu_a,    X"401" & "0---") else '0';
	-- ROM $8000-$BFFF & $C000-$FFFF
  prg_cs <= 		'1' when STD_MATCH(cpu_a, "11--------------") else 
								'1' when STD_MATCH(cpu_a, "10--------------") else 
								'0';

	--	
	-- data mux
	--
	cpu_d_i <=	wram_d_i when wram_cs = '1' else
							ppu_d_i when ppu_cs = '1' else
							-- DMC must come *after* JOY because of decode overlap
							--dmc_datao when dmc_cs = '1' else
							prg_d_i when prg_cs = '1' else
							(others => '0');

	--
	-- write-enables
	--
	wram_wr <= wram_cs and not cpu_rw_n;
	
	--
	-- PRG bus drivers
	--
	prg_a <= cpu_a_ext(prg_a'range);
	prg_d_o <= (others => '0');
	prg_d_oe <= '0';
	prg_rom_ce_n <= '0';
	prg_rw_n <= '1';
	
  chr_a <= chr_a_s;
	chr_a13_n <= not chr_a_s(13);
	chr_ram_rd_n <= '0';

	irq_oe <= '0';
		
	-- produce 1.77MHz clock from 21MHz (/12)
	process (clk, clk_21M_en, reset)
		subtype count_t is integer range 0 to 11;
		variable count : count_t := 0;
	begin
		if reset = '1' then
			clk_1M77_en <= '0';
			count := 0;
		elsif rising_edge(clk) and clk_21M_en = '1' then
			clk_1M77_en <= '0'; -- default
			if count = count_t'high then
				count := 0;
				clk_1M77_en <= '1';
			else
				count := count + 1;
			end if;
		end if;
	end process;

	apu_inst : entity work.nes_apu
		generic map
		(
			ENABLE_SOUND	=> ENABLE_SOUND
		)
		port map
		(
			Res_n   		=> machine_reset_n,
			Enable  		=> clk_1M77_en,
			Clk     		=> clk,
			IRQ_n   		=> cpu_irq_n,
			NMI_n   		=> cpu_nmi_n,
			R_W_n   		=> cpu_rw_n,
			A       		=> cpu_a_ext,
			DI      		=> cpu_d_i,
			DO      		=> cpu_d_o,

		  joypad_rst	=> joypad_rst,
		  joypad_rd		=> joypad_rd,
		  joypad_d_i	=> joypad_d_i,
		
			snd1				=> snd1,
			snd2				=> snd2
		);

	ppu_inst : entity work.nes_ppu
		generic map
		(
			NTSC				=> NTSC
		)
	  port map
	  (
	    clk         => clk,
	    clk_21M_en  => clk_21M_en,
	    reset       => reset,

			-- cpu interface
      cpu_clken   => clk_1M77_en,
			cpu_a				=> cpu_a(2 downto 0),
			cpu_d_i			=> cpu_d_o,
			cpu_d_o			=> ppu_d_i,
			cpu_cs			=> ppu_cs,
			cpu_rw_n		=> cpu_rw_n,
			vbl					=> ppu_vbl,
			
			-- CHR bus interface		
	    chr_a       => chr_a_s,
	    chr_d_i     => chr_d_i,
	    chr_d_o     => chr_d_o,
	    chr_d_oe    => chr_d_oe,
      ale         => open,
      rd_n        => open,
      wr_n        => open,

			-- composite video output
	    r           => r,
	    g           => g,
	    b           => b,
	    hsync       => hsync,
	    vsync       => vsync
	  );

	GEN_INTERNAL_WRAM : if NES_USE_INTERNAL_WRAM generate

		wram_inst : ENTITY work.nes_wram
			port map
			(
				clock			=> clk,
				address		=> cpu_a(10 downto 0),
				data			=> cpu_d_o,
				wren			=> wram_wr,
				q					=> wram_d_i
			);

	end generate GEN_INTERNAL_WRAM;
	
end SYN;
