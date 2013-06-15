library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package antic_pkg is

	type antic_variant is
	(
		CO12296,		-- NTSC (400,800,1200XL)
		CO14887,		-- PAL/SECAM (400,800)
		CO21697,		-- NTSC (600XL,800XL,XE)
		CO21698		  -- PAL/SECAM (XL,XE)
	);

  type antic_dbg_t is record
    dmactl    : unsigned(7 downto 0);
    chactl    : unsigned(7 downto 0);
    dlistl    : unsigned(7 downto 0);
    dlisth    : unsigned(7 downto 0);
    hscrol    : unsigned(7 downto 0);
    vscrol    : unsigned(7 downto 0);
    pmbase    : unsigned(7 downto 0);
    chbase    : unsigned(7 downto 0);
    wsync     : unsigned(7 downto 0);
    nmien     : unsigned(7 downto 0);
    nmires    : unsigned(7 downto 0);
    vcount    : unsigned(7 downto 0);
    penh      : unsigned(7 downto 0);
    penv      : unsigned(7 downto 0);
    nmist     : unsigned(7 downto 0);
  end record antic_dbg_t;
  
  component antic is
    generic
    (
      VARIANT	: antic_variant
    );
    port
    (
      clk     : in std_logic;
      clk_en  : in std_logic;
      rst     : in std_logic;
      
      fphi0_i : in std_logic;
      phi0_o  : out std_logic;
      phi2_i  : in std_logic;
      res_n   : in std_logic;

      -- CPU interface
      a_i     : in std_logic_vector(15 downto 0);
      a_o     : out std_logic_vector(15 downto 0);
      d_i     : in std_logic_vector(7 downto 0);
      d_o     : out std_logic_vector(7 downto 0);
      r_wn_i  : in std_logic;
      r_wn_o  : out std_logic;
      halt_n  : out std_logic;
      rnmi_n  : in std_logic;
      nmi_n   : out std_logic;
      rdy     : out std_logic;
      
      -- CTIA/GTIA interface
      an      : out std_logic_vector(2 downto 0);

      -- light pen input
      lp_n    : in std_logic;
      -- unused (DRAM refresh)
      ref_n   : out std_logic;
      
      -- debug
      dbg     : out antic_dbg_t
    );
  end component antic;
	
  component antic_hexy is
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

      dbg       : in antic_dbg_t
    );
  end component antic_hexy;

end package antic_pkg;
