library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_europa_support_lib.to_std_logic;

library work;
use work.atari_gtia_pkg.all;

entity atari_gtia is
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
    r       : out std_logic_vector(3 downto 0);
    g       : out std_logic_vector(3 downto 0);
    b       : out std_logic_vector(3 downto 0);
    hsync   : out std_logic;
    vsync   : out std_logic;
    de      : out std_logic;
    
    -- dbg
    dbg     : out gtia_dbg_t
	);
end entity atari_gtia;

architecture SYN of atari_gtia is

  type reg_a is array (natural range <>) of std_logic_vector(7 downto 0);
  
  -- WRITE-ONLY
  signal hposp_r    : reg_a(0 to 3);
  signal hposm_r    : reg_a(0 to 3);
  signal sizep_r    : reg_a(0 to 3);
  signal sizem_r    : std_logic_vector(7 downto 0);
  signal grafp_r    : reg_a(0 to 3);
  signal grafm_r    : std_logic_vector(7 downto 0);
  signal colpm_r    : reg_a(0 to 3);
  signal colpf_r    : reg_a(0 to 3);
  signal colbk_r    : std_logic_vector(7 downto 0);
  signal prior_r    : std_logic_vector(7 downto 0);
  signal vdelay_r   : std_logic_vector(7 downto 0);
  signal gractl_r   : std_logic_vector(7 downto 0);
  signal hitclr_r   : std_logic_vector(7 downto 0);
  signal conspk_r   : std_logic_vector(7 downto 0);
  
  -- READ_ONLY
  signal mpf_r    : reg_a(0 to 3);
  signal ppf_r    : reg_a(0 to 3);
  signal mpl_r    : reg_a(0 to 3);
  signal ppl_r    : reg_a(0 to 3);
  signal trig_r   : reg_a(0 to 3);
  signal pal_r    : std_logic_vector(7 downto 0);
  signal consol_r   : std_logic_vector(7 downto 0);
  
begin

  -- clocks
  -- - supplies (in effect) CPU clock to ANTIC
  -- - FPHI0 has the same phase as PHI2
  fphi0_o <= phi2_i;
  
  -- registers
  process (clk, rst)
    variable i  : integer range 0 to 3;
  begin
    if rst = '0' then
      -- WRITE-ONLY
      hposp_r <= (others => (others => '0'));
      hposm_r <= (others => (others => '0'));
      sizep_r <= (others => (others => '0'));
      sizem_r <= (others => '0');
      grafp_r <= (others => (others => '0'));
      grafm_r <= (others => '0');
      colpm_r <= (others => (others => '0'));
      colpf_r <= (others => (others => '0'));
      colbk_r <= (others => '0');
      prior_r <= (others => '0');
      vdelay_r <= (others => '0');
      gractl_r <= (others => '0');
      hitclr_r <= (others => '0');
      conspk_r <= (others => '0');
      -- READ_ONLY
      mpf_r <= (others => (others => '0'));
      ppf_r <= (others => (others => '0'));
      mpl_r <= (others => (others => '0'));
      ppl_r <= (others => (others => '0'));
      trig_r <= (others => (others => '0'));
      if VARIANT = CO14805 then
        -- NTSC
        pal_r <= "00000111";
      else
        -- PAL/SECAM?
        pal_r <= "00000000";
      end if;
      -- hack for now (no keys active)
      consol_r <= "00001111";
    elsif rising_edge(clk) then
      if phi2_i = '1' then
        if cs_n = '0' then
          i := to_integer(unsigned(a(1 downto 0)));
          if r_wn = '0' then
            -- register writes
            case a is
              when "000--" =>
                hposp_r(i) <= d_i;
              when "001--" =>
                hposm_r(i) <= d_i;
              when "010--" =>
                sizep_r(i) <= d_i;
              when "01100" =>
                sizem_r <= d_i;
              when "01101" =>
                grafp_r(0) <= d_i;
              when "01110" =>
                grafp_r(1) <= d_i;
              when "01111" =>
                grafp_r(2) <= d_i;
              when "10000" =>
                grafp_r(3) <= d_i;
              when "10001" =>
                grafm_r <= d_i;
              when "10010" =>
                colpm_r(0) <= d_i;
              when "10011" =>
                colpm_r(1) <= d_i;
              when "10100" =>
                colpm_r(2) <= d_i;
              when "10101" =>
                colpm_r(3) <= d_i;
              when "10110" =>
                colpf_r(0) <= d_i;
              when "10111" =>
                colpf_r(1) <= d_i;
              when "11000" =>
                colpf_r(2) <= d_i;
              when "11001" =>
                colpf_r(3) <= d_i;
              when "11010" =>
                colbk_r <= d_i;
              when "11011" =>
                prior_r <= d_i;
              when "11100" =>
                vdelay_r <= d_i;
              when "11101" =>
                gractl_r <= d_i;
              when "11110" =>
                hitclr_r <= d_i;
              when "11111" =>
                conspk_r <= d_i;
              when others =>
                null;
            end case;
          else
            -- register reads
            case a is
              when "000--" =>
                d_o <= mpf_r(i);
              when "001--" =>
                d_o <= ppf_r(i);
              when "010--" =>
                d_o <= mpl_r(i);
              when "011--" =>
                d_o <= ppl_r(i);
              when "100--" =>
                d_o <= trig_r(i);
              when "10100" =>
                d_o <= pal_r;
              when "11111" =>
                d_o <= consol_r;
              when others =>
                null;
            end case;
          end if; -- r_wn_i
        end if; -- $D4XX
      end if; -- clk_en
    end if;
  end process;

