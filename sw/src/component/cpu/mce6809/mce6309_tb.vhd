library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.mce6309_pack.all;

entity mce6309_tb is
	port (
		fail:				out  boolean
	);
end mce6309_tb;

architecture SYN of mce6309_tb is
	--for syn_cpu : mce6309 use entity work.mce6309 (SYN);
	--for beh_cpu : mce6309 use entity work.mce6309 (BEH);

	subtype MemData_idx is integer range 0 to 65535;
	subtype MemData_type is std_logic_vector(7 downto 0);
	type Mem_type is array(MemData_idx) of MemData_type;

	signal clk				: std_logic	:= '0';
	signal reset			: std_logic	:= '1';
	signal syn_read		: std_logic;
	signal syn_vma		: std_logic;
	signal syn_addr		: std_logic_vector(15 downto 0);
	signal syn_data_o	: std_logic_vector(7 downto 0);
	signal beh_read		: std_logic;
	signal beh_vma		: std_logic;
	signal beh_addr		: std_logic_vector(15 downto 0);
	signal beh_data_o	: std_logic_vector(7 downto 0);
	signal mem_read		: std_logic;
	signal mem_addr		: std_logic_vector(15 downto 0);
	signal mem_data		: std_logic_vector(7 downto 0);

  signal bdm_clk    : std_logic;
  signal bdm_i      : std_logic;
  signal bdm_o      : std_logic;
  signal bdm_mosi   : std_logic;
  signal bdm_miso   : std_logic;
  
	signal match_ext	: std_logic;

