--
-- minimig_de1 VHDL translation
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity minimig_de1 is
  generic
  (
    HAS_I2C_AV_CONFIG  : boolean := true
  );
  port
  (
    joya          : in std_logic_vector(5 downto 0);
    joyb          : in std_logic_vector(5 downto 0);
    sd_dat        : in std_logic;
    joy           : in std_logic_vector(6 downto 0);
    clock_27      : in std_logic_vector(1 downto 0);
    clock_24      : in std_logic_vector(1 downto 0);
    ext_clock     : in std_logic;
    clock_50      : in std_logic;
    key           : in std_logic_vector(3 downto 0);
    sw            : in std_logic_vector(9 downto 0);
    aud_adcdat    : in std_logic;
    uart_rxd      : in std_logic;
    tdi           : in std_logic;
    tck           : in std_logic;
    tcs           : in std_logic;
    dram_cke      : out std_logic;
    dram_dq       : inout std_logic_vector(15 downto 0);
    dram_addr     : out std_logic_vector(12 downto 0);
    dram_cs_n     : out std_logic;
    ledg          : out std_logic_vector(7 downto 0);
    dram_ba_0     : out std_logic;
    dram_ba_1     : out std_logic;
    dram_we_n     : out std_logic;
    dram_ldqm     : out std_logic;
    dram_ras_n    : out std_logic;
    dram_udqm     : out std_logic;
    dram_cas_n    : out std_logic;
    fl_dq         : inout std_logic_vector(7 downto 0);
    fl_ce_n       : out std_logic;
    fl_oe_n       : out std_logic;
    fl_rst_n      : out std_logic;
    fl_we_n       : out std_logic;
    sram_dq       : inout std_logic_vector(15 downto 0);
    fl_addr       : out std_logic_vector(21 downto 0);
    sram_addr     : out std_logic_vector(17 downto 0);
    sram_ub_n     : out std_logic;
    sram_lb_n     : out std_logic;
    sram_we_n     : out std_logic;
    sram_ce_n     : out std_logic;
    ps2_mdat      : inout std_logic;
    sram_oe_n     : out std_logic;
    ps2_mclk      : inout std_logic;
    ps2_dat       : inout std_logic;
    ps2_clk       : inout std_logic;
    vga_hs        : out std_logic;
    tdo           : out std_logic;
    vga_vs        : out std_logic;
    vga_r         : out std_logic_vector(3 downto 0);
    vga_g         : out std_logic_vector(3 downto 0);
    vga_b         : out std_logic_vector(3 downto 0);
    sd_dat3       : out std_logic;
    sd_clk        : out std_logic;
    sd_cmd        : out std_logic;
    aud_adclrck   : inout std_logic;
    uart_txd      : out std_logic;
    hex0          : out std_logic_vector(6 downto 0);
    hex1          : out std_logic_vector(6 downto 0);
    hex2          : out std_logic_vector(6 downto 0);
    hex3          : out std_logic_vector(6 downto 0);
    ledr          : out std_logic_vector(9 downto 0);
    aud_xck       : out std_logic;
    aud_dacdat    : out std_logic;
    aud_daclrck   : inout std_logic;
    aud_bclk      : inout std_logic;
    dram_clk      : out std_logic;
    i2c_sclk      : out std_logic;
    i2c_sdat      : inout std_logic
  );
end minimig_de1;

