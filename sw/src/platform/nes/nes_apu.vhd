library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity nes_apu is
	generic
	(
		ENABLE_SOUND	: boolean := true
	);
	port
	(
		Res_n         : in  std_logic;
		Enable        : in  std_logic;
		Clk           : in  std_logic;
		IRQ_n         : in  std_logic;
		NMI_n         : in  std_logic;
		R_W_n         : out std_logic;
		A             : out std_logic_vector(23 downto 0);
		DI            : in  std_logic_vector(7 downto 0);
		DO            : out std_logic_vector(7 downto 0);
		
		joypad_rst		: out std_logic;
		joypad_rd			: out std_logic_vector(1 to 2);
		joypad_d_i		: in std_logic_vector(1 to 2);
						
		snd1		      : out std_logic_vector(15 downto 0);
		snd2		      : out std_logic_vector(15 downto 0)
	);
end nes_apu;

architecture SYN of nes_apu is

	signal Res					: std_logic := '0';
	signal clk3M58_en		: std_logic := '0';

	signal cpu_a_ext		: std_logic_vector(23 downto 0) := (others => '0');
	alias cpu_a : std_logic_vector(15 downto 0) is cpu_a_ext(15 downto 0);
  signal cpu_d_i      : std_logic_vector(7 downto 0) := (others => '0');
  signal cpu_d_o      : std_logic_vector(7 downto 0) := (others => '0');
  signal cpu_rw_n     : std_logic := '0';
  signal cpu_rdy      : std_logic := '0';

	signal dma_cs				: std_logic := '0';
	signal dma_wr				: std_logic := '0';
	signal dma_a				: std_logic_vector(15 downto 0) := (others => '0');
	signal dma_d				: std_logic_vector(7 downto 0);
	signal dma_in_progress		: std_logic := '0';
	signal dma_ppu_rw_n : std_logic := '0';

	signal joy_cs				: std_logic := '0';
	signal joy_wr				: std_logic := '0';
	signal joy_data			: std_logic_vector(7 downto 0) := (others => '0');
	
	signal snd_d			  : std_logic_vector(7 downto 0) := (others => '0');
  signal snd_cs       : std_logic := '0';
	signal snd_rd				: std_logic := '0';
	signal snd_wr				: std_logic := '0';

