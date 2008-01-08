-- ======================================================================================
--
--      Generic VHDL model for simulation of a SRAM with complete timing parameters
--             
--          Dynamic memory allocation,  version 0.7(+) beta    9. August 1996
--
-- ======================================================================================
--
-- (C) Andre' Klindworth, Dept. of Computer Science
--                        University of Hamburg
--                        Vogt-Koelln-Str. 30
--                        22527 Hamburg
--                        klindwor@informatik.uni-hamburg.de
--
-- This VHDL code may be freely copied as long as the copyright note isn't removed from 
-- its header. Full affiliation of anybody modifying this file shall be added to the
-- header prior to further distribution.
--
-- The download procedure has been inspired by DLX memory-behaviour.vhdl: 
--                    Copyright (C) 1993, Peter J. Ashenden
--                    Mail:       Dept. Computer Science
--                                University of Adelaide, SA 5005, Australia
--                    e-mail:     petera@cs.adelaide.edu.au
--
-- --------------------------------------------------------------------------End_of_Header
-- 
-- Features:
--
--  o  generic memory size, width and timing parameters
--
--  o  18 typical SRAM timing parameters supported
--
--  o  clear-on-power-up and/or download-on-power-up if requested by generic
--
--  o  RAM dump into or download from an ASCII-file at any time possible 
--     (requested by signal)
--   
--  o  pair of active-low and active-high Chip-Enable signals 
--
--  o  nWE-only memory access control
--
--  o  many (but not all) timing and access control violations reported by assertions
-- 
-- 
-- This model (in contrast to the static memory SRAM model at 
-- http://tech-www.informatik.uni-hamburg.de/vhdl/models/sram)
-- uses dynamic memory allocation for storage of the contents of the SRAM.
-- For this purpose, the address space of the RAM is split up in blocks of
-- RAM_block_size addresses. Whenever a write access to a RAM block takes
-- place for the first time during a simulation run, storage for that RAM block
-- is automatically allocated. This procedure allows to simulate large, but
-- sparsely used RAMs (up to 2^31 words of unlimited width) with a minimum
-- amount of storage.
-- Also provided is the port-signal release which allows to release 
-- (deallocate) blocks of memory which are no longer needed for the rest of
-- the simulation run.
-- 
--
-- RAM data file format:
--
-- The format of the ASCII-files for RAM download or dump is very simple:
-- Each line of the file consists of the memory address (given as a decimal number).
-- and the corresponding RAM data at this address (given as a binary number).
-- Any text in a line following the width-th digit of the binary number is ignored.
-- Please notice that address and data have to be seperated by a SINGLE blank,
-- that the binary number must have as many digits as specified by the generic width,
-- and that no additional blanks or blank lines are tolerated. Example:
--                
--            0 0111011010111101 This text is interpreted as a comment
--            1 1011101010110010 
--            17 0010001001000100
--
-- When all or parts of the RAM's contents is dumped to file, only those addresses
-- are written to the file which hold data that differs from the default value
-- (that is, is not the vector "UU...U" and, if the generic clear_on_power_up is
--  active, is not the all-zero vector).
--
-- Hints & traps:
--
-- If you have problems using this model, please feel free to send me an e-mail.
-- Here are some potential problems which have been reported to me so far:
--
--    o There's a potential problem with passing the filenames for RAM download or
--      dump via port signals of type string. E.g. for Synopsys VSS, the string
--      assigned to a filename-port should have the same length as its default value.
--      If you are sure that you need a download or dump only once during a single
--      simulation run, you may remove the filename-ports from the interface list
--      and replace the constant string in the corresponding file declarations.
--
--    o Some simulators do not implement all of the standard TEXTIO-functions as
--      specified by the IEEE Std 1076-87 and IEEE Std 1076-93. Check it out.
--      If any of the (multiple overloaded) writeline, write, readline or
--      read functions that are used in this model is missing, you have to
--      write your own version and you should complain at your simulator tool
--      vendor for this deviation from the standard.
--
--
-- Bugs:
--
--   No severe bugs have been found so far. Please report any bugs or comments to:
--   e-mail: klindwor@informatik.uni-hamburg.de
--
   
   

USE std.textio.all;
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.CONV_STD_LOGIC_VECTOR;
USE IEEE.std_logic_unsigned.CONV_INTEGER;
USE IEEE.std_logic_textio.all;

ENTITY sram_d IS

  GENERIC (
    RAM_block_size: NATURAL := 1;     -- block size defaults to a single word

    clear_on_power_up: boolean := FALSE;    -- if TRUE, RAM is initialized with zeroes at start of simulation
                                            -- Clearing of RAM is carried out before download takes place

    download_on_power_up: boolean := FALSE;  -- if TRUE, RAM is downloaded at start of simulation 
      
    trace_ram_load: boolean := FALSE;        -- Echoes the data downloaded to the RAM on the screen
                                            -- (included for debugging purposes)


    enable_nWE_only_control: boolean := TRUE;  -- Read-/write access controlled by nWE only
                                               -- nOE may be kept active all the time

    TimingCheckOn          : boolean := true;  -- Enables timing violation reports


    -- Configuring RAM size

    size:      INTEGER :=  8;  -- number of memory words
    adr_width: INTEGER :=  3;  -- number of address bits
    width:     INTEGER :=  8;  -- number of bits per memory word


    -- READ-cycle timing parameters

    tAA_max:    TIME := 9999 NS; -- Address Access Time
    tOHA_min:   TIME :=  3 NS; -- Output Hold Time
    tACE_max:   TIME := 20 NS; -- nCE/CE2 Access Time
    tDOE_max:   TIME :=  8 NS; -- nOE Access Time
    tLZOE_min:  TIME :=  0 NS; -- nOE to Low-Z Output
    tHZOE_max:  TIME :=  8 NS; --  OE to High-Z Output
    tLZCE_min:  TIME :=  3 NS; -- nCE/CE2 to Low-Z Output
    tHZCE_max:  TIME := 10 NS; --  CE/nCE2 to High Z Output
 

    -- WRITE-cycle timing parameters

    tWC_min:    TIME := 9999 NS; -- Write Cycle Time
    tSCE_min:   TIME := 18 NS; -- nCE/CE2 to Write End
    tAW_min:    TIME := 15 NS; -- tAW Address Set-up Time to Write End
    tHA_min:    TIME :=  0 NS; -- tHA Address Hold from Write End
    tSA_min:    TIME :=  0 NS; -- Address Set-up Time
    tPWE_min:   TIME := 13 NS; -- nWE Pulse Width
    tSD_min:    TIME := 10 NS; -- Data Set-up to Write End
    tHD_min:    TIME :=  0 NS; -- Data Hold from Write End
    tHZWE_max:  TIME := 10 NS; -- nWE Low to High-Z Output
    tLZWE_min:  TIME :=  0 NS  -- nWE High to Low-Z Output
  );

  PORT (
      
    nCE: IN std_logic := '1';  -- low-active Chip-Enable of the SRAM device; defaults to '1' (inactive)
    nOE: IN std_logic := '1';  -- low-active Output-Enable of the SRAM device; defaults to '1' (inactive)
    nWE: IN std_logic := '1';  -- low-active Write-Enable of the SRAM device; defaults to '1' (inactive)

    A:   IN std_logic_vector(adr_width-1 downto 0); -- address bus of the SRAM device
    D:   INOUT std_logic_vector(width-1 downto 0);  -- bidirectional data bus to/from the SRAM device

    CE2: IN std_logic := '1';  -- high-active Chip-Enable of the SRAM device; defaults to '1'  (active) 


    download: IN boolean := FALSE;    -- A FALSE-to-TRUE transition on this signal downloads the data
                                      -- from the file specified by download_filename to the RAM.

    download_filename: IN string := "sram_load.dat";  -- name of the download source file
                                                      --            Passing the filename via a port of type
                                                      -- ********** string may cause a problem with some
                                                      -- WATCH OUT! simulators. The string signal assigned
                                                      -- ********** to the port at least should have the
                                                      --            same length as the default value.
 
    addr_start: IN natural := 0;     -- This pair of addresses specifies a section of the RAMs
    addr_end: IN natural := size-1;  -- address space which used for release_memory and dump (see below).

    release: IN boolean := FALSE;    -- A FALSE-to-TRUE transition on this signal deallocates
                                     -- all memory allocated by the VHDL model for RAM addresses 
                                     -- addr_start to addr_end.

    dump: IN boolean := FALSE;       -- A FALSE-to-TRUE transition on this signal dumps the
                                     -- current contents of the RAM from addresses
                                     -- addr_start to addr_end to the file specified by dump_filename.

    dump_filename: IN string := "sram_dump.dat"  -- name of the dump destination file
                                                 -- (See note at port  download_filename)

  );
END sram_d;


ARCHITECTURE behavior OF sram_d IS

  FUNCTION Check_For_Valid_Data (a: std_logic_vector) RETURN BOOLEAN IS
    VARIABLE result: BOOLEAN;
   BEGIN
    --result := TRUE;
    --FOR i IN a'RANGE LOOP
    --  result := (a(i) = '0') OR (a(i) = '1');
    --  IF NOT result THEN EXIT;
    --  END IF;
    --END LOOP;
    RETURN result;
  END Check_For_Valid_Data;

  FUNCTION Check_For_Tristate (a: std_logic_vector) RETURN BOOLEAN IS
    VARIABLE result: BOOLEAN;
   BEGIN
    result := TRUE;
    FOR i IN a'RANGE LOOP
      result := (a(i) = 'Z');
      IF NOT result THEN EXIT;
      END IF;
    END LOOP;
    RETURN result;
  END Check_For_Tristate;
 
  SIGNAL tristate_vec: std_logic_vector(D'RANGE);   -- constant all-Z vector for data bus D
  SIGNAL undef_vec: std_logic_vector(D'RANGE);      -- constant all-X vector for data bus D
  SIGNAL undef_adr_vec: std_logic_vector(A'RANGE);  -- constant all-X vector for address bus

  SIGNAL read_active: BOOLEAN := FALSE;             -- Indicates whether the SRAM is sending on the D bus
  SIGNAL read_valid: BOOLEAN := FALSE;              -- If TRUE, the data output by the RAM is valid
  SIGNAL read_data: std_logic_vector(D'RANGE);      -- content of the memory location addressed by A
  SIGNAL do_write: std_logic := '0';                -- A '0'->'1' transition on this signal marks
                                                    -- the moment when the data on D is stored in the
                                                    -- addressed memory location
  SIGNAL adr_setup: std_logic_vector(A'RANGE);      -- delayed value of A to model the Address Setup Time
  SIGNAL adr_hold: std_logic_vector(A'RANGE);       -- delayed value of A to model the Address Hold Time
  SIGNAL valid_adr: std_logic_vector(A'RANGE);      -- valid memory address derived from A after
                                                    -- considering Address Setup and Hold Times
      
BEGIN


  PROCESS BEGIN                 -- static assignments to the variable length busses'
                                -- all-X and all-Z signal vectors
    FOR i IN D'RANGE LOOP
      tristate_vec(i) <= 'Z';
      undef_vec(i) <= 'X';
    END LOOP;
    FOR i IN A'RANGE LOOP
      undef_adr_vec(i) <= 'X';
    END LOOP;
    WAIT;
  END PROCESS;



  memory: PROCESS
   
    CONSTANT low_address: natural := 0;
    CONSTANT high_address: natural := size -1; 

    SUBTYPE ram_address_type IS NATURAL RANGE low_address TO high_address;
    SUBTYPE ram_word_type    IS std_logic_vector(width-1 DOWNTO 0);
    SUBTYPE ram_block_index_type IS NATURAL RANGE 0 TO ram_block_size-1;

    TYPE ram_block_type;
    TYPE ram_block_ptr_type  IS ACCESS ram_block_type;
--    TYPE ram_block_data_type IS ARRAY(0 TO ram_block_size-1) OF ram_word_type;
    TYPE ram_block_data_type IS ARRAY(ram_block_index_type) OF ram_word_type;
    TYPE ram_block_type      IS RECORD
                                  succ: ram_block_ptr_type;
                                  address: ram_address_type;
                                  data: ram_block_data_type;
                                END RECORD;

    FUNCTION get_block_address(address: IN ram_address_type) RETURN ram_address_type IS
     BEGIN
      RETURN address - (address MOD ram_block_size);
    END get_block_address;

    PROCEDURE get_block_address(address: IN ram_address_type; 
                               block_address: OUT ram_address_type;
                               local_index: OUT ram_block_index_type) IS
     
       VARIABLE loc_ind: ram_block_index_type;

     BEGIN
      loc_ind := address MOD ram_block_size;
      local_index := loc_ind;
      block_address := address - loc_ind;
    END get_block_address;


    FUNCTION create_ram_block(block_address: IN ram_address_type) RETURN ram_block_ptr_type IS

      VARIABLE ptr: ram_block_ptr_type;
      VARIABLE init_val: std_logic;

     BEGIN

      ptr := NEW ram_block_type;
      ptr.succ := NULL;
      ptr.address := block_address;

      IF clear_on_power_up
        THEN init_val := '0';
        ELSE init_val := 'U';
      END IF;
      FOR i IN ptr.data'RANGE LOOP
        FOR j IN ram_word_type'RANGE LOOP
          ptr.data(i)(j) := init_val;
        END LOOP;
      END LOOP;
      RETURN ptr;

    END create_ram_block;

 
    PROCEDURE read_ram_cell(first_block: INOUT ram_block_ptr_type; address: IN ram_address_type;
                            data: OUT ram_word_type) IS

       VARIABLE ptr: ram_block_ptr_type;
       VARIABLE block_address: ram_address_type;
       VARIABLE local_index: ram_block_index_type;
       VARIABLE init_val: std_logic;

     BEGIN
      
      get_block_address(address, block_address, local_index);
      ptr := first_block;
      IF (ptr /= NULL) THEN             -- This check was added before loop to
                                        -- avoid crashes when ModelSim tries to
                                        -- evaluate ptr.address when ptr=null
                                        -- (happens when code coverage is enabled)
        WHILE ((ptr /= NULL) AND (ptr.address < block_address)) LOOP
          ptr := ptr.succ;
          IF ptr = NULL THEN
            EXIT;
          END IF;
        END LOOP;
      END IF;
      IF (ptr = NULL) THEN  -- not found
        IF clear_on_power_up THEN
          init_val := '0';
        ELSE
          init_val := 'U';
        END IF;
        FOR i IN data'RANGE LOOP
          data(i) := init_val;
        END LOOP;
      ELSIF (ptr.address > block_address) THEN
        IF clear_on_power_up THEN
          init_val := '0';
        ELSE
          init_val := 'U';
        END IF;
        FOR i IN data'RANGE LOOP
          data(i) := init_val;
        END LOOP;
      ELSE
        data := ptr.data(local_index);
      END IF;

    END read_ram_cell;
               
   
    PROCEDURE write_ram_cell(first_block: INOUT ram_block_ptr_type; 
                             address: IN ram_address_type;
                             data: IN ram_word_type) IS

       VARIABLE ptr, prev_ptr, ptr2: ram_block_ptr_type;
       VARIABLE block_address: ram_address_type;
       VARIABLE local_index: ram_block_index_type;
       VARIABLE init_val: std_logic;

     BEGIN
      
      get_block_address(address, block_address, local_index);
      ptr := first_block; 
      prev_ptr := NULL;
      IF (ptr /= NULL) then             -- This check was added before loop to
                                        -- avoid crashes when ModelSim tries to
                                        -- evaluate ptr.address when ptr=null
                                        -- (happens when code coverage is enabled)
        WHILE ((ptr /= NULL) AND (ptr.address < block_address)) LOOP
          prev_ptr := ptr;
          ptr := ptr.succ;
          IF (ptr = NULL) THEN
            EXIT;
          END IF;
        END LOOP;
      END IF;
      IF (ptr = NULL) THEN
        ptr := create_ram_block(block_address);
        IF (prev_ptr = NULL) THEN
          first_block := ptr;
        ELSE
          prev_ptr.succ := ptr;
        END IF;
      ELSIF (ptr.address /= block_address) THEN
        ptr2 := ptr;
        ptr := create_ram_block(block_address);
        IF (prev_ptr = NULL) THEN
          first_block := ptr;
        ELSE
          prev_ptr.succ := ptr;
        END IF;
        ptr.succ := ptr2;
      END IF;
      ptr.data(local_index) := data;
     
    END write_ram_cell;


 
    PROCEDURE do_download (ram: INOUT ram_block_ptr_type; download_filename: IN string) IS

      FILE source : text IS IN download_filename;
      VARIABLE inline, outline : line;
      VARIABLE source_line_nr: integer := 1;
      VARIABLE c : character;
      VARIABLE add: ram_address_type;
      VARIABLE data: ram_word_type;

     BEGIN
      write(output, string'("Loading SRAM from file ") & download_filename & string'(" ... ") );
      WHILE NOT endfile(source) LOOP
        readline(source, inline);
        read(inline, add);
        read(inline, c); 
        IF (c /= ' ') THEN
          write(outline, string'("Syntax error in file '"));
          write(outline, download_filename);
          write(outline,  string'("', line "));
          write(outline, source_line_nr);
          writeline(output, outline);
          ASSERT FALSE
          REPORT "RAM loader aborted."
          SEVERITY ERROR;
        END IF;
        FOR i IN data'RANGE LOOP
          read(inline, c);
	  IF (c = '1') THEN
            data(i) := '1';
          ELSE
            IF (c /= '0') THEN
              write(outline, string'("-W- Invalid character '"));
              write(outline, c);
              write(outline, string'("' in Bitstring in '"));
              write(outline, download_filename);
              write(outline, '(');
              write(outline, source_line_nr);
              write(outline, string'(") is set to '0'"));
              writeline(output, outline);
            END IF;
            data(i) := '0';
          END IF;
        END LOOP;
        write_ram_cell(ram, add, data);
        IF (trace_ram_load) THEN
          write(outline, string'("RAM["));
          write(outline, add);
          write(outline, string'("] :=  "));
          write(outline, data);
          writeline(output, outline );
        END IF;
        source_line_nr := source_line_nr +1;

      END LOOP;

      write(outline, string'("Done!"));
      writeline(output, outline );

    END do_download;



    PROCEDURE do_release (ram: INOUT ram_block_ptr_type; release_start, release_end: IN natural) IS
     
      VARIABLE block_address: ram_address_type;
      VARIABLE ptr, ptr2, prev_ptr: ram_block_ptr_type;

     BEGIN
    
      IF (ram /= NULL)
        THEN ptr := ram; prev_ptr := NULL;
             block_address := get_block_address(release_start + ram_block_size-1);
             WHILE ((ptr /= NULL) AND (ptr.address < block_address)) LOOP
               prev_ptr := ptr; ptr := ptr.succ;
             END LOOP;
             block_address := get_block_address(release_end +1);
             WHILE ((ptr /= NULL) AND (ptr.address <= block_address)) LOOP
               ptr2 := ptr.succ; DEALLOCATE(ptr); ptr := ptr2;
             END LOOP; 
             IF (prev_ptr /= NULL)
               THEN prev_ptr.succ := ptr;
               ELSE ram := ptr;
             END IF;
      END IF;

    END do_release;                



    PROCEDURE do_dump (ram: INOUT ram_block_ptr_type; 
                       dump_start, dump_end: IN natural; dump_filename: IN string) IS
 
      FUNCTION initialized(data: IN ram_word_type) RETURN boolean IS
        VARIABLE erg: boolean := FALSE;
       BEGIN
        FOR i IN data'RANGE LOOP
          IF ((data(i) /= 'U') AND NOT (clear_on_power_up AND (data(i) = '0')))
            THEN erg := TRUE;
                 EXIT;
          END IF;
        END LOOP;
        RETURN erg;
      END initialized; 
        
      FILE dest : text IS OUT dump_filename;
      VARIABLE l : line;
      VARIABLE add: natural;
      VARIABLE c : character;
      VARIABLE data : ram_word_type;

     BEGIN

      IF (dump_start > dump_end)  OR (dump_end >= size) THEN
        ASSERT FALSE
        REPORT "Invalid addresses for memory dump. Cancelled."
        SEVERITY ERROR;
      ELSE
        FOR adr IN dump_start TO dump_end LOOP
          read_ram_cell(ram, adr, data);
          IF initialized(data)
            THEN write(l, adr);
                 write(l, character'(' '));
                 FOR i IN data'RANGE LOOP
                   write(l, data(i));
                 END LOOP;
                 writeline(dest, l);
          END IF;
        END LOOP;
      END IF;

    END do_dump;

  
    VARIABLE ram: ram_block_ptr_type;
    VARIABLE write_data: ram_word_type;
    VARIABLE read_data_var: ram_word_type;

   BEGIN
    IF download_on_power_up THEN 
      do_download(ram, download_filename);
    END IF;
    LOOP    
      IF do_write'EVENT and (do_write = '1') then
        IF NOT Check_For_Valid_Data(D) THEN
          IF D'EVENT AND Check_For_Valid_Data(D'DELAYED) THEN
            if TimingCheckOn then
              write(output, "-W- Data changes exactly at end-of-write to SRAM.");
            end if;
            write_data := D'delayed;
          ELSE
            if TimingCheckOn then
              write(output, "-E- Data not valid at end-of-write to SRAM.");
            end if;
            write_data := undef_vec;
          END IF;
        ELSIF NOT D'DELAYED(tHD_min)'STABLE(tSD_min) THEN
          if TimingCheckOn then
            write(output, "-E- tSD violation: Data input changes within setup-time at end-of-write to SRAM.");
          end if;
          write_data := undef_vec;
        ELSIF NOT D'STABLE(tHD_min) THEN
          if TimingCheckOn then
            write(output, "-E- tHD violation: Data input changes within hold-time at end-of-write to SRAM.");
          end if;
          write_data := undef_vec;
        ELSIF NOT nWE'DELAYED(tHD_min)'DELAYED'STABLE(tPWE_min) THEN
          if TimingCheckOn then
            write(output, "-E- tPWE violation: Pulse width of nWE too short at SRAM.");
          end if;
          write_data := undef_vec;
        ELSE write_data := D;
        END IF;
        write_ram_cell(ram, CONV_INTEGER(valid_adr), write_data);
      END IF;
      IF Check_For_Valid_Data(valid_adr) THEN
        read_ram_cell(ram, CONV_INTEGER(valid_adr), read_data_var); 
        read_data <= read_data_var;
      ELSE
        read_data <= undef_vec;
      END IF;
      IF dump AND dump'EVENT THEN do_dump(ram, addr_start, addr_end, dump_filename);
      END IF;
      IF download AND download'EVENT THEN do_download(ram, download_filename);
      END IF;
      IF release AND release'EVENT THEN do_release(ram, addr_start, addr_end);
      END IF;
      WAIT ON do_write, valid_adr, download, release, dump;
    END LOOP;

  END PROCESS memory;


  adr_setup <= TRANSPORT A AFTER tAA_max;
  adr_hold <= TRANSPORT A AFTER tOHA_min;

  valid_adr <= adr_setup WHEN     Check_For_Valid_Data(adr_setup)
                              AND (adr_setup = adr_hold) 
                              AND adr_hold'STABLE(tAA_max - tOHA_min) ELSE
               undef_adr_vec;

  read_active <=    (     (nOE = '0') AND (nOE'DELAYED(tLZOE_min) = '0') AND nOE'STABLE(tLZOE_min) 
                      AND ((nWE = '1') OR (nWE'DELAYED(tHZWE_max) = '0'))
                      AND (nCE = '0') AND (CE2 = '1') AND nCE'STABLE(tLZCE_min) AND CE2'STABLE(tLZCE_min))
                 OR (read_active AND (nOE'DELAYED(tHZOE_max) = '0') 
                                 AND (nWE'DELAYED(tHZWE_max) = '1')
                                 AND (nCE'DELAYED(tHZCE_max) = '0') AND (CE2'DELAYED(tHZCE_max) = '1'));

  read_valid <=     (     (nOE = '0') AND nOE'STABLE(tDOE_max) 
                      AND (nWE = '1') AND (nWE'DELAYED(tHZWE_max) = '1')
                      AND (nCE = '0') AND (CE2 = '1') AND nCE'STABLE(tACE_max) AND CE2'STABLE(tACE_max))
                 OR (read_valid AND read_active);

  D <= read_data WHEN read_valid and read_active ELSE
       undef_vec WHEN not read_valid and read_active ELSE
       tristate_vec;

       
  PROCESS (nWE, nCE, CE2) 
   BEGIN
    IF      ((nCE = '1') OR (nWE = '1') OR (CE2 = '0'))
        AND (nCE'DELAYED = '0') AND (CE2'DELAYED = '1') AND (nWE'DELAYED = '0') -- End of Write
      THEN 
        do_write <= '1' AFTER tHD_min;
    ELSE 
      IF (Now > 10 NS) AND (nCE = '0') AND (CE2 = '1') AND (nWE = '0') -- Start of Write
        THEN            
          ASSERT (not TimingCheckOn) or Check_For_Valid_Data(A)
          REPORT "Address not valid at start-of-write to RAM."
          SEVERITY ERROR;
         
          ASSERT (not TimingCheckOn) or A'STABLE(tSA_min)
          REPORT "tSA violation: Address changed within setup-time at start-of-write to SRAM."
          SEVERITY ERROR;

          ASSERT (not TimingCheckOn) or enable_nWE_only_control OR
                 ((nOE = '1') AND nOE'STABLE(tSA_min))
          REPORT "tSA violation: nOE not inactive at start-of-write to RAM."
          SEVERITY ERROR;
      END IF;
      do_write <= '0';
    END IF;
  END PROCESS;
 


-- The following processes check for validity of the control signals at the
-- SRAM interface. Removing them to speed up simulation will not affect the
-- functionality of the SRAM model.      
     

  PROCESS (A) -- Checks that an address change is allowed
  BEGIN
    IF (Now > 10 NS) THEN  -- suppress obsolete error message at time 0
      ASSERT (not TimingCheckOn) or (nCE = '1') OR (CE2 = '0') OR (nWE = '1')
      REPORT "Address not stable while write-to-SRAM active"
      SEVERITY ERROR;

      ASSERT (not TimingCheckOn) or (nCE = '1') OR (CE2 = '0') OR (nWE = '1')
             OR  (nCE'DELAYED(tHA_min) = '1') OR (CE2'DELAYED(tHA_min) = '0')
             OR (nWE'DELAYED(tHA_min) = '1')
      REPORT "tHA violation: Address changed within hold-time at end-of-write to SRAM."
      SEVERITY ERROR;
    END IF;
  END PROCESS;


  PROCESS (nOE, nWE, nCE, CE2)  -- Checks that control signals at RAM are valid all the time
   BEGIN
    IF (Now > 10 NS) AND (nCE /= '1') AND (CE2 /= '0') THEN
      IF (nCE = '0') AND (CE2 = '1') THEN
        ASSERT (not TimingCheckOn) or (nWE = '0') OR (nWE = '1')
        REPORT "Invalid nWE-signal at SRAM while nCE is active"
        SEVERITY WARNING;
      ELSE
        IF (nCE /= '0') THEN  
          ASSERT (not TimingCheckOn) or (nOE = '1')  
          REPORT "Invalid nCE-signal at SRAM while nOE not inactive"
          SEVERITY WARNING;
      
          ASSERT (not TimingCheckOn) or (nWE = '1')
          REPORT "Invalid nCE-signal at SRAM while nWE not inactive"
          SEVERITY ERROR;
        END IF;
        IF (CE2 /= '1') THEN  
          ASSERT (not TimingCheckOn) or (nOE = '1')  
          REPORT "Invalid CE2-signal at SRAM while nOE not inactive"
          SEVERITY WARNING;
      
          ASSERT (not TimingCheckOn) or (nWE = '1')
          REPORT "Invalid CE2-signal at SRAM while nWE not inactive"
          SEVERITY ERROR;
        END IF;
      END IF;
    END IF;
  END PROCESS;

END behavior;
