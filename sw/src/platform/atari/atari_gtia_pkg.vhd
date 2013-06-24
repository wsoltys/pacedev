library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package atari_gtia_pkg is

	type atari_gtia_variant is
	(
		CO14889,		-- PAL
		CO14805,		-- NTSC
		CO20120 		-- SECAM
	);

  type gtia_dbg_t is record
    unused    : unsigned(7 downto 0);
  end record gtia_dbg_t;
  
  component atari_gtia is
    generic
    (
      VARIANT	: atari_gtia_variant
    );
    port
    (
      clk     : in std_logic;
      clk_en  : in std_logic;
      rst     : in std_logic;

      osc     : in std_logic;
      phi2_i  : in std_logic;
      fphi0_o : out std_logic;

      -- CPU interface
      a       : in std_logic_vector(4 downto 0);
      d_i     : in std_logic_vector(7 downto 0);
      d_o     : out std_logic_vector(7 downto 0);
      cs_n    : in std_logic;
      r_wn    : in std_logic;
      halt_n  : out std_logic;
      
      -- CTIA/GTIA interface
      an      : in std_logic_vector(2 downto 0);

      -- joystick
      t       : in std_logic_vector(3 downto 0);
      -- console
      s_i     : in std_logic_vector(3 downto 0);
      s_o     : out std_logic_vector(3 downto 0);
      
      -- video inputs
      cad3    : in std_logic;
      pal     : in std_logic;
      
      -- RGB output
      clk_vga : in std_logic;
      r       : out std_logic_vector(7 downto 0);
      g       : out std_logic_vector(7 downto 0);
      b       : out std_logic_vector(7 downto 0);
      hsync   : out std_logic;
      vsync   : out std_logic;
      de      : out std_logic;
      
      -- debug
      dbg     : out gtia_dbg_t
    );
  end component atari_gtia;
	
  component atari_gtia_hexy is
    generic 
    (
      yOffset : integer := 100;
      xOffset : integer := 100
    );
    port 
    (
      clk       : in std_logic;
      clk_ena   : in std_logic;
      vSync     : in std_logic;
      hSync     : in std_logic;
      video     : out std_logic;
      dim       : out std_logic;

      dbg       : in gtia_dbg_t
    );
  end component atari_gtia_hexy;

end package atari_gtia_pkg;
