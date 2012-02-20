library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity avalon_slave_conduit is 
  generic
  (
    WIDTH_AD                  : natural := 10;
    WIDTH                     : natural := 8
  );
  port
  (
    csi_clockreset_clk        : in std_logic;
    csi_clockreset_reset      : in std_logic;
    
    -- NIOS interface
    avs_s1_chipselect         : in std_logic;
    avs_s1_address            : in std_logic_vector(WIDTH_AD-1 downto 0);
    avs_s1_readdata           : out std_logic_vector(WIDTH-1 downto 0);
    avs_s1_writedata          : in std_logic_vector(WIDTH-1 downto 0);
    avs_s1_read               : in std_logic;
    avs_s1_write              : in std_logic;
    avs_s1_waitrequest        : out std_logic;
        
    -- conduit interface
    coe_s2_clk                : out std_logic;
    coe_s2_reset              : out std_logic;
    coe_s2_chipselect         : out std_logic;
    coe_s2_address            : out std_logic_vector(WIDTH_AD-1 downto 0);
    coe_s2_readdata           : in std_logic_vector(WIDTH-1 downto 0);
    coe_s2_writedata          : out std_logic_vector(WIDTH-1 downto 0);
    coe_s2_read               : out std_logic;
    coe_s2_write              : out std_logic;
    coe_s2_waitrequest        : in std_logic
  );
end entity avalon_slave_conduit;

architecture SYN of avalon_slave_conduit is

begin

    coe_s2_clk                <= csi_clockreset_clk;
    coe_s2_reset              <= csi_clockreset_reset;
    coe_s2_chipselect         <= avs_s1_chipselect;
    coe_s2_address            <= avs_s1_address;
    avs_s1_readdata           <= coe_s2_readdata;
    coe_s2_writedata          <= avs_s1_writedata;
    coe_s2_read               <= avs_s1_read;
    coe_s2_write              <= avs_s1_write;
    avs_s1_waitrequest        <= coe_s2_waitrequest;

end architecture SYN;