--  -- HALT (none for now)
--  halt_n <= '1';
--  -- NMI (none for now)
--  nmi_n <= '1';
  
  process (clk, rst)
    variable hblank_r  : std_logic;
    variable hsync_cnt  : integer range 0 to 15;
  begin
    if rst = '1' then
      hblank_r := '0';
      hsync_cnt := 0;
    elsif rising_edge(clk) then
      if osc = '1' then
        -- generate VSYNC
        if an = "001" then
          vsync <= '1';
        else
          vsync <= '0';
        end if;
        -- generate HSYNC
        if hblank_r = '0' and an(2 downto 1) = "01" then
          hsync_cnt := hsync_cnt'high;
        end if;
        if hsync_cnt > 0 then
          hsync <= '1';
          hsync_cnt := hsync_cnt - 1;
        else
          hsync <= '0';
        end if; -- hsync_cnt>0
        if an(2 downto 1) = "01" then
          hblank_r := '1';
        else
          hblank_r := '0';
        end if; -- an(2..1)
      end if; -- osc='1'
    end if;
  end process;
  
  BLK_DEBUG : block
  begin
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

entity atari_gtia_hexy is
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
end entity atari_gtia_hexy;

architecture SYN of atari_gtia_hexy is
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
--			when "000000" => cChar <= "001101"; -- D
--			when "000001" => cChar <= "010110"; -- M
--			when "000010" => cChar <= "001010"; -- A
--			when "000011" => cChar <= "111110"; -- :                  
--			when "000100" => cChar <= "00" & dbg.dmactl(7 downto 4); 
--			when "000101" => cChar <= "00" & dbg.dmactl(3 downto 0); 
--			when "000110" => cChar <= "111111"; --                   
--			when "000111" => cChar <= "001100"; -- C                
--			when "001000" => cChar <= "001100"; -- C                  
--			when "001001" => cChar <= "111110"; -- :                  
--			when "001010" => cChar <= "00" & dbg.chactl(3 downto 0); 
--			when "001011" => cChar <= "111111"; --                   
--			when "001100" => cChar <= "001101"; -- D                  
--			when "001101" => cChar <= "010101"; -- L                  
--			when "001110" => cChar <= "111110"; -- :                   
--			when "001111" => cChar <= "00" & dbg.dlisth(7 downto 4);   
--			when "010000" => cChar <= "00" & dbg.dlisth(3 downto 0);   
--			when "010001" => cChar <= "00" & dbg.dlistl(7 downto 4);  
--			when "010010" => cChar <= "00" & dbg.dlistl(3 downto 0);  
--			when "010011" => cChar <= "111111"; --                    
--			when "010100" => cChar <= "010001"; -- H                  
--			when "010101" => cChar <= "111110"; -- :                  
--			when "010110" => cChar <= "00" & dbg.hscrol(3 downto 0);  
--			when "010111" => cChar <= "111111"; --                    
--			when "011000" => cChar <= "011111"; -- V                  
--			when "011001" => cChar <= "111110"; -- :                 
--			when "011010" => cChar <= "00" & dbg.vscrol(3 downto 0);  
--			when "011011" => cChar <= "111111"; --                    
--			when "011100" => cChar <= "011001"; -- P                  
--			when "011101" => cChar <= "001011"; -- B                  
--			when "011110" => cChar <= "111110"; -- :                  
--			when "011111" => cChar <= "00" & dbg.pmbase(7 downto 4); 			  
--			when "100000" => cChar <= "00" & dbg.pmbase(3 downto 0);        
--			when "100001" => cChar <= "111111"; --                          
--			when "100010" => cChar <= "001100"; -- C                        
--			when "100011" => cChar <= "001011"; -- B                        
--			when "100100" => cChar <= "111110"; -- :                      
--			when "100101" => cChar <= "00" & dbg.chbase(7 downto 4);  
--			when "100110" => cChar <= "00" & dbg.chbase(3 downto 0);  
--			when "100111" => cChar <= "111111"; --                    
--			when "101000" => cChar <= "010111"; -- N                  
--			when "101001" => cChar <= "010110"; -- M
--			when "101010" => cChar <= "010010"; -- I
--			when "101011" => cChar <= "111110"; -- :                  
--			when "101100" => cChar <= "001110"; -- E
--			when "101101" => cChar <= "00" & dbg.nmien(7 downto 4);   
--			when "101110" => cChar <= "011100"; -- S                  
--			when "101111" => cChar <= "00" & dbg.nmist(3 downto 0);   
--			when "110000" => cChar <= "011011"; -- R                  
--			when "110001" => cChar <= "00" & dbg.nmires(3 downto 0);  
--			when "110010" => cChar <= "111111"; --                                                    
--			when "110011" => cChar <= "011111"; -- V                
--			when "110100" => cChar <= "001100"; -- C                
--			when "110101" => cChar <= "111110"; -- :                
--			when "110110" => cChar <= "00" & dbg.vcount(7 downto 4);
--			when "110111" => cChar <= "00" & dbg.vcount(3 downto 0);
--			when "111000" => cChar <= "111111"; --                  
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

