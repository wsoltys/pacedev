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
    project_i         : in from_PROJECT_IO_t;
    project_o         : out to_PROJECT_IO_t;
    platform_i        : in from_PLATFORM_IO_t;
    platform_o        : out to_PLATFORM_IO_t;
    target_i          : in from_TARGET_IO_t;
    target_o          : out to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

begin

end architecture SYN;
