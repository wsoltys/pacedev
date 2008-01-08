library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.project_pkg.all;
use work.target_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	--
	-- Platform-specific constants (optional)
	--

  constant PLATFORM_SRC_DIR    : string := "..";

	-- Number of tracks on disk
  constant num_tracks : integer := 84; 

	subtype track_type is integer range 1 to num_tracks;
	
	type sectsize_arr_type is array(natural range <>) of integer;
	
	--constant sectsize_arr : sectsize_arr_type(0 to 3) := (6250, 6666, 7142, 7692);	-- As actual disk timings
	constant sectsize_arr : sectsize_arr_type(0 to 3) := (6290, 6660, 7030, 7770);		-- As output from d64toc
	
	-- Zone 3: 1-17, Zone 2: 18-24, Zone 1: 25-30, Zone 0: 31-35
	-- Doubled to account for half tracks
	constant disk_image_limit : integer 
		:= (sectsize_arr(3) * 34 + sectsize_arr(2) * 14 + sectsize_arr(1) * 12 + sectsize_arr(0) * 24) - 1;

end;
