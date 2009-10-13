library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
--use work.sdram_pkg.all;
use work.video_controller_pkg.all;
--use work.maple_pkg.all;
--use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
port
  (
    -- primary system clock
    sysclk            : in std_logic;

    -- apple ii bus interface    

    bus_dmaout        : in std_logic;
    bus_intout        : in std_logic;
    bus_nmi           : in std_logic;
    bus_irq           : in std_logic;
    bus_reset         : in std_logic;
    bus_inh           : in std_logic;

    bus_3m58          : in std_logic;
    bus_7m            : in std_logic;
    bus_q3            : in std_logic;
    bus_phase1        : in std_logic;
    bus_user1         : in std_logic;
    bus_phase0        : in std_logic;
    n_bus_dev_sel     : in std_logic;
    bus_d             : inout std_logic_vector(7 downto 0);

    bus_dmain         : in std_logic;
    bus_intin         : in std_logic;
    bus_dma           : in std_logic;
    bus_rdy           : in std_logic;
    bus_iostrobe      : in std_logic;
    bus_sync          : in std_logic;
    bus_r_w           : in std_logic;
    bus_a             : in std_logic_vector(15 downto 0);
    n_bus_io_sel

    -- boot flash interface
    prom_cs           : out std_logic;
    extspi_din        : out std_logic;  -- one of these is wrong
    extspi_dout       : out std_logic;
    extspi_sclk       : out std_logic;
    
    -- SRAM
    sram_a            : out std_logic_vector(16 downto 0);
    sram_d            : inout std_logic_vector(7 downto 0);
    sram_ncs          : out std_logic_vector(1 downto 0);
    sram_noe          : out std_logic;
    sram_nwe          : out std_logic;

    -- peripheral board clocks    
    clk_en            : out std_logic;
    clk_ext0          : out std_logic;
    clk_ext1          : out std_logic;
    
    -- peripheral board i/o
    pbio              : inout std_logic_vector(49 downto 0);

    -- peripheral board one wire interface
    one_wire_id       : inout std_logic;

    -- peripheral board i2c
    scl               : inout std_logic;
    sda               : inout std_logic;

    -- peripheral board sp interface
    extspi_cs_n0      : out std_logic;
    extspi_cs_n1      : out std_logic;
    sdio_detect       : out std_logic;
    sdio_protect      : out std_logic;
    
    -- vga interface
    clk_ext2          : out std_logic;

    -- IDE interface
    dmarq             : in std_logic;
    intrq             : in std_logic;
    iordy             : in std_logic;

    -- soft JTAG
    tck_soft          : out std_logic;
    tdi_soft          : out std_logic;
    tdo_soft          : out std_logic;
    tms_soft          : out std_logic
  );
end target_top;

architecture SYN of target_top is

  -- sigma-delta audio interface
  alias audio_left    : std_logic is sda;
  alias audio_right   : std_logic is scl;
  
  -- vga interface
  alias vga_r0        : std_logic is clk_ext2;
  alias vga_r1        : std_logic is pbio(4);
  alias vga_g0        : std_logic is pbio(0);
  alias vga_g1        : std_logic is pbio(1);
  alias vga_b0        : std_logic is pbio(2);
  alias vga_b1        : std_logic is pbio(3);
  alias vga_hs        : std_logic is pbio(45);
  alias vga_vs        : std_logic is pbio(46);
  
  -- sd card interface
  alias data1         : std_logic is pbio(47);
  alias data2         : std_logic is pbio(48);
  alias data3         : std_logic is pbio(49);

begin

end architecture SYN;
