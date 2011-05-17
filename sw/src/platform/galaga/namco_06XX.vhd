library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity namco_06xx is
  generic
  (
    SYS_CLK_Hz    : integer;
    CLK_EN_DUTY   : integer := 1
  );
  port
  (
    clk           : in std_logic;
    clk_en        : in std_logic;
    rst           : in std_logic;
    
    cs_n          : in std_logic;
    r_wn          : in std_logic;
    sel           : in std_logic;
    sd_i          : in std_logic_vector(7 downto 0);
    sd_o          : out std_logic_vector(7 downto 0);
    nmi_n         : out std_logic;
    
    id_i          : in std_logic_vector(7 downto 0);
    id_o          : out std_logic_vector(7 downto 0);
    io_n          : out std_logic_vector(1 to 4);       -- sd_i(0)->IOn(4)

    pin1          : out std_logic
  );
 end entity namco_06xx;
 
 architecture SYN of namco_06xx is
 
  signal control  : std_logic_vector(7 downto 0) := (others => '0');
  
 begin

  -- cpu interface
  process (clk, rst)
    -- NMI timer is 200us
    subtype nmi_tmr_t is integer range 0 to SYS_CLK_Hz/CLK_EN_DUTY/5000;
    variable nmi_tmr : nmi_tmr_t := 0;
    subtype nmi_cnt_t is integer range 0 to 23;
    variable nmi_cnt : nmi_cnt_t := 0;
    variable nmi_ena : std_logic := '0';
  begin
    if rst = '1' then
      nmi_tmr := 0;
      nmi_cnt := 0;
      nmi_ena := '0';
      nmi_n <= '1';
      control <= (others => '0');
    elsif rising_edge(clk) then
    
      if clk_en = '1' then
      
        -- pulse NMI low for 23 clocks
        if nmi_cnt > 0 then
          nmi_n <= '0';
          nmi_cnt := nmi_cnt - 1;
        else
          nmi_n <= '1';
        end if;

        -- handle periodic (200us) NMI generation
        if nmi_ena = '1' then
          if nmi_tmr > 0 then
            nmi_tmr := nmi_tmr - 1;
          else
            nmi_tmr := nmi_tmr_t'high;
            nmi_cnt := nmi_cnt_t'high;
          end if;
        end if;
        
        if cs_n = '0' then
          if sel = '0' then
            if r_wn = '1' then
              -- data read
              if control(4) = '1' then
                -- logical AND of all selected inputs
                -- implemented in a mux outside
                sd_o <= id_i;
              else
                -- error: device in write mode
                sd_o <= (others => '0');
              end if;
            else
              -- data write
              if control(4) = '0' then
                id_o <= sd_i;
              end if;
            end if; -- wr_n
          else
            -- control operation
            if r_wn = '1' then
              -- control read
              sd_o <= control;
            else
              -- control write
              if sd_i(3 downto 0) = "0000" then
                -- disable NMI timer
                nmi_ena := '0';
              else
                -- start 200us periodic NMI
                nmi_tmr := nmi_tmr_t'high;
                -- leave nmi_cnt alone
                nmi_ena := '1';
              end if;
              -- latch control state
              control <= sd_i;
            end if; -- rw_n
          end if; -- sel
        end if; -- cs_n

        -- drive output pins
        if control(3 downto 0) /= "0000" then
          pin1 <= control(4);
        end if;
        io_n <= not control(3 downto 0);
        
      end if; -- clk_en
    end if;
  end process;
  
 end architecture SYN;
 