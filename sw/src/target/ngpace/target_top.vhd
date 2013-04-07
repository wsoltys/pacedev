library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
use work.video_controller_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;

entity target_top is
	port
	(
		clk_ref         :	 in std_logic;

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
    --  - SM1:  A<-SDA(15..0)   D->SDD(7..0)    (on cartridge)
    --  - SFIX: A<-NEO_IO       D->FIXD(7..0)   (D only on cartridge)
    --  - LO:   A<-P(15..0)     D->P(23..16)    (on cartridge)
    --  - BIOS: A<-A(16..1)     D->D(15..0)     (on cartridge)
    --  - SRAM: A<-A(20..1)     D->D(15..0)     (on cartridge, but same as BIOS)

    -- SDA(15..0) only, need extra lines to drive high order bits
    sm1_a           : out std_logic_vector(18 downto 16);
    sm1_d15_8       : inout std_logic_vector(15 downto 8);
    --sm1_d           : inout std_logic_vector(15 downto 0);
    sm1_cs_n        : out std_logic;
    sm1_oe_n        : out std_logic;
    sm1_we_n        : out std_logic;
    
    sfix_a          : out std_logic_vector(18 downto 0);
    sfix_d15_8      : inout std_logic_vector(15 downto 8);
    --sfix_d          : inout std_logic_vector(15 downto 0);
    sfix_cs_n       : out std_logic;
    sfix_oe_n       : out std_logic;
    sfix_we_n       : out std_logic;
    
    -- P(15..0) only routed to LO
    lo_a            : out std_logic_vector(18 downto 16);
    lo_d15_8        : inout std_logic_vector(15 downto 8);
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
  
  signal clkrst_i     : from_CLKRST_t;
  signal buttons_i    : from_BUTTONS_t;
  signal switches_i   : from_SWITCHES_t;
  signal leds_o       : to_LEDS_t;
  signal inputs_i     : from_INPUTS_t;
  signal flash_i      : from_FLASH_t;
  signal flash_o      : to_FLASH_t;
	signal sram_i			  : from_SRAM_t;
	signal sram_o			  : to_SRAM_t;	
	signal sdram_i      : from_SDRAM_t;
	signal sdram_o      : to_SDRAM_t;
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  signal project_i    : from_PROJECT_IO_t;
  signal project_o    : to_PROJECT_IO_t;
  signal platform_i   : from_PLATFORM_IO_t;
  signal platform_o   : to_PLATFORM_IO_t;
  signal target_i     : from_TARGET_IO_t;
  signal target_o     : to_TARGET_IO_t;

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

  BLK_INIT : block
    signal init       : std_logic := '1';
  begin
  
    reset_gen : process (clk_ref)
      variable reset_cnt : integer := 999999;
    begin
      if rising_edge(clk_ref) then
        if reset_cnt > 0 then
          init <= '1';
          reset_cnt := reset_cnt - 1;
        else
          init <= '0';
        end if;
      end if;
    end process reset_gen;

    clkrst_i.arst <= init;
    clkrst_i.arst_n <= not clkrst_i.arst;
    
  end block BLK_INIT;
  
  GEN_RESETS : for i in 0 to 3 generate

    process (clkrst_i.clk(i), clkrst_i.arst)
      variable rst_r : std_logic_vector(2 downto 0) := (others => '0');
    begin
      if clkrst_i.arst = '1' then
        rst_r := (others => '1');
      elsif rising_edge(clkrst_i.clk(i)) then
        rst_r := rst_r(rst_r'left-1 downto 0) & '0';
      end if;
      clkrst_i.rst(i) <= rst_r(rst_r'left);
    end process;

  end generate GEN_RESETS;

  GEN_FLASH : if PACE_HAS_FLASH generate
    alias flash_a18_16  : std_logic_vector(18 downto 16) is sm1_a;
    alias flash_a15_0   : std_logic_vector(15 downto 0) is sda;
    alias flash_d15_8   : std_logic_vector(15 downto 8) is sm1_d15_8;
    alias flash_d7_0    : std_logic_vector(7 downto 0) is sdd;
    alias flash_cs_n    : std_logic is sm1_cs_n;
    alias flash_oe_n    : std_logic is sm1_oe_n;
    alias flash_we_n    : std_logic is sm1_we_n;
  begin
    flash_a18_16 <= flash_o.a(18 downto 16);
    flash_a15_0 <= flash_o.a(15 downto 0);
    flash_i.d(15 downto 0) <= flash_d15_8 & flash_d7_0;
    flash_d15_8 <= flash_o.d(15 downto 8) when flash_o.we = '1' else (others => 'Z');
    flash_d7_0 <= flash_o.d(7 downto 0) when flash_o.we = '1' else (others => 'Z');
    flash_cs_n <= not flash_o.cs;
    flash_oe_n <= not flash_o.oe;
    flash_we_n <= not flash_o.we;
  end generate GEN_FLASH;
  
  GEN_SRAM : if PACE_HAS_SRAM generate
    alias sram_a    : std_logic_vector(19 downto 0) is a(20 downto 1);
    alias sram_d    : std_logic_vector(15 downto 0) is d(15 downto 0);
  begin
    -- enough lines on A for the entire device
    sram_a <= sram_o.a(sram_a'range);
    sram_i.d(sram_d'range) <= sram_d;
    sram_d <= sram_o.d(sram_d'range) when sram_o.we = '1' else (others => 'Z');
    sram_cs_n <= not sram_o.cs;
    sram_oe_n <= not sram_o.oe;
    sram_we_n <= not sram_o.we;
    sram_bhe_n <= not sram_o.be(1);
    sram_ble_n <= not sram_o.be(0);
  end generate GEN_SRAM;
  
  BLK_VIDEO : block
    type state_t is (IDLE, S1, S2, S3);
    signal state : state_t := IDLE;
  begin
  
    video_i.clk <= clkrst_i.clk(1);
    video_i.clk_ena <= '1';
    video_i.reset <= clkrst_i.rst(1);

    -- DVI (digital) output
    vdo_idck <= video_o.clk;
    vdo_red <= video_o.rgb.r(9 downto 2);
    vdo_green <= video_o.rgb.g(9 downto 2);
    vdo_blue <= video_o.rgb.b(9 downto 2);
    vdo_hsync <= video_o.hsync;
    vdo_vsync <= video_o.vsync;
    vdo_de <= not (video_o.hblank or video_o.vblank);

    -- VGA (analogue) output
		vao_clk <= video_o.clk;
		vao_red <= video_o.rgb.r;
		vao_green <= video_o.rgb.g;
		vao_blue <= video_o.rgb.b;
    vao_hsync <= video_o.hsync;
    vao_vsync <= video_o.vsync;
		vao_blank_n <= '1';
		vao_sync_t <= '0';

    -- configure the THS8135 video DAC
    process (video_o.clk, clkrst_i.arst)
      subtype count_t is integer range 0 to 9;
      variable count : count_t := 0;
    begin
      if clkrst_i.arst = '1' then
        state <= IDLE;
        vao_sync_n <= '1';
        vao_m1 <= '0';
        vao_m2 <= '0';
      elsif rising_edge(video_o.clk) then
        case state is
          when IDLE =>
            count := 0;
            state <= S1;
          when S1 =>
            vao_sync_n <= '0';
            vao_m1 <= '0';  -- BLNK_INT (full-range)
            vao_m2 <= '0';  -- sync insertion on 1?
            if count = count_t'high then
              count := 0;
              state <= S2;
            else
              count := count + 1;
            end if;
          when S2 =>
            vao_sync_n <= '1';
            -- RGB mode
            vao_m1 <= '0';
            vao_m2 <= '0';
            if count = count_t'high then
              state <= S3;
            else
              count := count + 1;
            end if;
          when S3 =>
            null;
        end case;
      end if;
    end process;
    
  end block BLK_VIDEO;
  
  --
  --  Cartridge connectors are not compatible with any external memories
  --
  
  GEN_TARGET_IO : if not (PACE_HAS_SRAM or PACE_HAS_FLASH) generate
  begin
    --
    -- MVS connector (186 pins)
    -- - RESET & SLOTCS duplicated (188 pins)
    --
    
    clk_24M <= target_o.mvs.clk_24M;
    clk_12M <= target_o.mvs.clk_12M;
    clk_8M <= target_o.mvs.clk_8M;
    clk_4MB <= target_o.mvs.clk_4MB;
    m68kclkb <= target_o.mvs.m68kclkb;
    reset <= target_o.mvs.reset;

    -- 68K bus signals
    a <= target_o.mvs.a;
    target_i.mvs.d_i <= d;
    d(15 downto 8) <= target_o.mvs.d_o(15 downto 8) when target_o.mvs.d_oe(1) = '1' else 
                      (others => 'Z');
    d(7 downto 0) <= target_o.mvs.d_o(7 downto 0) when target_o.mvs.d_oe(0) = '1' else 
                      (others => 'Z');
    as <= target_o.mvs.as;
    rw_n <= target_o.mvs.rw_n;
    
    -- $000000-$0FFFFF P1 ROM
    -- - P1 ROM read
    romoe_n <= target_o.mvs.romoe_n;
    -- - P1 ROM odd byte read
    romoel_n <= target_o.mvs.romoel_n;
    -- - P1 ROM even byte read
    romoeu_n <= target_o.mvs.romoeu_n;
    -- add 1 cycle delay for P1 ROM reads
    target_i.mvs.romwait_n <= romwait_n;
    -- add 0-3 cycle delays for P2 ROM reads
    target_i.mvs.pwait_n <= pwait_n;
    -- dtack config from cartridge
    target_i.mvs.pdtack <= pdtack;

    -- $200000-$2FFFFF P2+ROM/Security chip
    -- - any access
    portadrs_n <= target_o.mvs.portadrs_n;
    -- - odd byte write
    portwel_n <= target_o.mvs.portwel_n;
    -- - even byte write
    portweu_n <= target_o.mvs.portweu_n;
    -- - odd byte read
    portoel_n <= target_o.mvs.portoel_n;
    -- - even byte read
    portoeu_n <= target_o.mvs.portoeu_n;

    -- C ROM, S ROM & LO ROM multiplexed address/data bus
    target_i.mvs.p_i <= p;
    p <= target_o.mvs.p_o when target_o.mvs.p_oe = '1' else 
            (others => 'Z');
    
    -- C ROM A(4) line, address latch, data bus
    ca4 <= target_o.mvs.ca4;
    pck1b <= target_o.mvs.pck1b;
    target_i.mvs.cr_i <= cr;
    cr(31 downto 24) <= target_o.mvs.cr_o(31 downto 24) when target_o.mvs.cr_oe(3) = '1' else
          (others => 'Z');
    cr(23 downto 16) <= target_o.mvs.cr_o(23 downto 16) when target_o.mvs.cr_oe(2) = '1' else
          (others => 'Z');
    cr(15 downto 8) <= target_o.mvs.cr_o(15 downto 8) when target_o.mvs.cr_oe(1) = '1' else
          (others => 'Z');
    cr(7 downto 0) <= target_o.mvs.cr_o(7 downto 0) when target_o.mvs.cr_oe(0) = '1' else
          (others => 'Z');
    
    -- S ROM A(3) line, address latch, data bus
    sa3_2h1 <= target_o.mvs.sa3_2h1;
    pck2b <= target_o.mvs.pck2b;
    target_i.mvs.fixd_i <= fixd;
    fixd <= target_o.mvs.fixd_o when target_o.mvs.fixd_oe = '1' else
            (others => 'Z');
    
    -- Z80 address, data bus
    sda <= target_o.mvs.sda;
    target_i.mvs.sdd_i <= sdd;
    sdd <= target_o.mvs.sdd_o when target_o.mvs.sdd_oe = '1' else
            (others => 'Z');
    -- Z80 M1/RAM read signal (A17?)
    sdmrd <= target_o.mvs.sdmrd;
    -- SDRD0 is the write signal from NEO-D0 (A20..19?)
    sdrd <= target_o.mvs.sdrd;

    -- from NEO-D0 (A18?)
    sdrom <= target_o.mvs.sdrom;
    
    -- ADPCM-A ROM address bus
    -- only 23..20,9..8 used
    sdra_23_20 <= target_o.mvs.sdra_23_20;
    sdra_9_8 <= target_o.mvs.sdra_9_8;
    -- ADPCM-A ROM data/address bus
    target_i.mvs.sdrad_i <= sdrad;
    sdrad <= target_o.mvs.sdrad_o when target_o.mvs.sdrad_oe = '1' else
              (others => 'Z');
    -- ADPCM-B ROM address bus
    sdpa <= target_o.mvs.sdpa;
    -- ADPCM-B ROM data/address bus
    target_i.mvs.sdpad_i <= sdpad;
    sdpad <= target_o.mvs.sdpad_o when target_o.mvs.sdpad_oe = '1' else
              (others => 'Z');
    -- PCM bus muliplexing signals from YM2610
    sdpoe_n <= target_o.mvs.sdpoe_n;
    sdroe_n <= target_o.mvs.sdroe_n;
    sdpmpx <= target_o.mvs.sdpmpx;
    sdrmpx <= target_o.mvs.sdrmpx;

    -- tied to SYSTEMB on 1-slot boards
    -- goes LOW when slot is in use
    target_i.mvs.slotcs_n <= slotcs_n;

    --
    -- AES Connector (extra 14 pins)
    --
    
    clk_6M <= target_o.aes.clk_6M;
    
    -- NEO-ZMC2 outputs
    target_i.aes.dota <= dota;
    target_i.aes.dotb <= dotb;
    target_i.aes.gad <= gad;
    target_i.aes.gbd <= gbd;
    
    -- PRO-CT0 outputs (NEO-ZMC2 inputs)
    load <= target_o.aes.load;
    h <= target_o.aes.h;
    even <= target_o.aes.even;

  end generate GEN_TARGET_IO;
      
--  pace_inst : entity work.pace
--    port map
--    (
--      clock		        => clock,
--
--      --
--      --  AUDIO output
--      --
--      
--      -- TBA (SPI DAC?)
--      
--      --
--      --  External memories
--      --  - SM1:  A<-SDA      D->SDD    (on cartridge)
--      --  - SFIX: A<-NEO_IO   D->FIXD   (D only on cartridge)
--      --  - LO:   A<-P        D->P      (on cartridge)
--      --  - BIOS: A<-A        D->D      (on cartridge)
--      --  - SRAM: A<-A        D->D      (on cartridge, but same as BIOS)
--
--      -- SDA(15..0) only, need extra lines to drive high order bits
--      sm1_a           => sm1_a,
--      --sm1_d           : inout std_logic_vector(15 downto 0);
--      sm1_cs_n        => sm1_cs_n,
--      sm1_oe_n        => sm1_oe_n,
--      sm1_we_n        => sm1_we_n,
--      
--      sfix_a          => sfix_a,
--      --sfix_d          : inout std_logic_vector(15 downto 0);
--      sfix_cs_n       => sfix_cs_n,
--      sfix_oe_n       => sfix_oe_n,
--      sfix_we_n       => sfix_we_n,
--      
--      -- enough lines on P for the entire device
--      --lo_a            : out std_logic_vector(18 downto 0);
--      --lo_d            : inout std_logic_vector(15 downto 0);
--      lo_cs_n         => lo_cs_n,
--      lo_oe_n         => lo_oe_n,
--      lo_we_n         => lo_we_n,
--
--      -- *** NOTE: BIOS and SRAM on the same bus!!!
--      -- drive these separately for multiple BIOS images
--      bios_a          => bios_a,
--      --bios_d          : inout std_logic_vector(15 downto 0);
--      bios_cs_n       => bios_cs_n,
--      bios_oe_n       => bios_oe_n,
--      bios_we_n       => bios_we_n,
--      
--      --flash_we_n      : out std_logic;
--      
--      --
--      --  SD card
--      --
--
--      sd_dat3         => sd_dat3,
--      sd_cmd          => sd_cmd,
--      sd_clk          => sd_clk,
--      sd_dat_i        => sd_dat_i,
--      sd_dat_o        => sd_dat_o,
--      sd_dat_oe       => sd_dat_oe,
--      
--      --
--      --  I/O
--      --  - eg. gamecube/dc, Commodate IEC, etc
--      --
--
--      misc_io_i       => misc_io_i,
--      misc_io_o       => misc_io_o,
--      misc_io_oe      => misc_io_oe,
--      
--      --
--      -- ARM communications (SPIx3)
--      --
--      --  SPI0: 
--      --  SPI1: inputs (USB, AESJOY etc)
--      --  SPI2:
--      --
--      
--      spi_clk_i       => spi_clk_i,
--      spi_clk_o       => spi_clk_o,
--      spi_clk_oe      => spi_clk_oe,
--      spi_miso_i      => spi_miso_i,
--      spi_miso_o      => spi_miso_o,
--      spi_miso_oe     => spi_miso_oe,
--      spi_mosi_i      => spi_mosi_i,
--      spi_mosi_o      => spi_mosi_o,
--      spi_mosi_oe     => spi_mosi_oe,
--      spi_nss_i       => spi_nss_i,
--      spi_nss_o       => spi_nss_o,
--      spi_nss_oe      => spi_nss_oe,
--      
--      --
--      --  CPU socket (if we have the pins)
--      --  - 68K is 40 pins
--      --  - ARM2 is 84-pin PLCC
--      --  - ARM250 is 160 pin
--      --
--      cpu_io_i        => cpu_io_i,
--      cpu_io_o        => cpu_io_o,
--      cpu_io_oe       => cpu_io_oe
--	);

  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clkrst_i					=> clkrst_i,

      -- misc inputs and outputs
      buttons_i         => buttons_i,
      switches_i        => switches_i,
      leds_o            => leds_o,
      
      -- controller inputs
      inputs_i          => inputs_i,

     	-- external ROM/RAM
     	flash_i           => flash_i,
      flash_o           => flash_o,
      sram_i        		=> sram_i,
      sram_o        		=> sram_o,
     	sdram_i           => sdram_i,
     	sdram_o           => sdram_o,
  
      -- VGA video
      video_i           => video_i,
      video_o           => video_o,
      
      -- sound
      audio_i           => audio_i,
      audio_o           => audio_o,

      -- SPI (flash)
      spi_i.din         => '0',
      spi_o             => open,
  
      -- serial
      ser_i             => ser_i,
      ser_o             => ser_o,
      
      -- custom i/o
      project_i         => project_i,
      project_o         => project_o,
      platform_i        => platform_i,
      platform_o        => platform_o,
      target_i          => target_i,
      target_o          => target_o
    );

  --
  -- inout drivers
  --
  
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
