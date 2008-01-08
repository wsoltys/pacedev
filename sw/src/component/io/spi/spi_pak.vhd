library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;

package spi_pak is

  constant SPI_SS_NB : positive := 8;
  
component spi_top is
  port
    (
      wb_clk_i    : in std_logic;                                 -- master clock input
      wb_rst_i    : in std_logic;                                 -- synchronous active high reset
      wb_adr_i    : in std_logic_vector(4 downto 0);              -- lower address bits
      wb_dat_i    : in std_logic_vector(31 downto 0);             -- databus input
      wb_dat_o    : out std_logic_vector(31 downto 0);            -- databus output
      wb_sel_i    : in std_logic_vector(3 downto 0);              -- byte select inputs
      wb_we_i     : in std_logic;                                 -- write enable input
      wb_stb_i    : in std_logic;                                 -- stobe/core select signal
      wb_cyc_i    : in std_logic;                                 -- valid bus cycle input
      wb_ack_o    : out std_logic;                                -- bus cycle acknowledge output
      wb_err_o    : out std_logic;                                -- termination w/ error
      wb_int_o    : out std_logic;                                -- interrupt request signal output
    
      -- SPI signals
      ss_pad_o    : out std_logic_vector(SPI_SS_NB-1 downto 0);   -- slave select
      sclk_pad_o  : out std_logic;                                -- serial clock
      mosi_pad_o  : out std_logic;                                -- master out slave in
      miso_pad_i  : in std_logic                                  -- master in slave out
    );
end component;

end spi_pak;

