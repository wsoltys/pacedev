library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;
--use work.pace_pkg.all;
--use work.sdram_pkg.all;
--use work.video_controller_pkg.all;
--use work.project_pkg.all;
--use work.platform_pkg.all;
--use work.target_pkg.all;

entity target_top is
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
    d               : inout std_logic_vector(15 downto 0);
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
    p               : inout std_logic_vector(23 downto 0);
    
    -- C ROM A(4) line, address latch, data bus
    ca4             : out std_logic;
    pck1b           : out std_logic;
    cr              : inout std_logic_vector(31 downto 0);
    
    -- S ROM A(3) line, address latch, data bus
    sa3_2h1         : out std_logic;
    pck2b           : out std_logic;
    fixd            : inout std_logic_vector(7 downto 0);
    
    -- Z80 address, data bus
    sda             : out std_logic_vector(15 downto 0);
    sdd             : inout std_logic_vector(7 downto 0);
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
    sdrad           : inout std_logic_vector(7 downto 0);
    -- ADPCM-B ROM address bus
    sdpa            : out std_logic_vector(11 downto 8);
    -- ADPCM-B ROM data/address bus
    sdpad           : inout std_logic_vector(7 downto 0);
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
    -- VIDEO output
    --
    
    -- VGA output, 1 pix/clk, 30-bit mode
		vao_clk	  	    : out std_logic;
		vao_red			    : out std_logic_vector(9 downto 0);
		vao_green		    : out std_logic_vector(9 downto 0);
		vao_blue		    : out std_logic_vector(9 downto 0);
		vao_hsync       : out std_logic;
		vao_vsync       : out std_logic;
		vao_blank_n     : out std_logic;
		vao_sync_n	    : out std_logic;
		vao_sync_t	    : out std_logic;
		vao_m1			    : out std_logic;
		vao_m2			    : out std_logic;

    -- DVI output, 24-bit mode
		vdo_red			    : out std_logic_vector(7 downto 0);
		vdo_green		    : out std_logic_vector(7 downto 0);
		vdo_blue		    : out std_logic_vector(7 downto 0);
		vdo_idck		    : out std_logic;
		vdo_hsync		    : out std_logic;
		vdo_vsync		    : out std_logic;
		vdo_de			    : out std_logic;
    
		vdo_po1			    : in std_logic;
		vdo_rstn		    : out std_logic;

    -- I2C to the TFP410 (DVI out transmitter)
    vdo_scl         : inout std_logic;
    vdo_sda         : inout std_logic;
    
    -- I2C on the DVI output connector
    -- (possibly don't need this)
		dvo_scl			    : inout std_logic;
		dvo_sda			    : inout std_logic;

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
    
    -- enough lines on A for the entire device
    --sram_a           : out std_logic_vector(19 downto 0);
    --sram_d           : inout std_logic_vector(15 downto 0);
    sram_cs_n        : out std_logic;
    sram_oe_n        : out std_logic;
    sram_we_n        : out std_logic;
    sram_bhe_n       : out std_logic;
    sram_ble_n       : out std_logic;
    
    --
    --  PS2 (mouse + keyboard)
    --
    
    ps2_kclk        : out std_logic;
    ps2_kdat        : inout std_logic;
    ps2_mclk        : out std_logic;
    ps2_mdat        : inout std_logic;
    
    --
    --  UART/Serial
    --
    
    uart_tx         : out std_logic;
    uart_rx         : in std_logic;
    uart_cts        : in std_logic;
    uart_rts        : out std_logic;
    
    --
    --  SD card
    --

    sd_dat3         : out std_logic;
    sd_cmd          : out std_logic;
    sd_clk          : out std_logic;
    sd_dat          : inout std_logic;
    
    --
    --  I/O
    --  - eg. gamecube/dc, Commodate IEC, etc
    --

    misc_io         : inout std_logic_vector(15 downto 0);
    
    --
    -- ARM communications (SPIx3)
    --
    --  SPI0: 
    --  SPI1: inputs (USB, AESJOY etc)
    --  SPI2:
    --
    
    spi_clk         : inout std_logic_vector(0 to 2);
    spi_miso        : inout std_logic_vector(0 to 2);
    spi_mosi        : inout std_logic_vector(0 to 2);
    spi_nss         : inout std_logic_vector(0 to 2);
    
    --
    --  CPU socket (if we have the pins)
    --  - 68K is 40 pins
    --  - ARM2 is 84-pin PLCC
    --  - ARM250 is 160 pin
    --
    cpu_io          : inout std_logic_vector(39 downto 0);

    --
    -- SDRAM (37 pins)
    --
    
		sdram_clk       : out std_logic;
		sdram_data      : inout unsigned(15 downto 0);
		sdram_addr      : out unsigned(12 downto 0);
		sdram_we_n      : out std_logic;
		sdram_ras_n     : out std_logic;
		sdram_cas_n     : out std_logic;
		sdram_ba        : out std_logic_vector(1 downto 0);
		sdram_ldqm      : out std_logic;
		sdram_udqm      : out std_logic
    
--    --
--    --  DDR (if we have 81 spare pins)
--    --  - 32 bits wide
--    --
--    
--    ddr_odt         : out std_logic_vector(0 downto 0);
--		ddr_clk         : inout std_logic_vector(0 downto 0);
--		ddr_clk_n       : inout std_logic_vector(0 downto 0);
--		ddr_cs_n        : out std_logic_vector(0 downto 0);
--		ddr_cke         : out std_logic_vector(0 downto 0);
--		ddr_a           : out std_logic_vector(12 downto 0);
--		ddr_ba          : out std_logic_vector(2 downto 0);
--		ddr_ras_n       : out std_logic;
--		ddr_cas_n       : out std_logic;
--		ddr_we_n        : out std_logic;
--		ddr_dq          : inout std_logic_vector(31 downto 0);
--		ddr_dqs         : inout std_logic_vector(7 downto 0);
--		ddr_dqsn        : inout std_logic_vector(7 downto 0);
--		ddr_dm          : out std_logic_vector(7 downto 0);
--		ddr_reset_n     : out std_logic
	);
