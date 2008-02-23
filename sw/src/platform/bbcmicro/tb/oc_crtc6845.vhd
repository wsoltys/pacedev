--===========================================================================--
--                                                                           --
--  S Y N T H E S I Z A B L E    CRTC6845   C O R E                          --
--                                                                           --
--  www.opencores.org - January 2000                                         --
--  This IP core adheres to the GNU public license.                          --
--                                                                           --
--  VHDL model of MC6845 compatible CRTC                                     --
--                                                                           --
--  This model doesn't implement interlace mode. Everything else is          --
--  (probably) according to original MC6845 data sheet (except VTOTADJ).     --
--                                                                           --
--  Implementation in Xilinx Virtex XCV50-6 runs at 50 MHz (character clock).--
--  With external pixel	generator this CRTC could handle 450MHz pixel rate   --
--  (see MC6845 datasheet for typical application).	                     --
--                                                                           --
--  Author: Damjan Lampret, lampret@opencores.org                            --
--                                                                           --
--  TO DO:                                                                   --
--                                                                           --
--   - fix REG_INIT and remove non standard signals at topl level entity.    --
--     Allow fixed registers values (now set with REG_INIT). Anyway cleanup  --
--     required.                                                             --
--                                                                           --
--   - split design in four units (horizontal sync, vertical sync, bus       --
--     interface and the rest)                                               --
--                                                                           --
--   - synthesis with Synplify pending (there are some problems with         --
--     UNSIGNED and BIT_LOGIC_VECTOR types in some units !)                  --
--                                                                           --
--   - testbench                                                             --
--                                                                           --
--   - interlace mode support, extend VSYNC for V.Total Adjust value (R5)    --
--                                                                           --
--   - verification in a real application                                    --
--                                                                           --
--===========================================================================--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity crtc6845 is
    generic (
  MA_WIDTH : natural := 14;
  RA_WIDTH : natural := 5;
  DB_WIDTH : natural := 8;
  AR_WIDTH : natural := 5
    );
    port (
	MA     : out STD_LOGIC_VECTOR (MA_WIDTH-1 downto 0);
	RA     : out STD_LOGIC_VECTOR (RA_WIDTH-1 downto 0);
	HSYNC  : out STD_LOGIC;
	VSYNC  : out STD_LOGIC;
	DE     : out STD_LOGIC;
	CURSOR : out STD_LOGIC;
	LPSTBn : in STD_LOGIC;
	E      : in STD_LOGIC;
	RS     : in STD_LOGIC;
	CSn    : in STD_LOGIC;
	RW     : in STD_LOGIC;
	DI     : in STD_LOGIC_VECTOR (DB_WIDTH-1 downto 0);
	DO     : out STD_LOGIC_VECTOR (DB_WIDTH-1 downto 0);
	RESETn : in STD_LOGIC;
	CLK    : in STD_LOGIC;
	-- not standard
	REG_INIT: in STD_LOGIC;
	--
	Hend: inout STD_LOGIC;
	HS: inout STD_LOGIC;
	CHROW_CLK: inout STD_LOGIC;
	Vend: inout STD_LOGIC;
	SLadj: inout STD_LOGIC;
	H: inout STD_LOGIC;
	V: inout STD_LOGIC;
	CURSOR_ACTIVE: inout STD_LOGIC;
	VERT_RST: inout STD_LOGIC
    );
end crtc6845;

architecture crtc6845_behav of crtc6845 is

begin

end crtc6845_behav;
