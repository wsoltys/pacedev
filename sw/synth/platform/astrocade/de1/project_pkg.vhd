library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.PACEVideoController_t;
use work.video_controller_pkg.PACE_VIDEO_NONE;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  constant PACE_HAS_PLL                     : boolean := false;
  --constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;
  
  -- Reference clock is 50MHz
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 1; -- not used
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 1; -- not used
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 1; -- not used
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 1; -- not used
                                            
	-- Astrocade-specific constants           
	constant ASTROCADE_HAS_CART							  : boolean := true;
	constant ASTROCADE_CART_NAME						  : string := "muncher";
	--constant ASTROCADE_CART_NAME					  	: string := "treasure";

  constant ASTROCADE_CART_IN_FLASH          : boolean := true;

  -- (derive)
  constant PACE_HAS_FLASH                   : boolean := ASTROCADE_CART_IN_FLASH;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
