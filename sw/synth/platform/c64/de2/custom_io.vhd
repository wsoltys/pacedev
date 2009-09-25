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
    -- GPIO 0 connector
    gpio_0_i          : in std_logic_vector(35 downto 0);
    gpio_0_o          : out std_logic_vector(35 downto 0);
    gpio_0_oe         : out std_logic_vector(35 downto 0);
    gpio_0_is_custom  : out std_logic_vector(35 downto 0);
    
    -- GPIO 1 connector
    gpio_1_i          : in std_logic_vector(35 downto 0);
    gpio_1_o          : out std_logic_vector(35 downto 0);
    gpio_1_oe         : out std_logic_vector(35 downto 0);
    gpio_1_is_custom  : out std_logic_vector(35 downto 0);

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

  gpio_0_is_custom <= (others => '0');

  GEN_NO_EXT_SB : if not C64_HAS_EXT_SB generate
    gpio_1_is_custom <= (others => '0');
  end generate GEN_NO_EXT_SB;
  
  GEN_EXT_SB : if C64_HAS_EXT_SB generate

    gpio_1_is_custom(gpio_1_is_custom'left downto 18) <= (others => '0');
    gpio_1_is_custom(17 downto 10) <= (others => '1');
    gpio_1_is_custom(9 downto 0) <= (others => '0');

    --alias ext_sb_data_in_n	: std_logic is gpio_1(14);
    --alias ext_sb_data_out_n	: std_logic is gpio_1(15);
    --alias ext_sb_clk_in_n		: std_logic is gpio_1(12);
    --alias ext_sb_clk_out_n	: std_logic is gpio_1(13);
    --alias ext_sb_atn_in_n		: std_logic is gpio_1(10);
    --alias ext_sb_atn_out_n	: std_logic is gpio_1(11);
    --alias ext_sb_rst_in_n		: std_logic is gpio_1(16);
    --alias ext_sb_rst_out_n	: std_logic is gpio_1(17);

    -- hook up the serial bus
    -- on the DE2 need to invert the bus logic
    -- so drive a '1' to put a '0' on the bus
    --ext_sb_data_in_s <= not ext_sb_data_in_n;
    --ext_sb_data_out_n <= '1' when ext_sb_data_oe = '1' else '0';
    --ext_sb_clk_in_s <= not ext_sb_clk_in_n;
    --ext_sb_clk_out_n <= '1' when ext_sb_clk_oe = '1' else '0';
    --ext_sb_atn_in_s <= not ext_sb_atn_in_n;
    --ext_sb_atn_out_n <= '1' when ext_sb_atn_oe = '1' else '0';
    -- not yet implemented
    --ext_sb_rst_out_n <= '0';

    platform_i.sb_data_in <= not gpio_1_i(14);
    gpio_1_o(15) <= '1' when platform_o.sb_data_oe = '1' else '0';
    platform_i.sb_clk_in <= not gpio_1_i(12);
    gpio_1_o(13) <= '1' when platform_o.sb_clk_oe = '1' else '0';
    platform_i.sb_atn_in <= not gpio_1_i(10);
    gpio_1_o(11) <= '1' when platform_o.sb_atn_oe = '1' else '0';
    platform_i.sb_rst_in <= not gpio_1_i(16);
    -- not yet implemented
    gpio_1_o(17) <= '0';

    -- all SB output is push-pull
    gpio_1_oe(17 downto 10) <= "10101010";

  end generate GEN_EXT_SB;
  
end architecture SYN;
