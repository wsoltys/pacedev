library ieee;
use ieee.std_logic_1164.all;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

package body project_pkg is

  function IS_SUPPORTED return boolean is
  begin
    report PACE_PLATFORM_NAME & " is not currently supported on " & 
            PACE_TARGET_NAME & " hardware"
      severity failure;
    return false;
  end function IS_SUPPORTED;

  constant NOT_SUPPORTED : boolean := IS_SUPPORTED;

end package body project_pkg;

