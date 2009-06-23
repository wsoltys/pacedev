library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package sdram_pkg is

  component yadmc
    generic
    (
      sdram_depth         : natural := 25;
      sdram_columndepth   : natural := 9;
      sdram_adrwires      : natural := 13;
      sdram_bytes_depth   : natural := 1;
      cache_depth         : natural := 10;
      --sdram_bits          : natural := (8 << sdram_bytes_depth);
      sdram_bits          : natural;
      --cache_linedepth     : natural := sdram_bytes_depth + 1;
      cache_linedepth     : natural;
      --cache_linelength    : natural := (4 << cache_linedepth);
      cache_linelength    : natural;
      --cache_tagdepth      : natural := sdram_depth - cache_depth - cache_linedepth - 2
      cache_tagdepth      : natural
    );
    port
    (
      -- debug
      state         : out std_logic_vector(1 downto 0);
      statey        : out std_logic_vector(4 downto 0);
      
      -- WISHBONE interface
      sys_clk       : in std_logic;
      sys_rst       : in std_logic;
      wb_adr_i      : in std_logic_vector(31 downto 0);
      wb_dat_i      : in std_logic_vector(31 downto 0);
      wb_dat_o      : out std_logic_vector(31 downto 0);
      wb_sel_i      : in std_logic_vector(3 downto 0);
      wb_cyc_i      : in std_logic;
      wb_stb_i      : in std_logic;
      wb_we_i       : in std_logic;
      wb_ack_o      : out std_logic;

      -- SDRAM interface
      sdram_clk     : in std_logic;
      sdram_cke     : out std_logic;
      sdram_cs_n    : out std_logic;
      sdram_we_n    : out std_logic;
      sdram_cas_n   : out std_logic;
      sdram_ras_n   : out std_logic;
      sdram_dqm     : out std_logic_vector((sdram_bits/8)-1 downto 0);
      sdram_adr     : out std_logic_vector(sdram_adrwires-1 downto 0);
      sdram_ba      : out std_logic_vector(1 downto 0);
      sdram_dq      : inout std_logic_vector(sdram_bits-1 downto 0)
    );
  end component yadmc;
  
  -- Types

	type from_SDRAM_t is record
		d					: std_logic_vector(31 downto 0);
		ack       : std_logic;
	end record;
	
	type to_SDRAM_t is record
    clk       : std_logic;
    rst       : std_logic;
		a					: std_logic_vector(31 downto 0);
		d					: std_logic_vector(31 downto 0);
		sel			  : std_logic_vector(3 downto 0);
		cyc			  : std_logic;
		stb			  : std_logic;
		we				: std_logic;
	end record;

end;