end entity target_top;

architecture SYN of target_top is

--    attribute altera_attribute : string;
--    attribute altera_attribute of sdra : signal is "-name VIRTUAL_PIN ON";

  signal d_i          : std_logic_vector(15 downto 0);
  signal d_o          : std_logic_vector(15 downto 0);
  signal d_oe         : std_logic_vector(1 downto 0);
  
  signal p_i          : std_logic_vector(23 downto 0);
  signal p_o          : std_logic_vector(23 downto 0);
  signal p_oe         : std_logic;
  
  signal cr_i         : std_logic_vector(31 downto 0);
  signal cr_o         : std_logic_vector(31 downto 0);
  signal cr_oe        : std_logic_vector(3 downto 0);
  
  signal fixd_i       : std_logic_vector(7 downto 0);
  signal fixd_o       : std_logic_vector(7 downto 0);
  signal fixd_oe      : std_logic;
  
  signal sdd_i        : std_logic_vector(7 downto 0);
  signal sdd_o        : std_logic_vector(7 downto 0);
  signal sdd_oe       : std_logic;
  
  signal sdrad_i      : std_logic_vector(7 downto 0);
  signal sdrad_o      : std_logic_vector(7 downto 0);
  signal sdrad_oe     : std_logic;
  
  signal sdpad_i      : std_logic_vector(7 downto 0);
  signal sdpad_o      : std_logic_vector(7 downto 0);
  signal sdpad_oe     : std_logic;
  
  signal sd_dat_i     : std_logic;
  signal sd_dat_o     : std_logic;
  signal sd_dat_oe    : std_logic;

  signal misc_io_i    : std_logic_vector(15 downto 0);
  signal misc_io_o    : std_logic_vector(15 downto 0);
  signal misc_io_oe   : std_logic_vector(15 downto 0);
  
  signal spi_clk_i    : std_logic_vector(0 to 2);
  signal spi_clk_o    : std_logic_vector(0 to 2);
  signal spi_clk_oe   : std_logic_vector(0 to 2);
  signal spi_miso_i   : std_logic_vector(0 to 2);
  signal spi_miso_o   : std_logic_vector(0 to 2);
  signal spi_miso_oe  : std_logic_vector(0 to 2);
  signal spi_mosi_i   : std_logic_vector(0 to 2);
  signal spi_mosi_o   : std_logic_vector(0 to 2);
  signal spi_mosi_oe  : std_logic_vector(0 to 2);
  signal spi_nss_i    : std_logic_vector(0 to 2);
  signal spi_nss_o    : std_logic_vector(0 to 2);
  signal spi_nss_oe   : std_logic_vector(0 to 2);
  
  signal cpu_io_i     : std_logic_vector(39 downto 0);
  signal cpu_io_o     : std_logic_vector(39 downto 0);
  signal cpu_io_oe    : std_logic_vector(39 downto 0);
  
