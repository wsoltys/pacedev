--------------------------------------------------------------------------------
-- SubModule FDC_1793
-- Created   19/08/2005 1:41:15 PM
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity FDC_1793 is 
	port
   (
     clk            : in    std_logic;
     uPclk          : in    std_logic;
     reset          : in    std_logic;

     fdcaddr        : in    std_logic_vector(2 downto 0);
     fdcdatai       : in    std_logic_vector(7 downto 0);
     fdcdatao       : out   std_logic_vector(7 downto 0);
     fdc_rd         : in    std_logic;
     fdc_wr         : in    std_logic;
     fdc_drq_int    : out   std_logic;
     fdc_dto_int		: out   std_logic;

     spi_clk        : out   std_logic;
     spi_ena        : out   std_logic;
     spi_mode       : out   std_logic;
     spi_sel        : out   std_logic;
     spi_din        : in    std_logic;
     spi_dout       : out   std_logic;

     ser_rx         : in    std_logic;
     ser_tx         : out   std_logic;

     debug          : out   std_logic_vector(7 downto 0)
   );
end FDC_1793;

architecture SYN of FDC_1793 is

-- Component Declarations

  component FDC_regs is 
  	port
      (
        clk             : in  std_logic;
        reset           : in  std_logic;
  
        -- CPU interface
        fdc_addr        : in  std_logic_vector(2 downto 0);
        fdc_datai       : in  std_logic_vector(7 downto 0);
        fdc_datao       : out std_logic_vector(7 downto 0);
        fdc_rd          : in  std_logic;
        fdc_wr          : in  std_logic;
  
         -- input signa ls
        not_ready       : in  std_logic;
        wp              : in  std_logic;
        hd_loaded       : in  std_logic;
        seek_err        : in  std_logic;
        crc_err         : in  std_logic;
        trk_0           : in  std_logic;
        idx_pulse       : in  std_logic;
        busy            : in  std_logic;
        rnf             : in  std_logic;
        lost_data       : in  std_logic;
        drq             : in  std_logic;
        rec_type        : in  std_logic_vector(1 downto 0);
        wr_fault        : in  std_logic;
  
        data_i          : in  std_logic_vector(7 downto 0);
        data_i_stb      : in  std_logic;
      
        -- output signals
        command         : out std_logic_vector(7 downto 0);
        drive           : out std_logic_vector(1 downto 0);
        track           : out std_logic_vector(7 downto 0);
        sector          : out std_logic_vector(7 downto 0);
        data_o          : out std_logic_vector(7 downto 0);
  
        cmd_wr_stb      : out std_logic;
        data_rd_stb     : out std_logic;
        data_wr_stb     : out std_logic
    );
  end component;

  component FDC_ctl is 
  	port
      (
        clk            : in   std_logic;
        reset          : in   std_logic;
        
        -- input signals
        command         : in std_logic_vector(7 downto 0);
				drive						: in std_logic_vector(1 downto 0);
        track           : in std_logic_vector(7 downto 0);
        sector          : in std_logic_vector(7 downto 0);
        data_i          : in std_logic_vector(7 downto 0);
  
        cmd_wr_stb      : in std_logic;
        data_rd_stb     : in std_logic;
        data_wr_stb     : in std_logic;
  
        -- output signals
        not_ready       : out std_logic;
        wp              : out std_logic;
        hd_loaded       : out std_logic;
        seek_err        : out std_logic;
        crc_err         : out std_logic;
        trk_0           : out std_logic;
        idx_pulse       : out std_logic;
        busy            : out std_logic;
        rnf             : out std_logic;
        lost_data       : out std_logic;
        drq             : out std_logic;
        rec_type        : out std_logic_vector(1 downto 0);
        wr_fault        : out std_logic;
  
        data_o          : out std_logic_vector(7 downto 0);
        data_o_stb      : out std_logic;
        intreq          : out std_logic;

        -- SPI signals
        spi_clk        : out   std_logic;
        spi_ena        : out   std_logic;
        spi_mode       : out   std_logic;
        spi_sel        : out   std_logic;
        spi_din        : in    std_logic;
        spi_dout       : out   std_logic;
        
        debug           : out std_logic_vector(7 downto 0)
     );
  end component;

