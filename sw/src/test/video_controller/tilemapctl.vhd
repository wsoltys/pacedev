library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

entity tilemapCtl_1 is          
port               
(
    clk         : in std_logic;
		reset				: in std_logic;

		-- video control signals		
		stb         : in std_logic;
    hblank      : in std_logic;
    vblank      : in std_logic;
    x           : in std_logic_vector(10 downto 0);
    y           : in std_logic_vector(10 downto 0);

		scroll_data		: in std_logic_vector(7 downto 0);
		palette_data	: in ByteArrayType(15 downto 0);

    -- tilemap interface
    tilemap_d   : in std_logic_vector(15 downto 0);
    tilemap_a   : out std_logic_vector(15 downto 0);
    tile_d      : in std_logic_vector(7 downto 0);
    tile_a      : out std_logic_vector(15 downto 0);
    attr_d      : in std_logic_vector(15 downto 0);
    attr_a      : out std_logic_vector(9 downto 0);

		-- RGB output (10-bits each)
		rgb					: out RGB_t;
		tilemap_on	: out std_logic
);
end tilemapCtl_1;

use work.all;

-- Modelsim appears to be ignoring this!!!
-- workaround: (re)compile the desired tilemap controller

configuration SIM_CFG of graphics is
	for SYN
		for GEN_TILEMAP_1
			for foreground_mapctl_inst : tilemapCtl_1
				--use entity work.tilemapCtl_1(GALAXIAN);
				use entity work.tilemapCtl_1(TRS80_M3);
			end for;
		end for;
	end for;
end configuration SIM_CFG;
