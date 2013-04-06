library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;

entity pace is
	port
	(
		clock		        :	 in std_logic;

    --
    -- MVS connector (186 pins)
    -- - RESET & SLOTCS duplicated (188 pins)
    --
    
    clk_24M         : out std_logic;
    clk_12M         : out std_logic;
    clk_8M          : out std_logic;
    clk_4MB         : out std_logic;
    m68kclkb        : out std_logic;  -- from NEO-D0
    reset           : out std_logic;

    -- 68K bus signals
    a               : out std_logic_vector(23 downto 1);
    d_i             : in std_logic_vector(15 downto 0);
    d_o             : out std_logic_vector(15 downto 0);
    d_oe            : out std_logic_vector(1 downto 0);
    as              : out std_logic;
    rw_n            : out std_logic;
    
    -- $000000-$0FFFFF P1 ROM
    -- - P1 ROM read
    romoe_n         : out std_logic;
    -- - P1 ROM odd byte read
    romoel_n        : out std_logic;
    -- - P1 ROM even byte read
    romoeu_n        : out std_logic;
    -- add 1 cycle delay for P1 ROM reads
    romwait_n       : in std_logic;
    -- add 0-3 cycle delays for P2 ROM reads
    pwait_n         : in std_logic_vector(1 downto 0);
    -- dtack config from cartridge
    pdtack          : in std_logic;

    -- $200000-$2FFFFF P2+ROM/Security chip
    -- - any access
    portadrs_n      : out std_logic;
    -- - odd byte write
    portwel_n       : out std_logic;
    -- - even byte write
    portweu_n       : out std_logic;
    -- - odd byte read
    portoel_n       : out std_logic;
    -- - even byte read
    portoeu_n       : out std_logic;

    -- C ROM, S ROM & LO ROM multiplexed address/data bus
    p_i             : in std_logic_vector(23 downto 0);
    p_o             : out std_logic_vector(23 downto 0);
    p_oe            : out std_logic;
    
    -- C ROM A(4) line, address latch, data bus
    ca4             : out std_logic;
    pck1b           : out std_logic;
    cr_i            : in std_logic_vector(31 downto 0);
    cr_o            : out std_logic_vector(31 downto 0);
    cr_oe           : out std_logic_vector(3 downto 0);
    
    -- S ROM A(3) line, address latch, data bus
    sa3_2h1         : out std_logic;
    pck2b           : out std_logic;
    fixd_i          : in std_logic_vector(7 downto 0);
    fixd_o          : out std_logic_vector(7 downto 0);
    fixd_oe         : out std_logic;
    
    -- Z80 address, data bus
    sda             : out std_logic_vector(15 downto 0);
    sdd_i           : in std_logic_vector(7 downto 0);
    sdd_o           : out std_logic_vector(7 downto 0);
    sdd_oe          : out std_logic;
    -- Z80 M1/RAM read signal (A17?)
    sdmrd           : out std_logic;
    -- SDRD0 is the write signal from NEO-D0 (A20..19?)
    sdrd            : out std_logic_vector(1 downto 0);

    -- from NEO-D0 (A18?)
    sdrom           : out std_logic;
    
    -- ADPCM-A ROM address bus
    -- only 23..20,9..8 used
    sdra_23_20      : out std_logic_vector(23 downto 20);
    sdra_9_8        : out std_logic_vector(9 downto 8);
    -- ADPCM-A ROM data/address bus
    sdrad_i         : in std_logic_vector(7 downto 0);
    sdrad_o         : out std_logic_vector(7 downto 0);
    sdrad_oe        : out std_logic;
    -- ADPCM-B ROM address bus
    sdpa            : out std_logic_vector(11 downto 8);
    -- ADPCM-B ROM data/address bus
    sdpad_i         : in std_logic_vector(7 downto 0);
    sdpad_o         : out std_logic_vector(7 downto 0);
    sdpad_oe        : out std_logic;
    -- PCM bus muliplexing signals from YM2610
    sdpoe_n         : out std_logic;
    sdroe_n         : out std_logic;
    sdpmpx          : out std_logic;
    sdrmpx          : out std_logic;

    -- tied to SYSTEMB on 1-slot boards
    -- goes LOW when slot is in use
    slotcs_n        : in std_logic;

    --
    -- AES Connector (extra 14 pins)
    --
    
    clk_6M          : out std_logic;
    
    -- NEO-ZMC2 outputs
    dota            : in std_logic;
    dotb            : in std_logic;
    gad             : in std_logic_vector(3 downto 0);
    gbd             : in std_logic_vector(3 downto 0);
    
    -- PRO-CT0 outputs (NEO-ZMC2 inputs)
    load            : out std_logic;
    h               : out std_logic;
    even            : out std_logic;

    --
    --  AUDIO output
    --
    
    -- TBA (SPI DAC?)
    
    --
    --  External memories
    --  - SM1:  A<-SDA      D->SDD    (on cartridge)
    --  - SFIX: A<-NEO_IO   D->FIXD   (D only on cartridge)
    --  - LO:   A<-P        D->P      (on cartridge)
    --  - BIOS: A<-A        D->D      (on cartridge)
    --  - SRAM: A<-A        D->D      (on cartridge, but same as BIOS)

    -- SDA(15..0) only, need extra lines to drive high order bits
    sm1_a           : out std_logic_vector(18 downto 16);
    --sm1_d           : inout std_logic_vector(15 downto 0);
    sm1_cs_n        : out std_logic;
    sm1_oe_n        : out std_logic;
    sm1_we_n        : out std_logic;
    
    sfix_a          : out std_logic_vector(18 downto 0);
    --sfix_d          : inout std_logic_vector(15 downto 0);
    sfix_cs_n       : out std_logic;
    sfix_oe_n       : out std_logic;
    sfix_we_n       : out std_logic;
    
    -- enough lines on P for the entire device
    --lo_a            : out std_logic_vector(18 downto 0);
    --lo_d            : inout std_logic_vector(15 downto 0);
    lo_cs_n         : out std_logic;
    lo_oe_n         : out std_logic;
    lo_we_n         : out std_logic;

    -- *** NOTE: BIOS and SRAM on the same bus!!!
    -- drive these separately for multiple BIOS images
    bios_a          : out std_logic_vector(18 downto 16);
    --bios_d          : inout std_logic_vector(15 downto 0);
    bios_cs_n       : out std_logic;
    bios_oe_n       : out std_logic;
    bios_we_n       : out std_logic;
    
    --flash_we_n      : out std_logic;
    
    --
    --  SD card
    --

    sd_dat3         : out std_logic;
    sd_cmd          : out std_logic;
    sd_clk          : out std_logic;
    sd_dat_i        : in std_logic;
    sd_dat_o        : out std_logic;
    sd_dat_oe       : out std_logic;
    
    --
    --  I/O
    --  - eg. gamecube/dc, Commodate IEC, etc
    --

    misc_io_i       : in std_logic_vector(15 downto 0);
    misc_io_o       : out std_logic_vector(15 downto 0);
    misc_io_oe      : out std_logic_vector(15 downto 0);
    
    --
    -- ARM communications (SPIx3)
    --
    --  SPI0: 
    --  SPI1: inputs (USB, AESJOY etc)
    --  SPI2:
    --
    
    spi_clk_i       : in std_logic_vector(0 to 2);
    spi_clk_o       : out std_logic_vector(0 to 2);
    spi_clk_oe      : out std_logic_vector(0 to 2);
    spi_miso_i      : in std_logic_vector(0 to 2);
    spi_miso_o      : out std_logic_vector(0 to 2);
    spi_miso_oe     : out std_logic_vector(0 to 2);
    spi_mosi_i      : in std_logic_vector(0 to 2);
    spi_mosi_o      : out std_logic_vector(0 to 2);
    spi_mosi_oe     : out std_logic_vector(0 to 2);
    spi_nss_i       : in std_logic_vector(0 to 2);
    spi_nss_o       : out std_logic_vector(0 to 2);
    spi_nss_oe      : out std_logic_vector(0 to 2);
    
    --
    --  CPU socket (if we have the pins)
    --  - 68K is 40 pins
    --  - ARM2 is 84-pin PLCC
    --  - ARM250 is 160 pin
    --
    cpu_io_i        : in std_logic_vector(39 downto 0);
    cpu_io_o        : out std_logic_vector(39 downto 0);
    cpu_io_oe       : out std_logic_vector(39 downto 0)
	);
