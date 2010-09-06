library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
-- the OCIDE controller uses UNSIGNED from here
use ieee.std_logic_arith.unsigned;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity custom_io is
  port
  (
    -- compact flash
    iordy0_cf         : in std_logic;
    rdy_irq_cf        : in std_logic;
    cd_cf             : in std_logic;
    a_cf              : out std_logic_vector(2 downto 0);
    nce_cf            : out std_logic_vector(2 downto 1);
    d_cf              : inout std_logic_vector(15 downto 0);
    nior0_cf          : out std_logic;
    niow0_cf          : out std_logic;
    non_cf            : out std_logic;
    reset_cf          : out std_logic;
    ndmack_cf         : out std_logic;
    dmarq_cf          : in std_logic;
    
    project_i         : out from_PROJECT_IO_t;
    project_o         : in to_PROJECT_IO_t;
    platform_i        : out from_PLATFORM_IO_t;
    platform_o        : in to_PLATFORM_IO_t;
    target_i          : out from_TARGET_IO_t;
    target_o          : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

  signal dd_i     : std_logic_vector(15 downto 0) := (others => '0');
  signal dd_o     : std_logic_vector(15 downto 0) := (others => '0');
  signal dd_oe    : std_logic := '0';
  signal a_cf_us  : unsigned(2 downto 0) := (others => '0');
  
begin

  atahost_inst : entity work.atahost_top
    generic map
    (
      -- PIO mode 0 settings (@100MHz clock)
      PIO_mode0_T1    => 6,     -- 70ns
      PIO_mode0_T2    => 28,    -- 290ns
      PIO_mode0_T4    => 2,     -- 30ns
      PIO_mode0_Teoc  => 23     -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
    )
    port map
    (
      -- WISHBONE SYSCON signals
      wb_clk_i      => target_o.wb_clk,
      arst_i        => target_o.wb_arst_n,
      wb_rst_i      => target_o.wb_rst,

      -- WISHBONE SLAVE signals
      wb_cyc_i      => '0',
      wb_stb_i      => '0',
      wb_ack_o      => open,
      wb_err_o      => open,
      wb_adr_i      => (others => '0'),
      wb_dat_i      => (others => '0'),
      wb_dat_o      => open,
      wb_sel_i      => "0000",
      wb_we_i       => '0',
      wb_inta_o     => open,

      -- ATA signals
      resetn_pad_o  => reset_cf,
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
  
  -- data bus drivers
  dd_i <= d_cf;
  d_cf <= dd_o when dd_oe = '1' else (others => 'Z');

  -- DMA mode not supported
  ndmack_cf <= 'Z';

  -- detect
  --<= cd_cf;
  
  -- power
  non_cf <= '1';
  
end architecture SYN;
