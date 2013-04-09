library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET 				: PACETargetType := PACE_TARGET_NGPACE;
	constant PACE_FPGA_VENDOR		: PACEFpgaVendor_t := PACE_FPGA_VENDOR_ALTERA;
	constant PACE_FPGA_FAMILY		: PACEFpgaFamily_t := PACE_FPGA_FAMILY_CYCLONE5;

  constant PACE_CLKIN0        : natural := 24;
  constant PACE_CLKIN1        : natural := 24;
  --constant PACE_HAS_FLASH     : boolean := false; -- can be emulated
  --constant PACE_HAS_SRAM      : boolean := false; -- can be emulated

  type to_MVS_CONNECTOR_t is record
  
    clk_24M         : std_logic;
    clk_12M         : std_logic;
    clk_8M          : std_logic;
    clk_4MB         : std_logic;
    m68kclkb        : std_logic;  -- from NEO-D0
    reset           : std_logic;

    -- 68K bus signals
    a               : std_logic_vector(23 downto 1);
    d_o             : std_logic_vector(15 downto 0);
    d_oe            : std_logic_vector(1 downto 0);
    as              : std_logic;
    rw_n            : std_logic;
    
    -- $000000-$0FFFFF P1 ROM
    -- - P1 ROM read
    romoe_n         : std_logic;
    -- - P1 ROM odd byte read
    romoel_n        : std_logic;
    -- - P1 ROM even byte read
    romoeu_n        : std_logic;

    -- $200000-$2FFFFF P2+ROM/Security chip
    -- - any access
    portadrs_n      : std_logic;
    -- - odd byte write
    portwel_n       : std_logic;
    -- - even byte write
    portweu_n       : std_logic;
    -- - odd byte read
    portoel_n       : std_logic;
    -- - even byte read
    portoeu_n       : std_logic;

    -- C ROM, S ROM & LO ROM multiplexed address/data bus
    p_o             : std_logic_vector(23 downto 0);
    p_oe            : std_logic;
    
    -- C ROM A(4) line, address latch, data bus
    ca4             : std_logic;
    pck1b           : std_logic;
    cr_o            : std_logic_vector(31 downto 0);
    cr_oe           : std_logic_vector(3 downto 0);
    
    -- S ROM A(3) line, address latch, data bus
    sa3_2h1         : std_logic;
    pck2b           : std_logic;
    fixd_o          : std_logic_vector(7 downto 0);
    fixd_oe         : std_logic;
    
    -- Z80 address, data bus
    sda             : std_logic_vector(15 downto 0);
    sdd_o           : std_logic_vector(7 downto 0);
    sdd_oe          : std_logic;
    -- Z80 M1/RAM read signal (A17?)
    sdmrd           : std_logic;
    -- SDRD0 is the write signal from NEO-D0 (A20..19?)
    sdrd            : std_logic_vector(1 downto 0);

    -- from NEO-D0 (A18?)
    sdrom           : std_logic;
    
    -- ADPCM-A ROM address bus
    -- only 23..20,9..8 used
    sdra_23_20      : std_logic_vector(23 downto 20);
    sdra_9_8        : std_logic_vector(9 downto 8);
    -- ADPCM-A ROM data/address bus
    sdrad_o         : std_logic_vector(7 downto 0);
    sdrad_oe        : std_logic;
    -- ADPCM-B ROM address bus
    sdpa            : std_logic_vector(11 downto 8);
    -- ADPCM-B ROM data/address bus
    sdpad_o         : std_logic_vector(7 downto 0);
    sdpad_oe        : std_logic;
    -- PCM bus muliplexing signals from YM2610
    sdpoe_n         : std_logic;
    sdroe_n         : std_logic;
    sdpmpx          : std_logic;
    sdrmpx          : std_logic;

    -- tied to SYSTEMB on 1-slot boards
    -- goes LOW when slot is in use
    slotcs          : std_logic;
    slotcs_oe       : std_logic;
    
  end record;
  
  type from_MVS_CONNECTOR_t is record
  
    -- 68K bus signals
    d_i             : std_logic_vector(15 downto 0);
    
    -- $000000-$0FFFFF P1 ROM
    -- add 1 cycle delay for P1 ROM reads
    romwait_n       : std_logic;
    -- add 0-3 cycle delays for P2 ROM reads
    pwait_n         : std_logic_vector(1 downto 0);
    -- dtack config from cartridge
    pdtack          : std_logic;

    -- C ROM, S ROM & LO ROM multiplexed address/data bus
    p_i             : std_logic_vector(23 downto 0);
    
    -- C ROM A(4) line, address latch, data bus
    cr_i            : std_logic_vector(31 downto 0);
    
    -- S ROM A(3) line, address latch, data bus
    fixd_i          : std_logic_vector(7 downto 0);
    
    -- Z80 address, data bus
    sdd_i           : std_logic_vector(7 downto 0);

    -- ADPCM-A ROM address bus
    sdrad_i         : std_logic_vector(7 downto 0);
    -- ADPCM-B ROM data/address bus
    sdpad_i         : std_logic_vector(7 downto 0);

  end record;
  
  type to_AES_CONNECTOR_t is record
  
    clk_6M          : std_logic;
    
    -- PRO-CT0 outputs (NEO-ZMC2 inputs)
    load            : std_logic;
    h               : std_logic;
    even            : std_logic;
    
  end record;

  type from_AES_CONNECTOR_t is record
    
    -- NEO-ZMC2 outputs
    dota            : std_logic;
    dotb            : std_logic;
    gad             : std_logic_vector(3 downto 0);
    gbd             : std_logic_vector(3 downto 0);
    
  end record;
  
  type from_TARGET_IO_t is record
  
    mvs             : from_MVS_CONNECTOR_t;
    aes             : from_AES_CONNECTOR_t;
  
    -- SD card
    sd_dat_i        : std_logic;
    
    misc_io_i       : std_logic_vector(15 downto 0);
    
    spi_clk_i       : std_logic_vector(0 to 2);
    spi_miso_i      : std_logic_vector(0 to 2);
    spi_mosi_i      : std_logic_vector(0 to 2);
    spi_nss_i       : std_logic_vector(0 to 2);

    cpu_io_i        : std_logic_vector(39 downto 0);

  end record;

  type to_TARGET_IO_t is record
  
    mvs             : to_MVS_CONNECTOR_t;
    aes             : to_AES_CONNECTOR_t;
    
    -- SD card
    sd_dat3         : std_logic;
    sd_cmd          : std_logic;
    sd_clk          : std_logic;
    sd_dat_o        : std_logic;
    sd_dat_oe       : std_logic;

    misc_io_o       : std_logic_vector(15 downto 0);
    misc_io_oe      : std_logic_vector(15 downto 0);
    
    spi_clk_o       : std_logic_vector(0 to 2);
    spi_clk_oe      : std_logic_vector(0 to 2);
    spi_miso_o      : std_logic_vector(0 to 2);
    spi_miso_oe     : std_logic_vector(0 to 2);
    spi_mosi_o      : std_logic_vector(0 to 2);
    spi_mosi_oe     : std_logic_vector(0 to 2);
    spi_nss_o       : std_logic_vector(0 to 2);
    spi_nss_oe      : std_logic_vector(0 to 2);

    cpu_io_o        : std_logic_vector(39 downto 0);
    cpu_io_oe       : std_logic_vector(39 downto 0);

  end record;

  --function NULL_TO_TARGET_IO return to_TARGET_IO_t;
  
end;