architecture SYN of minimig_de1 is

  component amigaclk is
    port
    (
      inclk0        : in std_logic;
      areset        : in std_logic;
      c0            : out std_logic;
      c1            : out std_logic;
      c2            : out std_logic;
      locked        : out std_logic
    );
  end component amigaclk;

  component TG68 is
    port
    (        
      clk           : in std_logic;
      reset         : in std_logic;
      clkena_in     : in std_logic:='1';
      data_in       : in std_logic_vector(15 downto 0);
      IPL           : in std_logic_vector(2 downto 0):="111";
      dtack         : in std_logic;
      addr          : out std_logic_vector(31 downto 0);
      data_out      : out std_logic_vector(15 downto 0);
      as            : out std_logic;
      uds           : out std_logic;
      lds           : out std_logic;
      rw            : out std_logic
    );
  end component TG68;

  component minimig1_pace is
    port
    (
      cpuaddress    : in std_logic_vector(23 downto 1);
      i_as          : in std_logic;
      i_uds         : in std_logic;
      i_lds         : in std_logic;
      r_w           : in std_logic;
      ramdata       : in std_logic_vector(15 downto 0);
      c_7m_in       : in std_logic;
      c_28m         : in std_logic;
      rxd           : in std_logic;
      cts           : in std_logic;
      i_joy1        : in std_logic_vector(5 downto 0);
      i_joy2        : in std_logic_vector(5 downto 0);
      i_15khz       : in std_logic;
      cpudata_in    : in std_logic_vector(15 downto 0);
      floppy_ena    : in std_logic;
      user_ena      : in std_logic;
      user_clk      : in std_logic;
      di_floppy     : in std_logic_vector(15 downto 0);
      floppy_clk    : in std_logic;
      exrst         : in std_logic;
      di_user       : in std_logic_vector(7 downto 0);
      cpudata_out   : out std_logic_vector(15 downto 0);
      o_ipl         : out std_logic_vector(2 downto 0);
      o_dtack       : out std_logic;
      o_cpureset    : out std_logic;
      cpuclk        : out std_logic;
      ramaddress    : out std_logic_vector(19 downto 1);
      o_ramsel0     : out std_logic;
      o_ramsel1     : out std_logic;
      o_ub          : out std_logic;
      o_lb          : out std_logic;
      o_we          : out std_logic;
      o_oe          : out std_logic;
      txd           : out std_logic;
      rts           : out std_logic;
      pwrled        : out std_logic;
      msdat         : inout std_logic;
      msclk         : inout std_logic;
      kbddat        : inout std_logic;
      kbdclk        : inout std_logic;
      do_floppy     : out std_logic_vector(15 downto 0);
      o_hsyncout    : out std_logic;
      o_vsyncout    : out std_logic;
      redout        : out std_logic_vector(3 downto 0);
      greenout      : out std_logic_vector(3 downto 0);
      blueout       : out std_logic_vector(3 downto 0);
      ldata         : out std_logic_vector(13 downto 0);
      rdata         : out std_logic_vector(13 downto 0);
      sd_wr_data    : out std_logic_vector(15 downto 0);
      do_user       : out std_logic_vector(7 downto 0)
    );
  end component minimig1_pace;

  component sdram is
    port
    (
      sdata		      : inout std_logic_vector(15 downto 0);
      sdaddr		    : out std_logic_vector(12 downto 0);
      dqm			      : out std_logic_vector(3 downto 0);
      sd_cs		      : out std_logic_vector(3 downto 0);
      ba			      : buffer std_logic_vector(1 downto 0);
      sd_we		      : out std_logic;
      sd_ras		    : out std_logic;
      sd_cas		    : out std_logic;

      sysclk		    : in std_logic;
      reset		      : in std_logic;
      
      zdatawr		    : in std_logic_vector(7 downto 0);
      zAddr		      : in std_logic_vector(22 downto 0);
      zwr			      : in std_logic;
      datawr		    : in std_logic_vector(15 downto 0);
      rAddr		      : in std_logic_vector(22 downto 0);
      rwr			      : in std_logic;
      dwrL		      : in std_logic;
      dwrU		      : in std_logic;
      zstate		    : in std_logic_vector(2 downto 0);
      
      dataout		    : out std_logic_vector(15 downto 0);
      zdataout		  : out std_logic_vector(7 downto 0);
      c_56m		      : out std_logic;
      zena_o		    : out std_logic;
      c_28m		      : out std_logic;
      c_7m		      : out std_logic;
      reset_out	    : out std_logic
    );
  end component sdram;

  component spihost is
    port
    (
      data_rd       : in std_logic_vector(7 downto 0);
      host_clk      : in std_logic;
      memwait       : in std_logic;
      host_reset    : in std_logic;
      sd_di         : in std_logic;
      di_floppy     : in std_logic_vector(15 downto 0);
      di_user       : in std_logic_vector(7 downto 0);
      sw            : in std_logic_vector(3 downto 0);
      lin           : in std_logic_vector(15 downto 0);
      rin2          : in std_logic_vector(15 downto 0);
      data_wr       : out std_logic_vector(7 downto 0);
      addr          : out std_logic_vector(23 downto 0);
      mem_wr        : out std_logic;
      sd_cs         : out std_logic_vector(7 downto 0);
      sd_clk        : out std_logic;
      sd_do         : out std_logic;
      uart_txd      : out std_logic;
      do_user       : out std_logic_vector(7 downto 0);
      do_floppy     : out std_logic_vector(15 downto 0);
      hex0          : out std_logic_vector(6 downto 0);
      hex1          : out std_logic_vector(6 downto 0);
      hex2          : out std_logic_vector(6 downto 0);
      hex3          : out std_logic_vector(6 downto 0);
      ledr          : out std_logic_vector(9 downto 0);
      links         : out std_logic_vector(15 downto 0);
      rechts        : out std_logic_vector(15 downto 0);
      romled        : out std_logic;
      enaled        : out std_logic;
      zstate        : out std_logic_vector(2 downto 0)
    );
  end component spihost;

  component a_codec is
    port
    (
      iCLK          : in std_logic;
      iMUTE         : in std_logic;
      iSL           : in std_logic_vector(15 downto 0);
      iSR           : in std_logic_vector(15 downto 0);
      oAUD_XCK      : out std_logic;
      oAUD_DATA     : out std_logic;
      oAUD_LRCK     : out std_logic;
      oAUD_BCK      : out std_logic
    );
  end component a_codec;

  component i2c_av_config 
    generic
    (
      CLK_Freq	  : integer := 24000000;
      I2C_Freq	  : integer := 20000;
      LUT_SIZE	  : integer := 11;
      Dummy_DATA	: integer := 0;
      SET_LIN_L	  : integer := 1;
      SET_LIN_R	  : integer := 2;
      SET_HEAD_L	: integer := 3;
      SET_HEAD_R	: integer := 4;
      A_PATH_CTRL	: integer := 5;
      D_PATH_CTRL	: integer := 6;
      POWER_ON	  : integer := 7;
      SET_FORMAT	: integer := 8;
      SAMPLE_CTRL	: integer := 9;
      SET_ACTIVE	: integer := 10
    );
    port
    (
      iCLK          : in std_logic;
      iRST_N        : in std_logic;
      oI2C_SCLK     : out std_logic;
      oI2C_SDAT     : inout std_logic	
    );
  end component i2c_av_config;

  signal sysclk         : std_logic;
  signal locked         : std_logic;
  signal cpuclk         : std_logic;
  signal cpureset       : std_logic;
  signal cpudata_out    : std_logic_vector(15 downto 0);
  signal dtack          : std_logic;
  signal s_addr         : std_logic_vector(31 downto 0);
  signal cpudata_in     : std_logic_vector(15 downto 0);
  signal ipl            : std_logic_vector(2 downto 0);
  signal as             : std_logic;
  signal uds            : std_logic;
  signal lds            : std_logic;
  signal rw             : std_logic;
  signal dout           : std_logic_vector(15 downto 0);
  signal c_7m           : std_logic;
  signal c_28m          : std_logic;
  signal spi_cs         : std_logic_vector(7 downto 0);
  signal floppy         : std_logic_vector(15 downto 0);
  signal sdreset        : std_logic;
  signal user           : std_logic_vector(7 downto 0);
  signal ra             : std_logic_vector(19 downto 1);
  signal r0             : std_logic;
  signal r1             : std_logic;
  signal ub             : std_logic;
  signal lb             : std_logic;
  signal we             : std_logic;
  signal do_floppy      : std_logic_vector(15 downto 0);
  signal ldata          : std_logic_vector(13 downto 0);
  signal rdata          : std_logic_vector(13 downto 0);
  signal sd_wr_data     : std_logic_vector(15 downto 0);
  signal do_user        : std_logic_vector(7 downto 0);
  signal sdaddr         : std_logic_vector(12 downto 0);
  signal dqm            : std_logic_vector(3 downto 0);
  signal sd_cs          : std_logic_vector(3 downto 0);
  signal ba             : std_logic_vector(1 downto 0);
  signal zdatawr        : std_logic_vector(7 downto 0);
  signal zaddr          : std_logic_vector(23 downto 0);
  signal zwr            : std_logic;
  signal zstate         : std_logic_vector(2 downto 0);
  signal zdataout       : std_logic_vector(7 downto 0);
  signal zena_o         : std_logic;
  signal host_reset     : std_logic;
  signal links          : std_logic_vector(15 downto 0);
  signal rechts         : std_logic_vector(15 downto 0);
  signal rl             : std_logic;
  signal el             : std_logic;
  signal led            : std_logic_vector(7 downto 0);

