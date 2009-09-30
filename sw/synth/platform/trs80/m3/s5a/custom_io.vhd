library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity custom_io is
  port
  (
    -- wishbone (LPC) interface
    wb_clk          : in std_logic;
    wb_rst          : in std_logic;
    wb_cyc          : in std_logic;
    wb_stb          : in std_logic;
    wb_adr          : in std_logic_vector(7 downto 0);
    wb_dat_i        : in std_logic_vector(7 downto 0);
    wb_dat_o        : out std_logic_vector(7 downto 0);
    wb_we           : in std_logic;
    wb_ack          : out std_logic;
    
    project_i       : out from_PROJECT_IO_t;
    project_o       : in to_PROJECT_IO_t;
    platform_i      : out from_PLATFORM_IO_t;
    platform_o      : in to_PLATFORM_IO_t;
    target_i        : out from_TARGET_IO_t;
    target_o        : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

  --signal fifo_q         : std_logic_vector(15 downto 0) := (others => '0');
  --signal fifo_rdreq     : std_logic := '0';
  --signal fifo_rdempty   : std_logic := '0';
    
begin

  -- address map
  --
  --  $00 - (R) STP_IN & STP_OUT  (W) WPSn & TR00SENSEn
  --  $01 - (R) FIFO_WRFULL       (W) FIFO
  --  $02 - (R) FIFO_USEDW
  --
  process (wb_clk, wb_rst)
    variable rd_r : std_logic := '0';
    variable wr_r : std_logic := '0';
  begin
    if wb_rst = '1' then
      rd_r := '0';
      wr_r := '0';
      wb_ack <= '0';
    elsif rising_edge(wb_clk) then
      --platform_i.fifo_wrreq <= '0'; -- default
      --fifo_rdreq <= '0';            -- default
      if rd_r = '0' and wb_cyc = '1' and wb_stb = '1' and wb_we = '0' then
        -- leading edge read
        case wb_adr(3 downto 0) is
          when X"0" =>
            --wb_dat_o <= "000000" & platform_o.stp_in & platform_o.stp_out;
          when X"1" =>
            --wb_dat_o <= "0000000" & platform_o.fifo_wrfull;
          when X"2" =>
            --wb_dat_o <= platform_o.fifo_wrusedw;
          when others =>
            null;
        end case;
      elsif wr_r = '0' and wb_cyc = '1' and wb_stb = '1' and wb_we = '1' then
        -- leading edge write
        case wb_adr(3 downto 0) is
          when X"0" =>
            --platform_i.wps_n <= wb_dat_i(0);
            --platform_i.tr00_sense_n <= wb_dat_i(1);
          when X"1" =>
            --platform_i.fifo_data <= wb_dat_i;
            --platform_i.fifo_wrreq <= '1';
          when others =>
            null;
        end case;
      end if;
      wb_ack <= wb_cyc and wb_stb;
      rd_r := wb_cyc and wb_stb and not wb_we;
      wr_r := wb_cyc and wb_stb and wb_we;
    end if;
  end process;

  --platform_i.fifo_wrclk <= wb_clk;

end architecture SYN;
