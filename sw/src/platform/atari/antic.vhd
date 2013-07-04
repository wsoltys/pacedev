library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_europa_support_lib.to_std_logic;

library work;
use work.antic_pkg.all;

entity antic is
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
    
    -- dbg
    dbg     : out antic_dbg_t
	);
end entity antic;

architecture SYN of antic is

  constant NTSC : boolean := (VARIANT = CO12296 or VARIANT = CO21697);
  constant PAL  : boolean := not NTSC;
  
  -- WRITE-ONLY registers
  signal dmactl_r : std_logic_vector(5 downto 0);
    -- b5=1 enable instruction fetch DMA
    -- b4=1 1 line P/M resolution
    -- b4=0 2 line P/M resolution
    -- b3=1 enable player DMA
    -- b2=1 enable missile DMA
    -- b1..0 = 00 no playfield DMA
    --         01 narrow playfield DMA (128 colour clocks)
    --         10 standard playfield DMA (160 colour clocks)
    --         11 wide playfield DMA (192 colour clocks)
  signal chactl_r : std_logic_vector(2 downto 0);
    -- b2 character vertical reflect
    -- b1 character video invert
    -- b0 character blank (blink)
  signal dlistl_r : std_logic_vector(7 downto 0);
  signal dlisth_r : std_logic_vector(7 downto 0);
  signal hscrol_r : std_logic_vector(3 downto 0);
  signal vscrol_r : std_logic_vector(3 downto 0);
  signal pmbase_r : std_logic_vector(7 downto 3);
  signal chbase_r : std_logic_vector(7 downto 1);
  signal wsync_r  : std_logic_vector(0 downto 0);
  signal nmien_r  : std_logic_vector(7 downto 6);
    -- b7 display list NMI
    -- b6 vertical blank NMI
  signal nmires_r : std_logic_vector(0 downto 0);

  -- READ-ONLY registers
  signal vcount_r : std_logic_vector(7 downto 0);
  signal penh_r   : std_logic_vector(7 downto 0);
  signal penv_r   : std_logic_vector(7 downto 0);
  signal nmist_r  : std_logic_vector(7 downto 5);
    -- b7 display list NMI
    -- b6 vertical blank NMI
    -- b5 reset button NMI

  signal hblank       : std_logic;
  signal background   : std_logic;
  signal vsync        : std_logic;
  signal vblank       : std_logic;
  
