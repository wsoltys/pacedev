library IEEE;
use IEEE.std_logic_1164.all;
------------------------------------------------------------------------------
-- ENTITY DECLARATION
------------------------------------------------------------------------------
entity SRAM8MBit is
  generic (
    TimingCheckOn : boolean := true;   -- Enables timing violation reports
    -- see description of params in body of file
    -- READ-cycle timing parameters
    -- put some bad defaults, need default for modelsom to load vhdl
    tAA_max   : time := 999 ns;
    tOHA_min  : time := 999 ns;
    tACE_max  : time := 999 ns;
    tDOE_max  : time := 999 ns;
    tLZOE_min : time := 999 ns;
    tHZOE_max : time := 999 ns;
    tLZCE_min : time := 999 ns;
    tHZCE_max : time := 999 ns;
    -- WRITE-cycle timing parameters
    tWC_min   : time := 999 ns;
    tSCE_min  : time := 999 ns;
    tAW_min   : time := 999 ns;

    tHA_min   : time := 999 ns;
    tSA_min   : time := 999 ns;
    tPWE_min  : time := 999 ns;
    tSD_min   : time := 999 ns;
    tHD_min   : time := 999 ns;
    tHZWE_max : time := 999 ns;
    tLZWE_min : time := 999 ns;

    download_on_power_up    : boolean := false;
    clear_on_power_up       : boolean := false;
    download_filename: string := "nofile");

  port (
    NCE1    : in    std_logic;              -- Chip select 1, active Low
    CE2     : in    std_logic;              -- Chip select 2, active high
    NWE     : in    std_logic;              -- Write enable, active Low
    NOE     : in    std_logic;              -- Output enable
    NBHE    : in    std_logic;              -- High byte enable
    NBLE    : in    std_logic;              -- Low byte enable
    NBYTE   : in    std_logic;              -- Byte mode enable - D15 is A19
                                            -- in byte mode
    A     : in    std_logic_vector(18 downto 0);              
    D     : inout    std_logic_vector(15 downto 0));
end;

------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
------------------------------------------------------------------------------
architecture SIM of SRAM8MBit is

  component SRAM_D
    generic (
      RAM_block_size : natural;         -- block size defaults to a single
                                        -- word
      clear_on_power_up : boolean;      -- if TRUE, RAM is initialized with
                                        -- zeroes at start of simulation
                                        -- Clearing of RAM is carried out
                                        -- before download takes place
      download_on_power_up : boolean;   -- if TRUE, RAM is downloaded at start
                                        -- of simulation 
      trace_ram_load : boolean;         -- Echoes the data downloaded to
                                        -- the RAM on the screen
                                        -- (included for debugging purposes)
      enable_nWE_only_control : boolean;  -- Read-/write access controlled
                                          -- by nWE only nOE may be kept
                                          -- active all the time
      TimingCheckOn: boolean;             -- Enables timing violation reports

      -- Configuring RAM size
      size      : integer;              -- number of memory words
      adr_width : integer;              -- number of address bits
      width     : integer;              -- number of bits per memory word


      -- READ-cycle timing parameters
      tAA_max   : time;                 -- Address Access Time
      tOHA_min  : time;                 -- Output Hold Time
      tACE_max  : time;                 -- nCE/CE2 Access Time
      tDOE_max  : time;                 -- nOE Access Time
      tLZOE_min : time;                 -- nOE to Low-Z Output
      tHZOE_max : time;                 --  OE to High-Z Output
      tLZCE_min : time;                 -- nCE/CE2 to Low-Z Output
      tHZCE_max : time;                 --  CE/nCE2 to High Z Output


      -- WRITE-cycle timing parameters
      tWC_min   : time;                 -- Write Cycle Time
      tSCE_min  : time;                 -- nCE/CE2 to Write End
      tAW_min   : time;                 -- tAW Address Set-up Time to
                                        -- Write End
      tHA_min   : time;                 -- tHA Address Hold from Write End
      tSA_min   : time;                 -- Address Set-up Time
      tPWE_min  : time;                 -- nWE Pulse Width
      tSD_min   : time;                 -- Data Set-up to Write End
      tHD_min   : time;                 -- Data Hold from Write End
      tHZWE_max : time;                 -- nWE Low to High-Z Output
      tLZWE_min : time);                -- nWE High to Low-Z Output

    port (

      nCE : in std_logic;               -- low-active Chip-Enable of
                                        -- the SRAM device;
                                        -- defaults to '1' (inactive)
      nOE : in std_logic;               -- low-active Output-Enable of
                                        -- the SRAM device;
                                        -- defaults to '1' (inactive)
      nWE : in std_logic;               -- low-active Write-Enable of
                                        -- the SRAM device;
                                        -- defaults to '1' (inactive)

      A : in    std_logic_vector(adr_width-1 downto 0);  -- address bus of
                                                         -- the SRAM device
      D : inout std_logic_vector(width-1 downto 0);  -- bidirectional data bus
                                                     -- to/from the SRAM
                                                     -- device

      CE2 : in std_logic;               -- high-active Chip-Enable of
                                        -- the SRAM device;
                                        -- defaults to '1'  (active) 


      download : in boolean;            -- A FALSE-to-TRUE transition on this
                                        -- signal downloads the data
      -- from the file specified by download_filename to the RAM.

      download_filename : in string;    -- name of the download source file
      --            Passing the filename via a port of type
      -- ********** string may cause a problem with some
      -- WATCH OUT! simulators. The string signal assigned
      -- ********** to the port at least should have the
      --            same length as the default value.

      addr_start : in natural;          -- This pair of addresses specifies
                                        -- a section of the RAMs
      addr_end   : in natural;          -- address space which used for
                                        -- release_memory and dump
                                        -- (see below).

      release : in boolean;             -- A FALSE-to-TRUE transition on
      -- this signal deallocates all memory allocated by the VHDL model
      -- for RAM addresses addr_start to addr_end.

      dump : in boolean;                -- A FALSE-to-TRUE transition on
      -- this signal dumps the current contents of the RAM from addresses
      -- addr_start to addr_end to the file specified by dump_filename.

      dump_filename : IN string);  -- name of the dump destination file
                                   -- (See note at port download_filename)
  end component;

  -- Configuring RAM size for 512K x 16

  constant adr_width : integer := 19;   -- number of address bits
  constant width     : integer := 16;    -- number of bits per memory word
  constant size      : integer := 2**adr_width;  -- number of memory
                                          -- words for full adress range

  -- Signals

  signal  TA  : std_logic_vector(adr_width-1 downto 0) := (others => 'X');
  signal  TD  : std_logic_vector(width-1 downto 0) := (others => 'X');
  signal  download: boolean := FALSE;    -- A FALSE-to-TRUE transition on
                                         -- this signal downloads the data
                                         -- from the file specified by
                                         -- download_filename to the RAM.
