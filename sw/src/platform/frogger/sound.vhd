library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.STD_MATCH;

library work;
use work.project_pkg.all;

entity Sound is 
  generic
  (
    CLK_MHz : natural := 5
  );
	port
   (
     sysClk            : in    std_logic;
     reset             : in    std_logic;

     sndif_rd          : in    std_logic;
     sndif_wr          : in    std_logic;
     sndif_datai       : in    std_logic_vector(7 downto 0);
     sndif_addr        : in    std_logic_vector(15 downto 0);

     snd_clk           : out   std_logic;
     snd_data          : out   std_logic_vector(7 downto 0);
     sndif_datao       : out   std_logic_vector(7 downto 0)
   );
end Sound;

architecture SYN of Sound is

-- Signal Declarations

	alias clk_30M					: std_logic is sysClk;
  signal clk_1M76_en		: std_logic;

	signal up_addr				: std_logic_vector(15 downto 0);
  signal up_datai				: std_logic_vector(7 downto 0);
  signal up_datao				: std_logic_vector(7 downto 0);

  signal up_memrd				: std_logic;
  signal up_memwr				: std_logic;
	signal up_iord				: std_logic;
	signal up_iowr				: std_logic;
  signal up_irq         : std_logic;
  signal up_intack      : std_logic;

	signal pia1_cs				: std_logic;
  signal pa_o           : std_logic_vector(7 downto 0);
  signal pb_o           : std_logic_vector(7 downto 0);

	signal rom0_cs				: std_logic;
	signal rom1_cs				: std_logic;
	signal ram_cs					: std_logic;
	signal filter_cs			: std_logic;
	signal ram_wr					: std_logic;
	signal filter_wr			: std_logic;
	
	signal sndrom0_data		: std_logic_vector(7 downto 0);
	signal sndrom1_data		: std_logic_vector(7 downto 0);
	signal sndram_data		: std_logic_vector(7 downto 0);

	signal ay8910_data		: std_logic_vector(7 downto 0);	
	signal ay8910_rd			: std_logic;
	signal ay8910_wr			: std_logic;
	signal ay8910_la			: std_logic;
	signal ay8910_bc1			: std_logic;
	signal ay8910_bc2			: std_logic;
	signal ay8910_bdir		: std_logic;

	signal snda_data			: std_logic_vector(7 downto 0);
	signal sndb_data			: std_logic_vector(7 downto 0);
	signal sndc_data			: std_logic_vector(7 downto 0);

	signal timer_data			: std_logic_vector(7 downto 0);
			
