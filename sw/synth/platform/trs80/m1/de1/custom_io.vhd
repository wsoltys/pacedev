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
    seg7              : out std_logic_vector(15 downto 0);
    
    -- SD card
		sd_dat            : inout std_logic;
		sd_dat3           : inout std_logic;
		sd_cmd            : inout std_logic;
		sd_clk            : out std_logic;

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

  gpio_0_is_custom <= (others => '0');
  gpio_1_is_custom <= (others => '0');

  seg7 <= X"dACE";

  GEN_BARTLETT_IDE : if TRS80_M1_HAS_HDD generate

    signal clk_25M          : std_logic := '0';
  
    signal sd_dat_i         : std_logic_vector(3 downto 0) := (others => '0');
    signal sd_dat_o         : std_logic_vector(3 downto 0);
    signal sd_dat_oe        : std_logic;
    signal sd_cmd_i         : std_logic := '0';
    signal sd_cmd_o         : std_logic;
    signal sd_cmd_oe        : std_logic;
    
  begin
  
--    sd_pll_inst : entity work.sd_pll
--      port map
--      (
--        inclk0		  => platform_o.clk_50M,
--        c0		      => open,      -- 50MHz
--        c1		      => clk_25M,
--        locked		  => open
--      );

    clk_25M <= platform_o.clk_25M;
    
    sd_if : entity work.ide_sd
      generic map
      (
        LBA_MODE          => false,
        HEAD_BITS         => 3,         -- 8 heads
        SECTOR_BITS       => 5,         -- 32 sectors
        ID_INIT_FILE      => "../../../../../src/platform/coco1/roms/identifydevice.hex"
      )
      port map
      (
        -- clocking, reset
        clk               => platform_o.clk,
        clk_ena           => '1',
        rst               => platform_o.rst,
        
        -- IDE interface
        iordy0_cf         => platform_i.iordy0_cf,
        rdy_irq_cf        => platform_i.rdy_irq_cf,
        cd_cf             => open,
        a_cf              => platform_o.a_cf,
        nce_cf            => platform_o.nce_cf,
        d_i               => platform_i.dd_i,
        d_o               => platform_o.dd_o,
        d_oe              => platform_o.dd_oe,
        nior0_cf          => platform_o.nior0_cf,
        niow0_cf          => platform_o.niow0_cf,
        non_cf            => platform_o.non_cf,
        nreset_cf         => platform_o.nreset_cf,
        ndmack_cf         => '0',
        dmarq_cf          => open,
        
        -- SD/MMC interface
        clk_25M           => clk_25M,
        sd_dat_i          => sd_dat_i,
        sd_dat_o          => sd_dat_o,
        sd_dat_oe         => sd_dat_oe,
        sd_cmd_i          => sd_cmd_i,
        sd_cmd_o          => sd_cmd_o,
        sd_cmd_oe         => sd_cmd_oe,
        sd_clk            => sd_clk
      );

    -- SD/MMC drivers
    sd_dat_i(0) <= sd_dat;
    sd_dat <= sd_dat_o(0) when sd_dat_oe = '1' else 'Z';
    sd_dat_i(3) <= sd_dat3;
    --sd_dat3 <= sd_dat_o(3) when sd_dat_oe = '1' else 'Z';
    sd_dat3 <= '1';
    sd_cmd_i <= sd_cmd;
    sd_cmd <= sd_cmd_o when sd_cmd_oe = '1' else 'Z';
    
  end generate GEN_BARTLETT_IDE; 

end architecture SYN;