--  signal download_filename: string(1 to 13) := "sram_load.dat";  -- name of
                                         -- the download source file
  --            Passing the filename via a port of type
  -- ********** string may cause a problem with some
  -- WATCH OUT! simulators. The string signal assigned
  -- ********** to the port at least should have the
  --            same length as the default value. 
  signal addr_start: natural := 0;     -- This pair of addresses specifies
                                       -- a section of the RAMs
  signal addr_end: natural := size-1;  -- address space which used for
                                          -- release_memory and dump
                                          -- (see below).
  signal release: boolean := FALSE;    -- A FALSE-to-TRUE transition on
                                       -- this signal deallocates
                                       -- all memory allocated by the VHDL
                                       -- model for RAM addresses addr_start
                                       -- to addr_end.
  signal dump: boolean := FALSE;       -- A FALSE-to-TRUE transition on
                                       -- this signal dumps the
                                       -- current contents of the RAM from
                                       -- addresses addr_start to addr_end to
                                       -- the file specified by dump_filename.
  signal dump_filename: string (1 to 13) := "sram_dump.dat";  -- name of the
                                       -- dump destination file
                                       -- (See note at port download_filename)

    -- Constants defining the timing of the SRAM model

  constant RAM_block_size          : natural := 1;  -- block size defaults
                                                    -- to a single word
--  constant clear_on_power_up       : boolean := false;  -- if TRUE, RAM is
                                     -- initialized with zeroes at
                                     -- start of simulation
                                     -- Clearing of RAM is carried out
                                     -- before download takes place
--  constant download_on_power_up    : boolean := false;  -- if TRUE, RAM is
                                     -- downloaded at start of simulation
  constant trace_ram_load          : boolean := false;  -- Echoes the data
                                     -- downloaded to the RAM on the screen
                                     -- (included for debugging purposes)
  constant enable_nWE_only_control : boolean := true;  -- Read-/write
                                        -- access controlled by nWE only
                                        -- nOE may be kept active all the time


------------------------------------------------------------------------------
begin

  SRAM_CORE : SRAM_D                      -- Instantiate SRAM component
    generic map (
      RAM_block_size          => RAM_block_size,
      clear_on_power_up       => clear_on_power_up,
      download_on_power_up    => download_on_power_up,
      trace_ram_load          => trace_ram_load,
      enable_nWE_only_control => enable_nWE_only_control,
      TimingCheckOn           => TimingCheckOn,
      size                    => size,
      adr_width               => adr_width,
      width                   => width,
      tAA_max                 => tAA_max,
      tOHA_min                => tOHA_min,
      tACE_max                => tACE_max,
      tDOE_max                => tDOE_max,
      tLZOE_min               => tLZOE_min,
      tHZOE_max               => tHZOE_max,
      tLZCE_min               => tLZCE_min,
      tHZCE_max               => tHZCE_max,
      tWC_min                 => tWC_min,
      tSCE_min                => tSCE_min,
      tAW_min                 => tAW_min,
      tHA_min                 => tHA_min,
      tSA_min                 => tSA_min,
      tPWE_min                => tPWE_min,
      tSD_min                 => tSD_min,
      tHD_min                 => tHD_min,
      tHZWE_max               => tHZWE_max,
      tLZWE_min               => tLZWE_min)
    port map (
      NCE                     => NCE1,
      CE2                     => CE2,
      NOE                     => NOE,
      NWE                     => NWE,
      A                   => A,
      D                   => D,
      download                => download,
      download_filename       => download_filename,
      addr_start              => addr_start,
      addr_end                => addr_end,
      release                 => release,
      dump                    => dump,
      dump_filename           => dump_filename
      );

  -- Process to check some extra design rules regarding byte modes
  PROCESS(NBYTE, NWE, NBHE, NBLE)
   BEGIN    
     IF (NCE1 = '0' AND CE2 = '1') THEN
       ASSERT (NBYTE = '1') 
         REPORT "SRAM model does not currently support byte mode."
         SEVERITY ERROR;
  
       IF (NWE = '0') THEN
         ASSERT (NBHE = '0') AND (NBLE = '0')
           REPORT "One or more byte enables de-asserted during write.  Not supported by SRAM model."
           SEVERITY ERROR;
        END IF;
      
       ASSERT (NBHE = '0') AND (NBLE = '0')
         REPORT "Byte enables should be tied low at all times for correct operation."
         SEVERITY WARNING;
     END IF;
  END PROCESS;
  
------------------------------------------------------------------------------
end SIM;
