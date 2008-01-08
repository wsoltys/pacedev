library ieee;
use ieee.std_logic_1164.all;

package platform_pkg is

  -- debug build options
  constant BUILD_TEST_VGA_ONLY    : boolean := false;
  
  -- CoCo build options
  constant EXTENDED_COLOR_BASIC   : boolean := true;

  -- depends on build or simulation
  constant COCO1_SOURCE_ROOT_DIR  : string;

end;
