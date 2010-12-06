library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- the OCIDE controller uses UNSIGNED from here
use ieee.std_logic_arith.unsigned;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity custom_io is
  port
  (
    -- GPIO 0 connector
    gpio_0_i          : in std_logic_vector(35 downto 0);
    gpio_0_o          : out std_logic_vector(35 downto 0);
    gpio_0_oe         : out std_logic_vector(35 downto 0);
    gpio_0_is_custom  : out std_logic_vector(35 downto 0);
    
    -- GPIO 1 connector
    gpio_1_i          : in std_logic_vector(35 downto 0);
    gpio_1_o          : out std_logic_vector(35 downto 0);
    gpio_1_oe         : out std_logic_vector(35 downto 0);
    gpio_1_is_custom  : out std_logic_vector(35 downto 0);

    -- 7-segment display
    seg7              : out std_logic_vector(15 downto 0);

    -- SD card
		sd_dat            : inout std_logic;
		sd_dat3           : inout std_logic;
		sd_cmd            : inout std_logic;
		sd_clk            : out std_logic;

    project_i         : out from_PROJECT_IO_t;
    project_o         : in to_PROJECT_IO_t;
    platform_i        : out from_PLATFORM_IO_t;
    platform_o        : in to_PLATFORM_IO_t;
    target_i          : out from_TARGET_IO_t;
    target_o          : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

  -- use an alias so we can easily switch connectors
  alias gpio_i              : std_logic_vector(35 downto 0) is gpio_1_i;
  alias gpio_o              : std_logic_vector(35 downto 0) is gpio_1_o;
  alias gpio_oe             : std_logic_vector(35 downto 0) is gpio_1_oe;
  alias gpio_is_custom      : std_logic_vector(35 downto 0) is gpio_1_is_custom;
  alias gpio_is_not_used    : std_logic_vector(35 downto 0) is gpio_0_is_custom;

  -- 6809 interface

  type state_type is (idle, rd0, rd1, wr);
  signal state            : state_type;
  signal next_state       : state_type;

  -- IO bus signals
	signal io_wr					  : std_logic;
	signal io_di					  : std_logic_vector(23 downto 0);
	signal io_do					  : std_logic_vector(23 downto 0);
	--signal io_oe			      : std_logic;

  signal m6809e_oe_reset  : std_logic;
  signal m6809e_oe_d      : std_logic;
  signal cpu_6809_r_wn    : std_logic;
  
  signal clk_CPLD_ena     : std_logic;

begin

  GEN_REAL_6809 : if COCO1_USE_REAL_6809 generate

    process (platform_o.clk_cpld, platform_o.arst)
    begin
      if platform_o.arst = '1' then
        clk_CPLD_ena <= '0';
      elsif rising_edge(platform_o.clk_cpld) then
        clk_CPLD_ena <= not clk_CPLD_ena;
      end if;
    end process;
    --clk_CPLD_ena <= platform_o.clk_50M;
    
    m6809e_oe_d <= '0' when platform_o.arst = '1' else cpu_6809_r_wn;
    m6809e_oe_reset <= not platform_o.cpu_6809_rst_n;
    
    -- Assign signals to IO bus
    io_di <= gpio_i(23 downto 0);
    gpio_o(23 downto 0) <= io_do;
    gpio_o(28) <= clk_CPLD_ena;               gpio_oe(28) <= '1';
    gpio_o(29) <= platform_o.cpu_6809_q;      gpio_oe(29) <= '1';
    gpio_o(30) <= platform_o.arst;            gpio_oe(30) <= '1';
    gpio_o(31) <= platform_o.cpu_6809_e;      gpio_oe(31) <= '1';

    io_do <= "000000000" & 
              platform_o.cpu_6809_firq_n & platform_o.cpu_6809_irq_n & platform_o.cpu_6809_nmi_n & 
              platform_o.cpu_6809_tsc & 
              platform_o.cpu_6809_halt_n & 
              m6809e_oe_reset & m6809e_oe_d &
              platform_o.cpu_6809_d_i;

    gpio_oe(23 downto 0) <= (others => '1') when state = wr else (others => '0');
    
    io_wr <= '0';

    -- State machine
    io_sm : process(state, io_wr)
    begin
      case state is
      when idle =>  next_state <= rd0;
      when wr 	=>	if io_wr = '1' then next_state <= wr; else next_state <= rd0; end if;
      when rd0	=>	if io_wr = '1' then next_state <= wr; else next_state <= rd1; end if;
      when rd1	=>	if io_wr = '1' then next_state <= wr; else next_state <= wr; end if;
      end case;
    end process;

    -- Registers
    reg : process(platform_o.clk_cpld, clk_CPLD_ena, platform_o.arst)
    begin
      if platform_o.arst = '1' then
        state					              <= idle;
        platform_i.cpu_6809_d_o     <= (others => '0');
        platform_i.cpu_6809_a       <= (others => '0');
        cpu_6809_r_wn               <= '0';
        --m6809e_ba     <= '0';
        --m6809e_bs     <= '0';
        platform_i.cpu_6809_busy    <= '0';
        platform_i.cpu_6809_lic     <= '0';
        platform_i.cpu_6809_vma     <= '0';

      --elsif rising_edge(platform_o.clk_50M) then
      elsif rising_edge(clk_CPLD_ena) then
        --if clk_CPLD_ena = '1' then
          state <= next_state;

          if state = rd0 then
            cpu_6809_r_wn             <= io_di(21);
            --m6809e_ba     <= io_di(20);
            --m6809e_bs     <= io_di(19);
            platform_i.cpu_6809_busy  <= io_di(18);
            platform_i.cpu_6809_lic   <= io_di(17);
            platform_i.cpu_6809_vma   <= io_di(16);
            platform_i.cpu_6809_a     <= io_di(15 downto 0);
            -- show the PC on the 7-segment display
            seg7(15 downto 0) <= io_di(15 downto 0);
          end if;

          if state = rd1 then
            cpu_6809_r_wn             <= io_di(21);
            --m6809e_ba     <= io_di(20);
            --m6809e_bs     <= io_di(19);
            platform_i.cpu_6809_busy  <= io_di(18);
            platform_i.cpu_6809_lic   <= io_di(17);
            platform_i.cpu_6809_vma   <= io_di(16);
            platform_i.cpu_6809_d_o   <= io_di(7 downto 0);
          end if;
        --end if;
      end if;
    end process;

    -- assign output
    platform_i.cpu_6809_r_wn  <= cpu_6809_r_wn;

    gpio_is_custom <= (others => '1');
    
  end generate GEN_REAL_6809;

  GEN_CPU09 : if not COCO1_USE_REAL_6809 generate
  
    seg7(15 downto 0) <= platform_o.seg7(15 downto 0);
    gpio_is_custom <= (others => '0');
    
  end generate GEN_CPU09;
  
  gpio_is_not_used <= (others => '0');


  --
  -- IDE Interface
  --

  GEN_IDE : if COCO1_HAS_IDE generate

    signal iordy0_cf        : std_logic;
    signal rdy_irq_cf       : std_logic;
    signal cd_cf            : std_logic;
    signal a_cf             : std_logic_vector(2 downto 0);
    signal nce_cf           : std_logic_vector(2 downto 1);
    signal d_cf             : std_logic_vector(15 downto 0);
    signal nior0_cf         : std_logic;
    signal niow0_cf         : std_logic;
    signal non_cf           : std_logic;
    signal nreset_cf        : std_logic;

    signal wb_sel           : std_logic_vector(3 downto 0) := (others => '0');
    
    signal dd_i             : std_logic_vector(15 downto 0) := (others => '0');
    signal dd_o             : std_logic_vector(15 downto 0) := (others => '0');
    signal dd_oe            : std_logic := '0';
    signal a_cf_us          : ieee.std_logic_arith.unsigned(2 downto 0) := (others => '0');
  
    signal clk_25M          : std_logic := '0';
  
    signal sd_dat_i         : std_logic_vector(3 downto 0) := (others => '0');
    signal sd_dat_o         : std_logic_vector(3 downto 0);
    signal sd_dat_oe        : std_logic;
    signal sd_cmd_i         : std_logic := '0';
    signal sd_cmd_o         : std_logic;
    signal sd_cmd_oe        : std_logic;
    
  begin

    -- 16-bit access to PIO registers, otherwise 32
    wb_sel <= "0011" when platform_o.wb_adr(6) = '1' else "1111";
    
    atahost_inst : entity work.atahost_top
      generic map
      (
        --TWIDTH          => 5,
        -- PIO mode 0 settings
        -- - (100MHz = 6, 28, 2, 23)
        -- - (57M272 = 4, 16, 1, 13)
        PIO_mode0_T1    => 4,     -- 70ns
        PIO_mode0_T2    => 16,    -- 290ns
        PIO_mode0_T4    => 1,     -- 30ns
        PIO_mode0_Teoc  => 13     -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
      )
      port map
      (
        -- WISHBONE SYSCON signals
        wb_clk_i      => platform_o.wb_clk,
        arst_i        => platform_o.wb_arst_n,
        wb_rst_i      => platform_o.wb_rst,
  
        -- WISHBONE SLAVE signals
        wb_cyc_i      => platform_o.wb_cyc_stb,
        wb_stb_i      => platform_o.wb_cyc_stb,
        wb_ack_o      => platform_i.wb_ack,
        wb_err_o      => open,
        wb_adr_i      => ieee.std_logic_arith.unsigned(platform_o.wb_adr),
        wb_dat_i      => platform_o.wb_dat,
        wb_dat_o      => platform_i.wb_dat,
        wb_sel_i      => wb_sel,
        wb_we_i       => platform_o.wb_we,
        wb_inta_o     => platform_i.wb_inta,
  
        -- ATA signals
        resetn_pad_o  => nreset_cf,
        dd_pad_i      => dd_i,
        dd_pad_o      => dd_o,
        dd_padoe_o    => dd_oe,
        da_pad_o      => a_cf_us,
        cs0n_pad_o    => nce_cf(1),
        cs1n_pad_o    => nce_cf(2),
  
        diorn_pad_o	  => nior0_cf,
        diown_pad_o	  => niow0_cf,
        iordy_pad_i	  => iordy0_cf,
        intrq_pad_i	  => rdy_irq_cf
      );
  
    a_cf <= std_logic_vector(a_cf_us);
    
    -- power
    non_cf <= '0';

    sd_pll_inst : entity work.sd_pll
      port map
      (
        inclk0		  => platform_o.clk_50M,
        c0		      => open,      -- 50MHz
        c1		      => clk_25M,
        locked		  => open
      );

    sd_if : entity work.ide_sd
      generic map
      (
        ID_INIT_FILE      => "../../../../src/platform/coco1/roms/identifydevice.hex"
      )
      port map
      (
        -- clocking, reset
        clk               => platform_o.wb_clk,
        clk_ena           => '1',
        rst               => platform_o.wb_rst,
        
        -- IDE interface
        iordy0_cf         => iordy0_cf,
        rdy_irq_cf        => rdy_irq_cf,
        cd_cf             => open,
        a_cf              => a_cf,
        nce_cf            => nce_cf,
        d_i               => dd_i,
        d_o               => dd_o,
        d_oe              => dd_oe,
        nior0_cf          => nior0_cf,
        niow0_cf          => niow0_cf,
        non_cf            => non_cf,
        nreset_cf         => nreset_cf,
        ndmack_cf         => '0',
        dmarq_cf          => open,
        
        -- SD/MMC interface
        clk_25M           => clk_25M,
        sd_dat_i          => sd_dat_i,
        sd_dat_o          => sd_dat_o,
        sd_dat_oe         => sd_dat_oe,
        sd_cmd_i          => sd_cmd_i,
        sd_cmd_o          => sd_cmd_o,
        sd_cmd_oe         => sd_cmd_oe,
        sd_clk            => sd_clk
      );

    -- SD/MMC drivers
    sd_dat_i(0) <= sd_dat;
    sd_dat <= sd_dat_o(0) when sd_dat_oe = '1' else 'Z';
    sd_dat_i(3) <= sd_dat3;
    --sd_dat3 <= sd_dat_o(3) when sd_dat_oe = '1' else 'Z';
    sd_dat3 <= '1';
    sd_cmd_i <= sd_cmd;
    sd_cmd <= sd_cmd_o when sd_cmd_oe = '1' else 'Z';
    
  end generate GEN_IDE; 

end architecture SYN;