-- Signal Declarations
signal intreq_s     : std_logic;

-- control status signals
signal not_ready    : std_logic;
signal wp           : std_logic;
signal hd_loaded    : std_logic;
signal seek_err     : std_logic;
signal crc_err      : std_logic;
signal trk_0        : std_logic;
signal idx_pulse    : std_logic;
signal busy         : std_logic;
signal rnf          : std_logic;
signal lost_data    : std_logic;
signal drq          : std_logic;
signal rec_type     : std_logic_vector(1 downto 0);
signal wr_fault     : std_logic;

signal cmd_wr_stb   : std_logic;
signal data_rd_stb  : std_logic;
signal data_wr_stb  : std_logic;

-- register signals
signal command      : std_logic_vector(7 downto 0);
signal drive        : std_logic_vector(1 downto 0);
signal track        : std_logic_vector(7 downto 0);
signal sector       : std_logic_vector(7 downto 0);
signal disk_rd_data : std_logic_vector(7 downto 0);
signal disk_rd_stb  : std_logic;
signal disk_wr_data : std_logic_vector(7 downto 0);

begin

  -- need to stretch intreq to a cpu clock cycle
  process (clk, reset)
    variable intreq_v : std_logic;
    variable count_v  : integer range 0 to 10;
  begin
    if reset = '1' then
      intreq_v := '0';
    elsif rising_edge(clk) then
      if intreq_v = '0' and intreq_s = '1' then
        intreq_v := '1';
        count_v := 10;
      elsif intreq_v = '1' then
        if count_v = 0 then
          intreq_v := '0';
        else
          count_v := count_v - 1;
        end if;
      end if;
    end if;
    fdc_drq_int <= intreq_v;
    fdc_dto_int <= '0';
  end process;
    
  -- not used atm
  ser_tx <= '0';

  -- component instantiations

  fdc_regs_inst : FDC_regs
    port map
      (
        clk             => clk,
        reset           => reset,
     
        fdc_addr        => fdcaddr,
        fdc_datai       => fdcdatai,
        fdc_datao       => fdcdatao,
        fdc_rd          => fdc_rd,
        fdc_wr          => fdc_wr,
  
        -- input signals
        not_ready       => not_ready,
        wp              => wp,
        hd_loaded       => hd_loaded,
        seek_err        => seek_err, 
        crc_err         => crc_err,  
        trk_0           => trk_0,    
        idx_pulse       => idx_pulse,
        busy            => busy,     
        rnf             => rnf,      
        lost_data       => lost_data,
        drq             => drq,      
        rec_type        => rec_type, 
        wr_fault        => wr_fault, 
        
        data_i          => disk_rd_data,
        data_i_stb      => disk_rd_stb,
  
        -- output signals
        command         => command,
        drive           => drive,
        track           => track,
        sector          => sector,
        data_o          => disk_wr_data,
        
        cmd_wr_stb      => cmd_wr_stb,
        data_rd_stb     => data_rd_stb,
        data_wr_stb     => data_wr_stb
      );

  fdc_ctl_inst : FDC_ctl
  	port map
      (
        clk             => clk,
        reset           => reset,
        
        -- input signals
        command         => command,
        drive           => drive,
        track           => track,
        sector          => sector,
        data_i          => disk_wr_data,
  
        cmd_wr_stb      => cmd_wr_stb,
        data_rd_stb     => data_rd_stb,
        data_wr_stb     => data_wr_stb,
  
        -- output signals
        not_ready       => not_ready,
        wp              => wp,
        hd_loaded       => hd_loaded,
        seek_err        => seek_err,
        crc_err         => crc_err,
        trk_0           => trk_0,
        idx_pulse       => idx_pulse,
        busy            => busy,
        rnf             => rnf,
        lost_data       => lost_data,
        drq             => drq,
        rec_type        => rec_type,
        wr_fault        => wr_fault,
  
        data_o          => disk_rd_data,
        data_o_stb      => disk_rd_stb,
        intreq          => intreq_s,

        -- SPI signals
        spi_clk     => spi_clk,
        spi_ena     => spi_ena,
        spi_mode    => spi_mode,
        spi_sel     => spi_sel,
        spi_din     => spi_din,
        spi_dout    => spi_dout,
      
        debug       => debug
     );
        
end SYN;
