library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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

begin

  gpio_0_is_custom <= (others => '0');
  gpio_1_is_custom <= (others => '0');

  seg7 <= X"dACE";

  GEN_BARTLETT_IDE : if TRS80_M1_HAS_HDD generate

    signal wb_clk       : std_logic := '0';
    signal wb_rst       : std_logic := '0';
    signal wb_arst_n    : std_logic := '0';
    signal wb_cyc_stb   : std_logic := '0';
    signal wb_sel       : std_logic_vector(3 downto 0) := (others => '0');
    signal wb_adr       : std_logic_vector(6 downto 2) := (others => '0');
    signal wb_dat_i     : std_logic_vector(31 downto 0) := (others => '0');
    signal wb_dat_o     : std_logic_vector(31 downto 0) := (others => '0');
    signal wb_we        : std_logic := '0';
    signal wb_ack       : std_logic := '0';
    
    signal dd_i         : std_logic_vector(15 downto 0) := (others => '0');
    signal dd_o         : std_logic_vector(15 downto 0) := (others => '0');
    signal dd_oe        : std_logic := '0';
    signal a_cf_us      : ieee.std_logic_arith.unsigned(2 downto 0) := (others => '0');

    type state_t is ( S_IDLE, S_I1, S_R1, S_W1 );
    signal state : state_t := S_IDLE;

    signal ide_cs       : std_logic := '0';
    signal ide_d_r      : std_logic_vector(31 downto 0) := (others => '0');

    signal hdci_cntl    : std_logic_vector(7 downto 0) := (others => '0');
    alias hdci_enable   : std_logic is hdci_cntl(3);
    
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

    signal clk_25M          : std_logic := '0';
  
    signal sd_dat_i         : std_logic_vector(3 downto 0) := (others => '0');
    signal sd_dat_o         : std_logic_vector(3 downto 0);
    signal sd_dat_oe        : std_logic;
    signal sd_cmd_i         : std_logic := '0';
    signal sd_cmd_o         : std_logic;
    signal sd_cmd_oe        : std_logic;
    
  begin
  
    wb_clk <= platform_o.clk;
    wb_rst <= platform_o.rst;
    wb_arst_n <= platform_o.arst_n;

    platform_i.hdd_cs <= ide_cs;
    
    -- IDE registers
    --
    --  $C0-C2  - original RS registers
    --  $C3     - upper-byte data latch
    --  $C8-CF  - write-thru to IDE device
    --
    
    ide_cs <= (platform_o.cpu_io_rd or platform_o.cpu_io_wr) 
                when STD_MATCH(platform_o.cpu_a(7 downto 0), X"C"&"----") 
                else '0';
    
    process (platform_o.clk, platform_o.rst)
      variable cpu_io_r : std_logic := '0';
    begin
      if platform_o.rst = '1' then
        hdci_cntl <= (others => '0');
        wb_cyc_stb <= '0';
        wb_we <= '0';
        state <= S_I1;
      elsif rising_edge(platform_o.clk) then
        case state is
          when S_I1 =>
            -- initialise the OCIDE core
            wb_cyc_stb <= '1';
            wb_adr <= "00000";
            wb_dat_i <= X"00000082";   -- enable IDE, IORDY timing
            wb_we <= '1';
            state <= S_W1;
          when S_IDLE =>
            wb_cyc_stb <= '0'; -- default
            -- start a new cycle on rising_edge IORD
            if cpu_io_r = '0' and (platform_o.cpu_io_rd or platform_o.cpu_io_wr) = '1' then
              if ide_cs = '1' then
                case platform_o.cpu_a(3 downto 0) is
                  when X"0" =>    -- hdci_wp
                  when X"1" =>    -- hdci_cntl
                    hdci_cntl <= platform_o.cpu_d_o;
                  when X"2" =>    -- hdci_present
                  when X"3" =>    -- high-byte latch
                    if platform_o.cpu_io_rd = '1' then
                      -- read latch from previous access
                      platform_i.hdd_d <= ide_d_r(15 downto 8);
                    elsif platform_o.cpu_io_wr = '1' then
                      -- latch write data for subsequent access
                      ide_d_r(15 downto 8) <= platform_o.cpu_d_o;
                    end if;
                  when others =>
                    -- IDE device registers @$08-$0F
                    if platform_o.cpu_a(3) = '1' then
                      -- start a new access to the OCIDEC
                      wb_cyc_stb <= ide_cs;
                      -- $08-$0F => $10-$17 (ATA registers)
                      wb_adr <= "10" & platform_o.cpu_a(2 downto 0);
                      wb_dat_i(31 downto 8) <= X"0000" & ide_d_r(15 downto 8);
                      -- Peter Bartlett's drivers require this
                      -- because IDE sectors start at 1, not 0
                      if platform_o.cpu_a(3 downto 0) = X"B" then
                        wb_dat_i(7 downto 0) <= std_logic_vector(unsigned(platform_o.cpu_d_o) + 1);
                      else
                        wb_dat_i(7 downto 0) <= platform_o.cpu_d_o;
                      end if;
                      wb_we <= platform_o.cpu_io_wr;
                      if platform_o.cpu_io_rd = '1' then
                        state <= S_R1;
                      else
                        state <= S_W1;
                      end if;
                    end if; -- $08-$0F (device register)
                end case;
              end if; -- ide_cs = '1'
            end if;
          when S_R1 =>
            if wb_ack = '1' then
              -- latch the whole data bus from the core
              ide_d_r <= wb_dat_o;
              -- Peter Bartlett's drivers require this
              -- because IDE sectors start at 1, not 0
              if platform_o.cpu_a(3 downto 0) = X"B" then
                platform_i.hdd_d <= std_logic_vector(unsigned(wb_dat_o(platform_i.hdd_d'range)) - 1);
              else
                platform_i.hdd_d <= wb_dat_o(platform_i.hdd_d'range);
              end if;
              wb_cyc_stb <= '0';
              state <= S_IDLE;
            end if;
          when S_W1 =>
            if wb_ack = '1' then
              wb_cyc_stb <= '0';
              state <= S_IDLE;
            end if;
          when others =>
            wb_cyc_stb <= '0';
            state <= S_IDLE;
        end case;
        cpu_io_r := platform_o.cpu_io_rd or platform_o.cpu_io_wr;
      end if;
    end process;
      
    -- 16-bit access to PIO registers, otherwise 32
    wb_sel <= "0011" when wb_adr(6) = '1' else "1111";
    
    -- PIO mode timings
    --          0,   1,   2,   3,   4,   5,   6
    -- t1   -  70,  50,  30,  30,  25,  15,  10
    -- t2   - 165, 125, 100,  80,  70,  65,  55
    -- t4   -  30,  20,  15,  10,  10,   5,   5
    -- teoc - 365, 208, 110,  70,  25,  25,  20
    --
    -- n = max(0, round_up((t * clk) - 2))
    --
    atahost_inst : entity work.atahost_top
      generic map
      (
        --TWIDTH          => 5,
        -- PIO mode0 100MHz = 6, 28, 2, 23
        -- PIO mode0 57M272 = 4, 16, 1, 13
        -- PIO mode0 40MHz => 1, 5, 0, 13
        -- PIO mode3 40MHz => 0, 2, 0, 1
        PIO_mode0_T1    => 1,
        PIO_mode0_T2    => 5,
        PIO_mode0_T4    => 0,
        PIO_mode0_Teoc  => 13
      )
      port map
      (
        -- WISHBONE SYSCON signals
        wb_clk_i      => wb_clk,
        arst_i        => wb_arst_n,
        wb_rst_i      => wb_rst,

        -- WISHBONE SLAVE signals
        wb_cyc_i      => wb_cyc_stb,
        wb_stb_i      => wb_cyc_stb,
        wb_ack_o      => wb_ack,
        wb_err_o      => open,
        wb_adr_i      => ieee.std_logic_arith.unsigned(wb_adr),
        wb_dat_i      => wb_dat_i,
        wb_dat_o      => wb_dat_o,
        wb_sel_i      => wb_sel,
        wb_we_i       => wb_we,
        wb_inta_o     => open,

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
    
--    sd_pll_inst : entity work.sd_pll
--      port map
--      (
--        inclk0		  => platform_o.clk_50M,
--        c0		      => open,      -- 50MHz
--        c1		      => clk_25M,
--        locked		  => open
--      );

    clk_25M <= platform_o.clk_25M;
    
    sd_if : entity work.ide_sd
      generic map
      (
        LBA_MODE          => false,
        HEAD_BITS         => 3,         -- 8 heads
        SECTOR_BITS       => 5,         -- 32 sectors
        ID_INIT_FILE      => "../../../../../src/platform/coco1/roms/identifydevice.hex"
      )
      port map
      (
        -- clocking, reset
        clk               => wb_clk,
        clk_ena           => '1',
        rst               => wb_rst,
        
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
    
  end generate GEN_BARTLETT_IDE; 

end architecture SYN;
