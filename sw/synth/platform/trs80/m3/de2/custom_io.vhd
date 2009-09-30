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

    -- 7-segment display
    seg7              : out std_logic_vector(31 downto 0);
    
    project_i         : out from_PROJECT_IO_t;
    project_o         : in to_PROJECT_IO_t;
    platform_i        : out from_PLATFORM_IO_t;
    platform_o        : in to_PLATFORM_IO_t;
    target_i          : out from_TARGET_IO_t;
    target_o          : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

begin

  -- hook up Burched SRAM module
  GEN_D: for i in 0 to 7 generate
    platform_i.sram_i.d(i) <= gpio_0_i(35-i);
    gpio_0_o(35-i) <= platform_o.sram_o.d(i);
    gpio_0_o(27-i) <= 'Z';
  end generate;
  GEN_A: for i in 0 to 15 generate
    gpio_0_o(17-i) <= platform_o.sram_o.a(i);
  end generate;
  gpio_0_o(1) <= '0';                         -- A16
  gpio_0_o(0) <= '0';                         -- CEAn
  gpio_0_o(18) <= '1';                        -- upper byte WEn
  gpio_0_o(19) <= not platform_o.sram_o.we;   -- lower byte WEn
  
  -- signal drivers
  GEN_D_OE : for i in 0 to 7 generate
    gpio_0_oe(35-i) <= platform_o.sram_o.we;
    gpio_0_oe(27-i) <= '0';
  end generate;
  GEN_A_OE : for i in 0 to 15 generate
    gpio_0_oe(17-i) <= '1';
  end generate;
  gpio_0_oe(1) <= '1';
  gpio_0_oe(0) <= '1';
  gpio_0_oe(18) <= '1';
  gpio_0_oe(19) <= '1';
  
  -- is_custom drivers
  gpio_0_is_custom <= (others => '1');
  gpio_1_is_custom <= (others => '0');

  seg7(31 downto 16) <= X"6ACE";
  seg7(15 downto 0) <= platform_o.seg7;
  
end architecture SYN;