end entity pace;

architecture SYN of pace is

--    attribute altera_attribute : string;
--    attribute altera_attribute of sdra : signal is "-name VIRTUAL_PIN ON";
    
begin

  -- MVS cartridge connector OE
  
  d_oe <= (others => '0');
  p_oe <= '0';
  cr_oe <= (others => '0');
  fixd_oe <= '0';
  sdd_oe <= '0';
  sdrad_oe <= '0';
  sdpad_oe <= '0';

  -- memories
  sm1_a <= (others => 'Z');
  sm1_cs_n <= '1';
  sm1_oe_n <= '1';
  sm1_we_n <= '1';
  
  sfix_a <= (others => 'Z');
  sfix_cs_n <= '1';
  sfix_oe_n <= '1';
  sfix_we_n <= '1';
  
  --lo_a <= (others => 'Z');
  lo_cs_n <= '1';
  lo_oe_n <= '1';
  lo_we_n <= '1';

  bios_a <= (others => 'Z');
  bios_cs_n <= '1';
  bios_oe_n <= '1';
  bios_we_n <= '1';
  
--  sram_cs_n <= '1';
--  sram_oe_n <= '1';
--  sram_we_n <= '1';
--  sram_bhe_n <= '1';
--  sram_ble_n <= '1';

--  ps2_kdat <= 'Z';
--  ps2_mdat <= 'Z';

--  uart_tx <= 'Z';
--  uart_rts <= 'Z';
  
  sd_dat3 <= 'Z';
  sd_cmd <= 'Z';
  sd_clk <= 'Z';
  sd_dat_oe <= 'Z';
  
  misc_io_oe <= (others => '0');
  
  spi_clk_oe <= (others => '0');
  spi_mosi_oe <= (others => '0');
  spi_miso_oe <= (others => '0');
  spi_nss_oe <= (others => '0');

  cpu_io_o <= (others => '0');
  

end architecture SYN;

