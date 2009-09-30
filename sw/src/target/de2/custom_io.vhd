library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity custom_io is
  port
  (
    -- GPIO 0 connector
    gpio_0_i          : in std_logic_vector(35 downto 0);
    gpio_0_o          : out std_logic_vector(35 downto 0);
    gpio_0_oe         : out std_logic_vector(35 downto 0);
    gpio_0_is_custom  : out std_logic_vector(35 downto 0);
    
    -- GPIO 1 connector
    gpio_1_i          : in std_logic_vector(35 downto 0);
    gpio_1_o          : out std_logic_vector(35 downto 0);
    gpio_1_oe         : out std_logic_vector(35 downto 0);
    gpio_1_is_custom  : out std_logic_vector(35 downto 0);

    -- 7-segment display
    seg7              : out std_logic_vector(31 downto 0);
    
    project_i       : out from_PROJECT_IO_t;
    project_o       : in to_PROJECT_IO_t;
    platform_i      : out from_PLATFORM_IO_t;
    platform_o      : in to_PLATFORM_IO_t;
    target_i        : out from_TARGET_IO_t;
    target_o        : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

begin

  gpio_0_is_custom <= (others => '0');
  gpio_1_is_custom <= (others => '0');

end architecture SYN;
