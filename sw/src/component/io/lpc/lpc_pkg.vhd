library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package lpc_pkg is

  -- from wb_lpc_defines.v
  --`define WB_TGA_MEM      2'b00               // Memory Cycle
  --`define WB_TGA_IO       2'b01               // I/O Cycle
  --`define WB_TGA_FW       2'b10               // Firmware Cycle
  --`define WB_TGA_DMA      2'b11               // DMA Cycle
  constant WB_TGA_MEM      : std_logic_vector(1 downto 0) := "00";
  constant WB_TGA_IO       : std_logic_vector(1 downto 0) := "01";
  constant WB_TGA_FW       : std_logic_vector(1 downto 0) := "10";
  constant WB_TGA_DMA      : std_logic_vector(1 downto 0) := "11";
  
  component wb_lpc_periph is
    port
    (
      clk_i       : in std_logic;
      nrst_i      : in std_logic;
      wbm_adr_o   : out std_logic_vector(31 downto 0);
      wbm_dat_o   : out std_logic_vector(31 downto 0);
      wbm_dat_i   : in std_logic_vector(31 downto 0);
      wbm_sel_o   : out std_logic_vector(3 downto 0);
      wbm_tga_o   : out std_logic_vector(1 downto 0);
      wbm_we_o    : out std_logic;
      wbm_stb_o   : out std_logic;
      wbm_cyc_o   : out std_logic;
      wbm_ack_i   : in std_logic;
      wbm_err_i   : in std_logic;
      dma_chan_o  : out std_logic_vector(2 downto 0);
      dma_tc_o    : out std_logic;
      lframe_i    : in std_logic;
      lad_i       : in std_logic_vector(3 downto 0);
      lad_o       : out std_logic_vector(3 downto 0);
      lad_oe      : out std_logic
    );
  end component wb_lpc_periph;

  component serirq_slave is
    port
    (
      clk_i       : in std_logic;
      nrst_i      : in std_logic;
      irq_i       : in std_logic_vector(31 downto 0);
      
      serirq_i    : in std_logic;
      serirq_o    : out std_logic;
      serirq_oe   : out std_logic
    );
  end component serirq_slave;
  
end package lpc_pkg;
