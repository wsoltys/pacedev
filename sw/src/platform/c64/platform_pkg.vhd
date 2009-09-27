library ieee;
use ieee.std_logic_1164.all;

package platform_pkg is

  --  
  -- PACE constants which *MUST* be defined
  --

  --
  -- Platform-specific constants (optional)
  --

  constant PLATFORM_SRC_DIR : string := "../../../../../src/platform/c64";
  constant ROMS_DIR         : string := PLATFORM_SRC_DIR & "/roms";

  constant NTSCMODE_PAL     : std_logic := '0';
  constant NTSCMODE_NTSC    : std_logic := '1';
  
  -- Number of tracks on disk
  constant num_tracks : integer := 84; 

  subtype track_type is integer range 0 to num_tracks;

  type sectsize_arr_type is array(natural range <>) of integer;
  
  --constant sectsize_arr : sectsize_arr_type(0 to 3) := (6250, 6666, 7142, 7692);  -- As actual disk timings
  constant sectsize_arr : sectsize_arr_type(0 to 3) := (6290, 6660, 7030, 7770);    -- As output from d64toc
  
  -- Zone 3: 1-17, Zone 2: 18-24, Zone 1: 25-30, Zone 0: 31-35
  -- Doubled to account for half tracks
  constant disk_image_limit : integer 
    := (sectsize_arr(3) * 34 + sectsize_arr(2) * 14 + sectsize_arr(1) * 12 + sectsize_arr(0) * 24) - 1;

  type mech_in_t is
    record
      wps_n : std_logic;
      data  : std_logic_vector(7 downto 0);
    end record;

  type mech_out_t is
    record
      addr : std_logic_vector(19 downto 0);
      data : std_logic_vector( 7 downto 0);
      rd   : std_logic;
      mtr  : std_logic;
      sync : std_logic;
    end record;

  type mech_dbg_t is
    record
      dbg_track    : std_logic_vector( 7 downto 0);
      dbg_offs     : std_logic_vector(13 downto 0);
      dbg_shifter  : std_logic_vector( 9 downto 0);
      dbg_synchole : std_logic;
    end record;

  type from_PLATFORM_IO_t is record
		-- IEC
		sb_data_in			: std_logic;
		sb_clk_in				: std_logic;
		sb_atn_in				: std_logic;
		sb_rst_in       : std_logic;
    -- drive mech signals
		wps_n						: std_logic;
		tr00_sense_n		: std_logic;
    fifo_wrclk      : std_logic;
    fifo_data       : std_logic_vector(7 downto 0);
    fifo_wrreq      : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
		-- IEC
		sb_data_oe			: std_logic;
		sb_clk_oe				: std_logic;
		sb_atn_oe				: std_logic;
		sb_rst_oe       : std_logic;
    -- drive mech signals
		stp_in					: std_logic;
		stp_out					: std_logic;
    fifo_wrfull     : std_logic;
    fifo_wrusedw    : std_logic_vector(7 downto 0);
    -- sound data
    snd_data        : std_logic_vector(17 downto 0);
  end record;

end;
