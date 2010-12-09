library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- the OCIDE controller uses UNSIGNED from here
--use ieee.std_logic_arith.unsigned;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity custom_io is
  port
  (
    -- compact flash
    iordy0_cf         : in std_logic;
    rdy_irq_cf        : in std_logic;
    cd_cf             : in std_logic;
    a_cf              : out std_logic_vector(2 downto 0);
    nce_cf            : out std_logic_vector(2 downto 1);
    d_cf              : inout std_logic_vector(15 downto 0);
    nior0_cf          : out std_logic;
    niow0_cf          : out std_logic;
    non_cf            : out std_logic;
    nreset_cf         : out std_logic;
    ndmack_cf         : out std_logic;
    dmarq_cf          : in std_logic;
    
    project_i         : out from_PROJECT_IO_t;
    project_o         : in to_PROJECT_IO_t;
    platform_i        : out from_PLATFORM_IO_t;
    platform_o        : in to_PLATFORM_IO_t;
    target_i          : out from_TARGET_IO_t;
    target_o          : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

begin

  platform_i.iordy0_cf <= iordy0_cf;
  platform_i.rdy_irq_cf <= rdy_irq_cf;
  platform_i.cd_cf <= cd_cf;
  a_cf <= platform_o.a_cf;
  nce_cf <= platform_o.nce_cf;
  nior0_cf <= platform_o.nior0_cf;
  niow0_cf <= platform_o.niow0_cf;
  non_cf <= platform_o.non_cf;
  nreset_cf <= platform_o.nreset_cf;
  ndmack_cf <= platform_o.ndmack_cf;
  platform_i.dmarq_cf <= dmarq_cf;

  -- data bus drivers
  platform_i.dd_i <= d_cf;
  d_cf <= platform_o.dd_o when platform_o.dd_oe = '1' else (others => 'Z');
  
end architecture SYN;