begin

	syn_cpu : entity work.mce6309(SYN)
	  port map 
	  (
	    clk       => clk, 
	    clken     => '1', 
	    reset     => reset, 
	    
	    rw        => syn_read,
		  vma       => syn_vma, 
		  address   => syn_addr, 
	    data_i    => mem_data, 
	    data_o    => syn_data_o, 
	    data_oe   => open,
	    lic       => open,
		  halt      => '0', 
		  hold      => '0', 
		  irq       => '0', 
		  firq      => '0', 
		  nmi       => '0',

      bdm_clk   => bdm_clk,
      bdm_rst   => reset,
      bdm_mosi  => bdm_mosi,
      bdm_miso  => bdm_miso,
		  bdm_i     => bdm_i,
		  bdm_o     => open,
		  bdm_oe    => open,
		  
		  op_fetch  => open
	  );

    BLK_BDM : block
    
      procedure bdm_send_recv (
        variable cmd    	: in std_logic_vector(7 downto 0);
        variable data_i		: in std_logic_vector(15 downto 0);
        variable data_o		: out std_logic_vector(15 downto 0);
        signal bdm_miso : in std_logic;
        signal bdm_mosi : out std_logic;
        signal bdm_o    : out std_logic) is
        variable osr : std_logic_vector(23 downto 0);
        variable isr : std_logic_vector(23 downto 0);
      begin
      	osr := cmd & data_i;
        for i in osr'range loop
          wait until falling_edge(bdm_clk);
          bdm_mosi <= '1';
          bdm_o <= osr(osr'left);
          osr := osr(osr'left-1 downto 0) & osr(osr'left);
        end loop;
        wait until falling_edge(bdm_clk);
        bdm_mosi <= '0';
        
        wait until rising_edge(bdm_miso);
        for i in isr'range loop
					wait until rising_edge(bdm_clk);
					isr := isr(isr'left-1 downto 0) & bdm_miso;
				end loop;

				data_o := isr(15 downto 0);
								
      end bdm_send_recv;

      procedure bdm_delay (
        clocks  : in integer) is
      begin
        for i in 1 to clocks loop
          wait until rising_edge(bdm_clk);
        end loop;
      end bdm_delay;

      procedure dump_regs (
        signal bdm_miso : in std_logic;
        signal bdm_mosi : out std_logic;
        signal bdm_o    : out std_logic) is
        variable cmd		: std_logic_vector(7 downto 0);
        variable data_i	: std_logic_vector(15 downto 0) := (others => '0');
        variable data_o	: std_logic_vector(15 downto 0);
        variable l			: line;
      begin
      	for i in 0 to 15 loop
      		bdm_delay(2);
      		if i /= 12 and i /= 13 then
	      		cmd := X"2" & std_logic_vector(to_unsigned(i,4));
	      		bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_o);
	      		write (l, to_integer(unsigned(data_o)));
	      		writeline (output, l);
      		end if;
      	end loop;
      end dump_regs;
      
    begin
    
      -- generate BDM clock
      process
      begin
        bdm_clk <= '0';
        wait until reset = '0';
        loop
          wait until rising_edge(clk);
          bdm_clk <= '1';
          wait until rising_edge(clk);
          bdm_clk <= '0';
        end loop;
      end process;

      -- do some bdm stuff
      PROC_BDM : process
        variable cmd  		: std_logic_vector(7 downto 0);
        variable data_i 	: std_logic_vector(15 downto 0);
        variable data_o 	: std_logic_vector(15 downto 0);
      begin
        bdm_mosi <= '0';
        bdm_i <= '0';
        data_i := X"0000";
        wait until reset = '0';
        cmd := X"81";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- step
        bdm_delay(4);
        cmd := X"00";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- read CR
        bdm_delay(4);
        cmd := X"02";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- read AP
        bdm_delay(4);
        cmd := X"03";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- read BP
        bdm_delay(4);
        cmd := X"81";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- step
        bdm_delay(4);
        cmd := X"12";
        data_i := X"001E";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- set breakpoint
        bdm_delay(4);
        cmd := X"82";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- go
        bdm_delay(4);
        wait for 2 us;
        cmd := X"80";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- break
        bdm_delay(4);
        
        -- dump registers
        dump_regs (bdm_miso, bdm_mosi, bdm_i);
        
        -- disable BDM and continue
        cmd := X"10";
        data_i := X"0000";
        bdm_send_recv (cmd, data_i, data_o, bdm_miso, bdm_mosi, bdm_i);   -- LD CR,$00 (disable BDM)
      end process PROC_BDM;
      
    end block BLK_BDM;
        
--	beh_cpu : mce6309 
--	  port map 
--	  (
--	    clk       => clk, 
--	    clken     => '1', 
--	    reset     => reset, 
--	    
--	    rw        => beh_read,
--		  vma       => beh_vma, 
--		  address   => beh_addr, 
--	    data_i    => mem_data, 
--	    data_o    => beh_data_o, 
--	    data_oe   => open,
--		  halt      => '0', 
--		  hold      => '0', 
--		  irq       => '0', 
--		  firq      => '0', 
--		  nmi       => '0',
--		  
--		  bdm_i     => '0',
--		  bdm_o     => open,
--		  bdm_oe    => open,
--		  
--		  op_fetch  => open
--	  );

	-- Check external signals match
	match_ext <= '0' when beh_vma /= syn_vma or (syn_vma = '1' and beh_read /= syn_read) or (syn_vma = '1' and beh_addr /= syn_addr) else
		'1';

	-- Generate CLK and reset
	clk <= not clk after 20 ns;
	reset <= '0' after 101 ns;

	mem_read <= syn_read;
	mem_addr <= syn_addr;
	--mem_read <= beh_read;
	--mem_addr <= beh_addr;

	beh_mem : process(mem_read, mem_addr)
		constant mem_delay : time := 12 ns;
		constant mem : Mem_type := (
			16#00#	=>	X"9B",	-- ADDA 10h
			16#01#	=>	X"10",	--
			16#02#	=>	X"9B",	-- ADDA 11h
			16#03#	=>	X"11",	--
			16#04#	=>	X"12",	-- NOP
			16#05#	=>	X"12",	-- NOP
			16#06#	=>	X"1E",	-- EXG D,X
			16#07#	=>	X"01",	-- 
			16#08#	=>	X"4C",	-- INCA
			16#09#	=>	X"5C",	-- INCB
			16#0A#	=>	X"1E",	-- EXG X,U
			16#0B#	=>	X"13",	--
			16#0C#	=>	X"1E",	-- EXG S,U
			16#0D#	=>	X"43",	--
			16#0E#	=>	X"1E",	-- EXG A,CC       -- CC all over the place
			16#0F#	=>	X"8A",	--
			16#10#	=>	X"1E",	-- EXG B,DP
			16#11#	=>	X"9B",	--
			16#12#	=>	X"1E",	-- EXG D,S
			16#13#	=>	X"04",	--
			16#14#	=>	X"9B",	-- ADDA -1        -- is this what is meant?
			16#15#	=>	X"FF",	--
			16#16#	=>	X"BB",	-- ADDA #0005h
			16#17#	=>	X"00",	--
			16#18#	=>	X"05",		
			16#19#	=>	X"AB",	-- ADDA ,X
			16#1A#	=>	X"84",
			16#1B#	=>	X"AB",	-- ADDA 5,X
			16#1C#	=>	X"05",
			16#1D#	=>	X"12",
			16#1E#	=>	X"12",
			16#1F#	=>	X"12",
			16#20#	=>	X"12",
			16#21#	=>	X"12",
			others	=>	X"12"
		);
	begin
		mem_data <= mem(to_integer(unsigned(mem_addr))) after mem_delay;
		if mem_addr = X"FFFF" then
			assert false report "End of simulation" severity Failure;  
		end if;
	end process beh_mem;

	fail_check : process(clk, reset, match_ext)
	begin
		if rising_edge(clk) and reset = '0' then
			if match_ext = '0' then
				fail <= true;
			else
				fail <= false;
			end if;
		end if;
	end process fail_check;
end SYN;
