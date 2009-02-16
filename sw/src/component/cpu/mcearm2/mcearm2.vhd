library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mce_arm2 is
  port
  (
    -- system signals
    clk_i         : in std_logic;
    reset_i       : in std_logic;

    -- clocks
    ph1_ena       : in std_logic;
    ph2_ena       : in std_logic;

    rn_w          : out std_logic;
    opc_n         : out std_logic;
    mreq_n        : out std_logic;
    abort         : in std_logic;
    irq_n         : in std_logic;
    fiq_n         : in std_logic;
    reset         : in std_logic;
    trans_n       : out std_logic;
    m_n           : out std_logic(1 downto 0);
    seq           : out std_logic;
    ale           : in std_logic;
    a             : out std_logic_vector(25 downto 0);
    --a_oe          : out std_logic;
    abe           : in std_logic;
    d_i           : in std_logic_vector(31 downto 0);
    d_o           : out std_logic_vector(31 downto 0);
    dbe           : in std_logic;
    bn_w          : out std_logic;
    cpi_n         : out std_logic;
    cpb           : in std_logic;
    cpa           : in std_logic
  );
end entity mce_arm2;

architecture SYN of mce_arm2 is
begin
end architecture mce_arm2;
