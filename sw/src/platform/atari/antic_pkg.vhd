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

  component antic is
    generic
    (
      VARIANT	: antic_variant
    );
    port
    (
      clk     : in std_logic;
      clk_en  : in std_logic;
      
      fphi0_i : in std_logic;
      phi0_o  : out std_logic;
      phi2_i  : in std_logic;
      rst     : in std_logic;

      -- CPU interface
      a_i     : in std_logic_vector(15 downto 0);
      a_o     : out std_logic_vector(15 downto 0);
      d_i     : in std_logic_vector(7 downto 0);
      d_o     : out std_logic_vector(7 downto 0);
      r_wn    : out std_logic;
      halt    : out std_logic;
      rnmi    : in std_logic;
      nmi     : out std_logic;
      rdy     : out std_logic;
      
      -- CTIA/GTIA interface
      an      : out std_logic_vector(2 downto 0);

      -- light pen input
      lp      : in std_logic;
      -- unused (DRAM refresh)
      ref     : out std_logic
    );
  end component antic;
	
end package antic_pkg;