begin

  GEN_SOUND : if FROGGER_HAS_SOUND generate

    -- generate CPU clock (1.78975MHz from 30MHz)
    clk_en_inst : entity work.clk_div
      generic map
      (
        DIVISOR		=> 17
      )
      port map
      (
        clk				=> clk_30M,
        reset			=> reset,
        clk_en		=> clk_1M76_en
      );

    -- Chip-select logic
    -- ROM0 $0000-$1000
    rom0_cs <= 		'1' when STD_MATCH(up_addr, X"0"&   "------------") else '0';
    -- ROM1 $1000-$17FF, mirrored $1800-$1FFF
    rom1_cs <= 		'1' when STD_MATCH(up_addr, X"1"&   "------------") else '0';
    -- RAM $4000-$43FF
    ram_cs <= 		'1' when STD_MATCH(up_addr, X"4"&"00"&"----------") else '0';
    -- FILTER $6000 -$6FFF
    filter_cs <= 	'1' when STD_MATCH(up_addr, X"6"&   "------------") else '0';

    -- write controls
    ram_wr <= ram_cs and up_memwr;
    filter_wr <= filter_cs and up_memwr;

    -- read mux
    up_datai <= sndrom0_data when (rom0_cs and up_memrd) = '1' else
                sndrom1_data when (rom1_cs and up_memrd) = '1' else
                ay8910_data when ay8910_rd = '1' else
                sndram_data;

    -- I/O read/write logic
    -- AY8910 rd=$40, wr=$40, latch_addr=$80
    ay8910_rd <= up_iord when STD_MATCH(up_addr(7 downto 0), X"40") else '0';
    ay8910_wr <= up_iowr when STD_MATCH(up_addr(7 downto 0), X"40") else '0';
    ay8910_la <= up_iowr when STD_MATCH(up_addr(7 downto 0), X"80") else '0';

    -- AY8910 bus control signals
    ay8910_bdir <= ay8910_wr or ay8910_la;
    ay8910_bc2 <= '1';
    ay8910_bc1 <= ay8910_rd or ay8910_la;

    snd_clk <= clk_1M76_en;

    --
    --	COMPONENT INSTANTIATION
    --

    U_uP : entity work.Z80
      port map
      (
        clk 		=> clk_30M,                                   
        clk_en	=> clk_1M76_en,
        reset  	=> reset,                                     

        addr   	=> up_addr,
        datai  	=> up_datai,
        datao  	=> up_datao,

        mem_rd 	=> up_memrd,
        mem_wr 	=> up_memwr,
        io_rd  	=> up_iord,
        io_wr  	=> up_iowr,

        intreq 	=> up_irq,
        intvec 	=> (others => 'X'),
        intack 	=> up_intack,
        nmi    	=> '0'
      );

    sndrom0_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/frogger/roms/frogsnd0.hex",
        numwords_a	=> 4096,
        widthad_a		=> 12
      )
      port map
      (
        clock			=> clk_30M,
        address		=> up_addr(11 downto 0),
        q					=> sndrom0_data
      );

    sndrom1_inst : entity work.sprom
      generic map
      (
        init_file		=> "../../../../src/platform/frogger/roms/frogsnd1.hex",
        numwords_a	=> 2048,
        widthad_a		=> 11
      )
      port map
      (
        clock			=> clk_30M,
        address		=> up_addr(10 downto 0),
        q					=> sndrom1_data
      );

    sndram_inst : entity work.spram
      generic map
      (
        numwords_a	=> 1024,
        widthad_a		=> 10
      )
      port map
      (
        clock				=> clk_30M,
        address			=> up_addr(9 downto 0),
        wren				=> ram_wr,
        data				=> up_datao,
        q						=> sndram_data
      );

    ay38910_inst : entity work.ay_3_8910
      port map
      (
        -- AY-3-8910 sound controller
        clk         => clk_30M,
        reset       => reset,
        clk_en      => clk_1M76_en,

        -- CPU I/F
        cpu_d_in    => up_datao,
        cpu_d_out   => ay8910_data,
        cpu_bdir    => ay8910_bdir,
        cpu_bc1     => ay8910_bc1,
        cpu_bc2     => ay8910_bc2,

        -- I/O I/F
        io_a_in     => pa_o,
        io_b_in     => timer_data,
        io_a_out    => open,
        io_b_out    => open,

        -- Sound output
        snd_A       => snda_data,
        snd_B       => sndb_data,
        snd_C       => sndc_data
      );

    mixer_inst : entity work.mixer4
    port map
    (
        -- Sound inputs
        snd_A       => snda_data,
        snd_B       => sndb_data,
        snd_C       => sndc_data,
        snd_D       => (others => '0'),

        -- Sound output
        snd_out     => snd_data
    );

    timer_inst : entity work.froggerTimer
      port map
      (
        clk         => clk_1M76_en,
        reset       => reset,

        -- data
        datao       => timer_data
      );
      
    --
    --	The 8255 is accessed by the *MAIN GAME CPU*
    --	- not the sound CPU!
    --

    pia1_cs <= sndif_rd or sndif_wr;

    pia8255_1_inst : entity work.pia8255
      port map
      (
        -- uC interface
        clk			=> clk_30M,
        clken		=> '1',
        reset		=> reset,
        a				=> sndif_addr(2 downto 1),
        d_i			=> sndif_datai,
        d_o			=> sndif_datao,
        cs			=> pia1_cs,
        rd			=> sndif_rd,
        wr			=> sndif_wr,
        
        -- I/O interface
        pa_i		=> (others => '0'),
        pa_o		=> pa_o,			-- sound_latch_wr
        pb_i		=> (others => '0'),
        pb_o		=> pb_o,			-- scramble_sh_irqtrigger_w
        pc_i		=> (others => '0'),
        pc_o		=> open
      );

    -- Sound latch is a handshake between main and sound CPU
    -- - Main CPU writes to latch via PIA_PA
    -- - Sound CPU reads from latch via AY38910_PA
    -- * PIA_PA_O is connected directly to AY38910_PA_IN

    -- IRQn to the sound CPU is controlled from the main CPU via a 7474 FF
    -- - CLK = ~PIA_PB:3, PR=0, D=1, Qn=IRQn
    -- so, interrupt set by PB:3 1->0, cleared by INTACK
    -- - but we can make this synchronous
    process (clk_30M, reset, up_intack)
      variable q      : std_logic;
      variable pb3_r  : std_logic;
    begin
      if reset = '1' or up_intack = '1' then
        q := '0';
        pb3_r := '0';
      elsif rising_edge(clk_30M) then
        if pb3_r = '1' and pb_o(3) = '0' then
          q := '1';
        end if;
        pb3_r := pb_o(3);
      end if;
      -- assign interrupt (we have active high)
      up_irq <= q;
    end process;

  end generate GEN_SOUND;

  GEN_NO_SOUND : if not FROGGER_HAS_SOUND generate

  end generate GEN_NO_SOUND;
  
end SYN;