begin

  -- registers
  process (clk, rst)
  begin
    if rst = '1' then
      dmactl_r <= (others => '0');
      chactl_r <= (others => '0');
      dlistl_r <= (others => '0');
      dlisth_r <= (others => '0');
      hscrol_r <= (others => '0');
      vscrol_r <= (others => '0');
      pmbase_r <= (others => '0');
      chbase_r <= (others => '0');
      wsync_r <= "0";
      nmien_r <= (others => '0');
      nmires_r <= "0";
    elsif rising_edge(clk) then
      if clk_en = '1' then
        -- phi2_i is the CPU clk_en
        if phi2_i = '1' then
          -- (should also sample res_n here)
          if STD_MATCH(a_i, X"D4--") then
            if r_wn_i = '0' then
              -- register writes
              case a_i(3 downto 0) is
                when X"0" =>
                  dmactl_r <= d_i(dmactl_r'range);
                when X"1" =>
                  chactl_r <= d_i(chactl_r'range);
                when X"2" =>
                  dlistl_r <= d_i;
                when X"3" =>
                  dlisth_r <= d_i;
                when X"4" =>
                  hscrol_r <= d_i(hscrol_r'range);
                when X"5" =>
                  vscrol_r <= d_i(vscrol_r'range);
                when X"7" =>
                  pmbase_r <= d_i(pmbase_r'range);
                when X"9" =>
                  chbase_r <= d_i(chbase_r'range);
                when X"A" =>
                  -- probably don't need a register
                  wsync_r <= "1";
                when X"E" =>
                  -- reportedly, this must be written by:
                  -- - cycle 7 to enable
                  -- - cycle 8 to disable
                  nmien_r <= d_i(nmien_r'range);
                when X"F" =>
                  -- probably don't need a register
                  nmires_r <= d_i(nmires_r'range);
                when others =>
                  null;
              end case;
            else
              -- register reads
              case a_i(3 downto 0) is
                when X"B" =>
                  d_o <= vcount_r;
                when X"C" =>
                  d_o <= penh_r;
                when X"D" =>
                  d_o <= penv_r;
                when X"F" =>
                  d_o <= nmist_r & "00000";
                when others =>
                  null;
              end case;
            end if; -- r_wn_i
          end if; -- $D4XX
        end if; -- phi2_i (cpu_clk_en)
      end if; -- clk_en
    end if;
  end process;

  -- video controller
  process (clk, rst)
    -- fphi0 is the CPU clock
    -- - two (2) colour clocks per fphi0 clock
    variable h        : integer range 0 to 114-1;
    variable v        : integer range 0 to 312-1; -- 262-1 for NTSC
    variable vcount   : unsigned(8 downto 0);
  begin
    if rst = '1' then
      h := 0;
      v := 0;
      vcount := (others => '0');
      hblank <= '0';
      vsync <= '0';
      vblank <= '0';
      nmi_n <= '1';
    elsif rising_edge(clk) then
      if fphi0_i = '1' then
        -- h,v video counters
        if h = h'high then
          h := 0;
          if (NTSC and v = 262-1) or v = v'high then
            v := 0;
          else
            v := v + 1;
          end if; -- v=v'high
        else
          h := h + 1;
        end if; -- h=h'high
        -- generate VCOUNT
        -- - updated on cycle 110 (what a PITA!)
        if h = 110 then
          if (NTSC and v = 262-1) or v = v'high then
            vcount := (others => '0');
          else
            vcount := vcount + 1;
          end if;
        end if;
        -- generate VBI (NMI)
        -- - NTSC only (PAL=?)
        nmi_n <= '1';
        if h = 0 and v = 248 then
          if nmien_r(6) = '1' then
            nmi_n <= '0';
            -- TODO: nmist_ff
          end if;
        end if;
      end if; --fphi0_i
      -- assign BACKGROUND,HBLANK,VBLANK,VSYNC signals
      if (NTSC and v >= 8 and v <= 240) or
          -- *** fix PAL
          (PAL and v >= 8 and v <= 240) then
        vblank <= '0';
      else
        vblank <= '1';
        if (NTSC and v >= 251 and v <= 253) or
            (PAL and v >= 275 and v <= 278) then
          vsync <= '1';
        else
          vsync <= '0';
        end if;
      end if;
      -- same for NTSC/PAL
      -- hblank and background
      background <= '0'; -- default
      hblank <= '0';
      if h >= 17 and h <= 110 then
        case dmactl_r(1 downto 0) is
          when "01" =>
            if h <= 31 or h >= 96 then
              background <= '1';
            end if;
          when "10" | "00" =>
            if h <= 23 or h >= 104 then
              background <= '1';
            end if;
          when "11" =>
            if h <= 21 or h >= 110 then
              background <= '1';
            end if;
          when others =>
            background <= '0';
        end case;
      else
        hblank <= '1';
      end if;
    end if; -- rising_edge(clk)
    -- assign VCOUNT register
    vcount_r <= std_logic_vector(vcount(8 downto 1));
  end process;
  
  -- HALT (none for now)
  halt_n <= '1';
  
  BLK_GTIA_IF : block
  begin
    process (clk, rst)
    begin
      if rst = '1' then
      elsif rising_edge(clk) then
        if fphi0_i = '1' then
          if vsync = '1' then
            an <= "001";
          elsif hblank = '1' then
            -- normal mode
            an <= "010";
          elsif background = '1' then
            an <= "000";
          else
            -- fixme
            an <= "111";
          end if;
        end if; -- fphi0_en
      end if;
    end process;
  end block;
  
  BLK_DEBUG : block
  begin
    dbg.dmactl <= unsigned("00" & dmactl_r);
    dbg.chactl <= unsigned("00000" & chactl_r);
    dbg.dlistl <= unsigned(dlistl_r);
    dbg.dlisth <= unsigned(dlisth_r);
    dbg.hscrol <= unsigned("0000" & hscrol_r);
    dbg.vscrol <= unsigned("0000" & vscrol_r);
    dbg.pmbase <= unsigned(pmbase_r & "000");
    dbg.chbase <= unsigned(chbase_r & "0");
    dbg.wsync <= unsigned("0000000" & wsync_r);
    dbg.nmien <= unsigned(nmien_r & "000000");
    dbg.nmires <= unsigned("0000000" & nmires_r);
    dbg.vcount <= unsigned(vcount_r);
    dbg.penh <= unsigned(penh_r);
    dbg.penv <= unsigned(penv_r);
    dbg.nmist <= unsigned(nmist_r & "00000");
  end block BLK_DEBUG;
  
end architecture SYN;

--
-- This module is based *heavily* on the fpga64_hexy.vhd module from:
--
-- FPGA64
-- Reconfigurable hardware based commodore64 emulator.
-- Copyright 2005-2008 Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.antic_pkg.all;

entity antic_hexy is
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
end entity antic_hexy;

architecture SYN of antic_hexy is
	signal oldV : std_logic;
	signal oldH : std_logic;
	
	signal vPos : integer range 0 to 1023;
	signal hPos : integer range 0 to 2047;
	
	signal localX : unsigned(8 downto 0);
	signal localX2 : unsigned(8 downto 0);
	signal localX3 : unsigned(8 downto 0);
	signal localY : unsigned(3 downto 0);
	signal runY : std_logic;
	signal runX : std_logic;
	
	signal cChar : unsigned(5 downto 0);
	signal pixels : unsigned(0 to 63);
	
begin
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			if hSync = '0' and oldH = '1' then
				hPos <= 0;
				vPos <= vPos + 1;
			else
				hPos <= hPos + 1;
			end if;
			if vSync = '0' and oldV = '1' then
				vPos <= 0;
			end if;				
			oldH <= hSync;
			oldV <= vSync;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			if hPos = xOffset then
				localX <= (others => '0');
				runX <= '1';
				if vPos = yOffset then
					localY <= (others => '0');
					runY <= '1';
				end if;
			elsif runX = '1' and localX = "111111111" then
				runX <= '0';
				if localY = "111" then
					runY <= '0';
				else	
					localY <= localY + 1;
				end if;									
			else				
				localX <= localX + 1;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			case localX(8 downto 3) is
			when "000000" => cChar <= "001101"; -- D
			when "000001" => cChar <= "010110"; -- M
			when "000010" => cChar <= "001010"; -- A
			when "000011" => cChar <= "111110"; -- :                  
			when "000100" => cChar <= "00" & dbg.dmactl(7 downto 4); 
			when "000101" => cChar <= "00" & dbg.dmactl(3 downto 0); 
			when "000110" => cChar <= "111111"; --                   
			when "000111" => cChar <= "001100"; -- C                
			when "001000" => cChar <= "001100"; -- C                  
			when "001001" => cChar <= "111110"; -- :                  
			when "001010" => cChar <= "00" & dbg.chactl(3 downto 0); 
			when "001011" => cChar <= "111111"; --                   
			when "001100" => cChar <= "001101"; -- D                  
			when "001101" => cChar <= "010101"; -- L                  
			when "001110" => cChar <= "111110"; -- :                   
			when "001111" => cChar <= "00" & dbg.dlisth(7 downto 4);   
			when "010000" => cChar <= "00" & dbg.dlisth(3 downto 0);   
			when "010001" => cChar <= "00" & dbg.dlistl(7 downto 4);  
			when "010010" => cChar <= "00" & dbg.dlistl(3 downto 0);  
			when "010011" => cChar <= "111111"; --                    
			when "010100" => cChar <= "010001"; -- H                  
			when "010101" => cChar <= "111110"; -- :                  
			when "010110" => cChar <= "00" & dbg.hscrol(3 downto 0);  
			when "010111" => cChar <= "111111"; --                    
			when "011000" => cChar <= "011111"; -- V                  
			when "011001" => cChar <= "111110"; -- :                 
			when "011010" => cChar <= "00" & dbg.vscrol(3 downto 0);  
			when "011011" => cChar <= "111111"; --                    
			when "011100" => cChar <= "011001"; -- P                  
			when "011101" => cChar <= "001011"; -- B                  
			when "011110" => cChar <= "111110"; -- :                  
			when "011111" => cChar <= "00" & dbg.pmbase(7 downto 4); 			  
			when "100000" => cChar <= "00" & dbg.pmbase(3 downto 0);        
			when "100001" => cChar <= "111111"; --                          
			when "100010" => cChar <= "001100"; -- C                        
			when "100011" => cChar <= "001011"; -- B                        
			when "100100" => cChar <= "111110"; -- :                      
			when "100101" => cChar <= "00" & dbg.chbase(7 downto 4);  
			when "100110" => cChar <= "00" & dbg.chbase(3 downto 0);  
			when "100111" => cChar <= "111111"; --                    
			when "101000" => cChar <= "010111"; -- N                  
			when "101001" => cChar <= "010110"; -- M
			when "101010" => cChar <= "010010"; -- I
			when "101011" => cChar <= "111110"; -- :                  
			when "101100" => cChar <= "001110"; -- E
			when "101101" => cChar <= "00" & dbg.nmien(7 downto 4);   
			when "101110" => cChar <= "011100"; -- S                  
			when "101111" => cChar <= "00" & dbg.nmist(3 downto 0);   
			when "110000" => cChar <= "011011"; -- R                  
			when "110001" => cChar <= "00" & dbg.nmires(3 downto 0);  
			when "110010" => cChar <= "111111"; --                                                    
			when "110011" => cChar <= "011111"; -- V                
			when "110100" => cChar <= "001100"; -- C                
			when "110101" => cChar <= "111110"; -- :                
			when "110110" => cChar <= "00" & dbg.vcount(7 downto 4);
			when "110111" => cChar <= "00" & dbg.vcount(3 downto 0);
			when "111000" => cChar <= "111111"; --                  
			when others => cChar <= (others => '1');
			end case;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			localX2 <= localX;
			localX3 <= localX2;
			if (runY = '0')
			or (runX = '0') then
				pixels <= (others => '0');
			else
				case cChar is
				when "000000" => pixels <= X"3C666E7666663C00"; -- 0
				when "000001" => pixels <= X"1818381818187E00"; -- 1
				when "000010" => pixels <= X"3C66060C30607E00"; -- 2
				when "000011" => pixels <= X"3C66061C06663C00"; -- 3
				when "000100" => pixels <= X"060E1E667F060600"; -- 4
				when "000101" => pixels <= X"7E607C0606663C00"; -- 5
				when "000110" => pixels <= X"3C66607C66663C00"; -- 6
				when "000111" => pixels <= X"7E660C1818181800"; -- 7
				when "001000" => pixels <= X"3C66663C66663C00"; -- 8
				when "001001" => pixels <= X"3C66663E06663C00"; -- 9

				when "001010" => pixels <= X"183C667E66666600"; -- A
				when "001011" => pixels <= X"7C66667C66667C00"; -- B
				when "001100" => pixels <= X"3C66606060663C00"; -- C
				when "001101" => pixels <= X"786C6666666C7800"; -- D
				when "001110" => pixels <= X"7E60607860607E00"; -- E
				when "001111" => pixels <= X"7E60607860606000"; -- F
				when "010000" => pixels <= X"3C66606E66663C00"; -- G
				when "010001" => pixels <= X"6666667E66666600"; -- H
				when "010010" => pixels <= X"3C18181818183C00"; -- I
				when "010011" => pixels <= X"1E0C0C0C0C6C3800"; -- J
				when "010100" => pixels <= X"666C7870786C6600"; -- K
				when "010101" => pixels <= X"6060606060607E00"; -- L
				when "010110" => pixels <= X"63777F6B63636300"; -- M
				when "010111" => pixels <= X"66767E7E6E666600"; -- N
				when "011000" => pixels <= X"3C66666666663C00"; -- O
				when "011001" => pixels <= X"7C66667C60606000"; -- P
				when "011010" => pixels <= X"3C666666663C0E00"; -- Q
				when "011011" => pixels <= X"7C66667C786C6600"; -- R
				when "011100" => pixels <= X"3C66603C06663C00"; -- S
				when "011101" => pixels <= X"7E18181818181800"; -- T
				when "011110" => pixels <= X"6666666666663C00"; -- U
				when "011111" => pixels <= X"66666666663C1800"; -- V
				when "100000" => pixels <= X"6363636B7F776300"; -- W
				when "100001" => pixels <= X"66663C183C666600"; -- X
				when "100010" => pixels <= X"6666663C18181800"; -- Y
				when "100011" => pixels <= X"7E060C1830607E00"; -- Z
				when "111110" => pixels <= X"0000180000180000"; -- :
				when others   => pixels <= X"0000000000000000"; -- space
				end case;
			end if;
		end if;			
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) and clk_ena = '1' then
			video <= pixels(to_integer(localY & localX3(2 downto 0)));
		end if;
	end process;
	
	dim <= runX and runY;
	
end architecture SYN;

