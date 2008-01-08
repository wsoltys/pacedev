library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity sound is port
 (
   sysclk            : in    std_logic;
   reset             : in    std_logic;

   sndif_rd          : in    std_logic;
   sndif_wr          : in    std_logic;
   sndif_datai       : in    std_logic_vector(7 downto 0);
   sndif_addr        : in    std_logic_vector(15 downto 0);

   snd_clk           : out   std_logic;
   snd_data          : out   std_logic_vector(7 downto 0);
   sndif_datao       : out   std_logic_vector(7 downto 0)
 );
end sound;

architecture SYN of sound is

-- Component Declarations

-- Signal Declarations

  signal rom_a      : std_logic_vector(7 downto 0);
  signal rom_d      : std_logic_vector(7 downto 0);
  signal snd_pulse  : std_logic;
  signal snd_clock  : std_logic;

begin

  process (sysclk, reset)
    variable count : integer;
		variable clk_count : std_logic_vector(2 downto 0);
  begin
    if reset = '1' then
			count := 0;
			clk_count := (others => '0');
    elsif rising_edge(sysclk) then
      snd_pulse <= '0';
      if count = 0 then
        snd_pulse <= '1';
	      count := 312;		-- 96KHz at 30MHz
				--count := 520;		-- 96KHz at 50MHz
      end if;
      count := count - 1;
			-- arbitrary clock, as long as it's in range of the DAC
			clk_count := clk_count + 1;
    end if;
		-- assign outputs
		snd_clk <= clk_count(2);
  end process;

  pacsnd_inst : entity work.pacSnd
    port map
    (
      -- Pacman sound controller
      clk             => sysclk,
      reset           => reset,
      snd_pulse       => snd_pulse,

      -- CPU I/F
      cpu_a           => sndif_addr(4 downto 0),
      cpu_d_in        => sndif_datai(3 downto 0),
      cpu_d_out       => sndif_datao(3 downto 0),
      cpu_rd          => sndif_rd,
      cpu_wr          => sndif_wr,

      -- ROM I/F
      rom_a           => rom_a,
      rom_d           => rom_d(3 downto 0),
      rom_rd          => open,

      -- Sound output
      sound_out       => snd_data,
  
      testvoc1Out     => open,
      testvoc2Out     => open,
      testvoc3Out     => open
    );
  sndif_datao(sndif_datao'left downto 4) <= (others => '0');

	-- can't (currently) fit sound rom into nanoboard NB1
	GEN_SOUND_ROM : if PACE_TARGET /= PACE_TARGET_NANOBOARD_NB1 generate
	
	  snd_rom_inst : entity work.snd_rom
	    port map
	    (
				clock			=> sysclk,
				address		=> rom_a,
				q					=> rom_d
	    );

	end generate GEN_SOUND_ROM;
	
end SYN;
