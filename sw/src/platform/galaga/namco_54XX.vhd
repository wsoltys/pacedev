library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity namco_54xx is
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
    io_n          : out std_logic_vector(3 downto 0)
  );
 end entity namco_54xx;
 
 architecture SYN of namco_54xx is
 
  signal control  : std_logic_vector(7 downto 0) := (others => '0');
  
 begin
 
  -- cpu interface
  process (clk, rst)
    -- NMI timer is 200us
    subtype nmi_cnt_t is integer range 0 to SYS_CLK_Hz/CLK_EN_DUTY/5000;
    variable nmi_cnt : nmi_cnt_t := 0;
  begin
    if rst = '1' then
      nmi_cnt := 0;
      nmi_n <= '1';
      control <= (others => '0');
    elsif rising_edge(clk) then
      if clk_en = '1' then
      
        -- pulse NMI low for 1 clk_en
        nmi_n <= '1'; -- default
        if nmi_cnt > 0 then
          if nmi_cnt = 1 then
            nmi_n <= '0';
          end if;
          nmi_cnt := nmi_cnt - 1;
        end if;
        
        if cs_n = '0' then
          if r_wn = '1' then
            if sel = '0' then
              -- data read
              if control(4) = '0' then
                -- error: device in read mode
                sd_o <= (others => '0');
              else
                -- logical AND of all selected inputs
                -- implemented in a mux outside
                sd_o <= id_i;
              end if;
            else
              -- control read
              sd_o <= control;
            end if;
          else
            if sel = '0' then
              -- data write
              if control(4) = '0' then
                id_o <= sd_i;
                -- assert IRQ signals to custom chips
                io_n <= not control(3 downto 0);
              end if;
            else
              -- control write
              control <= sd_i;
              if sd_i(3 downto 0) = "0000" then
                nmi_cnt := 0;
              else
                nmi_cnt := nmi_cnt_t'high;
                if sd_i(4) = '1' then
                  io_n <= not sd_i(3 downto 0);
                end if;
              end if;
            end if; -- sel
          end if; -- rw_n
        end if; -- cs_n
        
      end if; -- clk_en
    end if;
  end process;
  
 end architecture SYN;
 