begin

	Res <= not Res_n;
	cpu_rdy <= not dma_in_progress;

	-- internal 2x 1.79MHz to produce 3.58MHz (in phase)
	process (Clk, Enable, Res_n)
		variable count : integer range 0 to 12;
	begin
		if Res_n = '0' then
			count := 0;
			clk3M58_en <= '0';
		elsif rising_edge(Clk) then
      clk3M58_en <= '0'; -- default
			if Enable = '1' then
				count := 0;
			else
        if count = 4 or count = 10 then
				  clk3M58_en <= '1';
        end if;
				count := count + 1;
			end if;
		end if;
	end process;
	
  -- $4000-$4017
  -- - currently there is an overlap - will this produce any side-effects???
	snd_cs <=	'1' when cpu_a(15 downto 5) = X"40"&"000" and (cpu_a(4) = '0' or cpu_a(3) = '0') else '0';
  snd_rd <= snd_cs and cpu_rw_n;
  snd_wr <= snd_cs and not cpu_rw_n;

  -- SPRITE DMA $4014
	dma_cs <= '1' when cpu_a = X"4014" else '0';
	dma_wr <= dma_cs and not cpu_rw_n;

	-- JOYPAD ports $4016,$4017
	joy_cs <= '1' when cpu_a(15 downto 1) = X"401"&"011" else '0';
  joy_wr <= joy_cs and not cpu_rw_n;

  -- CPU/APU bus arbitration
  A <= (X"00" & dma_a) when dma_in_progress = '1' else cpu_a_ext;
  cpu_d_i <=  joy_data when joy_cs = '1' else
              snd_d when snd_cs = '1' else 
              DI;
  DO <= dma_d when dma_in_progress = '1' else cpu_d_o;
  R_W_n <= dma_ppu_rw_n when dma_in_progress = '1' else cpu_rw_n;

	-- (sprite) DMA
	process (Clk, Enable, Res_n)
		variable state		  : std_logic := '0';
    variable dma_wram_a : std_logic_vector(15 downto 0) := (others => '0');
	  alias dma_count			: std_logic_vector(7 downto 0) is dma_wram_a(7 downto 0);	
	begin
		if Res_n = '0' then
			dma_in_progress <= '0';
			state := '0';
		elsif rising_edge(Clk) then
			if Enable = '1' then
				-- defaults
				dma_ppu_rw_n <= '1';
				if dma_in_progress = '0' then
					if dma_wr = '1' then
						dma_wram_a(15 downto 8) := cpu_d_o;
						dma_count := (others => '0');
						-- start the DMA
						dma_in_progress <= '1';
						state := '0';
					end if; -- dma_wr = '1'
				else
					if state = '0' then
						-- fetch from cpu RAM
            dma_a <= dma_wram_a;
						dma_d <= DI;
					else
						-- write to ppu
            dma_a <= X"2004";
						dma_ppu_rw_n <= '0';
						if dma_count = X"FF" then
							dma_in_progress <= '0';
						else
							dma_count := dma_count + 1;
						end if;
					end if;
					state := not state;
				end if; -- dip
			end if; -- clk_1M77_en = '1'
		end if; -- rising_edge(clk)
	end process;

	-- controller inputs
	process (Clk, Enable, Res_n)
		variable joy_rst_v 	: std_logic := '0';
	begin
		if Res_n = '0' then
			joy_rst_v := '0';
			joypad_rd <= (others => '0');
		elsif rising_edge(clk) then
			if Enable = '1' then
				joypad_rd <= (others => '0'); -- default
				if joy_cs = '1' then
					if joy_wr = '0' then
						if joy_rst_v = '0' then
							if cpu_a(0) = '0' then
								joypad_rd(1) <= '1';
							else
								joypad_rd(2) <= '1';
							end if;
						end if;
					else
						if cpu_a(0) = '0' then
							joy_rst_v := cpu_d_o(0);
						end if;
					end if; -- write to joy port
				end if; -- joy_cs = '1'
			end if; -- clk_1M77_en = '1'
		end if;
		-- drive port data
		joypad_rst <= joy_rst_v;
		joy_data(7 downto 1) <= "0001000";
	end process;
	joy_data(0) <= joypad_d_i(1) when cpu_a(0) = '0' else joypad_d_i(2);
	
	cpu_inst : entity work.T65
		port map
		(
			Mode    		=> "00",	-- 6502
			Res_n   		=> Res_n,
			Enable  		=> Enable,
			Clk     		=> Clk,
			Rdy     		=> cpu_rdy,
			Abort_n 		=> '1',
			IRQ_n   		=> IRQ_n,
			NMI_n   		=> NMI_n,
			SO_n    		=> '1',
			R_W_n   		=> cpu_rw_n,
			Sync    		=> open,
			EF      		=> open,
			MF      		=> open,
			XF      		=> open,
			ML_n    		=> open,
			VP_n    		=> open,
			VDA     		=> open,
			VPA     		=> open,
			A       		=> cpu_a_ext,
			DI      		=> cpu_d_i,
			DO      		=> cpu_d_o
		);

  GEN_SND : if ENABLE_SOUND generate
		
  	snd_inst : entity work.nes_snd
  		port map
  		(
  			clk         	=> Clk,
  			reset       	=> Res,
  			clk358_en   	=> clk3M58_en,
  			clk179_en			=> Enable,
  			
  			-- CPU I/F
  			a							=> cpu_a(4 downto 0),
  			d_in					=> cpu_d_o,
  			d_out					=> snd_d,
  			rd						=> snd_rd,
  			wr						=> snd_wr,
  			irq						=> open,
  
  			-- Sound data
  			snd1					=> snd1,
  			snd2					=> snd2
  		) ;

  end generate GEN_SND;

  GEN_NO_SND : if not ENABLE_SOUND generate

    snd_d <= (others => '0');
    snd1 <= (others => '0');
    snd2 <= (others => '0');

  end generate GEN_NO_SND;
	
end SYN;