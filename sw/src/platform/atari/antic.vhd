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
    ref_n   : out std_logic
	);
end entity antic;

architecture SYN of antic is

  -- WRITE-ONLY registers
  signal dmactl   : std_logic_vector(5 downto 0);
    -- b5=1 enable instruction fetch DMA
    -- b4=1 1 line P/M resolution
    -- b4=0 2 line P/M resolution
    -- b3=1 enable player DMA
    -- b2=1 enable missile DMA
    -- b1..0 = 00 no playfield DMA
    --         01 narrow playfield DMA (128 colour clocks)
    --         10 standard playfield DMA (160 colour clocks)
    --         11 wide playfield DMA (192 colour clocks)
  signal chactl   : std_logic_vector(2 downto 0);
    -- b2 character vertical reflect
    -- b1 character video invert
    -- b0 character blank (blink)
  signal dlistl   : std_logic_vector(7 downto 0);
  signal dlisth   : std_logic_vector(7 downto 0);
  signal hscrol   : std_logic_vector(3 downto 0);
  signal vscrol   : std_logic_vector(3 downto 0);
  signal pmbase   : std_logic_vector(7 downto 3);
  signal chbase   : std_logic_vector(7 downto 1);
  signal wsync    : std_logic_vector(0 downto 0);
  signal nmien    : std_logic_vector(0 downto 0);
  signal nmires   : std_logic_vector(0 downto 0);

  -- READ-ONLY registers
  signal vcount   : std_logic_vector(7 downto 0);
  signal penh     : std_logic_vector(7 downto 0);
  signal penv     : std_logic_vector(7 downto 0);
  signal nmist    : std_logic_vector(7 downto 0);

begin

  -- registers
  process (clk, rst)
  begin
    if rst = '0' then
      dmactl <= (others => '0');
      chactl <= (others => '0');
      dlistl <= (others => '0');
      dlisth <= (others => '0');
      hscrol <= (others => '0');
      vscrol <= (others => '0');
      pmbase <= (others => '0');
      chbase <= (others => '0');
      wsync <= "0";
      nmien <= "0";
      nmires <= "0";
    elsif rising_edge(clk) then
      if clk_en = '1' then
        -- (should also sample res_n here)
        if STD_MATCH(a_i, X"D4--") then
          if r_wn_i = '0' then
            -- register writes
            case a_i(3 downto 0) is
              when X"0" =>
                dmactl <= d_i(dmactl'range);
              when X"1" =>
                chactl <= d_i(chactl'range);
              when X"2" =>
                dlistl <= d_i;
              when X"3" =>
                dlisth <= d_i;
              when X"4" =>
                hscrol <= d_i(hscrol'range);
              when X"5" =>
                vscrol <= d_i(vscrol'range);
              when X"7" =>
                pmbase <= d_i(pmbase'range);
              when X"9" =>
                chbase <= d_i(chbase'range);
              when X"A" =>
                wsync <= "1";
              when X"E" =>
                nmien <= d_i(nmien'range);
              when X"F" =>
                nmires <= d_i(nmien'range);
              when others =>
                null;
            end case;
          else
            -- register reads
            case a_i(3 downto 0) is
              when X"B" =>
                d_o <= vcount;
              when X"C" =>
                d_o <= penh;
              when X"D" =>
                d_o <= penv;
              when X"F" =>
                d_o <= nmist;
              when others =>
                null;
            end case;
          end if; -- r_wn_i
        end if; -- $D4XX
      end if; -- clk_en
    end if;
  end process;
  
end architecture SYN;