begin

  host_reset <= sw(3) and sdreset;
  led <= (others => '0');

  -- assign output ports
  dram_cke <= '1';
  dram_addr <= sdaddr;
  dram_cs_n <= sd_cs(0);
  dram_ba_0 <= ba(0);
  dram_ba_1 <= ba(1);
  dram_ldqm <= dqm(0);
  dram_udqm <= dqm(1);
  fl_ce_n <= '1';
  fl_oe_n <= '1';
  fl_rst_n <= '1';
  fl_we_n <= '1';
  ledg <= led(7 downto 2) & el & rl;
  sram_addr <= (others => '1');
  sram_ub_n <= '1';
  sram_lb_n <= '1';
  sram_we_n <= '1';
  sram_ce_n <= '1';
  sram_oe_n <= '1';
  tdo <= '1';
  sd_dat3 <= spi_cs(1);

  BLK_AMIGACLK : block
    signal arst             : std_logic;
    signal amigaclk_locked  : std_logic;
  begin
    arst <= not sw(0);
    amigaclk_inst : amigaclk
      port map
      (
        inclk0        => clock_27(0),
        areset        => arst,
        c0            => sysclk,
        c1            => open,
        c2            => dram_clk,
        locked        => amigaclk_locked
      );
    locked <= amigaclk_locked and sw(0);
  end block BLK_AMIGACLK;

  tg68_inst : TG68
    port map
    (        
      clk           => cpuclk,
      reset         => cpureset,
      clkena_in     => '1',
      data_in       => cpudata_out,
      IPL           => ipl,
      dtack         => dtack,
      addr          => s_addr,
      data_out      => cpudata_in,
      as            => as,
      uds           => uds,
      lds           => lds,
      rw            => rw
    );

  BLK_MINIMIG1 : block
    signal exrst    : std_logic;
  begin
    exrst <= sw(2) and spi_cs(3) and sdreset;
    minimig1_inst : minimig1_pace
      port map
      (
        cpuaddress    => s_addr(23 downto 1),
        i_as          => as,
        i_uds         => uds,
        i_lds         => lds,
        r_w           => rw,
        ramdata       => dout,
        c_7m_in       => c_7m,
        c_28m         => c_28m,
        rxd           => '1',
        cts           => '1',
        i_joy1        => joya,
        i_joy2        => joyb,
        i_15khz       => sw(9),
        cpudata_in    => cpudata_in,
        floppy_ena    => spi_cs(4),
        user_ena      => spi_cs(5),
        user_clk      => spi_cs(7),
        di_floppy     => floppy,
        floppy_clk    => spi_cs(6),
        exrst         => exrst,
        di_user       => user,
        cpudata_out   => cpudata_out,
        o_ipl         => ipl,
        o_dtack       => dtack,
        o_cpureset    => cpureset,
        cpuclk        => cpuclk,
        ramaddress    => ra,
        o_ramsel0     => r0,
        o_ramsel1     => r1,
        o_ub          => ub,
        o_lb          => lb,
        o_we          => we,
        o_oe          => open,
        txd           => open,
        rts           => open,
        pwrled        => open,
        msdat         => ps2_mdat,
        msclk         => ps2_mclk,
        kbddat        => ps2_dat,
        kbdclk        => ps2_clk,
        do_floppy     => do_floppy,
        o_hsyncout    => vga_hs,
        o_vsyncout    => vga_vs,
        redout        => vga_r,
        greenout      => vga_g,
        blueout       => vga_b,
        ldata         => ldata,
        rdata         => rdata,
        sd_wr_data    => sd_wr_data,
        do_user       => do_user
      );
  end block BLK_MINIMIG1;

  sdram_inst : sdram
    port map
    (
      sdata		      => dram_dq,
      sdaddr		    => sdaddr,
      dqm			      => dqm,
      sd_cs		      => sd_cs,
      ba			      => ba,
      sd_we		      => dram_we_n,
      sd_ras		    => dram_ras_n,
      sd_cas		    => dram_cas_n,

      sysclk		    => sysclk,
      reset		      => locked,
      
      zdatawr		    => zdatawr,
      zAddr		      => zaddr(22 downto 0),
      zwr			      => zwr,
      datawr		    => sd_wr_data,
      rAddr(22)     => '0',
      rAddr(21)     => r0,
      rAddr(20)     => r1,
      rAddr(19 downto 1) => ra,
      rAddr(0)      => '0',
      rwr			      => we,
      dwrL		      => lb,
      dwrU		      => ub,
      zstate		    => zstate,
      
      dataout		    => dout,
      zdataout		  => zdataout,
      c_56m		      => open,
      zena_o		    => zena_o,
      c_28m		      => c_28m,
      c_7m		      => c_7m,
      reset_out	    => sdreset
    );

  spihost_inst : spihost
    port map
    (
      data_rd       => zdataout,
      host_clk      => c_28m,
      memwait       => zena_o,
      host_reset    => host_reset,
      sd_di         => sd_dat,
      di_floppy     => do_floppy,
      di_user       => do_user,
      sw            => key(3 downto 0),
      lin(15 downto 2) => ldata,
      lin(1 downto 0) => (others => '0'),
      rin2(15 downto 2) => rdata,
      rin2(1 downto 0) => (others => '0'),
      data_wr       => zdatawr,
      addr          => zaddr,
      mem_wr        => zwr,
      sd_cs         => spi_cs,
      sd_clk        => sd_clk,
      sd_do         => sd_cmd,
      uart_txd      => uart_txd,
      do_user       => user,
      do_floppy     => floppy,
      hex0          => hex0,
      hex1          => hex1,
      hex2          => hex2,
      hex3          => hex3,
      ledr          => ledr,
      links         => links,
      rechts        => rechts,
      romled        => rl,
      enaled        => el,
      zstate        => zstate
    );

  a_codec_inst : a_codec
    port map
    (
      iCLK          => clock_24(0),
      iMUTE         => '1',
      iSL           => links,
      iSR           => rechts,
      oAUD_XCK      => aud_xck,
      oAUD_DATA     => aud_dacdat,
      oAUD_LRCK     => aud_daclrck,
      oAUD_BCK      => aud_bclk
    );

  GEN_I2C_AV_CONFIG : if HAS_I2C_AV_CONFIG generate
    i2c_av_config_inst : i2c_av_config 
      generic map
      (
        CLK_Freq	  => 50000000,
        LUT_SIZE	  => 50
      )
      port map
      (
        iCLK          => clock_24(0),
        iRST_N        => host_reset,
        oI2C_SCLK     => i2c_sclk,
        oI2C_SDAT     => i2c_sdat
      );
  end generate GEN_I2C_AV_CONFIG;

end SYN;