begin

  pace_inst : entity work.pace
    port map
    (
      clock		        => clock,

      --
      -- MVS connector (186 pins)
      -- - RESET & SLOTCS duplicated (188 pins)
      --
      
      clk_24M         => clk_24M,
      clk_12M         => clk_12M,
      clk_8M          => clk_8M,
      clk_4MB         => clk_4MB,
      m68kclkb        => m68kclkb,
      reset           => reset,

      -- 68K bus signals
      a               => a,
      d_i             => d_i,
      d_o             => d_o,
      d_oe            => d_oe,
      as              => as,
      rw_n            => rw_n,
      
      -- $000000-$0FFFFF P1 ROM
      -- - P1 ROM read
      romoe_n         => romoe_n,
      -- - P1 ROM odd byte read
      romoel_n        => romoel_n,
      -- - P1 ROM even byte read
      romoeu_n        => romoeu_n,
      -- add 1 cycle delay for P1 ROM reads
      romwait_n       => romwait_n,
      -- add 0-3 cycle delays for P2 ROM reads
      pwait_n         => pwait_n,
      -- dtack config from cartridge
      pdtack          => pdtack,

      -- $200000-$2FFFFF P2+ROM/Security chip
      -- - any access
      portadrs_n      => portadrs_n,
      -- - odd byte write
      portwel_n       => portwel_n,
      -- - even byte write
      portweu_n       => portweu_n,
      -- - odd byte read
      portoel_n       => portoel_n,
      -- - even byte read
      portoeu_n       => portoeu_n,

      -- C ROM, S ROM & LO ROM multiplexed address/data bus
      p_i             => p_i,
      p_o             => p_o,
      p_oe            => p_oe,
      
      -- C ROM A(4) line, address latch, data bus
      ca4             => ca4,
      pck1b           => pck1b,
      cr_i            => cr_i,
      cr_o            => cr_o,
      cr_oe           => cr_oe,
      
      -- S ROM A(3) line, address latch, data bus
      sa3_2h1         => sa3_2h1,
      pck2b           => pck2b,
      fixd_i          => fixd_i,
      fixd_o          => fixd_o,
      fixd_oe         => fixd_oe,
      
      -- Z80 address, data bus
      sda             => sda,
      sdd_i           => sdd_i,
      sdd_o           => sdd_o,
      sdd_oe          => sdd_oe,
      -- Z80 M1/RAM read signal (A17?)
      sdmrd           => sdmrd,
      -- SDRD0 is the write signal from NEO-D0 (A20..19?)
      sdrd            => sdrd,

      -- from NEO-D0 (A18?)
      sdrom           => sdrom,
      
      -- ADPCM-A ROM address bus
      -- only 23..20,9..8 used
      sdra_23_20      => sdra_23_20,
      sdra_9_8        => sdra_9_8,
      -- ADPCM-A ROM data/address bus
      sdrad_i         => sdrad_i,
      sdrad_o         => sdrad_o,
      sdrad_oe        => sdrad_oe,
      -- ADPCM-B ROM address bus
      sdpa            => sdpa,
      -- ADPCM-B ROM data/address bus
      sdpad_i         => sdpad_i,
      sdpad_o         => sdpad_o,
      sdpad_oe        => sdpad_oe,
      -- PCM bus muliplexing signals from YM2610
      sdpoe_n         => sdpoe_n,
      sdroe_n         => sdroe_n,
      sdpmpx          => sdpmpx,
      sdrmpx          => sdrmpx,

      -- tied to SYSTEMB on 1-slot boards
      -- goes LOW when slot is in use
      slotcs_n        => slotcs_n,

      --
      -- AES Connector (extra 14 pins)
      --
      
      clk_6M          => clk_6M,
      
      -- NEO-ZMC2 outputs
      dota            => dota,
      dotb            => dotb,
      gad             => gad,
      gbd             => gbd,
      
      -- PRO-CT0 outputs (NEO-ZMC2 inputs)
      load            => load,
      h               => h,
      even            => even,

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
      sm1_a           => sm1_a,
      --sm1_d           : inout std_logic_vector(15 downto 0);
      sm1_cs_n        => sm1_cs_n,
      sm1_oe_n        => sm1_oe_n,
      sm1_we_n        => sm1_we_n,
      
      sfix_a          => sfix_a,
      --sfix_d          : inout std_logic_vector(15 downto 0);
      sfix_cs_n       => sfix_cs_n,
      sfix_oe_n       => sfix_oe_n,
      sfix_we_n       => sfix_we_n,
      
      -- enough lines on P for the entire device
      --lo_a            : out std_logic_vector(18 downto 0);
      --lo_d            : inout std_logic_vector(15 downto 0);
      lo_cs_n         => lo_cs_n,
      lo_oe_n         => lo_oe_n,
      lo_we_n         => lo_we_n,

      -- *** NOTE: BIOS and SRAM on the same bus!!!
      -- drive these separately for multiple BIOS images
      bios_a          => bios_a,
      --bios_d          : inout std_logic_vector(15 downto 0);
      bios_cs_n       => bios_cs_n,
      bios_oe_n       => bios_oe_n,
      bios_we_n       => bios_we_n,
      
      --flash_we_n      : out std_logic;
      
      --
      --  SD card
      --

      sd_dat3         => sd_dat3,
      sd_cmd          => sd_cmd,
      sd_clk          => sd_clk,
      sd_dat_i        => sd_dat_i,
      sd_dat_o        => sd_dat_o,
      sd_dat_oe       => sd_dat_oe,
      
      --
      --  I/O
      --  - eg. gamecube/dc, Commodate IEC, etc
      --

      misc_io_i       => misc_io_i,
      misc_io_o       => misc_io_o,
      misc_io_oe      => misc_io_oe,
      
      --
      -- ARM communications (SPIx3)
      --
      --  SPI0: 
      --  SPI1: inputs (USB, AESJOY etc)
      --  SPI2:
      --
      
      spi_clk_i       => spi_clk_i,
      spi_clk_o       => spi_clk_o,
      spi_clk_oe      => spi_clk_oe,
      spi_miso_i      => spi_miso_i,
      spi_miso_o      => spi_miso_o,
      spi_miso_oe     => spi_miso_oe,
      spi_mosi_i      => spi_mosi_i,
      spi_mosi_o      => spi_mosi_o,
      spi_mosi_oe     => spi_mosi_oe,
      spi_nss_i       => spi_nss_i,
      spi_nss_o       => spi_nss_o,
      spi_nss_oe      => spi_nss_oe,
      
      --
      --  CPU socket (if we have the pins)
      --  - 68K is 40 pins
      --  - ARM2 is 84-pin PLCC
      --  - ARM250 is 160 pin
      --
      cpu_io_i        => cpu_io_i,
      cpu_io_o        => cpu_io_o,
      cpu_io_oe       => cpu_io_oe
	);

  --
  -- inout drivers
  --
  
  -- MVS cartridge connector
  d_i <= d;
  d(15 downto 8) <= d_o(15 downto 8) when d_oe(1) = '1' else (others => 'Z');
  d(7 downto 0) <= d_o(7 downto 0) when d_oe(0) = '1' else (others => 'Z');
  p_i <= p;
  p <= p_o when p_oe = '1' else (others => 'Z');
  cr_i <= cr;
  cr(31 downto 24) <= cr_o(31 downto 24) when cr_oe(3) = '1' else (others => 'Z');
  cr(23 downto 16) <= cr_o(23 downto 16) when cr_oe(2) = '1' else (others => 'Z');
  cr(15 downto 8) <= cr_o(15 downto 8) when cr_oe(1) = '1' else (others => 'Z');
  cr(7 downto 0) <= cr_o(7 downto 0) when cr_oe(0) = '1' else (others => 'Z');
  fixd_i <= fixd;
  fixd <= fixd_o when fixd_oe = '1' else (others => 'Z');
  sdd_i <= sdd;
  sdd <= sdd_o when sdd_oe = '1' else (others => 'Z');
  sdrad_i <= sdrad;
  sdrad <= sdrad_o when sdrad_oe = '1' else (others => 'Z');
  sdpad_i <= sdpad;
  sdpad <= sdpad_o when sdpad_oe = '1' else (others => 'Z');
  
  -- SD card
  sd_dat_i <= sd_dat;
  sd_dat <= sd_dat_o when sd_dat_oe = '1' else 'Z';
  
  -- MISC IO
  GEN_MISC_IO : for i in misc_io'range generate
    misc_io_i(i) <= misc_io(i);
    misc_io(i) <= misc_io_o(i) when misc_io_oe(i) = '1' else 'Z';
  end generate GEN_MISC_IO;
  
  -- SPI
  GEN_SPI : for i in spi_clk'range generate
    spi_clk_i(i) <= spi_clk(i);
    spi_clk(i) <= spi_clk_o(i) when spi_clk_oe(i) = '1' else 'Z';
    spi_miso_i(i) <= spi_miso(i);
    spi_miso(i) <= spi_miso_o(i) when spi_miso_oe(i) = '1' else 'Z';
    spi_mosi_i(i) <= spi_mosi(i);
    spi_mosi(i) <= spi_mosi_o(i) when spi_mosi_oe(i) = '1' else 'Z';
    spi_nss_i(i) <= spi_nss(i);
    spi_nss(i) <= spi_nss_o(i) when spi_nss_oe(i) = '1' else 'Z';
  end generate GEN_SPI;
  
  -- CPU IO
  GEN_CPU_IO : for i in cpu_io'range generate
    cpu_io_i(i) <= cpu_io(i);
    cpu_io(i) <= cpu_io_o(i) when cpu_io_oe(i) = '1' else 'Z';
  end generate GEN_CPU_IO;

end architecture SYN;
