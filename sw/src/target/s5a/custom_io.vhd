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

begin

  wb_dat_o <= (others => '0');

  process (wb_clk, wb_rst)
  begin
    if wb_rst = '1' then
      wb_ack <= '0';
    elsif rising_edge(wb_clk) then
      wb_ack <= wb_cyc and wb_stb;
    end if;
  end process;
  
end architecture SYN;
